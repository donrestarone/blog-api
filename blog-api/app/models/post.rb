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

			post_data[:Author] = (User.find(post.user_id)).name.capitalize
			post_data[:Title] = post.title
			post_data[:Category] = (Tag.find(post.tag_id)).name
			post_data[:Published_on] = (post.created_at).strftime("%m/%d/%Y at %I:%M%p")
			single_post[:data] = post_data



			collection.push(single_post)

			
			
		end
		response[:posts] = collection
		return response
	end


	def next
		self.class.where("id > ?", id).first
	end

	def previous
		self.class.where("id < ?", id).last
	end
end
