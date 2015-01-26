require! <[mongoose crypto node-uuid mongoose-unique-validator isf]>

mailer = require "./Mailer"
templates = require "./EmailTemplate"

{keys, replicate, lists-to-obj, map} = require "prelude-ls"
debug = (require \debug)(\app:User)
debug.error = (require \debug)(\app:User:Error)
debug.error.log = console.error.bind console

randomString = -> pos = 'QWERTYUIOPASDFGHJKLZXCVBNM1234567890qwertyuiopasdfghjklzxcvbnm'; [pos.charAt(Math.floor(Math.random()*pos.length)) for i in [0 til it]].join ""



class User extends require "./BaseModel"

    @initLogs!

    @props = 
        name: String
        email: {type: String, unique: true}
        password: String
        salt: String
        dob: Date
        number: String
        nationality: String
        phone: Number
        address: String
        major: String
        school: String
        image: String
        type: Number
        activated: String
        authtoken: String
        facebook: String
        account_number: Number

    @methods = 
        login: ->
            promise = new isf.Promise
            promise.then (data, fromStorage = null) ~>
                if data?
                    promise.progress "Attempting login"
                    User.model.find email: data.email, activated: "true", (err, user) ~>
                        promise.progress "Got something", err, user.length
                        if err or user.length isnt 1
                            promise.progress "Error before password", err
                            if err then promise.reject err
                            else if user.length is 0 then promise.reject "Invalid Credentials or Inactive Account"
                            else promise.reject "Something went terribly wrong!"
                        else 
                            @log "Trying #{data.authtoken} with #{user.0.authtoken}"
                            if (fromStorage and data.authtoken is user.0.authtoken) or ((crypto.create-hash "sha256" .update "#{data.password}#{user.0.salt}" .digest "base64") is user.0.password)
                                promise.progress "Everything OK"
                                d = {}
                                for key, value of User.props then d[key] = user.0.[key]
                                d.authtoken ?= node-uuid.v1!
                                @log "Saving Auth Token"
                                User.model.update '_id': user.0._id, d, (err, data) ~>
                                    @log "Saved Auth Token", err
                                    if err then promise.reject err
                                    else
                                        d._id = user.0._id 
                                        promise.resolve d
                            else promise.resolve false
            promise

        update: (data) -> @load data .save!; @

        register: ->
            promise = new isf.Promise
            promise.then (data) ~> 
                for key, value of data then if key.match /\$/g then delete data[key]
                if data._id?
                    @log "Must update existing user"

                    if data.password
                        debug "Must modify password"
                        data.salt = randomString 25

                        debug "Hashing password with salt", data.password, data.salt
                        data.password = crypto.create-hash "sha256" .update "#{data.password}#{data.salt}" .digest "base64"

                        debug "New password created", data.password

                    @log "Checking for updated permissions"

                    k = ((keys User.model._parent.props) * ',' - 'image,') / ','
                    ko = lists-to-obj k, (replicate k.length, true)

                    User.model.find {"_id": data._id}, ko, (err, dbdata) ~>
                        if err then promise.reject err 
                        else
                            if data.type isnt dbdata.0.type
                                @log "Permission Changed (#{data.type}, #{dbdata.0.type})"
                                User.model.find {"type": 2}, (err, admins) ~>
                                    if err then debug.error "Problem at retrieving all admins to notify"
                                    else
                                        for admin in admins
                                            @log "Sending email to #{admin.name} (#{admin.email})"
                                            mailer.send "sabin@lytic.co.uk", admin.email, "Changed Permission for #{data.name}", templates.compile "permission-change", name: data.name, email: data.email


                            @log "Updating"
                            User.model.update "_id": data._id, data, (err, d) ~>
                                @log "Done updating", err
                                if err then promise.reject err
                                else promise.resolve data
                else 
                    @log "Must register a new user"
                    @load data
                    @salt = randomString 25

                    @log "Hashing password with salt", @password, @salt
                    @password = crypto.create-hash "sha256" .update "#{@password}#{@salt}" .digest "base64"

                    @log "New password created", @password
                    @type = 0
                    @activated = 'false'

                    @log "Saving new user"
                    @save (err, data) ~>
                        if err then promise.reject err
                        else
                            @log "Sending email"
                            mailer.send "sabin@lytic.co.uk", @email, "Welcome to ISR", null, templates.compile "welcome-email", website: "localhost", name: @name, id: @_id

                            @log "Sending result"
                            promise.resolve @
            promise

        load: (data = {}) -> for key, value of data when User.props[key]? then @[key] = value; @

    @staticapi = 
        "/api/user/image/:id": (req, res) ~>
            @log "Serving image for #{req.params.id}"
            @model.find {_id: req.params.id}, {image: "true"}, (err, data) ~>
                if err or not data.0.image? then res.send "Does not exist", {"Content-Type": "text/plain"}, 404
                else 
                    try
                        ct = data.0.image.match /:([a-z\/]+);/ .1
                        b = new Buffer(data.0.image.match /,([a-zA-Z0-9+/]+={0,2})$/ .1, "base64")
                        @log "Will send pic", ct, b
                        res.set "Content-Type": ct
                        res.end b, \binary
                    catch e
                        res.send "There was a problem retrieving the image", {"Content-Type": "text/plain"}, 501

    @api = 
        "login": (sock, router, connection, data, fromStorage = false) ~>
            promise = (new @model!).login!

            success = (user) ~>
                if user then
                    nu = {}; props = keys @props
                    for k, v of user
                        if k in props or k is "_id"
                            if not (k in ["password", "salt", "image"])
                                nu[k] = v

                    connection.user = nu

                    @log "Sending login data"
                    sock.emit "login", null, connection.user
                else sock.emit "login", null, false

            error = (err) ~> @error err; sock.emit "login", err
            progress = ~> @log ...

            @log "Attempting Login"
            promise.then success, error, progress .resolve data, fromStorage

        "logout": (sock, router, connection) ~> if connection.user then delete connection.user

        "register": (sock, router, connection, data) ~>
            promise = (new @model!).register!

            success = ~> sock.emit "register", null, it
            error = ~> sock.emit "register", it
            progress = ~> sock.emit "register:progress", it

            promise.then success, error, progress .resolve data

        "saveUserDetails": (sock, router, connection, post) ~>

            promise = (new @model!).register!

            success = ~>
                try
                    sock.emit "admin:user:new", null, true
                catch error
                    @error error
            error = ~> sock.emit "admin:user:new", it
            progress = ~> sock.emit "admin:user:new:progress", it

            promise.then success, error, progress .resolve post

        "addUser": (sock, router, connection, post) ~>
            promise = (new @model!).register!

            success = ~>
                try
                    sock.emit "admin:user:new", null, true
                catch error
                    @error error
            error = ~> sock.emit "admin:user:new", it
            progress = ~> sock.emit "admin:user:new:progress", it

            promise.then success, error, progress .resolve post

        "resetUserPassword": (sock, router, connection, email) ~>

            @log "Going to reset password"
            @model.find "email": email, (err, user) ~>
                if error then sock.emit "login:resetted", err
                else
                    if user.length is 1
                        t = user.0
                        ks = keys @props
                        user = {}

                        @log t, ks, user
                        for k, v of t
                            if k in ks then user[k] = v

                        user._id = t._id
                        promise = (new @model!).register!

                        user.password = tempPass = randomString 10

                        @log "Created a new password, #{user.password}"

                        success = ~>
                            try
                                sock.emit "login:resetted", null, true
                                mailer.send "sabin@lytic.co.uk", it.email, "Password Reset", null, templates.compile "password-reset", name: user.name, pass: tempPass
                            catch error
                                @error error
                        error = ~> sock.emit "login:resetted", it
                        progress = ~> sock.emit "login:resetted:progress", it

                        @log user
                        promise.then success, error, progress .resolve user
                    else sock.emit "login:resetted", null, false


        "resetAdminPassword": (sock, router, connection, user) ~>


            @log "Going to reset password (from admin panel)"

            try
                promise = (new @model!).register!

                user.password = tempPass = randomString 10

                @log "Created a new password, #{user.password}"
                success = ~>
                    try
                        sock.emit "admin:user:resetted", null, true
                        mailer.send "sabin@lytic.co.uk", it.email, "Password Reset", null, templates.compile "password-reset", name: user.name, pass: tempPass
                    catch error
                        @error error
                error = ~> sock.emit "admin:user:resetted", it
                progress = ~> sock.emit "admin:user:resetted:progress", it

                promise.then success, error, progress .resolve user
            catch e
                @error e

        "getAdminUsers": (sock, router, connection, post = null) ~>

            if post then q = "_id": post
            else q = {}

            @log "Started user Query"

            k = (keys @props); k.splice (k.indexOf "image"), 1
            ko = lists-to-obj k, (replicate k.length, true)

            @log "Querying the database", q, ko, k
            @model.find q, ko .sort "name": 1 .exec (err, data) ~>
                @log "Query successful", err, data
                if err then sock.emit "admin:user:all", err
                else sock.emit "admin:user:all", null, data

        "removeUser": (sock, router, connection, postid) ~>
            @log "Received delete command for #postid"
            if not postid? then sock.emit "admin:user:remove", new Error "Invalid data received"
            @model.find "_id": postid .remove (err, data) ~>
                @log "Executed delete command for #postid", err
                if err then sock.emit "admin:user:remove", err
                else sock.emit "admin:user:remove", null

    @initModel!
        
    if mongoose.connection.readyState is 0 then mongoose.connect "mongodb://localhost/test"

    @setPropExport module.exports



