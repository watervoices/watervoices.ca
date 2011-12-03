class FirstNation < ActiveRecord::Base
  include Scrapable
  filename 'SearchFN.aspx'
  attributes name: 'ctl00_txtBandName',
    number: 'ctl00_txtBandNumber',
    address: 'ctl00_txtAddress',
    postal_code: 'ctl00_txtPostalCode',
    phone: 'ctl00_txtPhone',
    fax: 'ctl00_txtFax',
    url: 'ctl00_anchor1',
    aboriginal_canada_portal: 'ctl00_anchor2'

  belongs_to :tribal_council
  has_many :officials, dependent: :destroy
  has_many :nation_memberships
  has_many :reserves, through: :nation_memberships, dependent: :destroy

  validates_uniqueness_of :number

  def governance_url
    BASE_URL + 'FNGovernance.aspx?BAND_NUMBER=%s&lang=eng' % number
  end

  def scrape_detail
    super
    self.tribal_council = TribalCouncil.find_by_number(doc.at_css('#ctl00_hlTCNumber').andand.text)

    # @note This changes the doc, which can easily cause bugs if not careful.
    doc = Scrapable::Helpers.get governance_url
    {
      membership_authority: 'ctl00_txtAuthority',
      election_system: 'ctl00_txtElection',
      quorum: 'ctl00_txtQuorum',
    }.each do |attribute,id|
      self[attribute] = doc.at_css('#' + id).andand.text
    end

    Official.scrape_list doc
  end
end
