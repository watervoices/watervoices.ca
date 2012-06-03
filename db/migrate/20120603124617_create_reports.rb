class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.references :reserve
      t.string :title
      t.int :status
      t.text :message

      t.timestamps
    end
    add_index :reports, :reserve_id
  end
end
