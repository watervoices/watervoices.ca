# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run WaterVoices::Application

#use Rack::Static,
#  :urls => ["/stylesheets", "/images"],
#  :root => "public"
#
#run lambda { |env|
#  [
#    200,
#    {
#      'Content-Type'  => 'text/html',
#      'Cache-Control' => 'public, max-age=86400',
#    },
#    File.open('public/index.html', File::RDONLY)
#  ]
#}
