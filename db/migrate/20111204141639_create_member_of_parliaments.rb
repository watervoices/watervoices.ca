class CreateMemberOfParliaments < ActiveRecord::Migration
  def change
    create_table :member_of_parliaments do |t|
      t.string :caucus
      t.string :email
      t.string :web
      t.string :preferred_language
      t.string :twitter
      t.string :constituency
      t.string :constituency_number
      t.string :photo_url
      t.string :source_url

      t.timestamps
    end
  end
end
