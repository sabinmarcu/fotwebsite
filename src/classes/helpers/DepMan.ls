class DepMan extends IS.Object

  (@basePrefix = "", @deps = []) -> 
  _require   : (module, prefix = "") ~>
    unless module.substr? then module = module * "/"
    str = "#{prefix}#{module}"
    if @deps[str] then return @deps[str]
    else
      @deps[str] = require "#{@basePrefix}#{str}"
      return @deps["#{prefix}#{module}"]

  data       : (module, suffix = "") ~> @_require module, "data/#{suffix}"
  classes    : (module, suffix = "") ~> @_require module, "classes/#{suffix}"
  render     : (module, ...args) ~>
    module = @data module, "views/"
    if module.main then @fixrender module.main, @, [null, null, null] ++ [args]
    else @fixrender module, @, args
  fixrender  : (module, who, args) ~> 
    if module.apply? then module.apply @, args
    else module
  doc        : (module) ~> @data module, "docs/"
  stylesheet : (module) ~> @data module, "stylesheets/"
  image      : (module) ~> @data module, "images/"
  font       : (module) ~> @data module, "fonts/"
  language   : (module) ~> @data module, "languages/"
  json   : (module) ~> @data module, "jsons/"
  helper     : (module) ~> @classes module, "helpers/"
  controller : (module) ~> @classes module, "controllers/"
  directive : (module) ~> @classes module, "directives/"
  model      : (module) ~> @classes module, "models/"
  lib        : (module) ~> @classes module, "libs/"
  extScript  : (src, callback = null, del = true) ~>
    if @deps[src] then return @deps[src]
    _name = src.substr (src.lastIndexOf "/") + 1
    _s = @deps[src] = document.createElement "script"
    _s.src = src
    _s.id = _name
    _s.onload = ~>
      @log "#{_name} has been loaded! (#{src})"
      if del then _s.parentElement.removeChild _s
      if callback? then callback _s
    document.head.appendChild _s
    _s
  extLink  : (src, stylesheet = true) ~>
    if @deps[src] then return @deps[src]
    _name = src.substr (src.lastIndexOf "/") + 1
    _s = @deps[src] = document.createElement "link"
    _s.href = src
    _s.id = _name
    if stylesheet then _s.rel = "stylesheet"
    document.head.appendChild _s
    _s

  googleFont : (font, sizes, subsets = null) ~>
    if @deps[font] then return @deps[font]
    names = font.split " "
    _s = @deps["#{font}"] = document.createElement "link"
    string =  "#{window.location.protocol}//fonts.googleapis.com/css?family=#{names.join "+"}:#{sizes.join ","}"
    if subsets? then string += "&subset=#{subsets.join ","}"
    _s.setAttribute "href", string
    _s.setAttribute "rel", "stylesheet"
    _s.setAttribute "type", "text/css"
    document.head.appendChild _s
    _s

module.exports = DepMan
