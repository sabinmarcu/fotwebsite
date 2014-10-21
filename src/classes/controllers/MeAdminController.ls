class MeAdminController extends DepMan.controller "Base"

    (@scope, @location, @root, @comms) ~>
        @comms.hook "admin:me:reset", @resetsHook
        @comms.hook "admin:me:update", @updateHook
        @users = []
        @debug = active: false, message: "", type: ""
        @currentpost = null

        urlHandler = ~> 

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!
        
        @scope.isMobile = Tester.mobile
        super ...



    update: ~> 
        @log "Updating", @comms.user
        @comms.send "addUser", @comms.user

    reset: ~> 
        @log "Resetting Password", @comms.user
        @comms.send "resetUserPassword", @comms.user
        
    resetHook: (err) ~>
        @log "BACK", err
        if err then @comms.message "error", "There has been an error!"
        else @comms.message "success", "Updated!"
    updateHook: (err) ~>
        @log "BACK", err
        if err then @comms.message "error", "There has been an error!"
        else @comms.message "success", "Updated!"

    isActive: ~> @location.path!match /\/membership\/me\/?$/

    @hook ["$location", "$rootScope", 'Comms']
