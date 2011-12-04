class MemberOfParliament < ActiveRecord::Base
  BASE_URL = 'http://www.parl.gc.ca/MembersOfParliament/'

  has_many :reserves

  validates_uniqueness_of :constituency

  def self.scrape_list
    doc = Scrapable::Helpers.get 'http://www.parl.gc.ca/MembersOfParliament/MainMPsCompleteList.aspx?TimePeriod=Current&Language=E'
    doc.css('#MasterPage_MasterPage_BodyContent_PageContent_Content_ListContent_ListContent_grdCompleteList tr:gt(1').each do |tr|
      member_of_parliament = MemberOfParliament.find_or_create_by_constituency(tr.at_css('td:eq(2)').text, source_url: BASE_URL + tr.at_css('td:eq(1) a')[:href])
      member_of_parliament.save! if member_of_parliament.new_record?
    end
  end
end
