--数据库日志
local skynet = require "skynet"
local service = require "service"
local setting=require"setting"

local log_cnt=0

local _M={}

--[[
--默认必须要有的字段
--]]
local default_field = {
	["optime"] = {tp=1,valuecall=skynet.time},
};
local default_value = {}

--[[数据类型说明
	1  int(11) 		int_32
	2  bigint(20)	int_64
	3  varchar(50)	string
	4  blob 		bit
]]
-- 角色数据表公有字段
local ply_head = {
	{"sid",1},{"platform",1},{"sdk",3},{"uid",2},{"uname",3},{"rid",2},{"rname",3}
}

--数据表定义,这里配置日志表(然后在log数据库里去按对应的名字建表),必须有optime字段(操作时间)
--seri 一组操作的系列号,eg:买了一个道具,那么扣钱的seri和得道具的日志应该是同一个seri
--flag 操作简要信息
--optime 操作时间
local ply_log = {
	----------------------- 个人基础
	-- 创建角色
	["createrole"]= {{"optime",1}},
	--角色登录日志
	["login"]= {{"logintime",1},{"logouttime",1},{"seri",2},{"optime",1}},
	--代币
	["money"]= {{"old",2},{"new",2},{"val",2},{"src",3},{"optime",1}},
}

--其他非玩家的日志,如帮会
local other_log = {
	-- ["guildmoney"]={"gid","gname","moneytype","old", "new", "val", "flag", "optime"},
	["online"]={{"online_num",1},{"optime",1}}
	-- ["email"] = {"player_id","email_id","title","content","goods","flag","optime"},
	-- ["guildAuction"]={"gid","gname","opType","goodsId","num","money","optime"},
}

local build_s=[[CREATE TABLE IF NOT EXISTS `%s`(
	`id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT
]]
local build_e=[[
)AUTO_INCREMENT=0,
ENGINE=Innodb;
]]

local function createsql(dbproxy)
	local head = ""
	for _,v in ipairs(ply_head)do
		local line = "`"..v[1].."` "
		if v[2] == 1 then
			line = line.."INT(11) NULL"
		elseif v[2] == 2 then
			line = line.."BIGINT(20) NULL"
		elseif v[2] == 3 then
			line = line.."VARCHAR(50) NULL"
		else
			line = line.."BLOB NULL"
		end
		head = head..","..line
	end
	for name,cfg in pairs(ply_log)do
		local body = ""
		for _,v in ipairs(cfg)do
			local line = "`"..v[1].."` "
			if v[2] == 1 then
				line = line.."INT(11) NULL"
			elseif v[2] == 2 then
				line = line.."BIGINT(20) NULL"
			elseif v[2] == 3 then
				line = line.."VARCHAR(50) NULL"
			else
				line = line.."BLOB NULL"
			end
			body = body..",".. line
		end

		local sql = string.format(build_s,"t_log_"..name)..head..body..build_e
		skynet.call(dbproxy,'lua','query',sql)
	end

	for name,cfg in pairs(other_log)do
		local body = ""
		for _,v in ipairs(cfg)do
			local line = "`"..v[1].."` "
			if v[2] == 1 then
				line = line.."INT(11) NULL"
			elseif v[2] == 2 then
				line = line.."BIGINT(20) NULL"
			elseif v[2] == 3 then
				line = line.."VARCHAR(50) NULL"
			else
				line = line.."BLOB NULL"
			end
			body = body..",".. line
		end

		local sql = string.format(build_s,"t_log_"..name)..body..build_e
		skynet.call(dbproxy,'lua','query',sql)
	end
end

local function genlogsql(name, cfg, isplayer)
	local keys={}
	local values={}
	if isplayer then
		for _,v in ipairs(ply_head)do
			table.insert(keys,v[1]..",")
			table.insert(values,"'%s',")
		end
	end
	for k,v in ipairs(cfg)do
		if k < #cfg then
			table.insert(keys,v[1]..",")
			table.insert(values,"'%s',")
		else
			table.insert(keys,v[1])
			table.insert(values,"'%s'")
		end
	end
	local sql=string.format("insert into t_log_%s(%s) values(%s)",name,table.concat(keys),table.concat(values))
	return sql
end

function _M.log(name,role,...)
	--[[
	local p = {...}
	local valuecalllist = default_value[name];
	if valuecalllist then
		for _, callback in pairs(valuecalllist) do
			table.insert(p, callback());
		end
	end
	--]]
	local sql
	local cfg = ply_log[name]
	if cfg then
		-- "sid","platform","sdk","uid","uname","rid","rname"
		sql = string.format(cfg.sql,_M.sid,role.platform,role.sdk,role.uid,role.uname,role.rid,role.rname,...)
	else
		cfg = other_log[name]
		if cfg then
			sql = string.format(cfg.sql, ...)
		end
	end
	if sql then
		log_cnt = log_cnt + 1
		skynet.call(cfg.dbproxy,'lua','query',sql)
	end
end

function _M.update(name, set)
	local cfg = ply_log[name]
	if set then
		local sql = "update t_log_"..name.." "..set
		log_cnt = log_cnt + 1
		skynet.call(cfg.dbproxy,'lua','query',sql)
	end
end

function _M.info_stat()
	return log_cnt
end

local function init_single_default_field(name, single)
	local add = {};
	for dk, dinfo in pairs(default_field) do
		local have = false
		for _, info in pairs(single) do
			if dk == info[1] then
				have = true
				break;
			end
		end
		if not have then
			table.insert(add, {dk, dinfo.tp, dinfo.valuecall})
		end
	end
	for _, d in pairs(add) do
		table.insert(single, {d[1], d[2]});
		default_value[name] = default_value[name] or {};
		table.insert(default_value[name], d[3]);
	end
end

local function init_all_default_field()
	for k, info in pairs(ply_log) do
		init_single_default_field(k, info)
	end
	for k, info in pairs(other_log) do
		init_single_default_field(k, info)
	end
end

local function init()
	local dbmgr = skynet.uniqueservice("dbmgr")
	local dbproxy=skynet.call(dbmgr,"lua","query","DB_LOG")
	_M.sid=setting.get("svr_id")
	init_all_default_field();
	for k,v in pairs(ply_log)do
		v.sql = genlogsql(k,v,true)
		v.dbproxy=skynet.call(dbmgr,"lua","query","DB_LOG")
	end

	for k,v in pairs(other_log)do
		v.sql = genlogsql(k,v)
		v.dbproxy=skynet.call(dbmgr,"lua","query","DB_LOG")
	end
	createsql(dbproxy)

	local set=dofile("run/setting/modifylog.lua")
	for _,sql in ipairs(set) do
		skynet.call(dbproxy,'lua','safe_query',sql)
	end
end

local function release()

end

service.init {
	command = _M,
	init = init,
	release = release,
}
