class Post < ApplicationRecord
	belongs_to :user
	belongs_to :tag
	has_many :comments, :dependent => :delete_all
	validates :title, presence: true
	validates :body, presence: true
	def self.api_all_posts(posts)
		#define root to use in the meta
		root = 'https://json-blog-api.herokuapp.com/blogs/'
		# parent hash
		response = Hash.new
		# collection of posts
		collection = Array.new
		posts.each do |post|
			@post = post
			
			post_meta = Hash.new

			single_post = Hash.new
			post_data = Hash.new
			# deal with post meta data
			if @post.previous
				previous_post = @post.previous
				post_meta[:last] = "#{root}#{previous_post.id}"
			end
			if @post.next
				next_post = @post.next
				post_meta[:next] = "#{root}#{next_post.id}"
			end
			post_meta[:self] = "#{root}#{post.id}"

			single_post[:links] = post_meta

			# deal with the meat of the post
			post_data[:title] = post.title.capitalize
			post_data[:category] = (Tag.find(post.tag_id)).name.capitalize
			post_data[:body] = post.body
			post_data[:published_on] = (post.created_at).strftime("%m/%d/%Y at %I:%M%p")
			post_data[:last_edited] = (post.updated_at).strftime("%m/%d/%Y at %I:%M%p")
			single_post[:meta] = post_data
			# deal with relationships
			relation = Hash.new
			relation[:author] = (User.find(post.user_id)).name.capitalize
			relation[:posts_to_date] = (User.find(post.user_id)).posts.count
			relation[:comments_to_date] = (User.find(post.user_id)).comments.count
			single_post[:relationships] = relation

			collection.push(single_post)
		end
		response[:data] = collection
		return response
	end

	def self.api_find_post(post)
		root = 'https://json-blog-api.herokuapp.com/blogs/'
		@post = post
		meta = Hash.new
		response = Hash.new
		comments = Array.new
		
		meta[:self] = "#{root}#{@post.id}"

		# links
		if @post.next	
			meta[:next] = "#{root}#{@post.next.id}"
		end
		if @post.previous
			meta[:previous] = "#{root}#{@post.previous.id}"
		end
		response[:links] = meta

		boilerplate = Hash.new
		boilerplate[:type] = 'Blog Post'
		boilerplate[:id] = post.id

		boilerplate[:title] = post.title.capitalize
		boilerplate[:body] = post.body
		boilerplate[:Category] = (Tag.find(post.tag_id)).name.capitalize

		response[:data] = boilerplate
		# data for relationships
		author = Hash.new
		relationship_tree = Hash.new
		author[:author] = post.user.name.capitalize
		author[:posts_to_date] = User.find(post.user_id).posts.count
		author[:comments_to_date] = User.find(post.user_id).comments.count
		relationship_tree[:author] = author 
		response[:relationships] = relationship_tree
		# comments
		comments = Array.new
		if post.comments
			post.comments.map do |comment|
				comments.push({
					Author: User.find(comment.user_id).name,
					Body: comment.body,
					created_at: comment.created_at.strftime("%m/%d/%Y at %I:%M%p")
				})
			end
		end
		relationship_tree[:Comments] = comments
		return response
	end

	def self.create_post(params, tag_id)
		
		post = Post.new(title: params[:title].capitalize, body: params[:body].capitalize, user_id: params[:user_id], tag_id: tag_id)
		if post.save
			return Post.create_data_structure_for_create_post(post)
		else 
			{response: 'Bad Request', code: 400, errors: post.errors.full_messages, messages: ['please provide title, body, user_id and a tag to create a post', 'to create a user, please specify email, and name']}
		end
	end

	def self.destroy_post(post_obj)
		@deleted_post = post_obj
		if post_obj.destroy
			Post.create_data_structure_for_delete_post(@deleted_post)
		else
			return {response: 'server error', code: 500, errors: post_obj.errors.full_messages}
		end
	end

	def self.modify_post(params, post_obj)
		if params[:title] && params[:body]
			post_obj.title = params[:title]
			post_obj.body = params[:body]
			if post_obj.save
				return Post.create_data_structure_for_modify_post(post_obj)
			else 
				return {response: 'server error', code: 500}
			end
		elsif params[:title]
			post_obj.title = params[:title]
			if post_obj.save
				return Post.create_data_structure_for_modify_post(post_obj)
			else
				return {response: 'server error', code: 500}
			end
		elsif params[:body]
			post_obj.body = params[:body] 
			if post_obj.save
				return Post.create_data_structure_for_modify_post(post_obj)
			else
				return {response: 'server error', code: 500}
			end
		else
			return {response: 'bad request', code: 400}
		end
	end

	# used by api_all_posts/find_post for getting the next/prev post
	def next
		self.class.where("id > ?", id).first
	end

	def previous
		self.class.where("id < ?", id).last
	end

	private
	def self.create_data_structure_for_modify_post(post_obj)
		response = Hash.new
		data = Hash.new
		relationships = Hash.new
		data[:type] = 'Blog Post'
		data[:id] = post_obj.id
		data[:title] = post_obj.title
		data[:body] = post_obj.body
		data[:updated_at] = post_obj.updated_at.strftime("%m/%d/%Y at %I:%M%p")
		relationships[:author] = post_obj.user.name
		data[:relationships] = relationships
		response[:data] = data
		return response
	end	

	def self.create_data_structure_for_delete_post(deleted_post)
		response = Hash.new
		meta = Hash.new
		response[:code] = 200
		response[:status] = 'OK'
		meta[:title] = @deleted_post.title
		meta[:author] = @deleted_post.user.name
		meta[:tag] = @deleted_post.tag.name
		meta[:deleted_at] = Time.now.strftime("%m/%d/%Y at %I:%M%p")
		response[:attributes] = meta
		return response
	end

	def self.create_data_structure_for_create_post(post)
		root = 'https://json-blog-api.herokuapp.com/blogs/'
		response = Hash.new
		response_data = Hash.new
		attributes = Hash.new
		relation_tree = Hash.new
		# type/attributes
		response_data[:type] = "Blog Post"
		attributes[:title] = post.title
		attributes[:src] = "#{root}#{post.id}"
		attributes[:created_at] = post.created_at.strftime("%m/%d/%Y at %I:%M%p")
		response_data[:attributes] = attributes
		relation_tree[:author] = post.user.name
		relation_tree[:tag] = post.tag.name
		response_data[:relationships] = relation_tree
		
		# top level data
		response[:data] = response_data
		return response
	end
end
