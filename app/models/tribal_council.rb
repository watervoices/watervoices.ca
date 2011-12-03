class TribalCouncil < ActiveRecord::Base
  extend Scrapable
  filename 'SearchTC.aspx'
  attributes=
    name: 'ctl00_txtName',
    operating_name: 'ctl00_txtOperatingName',
    number: 'ctl00_txtNumber',
    address: 'ctl00_txtAddress',
    city: 'ctl00_txtCity',
    postal_code: 'ctl00_txtPostal',
    country: 'ctl00_txtCountry',
    geographic_zone: 'ctl00_txtZone',
    environmental_index: 'ctl00_txtEnvironmentalIndex',

  has_many :nations

  validates_uniqueness_of :number
end
