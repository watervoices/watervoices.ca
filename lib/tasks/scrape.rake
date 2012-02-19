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
    'BEATON RIVER 204, SOUTH HALF'                     => 'BEATON RIVER 204 (NORTH HALF)',
    'BEATON RIVER NO. 204, NORTH HALF'                 => 'BEATON RIVER 204 (SOUTH HALF)',
    'BIG HOLE TRACT INDIAN RESERVE NO. 8 (NORTH HALF)' => 'BIG HOLE TRACT 8 (NORTH HALF)',
    'BIG HOLE TRACT INDIAN RESERVE NO. 8 (SOUTH HALF)' => 'BIG HOLE TRACT 8 (SOUTH HALF)',

    # Whitespace
    'BIRDTAIL HAYLANDS 57A'   => 'BIRDTAIL HAY LANDS 57A',
    "BIHL' K' A 18"           => "BIHL' K'A 18",
    'S 1/2 TSIMPSEAN 2'       => 'S1/2 TSIMPSEAN 2',
    'STARBLANKET I.R. 83'     => 'STAR BLANKET 83',
    'SWEETGRASS I.R. 113'     => 'SWEET GRASS 113',
    'SWEETGRASS I.R. 113-O28' => 'SWEET GRASS 113-028', # typo
    'SWEETGRASS I.R. 113-C19' => 'SWEET GRASS 113-C19',
    'SWEETGRASS I.R. 113-C7'  => 'SWEET GRASS 113-C7',
    'SWEETGRASS I.R. 113-F16' => 'SWEET GRASS 113-F16',
    'SWEETGRASS I.R. 113-G7'  => 'SWEET GRASS 113-G7',
    'SWEETGRASS I.R. 113-I4'  => 'SWEET GRASS 113-I4',
    'SWEETGRASS I.R. 113-K32' => 'SWEET GRASS 113-K32',
    'SWEETGRASS I.R. 113-L6'  => 'SWEET GRASS 113-L6',
    'SWEETGRASS I.R. 113-M16' => 'SWEET GRASS 113-M16',
    'SWEETGRASS I.R. 113-N27' => 'SWEET GRASS 113-N27',
    'SWEETGRASS I.R. 113-P2'  => 'SWEET GRASS 113-P2',
    'SWEETGRASS I.R. 113A'    => 'SWEET GRASS 113A',
    'SWEETGRASS I.R. 113B'    => 'SWEET GRASS 113B',
    'YELLOW QUILL I.R. 90' => 'YELLOWQUILL 90',

    # Punctuation
    'ANAHIMS FLAT 1'                   => "ANAHIM'S FLAT 1",
    'MISSISSAUGAS OF SCUGOG ISLAND'    => "MISSISSAUGA'S OF SCUGOG ISLAND",
    'ST. BASILE INDIAN RESERVE NO. 10' => 'ST BASILE 10',
    'ST. THERESA POINT'                => 'ST THERESA POINT',

    # Typos (fingerprint with edit distance = 1)
    'FORT VERMILLION 173B'                        => 'FORT VERMILION 173B',
    'KEESEEKOOSE I.R. 66-CO-01'                   => 'KEESEEKOOSE 66-CO-O1',
    'KEHIWIN 123'                                 => 'KEHEWIN 123',
    'KINOOSAO-THOMAS CLARKE I.R. 204'             => 'KINOOSAO-THOMAS CLARK 204',
    'LYACKSON 3'                                  => 'LYACKSUN 3',
    'MAGNETAWAN INDIAN RESERVE NO. 1'             => 'MAGNETEWAN 1',
    'OLD CLEMENES 16'                             => 'OLD CLEMENS 16',
    'ONIKAHP SAHGNIKANSIS INDIAN RESERVE NO 165E' => 'ONIKAHP SAHGHIKANSIS 165E',
    'PARSNIPS 5'                                  => 'PARSNIP 5',
    'STONEY 142, 143, 144' => 'STONEY 142-143-144',
    'VILLAGE ISLANDS 7' => 'VILLAGE ISLAND 7',

    # Abbreviations
    'SAUGEEN AND CAPE CROKER FISHING ISLANDS INDIAN RESERVE NO. 1' => 'SAUGEEN & CAPE CROKER FISHING ISL. 1',
    'ST. JOE 10' => 'SAINT JOE 10',

    # Extra numbers
    'NEYAASHIINIGMIING RESERVE'                                 => 'NEYAASHIINIGMIING 27',
    'CHIPPEWA OF THE THAMES FIRST NATION INDIAN RESERVE NO. 42' => 'CHIPPEWA OF THE THAMES FIRST NATION INDIAN RESERVE',
    'OPASKWAYAK CREE NATION ROCKY LAKE INDIAN RESERVE NO. 1'    => 'OPASKWAYAK CREE NATION ROCKY LAKE',
    'WIKWEMIKONG UNCEDED INDIAN RESERVE NO. 26'                 => 'WIKWEMIKONG UNCEDED RESERVE',
    'WILLOW CREE INDIAN RSERVE'                                 => 'WILLOW CREE',

    # Other (fingerprint with edit distance > 1)
    "(DEADMAN'S ISLAND) HALKETT ISLAND NO. 2"         => "DEADMAN'S) HALKETT ISLAND NO. 2",
    'ONE HUNDRED FIVE MILE POST 2'                    => '105 MILE POST 2',
    'FOUR AND ONE HALF MILE 2'                        => '4 1/2 MILE 2',
    'FOX LAKE EAST 2'                                 => 'FOX LAKE 2',
    "GRIZZLY BEAR'S HEAD & LEAN MAN I.R.'S 110 & 111" => "GRIZZLY BEAR'S HEAD 110 & LEAN MAN 111",
    'HOLLOW WATER 10'                                 => 'HOLE OR HOLLOW WATER 10',
    'PEIGAN TIMBER LIMIT 147B'                        => 'PEIGAN TIMBER LIMIT "B"',
    'ROSEAU RIVER ANISHINABE 2B'                      => 'ROSEAU RIVER 2B',
    'RÉSERVE DE WÔLINAK  NO. 11'                      => 'WÔLINAK 11',
  }

  def locate(name, latitude, longitude, options = {})
    reserve = Reserve.find_by_name name
    if reserve.nil?
      if NAME_MAP[name]
        reserve = Reserve.find_by_name NAME_MAP[name]
        puts %("#{name}" no longer maps to "#{NAME_MAP[name]}") if reserve.nil?
      end
      if reserve.nil?
        fingerprint = Reserve.fingerprint(name)
        reserve = Reserve.find_by_fingerprint fingerprint
        puts %(Couldn't find #{name.ljust 60} #{fingerprint}) if reserve.nil?
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
            name = folder.at_css('name').text
            next if ['Type', 'Subdivision', 'National Park'].include? name
            placemarks = folder.css('Placemark')
            puts %(Processing "#{name}" folder (#{placemarks.size}))
            placemarks.each do |placemark|
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

namespace :other do
  desc 'Find federal electoral district for each reserve'
  task :districts => :environment do
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

  # National Assessment of Water and Wastewater Systems in First Nation Communities
  # http://www.aadnc-aandc.gc.ca/eng/1313426883501
  desc 'Get National Assessment data or each reserve'
  task :assessment => :environment do
    headers = {
      # Water System Information, Storage Information, Distribution System Information
      D1: %w(
        band_number band_name system_number system_name water_source
        treatment_class construction_year design_capacity actual_capacity
        max_daily_volume disinfection storage_type storage_capacity
        distribution_class population_served homes_piped homes_trucked
        number_of_trucks_in_service pipe_length pipe_length_per_connection
      ).map(&:to_sym),
      # Wastewater System Information
      D2: %w(
        band_number band_name system_number system_name construction_year
        receiver_name treatment_class design_capacity max_daily_volume
        wastewater_system_type wastewater_treatment_level
        wastewater_disinfection_chlorine wastewater_disinfection_uv
        discharge_frequency wastewater_sludge_treatment
      ).map(&:to_sym),
      E1: %w(
        band_number band_name system_number system_name water_source
        treatment_class source_risk design_risk operations_risk report_risk
        operator_risk final_risk_score
      ).map(&:to_sym),
      E2: %w(
        band_number band_name system_number system_name receiver_type
        treatment_class effluent_risk design_risk operations_risk report_risk
        operator_risk final_risk_score
      ).map(&:to_sym),
      F: %w(
        band_number band_name community_name current_population current_homes
        forecast_population forecast_homes zone_markup upgrade_to_protocol
        per_lot_upgrade_to_protocol recommended_servicing
        per_lot_recommended_servicing recommended_om per_lot_om
      ).map(&:to_sym),
    }
    offsets = {
      D1: 2,
      D2: 2,
      E1: 1,
      E2: 1,
      F: 1,
    }
    {
      'Atlantic' => {
        D1: 1314113533397,
        D2: 1314110702660,
        E1: 1314109175095,
        E2: 1314107811990,
        F: 1314107279728,
      },
      'Quebec' => {
        D1: 1314803394499,
        D2: 1314805074731,
        E1: 1314805939008,
        E2: 1314806422379,
        F: 1314806747219,
      },
      'Ontario' => {
        D1: 1314980372889,
        D2: 1314983298779,
        E1: 1314985112423,
        E2: 1314986491857,
        F: 1314987205360,
      },
      'Manitoba' => {
        D1: 1315323828369,
        D2: 1315325682402,
        E1: 1315326602568,
        E2: 1315326972669,
        F: 1315327625229,
      },
      'Saskatchewan' => {
        D1: 1315530975150,
        D2: 1315532271829,
        E1: 1315533276055,
        E2: 1315533694498,
        F: 1315534873076,
      },
      'Alberta' => {
        D1: 1315504260472,
        D2: 1315507039750,
        E1: 1315508036194,
        E2: 1315508624010,
        F: 1315509237811,
      },
      'British Columbia' => {
        D1: 1315616544441,
        D2: 1315618492442,
        E1: 1315621253969,
        E2: 1315621659651,
        F: 1315622140396,
      },
      'Yukon' => {
        D1: 1315613380808,
        D2: 1315614663440,
        E1: 1315615248425,
        E2: 1315615615822,
        F: 1315616040456,
      },
    }.each do |region,tables|
      puts "Scraping #{region} tables..."
      tables.each do |name,id|
        doc = Scrapable::Helpers.parse "http://www.aadnc-aandc.gc.ca/eng/#{id}"
        data = {}
        doc.css('table.widthFull').each_with_index do |table,i|
          table.css("tr:gt(#{offsets[name]})").each_with_index do |tr,j|
            data[j] ||= []
            data[j] += tr.css(i.zero? ? 'td' : 'td:gt(2)').map do |td|
              text = td.text.sub /\A[[:space:]]+\z/, ''
              number = text.gsub(/[$,]/, '')
              if number[/\A-?\d+\z/]
                Integer number
              elsif number[/\A-?[\d.]+\z/]
                Float number
              else
                text
              end
            end
          end
        end
        rows = []
        data.each do |_,values|
          rows << Hash[headers[name].zip(values)] # @todo save record instead
        end
      end
    end
  end
end
