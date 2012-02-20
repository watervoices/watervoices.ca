class AddFingerprintToReserves < ActiveRecord::Migration
  def up
    add_column :reserves, :fingerprint, :string
    Reserve.all.each do |o|
      o.update_attribute :fingerprint, o.class.fingerprint(o.name)
    end
  end

  def down
    remove_column :reserves, :fingerprint
  end
end
