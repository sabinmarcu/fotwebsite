{replicate, map} = prelude

class EventsController extends DepMan.controller "Base"
    (@scope, @location, @root, @comms) ~>

        @data = active: 0, vertical: true, content: (replicate 15, 0).map (item, index) -> index + 2
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

        unless @data.active

            p = $ "\#article-#{id}"
            i = p.find " > .wrapper"

            i.addClass "animate"

            let o = p.offset!, w = p.width!, h = p.height! then i.css top: o.top - 45, left: o.left, bottom: window.innerHeight - o.top - h, right: window.innerWidth - o.left - w

            setTimeout ~> 
                i.attr "style", "background: #{i.css 'background'}; transition: all 1s cubic-bezier(0.215, 0.61, 0.355, 1);" .removeClass "animate"
                @data.active = id
                @safeApply!
            , 50

        else

            p = $ "\#article-#{id}"
            i = p.find " > .wrapper"

            i.addClass "animate"

            let o = p.offset!, w = p.width!, h = p.height! then i.css top: o.top - 45, left: o.left, bottom: window.innerHeight - o.top - h, right: window.innerWidth - o.left - w

            i.css "transition", "all 1s cubic-bezier(0.215, 0.61, 0.355, 1)"

            setTimeout ~>
                @data.active = 0
                @safeApply!
                setTimeout ~>
                    i.attr "style", "background: #{i.css 'background'};" .removeClass "animate"
                , 750
            , 50

    getRandomColor: ~> window.randColor?!


    @hook ["$location", "$rootScope", "Comms"]
