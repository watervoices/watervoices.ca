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
