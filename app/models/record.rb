require 'csv'
require 'ipaddr'
require 'benchmark'

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
    time_to_transform = Benchmark.realtime do
      id = Record.count
      # begin
      conn.copy_data "COPY records FROM STDIN CSV" do
        Dir["#{folder}/*.csv"].each do |file|
          CSV.foreach(file, headers: true) do |row|
            id+=1
            row = row.to_h
            conn.put_copy_data "#{id},#{row['ClientIP']},#{row['ClientPort']},#{row['ServerIP']},#{row['ServerPort']},#{row['StartTime']},#{(row['StartTime'].to_datetime+row['Duration'].to_i)},#{row['UploadContentLength']},#{row['DownloadContentLength']},\"#{row['URI'].nil? ? '' : URI.escape(row['URI'])}\",#{row['RequestHeader.Host']}\n"
          end
        end
      end
      # rescue => e
      #   # /nvidia_web_services/controller.gfeclientcontent.php/com.nvidia.services.GFEClientContent.getShieldReady/{"gcV":"2.4.5.28","dID":"0FD3","osC":"6.10","
      #   p ['-----']
      #   p file_f
      #   p str
      #   p res
      #   p e.message
      #   pp e.backtrace[0..4]
      # end

    end
    p time_to_transform

  end

  def self.search(params)
    records = Record.all

    sym = params[:client_ip]
    records = Record.where(client_ip: sym) if sym.present?

    sym = params[:client_port]
    records = records.where(client_port: sym) if sym.present?

    sym = params[:destination_ip]
    records = records.where(destination_ip: sym) if sym.present?

    sym = params[:destination_port]
    records = records.where(destination_port: sym) if sym.present?

    sym = params[:domain]
    # records = records.where(domain: sym) if sym.present?
    records = records.where('domain like ?', "%#{sym}%") if sym.present?

    sym = params[:session_start_from]
    records = records.where('session_start >= ?', sym.to_datetime) if sym.present?

    sym = params[:session_end]
    records = records.where('session_end <=', {session_end: sym}) if sym.present?

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
    records = records.where('url like ?', "%#{sym}%") if sym.present?

    records
  end

end
