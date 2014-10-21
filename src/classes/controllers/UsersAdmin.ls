class UsersAdminController extends DepMan.controller "Base"

    (@scope, @location, @root, @comms) ~>
        @comms.hook "admin:user:all", @loadPostsHook
        @comms.hook "admin:user:new", @newPostsHook
        @comms.hook "admin:user:remove", @deleteHook
        @users = []
        @debug = active: false, message: "", type: ""
        @currentpost = null

        urlHandler = ~> 
            @scope.currentpost = null
            if @location.path!match /\/membership\/users\/?$/ then @loadPosts!
            else 
                m = @location.path!match /\/membership\/users\/edit\/([0-9a-z]*)$/ 
                if m? then @loadPosts m.1
                else if @location.path!match /\/membership\/users\/add$/ then @scope.currentpost = {}

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!
        
        @scope.isMobile = Tester.mobile
        super ...

    loadPosts: (post = null) ~> 
        @log "Asking for users"
        @comms.send "getAdminUsers", post
    loadPostsHook: (err, data) ~>
        @log "Got users", err, data
        if err then @log err
        else 
            while @users.length > 0 then @users.pop!
            for post in data then @users.push post
            m = @location.path!match /\/membership\/users\/edit\/([0-9a-z]*)$/ 
            if m? then @scope.currentpost = @findById m.1
            @safeApply!

    delete: ~> 
        @log "Sending delete command", @scope.currentpost
        if @scope.currentpost? then @comms.send "removeUser", @scope.currentpost._id
    deleteHook: (err, data) ~>
        @log "Got results of the delete", err, data
        if err then @comms.message "error", err
        else 
            @location.path "/membership/users"
            @posts.pop!
            @scope.safeApply!

    update: ~> 
        @log "Updating", @scope.currentpost
        @comms.send "addUser", @scope.currentpost
    reset: ~> 
        @log "Resetting Password", @scope.currentpost
        @comms.send "resetUserPassword", @scope.currentpost
        
    newPostsHook: (err) ~>
        @log "BACK", err
        if err then @comms.message "error", "There has been an error!"
        else @comms.message "success", "Updated!"

    findById: (id) ~>
        for post in @users 
            if post._id is id then return post
        return null

    isActive: (section) ~>
        switch section
            case 'list'
                if @location.path!match /\/membership\/users$/ then "active"
                else ""
            case 'edit'
                if @location.path!match /\/membership\/users\/(add|edit\/[0-9a-z]*)$/ then "active"
                else ""

    @hook ["$location", "$rootScope", 'Comms']
