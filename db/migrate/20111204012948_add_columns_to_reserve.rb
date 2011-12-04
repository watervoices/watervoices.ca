class AddColumnsToReserve < ActiveRecord::Migration
  def change
    add_column :reserves, :statcan_url, :string
    add_column :reserves, :latitude, :float
    add_column :reserves, :longitude, :float
    add_column :reserves, :connectivity, :text
  end
end
