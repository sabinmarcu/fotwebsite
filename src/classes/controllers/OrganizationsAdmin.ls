class OrganizationsAdminController extends DepMan.controller "Base"

    (@scope, @location, @root, @comms) ~>
        @comms.hook "admin:org:all", @loadPostsHook
        @comms.hook "admin:org:new", @newPostsHook
        @comms.hook "admin:org:remove", @deleteHook
        @organizations = []
        @debug = active: false, message: "", type: ""
        @currentpost = null

        urlHandler = ~> 
            @scope.currentpost = null
            if @location.path!match /\/membership\/organizations\/?$/ then @loadPosts!
            else 
                m = @location.path!match /\/membership\/organizations\/edit\/([0-9a-z]*)$/ 
                if m? then @loadPosts m.1
                else if @location.path!match /\/membership\/organizations\/add$/ then @scope.currentpost = {}

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!
        
        @scope.isMobile = Tester.mobile
        super ...

    loadPosts: (post = null) ~> 
        @log "Asking for organizations"
        @comms.send "getAdminOrgs", post
    loadPostsHook: (err, data) ~>
        @log "Got organizations", err, data
        if err then @log err
        else 
            while @organizations.length > 0 then @organizations.pop!
            for post in data then @organizations.push post
            m = @location.path!match /\/membership\/organizations\/edit\/([0-9a-z]*)$/ 
            if m? then @scope.currentpost = @findById m.1
            @safeApply!

    delete: ~> 
        @log "Sending delete command", @scope.currentpost
        if @scope.currentpost? then @comms.send "removeOrg", @scope.currentpost._id
    deleteHook: (err, data) ~>
        @log "Got results of the delete", err, data
        if err then @comms.message "error", err
        else 
            @location.path "/membership/organizations"
            @posts.pop!
            @scope.safeApply!

    update: ~> @log "Updating", @scope.currentpost; @comms.send "addOrg", @scope.currentpost
    newPostsHook: (err) ~>
        @log "BACK", err
        if err then @comms.message "error", "There has been an error!"
        else @comms.message "success", "Updated!"

    findById: (id) ~>
        for post in @organizations 
            if post._id is id then return post
        return null

    isActive: (section) ~>
        switch section
            case 'list'
                if @location.path!match /\/membership\/organizations$/ then "active"
                else ""
            case 'edit'
                if @location.path!match /\/membership\/organizations\/(add|edit\/[0-9a-z]*)$/ then "active"
                else ""

    @hook ["$location", "$rootScope", 'Comms']
