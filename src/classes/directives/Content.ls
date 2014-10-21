log = new Debug("app:LoadContentFor")

angular.module AppInfo.displayname .directive "loadContentFor", [ "$compile", ($compile) ->
    {
        restrict: \A
        scope: yes
        link: (scope, element, attrs) ->
            routes = DepMan.json "routes"
            
            name = ( scope.$eval attrs.loadContentFor ).replace /\ /g, ""
            name = name[0].toUpperCase! + name.slice 1

            if routes.isStaticPage[routes.order.indexOf scope.$eval attrs.loadContentFor] then doc = "pages/#name"
            else doc = "panes/#name"
            ( $compile DepMan.render doc) scope, (elem, scope) -> element.html elem
    }    
]
angular.module AppInfo.displayname .directive "adminLoadContentFor", [ "$compile", ($compile) ->
    {
        restrict: \A
        scope: yes
        link: (scope, element, attrs) ->
            name = ( scope.$eval attrs.adminLoadContentFor ).replace /\ /g, ""
            name = name[0].toUpperCase! + name.slice 1
            ( $compile DepMan.render "panes/admin/#name" ) scope, (elem, scope) -> element.html elem
    }    
]
angular.module AppInfo.displayname .directive "loadPartial", [ "$compile", ($compile) ->
    {
        restrict: \A
        scope: yes
        link: (scope, element, attrs) ->
            ( $compile scope.$eval attrs.loadPartial ) scope, (elem, scope) -> element.html elem
    }    
]
