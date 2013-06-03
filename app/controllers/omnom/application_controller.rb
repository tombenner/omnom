module Omnom
  class ApplicationController < ::ApplicationController
    helper Rails.application.routes.url_helpers
    helper PostsHelper
    layout 'omnom/layouts/application'

    def render_404
      render :status => 404 and return
    end
  end
end
