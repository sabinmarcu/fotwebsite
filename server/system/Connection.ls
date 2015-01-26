models =
    Org: require "./Org" .Org
    Event: require "./Event" .Event
    User: require "./User" .User
    Post: require "./Post" .Post

require! <[async crypto isf]>
debug = (require \debug)(\app:Connection)
debug.error = (require \debug)(\app:Connection:Error)
debug.error.log = console.error.bind console

{keys, lists-to-obj, replicate, keys, map} = require "prelude-ls"

const PAGELIMIT = 15

class Connection
    (@sock, @router) ~>
        debug "Creating connection", (typeof @sock), (typeof @router)
        for key, value of @
            m = key.match /(.*)Hook$/
            if m
                debug "Hooking #{m.1}"
                @sock.on m.1, @[key]
        debug "Setting connection for models"
        require "./User" .User               = socket: @sock, router: @router, connection: @
        require "./Post" .Post               = socket: @sock, router: @router, connection: @
        require "./Event" .Event             = socket: @sock, router: @router, connection: @
        require "./Org" .Org                 = socket: @sock, router: @router, connection: @
        require "./Transaction" .Transaction = socket: @sock, router: @router, connection: @

    echoHook: (data) ~> debug data
    
    getCombinedPostsHook: (lim) ~>

        k = ((keys models.Post._parent.props) * ',' - 'image,') / ','
        ko1 = lists-to-obj k, (replicate k.length, true)

        k = ((keys models.Event._parent.props) * ',' - 'image,') / ','
        ko2 = lists-to-obj k, (replicate k.length, true)

        LIMIT = (PAGELIMIT - lim)
        getPosts = (cb) -> models.Post.find {}, ko1 .sort "added": -1 .limit LIMIT, .exec (err, data) -> cb err, data
        getEvents = (cb) -> models.Event.find "start": {"$gte": new Date!}, ko2 .sort "added": -1 .limit LIMIT, .exec (err, data) -> cb err, data
        debug "Getting posts (combined) from #{lim}"
        async.parallel [getPosts, getEvents], (err, data) ~>
            debug "Got posts (combined) from #{lim}", data[0].length, data[1].length

            map (~> it._type = "post"), data[0]
            map (~> it._type = "event"), data[1]

            if err then @sock.emit "post:combined:all", err
            else async.sortBy data[0] ++ data[1], ((item, cb) -> cb null, item.added), (err, data) ~>
                debug "Joined posts (combined) for #{lim}", data.length
                if err then @sock.emit "post:combined:all", err
                else
                    data = data.filter (value, index) -> if index < LIMIT then value else undefined
                    data = data.reverse!
                    debug "Sending posts (combined) for #{lim}", data.length
                    @sock.emit "post:combined:all", null, ([0] ++ data)

isf.DefineProperty "Connection", ~> debug "Getting Connection"; Connection
, (server) ~>
, module.exports
