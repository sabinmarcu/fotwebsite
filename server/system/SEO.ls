require! <[fs mime path]>

markdown = require "node-markdown" .Markdown
walker = require "../walker"

debug = (require "debug")("app:SEO")
debug.error = (require "debug")("app:SEO:Error")

info = require path.resolve "#{__dirname}/../../package.json"

keys = require "prelude-ls" .keys

class SEO

    seo-files: keys (walker.generate "../seo", false, false)
    (@server, @watch) ~> 
        @data = require path.resolve "#{__dirname}/../../seo/defaults.json"
        for route, data of @data
            @hook route, data
            if data.alt
                if data.alt.substr? then data.alt = data.alt.replace /\ /, "" .split ","
                for item in data.alt then @hook item, data
            

    hook: (route, data) ~>
        debug "Hooking", route
        @server.get route, (req, res) ~>
            debug "Triggered", route
            content = fs.readFileSync path.resolve("#{__dirname}/../../public/_index_seo.html"), "utf-8"
            content = content.replace /\{\{appname\}\}/, info.name
            title = info.displayname or info.name
            if data.title then title = "#{data.title} – #{title}"
            content = content.replace /\{\{displayname\}\}/g, title

            if not data.keywords? then data.keywords = ""
            if not data.keywords.substr? then data.keywords = data.keywords.join ","
            content = content.replace /\{\{keywords\}\}/, data.keywords

            if not data.description? then data.description
            content = content.replace /\{\{description\}\}/, data.description

            p = path.resolve "#{__dirname}../../../seo#{route}/index.md"
            if fs.existsSync p then dcontent = markdown fs.readFileSync p, "utf-8"
            else dcontent = data.description

            content = content.replace /\{\{dcontent\}\}/, dcontent

            if @watch then extra = "<script>document.write('<script src=\"http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1\"></' + 'script>')</script>"
            else extra = ""
            content = content.replace /\{\{extra\}\}/, extra

            res.send content, {"Content-Type": "text/html"}, 201


#     compile: (template, vars) ~>
#         if not @templates[template]? then return null

#         template = @templates[template]
#         type = template.type
#         template = template.data

#         for k, v of vars then if template.indexOf "{{#{k}}}" >= 0 then template = template.replace "{{#{k}}}", v

#         if type.match /markdown/ then markdown template
#         else if type.match /jade/ then jade.compile template
#         else template


module.exports = SEO