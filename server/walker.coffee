fs = require "fs"

class Walker
    @generateOutput: ->
        return @indent @files, 1

    @indent: (object, number) ->
        bprefix = ""
        bprefix = "#{bprefix}\t" for i in [1..number]
        string = ""; items = 0
        for key, value of object
            if not value.substr? then string += "'#{key}': #{@indent value, number + 1},\n"
            else string += "#{items++}: '#{value}',\n"
        "{#{string} length: #{items}}"

    @generate: (path = "../src", deext = true, gen = true) ->
        @files = {}

        path = (require "path").resolve "#{__dirname}/#{path}"
        @walkDir path, @files, deext

        if gen then @generateOutput @files
        else @files

    @walkDir: (dir, into, deext) ->
        if fs.lstatSync(dir).isDirectory()
            files = fs.readdirSync dir
            for file in files
                if fs.lstatSync("#{dir}/#{file}").isDirectory()
                    into[file] = {}
                    Walker.walkDir "#{dir}/#{file}", into[file], deext
                else
                    if deext and (file.indexOf ".") >= 0 then name = file.substr 0, file.lastIndexOf "."
                    else name = file
                    into[name] = name

module.exports = Walker
