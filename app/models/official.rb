class Official < ActiveRecord::Base
  belongs_to :first_nation

  validates_uniqueness_of :given_name, scope: [:surname, :first_nation_id]

  def self.scrape_list(doc)
    doc.css('tr:gt(1)').each do |tr|
      Official.scrape_detail tr
    end
  end

  def self.scrape_detail(tr)
    surname = tr.at_css('td:eq(2)').text
    given_name = tr.at_css('td:eq(3)').text
    official = Official.find_or_initialize_by_surname_and_given_name(surname, given_name)
    official.attributes = {
      title: tr.at_css('td:eq(1)').text,
      surname: surname,
      given_name: given_name,
      appointed_on: Date.strptime(tr.at_css('td:eq(4)').text, '%m/%d/%Y'),
      expires_on: Date.strptime(tr.at_css('td:eq(5)').text, '%m/%d/%Y'),
    }
    official.save!
  end
end
