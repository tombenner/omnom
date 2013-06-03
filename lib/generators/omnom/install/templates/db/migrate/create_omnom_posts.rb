class CreateOmnomPosts < ActiveRecord::Migration
  def change
    create_table :omnom_posts do |t|
      t.string :guid_namespace, null: false
      t.text :guid, null: false
      t.text :url, null: false
      t.string :title, null: false
      t.string :subtitle
      t.text :description
      t.datetime :published_at, null: false
      t.text :thumbnail_url
      t.integer :thumbnail_width
      t.integer :thumbnail_height
      t.string :author_name
      t.text :author_url
      t.text :comments_url
      t.integer :comments_count
      t.text :tags
      t.text :other
      t.boolean :is_read, null: false, default: false

      t.timestamps
    end

    add_index :omnom_posts, :guid
    add_index :omnom_posts, [:guid_namespace, :guid]
    add_index :omnom_posts, :published_at
    add_index :omnom_posts, :is_read
  end
end
