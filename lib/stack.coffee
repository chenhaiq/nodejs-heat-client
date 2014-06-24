pkgcloud   = require "pkgcloud"
request    = require "request"

class Stack
    constructor: (@options) ->

    _getHeader: ->
        if not @debug
            header =
                'Accept': 'application/json'
                'Content-Type': 'application/json'
                'X-Auth-User': @options.username
                'X-Auth-Key': @options.password
                'X-Auth-Token': @token
        else
            header =
                'Accept': 'application/json'
                'X-Auth-User': @options.username
                'X-Auth-Key': @options.password
                'X-Auth-Token': @token

    init:(callback) ->
        return callback() if @debug
        pkg_options =
              url: @options.authUrl
              username: @options.username
              password: @options.password
              tenantName: @options.tenantName
        await pkgcloud.providers.openstack.identity.createIdentity pkg_options, defer(error, data)
        return callback error if error? or not data?
        @token = data.token.id
        @tenantId = data.token.tenant.id
        @url = @options.heat_url or "#{data.serviceCatalog.services.heat.selectedEndpoint.publicURL}"
        callback()
        
    # used for unit test only
    debugMode: (@token, @tenantId, @url, next) ->
        @debug = true
        next()
    
    #This method do create a stack
    create: (stack_params, callback) ->
        await @init defer error
        requestOptions =
          "url": "#{@url}/stacks"
          "method": "POST"
          "headers": @_getHeader()
          "json": stack_params
        request requestOptions, (err, response, body) ->
            callback err, body
    
    # This method do list stacks
    list: (next) ->
        await @init defer err
        requestOptions =
          "url": "#{@url}/stacks"
          "headers": @_getHeader()
          "method": "GET"
        request requestOptions, (err, response, body) ->
            next err, JSON.parse(body)
    
    # this method do get a stack
    get: (options, next) ->
        await @init defer err
        get_id_opt =
            "url": "#{@url}/stacks/#{options.stack_name}"
            "method": "GET"
            "headers": @_getHeader()
        await request get_id_opt, (defer error, response, body)
        id = JSON.parse(body).stack.id
        requestOptions =
            "url": "#{@url}/stacks/#{options.stack_name}/#{id}"
            "method": "GET"
            "headers": @_getHeader()
        request requestOptions, (err, response, body)->
            callback err, JSON.parse(body)

    # this method do update a stack
    update: (options, next) ->
        await @init defer err
        get_id_opt =
            "url": "#{@url}/stacks/#{options.stack_name}"
            "method": "GET"
            "headers": @_getHeader()
        await request get_id_opt, (defer error, response, body)
        id = JSON.parse(body).stack.id
        requestOptions =
          "url": "#{@url}/stacks/#{options.stack_name}/#{id}"
          "method": "PUT"
          "headers": @_getHeader()
          "json": options
        request requestOptions, (err, response, body) ->
            next(err, body)  
    
    # this method do delete a stack
    del: (options, callback) ->
        await @init defer err
        if options.stack_name? and typeof options.stack_name is 'string' and options.stack_name.length isnt 0
            _opt =
                "url": "#{@url}/stacks/#{options.stack_name}"
                "method": "GET"
                "headers": @_getHeader()
        else if options.stack_id? and typeof options.stack_id is 'string' and options.stack_id.length isnt 0
            _opt =
                "url": "#{@url}/stacks/#{options.stack_id}"
                "method": "GET"
                "headers": @_getHeader()
        else
            err = new Error('Must give a stack name or id')
            return callback err
        await request _opt, (defer error, response, body)
        try
            id = JSON.parse(body).stack.id
            name = JSON.parse(body).stack.stack_name
        catch error
            err = new Error(body)
            return callback err
        requestOptions =
            "url": "#{@url}/stacks/#{name}/#{id}"
            "method": "DELETE"
            "headers": @_getHeader()
        request requestOptions, (err, response, body)->
            callback err, body 

module.exports = Stack
