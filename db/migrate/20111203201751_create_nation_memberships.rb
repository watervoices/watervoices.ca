class CreateNationMemberships < ActiveRecord::Migration
  def change
    create_table :nation_memberships do |t|
      t.references :first_nation
      t.references :reserve

      t.timestamps
    end
    add_index :nation_memberships, :first_nation_id
    add_index :nation_memberships, :reserve_id
  end
end
