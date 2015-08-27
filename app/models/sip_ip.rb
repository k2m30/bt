class SipIp < ActiveRecord::Base
  has_many :calls

  def self.import(properties_file = 'config/sip.yml')
    conn = ActiveRecord::Base.connection.raw_connection
    properties = YAML.load(File.open(properties_file))
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
end