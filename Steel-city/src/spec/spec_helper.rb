# SimpleCov
require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end
SimpleCov.coverage_dir "coverage"

# Sinatra App
ENV["APP_ENV"] = "test"
require_relative "../app"
def app
  Sinatra::Application
end

# Capybara
require "capybara/rspec"
Capybara.app = Sinatra::Application

# RSpec
RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods

  # before each test is run, delete all non-hardcoded records in the User table
  config.before do
    PremiumSubscription.where { userid > 4}.delete
    Like.where { userid > 4}.delete
    Vote.where { userid > 4}.delete
    Subscription.where { readerid > 4 || writerid > 4}.delete
    StaffContact.where { userid > 4}.delete
    Poll.where { writerid > 4 || storyid > 10}.delete
    BoughtStory.where { userid > 4}.delete
    User.where { userid > 4 }.delete
    Story.where { storyid > 10}.delete
    PromotionalCampaign.where { campaignid > 3}.delete
  end
end