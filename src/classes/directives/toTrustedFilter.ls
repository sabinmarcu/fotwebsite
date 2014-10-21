angular.module AppInfo.displayname .filter "toTrusted", ["$sce", (sce) ->
    (text) -> sce.trustAsHtml text
]
