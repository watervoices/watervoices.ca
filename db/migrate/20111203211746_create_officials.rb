class CreateOfficials < ActiveRecord::Migration
  def change
    create_table :officials do |t|
      t.string :title
      t.string :surname
      t.string :given_name
      t.date :appointed_on
      t.date :expires_on

      t.timestamps
    end
  end
end
