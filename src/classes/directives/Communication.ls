class Communication extends IS.Object
    (@root, @toast) ~> 
        window.Comms = @
        @sock = (DepMan.lib "socket.io")!
        @log = new Debug("app:Connection")
        @meta = {}

    checkLogin: ~> 
        @log "Checking login data (offline)"
        DBStorage.get "user", (user) ~> 
            @log "Got login data (offline)", user
            if user? then @send "login", user, true

    hook: (event, handler) ~> 
        let h = handler, e = event
            @log e, " hooked to", h
            @sock.on event, (...args) ~>
                @log e, " receiving ", args
                h.apply h, args
    send: (event, ...args) ~> 
        @log event, " sending " args
        @sock.emit.apply @sock, [event] ++ args

    logout: ~>
        delete @user
        @log "Deleted from store, going to delete from DB"
        DBStorage.remove "user", ~>
            if it then @message "error", "Could not log you out!"
            else 
                setTimeout ~>
                    @log "Deleted from DB, logging out"
                    @send "logout"
                    @root.$broadcast "user:loggedout"
                    @message "success", "You have been logged out!"
                500

    message: (type, msg, position = "bottom right", duration = 3000) ~>
        @toast.show template: (DepMan.render "toast", type: type, content: msg), duration: duration, position: position
        setTimeout (-> angular.element "material-toast" .remove!), duration + 2000

angular.module AppInfo.displayname .service \Comms,["$rootScope", "$materialToast", Communication]