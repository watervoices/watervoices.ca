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
    if network == "SMS"
      # save message
      message_m = Message.new({:text => message, :from => from, :from_id => from_id, :network => network, :reserve => reserve})
      message_m.save
      # save message as a report to be displayed on map
      report = Report.new({:reserve => reserve, :title => reserve.try(:name) || 'Water Crisis', :status => true, :message => message || 'Please help.'})
      report.save!
      post_to_map(report)
      # render
      #render :json => Tropo::Generator.say("Message received")
      render :json => {:status => 200}
    else
      #render :json => Tropo::Generator.say("Unsupported operation")
      render :json => {:status => 500}
    end
  end

  def parse(message)
    reserve_name = message.scan(/^[0-9A-Z ]+/).first
    if reserve_name.present?
      reserve_name = reserve_name.string
      #reserve_name = "105 MILE POST 2"
      reserve = Reserve.find_by_sql("SELECT * FROM reserves WHERE levenshtein(LOWER(reserves.name), '#{reserve_name.downcase}') < 4;")
      return reserve.first
    else
      return nil
    end
  end


end
