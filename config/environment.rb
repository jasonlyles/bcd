# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
BrickCity::Application.initialize!

MAX_DOWNLOADS = 5
SUPPORTED_LOCALES = %w(en)
