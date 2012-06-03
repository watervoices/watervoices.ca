class Admin::BaseController < ApplicationController
  
  http_basic_authenticate_with(:name => "steve", :password => "watervoices") if Rails.env.production?
  
  layout 'admin'
  
end
