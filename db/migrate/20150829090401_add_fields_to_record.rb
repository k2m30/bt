class AddFieldsToRecord < ActiveRecord::Migration
  def change
    add_column :records, :subscriber_id, :string
    remove_column :records, :url
  end
end
