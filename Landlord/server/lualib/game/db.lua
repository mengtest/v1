local skynet=require "skynet"
local util = require "util"

local format = string.format
local proxy
skynet.init(function()
    proxy=assert(skynet.call(skynet.uniqueservice('dbmgr'),"lua","query","DB_GAME"))
end)

local function query(...)
    local d
    if select("#",...)==1 then
        d = skynet.call(proxy,'lua','query',...)
    else
        d = skynet.call(proxy,'lua','query',format(...))
    end
    if d.errno then
        error(format("%s[%s]",d.err,table.concat({...})))
    end
    return d
end

return function (...)
    return query(...)
end