class Address < ActiveRecord::Base
  has_many :addressings
  has_many :member_of_parliaments, through: :addressings
end
