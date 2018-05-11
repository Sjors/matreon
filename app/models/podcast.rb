require 'rss'
require 'open-uri'

class PodcastError < StandardError; end

class Podcast < ApplicationRecord
  default_scope { order(pub_date: :desc) }
  
  scope :published, -> { where('pub_date <= ?', Time.now.utc) }

  def self.fetch!
    return unless ENV['PODCAST'] == "1"
    ActiveRecord::Base.transaction do
      # Track episode guids to delete stale ones:  
      episode_guids = []

      RSS::Parser.parse(open(ENV['PODCAST_URL']).read, false).items.each do |episode|
        if !episode.guid || !episode.guid.content 
          raise PodcastError.new("Unable to parse podcast feed, missing guid for episode")
        end
        episode_guids << episode.guid.content
        @podcast = Podcast.where(guid: episode.guid.content, external: true).first_or_create!
        @podcast.update(
          pub_date: episode.pubDate,
          title: episode.title,
          description: episode.description,
          url: episode.link
        )
      end
      
      # Remove episodes that were deleted upstream:
      Podcast.where(external: true).where("guid NOT IN (?)", episode_guids).destroy_all
    end
  end
end
