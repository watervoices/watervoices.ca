module Scrapable
  def self.included(base)
    base.extend ClassMethods
  end

  # Temporarily stores the parsed document being scraped.
  attr_accessor :doc

  # Scrapes one detail page.
  def scrape_detail
    doc = Scrapable::Helpers.get detail_url
    @@attributes.each do |attribute,id|
      if id['anchor']
        self[attribute] = doc.at_css('#' + id).andand[:href]
      else
        self[attribute] = doc.at_css('#' + id).andand.text
      end
    end
  end

  module Helpers
    def get(url)
      Nokogiri::HTML(RestClient.get(url))
    end
  end

  module ClassMethods
    BASE_URL = 'http://pse5-esd5.ainc-inac.gc.ca/fnp/Main/Search/'

    alias :filename= :filename
    # Sets the filename at which to start the scrape.
    def filename(filename = nil)
      @filename = filename if filename
      @filename
    end  

    alias :attributes= :attributes
    # Sets a mapping between attribute and HTML id.
    def attributes(attributes = nil)
      @attributes = attributes if attributes
      @attributes
    end

    # Scrapes the list of items.
    def scrape_list
      agent = Mechanize.new
      page = agent.get(BASE_URL + @filename + '?lang=eng')

      form = page.forms.first
      form['__EVENTTARGET'] = 'ctl00$btnSearch'
      scrape_page form.submit
    end

    # Scrapes one page of the list of items.
    def scrape_page(page)
      page.parser.css('tr').each do |tr|
        a = tr.at_css('a')
        find_or_create_by_number(a.text, detail_url: BASE_URL + a[:href]) if a
      end

      if page.parser.at_css('#ctl00_btnNext')
        form = page.forms.first
        form['__EVENTTARGET'] = 'ctl00$btnNext'
        scrape_page form.submit
      end
    end

    # Scrapes the details pages.
    def scrape_details
      all.each do |item|
        item.scrape_detail
        item.save!
      end
    end
  end
end
