class CreateFirstNations < ActiveRecord::Migration
  def change
    create_table :first_nations do |t|
      t.string :name
      t.integer :number
      t.string :address
      t.string :postal_code
      t.string :phone
      t.string :fax
      t.string :url
      t.string :aboriginal_canada_portal
      t.references :tribal_council

      t.timestamps
    end
    add_index :first_nations, :tribal_council_id
  end
end
