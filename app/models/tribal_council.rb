class TribalCouncil < ActiveRecord::Base
  extend Scrapable
  filename 'SearchTC.aspx'

  has_many :nations

  validates_uniqueness_of :number

  def self.scrape_detail
    {
      name: 'ctl00_txtName',
      operating_name: 'ctl00_txtOperatingName',
      number: 'ctl00_txtNumber',
      address: 'ctl00_txtAddress',
      city: 'ctl00_txtCity',
      postal_code: 'ctl00_txtPostal',
      country: 'ctl00_txtCountry',
      geographic_zone: 'ctl00_txtZone',
      environmental_index: 'ctl00_txtEnvironmentalIndex',
    }.each do |attribute,id|
      if id['anchor']
        item[attribute] = doc.at_css('#' + id).andand[:href]
      else
        item[attribute] = doc.at_css('#' + id).andand.text
      end
    end
    item.tribal_council_id = doc.at_css('#ctl00_hlTCNumber').andand.text
    item.save!
  end
end
