class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|

      t.column :client_ip, :bigint
      t.integer :client_port

      t.column  :destination_ip, :bigint
      t.integer :destination_port

      t.datetime :session_start
      t.datetime :session_end

      t.integer :bytes_sent
      t.integer :bytes_received

      t.string  :url
      t.string  :domain

    end
    add_index :records, :client_ip
  end
end
