require! <[uuid crypto mongoose isf mongoose-unique-validator jade fs]>

debug = (require \debug)(\app:Transaction)
debug.error = (require \debug)(\app:Transaction:Error)
debug.error.log = console.error.bind console

template = jade.compile (fs.readFileSync "#{__dirname}/data/paymentform.jade", "utf-8")
User = require "./User" .User

class Transaction extends require "./BaseModel"

    @initLogs!

    @config = 
        production:
            merchantId: '220223192630001'
            customerLanguage: 'en'
            keyVersion: '1'
            currencyCode: '978'
            amount: '1000'
            normalReturnUrl: 'api/payment/return'
            automaticResponseUrl: 'api/payment/response'

        test: 
            merchantId: '002020000000001'

        interfaceVersion: 'HP_1.0'

        bankUrls:
            production: 'https://payment-webinit.omnikassa.rabobank.nl/paymentServlet' # Change to normal payments
            test: 'https://payment-webinit.simu.omnikassa.rabobank.nl/paymentServlet' # Change to normal payments

        urls: 
            test: "http://localhost:8000/"
            production: "http://isr.lytic.co.uk/"

        keys: 
            test: '002020000000001_KEY1'
            production: 'GFW3XC9-o-mxkwvtpcJBQIDoXDlpII_Kyp44axNa9vY'

    @props = 
        id: {type: String, unique: true}
        status: String
        
    @methods = 
        create: ->
            promise = new isf.Promise
            promise.then (user, amount = false) ~>
                if user? 
                    promise.progress "Trying to find an existing transaction"
                    Transaction.model.find id: user, (err, trans) ~>
                        promise.progress "Query successful"
                        if err then promise.reject err
                        else if trans.length is 1 
                            promise.progress "Found a transaction, sending"
                            promise.resolve trans.0
                        else 
                            promise.progress "Creating transaction"
                            import id: user, status: 'initiated'
                            @log @
                            @save!
                            promise.resolve @
                else promise.reject new Error "No data supplied"
            promise

        export: ->

            @log "Exporting"
            data = {} <<< Transaction.config.production

            if process.comp_args.compile then data <<< Transaction.config.test

            @log "Adding details (orderid: #{@id}) (merchantId: #{data.merchantId})"
            data.orderId = @id
            data.transactionReference = crypto.create-hash "md5" .update "#{@id}#{(new Date()).getTime!}" .digest "hex"

            @log "New orderId is #{data.orderId}"

            @log "Sending export data"

            d = @mashData data
            {Data: d, InterfaceVersion: Transaction.config.interfaceVersion, Seal: (@getHash d), Url: (if process.comp_args.compile then Transaction.config.bankUrls.test else Transaction.config.bankUrls.production)}

        mashData: (data) ->
            d = {} <<< data

            root = if process.comp_args.compile then Transaction.config.urls.test else Transaction.config.urls.production
            d.normalReturnUrl = "#{root}#{d.normalReturnUrl}"
            d.automaticResponseUrl = "#{root}#{d.automaticResponseUrl}"

            s = ["#{k}=#{v}" for k, v of d].join "|"

        getHash: (data) -> 
            key = if process.comp_args.compile then Transaction.config.keys.test else Transaction.config.keys.production
            @log "Generating hash for #{key} : #{data}"
            crypto.create-hash "sha256" .update "#{data}#{key}" .digest "hex"

    @staticpostapi = 
        "/api/payment/return": (req, res) ~> 
            code = (req.body.Data.split "|" .map (-> it.split "=") .filter (-> if it[0] is "responseCode" then it[1] else undefined ) )[0][1]
            user = (req.body.Data.split "|" .map (-> it.split "=") .filter (-> if it[0] is "orderId" then it[1] else undefined ) )[0][1]
            if code is "00" 
                @model.find "id": user, (err, trans) ~>
                    if err then @error err
                    else 
                        trans.0.status = "completed"
                        @model.update "id": trans.0.id, trans.0, (err) ~>
                            if err then @error err
                User.find "_id": user, (err, u) ~>
                    if err then 
                        @error err
                        res.status "501" .end "There was a problem finding the user to associate the payment. Please contact and administrator, and provide him with the following number: #{user}"
                    else if u.length isnt 1 
                        @error "Wrong number of users"
                        res.status "501" .end "There was a problem finding the user to associate the payment. Please contact and administrator, and provide him with the following number: #{user}"
                    else
                        u.activated = "true"
                        User.update "_id": user, u, (err, success) ~>
                            if err then 
                                @error err
                                res.status "501" .end "There has been a problem activating your account. Please notify one of the admins, and give them the following number: #{user}"
                            else res.status "200" .end "Success! Your account has been activated!"

            else if code is "17" 
                root = if process.comp_args.compile then Transaction.config.urls.test else Transaction.config.urls.production
                res.set "Content-Type": "text/html" .status "403" .end "It seems that you have cancelled the payment. If you wish, you can get in touch with ISR and pay directly, or try using the following address to begin the online payment process again : <a href='#{root}api/transaction/#{user}'>#{root}api/transaction/#{user}</a>"
            else
                root = if process.comp_args.compile then Transaction.config.urls.test else Transaction.config.urls.production 
                res.set "Content-Type": "text/html" .status "501" .end "There's been some problem on the bank's side. Please, check with the bank first, to make sure funds were not substracted. Afterwards, you can get in touch with ISR and pay directly, or try using the following address to begin the online payment process again : <a href='#{root}api/transaction/#{user}'>#{root}api/transaction/#{user}</a>"
        "/api/payment/response": (req, res) ~> @log "response" req.body

    @staticapi = 
        "/api/transaction/:id": (req, res) ~> 
            @log "requesting transaction for #{req.params.id}"
            User.find "_id": req.params.id, (err, user) ~>
                @log "Got data from the db", err, user
                if err then res.status 501 .end "#{it}"
                else if user.length isnt 1 then res.status 501 .end "Problem finding the user for the tansaction"
                else 
                    @log "found the user for the transaction (making sure we won't create a new one)"
                    if user.0.activated isnt "true"
                        @getTransaction req.params.id
                        , ~> @error it; res.status 501 .end "#{it}"
                        , ~> @log it 
                        , (trans) ~> 
                            @log "Found the transaction!"
                            trans = trans.export!
                            @log "Transaction id (exported) is #{trans.Data.orderId}"
                            res.set "Content-Type": "text/html" .status 200 .end template trans
                    else res.status "200" .end "Your account has been already paid and activated."

    @api = 
        "adminGetAllTransactions": (sock, router, connection) ~>
            @log "Getting all transactions"
            @model.find (err, data) ~>
                @log "Got all transactions", err
                if err then sock.emit "admin:transaction:all", err
                else sock.emit "admin:transaction:all", null, data

        "getTransaction": (sock, router, connection, userId) ~>
            success = (trans) ~>
                if trans then sock.emit "transaction", trans.export!
                else sock.emit "transaction", new Error "No transaction"
            error = (err) ~> @error err; sock.emit "transaction", err
            progress = ~> @log ...

            @getTransaction userId, error, progress, success

    @getTransaction = (id, error, progress, success) ~>
        promise = (new @model!).create!

        @log "Attempting to get a transaction"
        promise.then success, error, progress .resolve id

    @initModel!

    if mongoose.connection.readyState is 0 then mongoose.connect "mongodb://localhost/test"

    @setPropExport module.exports

