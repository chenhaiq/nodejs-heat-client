pkgcloud   = require "pkgcloud"
request    = require "request"

class Stack
    constructor: (@options) ->

    _getHeader: ->
        'Accept': 'application/json'
        'Content-Type': 'application/json'
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
        pkgcloud.providers.openstack.identity.createIdentity pkg_options, (error, data)->
            return callback error if error? or not data?
            @token = data.token.id
            @tenantId = data.token.tenant.id
            @url = @options.heat_url or "#{data.serviceCatalog.services.heat.selectedEndpoint.publicURL}"
            callback()
        
    # used for unit test only
    debugMode: (@token, @tenantId, @url, next) ->
        @debug = true
        next()
    
    create: (stack_params, callback) ->
        self = this
        @init (error)->
            requestOptions =
              "url": "#{self.url}/stacks"
              "method": "POST"
              "headers": self._getHeader()
              "json": stack_params
            request requestOptions, (err, response, body) ->
                callback err, body
    
    list: (next) ->
        self = this
        @init (error)->
            requestOptions =
              "url": "#{self.url}/stacks"
              "headers": self._getHeader()
              "method": "GET"
            request requestOptions, (err, response, body) ->
                next err, JSON.parse(body)
    
    get: (options, next) ->
        self = this
        @init (error)->
            get_id_opt =
                "url": "#{self.url}/stacks/#{options.stack_name}"
                "method": "GET"
                "headers": self._getHeader()
            await request get_id_opt, (defer error, response, body)
            id = JSON.parse(body).stack.id
            requestOptions =
                "url": "#{self.url}/stacks/#{options.stack_name}/#{id}"
                "method": "GET"
                "headers": self._getHeader()
            request requestOptions, (err, response, body)->
                next err, JSON.parse(body)

    update: (options, next) ->
        self = this
        @init (error)->
            get_id_opt =
                "url": "#{self.url}/stacks/#{options.stack_name}"
                "method": "GET"
                "headers": self._getHeader()
            await request get_id_opt, (defer error, response, body)
            id = JSON.parse(body).stack.id
            requestOptions =
              "url": "#{self.url}/stacks/#{options.stack_name}/#{id}"
              "method": "PUT"
              "headers": self._getHeader()
              "json": options
            request requestOptions, (err, response, body) ->
                next(err, body)  
    
    del: (options, callback) ->
        self = this
        @init (error)->
            if options.stack_name? and typeof options.stack_name is 'string' and options.stack_name.length isnt 0
                _opt =
                    "url": "#{self.url}/stacks/#{options.stack_name}"
                    "method": "GET"
                    "headers": self._getHeader()
            else if options.stack_id? and typeof options.stack_id is 'string' and options.stack_id.length isnt 0
                _opt =
                    "url": "#{self.url}/stacks/#{options.stack_id}"
                    "method": "GET"
                    "headers": self._getHeader()
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
                "url": "#{self.url}/stacks/#{name}/#{id}"
                "method": "DELETE"
                "headers": self._getHeader()
            request requestOptions, (err, response, body)->
                callback err, body 

module.exports =
    Stack: Stack
