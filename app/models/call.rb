class Call < ActiveRecord::Base
  has_and_belongs_to_many :ips, counter_cache: true

  def self.import(properties_file='config/calls.yml')
    properties = YAML.load(File.open(properties_file))
    folder = properties['import_folder']
    time_to_transform = Benchmark.realtime do
      Dir["#{folder}/**/*.csv"].each do |file|
        csv = []
        p file
        CSV.foreach(file, headers: true, col_sep: ',', quote_char: "\x00") do |row|
          row = row.to_h
          #Start Time,Call Identifier,Source Ip,Caller,Destination Ip,Callee,Call duration,Call Start time,Status at end,Response Code,Response Description,Proto,Request to,Call Type
          c = Call.new
          c.start_time = row['Start Time']
          c.call_identifier = row['Call Identifier']

          source_ip = IPAddr.new(row['Source Ip'].gsub(/[^\d+\.]/, ''))
          ip = Ip.find_by(ip: source_ip, source: true) || Ip.create(ip: source_ip, source: true)
          c.ips << ip
          c.caller = row['Caller']

          destination_ip = IPAddr.new(row['Destination Ip'].gsub(/[^\dx+\.]/, ''))
          ip = Ip.find_by(ip: destination_ip, source: false) || Ip.create(ip: destination_ip, source: false)
          c.ips << ip
          c.callee = row['Callee']

          c.duration = row['Call duration']
          c.status_at_end = row['Status at end']
          c.response_code = row['Response Code']
          c.response_description = row['Response Description']
          c.proto = row['Proto']
          c.request_to = row['Request to']
          c.call_type = row['Call Type']
          # r.save
          csv << c
        end
        csv.each(&:save)
      end
    end
    p time_to_transform
  end

  def self.search(params)
    calls = all

    sym = params[:source_ip]
    if sym.present?
      sym.gsub! ' ', ''
      # ip = IPAddr.new sym
      # sym = '::ffff:'+sym if ip.ipv4?
      calls = Call.joins(:ips).where(ips: {ip: sym, source: true})
    end

    sym = params[:destination_ip]
    if sym.present?
      sym.gsub! ' ', ''
      #ip = IPAddr.new sym
      # sym = '::ffff:'+sym if ip.ipv4?
      calls = Call.joins(:ips).where(ips: {ip: sym, source: false})
    end

    sym = params[:caller]
    calls = calls.where('caller similar to ?', "%#{sym}%") if sym.present?

    sym = params[:callee]
    calls = calls.where('callee similar to ?', "%#{sym}%") if sym.present?

    sym = params[:start_time_from]
    calls = calls.where('start_time >= ?', sym.to_datetime) if sym.present?

    sym = params[:start_time_to]
    calls = calls.where('start_time <= ?', sym.to_datetime) if sym.present?

    calls.order(start_time: :desc)

  end

end