class MessagesController < ApplicationController

  # Tropo
  # POST to /messages/
  def index
    message = params["session"]["initialText"]
    from = params["session"]["from"]
    network = from["network"]
    from_id = from["id"]
    if network == "SMS" && valid(message)
      # save message
      # save message as a report to be displayed on map
      render :json => Tropo::Generator.say("Message received")
    else
      render :json => Tropo::Generator.say("Unsupported operation")
    end
  end

  def valid(message)
    # do some parsing to extract the name of the reserve, check against reserves in db
    return true
  end

end
