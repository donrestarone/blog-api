class User < ApplicationRecord
	has_many :posts
	has_many :comments
	validates :email, presence: true, uniqueness: true
	validates :name, presence: true
	def self.create_user(params)
		user = User.new(name: params[:name], email: params[:email])
		if user.save
			response = Hash.new
			meta = Hash.new
			attributes = Hash.new
			meta[:type] = 'User'
			attributes[:name] = user.name
			attributes[:id] = user.id
			attributes[:email] = user.email
			meta[:attributes] = attributes
			response[:data] = meta
			return response
		else 
			{response: 'Bad Request', code: 400, errors: user.errors.full_messages}
		end
	end
end
