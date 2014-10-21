class JSONModel extends require "classes/BaseAngularHook"

    (@root) ~>
        @data = { nodes: [] }

        DBStorage.get "example", (data) ~>

            if data? then @data = data
            else @data = require "data/jsons/example"

            for node in @data.nodes
                if not node.position? then
                    node.position =
                        x: parseInt ($ 'svg' .width! / 2)
                        y: parseInt ($ 'svg' .height! / 2)

            @root.$broadcast "data:refresh"

            setInterval (~> DBStorage.set "example", @data), 5000

        @root.$on "data:refresh", @refresh
        @root.$on "data:refresh"

    refresh: (e, isSelfSent = false)~>
        @root.$emit "message", ""
        try
            unless isSelfSent
                @json = JSON.stringify @data, ((k, v)-> ; if (k.indexOf "$$") < 0 then return v; else return undefined), '\t'
        catch e
            @root.$emit "message", "ERROR: #{e}"

    change: ~>
        @root.$emit "message", ""
        try
            @data = JSON.parse @json
            @root.$broadcast "data:refresh", true
        catch e
            @root.$emit "message", "ERROR: #{e}"

    @hook ["$rootScope"]
