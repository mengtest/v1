local skynet = require "skynet"
local service = require "service"
local string_format = string.format

local _M={}

local dbmgr
skynet.init(function()
    dbmgr=skynet.uniqueservice("dbmgr")
end)

local function query(proxy,...)
    local d
    if select("#",...)==1 then
        d= skynet.call(proxy,'lua','query',...)
    else
        d= skynet.call(proxy,'lua','query',string_format(...))
    end
    if d.errno then
        error(string_format("%s[%s]",d.err,table.concat({...})))
    end
    return d
end

local freeproxy={}
local function start()
    freeproxy=skynet.call(dbmgr,"lua","query_list", "DB_LOG")
end

local queue={}
local function run(proxy,sql)
    if not sql then
        sql=table.remove(queue,1)
    end
    while sql do
        query(proxy, sql)
        sql=table.remove(queue,1)
    end
    table.insert(freeproxy,proxy)
end

function _M.push_log(...)
    local sql
    if select("#",...)==1 then
            sql=...
        else
            sql=string_format(...)
        end
    local proxy=table.remove(freeproxy)
    if proxy then
        skynet.fork(run,proxy,sql)
    else
        table.insert(queue, sql)
    end
end

service.init {
    command = _M,
    info = nil,
    release=nil,
    init=start,
}