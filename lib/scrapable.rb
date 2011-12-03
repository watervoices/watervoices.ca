module Scrapable
  BASE_URL = 'http://pse5-esd5.ainc-inac.gc.ca/fnp/Main/Search/'

  # Sets the filename at which to start the scrape.
  def filename(filename = nil)
    @filename = filename if filename
    @filename
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
      find_or_create_by_number!(a.text, detail_url: BASE_URL + a[:href]) if a
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
      item.scrape_detail Nokogiri::HTML(RestClient.get(item.detail_url))
    end
  end

  # Scrapes one detail page.
  def scrape_detail
    raise NotImplementedError
  end
end
