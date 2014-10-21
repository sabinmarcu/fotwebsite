require! <[mongoose node-uuid mongoose-unique-validator isf request]>

urlToImage = (url, cb) ->
    request url: url, encoding: null, (err, res, body) ->
        if not err and res.statusCode is 200 then cb null, "data:#{res.headers['content-type']};base64,#{body.toString('base64')}"
        else cb err or new Error "Problem!"

{keys, replicate, lists-to-obj, map} = require "prelude-ls"
const PAGELIMIT = 15

class Post extends require "./BaseModel"

    @initLogs!

    @props = 
        title: String
        type: String
        from: String
        shortlink: String
        content: String
        href: String
        image: String
        imageurl: String
        added: Date

    @methods = 
        add: ->
            promise = new isf.Promise!
            promise.then (post) ~>
                for key, value of post then if key.match /\$/g then delete post[key]
                if post._id?
                    post.added = new Date!
                    urlToImage post.imageurl, (err, image) ~>
                        if err then promise.reject err
                        else
                            post.image = image 
                            Post.model.update "_id": post._id, post, (err, data) ~>
                                if err then promise.reject err
                                else promise.resolve true
                else 
                    @load post
                    @added = new Date!
                    urlToImage post.imageurl, (err, image) ~>
                        if err then promise.reject err
                        else
                            @image = image 
                            @save (err, data) ~>
                                console.log err
                                if err then promise.reject err
                                else promise.resolve true
            , ~> promise.reject!
            promise

        load: (data = {}) -> for key, value of data when Post.props[key]? then @[key] = value; @

    @staticapi = 
        "/api/post/image/:id": (req, res) ~>
            @log "Serving image for #{req.params.id}"
            @model.find {_id: req.params.id}, {image: "true"}, (err, data) ~>
                if err then res.send "Does not exist", {"Content-Type": "text/plain"}, 404
                else 
                    ct = data.0.image.match /:([a-z\/]+);/ .1
                    b = new Buffer(data.0.image.match /,([a-zA-Z0-9+/]+={0,2})$/ .1, "base64")
                    @log "Will send pic", ct, b
                    res.set "Content-Type": ct
                    res.end b, \binary

    @api = 
        "getPosts": (sock, router, connection, it) ~>
            @log "Getting posts from #it"

            try
              
                k = ((keys @props) * ',' - 'image,') / ','
                ko = lists-to-obj k, (replicate k.length, true) 

                @model.find {}, ko .sort "added": -1 .limit PAGELIMIT .skip it * PAGELIMIT, .exec (err, data) ~>
                    @log "Got posts from #it", err
                    if err then sock.emit "post:post:all", err
                    else 
                        @model.count!exec (err, count) ~>
                            @log "Sending posts from #it with count #count", err
                            if err then sock.emit "post:post:all", err
                            else sock.emit "post:post:all", null, ([count] ++ data)
            catch e
                @error e

        "addPost": (sock, router, connection, post) ~>
            @log "Got request for a new (updated) post", post
            promise = (new @model!).add!

            success = ~>
                try          
                    for conn in router.connections
                        conn.sock.emit "post:new"
                    sock.emit "admin:post:new", null, true
                catch error
                    @error error
            error = ~> @error it; sock.emit "admin:post:new", it
            progress = ~> @log it; sock.emit "admin:post:new:progress", it

            promise.then success, error, progress .resolve post

        "removePost": (sock, router, connection, postid) ~>
            @log "Received delete command for #postid"

            if not postid? then sock.emit "admin:post:remove", new Error "Invalid data received"
            @model.find "_id": postid .remove (err, data) ~>
                @log "Executed delete command for #postid", err
                if err then sock.emit "admin:post:remove", err
                else sock.emit "admin:post:remove", null, true

        "getAdminPosts": (sock, router, connection, post) ~>

            @log "Getting admin posts", post
            k = ((keys @props) * ',' - 'image,') / ','
            ko = lists-to-obj k, (replicate k.length, true)

            if post then q = "_id": post
            else q = {}

            @model.find q, ko .sort "added": -1 .exec (err, data) ~>
                if err then sock.emit "admin:post:all", err
                else sock.emit "admin:post:all", null, data

    @initModel!
        
    if mongoose.connection.readyState is 0 then mongoose.connect "mongodb://localhost/test"

    @setPropExport module.exports