class Reserve < ActiveRecord::Base
  extend Scrapable
  filename 'SearchRV.aspx'

  has_many :nation_memberships
  has_many :nations, through: :nation_memberships

  validates_uniqueness_of :number

  def self.scrape_detail
    {
      name: 'ctl00_txtReserveName',
      number: 'ctl00_txtReserveNumber',
      location: 'ctl00_txtLocation',
      hectares: 'ctl00_txtHectares',
    }.each do |attribute,id|
      item[attribute] = doc.at_css('#' + id).andand.text
    end
    item.nation_ids = doc.at_css('#ctl00_dgFNlist td:first a').map{|a| a.text}
    item.save!
  end
end
