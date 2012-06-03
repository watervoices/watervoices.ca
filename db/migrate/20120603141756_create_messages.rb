class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :text
      t.string :from
      t.string :from_id
      t.string :network
      t.references :reserve

      t.timestamps
    end
    add_index :messages, :reserve_id
  end
end
