class StorageItem extends IS.Object
    constructor: (@item, @key, @parent) -> @driver = @parent.driver

    get: (callback, parse = false) =>
        try
            @driver.get @item, (@value) =>
                @value = JSON.parse @value if parse
                callback @value
        catch e
            @log e.message

    set : (value, stringify = false) =>
        if stringify then value = JSON.stringify value
        @driver.set @item, value
    
    remove: (callback) => @driver.remove @item, callback; @parent._remove @item

class Storage
    constructor: (callback) ->
        # Initial setup
        [@items, @lastKey, drivers, window.DBStorage] = [{}, 0, { "localstorage": "LocalStorage", "indexeddb": "IndexedDB" }, @]

        if Tester.indexeddb then @driver = new ( DepMan.helper "storage/Drivers/#{drivers.indexeddb}" )(=> callback() )
        else if Tester.localstorage then @driver = new ( DepMan.helper "storage/Drivers/#{drivers.localstorage}" )(=> callback() )

        return this

    # CRUD Definitions
    reuse  : (item) => @items[item] or (@items[item] = new StorageItem(item, @lastKey++, @))
    get    : (item, callback, parse = false) => (@reuse item).get callback, parse
    set    : (item, value, stringify = false) => (@reuse item).set value, stringify
    remove : (item, callback) => (@reuse item).remove callback
    check  : (item) => @get item, => console.log arguments

    # Ceanup Functions
    _remove: (item) => @items[item] = null

module.exports = Storage
