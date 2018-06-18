User.delete_all
Comment.delete_all
Post.delete_all
Tag.delete_all

usr_names = ['Bob', 'Grant', 'Cletus', 'Raj', 'Tabitha', 'Rose', 'Eunice']

usr_names.each do |name|
	email = "#{name}@example.com"
	User.create(name: name, email: email)
end

posts_titles = ['Things I like', 'Things you like', 'Things that we probably like', 'other things', 'stuff', 'these things are hard to grasp', 'important things']

tags = ['technology', 'pottery', 'art', 'medicine']
tags.each do |tag_name|
	Tag.create(name: tag_name)
end

comments = ['very nice', 'my dad approves this', 'well done', 'positivity', 'good vibes']
i = 0
posts_titles.each do |title|
	Post.create(title: title, body: "#{title} lorem ipsum dolor sit amet", tag_id: (Tag.find_by(name: tags.sample)).id, user_id: (User.find_by(name: usr_names[i])).id)
	i += 1
end

posts_titles.count.times do 
	Comment.create(body: comments.sample, user_id: (User.find_by(name: usr_names.sample)).id, post_id: (Post.find_by(title: posts_titles.sample)).id) 
end