# coding: utf-8

namespace :export do
  require 'csv'

  def export(model, columns, rows = [])
    skipped = model.columns.map(&:name) - columns - %w(created_at updated_at)
    puts "Not exporting #{skipped.to_sentence} from #{model.name}" unless skipped.empty?

    if rows.empty?
      rows = [columns]
      model.all(select: columns).each do |o|
        rows << o.attributes.values
      end
    end

    basename = File.join(Rails.root, 'tmp', model.name.underscore)

    # BOM, etc. tricks don't work in Excel 2011 for Mac
    CSV.open("#{basename}.csv", 'w') do |csv|
      rows.each do |row|
        csv << row
      end
    end

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    rows.each_with_index do |row,i|
      sheet1.row(i).concat row
    end
    book.write "#{basename}.xls"
  end

  # @note operating_name is empty
  desc 'Export tribal councils'
  task :tribal_councils => :environment do
    export TribalCouncil, %w(id name number address city postal_code country geographic_zone environmental_index url detail_url)
  end

  # @note includes one foreign key
  desc 'Export first nations'
  task :first_nations => :environment do
    export FirstNation, %w(id tribal_council_id name number address postal_code phone fax membership_authority election_system quorum aboriginal_canada_portal wikipedia url detail_url)
  end

  # @note includes one foreign key, omits one habtm
  desc 'Export reserves'
  task :reserves => :environment do
    columns = %w(id member_of_parliament_id name number location hectares latitude longitude connectivity connectivity_url statcan_url detail_url)
    reserves = Reserve.all(select: columns)

    keys = reserves.find(&:connectivity).connectivity.keys
    rows = [columns + keys]

    reserves.each do |o|
      attributes = o.attributes
      connectivity = attributes.delete 'connectivity'
      values = connectivity ? connectivity.values : [nil] * keys.size
      rows << attributes.values + values
    end

    export Reserve, columns, rows
  end

  # @note constituency_number is empty
  desc 'Export members of parliament'
  task :members_of_parliament => :environment do
    export MemberOfParliament, %w(id name constituency caucus email twitter preferred_language web photo_url detail_url)
  end
end
