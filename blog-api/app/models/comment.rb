class Comment < ApplicationRecord
	belongs_to :user
	belongs_to :post

	def self.create_comment(comment_body, user, post)
		comment = Comment.new(body: comment_body, user_id: user.id, post_id: post.id)
		if comment.save
			return Post.api_find_post(post)
		else 
			return {response: 'server error', code: 500}
		end
	end
end
