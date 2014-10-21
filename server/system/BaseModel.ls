require! <[mongoose mongoose-unique-validator isf]>

debug = (require "debug")("app:BaseModel")
debug.error = (require "debug")("app:#BaseModel:error")
debug.error.log = console.error.bind console

class BaseModel

    @initLogs = ->
        debug "Initializing logs for #{@name}"
        @log = @::log = (require "debug")("app:#{@name}")
        @error =  @::error = (require "debug")("app:#{@name}:error")
        @error.log = console.error.bind console

    @initModel = ->
        debug "Initializing model for #{@name}"
        @model = do ~>
            @log "Creating Model for #{@name}"
            schema = mongoose.Schema @props
            for key, method of @methods then schema.methods[key] = method
            schema.methods.log = @log
            schema.methods.error = @error
            schema.plugin mongoose-unique-validator
            model = mongoose.model @name, schema
            model._parent = @
            model._debug = debug
            model

    @setPropExport = (module) ->
        debug "Defining Property Export for #{@name}"
        isf.DefineProperty @name, ~> @log "Getting User"; @model
        , (data) ~> 
            @log "Setting User Server"
            if data.server?      then @loadServer? data.server
            if data.connection?  then @loadConnection? data.connection, data.router, data.socket
        , module
        @

    @loadServer = (server) ->           
        if @staticapi? 
            for route, handler of @staticapi
                let r = route, h = handler
                    server.get r, h     
        if @staticpostapi? 
            for route, handler of @staticpostapi
                let r = route, h = handler
                    server.post r, h
    @loadConnection = (connection, router, socket) ->   
        if @api?
            for ev, handler of @api 
                let e = ev, h = handler
                    socket.on e, (...args) -> h.apply h, [socket, router, connection] ++ args


module.exports = BaseModel