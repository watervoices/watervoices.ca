class Official < ActiveRecord::Base
  belongs_to :first_nation

  validates_uniqueness_of :given_name, scope: [:surname, :first_nation_id]
end
