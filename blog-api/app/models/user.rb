class User < ApplicationRecord
	has_many :posts
	has_many :comments
	validates :email, presence: true, uniqueness: true
	validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
	validates :name, presence: true

	def self.create_user(params)
		user = User.new(name: params[:name], email: params[:email])
		if user.save
			return User.create_data_structure(user)
		else 
			{response: 'Bad Request', code: 400, errors: user.errors.full_messages}
		end
	end

	def self.modify_user(params, user)
		if params[:name] && params[:user_id]
			user.name = params[:name]
			if user.save
				return User.create_data_structure(user)
			else
				return {response: 'server error', code: 500, errors: user.errors.full_messages}
			end	
		else 
			return {response: 'Bad Request', code: 400}
		end
	end

	private

	def self.create_data_structure(user)
		response = Hash.new
		meta = Hash.new
		attributes = Hash.new
		attributes[:name] = user.name
		attributes[:email] = user.email
		meta[:type] = 'User'
		meta[:id] = user.id
		meta[:attributes] = attributes
		response[:data] = meta
		return response
	end
end
