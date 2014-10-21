angular.module AppInfo.displayname .directive "readFile", [ "$parse", ($parse) ->
    restrict: 'A'
    scope:
        readFile: "="
    link: (scope, el, attrs) ->
        el.bind "change", (ev) ->
            fr = new FileReader
            fr.onload = (lev) -> 
                scope.$apply -> 
                    scope.readFile = lev.target.result
            fr.readAsDataURL ev.target.files.0
]