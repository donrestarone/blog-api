class Post < ApplicationRecord
	belongs_to :user
	belongs_to :tag
	has_many :comments

	def self.api_all_posts(posts)
		#define root to use in the meta
		root = '/blogs/'
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


			post_data[:Title] = post.title.capitalize
			post_data[:Category] = (Tag.find(post.tag_id)).name.capitalize
			post_data[:Body] = post.body
			post_data[:Published_on] = (post.created_at).strftime("%m/%d/%Y at %I:%M%p")
			post_data[:Last_edited] = (post.updated_at).strftime("%m/%d/%Y at %I:%M%p")
			single_post[:meta] = post_data
			# deal with relationships
			relation = Hash.new
			relation[:Author] = (User.find(post.user_id)).name.capitalize
			relation[:Posts_to_date] = (User.find(post.user_id)).posts.count
			relation[:Comments_to_date] = (User.find(post.user_id)).comments.count
			single_post[:relationships] = relation

			collection.push(single_post)

			
			
		end
		response[:data] = collection
		return response
	end

	def self.api_find_post(post)
		root = '/blogs/'
		@post = post
		meta = Hash.new
		response = Hash.new
		post_data = Array.new
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
		# data about post
		boilerplate = Hash.new
		boilerplate[:Type] = 'Blog Post'
		boilerplate[:Id] = post.id

		boilerplate[:Title] = post.title.capitalize
		boilerplate[:Body] = post.body
		boilerplate[:Category] = (Tag.find(post.tag_id)).name.capitalize
		post_data.push(boilerplate)

		response[:data] = post_data
		# data for relationships
		author = Hash.new
		relationship_tree = Hash.new
		author[:Author] = post.user.name.capitalize
		author[:Posts_to_date] = User.find(post.user_id).posts.count
		author[:Comments_to_date] = User.find(post.user_id).comments.count
		relationship_tree[:author] = author 
		response[:Relationships] = relationship_tree
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

	# used by api_all_posts/find_post for getting the next/prev post
	def next
		self.class.where("id > ?", id).first
	end

	def previous
		self.class.where("id < ?", id).last
	end
end
