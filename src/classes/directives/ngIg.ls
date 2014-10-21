angular.module AppInfo.displayname .directive 'ig', ->
    restrict: 'E'
    replace: true
    scope: 
        "model": "="
        "type": "@",
        "elements": "="
        "prop": "="
    transclude: true
    template: DepMan.render "input"
    compile: (ele, attr, transclude) ->
        pre: (scope) ->
            transclude scope, (clone) ->
                scope.description = clone[0].textContent
                scope.uuid = Math.uuid()
    link: ($scope, $elem, $attrs) ->
        $scope.$watch "type", (val) -> $scope.type = val or "text"
