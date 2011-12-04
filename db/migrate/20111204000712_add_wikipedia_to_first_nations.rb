class AddWikipediaToFirstNations < ActiveRecord::Migration
  def change
    add_column :first_nations, :wikipedia, :string
  end
end
