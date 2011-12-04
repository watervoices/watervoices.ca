class CreateAddressings < ActiveRecord::Migration
  def change
    create_table :addressings do |t|
      t.references :member_of_parliament
      t.references :address

      t.timestamps
    end
    add_index :addressings, :member_of_parliament_id
    add_index :addressings, :address_id
  end
end
