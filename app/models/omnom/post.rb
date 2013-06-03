module Omnom
  class Post < ActiveRecord::Base
    attr_accessible :author_name, :author_url, :comments_count, :comments_url, :description,
      :guid, :guid_namespace, :is_read, :other, :published_at, :subtitle, :tags,
      :thumbnail_height, :thumbnail_url, :thumbnail_width, :title, :url

    has_many :posts_origins, :dependent => :destroy

    serialize :tags
    serialize :other
    
    validates_presence_of :guid, :guid_namespace, :published_at, :title, :url
    validates_uniqueness_of :guid, :scope => :guid_namespace

    auto_strip_attributes :author_name, :author_url, :comments_url, :description, :guid, :subtitle,
      :thumbnail_url, :title, :url

    before_save :clean_urls, :set_thumbnail_size, :truncate_fields

    def clean_urls
      [:author_url, :comments_url, :thumbnail_url, :url].each do |attribute|
        value = send(attribute)
        send("#{attribute}=", Omnom::Utils.clean_url(value)) if value.present?
      end
    end

    def set_thumbnail_size
      return if thumbnail_url.blank?
      size = FastImage.size(thumbnail_url)
      return if size.blank?
      self.thumbnail_width, self.thumbnail_height = size
    end

    def truncate_fields
      fields = [:title, :subtitle]
      fields.each do |field|
        value = send(field)
        next if value.nil?
        send("#{field}=", value.truncate(255))
      end
    end

    def source
      posts_origins.first.source
    end
  end
end
