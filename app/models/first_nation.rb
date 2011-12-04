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
    'http://pse5-esd5.ainc-inac.gc.ca/fnp/Main/Search/FNGovernance.aspx?BAND_NUMBER=%s&lang=eng' % number
  end

  def scrape_detail
    super
    self.tribal_council = TribalCouncil.find_by_number(doc.at_css('#ctl00_hlTCNumber').andand.text)

    gov = Scrapable::Helpers.parse governance_url
    { membership_authority: 'ctl00_txtAuthority',
      election_system: 'ctl00_txtElection',
      quorum: 'ctl00_txtQuorum',
    }.each do |attribute,id|
      self[attribute] = gov.at_css('#' + id).andand.text
    end

    gov.css('tr:gt(1)').each do |tr|
      surname = tr.at_css('td:eq(2)').text
      given_name = tr.at_css('td:eq(3)').text

      official = officials.find_or_initialize_by_surname_and_given_name(surname, given_name)
      official.attributes = {
        title: tr.at_css('td:eq(1)').text,
        surname: surname,
        given_name: given_name,
        appointed_on: (Date.strptime(tr.at_css('td:eq(4)').text, '%m/%d/%Y') rescue nil),
        expires_on: (Date.strptime(tr.at_css('td:eq(5)').text, '%m/%d/%Y') rescue nil),
      }
    end
  end

  def scrape_extra
    begin
      doc = Scrapable::Helpers.parse 'http://www.aboriginalcanada.gc.ca/acp/community/site.nsf/eng/fn%d.html' % number
      self.wikipedia = doc.at_css('a[href*="wikipedia.org"]').andand[:href]

      # @note Not optimal to change state here, but okay.
      if tribal_council
        a = doc.css('a').find{|x| x.text == 'Tribal Council Homepage'}
        tribal_council.update_attribute :url, a[:href] if a
      end
    rescue RestClient::ResourceNotFound => e
      puts "404 for First Nation '#{name}' (#{number}) on aboriginalcanada.gc.ca"
    end
  end
end
