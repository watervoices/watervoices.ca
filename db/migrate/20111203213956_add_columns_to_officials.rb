class AddColumnsToOfficials < ActiveRecord::Migration
  def change
    add_column :officials, :first_nation, :references
  end
end
