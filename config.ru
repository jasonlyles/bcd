# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

use Rack::Static, urls: ['/carrierwave'], root: 'tmp'
use Rack::RubyProf, path: 'tmp/profile' if Rails.env.profile?

run BrickCity::Application
