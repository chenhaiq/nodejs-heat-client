{ spawn }            = require "child_process"
fs                   = require "fs"
glob                 = require "glob"
path                 = require "path"
{ parallel, series } = require "async"

task "clean", "Remove all compiled *.js files.", ->
    clean complete

task "compile", "Compile the code.", ->
    tasks = [
        (callback) -> clean callback
        (callback) -> compile callback
    ]
    series tasks, complete

clean = (callback) ->
    console.log "Cleaning up old files..."
    tasks = [
        (callback) -> glob "lib/*.js", callback
        (callback) -> glob "test/**/*.js", callback
    ]
    parallel tasks, (error, files) ->
        files = files.reduce ((previous, current) -> previous.concat current), []
        await
            for file in files
                fs.unlink file, defer error
        console.log "Finished cleaning up."
        callback()

compile = (callback) ->
    console.log "Compiling src -> lib/*.js"
    await node "./node_modules/.bin/iced --compile --output lib/ src/", defer error
    if error?
        console.log "Failed to compile the src code."
        return callback error
    else
        console.log "Compiling test -> test/*.js"
        await node "./node_modules/.bin/iced --compile test/", defer error
        if error?
            console.log "Failed to compile the test code."
            return callback error
        else
            console.log "Successfully compiled the code."
            return callback()

complete = (error) -> throw error if error?

node = (command, callback) ->
    args = command.split " "
    code = 0
    stamp = Date.now()
    
    await
        child = spawn process.execPath, args, { stdio: "inherit" }
        child.on "close", defer code
        child.on "exit", defer code
    if code is 0 then callback() else callback("'#{command}' failed")
