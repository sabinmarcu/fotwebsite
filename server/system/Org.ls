require! <[mongoose node-uuid mongoose-unique-validator isf]>

class Org extends require "./BaseModel"

    @initLogs!

    @props = 
        facebook: String
        name: String

    @methods = 
        add: ->
            promise = new isf.Promise!
            promise.then (org) ~>
                for key, value of org then if key.match /\$/g then delete org[key]
                if org._id?
                    org.added = new Date!
                    Org.model.update "_id": org._id, org, (err, data) ~>
                        if err then promise.reject err
                        else promise.resolve true
                else 
                    @load org
                    @added = new Date!
                    @save (err, data) ~>
                        console.log err
                        if err then promise.reject err
                        else promise.resolve true
            , ~> promise.reject!
            promise

        load: (data = {}) -> for key, value of data when Org.props[key]? then @[key] = value; @

    @api = 
        "addOrg": (sock, router, connection, post) ~>
            promise = (new @model!).add!

            success = ~>
                try
                    for conn in router.connections
                        conn.sock.emit "org:new"
                    sock.emit "admin:org:new", null, true
                catch error
                    @error error
            error = ~> sock.emit "admin:org:new", it
            progress = ~> sock.emit "admin:org:new:progress", it

            promise.then success, error, progress .resolve post

        "removeOrg": (sock, router, connection, postid) ~>        
            @log "Received delete command for #postid"
            if not postid? then sock.emit "admin:org:remove", new Error "Invalid data received"
            @model.find "_id": postid .remove (err, data) ~>
                @log "Executed delete command for #postid", err
                if err then sock.emit "admin:org:remove", err
                else sock.emit "admin:org:remove", null

        "getAdminOrgs": (sock, router, connection, post = null) ~>

            if post then q = "_id": post
            else q = {}

            @model.find q, (err, data) ~>
                if err then sock.emit "admin:org:all", err
                else sock.emit "admin:org:all", null, data


    @initModel!
        
    if mongoose.connection.readyState is 0 then mongoose.connect "mongodb://localhost/test"

    @setPropExport module.exports