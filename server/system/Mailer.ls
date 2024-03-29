nm = require "nodemailer"
dt = require "nodemailer-direct-transport"

debug = (require \debug)(\app:Mailer)
debug.error = (require \debug)(\app:Mailer:Error)
debug.error.log = console.error.bind console

class Mailer 
    ~> @transport = nm.createTransport dt name: "lytic.co.uk"
    send: (from, to, subject, text, html) ~> 

        debug "Sending email to <#{to}>, from <#{from}>, with subject '#{subject}'"
        if text? 
            debug "Sending with text"
            @transport.sendMail from: from, to: to, subject: subject, text: text
        else 
            debug "Sending with html"
            @transport.sendMail from: from, to: to, subject: subject, html: html


module.exports = new Mailer