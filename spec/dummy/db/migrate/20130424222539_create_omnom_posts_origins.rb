class CreateOmnomPostsOrigins < ActiveRecord::Migration
  def change
    create_table :omnom_posts_origins do |t|
      t.belongs_to :post
      t.string :feed_key
      t.string :source_key
      t.string :source_id

      t.timestamps
    end

    add_index :omnom_posts_origins, :post_id
    add_index :omnom_posts_origins, :feed_key
    add_index :omnom_posts_origins, :source_id
    add_index :omnom_posts_origins, [:feed_key, :source_id]
  end
end
