# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}

# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/user_name/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }

# I added everything below. The above is the default.

server '159.65.235.246', roles: %i[web app db], primary: true

set :repo_url,        'git@github.com:jasonlyles/bcd.git'
set :application,     'brick_city_depot'
set :user,            'rails'
set :puma_threads,    [4, 16]
set :puma_workers,    0
# set :rbenv_ruby,      '3.2.0'

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w[~/.ssh/id_rsa] }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true # Change to false when not using ActiveRecord

## Defaults:
# set :scm,           :git
# set :branch, :deploy_to_staging
set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :default_env, { path: '/usr/share/rvm/gems/ruby-3.2.0/bin:/usr/share/rvm/rubies/ruby-3.2.0/bin:$PATH' }
append :linked_dirs, '.bundle'
set :linked_files, %w[config/master.key config/credentials/production.key]
set :puma_service_unit_name, 'rails'
set :bundle_without, %w[development test].join(':')

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
      unless `git rev-parse HEAD` == `git rev-parse origin/#{current_branch}`
        puts "WARNING: HEAD is not the same as origin/#{current_branch}"
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  # task :restart_sidekiq do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     invoke!('sidekiq:restart')
  #   end
  # end

  # task :yarn_install do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     invoke!('yarn:install')
  #   end
  # end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  # after  :finishing,    :yarn_install
  after  :finishing,    :cleanup
  after  :finishing,    :restart
  # after  :finishing,    :restart_sidekiq
end

# namespace :yarn do
#   # before 'deploy:finished', 'yarn:install'
#
#   desc 'Install yarn dependencies'
#   task :install do
#     on roles(:app) do
#       within release_path do
#         execute :yarn, :install
#       end
#     end
#   end
#
#   desc 'yarn dependencies'
#   task :build do
#     on roles(:app) do
#       within release_path do
#         with node_env: :production do
#           execute :yarn, :build
#         end
#       end
#     end
#   end
# end

# In order to get this working, I had to set up sidekiq as a service controlled by systemd,
# https://github.com/sidekiq/sidekiq/blob/main/examples/systemd/sidekiq.service
# and add the rails user to the /etc/sudoers.d/90-cloud-init-users file
# namespace :sidekiq do
#   task :restart do
#     invoke 'sidekiq:stop'
#     invoke 'sidekiq:start'
#   end
#
#   # before 'deploy:finished', 'sidekiq:restart'
#
#   task :stop do
#     on roles(:app) do
#       within current_path do
#         execute 'sudo /bin/systemctl stop sidekiq'
#       end
#     end
#   end
#
#   task :start do
#     on roles(:app) do
#       within current_path do
#         execute 'sudo /bin/systemctl start sidekiq'
#       end
#     end
#   end
# end
