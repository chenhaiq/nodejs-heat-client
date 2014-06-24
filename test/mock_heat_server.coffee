http = require('http')
util = require('util')
express = require('express')

EXPECTED_TENANT_ID = ['111111', '222222', '333333', '444444']  
EXPECTED_STACK_NAME = ['aaaaaa', 'bbbbbb', 'cccccc', 'dddddd']
EXPECTED_STACK_ID = ['555555', '666666', '777777', '888888']  

creatsStack = (req,res) ->
    tenant_id = req.params.tenant_id
    statusCode = 201
    body = 
        "stack":
            "id": EXPECTED_STACK_ID[0]
            "links": "[ [Object] ]"
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body

listsStack = (req, res) ->
    tenant_id = req.params.tenant_id
    type = req.query.type
    fail = req.query.fail or false
    m = EXPECTED_TENANT_ID.indexOf(tenant_id)
    if fail 
        statusCode = 401 
        body = ""
    else 
        if m == -1 
            statusCode = 502
            body = 'Please type in right value!'
        else
            statusCode = 200
            body = 
                'tenant_id': tenant_id
                'stacks': 
                     'description': 'No description'
                     'links': 
                         'href': "http://127.0.0.1:8082/v1/#{tenant_id}/stacks"
                         'rel': 'self'
                     'stack_status_reason': 'Stack create completed successfully'
                     'creation_time': '2013-12-00T00:00:00'
                     'stack_status': 'CREATE_COMPLETE'
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
findsUrlStack = (req, res, next) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    #console.log(req.params)
    m = EXPECTED_TENANT_ID.indexOf(tenant_id)
    n = EXPECTED_STACK_NAME.indexOf(stack_name)
    o = EXPECTED_STACK_ID.indexOf(stack_id)
    #console.log(m,n,o)
    if n == -1 and o != -1
        stack_name = EXPECTED_STACK_NAME[o]
    if n != -1 and o == -1
        stack_id = EXPECTED_STACK_ID[n]
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        if m != -1 and (n != -1 or o != -1)
            statusCode = 201
            body = 
                'tenant_id': tenant_id
                'stack': 
                     'description': 'No description'
                     'links': 
                         'href': "http://127.0.0.1:8082/v1/#{tenant_id}/stacks/#{stack_name}"
                         'rel': 'self'
                     'stack_status_reason': 'Stack create completed successfully'
                     'stack_name': stack_name
                     'id': stack_id
                     'creation_time': '2013-12-00T00:00:00'
                     'stack_status': 'CREATE_COMPLETE'
        else
            statusCode = 502
            body = 'Please type in right value!'
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body

findsResourcelistStack = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 302
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
findsEventlistStack = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 302
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
getsDataStack = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
updatesStack = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    m = EXPECTED_TENANT_ID.indexOf(tenant_id)
    n = EXPECTED_STACK_NAME.indexOf(stack_name)
    q = EXPECTED_STACK_ID.indexOf(stack_id)
    if m != -1 and n != -1
        if q != -1
            statusCode = 202
            body = ""
        else
            statusCode = 502
            body = 'Please type in right value!'
    else
        statusCode = 502
        body = 'Please type in right value!'
      
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
deletesStack = (req, res) ->
    tenant_id = req.params.tenant_id 
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    m = EXPECTED_TENANT_ID.indexOf(tenant_id)
    n = EXPECTED_STACK_NAME.indexOf(stack_name)
    p = EXPECTED_STACK_ID.indexOf(stack_id)
    body = null
    if m != -1 and n != -1
        if p != -1
            statusCode = 204
            body =
                'tenant_id': tenant_id
                'stacks':
                     'description': 'No description'
                     'links':
                         'href': "http:127.0.0.1:8082/v1/#{tenant_id}/stacks/#{stack_name}/#{stack_id}"
                         'rel': 'self'
                     'stack_status_reason': 'Stack DELETE started'
                     'stack_name': stack_name
                     'creation_time': '2013-00-00T00:00:00'
                     'updated_time': '2013-00-00T00:00:01'
                     'stack_status': 'DELETE successed'
                     'id': stack_id
        else
            statusCode = 502 
            body = 'Please type in right value!'
    else
        statusCode = 502 
        body = 'Please type in right value!'
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
    
listsEventsStack = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
listsResourcesStack = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
getsDataResource = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    resource_name = req.params.resource_name
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
            'resource' :
                'name' : resource_name
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
getsMetadataResource = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    resource_name = req.params.resource_name
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
            'resource' :
                'name' : resource_name
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
listsEventsResourcesStack = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body =         
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
getsDataEvent = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    event_id = req.params.event_id
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
            'event' :
                'id' : event_id
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
getsTemplateStack = (req, res) ->
    tenant_id = req.params.tenant_id
    stack_name = req.params.stack_name
    stack_id = req.params.stack_id
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
  
validatesTemplate = (req, res) ->
    tenant_id = req.params.tenant_id
    fail = req.query.fail or false
    if fail then statusCode = 401 
    else 
        statusCode = 200
        body = 
            'tenant' :
                'id' : tenant_id
            'stack' :
                'name' : stack_name
                'id' : stack_id
            'resource' :
                'name' : resource_name
    "template_url":"{template_url}"
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body 
   
listsTemplateTypes = (req, res) ->
    tenant_id = req.params.tenant_id
    fail = req.query.fail or false
    if fail then statusCode = 401
    else
        statusCode = 200
        body = 
            'tenant' :
                 'id' : tenant_id
    res.writeHead statusCode, 'Content-Type': 'application/json'
    res.end JSON.stringify body
 
run = ->
    ip = '127.0.0.1'
    port = 8082
    server = express()
    server.post '/v1/:tenant_id/stacks', creatsStack
    server.get '/v1/:tenant_id/stacks/:stack_name([a-z]+)', findsUrlStack
    server.get '/v1/:tenant_id/stacks/:stack_id([0-9]+)', findsUrlStack
    server.delete '/v1/:tenant_id/stacks/:stack_name/:stack_id', deletesStack
    server.listen port, ip
    console.log "--Mock Heat server listening on IP #{ip} port #{port}--"


exports.run = run
exports.EXPECTED_TENANT_ID = EXPECTED_TENANT_ID 
exports.EXPECTED_STACK_NAME = EXPECTED_STACK_NAME 
exports.EXPECTED_STACK_ID = EXPECTED_STACK_ID



