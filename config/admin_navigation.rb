# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  # navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  navigation.selected_class = 'active'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  # navigation.active_leaf_class = 'your_active_leaf_class'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  navigation.autogenerate_item_ids = false

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  # navigation.name_generator = Proc.new {|name| "<span>#{name}</span>"}

  # The auto highlight feature is turned on by default.
  # This turns it off globally (for the whole plugin)
  # navigation.auto_highlight = false

  # Define the primary navigation
  navigation.items do |primary|
  
    primary.item :content, 'Content', '#' do |content|
      content.item :news_content, 'Home', admin_contents_path(:prefix => 'home'), :highlights_on => lambda { @nav == :contents && @prefix == 'home' }
      content.item :home_content, 'News', admin_contents_path(:prefix => 'news'), :highlights_on => lambda { @nav == :contents && @prefix == 'news' }
      content.item :courses_content, 'Courses', admin_contents_path(:prefix => 'courses'), :highlights_on => lambda { @nav == :contents && @prefix == 'courses' }
      content.item :about_content, 'About', admin_contents_path(:prefix => 'about'), :highlights_on => lambda { @nav == :contents && @prefix == 'about' }
      content.item :history_content, 'History', admin_contents_path(:prefix => 'history'), :highlights_on => lambda { @nav == :contents && @prefix == 'history' }
      content.item :contact_content, 'Contact', admin_contents_path(:prefix => 'contact'), :highlights_on => lambda { @nav == :contents && @prefix == 'contact' }
      content.item :resources_content, 'Resources', admin_contents_path(:prefix => 'resources'), :highlights_on => lambda { @nav == :contents && @prefix == 'resources' }
      content.item :jobs_content, 'Jobs', admin_contents_path(:prefix => 'jobs'), :highlights_on => lambda { @nav == :contents && @prefix == 'jobs' }
      content.item :instructors_content, 'Instructors', admin_contents_path(:prefix => 'instructors'), :highlights_on => lambda { @nav == :contents && @prefix == 'instructors' }
      content.item :graduates_content, 'Graduates', admin_contents_path(:prefix => 'graduates'), :highlights_on => lambda { @nav == :contents && @prefix == 'graduates' }
      content.item :enrollments_content, 'Enrollment', admin_contents_path(:prefix => 'enrollments'), :highlights_on => lambda { @nav == :contents && @prefix == 'enrollments' }
    end

    # You can also specify a condition-proc that needs to be fullfilled to display an item.
    # Conditions are part of the options. They are evaluated in the context of the views,
    # thus you can use all the methods and vars you have available in the views.

    # you can also specify a css id or class to attach to this particular level
    # works for all levels of the menu
    # primary.dom_id = 'menu-id'
    primary.dom_class = 'nav'

    # You can turn off auto highlighting for a specific level
    primary.auto_highlight = false

  end

end