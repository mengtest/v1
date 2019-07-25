local skynet=require 'skynet'
local LOCK=require 'skynet.queue'
local mysqlaux = require "skynet.mysqlaux.c"
local util=require "util"

local TNAME 		-- 表名
local SAVE 			-- SAVE[modname] = data
local PROXY,DIRTY
local SAVE_LOCK

local buildsql=[[CREATE TABLE IF NOT EXISTS `%s`(
  `id` varchar(50) NOT NULL,
  `val` blob,
  PRIMARY KEY (`id`)
)
ENGINE=Innodb;
]]

local format=string.format

local cache_pack=function(t)
	return mysqlaux.quote_sql_str(skynet.packstring(t))
end

local cache_unpack=function(s)
	return skynet.unpack(s)
end

local function query(id,...)
	local d
	if select("#",...)==1 then
		d= skynet.call(PROXY,'lua','query',...)
	else
		d= skynet.call(PROXY,'lua','query',format(...))
	end
	if d.errno then
		error(format("%d %s [%s]",d.errno,d.err,table.concat({...})))
	end
	return d
end

local function load_record(id)
	local d=query(id, format("select val from %s where id='%s'",TNAME,id))
	if not d.errno and #d==1 then
		return cache_unpack(d[1][1])
	end
	return nil
end

local function save_record(id,val)
	local val = cache_pack(val)
	local sql = format("insert into `%s`(id,val) values('%s',%s) on duplicate key update val=%s;",TNAME,id,val,val)
	query(id, sql)
end

local _M={}

function _M.init(proxy,tname)
	SAVE={}
	TNAME=tname
	PROXY=proxy
	SAVE_LOCK=LOCK()
end

function _M.loadall()
	if #SAVE > 0 then return SAVE end
	local d = skynet.call(PROXY,'lua','query',format("select id,val from `%s`",TNAME))
	if d.errno then
		skynet.call(PROXY,'lua','query',buildsql)
	else
		for _,v in ipairs(d) do
			local id = v[1]
			local val = v[2]
			SAVE[id] = cache_unpack(val)
		end
	end
	return SAVE
end

function _M.load(k)
	local m=SAVE[k]
	if m then return m end
	SAVE[k] = load_record(k)
	return SAVE[k]
end

function _M.dirty(k)
	local d=SAVE[k]
	if d then
		save_record(k,d)
	end
end

return _M
