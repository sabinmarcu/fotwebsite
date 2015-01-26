require! <[jade fs mime coffee-script/register path]>

markdown = require "node-markdown" .Markdown
walker = require "../walker"

debug = (require "debug")("app:EmailTemplate")
debug.error = (require "debug")("app:EmailTemplate:Error")

keys = require "prelude-ls" .keys

class EmailTemplate

    templates: keys (walker.generate "../emails", false, false)
    ~> 
        @templates = {}
        for tmp in @constructor::templates
            @templates[tmp.substr 0, tmp.lastIndexOf "."] = 
                data: fs.readFileSync (path.resolve "#{__dirname}/../../emails/#{tmp}"), 'utf-8'
                type: mime.lookup tmp

    compile: (template, vars) ~>
        if not @templates[template]? then return null

        template = @templates[template]
        type = template.type
        template = template.data

        for k, v of vars then if template.indexOf "{{#{k}}}" >= 0 then template = template.replace "{{#{k}}}", v

        if type.match /markdown/ then markdown template
        else if type.match /jade/ then jade.compile template
        else template


module.exports = new EmailTemplate