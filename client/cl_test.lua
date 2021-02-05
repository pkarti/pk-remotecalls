RegisterCommand('rpc:test', function(src, args, raw)
    local result, ranNumber = remoteCalls.execute('test:callback')

    print(json.encode(result), json.encode(ranNumber))
end, false)