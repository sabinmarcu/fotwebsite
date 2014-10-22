angular.module AppInfo.displayname .directive "ngLoad", ["$parse", ($parse) ->
    restrict: 'A'
    compile: (el, attr) ->
        fn = $parse attr["ngLoad"]
        (scope, el, attr) ->
            log = new Debug("app:ngLoad")
            el.on "load", (ev) ->
                log "Event Triggered"
                scope.$apply ->
                    fn scope, "$event": ev
]