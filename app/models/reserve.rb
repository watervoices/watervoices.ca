class Reserve < ActiveRecord::Base
  include Scrapable
  filename 'SearchRV.aspx'
  attributes name: 'ctl00_txtReserveName',
    number: 'ctl00_txtReserveNumber',
    location: 'ctl00_txtLocation',
    hectares: 'ctl00_txtHectares'

  has_many :nation_memberships
  has_many :first_nations, through: :nation_memberships, dependent: :destroy

  validates_uniqueness_of :number

  def scrape_detail
    super
    self.first_nations = FirstNation.find_all_by_number(doc.css('#ctl00_dgFNlist td:first a').map{|a| a.text})
  end
end
