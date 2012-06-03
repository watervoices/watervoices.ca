class Content < ActiveRecord::Base
  
  validates :key, :uniqueness => true

  scope :key_prefix, lambda {|prefix| where("contents.key LIKE '?%'", prefix)}
  
end
