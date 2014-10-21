angular.forEach <[src href]>, (name) ->
    ngName = "ng#{name.0.toUpperCase!}#{name.slice 1}"
    angular.module AppInfo.displayname .directive ngName, ->
        (scope, element, attrs) ->
            attrs.$observe ngName, (val) ->
                attrs.$set name, val
