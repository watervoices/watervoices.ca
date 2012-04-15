# coding: utf-8

namespace :export do
  require 'csv'

  def export(model, columns, rows = [], basename = nil)
    skipped = model.columns.map(&:name) - columns - %w(created_at updated_at)
    puts "Not exporting #{skipped.to_sentence} from #{model.name}" unless skipped.empty?

    if rows.empty?
      rows = [columns]
      model.all(select: columns).each do |o|
        rows << o.attributes.values
      end
    end

    filename = File.join(Rails.root, 'tmp', basename || model.name.underscore)

    # BOM, etc. tricks don't work in Excel 2011 for Mac
    CSV.open("#{filename}.csv", 'w') do |csv|
      rows.each do |row|
        csv << row
      end
    end

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    rows.each_with_index do |row,i|
      sheet1.row(i).concat row
    end
    book.write "#{filename}.xls"
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
    columns = %w(id member_of_parliament_id name number location hectares latitude longitude connectivity_url statcan_url detail_url)
    select = columns + ['connectivity']

    reserves = Reserve.all(select: select)

    keys = reserves.find(&:connectivity).connectivity.keys
    rows = [columns + keys]
    reserves.each do |o|
      attributes = o.attributes
      connectivity = attributes.delete 'connectivity'
      values = connectivity ? connectivity.values : [nil] * keys.size
      rows << attributes.values + values
    end

    export Reserve, select, rows
  end

  # @note constituency_number is empty
  desc 'Export members of parliament'
  task :members_of_parliament => :environment do
    export MemberOfParliament, %w(id name constituency caucus email twitter preferred_language web photo_url detail_url)
  end

  desc 'Export data rows'
  task :data_rows => :environment do
    columns = %w(table first_nation_id reserve_id)
    select = columns + ['data']

    %w(D1 D2 E1 E2 F Coverage).each do |table|
      data_rows = DataRow.where(table: table)

      keys = data_rows.first.data.keys.map(&:to_s)
      rows = [columns + keys]
      data_rows.each do |o|
        attributes = o.attributes.slice(*select)
        data = attributes.delete 'data'
        values = data.values
        rows << attributes.values + values
      end

      export DataRow, select, rows, table
    end
  end
end
