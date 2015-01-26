class HomeController extends DepMan.controller "Base"
    (@scope, @location, @root, @comms, @dialog) ~>

        @scope.data = @data = active: 0, width: window.innerWidth, asides:
            * title: "About Fish on Toast", id: "about"
            * title: "About Memberships", id: "membership"

        @items = [null, "about", "membership"]

        for item in @data.asides
            let el = $ "\##{item.id}"
                el.css "transition", "none"
                el.css "top", ""
                el.css "bottom", ""
                el.css "left", ""
                item.brief = DepMan.render "pages/#{item.id}.brief"
                item.content = DepMan.render "pages/#{item.id}.content"

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

        setTimeout ~>
            @log "Hooking Hammer"
            h = new Hammer ($ "\#Home" .0)
            h.on "swiperight", ~> @switchContent -1
            h.on "swipeleft", ~> @switchContent 1
        , 1000

        window.addEventListener "resize", ~> @data.width = window.innerWidth; @scope.safeApply!

        super ...

    loadImage: (index) !~>
        @log "FocusPoint #{index}"
        $ "\#fp-#{index}" .focusPoint!

    goto: (id) ~>
        @data.active = 0
        @data.state = 0
        if id? then @toggle id
        else @location.path "/"

    toggle: (id) ~>
        if @data.active isnt 0 then 
            @data.state = 0
            @data.active = 0
            @safeApply ~>
                @location.path "/"
        else 
            @data.state = 1
            @data.active = id
            @location.path "/#{id}"

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
