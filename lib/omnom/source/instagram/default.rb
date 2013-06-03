module Omnom
  module Source
    module Instagram
      class Default < Source::Base
        every '5m'
        url 'http://instagram.com/'
        required_config :web_auth_username, :web_auth_password

        def after_initialize
          @login_page_url = "#{@url}accounts/login/"
        end

        def authenticate
          login_page = @agent.get(@login_page_url)
          @page = login_page.form_with(id: 'login-form') do |form|
            form.username = config.web_auth_username
            form.password = config.web_auth_password
          end.submit
          @page = @agent.get(@url) if @page.uri.to_s != @url
          raise 'Unable to log into Instagram' if @page.uri.to_s != @url
        end

        def get_raw_posts
          @page.search('script').each do |script|
            script = script.text
            if script =~ /window\._jscalls\s+=/m
              cxt = V8::Context.new
              cxt['window'] = {}
              cxt.eval(script)
              return cxt['window']['_jscalls'][2][2].first['props']['moreQuery']['initial']['feed']['media']['nodes']
            end
          end
        end

        def post_attributes(node)
          url = "http://instagram.com/p/#{node['code']}/"
          image_url = node['display_src']
          {
            title: node['caption'].present? ? node['caption'] : node['owner']['username'],
            description: node['location'].present? ? node['location']['name'] : nil,
            guid: node['id'],
            url: url,
            published_at: Time.at(node['date']),
            thumbnail_url: image_url,
            author_name: node['owner']['username'],
            author_url: "http://instagram.com/#{node['owner']['username']}",
            comments_count: node['comments']['count'],
            comments_url: url,
            other: {
              likes_count: node['likes']['count'],
              location: node['location'].nil? ? nil : Hash[node['location'].to_a],
              images: [{
                image_url: image_url,
                page_url: url
              }]
            }
          }
        end
      end
    end
  end
end
