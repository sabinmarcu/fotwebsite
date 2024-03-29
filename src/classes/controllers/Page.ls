class PageController extends DepMan.controller "Base"

    (@scope, @location, @root, @comms) ~>
        @routes = DepMan.json "routes"
        @adminroutes = DepMan.json "adminroutes"
        @data = isContentActive: false
        
        @scope.$on "globalmenu:activated", ~> @data.isContentActive = false; @safeApply!
        @scope.$on "globalmenu:deactivated", ~> @data.isContentActive = true; @safeApply!

        @scope.$on "user:loggedout", ~> @location.path "/"; @safeApply!

        hammertime = new Hammer document.body

        hammertime.on "swipeleft", ~> @scope.$emit "globalmenu:activated"
        hammertime.on "swiperight", ~> @scope.$emit "globalmenu:deactivated"

        urlHandler = ~> 
            # if not @comms.user? and @location.path!.match  /\/membership.*/ then @comms.checkLogin!
            # if not @comms.user? and @location.path!.match /\/membership.*/ and not @location.path!.match /\/membership\/(login|register)/
            #     @comms.meta.prevURL = @location.path!
            #     return @location.path "/membership/login"
            # if @location.path!match /\/membership\/?$/ or ((@location.path!match /\/membership\/login/) and @comms.user?) then @activateMenu!
            $ "a" .toArray!filter (-> !it.href.match new RegExp window.location.host + "") .map -> it.target = "_blank"
            @data.isContentActive = false; @safeApply?!

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!
        
        @scope.isMobile = Tester.mobile

        window.addEventListener "click", !~> 
            if @data.isContentActive
                j = $ it.target
                c1 = it.target.id is "sitemenu" or j.parents "\#sitemenu" .length > 0
                c2 = it.target.tagName.toLowerCase! is "material-button" or j.parents "material-button" .length > 0
                c3 = it.target.tagName.toLowerCase! is "h1" or j.parents "h1" .length > 0
                @log "Clicked", it.target, c1, c2, c3
                if c1 and (c2 or c3) then @log "Safe"
                else @data.isContentActive = false; @safeApply!
        super ...

    isActive: (title) ~> 
        if @routes[title]? 
            if @routes[title].length is 3 and @routes[title].0 is @location.path! then true
            else if @routes[title].substr? then @location.path!match @routes[title]
            else
                for route in @routes[title] then unless route is "/"
                    if @location.path!match route then return true
                return false

    adminIsActive: (title) ~> 
        if title is "me" and @location.path!match /\/membership\/me\/?$/ then true
        else @location.path!match (new RegExp "#{@adminroutes[title]}/?.*") 

    isStatic: (title) ~> if @routes.isStaticPage[@routes.order.indexOf title] then true else false

    toggleMenu: ~> @data.isContentActive = !@data.isContentActive; @safeApply!
    hover: (type, ev) ~>
        if type is \in then 
            unless /safari/i.test(navigator.userAgent) && !/chrome/i.test(navigator.userAgent) && !/firefox/i.test(navigator.userAgent)
                @data.isContentActive = true
        if type is \out then 
            unless /safari/i.test(navigator.userAgent) && !/chrome/i.test(navigator.userAgent) && !/firefox/i.test(navigator.userAgent)
                @data.isContentActive = false
        if type is \toggle then @data.isContentActive = not @data.isContentActive

    isReady: !~> $ ".seoflier" .addClass "inactive"
    @hook ["$location", '$rootScope', 'Comms']
