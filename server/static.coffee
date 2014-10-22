
require "isf" # We're gonna need the ISF framework to help with ErrorReporting (for now)

info = require ( require "path" ).resolve "#{__dirname}/../package.json"

debug = (require "debug")("app:StaticServer")
debug.error = (require "debug")("app:StaticServer:Error")
debug.error.log = console.error.bind(console)

#notify = require "node-notifier"
#notif = new notify()

# Defining the Server Bootstrap class (the actual work is done by Express)
class Server

    # On construction we need an address and a port to start the server on
    # @param data Object An Object containing the address and port (both strings)
    # @return Server The server instance
    constructor: (data, @watch = false, @bundle = false) ->

        for item, values of data
            if values.length <= 1 then data[item] = values[0]

        # Testing to check for the right value
        return throw ServerErrorReporter.generate 1 if not data.address?
        return throw ServerErrorReporter.generate 2 if not data.port?
        return throw ServerErrorReporter.generate 3 if not data.address.substr?
        return throw ServerErrorReporter.generate 4 if not data.port.substr?

        # Going forward with the construction
        @address = data.address
        @port = parseInt data.port

    # Connect a compiler or other objects (if some other dev enables it)
    # @param CompilerObject Compiler The compiler object to be attached to the static server.
    # @return Server The current server instance
    connect: (CompilerObject) ->

        # Checking for the right object
        return throw ServerErrorReporter.generate 5 if not CompilerObject?
        return throw ServerErrorReporter.generate 6 if not CompilerObject.compile?

        # Moving forward
        @compiler = CompilerObject
        @

    # Start the server on the address and port specified when constructing it
    # @return Server The current server instance
    start: ->

        # Grabbing Express and checking if it is there
        Express = require "express"
        return throw ServerErrorReporter.generate 7 if not Express?

        try # Attempt to configure the server and return an error
            App = do Express
            Server = require("http").createServer App
            #ServerSSL = require("https").createServer {cert: (require "fs").readFileSync((require "path").resolve "#{__dirname}/../certs/server.crt"), key: (require "fs").readFileSync((require "path").resolve "#{__dirname}/../certs/server.key")}, App
            #App.use (req, res, next) =>
                #if not /https/.test req.protocol
                    #url = "https://#{req.headers.host}#{req.url}"
                    #if process.env.NODE_ENV is "development"
                        #if /:[0-9]+/.test req.headers.host then url = url.replace /:[0-9]+/, ":#{@port + 1}"
                        #else url = "https://#{req.headers.host}:#{@port + 1}#{req.url}"
                    #res.redirect url
                #else do next
            App.use (require "body-parser").json()
            App.use (require "body-parser").urlencoded()

            APp.Use (req, res, next) =>
                res.set "Cache-Control": "no-transform"
                do next

            # Hook models API endpoints
            try
                debug "Hooking Models to API endpoints"
                (require "./system/Post") .Post               = server: App
                (require "./system/Org") .Org                 = server: App
                (require "./system/User") .User               = server: App
                (require "./system/Event") .Event             = server: App
                (require "./system/Transaction") .Transaction = server: App
            catch e then @err e
                
            if @compiler?
                App.get "/js/#{info.name}.js", (req, res) => @compiler.compile null, (err, source) =>
                    if err then @err err
                    else
                        res.set "Content-Type": "application/javascript" 
                        res.send source, 201
                App.get "/js/#{info.name}.payload.js", (req, res) => @compiler.compileAux null, (err, source) =>
                    if err then @err err
                    else
                        res.set "Content-Type": "application/javascript" 
                        res.send source, 201
                if !@bundle
                    App.get "/css/#{info.name}.css", (req, res) => @compiler.compileStyles null, (err, source) =>
                        if err then @err err
                        else
                            res.set "Content-Type": "text/css" 
                            res.send source, 201
                
            App.get "*", (req, res) =>
                console.log "Requested", (require "path").resolve "#{__dirname}/../public#{req.url}"
                (require "fs").exists ((require "path").resolve "#{__dirname}/../public#{req.url}"), (exists) ->
                    if exists and req.url isnt "/" then res.sendfile ((require "path").resolve "#{__dirname}/../public#{req.url}")
                    else
                        content = (require "fs").readFileSync (require "path").resolve("#{__dirname}/../public/_index.html"), "utf-8"
                        content = content.replace /\<\<appname\>\>/, info.name
                        (require "fs").writeFileSync (require "path").resolve("#{__dirname}/../public/index.html"), content
                        res.send content, {"Content-Type": "text/html"}, 201
            # And if watch is enabled ...
            if @watch
                livereload = require "livereload"
                server = livereload.createServer exts: ["styl", "coffee", "json", "eco", "jade", "yaml", "ls", "md"], applyCSSLive: true, originalPath: "http://localhost:#{@port}/"
                server.watch "#{__dirname}/../src"
        catch e then @err e
        
        # Finally launch the server
        try
            Server.listen @port, @address
            new (require "./system/Router")(Server, App)
            #ServerSSL.listen @port + 1, @address
            console.log "Started the static server on address : #{@address}, and port : #{@port}"
            #console.log "Started the SSL static server on address : #{@address}, and port : #{@port + 1}"
            console.log "Instant compiling is enabled." if @compiler?
            Server.on "uncaughtException", @err
            Server.on "error", @err
        catch e then @err e

        process.on "uncaughtException", (err) =>
            #notif.notify title: "Big System Error", message: err.message or err
            debug "Big Error", err.message or err
            debug err.stack
            process.exit 1

        @

    err: (err) ->
        debug "Server Error", err.message or err
        debug "Stack : ", err.stack or err
        if not process.comp_args.verbose then process.exit 1

# Defining the ErrorReporting for the Server class
class ServerErrorReporter extends IS.Object

    # Defining the error messages, assigning them to groups and naming them.
    @errors =
        "ConstructorError": [
            "There is no address supplied"
            "There is no port supplied"
            "The address is not a string"
            "The port is not a string"
        ]
        "CompileConnectionError": [
            "There was no object supplied"
            "The object supplied was not compatible"
        ]
        "InternalError": [
            "Express module was not installed"
            "Error at configuring the server"
            "Error at starting the server"
            "Error at starting the data transfer server"
        ]

    # Making sure it behaves as it should
    @extend IS.ErrorReporter


# Exporting the server
module.exports = Server
