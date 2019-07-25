local skynet = require "skynet"
require "skynet.queue"
local service = require "service"
local log=require "log"

local DB={}
local INDEX={}
local UNIQUE={}
local _M={}

local LOCK=skynet.queue()


local dbinit
skynet.init(function()
	dbinit=skynet.uniqueservice("dbinit")
end)

local function start(name)
	if DB[name] then return end
	local conf=assert(skynet.call(dbinit,"lua","query",name))
	local ret={}
	for i=1,math.max(conf.count,1) do
		local s=skynet.newservice("mysqld", string.format("[%s.%d]",name,i))
		assert(skynet.call(s,"lua","start",conf.opt))
		table.insert(ret,s)
	end
	DB[name]=ret
end

local function release()
	for nm,v in pairs(DB) do
		for _,s in pairs(v) do
			skynet.call(s,"lua","stop")
		end
	end
	DB={}
end

function _M.query(db)
	local list=DB[db]
	if not list then
		LOCK(start,db)
		return _M.query(db)
	end
	local idx=INDEX[db] or 1
	INDEX[db]=idx+1
	idx=idx%(#list)
	if idx==0 then idx=#list end
	return list[idx]
end

function _M.query_list(db)
	local list=DB[db]
	if not list then
		LOCK(start,db)
		return _M.query_list(db)
	end
	return list
end

function _M.query_unique(db,flag)
	local s=string.format("%s@%s",flag,db)
	local r=UNIQUE[s]
	if not r then
		r=_M.query(db)
		if not UNIQUE[s] then
			UNIQUE[s]=r
		else
			r=UNIQUE[s]
		end
	end
	return r
end

function _M.stat()
	local ret={}
	for db,list in pairs(DB) do
		local cnt,allcnt,fincnt,errcnt=0,0,0,0
		for _,d in ipairs(list) do
			local a,c,e=skynet.call(d,"lua","info")
			cnt,allcnt,fincnt,errcnt=cnt+1,allcnt+a,fincnt+c,errcnt+e
		end
		ret[db]={cnt,allcnt,fincnt,errcnt}
	end
	return ret
end

service.init {
	command = _M,
	info = DB,
	release=release,
}