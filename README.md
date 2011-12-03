# Getting Started

git clone git://github.com/jpmckinney/watervoices.ca.git
bundle
bundle exec rake db:migrate
bundle exec rake tribal_councils:list
bundle exec rake tribal_councils:details
bundle exec rake first_nations:list
bundle exec rake first_nations:details
bundle exec rake reserves:list
bundle exec rake reserves:details
