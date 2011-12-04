class AddIndexes < ActiveRecord::Migration
  def change
    add_index :tribal_councils, :number
    add_index :first_nations, :number
    add_index :reserves, :number
    add_index :reserves, :name
    add_index :member_of_parliaments, :constituency
    add_index :nation_memberships, [:first_nation_id, :reserve_id]
    add_index :officials, [:given_name, :surname, :first_nation_id]
  end
end
