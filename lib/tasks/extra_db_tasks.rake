namespace :db do
  task :rebuild do
    puts "Dropping the db"
    system("rake db:drop")
    puts "Migrating anew"
    system("rake db:migrate")
    puts "Re-seeding the data"
    system("rake db:seed")
  end
end
