require 'rails_helper'

RSpec.describe Podcast, type: :model do
  describe "self.fetch!" do
    let!(:podcast) { create(:podcast, guid: "1", external: true) }

    before do
      rss_fixture = File.read(File.new(Rails.root.join("spec/fixtures/files/podcast.rss")))
      allow_any_instance_of(Kernel).to receive(:open).and_return(OpenStruct.new(read: rss_fixture))                 
    end
  
    it "should exit if PODCAST=0" do
      cached_env_podcast = ENV['PODCAST']
      ENV['PODCAST'] = "0"
      Podcast.fetch!
      expect(Podcast.count).to eq(1)
      ENV['PODCAST'] = cached_env_podcast
    end
  
    it "should download and parse an RSS feed" do
      Podcast.fetch!
      expect(Podcast.count).to eq(2)
    end
    
    it "should update entries if needed" do
      Podcast.fetch!
      Podcast.find_by(guid: "1").update(description: "Earlier version")
      Podcast.fetch!
      expect(Podcast.find_by(guid: "1").description).to eq("Long rant")
    end
    
    it "should delete items no longer in the RSS feed" do
      # Create "deleted" episode:
      Podcast.create(guid: "deleted", title: "Oops", description: "I did it again", external: true)
      
      Podcast.fetch!
      expect(Podcast.count).to eq(2)
    end
    
    it "should not delete non-external items" do
      # Create "deleted" episode:
      Podcast.create(guid: "local", title: "Rant", description: "Blah", external: false)
      
      Podcast.fetch!
      expect(Podcast.where(guid: "local").count).to eq(1)
    end
  end
end
