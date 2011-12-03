class Reserve < ActiveRecord::Base
  extend Scrapable
  filename 'SearchRV.aspx'
  attributes=
    name: 'ctl00_txtReserveName',
    number: 'ctl00_txtReserveNumber',
    location: 'ctl00_txtLocation',
    hectares: 'ctl00_txtHectares',

  has_many :nation_memberships
  has_many :nations, through: :nation_memberships, dependent: :destroy

  validates_uniqueness_of :number

  def scrape_detail
    super
    self.nation_ids = doc.at_css('#ctl00_dgFNlist td:first a').map{|a| a.text}
  end
end
