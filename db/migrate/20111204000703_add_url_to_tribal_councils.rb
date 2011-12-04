class AddUrlToTribalCouncils < ActiveRecord::Migration
  def change
    add_column :tribal_councils, :url, :string
  end
end
