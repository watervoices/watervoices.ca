class AddColumnsToOfficials < ActiveRecord::Migration
  def change
    add_column :officials, :first_nation_id, :integer
  end
end
