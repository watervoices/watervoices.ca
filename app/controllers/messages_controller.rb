class MessagesController < ApplicationController
  # needs better error validations

  # Tropo
  # POST to /messages/
  def index
    message = params["session"]["initialText"]
    from = params["session"]["from"]
    network = from["network"]
    from_id = from["id"]
    reserve = parse(message)
    if network == "SMS" && !reserve.nil?
      # save message
      message_m = Message.new({:text => message, :from => from, :from_id => from_id, :network => network, :reserve_id => reserve.id})
      message_m.save
      # save message as a report to be displayed on map
      report = Report.new({:reserve_id => reserve.id, :title => reserve.name, :status => true, :message => message})
      report.save
      # render
      #render :json => Tropo::Generator.say("Message received")
      render :json => {:status => 200}
    else
      #render :json => Tropo::Generator.say("Unsupported operation")
      render :json => {:status => 500}
    end
  end

  def parse(message)
    reserve_name = message.match(/^[0-9A-Z ]+/)
    if !reserve_name.nil?
      reserve_name = reserve_name.string
      #reserve_name = "105 MILE POST 2"
      reserve = Reserve.find_by_sql("SELECT * FROM reserves WHERE levenshtein(LOWER(reserves.name), '#{reserve_name.downcase}') < 4;")
      return reserve.first
    else
      return nil
    end
  end

  def post_to_map()
    report = Report.find(:all).first
    reserve = Reserve.find(:first, :conditions => {:id => report.reserve_id})
    c = Curl::Easy.perform("http://maps.watervoices.ca/Ushahidi_Web/reports/submit?incident_title=#{report.title}&incident_description=#{report.message}&incident_category=#{report.status}&location_name=#{reserve.location}")
    puts c.body_str
  end  

end
