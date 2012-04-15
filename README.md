# Getting Started

    git clone git://github.com/jpmckinney/watervoices.ca.git
    cd watervoices.ca
    bundle
    bundle exec rake db:setup
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
    bundle exec rake other:statcan
    bundle exec rake other:twitter
    bundle exec rake other:districts
    bundle exec rake other:assessment
    bundle exec rake other:broadband

# Deployment

[Create a Heroku account](http://heroku.com/signup) and setup SSH keys as described on [Getting Started with Heroku](http://devcenter.heroku.com/articles/quickstart).

    gem install heroku
    heroku create --stack cedar APP_NAME
    git push heroku master
    heroku db:push
    heroku addons:add custom_domains:basic
    heroku addons:add logging:expanded
    heroku addons:add pgbackups:auto-month
    heroku addons:add releases:basic
    heroku addons:add custom_error_pages

# Export Data

    bundle exec rake export:tribal_councils
    bundle exec rake export:first_nations
    bundle exec rake export:reserves
    bundle exec rake export:members_of_parliament
    bundle exec rake export:data_rows

# Data Sources

* [First Nation profiles from Aboriginal Affairs and Northern Development Canada](http://pse5-esd5.ainc-inac.gc.ca/fnp/Main/Index.aspx?lang=eng)
* [Aboriginal community information from Aboriginal Canada Portal](http://www.aboriginalcanada.gc.ca/acp/community/site.nsf/index_en.html?OpenPage)
* [National Assessment of Water and Wastewater Systems in First Nation Communities](http://www.aadnc-aandc.gc.ca/eng/1313426883501/1313426958782)
* [Canadian MPs on Twitter from Politwitter.ca](http://politwitter.ca/page/canadian-politics-twitters/mp/house)
* [GeoBase Aboriginal Lands](http://clss.nrcan.gc.ca/geobase-eng.php)
* [Census Subdivisions from Statistics Canada](http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-eng.cfm)
