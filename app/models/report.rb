class Report < ActiveRecord::Base
  belongs_to :reserve
  
  validates :message, :presence => true
  validates :reserve, :presence => true, :if => :web?
  
  after_create :send_tweet
  
  attr_accessor :web
  
  def web?
    @web == true
  end
  
  protected
  
  def send_tweet
    if reserve
      if reserve.member_of_parliament && reserve.member_of_parliament.twitter?
        # last minute coding = hacks like the ones below - June 03, 2012 - KV
        t = reserve.member_of_parliament.twitter.gsub('http://twitter.com/', '')
        Twitter.update("Dear @#{t}:" + message.first(100) + ' http://bit.ly/mywater')
      else
        Twitter.update(message.first(100) + ' http://bit.ly/mywater')
      end
    else
      Twitter.update(message.first(100) + ' http://bit.ly/mywater')
    end  
  end
  
end
