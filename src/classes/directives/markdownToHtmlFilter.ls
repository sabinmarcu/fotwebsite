angular.module AppInfo.displayname .filter "md2html", [ ->
    (text) -> 
        try
            markdown.toHTML text
        catch error
            text     
]
