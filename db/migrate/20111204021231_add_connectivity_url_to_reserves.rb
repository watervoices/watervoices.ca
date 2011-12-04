class AddConnectivityUrlToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :connectivity_url, :string
  end
end
