# frozen_string_literal: true

class BaseJob < ApplicationJob
  # :nocov:
  extend TempAgency
  # This method just returns the value set in one of the classes in this module. This is a way of
  # making a queue method available for TempAgency, which uses after hooks to hire and fire workers on Heroku
  def queue_name
    @queue
  end
  # :nocov:
end
