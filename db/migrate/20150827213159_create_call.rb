class CreateCall < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      # Start Time,Call Identifier,Source Ip,Caller,Destination Ip,Callee,Call duration,Call Start time,Status at end,Response Code,Response Description,Proto,Request to,Call Type
      t.belongs_to :sip_ip, index:true

      t.datetime :start_time #Start Time
      t.string :call_identifier #Call Identifier
      t.string :caller #Caller
      t.string :callee #Callee
      t.integer :duration #Call duration
      t.datetime :call_start_time #Call Start time
      t.string :status_at_end #Status at end
      t.string :response_code #Response Code
      t.string :response_description #Response Description

      t.string :proto #Proto
      t.string :request_to #Request to
      t.string :call_type #Call Type
    end
    add_index :calls, :start_time
  end
end
