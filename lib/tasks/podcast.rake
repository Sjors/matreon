namespace :podcast do :env
  desc "Fetch podcast RSS"
  task :fetch => :environment do
    Podcast.fetch!
  end
end
