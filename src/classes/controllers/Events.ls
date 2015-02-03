{replicate, map} = prelude

class EventsController extends DepMan.controller "Base"
    (@scope, @location, @root, @comms) ~>

        @data = active: 0, vertical: true, content: (DepMan.json "events"), scroll: top: 0, left: 0
        @colors = (replicate 20, 0).map ~> @getRandomColor!
        @isMobile = Tester.mobile
        @comms.hook "post:event:all", @loadPostsHook
        @comms.hook "post:event:image", @loadPostImage
        @comms.hook "post:new", @loadPosts

        DBStorage.get "events.layout", (data) ~>
            if data?
                @data.vertical = data
                @safeApply!
        , true

        urlHandler = ~>
            m = @location.path!.match /events\/?([0-9]+)?/
            if m? then @log "thing"

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!

        super ...

    toggleLayout: ~>
        @data.vertical = !@data.vertical
        DBStorage.set "events.layout", @data.vertical + ""

    toggleArticle: (id) !~>

        if @data.active 
            @data.active = 0
            let j = ($ "\#Events .grid.row2")
                j.animate {scrollTop: @data.scrollSave.top}, '1000', 'swing'
                j.animate {scrollLeft: @data.scrollSave.left}, '1000', 'swing'
                delete @data.scrollSave
        else 
            @data.scrollSave = angular.copy @data.scroll
            @data.active = id
        @safeApply ~>
            setTimeout (~> $ ".focuspoint\#fp-#{id}" .focusPoint!), 500

    scroll: (e) !~>
        @data.scroll.top = e.originalEvent.target.scrollTop
        @data.scroll.left = e.originalEvent.target.scrollLeft

    getRandomColor: ~> window.randColor?!
    loadedImage: !~>
        @log "Focuspointing image .focuspoint\#fp-#{it}"
        $ ".focuspoint\#fp-#{it}" .focusPoint!


    @hook ["$location", "$rootScope", "Comms"]
