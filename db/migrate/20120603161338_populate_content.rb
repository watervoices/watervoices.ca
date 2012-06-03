class PopulateContent < ActiveRecord::Migration
  def up
    # HOME PAGE
    set_content('home.body.title', 'Welcome to WaterVoices.ca')
    set_content('home.head.title', 'Welcome to WaterVoices')
    set_content('home.subtitle', 'Subtitle')
    set_content('home.body', 'A brief summary of what watervoices is about')

    # RESOURCES PAGE
    set_content('resources.body.title', 'Welcome to WaterVoices.ca')
    set_content('resources.head.title', 'Welcome to WaterVoices')
    set_content('resources.body', 'Resources page body')

    # MISSION PAGE
    set_content('mission.body.title', 'Welcome to WaterVoices.ca')
    set_content('mission.head.title', 'Welcome to WaterVoices')
    set_content('mission.body', 'Mission page body')
  end

  def down
    # no down
  end
  
  protected
  
  def set_content(key, value)
    c = Content.where(:key => key).first || Content.new(:key => key)
    c.body = value
    c.save
  end
  
end
