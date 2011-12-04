class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :kind
      t.string :address
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :tel
      t.string :fax

      t.timestamps
    end
  end
end
