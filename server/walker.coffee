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

    @generate: ->
        @files = {}
        path = (require "path").resolve "#{__dirname}/../src"
        @walkDir path, @files
        @generateOutput @files

    @walkDir: (dir, into) ->
        if fs.lstatSync(dir).isDirectory()
            files = fs.readdirSync dir
            for file in files
                if fs.lstatSync("#{dir}/#{file}").isDirectory()
                    into[file] = {}
                    Walker.walkDir "#{dir}/#{file}", into[file]
                else
                    if (file.indexOf ".") >= 0 then name = file.substr 0, file.lastIndexOf "."
                    else name = file
                    into[name] = name

module.exports = Walker
