class AddPodcastTokenToUser < ActiveRecord::Migration[5.1]
  def down
    remove_index :users, :podcast_token
    remove_column :users, :podcast_token
  end
  
  def up
    add_column :users, :podcast_token, :string
    add_index :users, :podcast_token, unique: true

    User.all.each do |user|
      user.regenerate_podcast_token
    end
  end
end
