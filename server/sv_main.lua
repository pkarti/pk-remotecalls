local res, promises, functions, callIden = GetCurrentResourceName(), {}, {}, 0

remoteCalls = {}

remoteCalls.register = function(name, func)
    functions[name] = func
end

remoteCalls.remove = function(name)
    functions[name] = nil
end

paramPacker = function(...)
    local params, pack = {...}, {}

    for i = 1, 15, 1 do
        pack[i] = {param = params[i]}
    end
    return pack
end

paramUnpacker = function(params, index)
    local idx = index or 1

    if idx <= #params then return params[idx]['param'], paramPacker(params, idx + 1) end
end

unpacker = function(params, index)
    local idx = index or 1

    if idx <= 15 then return params[idx], unpacker(params, idx + 1) end
end

clearPromise = function(callId)
    Citizen.SetTimeout(5000, function()
        promises[callId] = nil
    end)
end

RegisterNetEvent('pk-remoteCalls:cl_request')
AddEventHandler('pk-remoteCalls:cl_request', function(origin, name, callId, params)
    local response

    if functions[name] == nil then return end
    local success, error = pcall(function()
        if packaged then
            response = paramPacker(functions[name](paramUnpacker(params)))
        else
            response = paramPacker(functions[name](unpacker(params)))
        end
    end)

    if not success then
        print(string.format('Data Fetch Error: %s %s %s', origin, name, error))
    end

    if response == nil then response = {} end

    TriggerClientEvent('pk-remoteCalls:cl_response', source, origin, callId, response)
end)