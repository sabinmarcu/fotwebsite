angular.module AppInfo.displayname .directive "ngScroll", ["$parse", ($parse) ->
    restrict: 'A'
    compile: (el, attr) ->
        fn = $parse attr["ngScroll"]
        (scope, el, attr) ->
            el.on "scroll", (ev) ->
                scope.$apply ->
                    fn scope, "$event": ev
]
angular.module AppInfo.displayname .directive "ngWheel", ["$parse", ($parse) ->
    restrict: 'A'
    compile: (el, attr) ->
        fn = $parse attr["ngWheel"]
        (scope, el, attr) ->
            el.on "wheel", (ev) ->
                scope.$apply ->
                    fn scope, "$event": ev
]