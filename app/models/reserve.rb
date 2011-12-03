class Reserve < ActiveRecord::Base
  extend Scrapable
  filename 'SearchRV.aspx'

  has_many :nation_memberships
  has_many :nations, through: :nation_memberships

  validates_uniqueness_of :number

  def scrape_detail(doc)
    {
      name: 'ctl00_txtReserveName',
      number: 'ctl00_txtReserveNumber',
      location: 'ctl00_txtLocation',
      hectares: 'ctl00_txtHectares',
    }.each do |attribute,id|
      self[attribute] = doc.at_css('#' + id).andand.text
    end
    self.nation_ids = doc.at_css('#ctl00_dgFNlist td:first a').map{|a| a.text}
    save!
  end
end
