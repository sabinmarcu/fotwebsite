class RegisterController extends DepMan.controller "Base"
    (@scope, @root, @location, @comms) ~>
        @fields = <[name email password dob number nationality phone address major school facebook]>
        for field in @fields then @scope[field] = ""
        @comms.hook "register", @registerHook
        @comms.hook "register:progress", ~> @log it
        @comms.hook "transaction", @setupTransaction
        @scope.selected = null
        @scope.tabSelected = 1
        @debug = active: false, message: "", type: ""
        @countries = DepMan.json "countries"
        @foundoutabout = DepMan.json "foundoutabout"
        handler = ~> 

            if @location.path!match /^\/membership\/register\/?$/ then @scope.class = "active"
            else @scope.class = "inactive"

            if @video? then @video.pause!
            else if @location.path!.match /\/membership\/register/ 
                if @video? then @video.play!
                else
                    if Tester.getUserMedia
                        navigator.getUserMedia {video: true}, ((@mediaStream) ~>
                            @video = $ "video\#registerPreview" .0
                            @video.src = window.URL.createObjectURL @mediaStream
                            @video.play!
                            @safeApply!
                        ), ~> @comms.message "error", "We need access to your camera to register!"
        @root.$on "user:loggedout", ~> @safeApply!
        @root.$on "$locationChangeSuccess", handler
        handler!
        window.addEventListener "click", ~>
            if $ it.target .parents ".login" .length is 0
                @scope.selected = null
                @safeApply!
        super ...
    capture: ~>
        if @video?
            canvas = document.createElement "canvas"

            canvas.width  = @video.videoWidth
            canvas.height = @video.videoHeight

            context = canvas.getContext "2d"
            context.drawImage @video, 0, 0

            return canvas.toDataURL "image/png"

    getVContainerStyle: ~>
        if @video then height: $ @video .height!
        else height: 0

    submit: ~>
        if (@scope.tabSelected is 0 and not @video?) or (@scope.tabSelected is 1 and not @image) then return

        for field in @fields then if @scope[field] is "" then return @comms.message "error", "Fields cannot be empty!"
        if @scope.password isnt @scope.repassword then return @comms.message "error", "Passwords must be identical!" 

        if not @scope.email.match /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/ then return @comms.message "error", "You need a valid email address"
        if @scope.password.match /\ +/ then return @comms.message "error", "The password cannot have spaces!"

        object = {}
        for field in @fields then object[field] = @scope[field]

        if @scope.tabSelected is 0 then object[\image] = @capture!

        @comms.send "register", object

    registerUpdateHook: ~>
        @log it

    registerHook: (error, user) ~>
        if error 
            if error.message is "Validation failed" then @comms.message "error", "There already exists a user with that email address!"
            else @comms.message "error", "There has been a system error!"
        else 
            @comms.message "success", "Success!"
            @comms.send "getTransaction", user._id

    setupTransaction: (trans) ~>

        @log trans.Data

        form = document.createElement "form"
        form.setAttribute "method", "post"
        form.setAttribute "target", "_blank"
        form.setAttribute "action", trans.Url

        i = document.createElement "input"
        i.setAttribute "type", "hidden"
        i.setAttribute "name", "Seal"
        i.setAttribute "value", trans.Seal
        form.appendChild i        

        i = document.createElement "input"
        i.setAttribute "type", "hidden"
        i.setAttribute "name", "InterfaceVersion"
        i.setAttribute "value", trans.InterfaceVersion
        form.appendChild i

        i = document.createElement "input"
        i.setAttribute "type", "hidden"
        i.setAttribute "name", "Data"
        i.setAttribute "value", trans.Data
        form.appendChild i

        form.submit!


    @hook ["$rootScope", "$location", "Comms"]
