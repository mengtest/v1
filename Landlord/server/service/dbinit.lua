local skynet = require "skynet"
local service = require "service"
local mysql = require "skynet.db.mysql"
local cluser = require 'skynet.cluster'
local setting = require "setting"
local mysqlauto = require "mysql.mysqlauto"

local function on_connect(self)
	self:query('set names utf8');
end

function table.copy(t)
	local r={}
	for k,v in pairs(t) do
		if type(v)=='table' then
			r[k]=table.copy(v)
		else
			r[k]=v
		end
	end
	return r
end

local _M={}
local conf
local function init()
	conf=setting.get("db")
	mysqlauto.ignore("t_mod")
	mysqlauto.ignore("t_rank")
	mysqlauto.ignore("t_log")
	local dbs={}
	for name,cfg in pairs(conf) do
		dbs[cfg.opt.database]=dbs[cfg.opt.database] or {}
		table.insert(dbs[cfg.opt.database], name)
		local opt=table.copy(cfg.opt)
		opt.on_connect=on_connect
		opt.database='mysql'
		local con=mysql.connect(opt)
		con:query(string.format('CREATE DATABASE `%s` /*!40100 DEFAULT CHARACTER SET utf8 */',cfg.opt.database))
		con:disconnect()
	end
	for dbname,names in pairs(dbs) do
		local name=names[1]
		local cfg=conf[name]
		local opt=table.copy(cfg.opt)
		opt.on_connect=on_connect
		opt.compact_arrays = false
		local con=mysql.connect(opt)
		mysqlauto.fix(con, names)
		-- mysqlauto.dump(con,names)
		con:disconnect()
	end
end

function _M.query(db)
	return conf[db]
end

service.init {
	command = _M,
	init=init,
}
