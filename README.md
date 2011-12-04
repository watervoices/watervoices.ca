# Getting Started

git clone git://github.com/jpmckinney/watervoices.ca.git
bundle
bundle exec rake db:migrate
bundle exec rake tribal_councils:list
bundle exec rake tribal_councils:details
bundle exec rake tribal_councils:extra
bundle exec rake first_nations:list
bundle exec rake first_nations:details
bundle exec rake first_nations:extra
bundle exec rake reserves:list
bundle exec rake reserves:details
bundle exec rake reserves:extra

# Data Sources

* [First Nation profiles from Aboriginal Affairs and Northern Development Canada](http://pse5-esd5.ainc-inac.gc.ca/fnp/Main/Index.aspx?lang=eng)
* [Census subdivision boundaries from Statistics Canada](http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-eng.cfm)
* [Aboriginal community information from Aboriginal Canada Portal](http://www.aboriginalcanada.gc.ca/acp/community/site.nsf/index_en.html?OpenPage)
