class MemberOfParliament < ActiveRecord::Base
  BASE_URL = 'http://www.parl.gc.ca/MembersOfParliament/'

  has_many :reserves
  has_many :addressings
  has_many :addresses, through: :addressings

  validates_uniqueness_of :constituency

  def self.scrape_list
    doc = Scrapable::Helpers.get 'http://www.parl.gc.ca/MembersOfParliament/MainMPsCompleteList.aspx?TimePeriod=Current&Language=E'
    doc.css('#MasterPage_MasterPage_BodyContent_PageContent_Content_ListContent_ListContent_grdCompleteList tr:gt(1').each do |tr|
      member_of_parliament = find_or_create_by_constituency(tr.at_css('td:eq(2)').text, detail_url: BASE_URL + tr.at_css('td:eq(1) a')[:href])
      member_of_parliament.save! if member_of_parliament.new_record?
    end
  end

  def self.scrape_details
    all.each do |item|
      item.scrape_detail
      item.save!
    end
  end

  def scrape_detail
    # @todo constituency_number
    doc = Scrapable::Helpers.parse detail_url
    self.name = doc.at_css('#MasterPage_TombstoneContent_TombstoneContent_ucHeaderMP_lblMPNameData').text[/\A(?:Right Hon\. |Hon\. )?(.+)\z/]

    src = doc.at_css('#MasterPage_TombstoneContent_TombstoneContent_ucHeaderMP_imgPhoto')[:src]
    unless src == 'Images/BlankMPPhoto.GIF'
      self.photo_url = "http://www.parl.gc.ca/MembersOfParliament/#{src}"
    end

    { caucus: 'MasterPage_TombstoneContent_TombstoneContent_ucHeaderMP_hlCaucusWebSite',
      email: 'MasterPage_DetailsContent_DetailsContent_ctl00_hlEMail',
      web: 'MasterPage_DetailsContent_DetailsContent_ctl00_hlWebSite',
      preferred_language: 'MasterPage_DetailsContent_DetailsContent_ctl00_lblPrefLanguageData',
    }.each do |attribute,id|
      self[attribute] = doc.at_css('#' + id).andand.text
    end

    # @todo addressings
    #kind
    #address
    #city
    #region
    #postal_code
    #tel
    #fax
  end
end
