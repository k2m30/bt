class CreateSipIp < ActiveRecord::Migration
  def change
    create_table :sip_ips do |t|
      t.column :ip, :inet
      t.boolean :source
    end
  end
end
