{Stack}            = require "../lib/stack"
expect           = require "expect.js"
mock_heat_server = require "./mock_heat_server"

mock_heat_server.run()
describe "Stack class", ->

    tenantId = mock_heat_server.EXPECTED_TENANT_ID[0]
    stackName = mock_heat_server.EXPECTED_STACK_NAME[0]
    stackId = mock_heat_server.EXPECTED_STACK_ID[0]
    url = "http://127.0.0.1:8082/v1/#{tenantId}"

    describe "methods", ->
        os_options = null
 
        beforeEach (done) ->
            os_options = 
                username: "admin"
                password: "anypw"
                tenantName: "default"
            done()
            
        afterEach (done) ->
            done()
            
        it "can create stack", (done) ->
            stack = new Stack(os_options)
            await stack.debugMode("test_token", "#{tenantId}", "#{url}",defer error)
            options =
                "stack_name": stackName
                "template": '{"Outputs": {"InstanceIp": {"Description": "a test", "Value": {"Fn::GetAtt": ["instance", "networks"]}}}, "Resources": {"instance": {"Type": "OS::Nova::Server", "Properties": {"image": "cirros-0.3.1-x86_64-uec", "flavor": "2"}}}}',
            
            stack.create options, (err, body)->
                (expect err).to.be null
                (expect body.stacks).to.not.be null
                done()
                
        it "can list stack", (done) ->
            stack = new Stack(os_options)
            await stack.debugMode("test_token", "#{tenantId}", "#{url}",defer error)
            stack.list (err, body)->
                (expect err).to.be null
                (expect body.stacks).to.not.be null 
                done()                

        it "can get stack", (done) ->
            stack = new Stack(os_options)
            await stack.debugMode("test_token", "#{tenantId}", "#{url}", defer error)
            options =
                "stack_name": stackName,
                "stack_id": stackId
            
            stack.get options, (err, body)->
                (expect err).to.be null
                (expect body.stacks).to.not.be null 
                done()

        it "can update stack", (done) ->
            stack = new Stack(os_options)
            await stack.debugMode("test_token", "#{tenantId}", "#{url}", defer error)
            options =
                "stack_name": stackName,
                "stack_id": stackId
                "template": '{"Outputs": {"InstanceIp": {"Description": "a test", "Value": {"Fn::GetAtt": ["instance", "networks"]}}}, "Resources": {"instance": {"Type": "OS::Nova::Server", "Properties": {"image": "cirros-0.3.1-x86_64-uec", "flavor": "2"}}}}',
            
            stack.update options, (err, body)->
                (expect err).to.be null
                (expect body).to.be ''
                done()
                
        it "can delete stack", (done) ->
            stack = new Stack(os_options)
            await stack.debugMode("test_token", "#{tenantId}", "#{url}", defer error)
            options =
                "stack_name": stackName,
                "stack_id": stackId

            
            stack.del options, (err, body)->
                (expect err).to.be null
                # express can not return body for delete request
                done()

