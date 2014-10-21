require! <[mongoose node-uuid mongoose-unique-validator fb isf request]>

Org = require "./Org" .Org

urlToImage = (url, cb) ->
    request url: url, encoding: null, (err, res, body) ->
        if not err and res.statusCode is 200 then cb null, "data:#{res.headers['content-type']};base64,#{body.toString('base64')}"
        else cb err or new Error "Problem!"

{keys, replicate, lists-to-obj, map} = require "prelude-ls"
const PAGELIMIT = 15

class Event extends require "./BaseModel"

    @initLogs!

    @props = 
        title: String
        type: String
        from: String
        href: String
        image: String
        added: Date
        start: Date
        end: Date
        id: {type: String, unique: true}

    @methods = 
        add: ->
            promise = new isf.Promise!
            promise.then (post, from) ~>
                for key, value of post then if key.match /\$/g then delete post[key]
                unless post._id?
                    @title = post.name
                    @type = post.location
                    @from = from
                    @id = post.id
                    @start = new Date post.start_time
                    @end = new Date post.end_time
                    @href = "https://facebook.com/events/#{post.id}"
                    if post.cover? 
                        urlToImage post.cover.source, (err, image) ~>
                            if err then promise.reject err
                            else 
                                @image = image
                                @added = new Date!
                                @save (err, data) ~>
                                    if err then promise.reject err
                                    else promise.resolve true
                    else
                        @image = null
                        @added = new Date!
                        @save (err, data) ~>
                            if err then promise.reject err
                            else promise.resolve true
            , ~> post.reject!
            promise
        load: (data = {}) -> for key, value of data when Event.props[key]? then @[key] = value; @

    @staticapi = 
        "/api/event/image/:id": (req, res) ~>
            @log "Serving image for #{req.params.id}"
            @model.find {_id: req.params.id}, {image: "true"}, (err, data) ~>
                if err or not data.0.image? then res.send "Does not exist", {"Content-Type": "text/plain"}, 404
                else 
                    ct = data.0.image.match /:([a-z\/]+);/ .1
                    b = new Buffer(data.0.image.match /,([a-zA-Z0-9+/]+={0,2})$/ .1, "base64")
                    @log "Will send pic", ct, b
                    res.set "Content-Type": ct
                    res.end b, \binary

    @api = 
        "getEvents": (sock, router, connection, it) ~>
            @log "Getting events from #it"

            k = ((keys @props) * ',' - 'image,') / ','
            ko = lists-to-obj k, (replicate k.length, true)

            @model.find "start": {"$gte": new Date!}, ko .sort "added": -1 .limit PAGELIMIT .skip it * PAGELIMIT, .exec (err, data) ~>
                @log "Got events from #it", err
                if err then sock.emit "post:event:all", err
                else
                    @model.count!exec (err, count) ~>
                        @log "Sending events from #it with count #count", err
                        if err then sock.emit "post:event:all", err
                        else sock.emit "post:event:all", null, ([count] ++ data)

    @grab = (cb) ~> 
        try
            @log "Grabbing FB Events"
            Org.find (err, data) ~>
                if err then throw new Error err
                else
                    if data.length isnt 0
                        for org in data
                            @log "Getting events for #{org.facebook}"
                            [ "/#{org.facebook}/events",  "/pages/#{org.facebook}/events" ].map (endpoint) ~> 
                                fb.api endpoint, fields: "id, cover, name, location, start_time, end_time", ~> 
                                    if it.data?
                                        for item in it.data 
                                            @log "Checking if event #{item.id} (#{item.title}) exists"
                                            Event.model.find "id", item.id, (err, data) ~>
                                                if err then throw new Error err
                                                else 
                                                    if data.length is 0 
                                                        @log "Event #{item.id} does not exist."
                                                        (new Event.model!).add!resolve item, org.name
                                                    else
                                                        @log "Event #{item.id} exists." 
                                                        Event.model.update "id": item.id, item, (err, data) ->
                                                            if err then throw new Error err
                                    delete it.data
        catch e
            @error e
        setTimeout @grab, 5000

    @connect = (cb) ~>

        opts = grant_type: "client_credentials", client_id:'353273218168906', client_secret:'37b282c42e4af0b2a24b3fe0f7044595'

        fb.api "oauth/access_token", opts, (res) ~>
            if not res or res.error then throw new Error "Facebook Declined!"
            else 
                fb.setAccessToken res.access_token
                cb?!

    @initModel!
        
    if mongoose.connection.readyState is 0 then mongoose.connect "mongodb://localhost/test"

    @connect @grab

    @setPropExport module.exports

