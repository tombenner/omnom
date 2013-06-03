module Omnom
  class PostsController < Omnom::ApplicationController
    def update_all
      if Post.where(id: params[:ids]).update_all(params[:post])
        render json: {success: true}
      else
        render json: {success: false}, status: 500
      end
    end
  end
end
