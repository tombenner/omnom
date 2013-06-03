# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130424222539) do

  create_table "omnom_posts", :force => true do |t|
    t.string   "guid_namespace",                      :null => false
    t.text     "guid",                                :null => false
    t.text     "url",                                 :null => false
    t.string   "title",                               :null => false
    t.string   "subtitle"
    t.text     "description"
    t.datetime "published_at",                        :null => false
    t.text     "thumbnail_url"
    t.integer  "thumbnail_width"
    t.integer  "thumbnail_height"
    t.string   "author_name"
    t.text     "author_url"
    t.text     "comments_url"
    t.integer  "comments_count"
    t.text     "tags"
    t.text     "other"
    t.boolean  "is_read",          :default => false, :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "omnom_posts", ["guid"], :name => "index_omnom_posts_on_guid"
  add_index "omnom_posts", ["guid_namespace", "guid"], :name => "index_omnom_posts_on_guid_namespace_and_guid"
  add_index "omnom_posts", ["is_read"], :name => "index_omnom_posts_on_is_read"
  add_index "omnom_posts", ["published_at"], :name => "index_omnom_posts_on_published_at"

  create_table "omnom_posts_origins", :force => true do |t|
    t.integer  "post_id"
    t.string   "feed_key"
    t.string   "source_key"
    t.string   "source_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "omnom_posts_origins", ["feed_key", "source_id"], :name => "index_omnom_posts_origins_on_feed_key_and_source_id"
  add_index "omnom_posts_origins", ["feed_key"], :name => "index_omnom_posts_origins_on_feed_key"
  add_index "omnom_posts_origins", ["post_id"], :name => "index_omnom_posts_origins_on_post_id"
  add_index "omnom_posts_origins", ["source_id"], :name => "index_omnom_posts_origins_on_source_id"

end
