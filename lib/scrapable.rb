module Scrapable
  def self.included(base)
    base.extend ClassMethods
  end

   # Temporarily stores the parsed document being scraped.
  def doc=(doc)
    @doc = doc
  end

  def doc
    @doc
  end

  # Scrapes one detail page.
  def scrape_detail
    self.doc = Scrapable::Helpers.parse detail_url
    self.class.attributes.each do |attribute,id|
      if id['anchor']
        self[attribute] = doc.at_css('#' + id).andand[:href]
      else
        self[attribute] = doc.at_css('#' + id).andand.text
      end
    end
  end

  module Helpers
    def self.parse(url)
      begin
        Nokogiri::HTML(RestClient.get(url))
      rescue Timeout::Error, RestClient::RequestTimeout, RestClient::ServerBrokeConnection
        puts "Timeout. Retrying in 2..."
        retry
      end
    end
  end

  module ClassMethods
    BASE_URL = 'http://pse5-esd5.ainc-inac.gc.ca/fnp/Main/Search/'

    # Sets the filename at which to start the scrape.
    def filename(filename = nil)
      @filename = filename if filename
      @filename
    end  
    alias :filename= :filename

    # Sets a mapping between attribute and HTML id.
    def attributes(attributes = nil)
      @attributes = attributes if attributes
      @attributes
    end
    alias :attributes= :attributes

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
      unscraped.each do |item|
        item.scrape_detail
        item.save!
      end
    end
  end
end
