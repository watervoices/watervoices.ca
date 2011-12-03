class NationMembership < ActiveRecord::Base
  belongs_to :first_nation
  belongs_to :reserve

  validates_uniqueness_of :first_nation_id, scope: :reserve_id
end
