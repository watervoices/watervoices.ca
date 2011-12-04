class Addressing < ActiveRecord::Base
  belongs_to :member_of_parliament
  belongs_to :address
end
