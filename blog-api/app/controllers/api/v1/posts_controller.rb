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
		if Post.find_by(id: id_query)
			render json: Post.api_find_post(Post.find(id_query))
		else
			render json: {status: 'Not found', code: 404}
		end
	end

	def search
		# can search by author or title -> http://localhost:3000/api/v1/posts/search?author=cletus || http://localhost:3000/api/v1/posts/search?title=stuff
		if params[:author] && User.find_by(name: params[:author].capitalize)
			render json: Post.api_all_posts((User.find_by(name: params[:author].capitalize)).posts)
		elsif params[:title] && Post.find_by("title like ?", "%#{params[:title]}%")
			title = params[:title]
			render json: Post.api_find_post(Post.find_by("title like ?", "%#{title}%"))
		else 
			render json: {status: 'Bad Request', code: 400}
		end
	end

	def create
		#http://localhost:3000/api/v1/posts && provide params title, body, user_id to create a post || provide name and email to create a user
		# https://json-blog-api.herokuapp.com/api/v1/posts/
		# specify params under form-data, headers -> Content-Type 'application/json'
		if params[:title] && params[:body] && params[:user_id] && params[:tag]
			# render json: {response: 'create post'}
			if Tag.find_by("name like ?", "%#{params[:tag]}%")
				tag = Tag.find_by('name like ?', "#{params[:tag]}%")
				render json: Post.create_post(create_params, tag.id)
			else
				tag = Tag.create(name: params[:tag])
				render json: Post.create_post(create_params, tag.id)
			end
		elsif params[:name] && params[:email]
			render json: User.create_user(create_params)

		elsif params[:post_id] && params[:user_id] && params[:body]
			if Post.find_by(id: params[:post_id].to_i) && User.find_by(id: params[:user_id].to_i)
				post = Post.find_by(id: params[:post_id].to_i)
				user = User.find_by(id: params[:user_id].to_i)
				render json: Comment.create_comment(params[:body], user, post)
			else
				render json: {status: 'not found', code: 404}
			end
		else 
			render json: {status: 'Bad Request', code: 400, to_create_post: 'under form-data specify post title, body, tag and user id to create a post', to_create_a_comment: 'under form-data specify post_id user_id and body', to_create_user: 'under form-data specify the name and email'}
		end
	end

	def destroy
		
		if Post.find_by(id: params[:id])
			post = Post.find(params[:id])
			render json: Post.destroy_post(post)
		else 
			render json: {status: 'not found', code: 404}
		end
	end

	def update
		# to update a user -> http://localhost:3000/api/v1/posts/changeuser && specify user_id and name in form data || http://localhost:3000/api/v1/posts/changepost && specify title or body to change it
		if params[:id] == 'changepost' && Post.find_by(id: params[:post_id].to_i) && update_params
			post = Post.find(params[:post_id].to_i)
			render json: Post.modify_post(update_params, post)
		elsif params[:id] == 'changeuser' && User.find_by(id: params[:user_id].to_i) && update_params
			user = User.find(params[:user_id].to_i)
			render json: User.modify_user(update_params, user)
		else 
			render json: {status: 'bad request', code: 400}
		end
	end

	private
	def update_params
		params.permit(:id, :post_id, :user_id, :title, :body, :name)
	end
	def create_params
		params.permit(:title, :body, :user_id, :tag, :name, :email, :post_id, :comment)
	end


end