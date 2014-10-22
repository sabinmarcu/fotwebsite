class HomeController extends DepMan.controller "Base"
    (@scope, @location, @root, @comms, @dialog) ~>

        @data = active: 0, state: 0, asides:
            * title: "About Fish on Toast", id: "about"
            * title: "About Memberships", id: "membership"

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
                    if @data.active isnt m.1 
                        @data.active = 0
                        @data.state = 0
                        @toggle m.1
            @safeApply?!

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!

        super ...

    loadImage: (index) !~>
        @log "FocusPoint #{index}"
        $ "\#fp-#{index}" .focusPoint!

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

    @hook ["$location", "$rootScope", "Comms", "$materialDialog"]
