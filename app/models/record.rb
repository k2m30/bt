require 'csv'
require 'ipaddr'
require 'benchmark'
require 'parallel'
require 'smarter_csv'


class Record < ActiveRecord::Base
  def self.import(folder='HDR')
    t = Time.now
    p t
    t_csv = 0
    t_save = 0
    Dir["#{folder}/*"][0..9].each do |file|
      csv = []
      CSV.foreach(file, headers: true) do |row|
        dt_csv = Time.now
        row = row.to_h

        r = Record.new
        r.client_ip = (IPAddr.new row['ClientIP']).to_i
        r.client_port = row['ClientPort'].to_i

        r.destination_ip = (IPAddr.new row['ServerIP']).to_i
        r.destination_port = row['ServerPort'].to_i

        r.session_start = row['StartTime']
        r.session_end = r.session_start + row['Duration'].to_i

        r.bytes_sent = row['UploadContentLength']
        r.bytes_received = row['DownloadContentLength']

        r.url = row['URI']
        r.domain = row['RequestHeader.Host']
        r.domain ||= ''
        # r.save
        csv << r
        t_csv += Time.now - dt_csv
      end
      dt_save = Time.now
      csv.each(&:save)
      t_save += Time.now - dt_save
      p file

    end
    t1 = Time.now
    p t1
    p t1 - t
    p [t_csv, t_save]
  end

  def self.direct_import(folder='HDR')
    conn = ActiveRecord::Base.connection.raw_connection
    properties = YAML.load(File.open('config/properties.yml'))
    folder = properties['import_folder']

    time_to_transform = Benchmark.realtime do
      conn.transaction do
        conn.copy_data "COPY records (client_ip, client_port, destination_ip, destination_port, session_start, session_end, bytes_sent, bytes_received, url, domain) FROM STDIN CSV" do
          Dir["#{folder}/*.csv"].each do |file|
            CSV.foreach(file, headers: true) do |row|
              row = row.to_h
              conn.put_copy_data "#{row['ClientIP']},#{row['ClientPort']},#{row['ServerIP']},#{row['ServerPort']},#{row['StartTime']},#{(row['StartTime'].to_datetime+row['Duration'].to_i)},#{row['UploadContentLength']},#{row['DownloadContentLength']},\"#{row['URI'].nil? ? '' : URI.escape(row['URI'])}\",#{row['RequestHeader.Host']}\n"
            end
          end
        end
      end
    end
    p time_to_transform
  end

  def self.parallel
    ActiveRecord::Base.connection.reconnect!
    properties = YAML.load(File.open('config/properties.yml'))
    folder = properties['import_folder']
    processes = properties['processes']

    time_to_transform = Benchmark.realtime do
      Parallel.map(Dir["#{folder}/*.csv"], in_processes: processes) do |file|
        hashes = CSV.read(file, headers: true)
        worker(hashes)

        unless properties['leave_as_is']
          if properties['delete']
            FileUtils.rm "#{file}"
          else
            FileUtils.move "#{file}", "#{properties['move_to_folder']}"
          end
        end
      end
    end
    p time_to_transform
    ActiveRecord::Base.connection.reconnect!
    p Record.count
    p properties
  end

  def self.worker(hashes)
    config = Rails.configuration.database_configuration[Rails.env]
    conn = PG.connect(dbname: config['database'], host: config['host'], port: config['port'])
    conn.transaction do
      conn.async_exec("COPY records (client_ip, client_port, destination_ip, destination_port, session_start, session_end, bytes_sent, bytes_received, url, domain) FROM STDIN CSV")
      hashes.each do |row|
        conn.put_copy_data "#{row['ClientIP']},#{row['ClientPort']},#{row['ServerIP']},#{row['ServerPort']},#{row['StartTime']},#{(row['StartTime'].to_datetime+row['Duration'].to_i)},#{row['UploadContentLength']},#{row['DownloadContentLength']},\"#{row['URI'].nil? ? '' : URI.escape(row['URI'])}\",#{row['RequestHeader.Host']}\n"
      end
      conn.put_copy_end
    end
    conn.finish
  end

  def self.search(params)
    records = Record.all

    sym = params[:client_ip]
    if sym.present?
      sym.gsub! ' ',''
      ip = IPAddr.new sym
      sym = '::ffff:'+sym if ip.ipv4?
      records = Record.where(client_ip: sym)
    end

    sym = params[:client_port]
    records = records.where(client_port: sym) if sym.present?

    sym = params[:destination_ip]
    if sym.present?
      ip = IPAddr.new sym
      sym = '::ffff:'+sym if ip.ipv4?
      records = records.where(destination_ip: sym)
    end

    sym = params[:destination_port]
    records = records.where(destination_port: sym) if sym.present?

    sym = params[:dmn]
    # records = records.where(domain: sym) if sym.present?
    records = records.where('domain similar to ?', sym) if sym.present?

    sym = params[:session_start]
    records = records.where('session_start >= ?', sym.to_datetime) if sym.present?

    sym = params[:session_end]
    records = records.where('session_end <= ?', sym.to_datetime) if sym.present?

    sym = params[:bytes_sent_from]
    records = records.where('bytes_sent >= ?', sym) if sym.present?

    sym = params[:bytes_sent_to]
    records = records.where('bytes_sent <= ?', sym) if sym.present?

    sym = params[:bytes_received_from]
    records = records.where('bytes_received >= ?', sym) if sym.present?

    sym = params[:bytes_received_to]
    records = records.where('bytes_received <= ?', sym) if sym.present?

    sym = params[:url]
    # records = records.where(url: sym) if sym.present?
    records = records.where('url similar to ?', sym) if sym.present?

    records
  end

end
