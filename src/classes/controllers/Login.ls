class LoginController extends DepMan.controller "Base"
    (@scope, @root, @location, @comms, @toast) ~>
        @comms.hook "login", @loginHook
        @scope.email = @scope.password = ""
        @scope.selected = null
        @debug = active: false, message: "", type: ""
        @root.$on "user:loggedout", ~> @safeApply!
        @root.$on "$locationChangeSuccess", ~>
            if @location.path!match /^\/membership\/login\/?$/ then @scope.class = "active"
            else @scope.class = "inactive"
        window.addEventListener "click", ~>
            if $ it.target .parents ".login" .length is 0
                @scope.selected = null
                @safeApply!
        super ...

    loginHook: (error, user) ~> 
        if error 
            DBStorage.remove "user"
            if error.substr? then @comms.message "error", error
            else @comms.message "error", "There has been a server error!"
        else if not user then @comms.message "error", "Your credentials have been incorrect!"
        else
            @comms.message "success", "You have been logged in!"
            @comms.user = user
            if @scope.remember 
                @log "Saving user for auto-login"
                DBStorage.set "user", user
            @root.$broadcast "$locationChangeSuccess"
            @comms.message "success", "You have been logged in!"
            if @comms.meta.prevURL? then 
                @location.path @comms.meta.prevURL
            else @location.path "/membership"
        @safeApply!

    submit: ~>
        if @scope.email is "" or @scope.password is "" then @comms.message "error", "Fields cannot be empty!"
        else if not @scope.email.match /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/ then @comms.message "error", "You need a valid email address"
        else if @scope.password.match /\ +/ then @comms.message "error", "The password cannot have spaces!"
        else @comms.send "login", email: @scope.email, password: @scope.password
    @hook ["$rootScope", "$location", "Comms", "$materialToast"]
