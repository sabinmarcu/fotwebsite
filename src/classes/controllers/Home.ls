class HomeController extends DepMan.controller "Base"
    (@scope, @location, @root, @comms, @dialog) ~>

        @data = active: 0, state: 0, asides:
            * title: "About Fish on Toast", id: "about"
            * title: "About Memberships", id: "membership"

        @items = [null, "about", "membership"]

        for item in @data.asides
            let el = $ "\##{item.id}"
                el.css "transition", "none"
                el.css "top", ""
                el.css "bottom", ""
                el.css "left", ""

        urlHandler = ~>
            @log "Checking #{@location.path!}"
            if (@location.path!.replace /^\//, "") is "" 
                @data.active = 0
                @data.state = 0
            else 
                m = @location.path!.match /^\/(about|membership)\/?$/
                if m? 
                    if @data.active isnt m.1 then @goto m.1
            @safeApply?!

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!

        @log "Hooking Hammer"
        h = new Hammer (document.body)
        h.on "swiperight", ~> @switchContent -1
        h.on "swipeleft", ~> @switchContent 1

        super ...

    loadImage: (index) !~>
        @log "FocusPoint #{index}"
        $ "\#fp-#{index}" .focusPoint!

    goto: (id) ~>
        @data.active = 0
        @data.state = 0
        if id? then @toggle id

    toggle: (id) ~>
        if @data.active isnt 0 then 
            @log "Going into state 2 (active is #{@data.active})"
            $ "\##{id}" .removeClass "active"
            @data.state = 2
            @safeApply ~>
                setTimeout ~>
                    @log "Going into state 0"
                    @data.state = 0
                    @data.active = 0
                    @safeApply ~>
                        @location.path "/"
                , 500
        else 
            @log "Going into state 1"
            @data.state = 1
            @data.active = id

    getHeight: ~>
        if window.innerWidth < 700
            height: window.innerHeight - 45

    wheel: (e) ~>
        @log e.target, ($ e.target .hasClass "content") or (($ e.target .parents ".content" .length) > 0)
        unless e.target.className.match /(content|brief)/i
            if @throttle? then @throttle += 1
            else @throttle = 1

            if @timeout? then clearTimeout @timeout
            else 
                @log "throttle #{@throttle}"
                # @switchContent e.originalEvent.deltaY / (Math.abs e.originalEvent.deltaY)

            @timeout = setTimeout ~>
                @log "End #{throttle}"
                delete @timeout
                delete @throttle
            , 100

    switchContent: (dir) ~>
        @log "Checking Switch (#{dir}, #{typeof dir})"
        if @data.active is 0
            @log "I'm at home, so home + #{dir}"
            if dir is 1 then @goto "about"
            else @goto "membership"
        else 
            if @data.active is "about"
                @log "I'm at about, so about + #{dir}"
                if dir is 1 then @goto "membership"
                else @goto null
            else
                @log "I'm at membership, so membership + #{dir}"
                if dir is 1 then @goto null
                else @goto "about"

        @safeApply!

    @hook ["$location", "$rootScope", "Comms", "$materialDialog"]
