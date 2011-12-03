class CreateTribalCouncils < ActiveRecord::Migration
  def change
    create_table :tribal_councils do |t|
      t.string :name
      t.string :operating_name
      t.integer :number
      t.string :address
      t.string :city
      t.string :postal_code
      t.string :country
      t.integer :geographic_zone
      t.string :environmental_index
      t.string :detail_url

      t.timestamps
    end
  end
end
