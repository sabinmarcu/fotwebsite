class PostsAdminController extends DepMan.controller "Base"

    (@scope, @location, @root, @comms) ~>
        @comms.hook "admin:post:all", @loadPostsHook
        @comms.hook "admin:post:new", @newPostsHook
        @comms.hook "admin:post:remove", @deleteHook
        @posts = []; @editors = []
        @currentpost = null

        urlHandler = ~> 
            @scope.currentpost = null

            @log @location.path!
            if @location.path!match /\/membership\/posts\/?$/ then @loadPosts!
            else 
                m = @location.path!match /\/membership\/posts\/edit\/([0-9a-z]*)$/ 
                if m? then @loadPosts m.1
                else if @location.path!match /\/membership\/posts\/add\/?$/ 
                    _id = "new" + Math.uuid()
                    @hookEditor _id
                    @scope.currentpost = {_id: _id}

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!
        
        @scope.isMobile = Tester.mobile
        super ...

    hookEditor: (id) ~>
        setTimeout ~> 
            @log "Hooking editor to \#editor-#{id}, \#editor-#{id}-input", ($ "editor-#{id}") , ($ "editor-#{id}-input")
            if not @editors[id] then @editors[id] = new EpicEditor(container: "editor-#{id}", textarea: "editor-#{id}-input", basePath: "#{window.location.origin}/extras", parser: (str) -> markdown.toHTML str).load!
        , 1000

    loadPosts: (post = null) ~> 
        @log "Asking for posts"
        @comms.send "getAdminPosts", post
    loadPostsHook: (err, data) ~>
        @log "got posts", err, data
        if err then @log err
        else 
            while @posts.length > 0 then @posts.pop!
            for post in data then @posts.push post
            m = @location.path!match /\/membership\/posts\/edit\/([0-9a-z]*)$/ 
            if m? 
                @scope.currentpost = @findById m.1
                let post = @scope.currentpost
                    @hookEditor post._id
            @safeApply!

    delete: ~> 
        @log "Sending delete command", @scope.currentpost
        if @scope.currentpost? then @comms.send "removePost", @scope.currentpost._id
    deleteHook: (err, data) ~>
        @log "Got results of the delete", err, data
        if err then @comms.message "error", err
        else 
            @location.path "/membership/posts"
            @posts.pop!
            @scope.safeApply!

    update: ~> 
        @scope.currentpost.content = @editors[@scope.currentpost._id].exportFile()
        if @scope.currentpost._id.match /^new/
            @scope.currentpost._id = null
            delete @scope.currentpost._id
        @log "Updating", @scope.currentpost;
        @comms.send "addPost", @scope.currentpost

    newPostsHook: (err) ~>
        @log "BACK", err
        if err then @comms.message "error", "There has been an error!"
        else @comms.message "success", "Updated!"

    findById: (id) ~>
        for post in @posts 
            if post._id is id then return post
        return null

    isActive: (section) ~>
        switch section
            case 'list'
                if @location.path!match /\/membership\/posts$/ then "active"
                else ""
            case 'edit'
                if @location.path!match /\/membership\/posts\/(add|edit)\/?([0-9a-z]*)?$/  then"active"
                else ""

    @hook ["$location", "$rootScope", 'Comms']
