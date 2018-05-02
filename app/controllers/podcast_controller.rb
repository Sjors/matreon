class PodcastController < ApplicationController
  # Future CRUD should use /podcast/episodes 
  
  # GET /podcast.rss
  def feed
    @user = User.find_by_podcast_token(params[:token])
    if @user
      @episodes = Podcast.published.where("pub_date < ?", @user.contribution.subscribed_up_to)
    else
      @episodes = [] # Later: list public episodes
    end
    @last_pubdate = @episodes.count > 0 ? @episodes.first.pub_date : Time.zone.local(2018, 05, 01)
  end
end
