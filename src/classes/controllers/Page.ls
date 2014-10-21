class PageController extends DepMan.controller "Base"

    (@scope, @location, @root, @comms) ~>
        @routes = DepMan.json "routes"
        @adminroutes = DepMan.json "adminroutes"
        @data = isContentActive: true
        
        @scope.$on "globalmenu:activated", ~> @data.isContentActive = false; @safeApply!
        @scope.$on "globalmenu:deactivated", ~> @data.isContentActive = true; @safeApply!

        @scope.$on "user:loggedout", ~> @location.path "/"; @safeApply!

        hammertime = new Hammer document.body

        hammertime.on "swiperight", ~> @scope.$emit "globalmenu:activated"
        hammertime.on "swipeleft", ~> @scope.$emit "globalmenu:deactivated"

        urlHandler = ~> 
            if not @comms.user? and @location.path!.match  /\/membership.*/ then @comms.checkLogin!
            if not @comms.user? and @location.path!.match /\/membership.*/ and not @location.path!.match /\/membership\/(login|register)/
                @comms.meta.prevURL = @location.path!
                return @location.path "/membership/login"
            if @location.path!match /\/membership\/?$/ or ((@location.path!match /\/membership\/login/) and @comms.user?) then @activateMenu!

        @root.$on "$locationChangeSuccess", urlHandler
        urlHandler!
        
        @scope.isMobile = Tester.mobile
        super ...

    isActive: (title) ~> 
        if @routes[title]? 
            if @routes[title].length is 2 and @routes[title].0 is @location.path! then true
            else if @routes[title].substr? then @location.path!match @routes[title]
            else
                for route in @routes[title] then unless route is "/"
                    if @location.path!match route then return true
                return false

    adminIsActive: (title) ~> 
        if title is "me" and @location.path!match /\/membership\/me\/?$/ then true
        else @location.path!match (new RegExp "#{@adminroutes[title]}/?.*") 

    isStatic: (title) ~> if @routes.isStaticPage[@routes.order.indexOf title] then true else false
    @hook ["$location", '$rootScope', 'Comms']
