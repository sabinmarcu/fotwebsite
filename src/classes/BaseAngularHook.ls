class BaseAngularHook extends IS.Object
    ~> @log = new Debug("app:#{@constructor.name}")
    @hook = (args = []) ->
        @name = @toString!match /^function\s*([^\s(]+)/ .1
        @log "Hooking #{@name.replace /controller/i, ""} to AngularJS"
        if (@name.indexOf "Model") >= 0 then angular.module AppInfo.displayname .service @name, args ++ [@]
        else angular.module AppInfo.displayname .controller @name.replace(/controller/i, ""), ["$scope"] ++ args ++ [@]

module.exports = BaseAngularHook
