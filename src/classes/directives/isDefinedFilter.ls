angular.module AppInfo.displayname .filter "isDefined", [ ->
    (text, scope) -> angular.isDefined text
]
angular.module AppInfo.displayname .filter "isUndefined", [ ->
    (text, scope) -> !angular.isDefined text
]
