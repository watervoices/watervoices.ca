class AddColumnsToFirstNations < ActiveRecord::Migration
  def change
    add_column :first_nations, :membership_authority, :string
    add_column :first_nations, :election_system, :string
    add_column :first_nations, :quorum, :integer
  end
end
