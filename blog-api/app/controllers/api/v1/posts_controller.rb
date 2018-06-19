class Api::V1::PostsController < ApplicationController
	def index
		#must specifiy limit at this endpoint
		#http://localhost:3000/api/v1/posts/?limit=7
		if params[:limit]
			_limit = params[:limit]
			if _limit.to_i > Post.all.count
				render json: {status: 'invalid search limit', code: 400}
			else
				render json: Post.api_all_posts((Post.order(created_at: :desc)).limit(_limit))
			end
		end
	end

	def show
		id_query = params[:id].to_i

		render json: Post.api_find_post(Post.find(id_query))
	end

	def search
		render json: Post.first
	end

	def create
		render json: {response: 'create'}
	end

	def destroy
		render json: {response: 'destroy'}
	end

	def update
		render json: {response: 'update'}
	end
end