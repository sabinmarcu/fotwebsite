class TransactionsAdminController extends DepMan.controller "Base"

    (@scope, @location, @root, @comms) ~>
        @comms.hook "admin:transaction:all", @loadPostsHook
        @comms.hook "admin:transaction:new", @newPostsHook
        @comms.hook "admin:transaction:remove", @deleteHook
        @transactions = []
        @debug = active: false, message: "", type: ""
        @currentpost = null

        urlHandler = ~> 
            @scope.currentpost = null
            if @location.path!match /\/membership\/transactions\/?$/ then @loadPosts!
            else 
                m = @location.path!match /\/membership\/transactions\/edit\/([0-9a-z]*)$/ 
                if m? then @loadPosts m.1

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!
        
        @scope.isMobile = Tester.mobile
        super ...

    loadPosts: (post = null) ~> 
        @log "Asking for transactions"
        @comms.send "adminGetAllTransactions", post

    loadPostsHook: (err, data) ~>
        @log "Got transactions", err, data
        if err then @log err
        else 
            while @transactions.length > 0 then @transactions.pop!
            for post in data then @transactions.push post
            m = @location.path!match /\/membership\/transactions\/edit\/([0-9a-z]*)$/ 
            if m? then @scope.currentpost = @findById m.1
            @safeApply!

    delete: ~> 
        @log "Sending delete command", @scope.currentpost
        if @scope.currentpost? then @comms.send "removeOrg", @scope.currentpost._id
    deleteHook: (err, data) ~>
        @log "Got results of the delete", err, data
        if err then @comms.message "error", err
        else 
            @location.path "/membership/transactions"
            @posts.pop!
            @scope.safeApply!

    findById: (id) ~>
        for post in @transactions 
            if post._id is id then return post
        return null

    isActive: (section) ~>
        switch section
            case 'list'
                if @location.path!match /\/membership\/transactions$/ then "active"
                else ""
            case 'edit'
                if @location.path!match /\/membership\/transactions\/edit\/[0-9a-z]*$/ then "active"
                else ""

    @hook ["$location", "$rootScope", 'Comms']
