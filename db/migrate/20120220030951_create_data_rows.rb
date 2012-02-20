class CreateDataRows < ActiveRecord::Migration
  def change
    create_table :data_rows do |t|
      t.string :table
      t.text :data
      t.belongs_to :first_nation
      t.belongs_to :reserve

      t.timestamps
    end
    add_index :data_rows, :first_nation_id
    add_index :data_rows, :reserve_id
  end
end
