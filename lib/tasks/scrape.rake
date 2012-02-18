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

namespace :members_of_parliament do
  desc 'Scrape members of parliament list'
  task :list => :environment do
    MemberOfParliament.scrape_list
  end

  desc 'Scrape members of parliament details'
  task :details => :environment do
    MemberOfParliament.scrape_details
  end
end

# @todo update these figures
# @note 582 are found using Google Maps links on Aboriginal Canada.
#   Another 25 from GeoCommons.
#   Another 4 from KML.
#   Another 369 from Statcan census subdivisions.
namespace :location do
  require 'csv'
  require 'open-uri'
  require 'unicode_utils/upcase'

  NAME_MAP = {
    # Meaningful parentheses
    'BEATON RIVER 204, SOUTH HALF'                              => 'BEATON RIVER 204 (NORTH HALF)',
    'BEATON RIVER NO. 204, NORTH HALF'                          => 'BEATON RIVER 204 (SOUTH HALF)',
    'BIG HOLE TRACT INDIAN RESERVE NO. 8 (NORTH HALF)'          => 'BIG HOLE TRACT 8 (NORTH HALF)',
    'BIG HOLE TRACT INDIAN RESERVE NO. 8 (SOUTH HALF)'          => 'BIG HOLE TRACT 8 (SOUTH HALF)',

    # Major differences
    'ONE HUNDRED FIVE MILE POST 2'                              => '105 MILE POST 2',
    'FOUR AND ONE HALF MILE 2'                                  => '4 1/2 MILE 2',
    'ANAHIMS FLAT 1'                                            => "ANAHIM'S FLAT 1",
    "BIHL' K' A 18"                                             => "BIHL' K'A 18",
    'BIRDTAIL HAYLANDS 57A'                                     => 'BIRDTAIL HAY LANDS 57A',
    'CHIPPEWA OF THE THAMES FIRST NATION INDIAN RESERVE NO. 42' => 'CHIPPEWA OF THE THAMES FIRST NATION INDIAN RESERVE',
    'FORT VERMILLION 173B'                                      => 'FORT VERMILION 173B',
    'FOX LAKE EAST 2'                                           => 'FOX LAKE 2',
    "GRIZZLY BEAR'S HEAD & LEAN MAN I.R.'S 110 & 111"           => "GRIZZLY BEAR'S HEAD 110 & LEAN MAN 111",
    'HOLLOW WATER 10'                                           => 'HOLE OR HOLLOW WATER 10',
  }

  def locate(name, latitude, longitude, options = {})
    reserve = Reserve.find_by_name name
    if reserve.nil?
      if NAME_MAP[name]
        reserve = Reserve.find_by_name NAME_MAP[name]
        puts %("#{name}" no longer maps to "#{NAME_MAP[name]}") if reserve.nil?
      end
      if reserve.nil?
        reserve = Reserve.find_by_fingerprint Reserve.fingerprint(name)
        puts %("Couldn't find #{name}") if reserve.nil?
      end
    end
    if reserve
      reserve.set_latitude_and_longitude latitude, longitude, options
    end
  end

  # Reserve locations from Canada Lands Survey System
  # http://clss.nrcan.gc.ca/googledata-donneesgoogle-eng.php
  desc 'Import coordinates from Canada Lands Survey System'
  task :clss => :environment do
    Zip::ZipInputStream.open(open('http://clss-satc.nrcan-rncan.gc.ca/data-donnees/kml/placemarks-eng.kmz')) do |io|
      while entry = io.get_next_entry
        if entry.name == 'doc.kml'
          Nokogiri::XML(io.read, nil, 'utf-8').css('Folder').each do |folder|
            puts %(Processing "#{folder.at_css('name').text}" folder)
            folder.css('Placemark').each do |placemark|
              longitude, latitude = placemark.at_css('coordinates').text.split(',')
              locate placemark.at_css('name').text, latitude, longitude, force: true
            end
          end
          break
        end
      end
    end
  end

  # Census subdivision boundaries from Statistics Canada
  # http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-eng.cfm
  desc 'Import coordinates from Statistics Canada census subdivisions'
  task :statcan => :environment do
    # The CSV is longer than the list of reserves (5252 vs. 3216), so we don't
    # use the +locate+ method in this case to avoid too many debug messages.
    csv = {}
    CSV.open(File.join(Rails.root, 'data', 'statcan.gc.ca.csv'), headers: true, col_sep: "\t").each do |row|
      csv[UnicodeUtils.upcase(row['CSDNAME'])] = row
    end

    Reserve.all.each do |reserve|
      if csv[reserve.name]
        longitude, latitude = csv[reserve.name]['wkt_geom'].match(/\APOINT\(([0-9.-]+) ([0-9.-]+)\)\z/)[1..2]
        reserve.set_latitude_and_longitude latitude, longitude
      end
    end
  end

  # Aboriginal Communities and Friendship Centres in Google Earth
  # KML description is address and Aboriginal Canada Portal URL.
  # http://www.aboriginalcanada.gc.ca/acp/site.nsf/eng/ao36276.html
  desc 'Import coordinates from Aboriginal Canada KML'
  task :kml => :environment do
    Zip::ZipInputStream.open(open('http://www.aboriginalcanada.gc.ca/acp/community/site.nsf/vDownload/ge/$file/AboriginalCommunities_and_FriendshipCentres-CAN-V02-en.kmz')) do |io|
      while entry = io.get_next_entry
        if entry.name == 'AboriginalCommunities_and_FriendshipCentres-CAN-V02-en.kml'
          Nokogiri::XML(io.read).css('Placemark').each do |placemark|
            longitude, latitude = placemark.at_css('coordinates').text.split(',')
            locate UnicodeUtils.upcase(placemark.at_css('name').text), latitude, longitude
          end
        end
        break
      end
    end
  end

  # GeoCommons datasets by Steven DeRoy
  # http://geocommons.com/users/sderoy/overlays
  desc 'Import coordinates from GeoCommons'
  task :geocommons => :environment do
    Dir[File.join(Rails.root, 'data', 'geocommons.com', '* First Nations.csv')].each do |filename|
      CSV.foreach(filename, headers: true) do |row|
        locate UnicodeUtils.upcase(row['name'].gsub('&apos;', "'")), row['latitude'], row['longitude']
      end
    end
  end
