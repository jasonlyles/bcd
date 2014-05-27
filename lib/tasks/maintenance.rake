namespace :maintenance do
  task :reap_stale_carts => :environment do
    stale_carts = Cart.where("updated_at < '#{10.days.ago}'")
    puts "Reaping #{stale_carts.length} stale carts."
    stale_carts.destroy_all
  end

  #Not sure I need this because I guess devise will remember the user for 2 weeks. This ought not actually do anything.
  task :reap_stale_session => :environment do
    stale_sessions = ActiveRecord::SessionStore::Session.where("updated_at < '#{10.days.ago}'")
    puts "Reaping #{stale_sessions.length} stale sessions."
    stale_sessions.destroy_all
  end
end
