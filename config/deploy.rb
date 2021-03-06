# config valid only for current version of Capistrano
lock '3.11.0'

set :application, 'urgetopunt'
set :repo_url, 'git@github.com:jparker/urgetopunt.git'
set :use_sudo, false

if ENV['CAP_SSH_GATEWAY']
  ssh_command = "ssh #{ENV['CAP_SSH_GATEWAY']} -W %h:%p -A"
  set :ssh_options, proxy: Net::SSH::Proxy::Command.new(ssh_command)
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :jekyll do
  desc 'Build site with jekyll'
  task :build do
    on roles(:web) do
      within release_path do
        execute "BUNDLE_PATH=#{shared_path.join 'bundle'} " \
          "BUNDLE_GEMFILE=#{release_path.join 'Gemfile'} "  \
          "bundle exec jekyll build "                       \
          "--destination #{release_path.join '_site'} "     \
          "--source #{release_path}"
      end
    end
  end
end

after 'deploy:updated', 'jekyll:build'
