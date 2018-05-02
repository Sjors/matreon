require 'rails_helper'

RSpec.describe PodcastController, type: :controller do
  fixtures :users, :contributions, :invoices, :podcasts

  describe "GET feed" do
    it "should not have private @episodes without authentication" do
      get :feed, format: :rss
      expect(assigns(:episodes)).to eq([])
    end
    
    it "should have @episodes with token" do
      get :feed, format: :rss, params: {token: users(:dave).podcast_token}
      expect(assigns(:episodes)).to eq([podcasts(:ep1)])
    end

    describe "RSS feed" do
      render_views
      
      it "should be rendered" do
        get :feed, format: :rss
        expect(response).to render_template("feed")
        expect(response.body).to include("Sjorsnado")
      end
      
      it "should contain episodes" do
        get :feed, format: :rss, params: {token: users(:dave).podcast_token}
        expect(response).to render_template("feed")
        expect(response.body).to include('<link>https://example.com/podcast/1.mp3')
      end
    end
  end
end
