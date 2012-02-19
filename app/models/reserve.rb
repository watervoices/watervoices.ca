# coding: utf-8
class Reserve < ActiveRecord::Base
  include Scrapable
  filename 'SearchRV.aspx'
  attributes name: 'ctl00_txtReserveName',
    number: 'ctl00_txtReserveNumber',
    location: 'ctl00_txtLocation',
    hectares: 'ctl00_txtHectares'

  belongs_to :member_of_parliament
  has_many :nation_memberships
  has_many :first_nations, through: :nation_memberships, dependent: :destroy

  serialize :connectivity
  validates_uniqueness_of :number

  scope :unscraped, where(name: nil)
  scope :nongeocoded, where(latitude: nil)
  scope :geocoded, where('latitude IS NOT NULL')
  scope :unrepresented, where(member_of_parliament_id: nil)

  COMMON_WORDS = [
    'BAND\b',
    'C\.N\.',
    'COMMUNITY\b',
    'CREE FIRST NATION\b',
    'CREE NATION\b',
    'FIRST NATION\b',
    'FN\b',
    'I\.R\.',
    'INDIAN\b',
    'IR\b',
    'ISLAND\b',
    'NAKODA\b',
    'NO\.',
    'NO\b', # must come after NO.
    'RESERVE\b',
    'RIVER\b',
    'SETTLEMENT\b',
    'TIMBER LIMIT\b',
  ]

  def geocoded?
    latitude? && longitude?
  end

  # @param [String] string a string
  # @return [String] the string with dashes, accents, and parenthesized and
  #   common words removed, and with standardized conjunctions and identifiers.
  def self.fingerprint(string)
    string.gsub(/(\S)\(/, '\1 (').gsub('’', "'").gsub('&', 'AND').gsub(/\b(\d{1,3})[ -]([A-Z])\z/, '\1\2').gsub(/(?: (?:\([^)]{3,}\)|#{COMMON_WORDS.join '|'}))/, ' ').gsub(/[#-]/, ' ').squeeze(' ').strip.tr(
      "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
      "AAAAAAAAAAAAAAAAAACCCCCCCCCCDDDDDDEEEEEEEEEEEEEEEEEEGGGGGGGGHHHHIIIIIIIIIIIIIIIIIIJJKKKLLLLLLLLLLNNNNNNNNNNNOOOOOOOOOOOOOOOOOORRRRRRSSSSSSSSSTTTTTTUUUUUUUUUUUUUUUUUUUUWWYYYYYYZZZZZZ")
  end

  def set_latitude_and_longitude(lat, lng, options = {})
    if not geocoded? or options[:force]
      self.latitude = lat
      self.longitude = lng
      save!
    end
  end

  def aboriginal_url
    'http://www.aboriginalcanada.gc.ca/acp/community/site.nsf/eng/rn%05d.html' % number
  end

  def scrape_detail
    super
    self.name = self.name.squeeze(' ').gsub(/(\S)\(/, '\1 (')
    self.fingerprint = Reserve.fingerprint name
    self.first_nations = FirstNation.find_all_by_number(doc.css('#ctl00_dgFNlist td:first a').map{|a| a.text})
  end

  def scrape_extra
    begin
      doc = Scrapable::Helpers.parse aboriginal_url
      self.statcan_url = doc.at_css('a[href*="statcan"]').andand[:href]

      a = doc.at_css('a[href*="maps.google.com"]')
      self.latitude, self.longitude = URI.parse(a[:href]).query.match(/\bq=([0-9.-]+),([0-9.-]+)/)[1..2] if a

      a = doc.at_css('a[href*="connectivitysurvey.nsf"]')
      if a
        self.connectivity_url = 'http://www.aboriginalcanada.gc.ca/' + a[:href]
        doc = Scrapable::Helpers.parse connectivity_url

        tds = doc.css('td')
        self.connectivity = {}

        [ 'Band Administration Office Internet Connectivity Type',
          'Is that Internet Access available to Community Members ?',
          'Connectivity Status',
          'Number of SchoolNet Sites',
          'SchoolNet Internet Connectivity Type',
          'Police Detachment Internet Access Availability',
          'Community Access Point available at',
          'Does the FC have a CAP Site?',
          'FC Internet Connectivity Type',
          'Residential Internet Access Availability',
          'Percentage of Households that Subscribe to the Internet',
          'Expected Internet Availability by the end of 2007',
        ].each do |label|
          value = tds.find{|x|x.text == label}.next_element.text.gsub(/[[:space:]]/, ' ').strip.capitalize
          value[0] = value[0].capitalize if value.present?
          value = '' if ['No Connection', 'none available'].include? value
          self.connectivity[label] = value
        end
      end
    rescue RestClient::ResourceNotFound => e
      puts %(404 for reserve "#{name}" (#{number}) on aboriginalcanada.gc.ca)
    end
  end
end
