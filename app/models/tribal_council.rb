class TribalCouncil < ActiveRecord::Base
  extend Scrapable
  filename 'SearchTC.aspx'

  has_many :nations

  validates_uniqueness_of :number

  def scrape_detail(doc)
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
        self[attribute] = doc.at_css('#' + id).andand[:href]
      else
        self[attribute] = doc.at_css('#' + id).andand.text
      end
    end
    save!
  end
end
