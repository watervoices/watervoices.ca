class AddFingerprintToFirstNations < ActiveRecord::Migration
  def change
    add_column :first_nations, :fingerprint, :string
    FirstNation.all.each do |o|
      o.update_attribute :fingerprint, o.class.fingerprint(o.name)
    end
  end
end
