# frozen_string_literal: true

class ReapStaleSessionsJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform
    puts 'Reaping stale sessions.'
    ActiveRecord::SessionStore::Session.where(['updated_at < ?', 2.weeks.ago]).destroy_all
  end
end
