API endpoints:

#CREATE
  to create new users: POST https://json-blog-api.herokuapp.com/api/v1/posts
    provide form-data in the body -> email: foo@baz.com, name: bar
```json
    sample response: {
    "data": {
        "type": "User",
        "id": 2,
        "attributes": {
            "name": "Bill",
            "email": "bill@example.com"
        }
    }
}
```
  to create new posts: https://json-blog-api.herokuapp.com/api/v1/posts
    provide form data in the body -> user_id: int, title: foo, body: bar, tag: baz
```json    
    sample response: {
    "data": {
        "type": "Blog Post",
        "attributes": {
            "title": "Hello world",
            "src": "/blogs/2",
            "created_at": "06/19/2018 at 09:18PM"
        },
        "relationships": {
            "Author": "Eunice",
            "Tag": "ruby "
        }
    }
}
```
  note; if a tag is unique a new tag instance will be created and stored in the database, otherwise the new post will be related to the existing tag instance
#READ
  read all stories arranged by newest first: https://json-blog-api.herokuapp.com/api/v1/posts/?limit=2
  limit specifies how many post objects are retrieved from the database
```json  
  sample response: {
    "data": [
        {
            "links": {
                "last": "/blogs/1",
                "self": "/blogs/2"
            },
            "meta": {
                "Title": "Hello world",
                "Category": "Ruby ",
                "Body": "First post",
                "Published_on": "06/19/2018 at 09:18PM",
                "Last_edited": "06/19/2018 at 09:18PM"
            },
            "relationships": {
                "Author": "Eunice",
                "Posts_to_date": 2,
                "Comments_to_date": 0
            }
        },
        {
            "links": {
                "next": "/blogs/2",
                "self": "/blogs/1"
            },
            "meta": {
                "Title": "Hello world",
                "Category": "Ruby ",
                "Body": "First post",
                "Published_on": "06/19/2018 at 07:59PM",
                "Last_edited": "06/19/2018 at 07:59PM"
            },
            "relationships": {
                "Author": "Eunice",
                "Posts_to_date": 2,
                "Comments_to_date": 0
            }
        }
    ]
}
```
  note: if limit is higher than the post count in the database, a bad request response is returned
  read a single story: https://json-blog-api.herokuapp.com/api/v1/posts/2
  when id is specified the api returns a single story and all its relationships
```json  
  sample response: {
    "links": {
        "self": "/blogs/2",
        "previous": "/blogs/1"
    },
    "data": {
        "Type": "Blog Post",
        "Id": 2,
        "Title": "Hello world",
        "Body": "First post",
        "Category": "Ruby "
    },
    "Relationships": {
        "author": {
            "Author": "Eunice",
            "Posts_to_date": 2,
            "Comments_to_date": 0
        },
        "Comments": []
    }
}
```
  to search by author and get all their articles -> GET https://json-blog-api.herokuapp.com/api/v1/posts/search?author=authorname
```json  
  sample response: {
    "data": [
        {
            "links": {
                "next": "/blogs/2",
                "self": "/blogs/1"
            },
            "meta": {
                "Title": "Hello world",
                "Category": "Ruby ",
                "Body": "First post",
                "Published_on": "06/19/2018 at 07:59PM",
                "Last_edited": "06/19/2018 at 07:59PM"
            },
            "relationships": {
                "Author": "Eunice",
                "Posts_to_date": 2,
                "Comments_to_date": 0
            }
        },
        {
            "links": {
                "last": "/blogs/1",
                "self": "/blogs/2"
            },
            "meta": {
                "Title": "Hello world",
                "Category": "Ruby ",
                "Body": "First post",
                "Published_on": "06/19/2018 at 09:18PM",
                "Last_edited": "06/19/2018 at 09:18PM"
            },
            "relationships": {
                "Author": "Eunice",
                "Posts_to_date": 2,
                "Comments_to_date": 0
            }
        }
    ]
}
```
  to search by article title -> GET https://json-blog-api.herokuapp.com/api/v1/posts/search?title=Hello world
```json  
  sample response: {
    "links": {
        "self": "/blogs/1",
        "next": "/blogs/2"
    },
    "data": {
        "Type": "Blog Post",
        "Id": 1,
        "Title": "Hello world",
        "Body": "First post",
        "Category": "Ruby "
    },
    "Relationships": {
        "author": {
            "Author": "Eunice",
            "Posts_to_date": 2,
            "Comments_to_date": 0
        },
        "Comments": []
    }
}
```
#UPDATE
  to change user name -> PUT https://json-blog-api.herokuapp.com/api/v1/posts/changeuser
  specify user_id: and name: in the form-data body and Content-Type: 'application/json' in the headers
```json  
  sample response: {
    "data": {
        "type": "User",
        "id": 1,
        "attributes": {
            "name": "Sue",
            "email": "eunice@example.com"
        }
    }
}
```
  to change a post -> PUT https://json-blog-api.herokuapp.com/api/v1/posts/changepost
  append the same headers as before, but instead specify title:, body: and the post_id: in the form-data body
```json  
  sample response: {
    "data": {
        "type": "Blog Post",
        "id": 1,
        "title": "great world",
        "body": " foo bar",
        "updated_at": "06/19/2018 at 09:31PM",
        "relationships": {
            "author": "Sue"
        }
    }
}
```
#DELETE 
  to delete a post -> DELETE https://json-blog-api.herokuapp.com/api/v1/posts/1
  specify post id in the query string, if delete is successful 
```json  
  this response is returned: {
    "code": 200,
    "status": "OK",
    "attributes": {
        "title": "great world",
        "author": "Sue",
        "tag": "ruby ",
        "deleted_at": "06/19/2018 at 09:34PM"
    }
}
```
