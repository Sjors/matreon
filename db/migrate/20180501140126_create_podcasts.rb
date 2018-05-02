class CreatePodcasts < ActiveRecord::Migration[5.1]
  def change
    create_table :podcasts do |t|
      t.string :guid
      t.datetime :pub_date
      t.string :title
      t.text :description
      t.string :url
      t.boolean :external

      t.timestamps
    end
  end
end
