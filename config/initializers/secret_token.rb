# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
WaterVoices::Application.config.secret_token = ENV['SECRET_TOKEN'] || 'b7c5b2780a8c883520aeb41dd2c4cf854bbfa04786e658b956cc344d578a3aa9ed06b0e4d9e4e0c5bb9860b49b0ffacd161f2d3a3eb63632136a6b7d3f34fabf'
