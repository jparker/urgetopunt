server 'curlew.urgetopunt.com', roles: [:web], user: 'john', port: 22222

namespace :bundler do
  desc 'Install bundled gems'
  task :install do
    on roles(:all) do
      execute 'bundle', 'install', '-j2'
    end
  end
end

namespace :jekyll do
  desc 'Run jekyll to generate site'
  task :build do
    on on(:web) do
      execute 'bundle' 'exec', 'jekyll', 'build'
    end
  end
end

after 'deploy:symlink:release', 'jekyll:build'
before 'jekyll:build', 'bundle:install'
