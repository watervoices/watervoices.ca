class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :m # markdown text
  
  protected
  
  # markdown to html
  def m(text)
    RDiscount.new(text.to_s).to_html.html_safe
  end
  
  
end
