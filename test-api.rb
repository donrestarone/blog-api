require 'httparty'
require 'pry'
system "clear"
p 'test LOCAL or PRODUCTION?'
test_type = gets.chomp
if test_type == 'local'
	int = 0
	p 'testing endpoint /posts for limit constraints'
	10.times do 
		int += 1
		request = JSON.parse((HTTParty.get("http://localhost:3000/api/v1/posts/?limit=#{int}")).body)
		if request["data"]
			p "API returned #{request["data"].count} posts when asked for a limit of #{int}"
		else 
			p "At limit of #{int} API responded with #{request["status"]} and code of #{request["code"]}"
		end
	end

	p 'testing endpoint /posts/search'
	usr_names = ['Bob', 'Grant', 'Cletus', 'Raj', 'Tabitha', 'Rose', 'Eunice']
	posts_titles = ['Things I like', 'Things you like', 'Things that we probably like', 'other things', 'stuff', 'these things are hard to grasp', 'important things']
	# with names
	usr_names.each do |name|
		request = JSON.parse((HTTParty.get("http://localhost:3000/api/v1/posts/search?author=#{name}")).body)
		p "searched for articles by #{name} API returned: #{request["data"][0]["relationships"]["Author"]}, titled #{request["data"][0]["meta"]["Title"]}"
	end
	# with titles
	posts_titles.each do |title|
		request = JSON.parse((HTTParty.get("http://localhost:3000/api/v1/posts/search?title=#{title}")).body)
		p "Searched for article-> #{title} and API returned: #{request["data"][0]["Title"]} by #{request["Relationships"]["author"]["Author"]}"
	end
elsif test_type == 'production'

else 
	p 'wrong selection'

end