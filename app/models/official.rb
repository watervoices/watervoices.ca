class Official < ActiveRecord::Base
  belongs_to :first_nation

  def self.scrape_list(doc)
    doc.css('tr:gt(1)').each do |tr|
      Official.scrape_detail tr
    end
  end

  def self.scrape_detail(tr)
    surname = tr.at_css('td:eq(2)')
    given_name = tr.at_css('td:eq(3)')
    official = Official.find_or_build_by_surname_and_given_name(surname, given_name)
    official.attributes = {
      title: tr.at_css('td:eq(1)'),
      surname: surname,
      given_name: given_name,
      appointed_on: Date.strptime(tr.at_css('td:eq(4)'), '%m/%d/%Y'),
      expires_on: Date.strptime(tr.at_css('td:eq(5)'), '%m/%d/%Y'),
    }
    official.save!
  end
end
