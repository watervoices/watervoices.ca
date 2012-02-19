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

# @note 582 are found using Google Maps links on Aboriginal Canada.
#   All but 175 from Canada Lands Survey System
#   Another 2 from GeoCommons
#   Another 2 from Aboriginal Communities and Friendship Centres in Google Earth
#   Another 11 from Statistics Canada Census subdivisions
namespace :other do
  require 'csv'

  # Reserve locations from Canada Lands Survey System
  # http://clss.nrcan.gc.ca/geobase-eng.php
  desc 'Import coordinates from Canada Lands Survey System'
  task :locate => :environment do
    filename = File.join(Rails.root, 'data', 'al_ta_ca_shp_eng', 'AL_TA_CA_2_22_eng.shp')
    if File.exist? filename
      RGeo::Shapefile::Reader.open(filename) do |file|
        file.each do |record|
          next if record['ALTYPE'] == 'Land Claim'
          reserve = Reserve.find_by_number record['ALCODE'].to_i
          if reserve
            centroid = record.geometry.centroid
            reserve.set_latitude_and_longitude centroid.y, centroid.x
          else
            puts "Couldn't find #{record['NAME1'].ljust 65}#{record['ALCODE']}"
          end
        end
      end
    else
      puts "You must download and unzip the Canada Lands Survey System shapefile to data/"
    end
  end

  desc 'Add Twitter accounts for Members of Parliament'
  task :twitter => :environment do
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

  desc 'Find federal electoral district for each reserve'
  task :districts => :environment do
    Reserve.geocoded.unrepresented.all.each do |reserve|
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
    data = {}
    headers = {
      # Individual First Nation Water Summary
      # Water System Information, Storage Information, Distribution System Information
      D1: %w(
        band_number band_name system_number system_name water_source
        treatment_class construction_year design_capacity actual_capacity
        max_daily_volume disinfection storage_type storage_capacity
        distribution_class population_served homes_piped homes_trucked
        number_of_trucks_in_service pipe_length pipe_length_per_connection
      ).map(&:to_sym),
      # Individual First Nation Wastewater Summary
      # Wastewater System Information
      D2: %w(
        band_number band_name system_number system_name construction_year
        receiver_name treatment_class design_capacity max_daily_volume
        wastewater_system_type wastewater_treatment_level
        wastewater_disinfection_chlorine wastewater_disinfection_uv
        discharge_frequency wastewater_sludge_treatment
      ).map(&:to_sym),
      # Individual First Nation Water Risk Summary
      E1: %w(
        band_number band_name system_number system_name water_source
        treatment_class source_risk design_risk operations_risk report_risk
        operator_risk final_risk_score
      ).map(&:to_sym),
      # Individual First Nation Wastewater Risk Summary
      E2: %w(
        band_number band_name system_number system_name receiver_type
        treatment_class effluent_risk design_risk operations_risk report_risk
        operator_risk final_risk_score
      ).map(&:to_sym),
      # Protocol and Servicing Costs
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
        puts "Scraping table #{name}..."
        data[name] ||= {}
        offset = data[name].size
        doc = Scrapable::Helpers.parse "http://www.aadnc-aandc.gc.ca/eng/#{id}"
        doc.css('table.widthFull').each_with_index do |table,i|
          table.css("tr:gt(#{offsets[name]})").each_with_index do |tr,j|
            data[name][j + offset] ||= []
            data[name][j + offset] += tr.css(i.zero? ? 'td' : 'td:gt(2)').map do |td|
              text = td.text.sub(/\A[[:space:]]+\z/, '').gsub(/(?<=\S)-[[:space:]]/, '').gsub("\n", ' ').squeeze(' ')
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
      end

      # @todo save record instead?
      data.each do |name,x|
        rows = []
        x.each do |_,values|
          rows << Hash[headers[name].zip(values)]
        end
        File.open("#{name}.yml", 'w') do |f|
          f.write Psych.dump(rows)
        end
      end
    end
  end
end
