#This environment is set up to test a production-like environment, so rather than copy the prod config file and
# have config settings get out of sync as I update the prod file, I'm just loading the prod config. If I need to make
# any overrides for the profile environment, I can do so in the configure block below. Got this solution from:
#http://stackoverflow.com/questions/14947833/remove-duplication-between-staging-rb-and-production-rb

require Rails.root.join('config/environments/production')
BrickCity::Application.configure do

end