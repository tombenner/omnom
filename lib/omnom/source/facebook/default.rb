module Omnom
  module Source
    module Facebook
      class Default < Source::Base
        every '5m'
        url 'https://www.facebook.com/'
        required_config :web_auth_email, :web_auth_password

        def after_initialize
          @home_page_url = 'https://www.facebook.com/'
          @login_page_url = @home_page_url
        end

        def authenticate
          login_page = @agent.get(@login_page_url)
          @page = login_page.form_with(id: 'login_form') do |form|
            form.email = config.web_auth_email
            form.pass = config.web_auth_password
          end.submit
          @page = @agent.get(@home_page_url) if @page.uri.to_s != @home_page_url
          raise 'Unable to log into Facebook' if @page.uri.to_s != @home_page_url
        end

        def get_raw_posts
          comments = page_comments(@page)
          raise 'Unable to read the Facebook stream' if comments.blank?
          raw_posts = comments.search('li.uiUnifiedStory')
          raise 'Unable to find posts in the Facebook stream' if raw_posts.blank?
          raw_posts
        end

        def post_attributes(node)
          author_link = node.find('.actorName > a')
          author_link ||= node.find('.uiStreamHeadline .passiveName')
          return nil if author_link.blank?
          
          author_name = author_link.text
          author_url = author_link.attr('href')

          post_link = node.find('.uiStreamSource > a')
          if post_link.present? && post_link.attr('href') != '#'
            url = post_link.url
          else
            url = author_url
          end

          title = node.search('[role=article] > .uiStreamHeadline').text
          description_node = node.search('[role=article] > .userContentWrapper > .messageBody')

          if title == author_name
            title = description_node.text
            description = nil
          else
            description = description_node.inner_html
          end

          description = nil if title == description_node.text
          
          data = node.attr('data-ft')
          guid = JSON.parse(data)['mf_story_key']

          attributes = {
            title: title,
            description: description,
            guid: guid,
            url: url || author_url,
            published_at: Time.at(node.find('.uiStreamSource abbr[data-utime]').attr('data-utime').to_i).utc,
            thumbnail_url: node.find('.actorPhoto > img').attr('src'),
            author_name: author_name,
            author_url: author_url
          }

          photos_container = node.search('.photoRedesign')
          if photos_container.present?
            attributes[:other] ||= {}
            photos = node.search('a.uiPhotoThumb')
            photos = node.search('.photoRedesignLink') if photos.blank?
            attributes[:other][:images] = photos.collect do |photo|
              {
                page_url: photo.attr('href'),
                image_url: photo.find('img').attr('src'),
              }
            end
            attributes[:thumbnail_url] = attributes[:other][:images].first[:image_url] if attributes[:other][:images].present?
          end
          attributes
        end

        private

        def page_comments(page)
          return nil if page.blank?
          html = page.search('comment()').collect { |comment_node| comment_node.text }.join
          doc = Nokogiri::HTML(html)
          # Set the URI, so .url calls on nodes will work
          doc.uri = page.uri
          doc
        end
      end
    end
  end
end
