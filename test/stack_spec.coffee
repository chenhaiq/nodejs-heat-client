stack            = require "../lib/stack"
expect           = require "expect.js"
mock_heat_server = require "./mock_heat_server"

mock_heat_server.run()

describe "client", ->
    
    it "can create a heat stack", (done) ->
        #TODO implement
        done()
        