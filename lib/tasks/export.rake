# coding: utf-8

namespace :export do
  require 'csv'

  def export(model, attributes)
    basename = File.join(Rails.root, 'tmp', model.name.underscore)

    rows = [attributes]
    model.all(select: attributes).each do |o|
      rows << o.attributes.values
    end

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

  # @note has one foreign key
  desc 'Export first nations'
  task :first_nations => :environment do
    export FirstNation, %w(id tribal_council_id name number address postal_code phone fax membership_authority election_system quorum aboriginal_canada_portal wikipedia url detail_url)
  end

  # @note has one foreign key and one habtm, omitting connectivity
  desc 'Export reserves'
  task :reserves => :environment do
    export Reserve, %w(id member_of_parliament_id name number location hectares latitude longitude connectivity_url statcan_url detail_url)
  end

  desc 'Export members of parliament'
  task :members_of_parliament => :environment do
    export MemberOfParliament, %w(id name constituency caucus email twitter preferred_language web photo_url detail_url)
  end
end
