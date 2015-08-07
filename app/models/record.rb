require 'csv'
require 'ipaddr'

class Record < ActiveRecord::Base
  def self.import(folder='./HDR/ac-1400_192.168.10.38_192.168.10.36_000000001_20150709150750_HDR_V8.csv')
    CSV.foreach(folder, headers: true) do |row|
      row = row.to_h

      # t.column :client_ip, :bigint
      # t.integer :client_port
      #
      # t.column  :destination_ip, :bigint
      # t.integer :destination_port
      #
      # t.datetime :session_start
      # t.datetime :session_end
      #
      # t.integer :bytes_sent
      # t.integer :bytes_received
      #
      # t.string  :url
      # t.string  :domain

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
      r.save
    end
  end

  def self.search(params)
    records = Record.all

    sym = params[:client_ip]
    records = Record.where(client_ip: IPAddr.new(sym).ipv4_mapped.to_i) if sym.present?

    sym = params[:client_port]
    records = records.where(client_port: sym) if sym.present?

    sym = params[:domain]
    # records = records.where(domain: sym) if sym.present?
    records = records.where('domain like ?', "%#{sym}%") if sym.present?

    records
  end

  def ip_to_int(int)

  end
end
