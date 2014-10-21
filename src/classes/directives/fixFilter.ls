angular.module AppInfo.displayname .filter "fix", [ ->
    (text) -> text.replace /\ /g, ""
]
