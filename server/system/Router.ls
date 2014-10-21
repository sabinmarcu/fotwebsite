io = require "socket.io"
mongoose = require "mongoose"

debug = (require "debug")("app:Router")
debug.error = (require "debug")("app:Router:error")
debug.error.log = console.error.bind console

class Router
    (@static, express) ~>

        if mongoose.connection.readyState is 0 then mongoose.connect "mongodb://localhost/test"

        @server = io @static
        @connections = []

        (require "./Connection").Connection = express

        @server.on "connection", ~>
            try
                debug 
                @connections.push new (require "./Connection").Connection(it, @)
            catch error
                debug.error error

        @server.on "error", ~>
            console.log it

        console.log "Hooked WebSocket Server"

module.exports = Router