end

namespace :twitter do
  require 'csv'
  desc 'Add Twitter accounts for Members of Parliament'
  task :members_of_parliament => :environment do
    CSV.foreach(File.join(Rails.root, 'data', 'federal.csv'), headers: true, encoding: 'utf-8') do |row|
      begin
        matches = [MemberOfParliament.find_by_constituency(row['Riding']) || MemberOfParliament.where('constituency LIKE ?', "#{row['Riding']}%").all].flatten
        if matches.size > 1
          puts %(Many matches for constituency "#{row['Riding']}": #{matches.map(&:constituency).to_sentence})
        elsif matches.size == 1
          unless matches.first.name == row['Name']
            puts %("#{matches.first.name}" (stored) doesn't match "#{row['Name']}")
          end
          matches.first.update_attribute :twitter, "http://twitter.com/#{row['Twitter'].sub(/\A@/, '')}"
        else
          puts %(No match for constituency "#{row['Riding']}")
        end
      end
    end
  end
end

namespace :districts do
  desc 'Find federal electoral district for each reserve'
  task :lookup => :environment do
    Reserve.geocoded.all.each do |reserve|
      response = JSON.parse(RestClient.get 'http://api.vote.ca/api/beta/districts', params: {lat: reserve.latitude, lng: reserve.longitude})
      federal = response.find{|x| x['electoral_group']['level'] == 'Federal'}
      if federal
        begin
          reserve.update_attribute :member_of_parliament_id, MemberOfParliament.find_by_constituency!(federal['name']).id
        rescue ActiveRecord::RecordNotFound
          puts %(No match for constituency "#{federal['name']}")
        end
      else
        puts %(No match for reserve "#{reserve.name}" (#{reserve.number}))
      end
    end
  end
end
