angular.module AppInfo.displayname .directive "ngEnter", [ "$parse", ($parse) ->
    restrict: 'A'
    compile: (el, attr) ->
        fn = $parse attr["ngEnter"]
        (scope, el, attr) ->
            el.on "keyup", (ev) ->
                if ev.which === 13
                    scope.$apply ->
                        fn scope, "$event": ev
]