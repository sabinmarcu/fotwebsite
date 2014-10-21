# Including some base necessities and creating the compilation package (anonymously)
require "isf"
stitch   = require "stitchw"
stylus   = require "stylus"
nib      = require "nib"
path     = require 'path'
fs       = require "fs"
base     = path.resolve "@{__dirname}/../src/data/stylesheets"
json     = require path.resolve "@{__dirname}/../package.json"
debug    = (require "debug")("app:Compiler")
pack     = stitch.createPackage
    "dependencies": ["./node_modules/isf/lib/isf.min.js"]
    "paths": ["./src"]
auxpack  = stitch.createPackage
    "dependenceis": []
    "paths": ["./payload"]


# The Compiler Bootstrap
class Compiler

    @log: debug

    @sources: []
    @options: {}

    @throw: (error, callback = null) ->
        if callback then callback error
        else throw error

    # Compile the application to its designated location.
    @compile: (to = "./public/js/#{json.name}.js", callback = null) ->
        try
            pack.compile (err, source) =>
                if err then return @throw ( CompilerErrorReporter.generate 2, CompilerErrorReporter.wrapCustomError err ), callback
                critem = """
                    #{require path.resolve "#{__dirname}/data/copyright"}
                """


                @sources.push """
                    window.AppInfo = #{fs.readFileSync path.resolve "#{__dirname}/../package.json"};
                    window.SrcInfo = #{(require(path.resolve "#{__dirname}/walker")).generate()};
                """
                @sources.push """
                    /** COPYRIGHT
                    #{critem}

                    #{( require path.resolve "#{__dirname}/data/appinfo" )(json, new Date())}
                    **/
                """
                source += src for src in @sources when src.substr?
                source += do src for src in @sources when src.apply?

                @sources.pop()
                @sources.pop()

                added = false
                @compileStyles(null, (error, styles) =>
                    if error then return @throw error, callback
                    if @options.bundle
                        source = """
                                #{source}
                                var bundledStyles = \"#{styles.replace(/\"/g, "'").replace(/\'\\(f[0-9]+)\'/g, "\\\"\\\\$1\\\"").replace(/\n/g, "\\n")}\";
                        """
                    @log "Compiled styles, now joining"
                    @sendSource to, source, callback
                    @log "SENT"
                    , true)
        catch e then return @throw e, callback

    @compileAux: (to = "./public/js/#{json.name}.payload.js", callback = null) ->
        try 
            auxpack.compile (err, source) =>
                if err then return @throw ( CompilerErrorReporter.generate 2, CompilerErrorReporter.wrapCustomError err ), callback
                try
                    (require "fs").writeFileSync to.toString(), source, "utf8"
                    debug "Wrote sources to file"
                catch e then return @throw ( CompilerErrorReporter.generate 3, CompilerErrorReporter.wrapCustomError e ), callback
                if callback? then callback null, source
        catch e then return @throw e, callback

    @addSource: (source) -> @sources.push source
    @sendSource: (to, source, callback) ->
        source = """
                        (function(){
                            var getStylesheets = function() { 
                                var element;
                                if (typeof(bundledStyles) !== 'undefined' && bundledStyles !== null ) { 
                                    element = document.createElement('style');
                                    element.innerHTML = bundledStyles; 
                                } else {
                                    element = document.createElement('link');
                                    element.setAttribute('type', 'text/css');
                                    element.setAttribute('rel', 'stylesheet');
                                    element.setAttribute('href', '/css/#{json.name}.css');
                                }
                                element.id = \"compiled_styles\"; 
                                return element; 
                            };
                            #{if @options.verbose then "window.isDev = true; " else ""}

                            #{source}

                            window.addEventListener('load', function(){ 
                                new ( require("Application") )(getStylesheets); 
                            });
                        })();
        """
        try
            (require "fs").writeFileSync to.toString(), source, "utf8"
            debug "Wrote sources to file"
        catch e then return @throw ( CompilerErrorReporter.generate 3, CompilerErrorReporter.wrapCustomError e ), callback
        if callback? then callback null, source

    @compileStyles: (to = "./public/css/#{json.name}.css", callback = null, override = false) ->
        @log "Starting to compile styles"
        sty = (require "fs").readFileSync "#{base}/index.styl", "utf8"
        paths = [
             "#{base}"
        ]
        @log "Got the data for the styles"
        stylus(sty).set("filename", "#{base}/index.styl").set("paths", paths).use(do nib).import("nib").render (err, css) =>
            @log "Compiled the styles"
            if err then return @throw ( CompilerErrorReporter.generate 4, CompilerErrorReporter.wrapCustomError err ), callback
            else 
                try
                    (require "fs").writeFileSync to.toString(), css, "utf8"
                    debug "Wrote css to file"
                catch e then return @throw ( CompilerErrorReporter.generate 3, CompilerErrorReporter.wrapCustomError e ), callback
                if callback? then callback null, css

    @setAttribute: (attr, value) -> @options[attr] = value

# Defining the Compiler Error Reporter
class CompilerErrorReporter extends IS.Object

    # Setting the error parameters
    @errors:
        "CompilationError": [
            "An error occured when compiling the application"
            "The compiler failed"
            "The styles failed"
            "An error occured when compiling the stylesheets"
        ]
        "WriteError" : [
            "Couldn't write the application to the file"
            "Couldn't write the styles to the file"
        ]


    # Making sure it behaves properly
    @extend IS.ErrorReporter

# Exporting the Compiler
module.exports = Compiler
