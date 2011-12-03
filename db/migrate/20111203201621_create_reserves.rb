class CreateReserves < ActiveRecord::Migration
  def change
    create_table :reserves do |t|
      t.string :name
      t.integer :number
      t.string :location
      t.float :hectares
      t.string :detail_url

      t.timestamps
    end
  end
end
