class AddFingerprintToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :fingerprint, :string
    Reserve.all.each do |reserve|
      reserve.update_attribute :fingerprint, Reserve.fingerprint(reserve.name)
    end
  end
end
