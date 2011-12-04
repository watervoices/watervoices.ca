class AlterMemberOfParliaments < ActiveRecord::Migration
  def change
    rename_column :member_of_parliaments, :source_url, :detail_url
    add_column :member_of_parliaments, :name, :string
  end
end
