debug = Debug("app:ControllerInitializer")

angular.module AppInfo.displayname .directive "controllerFromString", ['$controller', (cont) ->
    {
        restrict: \A
        scope: yes
        link: (scope, element, attrs) ->
            locals = $scope: scope, $element: element, $attrs: attrs
            routes = DepMan.json "routes"
            
            if routes.isStaticPage[routes.order.indexOf scope.$eval attrs.controllerFromString] then name = "StaticPage"
            else
                name = ( scope.$eval attrs.controllerFromString ).replace /\ /g, ""
                name = name[0].toUpperCase! + name.slice 1

            if routes.implemented[routes.order.indexOf scope.$eval attrs.controllerFromString]
                debug "Controller Initializing", name
                element.data '$Controller', cont name, locals
            else debug "Controller will not be initialized", name
    }    
]
angular.module AppInfo.displayname .directive "adminControllerFromString", ['$controller', (cont) ->
    {
        restrict: \A
        scope: yes
        link: (scope, element, attrs) ->
            locals = $scope: scope, $element: element, $attrs: attrs
            name = ( scope.$eval attrs.adminControllerFromString ).replace /\ /g, ""
            name = (name[0].toUpperCase! + name.slice 1) + "Admin"
            element.data '$Controller', cont name, locals
    }    
]
