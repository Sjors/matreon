#encoding: UTF-8

xml.instruct! :xml, :version => "1.0"

xml.rss :version => "2.0", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd" do
  xml.channel do
    xml.title ENV["PODCAST_TITLE"]
    xml.link ENV["HOSTNAME"]
    xml.language 'en'
    xml.pubDate @last_pubdate.to_s(:rfc822)
    xml.lastBuildDate @last_pubdate.to_s(:rfc822)
    xml.itunes :author, ENV["PODCAST_TITLE"]
    xml.itunes :image, :href => ENV["PODCAST_IMAGE"]
    xml.itunes :owner do
      xml.itunes :name, ENV["PODCAST_TITLE"]
      xml.itunes :email, ENV["FROM_EMAIL"]
    end
    xml.itunes :block, 'no'

    @episodes.each do  |episode|
      xml.item do
        xml.title episode.title
        xml.description episode.description
        xml.pubDate episode.pub_date.to_s(:rfc822)
        xml.enclosure :url => episode.url, :length => 0, :type => 'audio/mpeg'
        xml.link episode.url
        xml.guid({:isPermaLink => episode.guid[0..3] == "http" ? "true" : "false"}, episode.guid)
      end
    end
  end
end
