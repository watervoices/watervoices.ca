class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :m # markdown text
  
  protected
  
  # markdown to html
  def m(text)
    RDiscount.new(text.to_s).to_html.html_safe
  end
  
  def post_to_map(report)
    #report = Report.find(:all).first
    if reserve = report.reserve
      c = Curl::Easy.http_post("http://maps.watervoices.ca/Ushahidi_Web/api",
                           Curl::PostField.content('task', 'report'),
                           Curl::PostField.content('incident_title', report.title),
                           Curl::PostField.content('incident_description', report.message),
                           Curl::PostField.content('incident_date', report.created_at.strftime("%m/%d/%Y")),
                           Curl::PostField.content('incident_hour', report.created_at.strftime("%I")),
                           Curl::PostField.content('incident_minute', report.created_at.strftime("%M")),
                           Curl::PostField.content('incident_ampm', report.created_at.strftime("%p").downcase),
                           Curl::PostField.content('incident_category', 1),
                           Curl::PostField.content('latitude', 43.6481),
                           Curl::PostField.content('longitude', 79.4042),
                           Curl::PostField.content('location_name', reserve.name))
      puts c.body_str
    end
  end
  
end
