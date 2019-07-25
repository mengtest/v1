local skynet=require 'skynet'
local LOCK=require 'skynet.queue'
local mysqlaux = require "skynet.mysqlaux.c"
local util=require "util"

-- local SAVE
-- local PROXY,ID,DIRTY
-- local QUEUE
-- local SAVE_LOCK
-- local PREFIX
local DATA = {}

local buildsql=[[CREATE TABLE IF NOT EXISTS `%s%s`(
	`id` varchar(50) NOT NULL,
	`val` BLOB NULL,
	`ver` INT(11) NULL DEFAULT '0',
	PRIMARY KEY (`id`)
)
ENGINE=Innodb;
]]

local format=string.format

local function query(id,...)
	local PROXY = DATA[id].PROXY
	local d
	if select("#",...)==1 then
		d= skynet.call(PROXY,'lua','query',...)
	else
		d= skynet.call(PROXY,'lua','query',format(...))
	end
	if d.errno then
		error(format("%s[%s]",d.err,table.concat({...})))
	end
	return d
end

local chache_pack=function(t)
	return mysqlaux.quote_sql_str(skynet.packstring(t))
end

local chache_unpack=function(s)
	return skynet.unpack(s)
end

local function load_record(id,k)
	local PROXY = DATA[id].PROXY
	local ID = DATA[id].ID
	local PREFIX = DATA[id].PREFIX

	local d=skynet.call(PROXY,'lua','safe_query',format("select val,ver from %s%s where id='%s'",PREFIX,k,ID))
	if d.errno then
		if d.errno==1146 then
			query(id,buildsql,PREFIX,k)
			return load_record(id,k)
		else
			error(d.err)
		end
	elseif #d==1 then
		d=d[1]
		d[1]=chache_unpack(d[1])
	elseif #d==0 then
		query(id,"insert ignore %s%s(id,val) values('%s',%s)",PREFIX,k,ID,chache_pack{})
		return load_record(id,k)
	else
		assert(false)
	end
	return d
end

local function save_record(id,k,val,ver)
	local PROXY = DATA[id].PROXY
	local ID = DATA[id].ID
	local PREFIX = DATA[id].PREFIX
	
	query(id,string.format([[update %s%s set val=%s,ver=%d where id="%s"]],PREFIX,k,chache_pack(val),ver,ID))
end

local _M={}

function _M.init(prfix,id,proxy)
	while DATA[id] do
		DATA[id].run = nil
		skynet.sleep(10)
	end
	DATA[id] = {run = true}
	local d = DATA[id]
	d.SAVE={}
	d.PREFIX,d.ID,d.PROXY=prfix,id,proxy
	d.SAVE_LOCK=LOCK()
	d.QUEUE=setmetatable({},{__index=function(t,k)
		local q=LOCK()
		t[k]=q
		return q
	end})
	d.check_time=skynet.now()+1000
	skynet.fork(function(id)
		while DATA[id].run do
			if skynet.now()>DATA[id].check_time then
				DATA[id].check_time=skynet.now()+1000
				_M.save(id)
			end
			skynet.sleep(10)
		end
		DATA[id] = nil
	end,id)
end

local function load(id,k)
	local d=DATA[id].SAVE[k]
	if not d then
		DATA[id].SAVE[k]=load_record(id,k)
		d=DATA[id].SAVE[k]
	end
	d.save_time = 0
	return d
end

local function save(id)
	if not DATA[id].DIRTY then return end
	for k,d in pairs(DATA[id].SAVE) do
		if d.dirty then
			local val,ver=d[1],d[2]
			save_record(id,k,val,ver)
			if d[2]==ver then
				d.dirty=nil
			end
			d.save_time=skynet.now()
		end
	end
end

local function getsub(S,K,...)
	if K==nil then return S end
	local s=S[K]
	if not s then
		s={}
		S[K]=s
	end
	return getsub(s,...)
end

function _M.load(id,k,...)
	local d=DATA[id].SAVE[k]
	if d then return d[1] end
	DATA[id].QUEUE[k](load,id,k)
	local S=DATA[id].SAVE[k][1]
	return getsub(S,...)
end

function _M.dirty(id,k)
	DATA[id].DIRTY=true
	local d=DATA[id].SAVE[k]
	d.dirty,d[2]=true,d[2]+1
end

function _M.savetime(id,k)
	local d=DATA[id].SAVE[k]
	return d.save_time
end

function _M.save(id)
	DATA[id].SAVE_LOCK(save,id)
end

function _M.unload(id)
	while DATA[id].DIRTY do
		_M.save(id)
		local dirty=nil
		for k,v in pairs(DATA[id].SAVE) do
			if v.dirty then
				dirty=true
				break
			end
		end
		if not dirty then DATA[id].DIRTY=nil end
	end
	DATA[id].run = nil
end

return _M
