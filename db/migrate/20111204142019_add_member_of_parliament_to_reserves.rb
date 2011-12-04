class AddMemberOfParliamentToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :member_of_parliament_id, :integer
  end
end
