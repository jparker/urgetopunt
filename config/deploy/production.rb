server 'albatross.urgetopunt.com', roles: [:web], user: 'urgetopunt', port: 22222

namespace :bundle do
  desc 'Install bundled gems'
  task :install do
    on roles(:all) do
      within "#{deploy_to}/current" do
        execute 'bundle', 'install', '-j2'
      end
    end
  end
end

namespace :jekyll do
  desc 'Run jekyll to generate site'
  task :build do
    on roles(:web) do
      within "#{deploy_to}/current" do
        execute 'bundle' 'exec', 'jekyll', 'build'
      end
    end
  end
end

after 'deploy:symlink:release', 'jekyll:build'
before 'jekyll:build', 'bundle:install'
