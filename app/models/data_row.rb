class DataRow < ActiveRecord::Base
  belongs_to :first_nation
  belongs_to :reserve

  serialize :data
end
