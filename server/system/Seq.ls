require! <[mongoose node-uuid mongoose-unique-validator isf request]>

{keys, replicate, lists-to-obj, map} = require "prelude-ls"

class Seq extends require "./BaseModel"

    @initLogs!

    @props = 
        id: String
        seq: Number


    @methods = 
        next: (id, callback) ->
            Seq.model.find "id": id, (err, docs) ~>
                if err or docs.length isnt 1
                    s = new Seq.model
                    s.id = id
                    s.seq = 1
                    s.save!
                    callback null, s.seq
                Seq.model.findOneAndUpdate {"id": id}, {"$inc": {"seq": 1}}, ~>
                    Seq.model.find "id": id, (err, docs) ~>
                        if err or docs.length isnt 1 then callback err or new Error "Database Error"
                        else callback null, docs.0.seq

    @initModel!
        
    if mongoose.connection.readyState is 0 then mongoose.connect "mongodb://localhost/test"

    @setPropExport module.exports