# Getting Started

    git clone git://github.com/jpmckinney/watervoices.ca.git
    bundle
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake members_of_parliament:list
    bundle exec rake tribal_councils:list
    bundle exec rake first_nations:list
    bundle exec rake reserves:list
    bundle exec rake members_of_parliament:details
    bundle exec rake tribal_councils:details
    bundle exec rake first_nations:details
    bundle exec rake reserves:details
    bundle exec rake first_nations:extra
    bundle exec rake reserves:extra
    bundle exec rake other:locate
    bundle exec rake other:twitter
    bundle exec rake other:districts
    bundle exec rake other:assessment

# Deployment

    gem install heroku
    heroku create --stack cedar APP_NAME
    git push heroku master
    heroku run rake db:migrate
    heroku run rake members_of_parliament:list
    heroku run rake tribal_councils:list
    heroku run rake first_nations:list
    heroku run rake reserves:list
    heroku run rake members_of_parliament:details
    heroku run rake tribal_councils:details
    heroku run rake first_nations:details
    heroku run rake reserves:details
    heroku run rake first_nations:extra
    heroku run rake reserves:extra
    heroku run rake other:locate
    heroku run rake other:twitter
    heroku run rake other:districts
    heroku run rake other:assessment

Or, if you already ran the scraping tasks locally:

    heroku db:push

# Data Sources

* [First Nation profiles from Aboriginal Affairs and Northern Development Canada](http://pse5-esd5.ainc-inac.gc.ca/fnp/Main/Index.aspx?lang=eng)
* [Aboriginal community information from Aboriginal Canada Portal](http://www.aboriginalcanada.gc.ca/acp/community/site.nsf/index_en.html?OpenPage)
* [National Assessment of Water and Wastewater Systems in First Nation Communities](http://www.aadnc-aandc.gc.ca/eng/1313426883501/1313426958782)
* [Canadian MPs on Twitter from Politwitter.ca](http://politwitter.ca/page/canadian-politics-twitters/mp/house)
* [GeoBase Aboriginal Lands](http://clss.nrcan.gc.ca/geobase-eng.php)
