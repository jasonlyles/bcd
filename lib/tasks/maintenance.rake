# frozen_string_literal: true

namespace :maintenance do
  task reap_stale_carts: :environment do
    puts 'Reaping stale carts'
    Cart.delete_all(['updated_at < ?', 2.weeks.ago])
  end

  task reap_stale_sessions: :environment do
    puts 'Reaping stale sessions.'
    ActiveRecord::SessionStore::Session.delete_all(['updated_at < ?', 2.weeks.ago])
  end
end
