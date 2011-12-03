class FirstNation < ActiveRecord::Base
  extend Scrapable
  filename 'SearchFN.aspx'

  belongs_to :tribal_council
  has_many :nation_memberships
  has_many :reserves, through: :nation_memberships

  validates_uniqueness_of :number

  def self.scrape_detail
    {
      name: 'ctl00_txtBandName',
      number: 'ctl00_txtBandNumber',
      address: 'ctl00_txtAddress',
      postal_code: 'ctl00_txtPostalCode',
      phone: 'ctl00_txtPhone',
      fax: 'ctl00_txtFax',
      url: 'ctl00_anchor1',
      aboriginal_canada_portal: 'ctl00_anchor2',
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
