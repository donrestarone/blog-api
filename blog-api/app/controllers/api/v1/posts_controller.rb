class Api::V1::PostsController < ApplicationController
	def index
		render json: Post.api_all_posts(Post.all)
	end

	def show
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