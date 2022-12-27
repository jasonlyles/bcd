# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# # TODO: I think the stuff below this line needs to go into initializers that won't
# get overwritten when running rails app:update
MAX_DOWNLOADS = 5
SUPPORTED_LOCALES = %w[en]
