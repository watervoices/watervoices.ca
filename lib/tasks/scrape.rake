# coding: utf-8

namespace :tribal_councils do
  desc 'Scrape tribal councils list'
  task :list => :environment do
    TribalCouncil.scrape_list
  end

  desc 'Scrape tribal councils details'
  task :details => :environment do
    TribalCouncil.scrape_details
  end
end

namespace :first_nations do
  desc 'Scrape First Nations list'
  task :list => :environment do
    FirstNation.scrape_list
  end

  desc 'Scrape First Nations details'
  task :details => :environment do
    FirstNation.scrape_details
  end

  desc 'Scrape First Nations data from Aboriginal Canada'
  task :extra => :environment do
    FirstNation.all.each do |item|
      item.scrape_extra
      item.save!
    end
  end
end

namespace :reserves do
  desc 'Scrape reserves list'
  task :list => :environment do
    Reserve.scrape_list
  end

  desc 'Scrape reserves details'
  task :details => :environment do
    Reserve.scrape_details
  end

  desc 'Scrape reserves data from Aboriginal Canada'
  task :extra => :environment do
    Reserve.all.each do |item|
      item.scrape_extra
      item.save!
    end
  end
end

namespace :geocode do
  require 'csv'
  require 'unicode_utils/upcase'

  def geocode(name, latitude, longitude)
    reserve = Reserve.find_by_name name
    if reserve
      reserve.set_latitude_and_longitude latitude, longitude
    else
      alt = (name.split(' ') - %w(COUNCIL FIRST GOVERNMENT NATION NATIONS RESERVE SETTLEMENT TREATY)).join(' ')
      matches = Reserve.where('name LIKE ?', "%#{alt}%").all.map(&:name)
      case matches.size
      when 1
        #puts "#{name.rjust(45)}  #{matches.first}"
      when 0
        #puts "Couldn't find '#{name}' (searching '#{alt}')"
      else
        #puts "Couldn't find '#{name}': searching '#{alt}':"
        #puts matches
      end
    end
  end

  desc 'Import coordinates from Statistics Canada subdivisions'
  task :statcan => :environment do
    csv = CSV.read(File.join(Rails.root, 'data', 'statcan.gc.ca.csv'), headers: true, col_sep: "\t")
    Reserve.where(latitude: nil).all.each do |reserve|
      if csv.find{|x| x['CSDNAME'] == reserve.name}
        puts "FOUND #{reserve.name}"
      else

      end
    end
  end

  desc 'Import coordinates from Aboriginal Canada KML'
  task :kml => :environment do
    Nokogiri::XML(File.read(File.join(Rails.root, 'data', 'aboriginalcanada.gc.ca.kml'))).css('Placemark').each do |placemark|
      name = UnicodeUtils.upcase placemark.at_css('name').text
      longitude, latitude = placemark.at_css('coordinates').text.split(',')
      geocode name, longitude, latitude
      # @todo placemark.at_css('description').text
    end
  end

  desc 'Import coordinates from GeoCommons'
  task :geocommons => :environment do
    Dir[File.join(Rails.root, 'data', '* First Nations.csv')].each do |filename|
      CSV.foreach(filename, headers: true) do |row|
        geocode UnicodeUtils.upcase row['name'].gsub('&apos;', "'"), row['latitude'], row['longitude']
      end
    end
  end
end
