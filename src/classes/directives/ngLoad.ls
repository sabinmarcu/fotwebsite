angular.module AppInfo.displayname .directive "ngLoad", ["$parse", ($parse) ->
    restrict: 'A'
    compile: (el, attr) ->
        fn = $parse attr["ngLoad"]
        (scope, el, attr) ->
            el.on "load", (ev) ->
                scope.$apply ->
                    fn scope, "$event": ev
]