{replicate} = prelude

class PostsController extends DepMan.controller "Base"
    (@scope, @location, @root, @comms, @dialog) ~>
        @content = []
        @pinchRecognizerHooked = false
        @data = article: null, state: false, page: 0, numposts: 2, inactive: false, scroll: top: 0
        @isMobile = Tester.mobile
        @comms.hook "post:post:all", @loadPostsHook
        @comms.hook "post:post:image", @loatPostImage
        @comms.hook "post:new", @loadPosts

        urlHandler = ~>
            m = @location.path!.match /posts\/?([0-9]+)?/
            if m? then @loadPosts (m.1 or 0)

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!
        
        window.addEventListener "resize", ~> @content.map ~> @blur it._id
        window.addEventListener "click", (e) ~> if (e.target.className.indexOf "detail") >= 0 then @reset!
        super ...

    getFontSize: (index, post, isH2) ~>
        size = $ "\#article-#index" .width! - 30
        if isH2
            if post.type? 
                size = (size / (post.type.length * 1.5) * 1.8)
                if size > 12 then size = 12
            else size = 0
        else
            size = (size / (post.title.length * 1.5) * 3)
            if size > 20 then size = 20
        "font-size": size
    isSmall: (index) ~> (parseInt((index + 7) / 9) is (index + 7) / 9) or (parseInt((index + 5) / 9) is (index + 5) / 9) or (parseInt((index + 3) / 9) is (index + 3) / 9)
    detailPositioning: (index) ~>
        el = $ "\#article-#index"
        o = el.offset!
        if @data.article is index
            if window.innerWidth <= 400 or window.innerHeight <= 400 then {top: 5, left: 5, right: 5, bottom: 5}
            else if window.innerWidth >= 1000 and !@data.state then {top: 25, left: (window.innerWidth - 950) / 2, height: window.innerHeight - 50, width: 950}
            else {top: 25, left: 25, height: window.innerHeight - 50, width: window.innerWidth - 50}
        else {top: o.top, left: o.left, height: el.height!, width: el.width!}
    isBigEnough: ~> window.innerWidth > 1000
    getRootStyles: ~>
        if @data.article isnt null then "overflow": "visible", "margin-top": "-#{@data.scroll.top}px"
        else ""
    clicked: (post, ev) !~>
        if post.href? and post.href isnt ""
            if post.href.match /^http/ then window.location = post.href
            else @location.path post.href
        else 
            @dialog.show {
                template: DepMan.render "dialog"
                targetEvent: ev
                controller: ["$scope", (scope) ~> scope.post = post; scope.close = @dialog.hide]
            }

    reset: ~>
        @data.article = null
        @data.state = true
        @safeApply!

    scrollFunc: (e) !~>
        @data.scroll.top = $ e.target .scrollTop!
        @safeApply!

    recognizePinch: ~>
        it = $ it.target
        detail = it.parents "aside.detail"
        article = it.parents "article.post"
        if detail.length > 0 then @reset!
        else if article.length > 0 then @clicked parseInt(article.0.id.replace "article-", "")
        Hammer.off "pinchend", @recognizePinch
        setTimeout (~> @safeApply!), 50
        setTimeout (~> @pinchRecognizerHooked = false), 500

    loadPosts: (page) ~> 

        if page? then @data.page = page
        @log "Requesting posts for page #{@data.page}"
        @scope.data.inactive = true
        @scope.safeApply!

        @comms.send "getPosts", @data.page

    loadPostsHook: (err, data) ~>
        if err then @log err
        else  
            @data.numposts = parseInt data.splice 0, 1
            @scope.content = data
            @content = @scope.content
            @scope.makeArray ?= (index) -> replicate (Math.ceil index / 15), 0 .map (v,i) -> i
            @scope.data.inactive = false
            @safeApply!

    getContentById: (id) ~>
        for post in @content
            if post._id is id then return post
        return null


    blur: (_id) ~>
        if not Tester.mobile then let i = _id
            setTimeout ~>
                try 
                    stackBlurImage "image-#{i}", "canvas-#{i}", 10
                catch e
                    @log e
            , 50
        @log "Loading image for #{_id}"

    loadImage: (_id) ~>

            $ "\#image-#{_id}" .addClass \active 
            @safeApply ~>
                $ "\#canvas-#{_id}" .addClass "active"
                $ ".focuspoint.posts\#fp-#{_id}" .focusPoint!

                @safeApply ~>
                    @blur _id
                    @log "Loading image for #{_id}"

    @hook ["$location", "$rootScope", "Comms", "$materialDialog"]
