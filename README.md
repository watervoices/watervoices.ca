# Getting Started

    git clone git://github.com/jpmckinney/watervoices.ca.git
    bundle
    bundle exec rake db:migrate
    bundle exec rake tribal_councils:list
    bundle exec rake tribal_councils:details
    bundle exec rake first_nations:list
    bundle exec rake first_nations:details
    bundle exec rake first_nations:extra
    bundle exec rake reserves:list
    bundle exec rake reserves:details
    bundle exec rake reserves:extra

# Deployment

    gem install heroku
    heroku create --stack cedar APP_NAME
    git push heroku master
    heroku run rake db:migrate
    heroku run rake tribal_councils:list
    heroku run rake tribal_councils:details
    heroku run rake first_nations:list
    heroku run rake first_nations:details
    heroku run rake first_nations:extra
    heroku run rake reserves:list
    heroku run rake reserves:details
    heroku run rake reserves:extra

# Data Sources

* [First Nation profiles from Aboriginal Affairs and Northern Development Canada](http://pse5-esd5.ainc-inac.gc.ca/fnp/Main/Index.aspx?lang=eng)
* [Aboriginal community information from Aboriginal Canada Portal](http://www.aboriginalcanada.gc.ca/acp/community/site.nsf/index_en.html?OpenPage)
* [Aboriginal Communities and Friendship Centres in Google Earth](http://www.aboriginalcanada.gc.ca/acp/site.nsf/eng/ao36276.html)
* [Census subdivision boundaries from Statistics Canada](http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-eng.cfm)
* [GeoCommons datasets by Steven DeRoy](http://geocommons.com/users/sderoy/overlays)
