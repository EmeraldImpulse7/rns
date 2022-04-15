--Rednet Secure (RNS)

--custom require from http go brrrrrrrrrrrrr
package.loaders[#package.loaders + 1] = function(name)
    if not name:find("^http") then
        return nil, "not a URL"
    end

    local localPathRoot = "/.cache/rns/"
    local filename = name:gsub("%.lua$",""):gsub(".*/","")..".lua"

    local localPath = localPathRoot .. filename
    if not fs.exists(localPath) then
        local request, err = http.get(name)
        if request then
            io.open(localPath, "w"):write(request.readAll()):close()
            request.close()
        else
            return nil, "Cannot download " .. name .. ": " .. err
        end
    end

    local fn, err = loadfile(localPath, nil, _ENV)
    if fn then
        return fn, localPath
    else
        return nil, err
    end
end

--set up our good old library table and shadow the default rednet api
--might change later, may want to implement regular unencrypted TCP
--probably gonna have to make another library for that, and then make it a dependency for this
--or i could have rns implement both TCP and encryption but that's kinda dumb cause its specifically for encryption
--idk
local rns = { version=0.1 }
for k, v in pairs(rednet) do rns[k] = v end
local expect = require "cc.expect"
expect = expect.expect

local sha = require("https://pastebin.com/raw/6UV4qfNF")

local function randomString(length)
    math.randomseed(os.time())
    local character_set = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    local random_string = {}

    for int = 1, length or 10 do
        local random_number = math.random(1, #character_set)
        local character = string.sub(character_set, random_number, random_number)

        random_string[#random_string + 1] = character
    end

    return table.concat(random_string)
end

--We can use this to check for replies from the computer you're talking to and see if it's an error message
--works like: assert(errorCheck(table_from_received_message))
--did this so that it's easier to check for errors the whole way
local function errorCheck(table)
    expect(1, table, "table")
    if table.error then
        return false, table.error
    else
        return true
    end
end

function rns.handshakeClient(serverID, randStr)
    --randStr an optional argument, can be inputed if you have your own method of random string generation
    --may remove
    expect(1, serverID, "number")
    expect(2, randStr, "string", "nil")
    if not randStr then
        randStr = randomString(128)
    end

    rns.send(serverID, { version=rns.version, randStr=randStr }, "ClientHello")

    local id, message = rednet.receive("ServerHello")
    assert(errorCheck(message))
end

function rns.handshakeServer()
    local id, message = rednet.receive("ClientHello")
    if message.version ~= rns.version then
        rns.send(id, { error="Incompatable versions! You're on "..message.version..", while I'm on "..rns.version.."!" }, "ServerHello")
        print("sent error")
        do return end
    else
        rns.send(id, {}, "ServerHello")
    end
end

--[[
    possible ideas for things I can implement
    - proper TCP implementation, might just go ahead and make it with RNS after all
    - make it work with .kst urls (maybe work in a certificate system that works with krist)
    - additional functionality for host(), will add an aditional "is_encrypted" or "encrypted" or "secure" field to the table that gets sent,
    this wont affect regular rednet and will allow rns clients to identify rns servers
        -aw shit ima have to overwrite rednet.run goddammit
    - not exactly a thing for the library but something I can make with it, a web browser and website server!
        -can prase urls like "rn://example.kst" or "rns://example.kst" for secure connections
        -will use rednet.host() for dns, clients can look up computers that support maybe "md" (markdown), "html", or i could make my own format.
            -custom name field will be used for urls
--]]

return rns
