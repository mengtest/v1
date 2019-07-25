local skynet = require "skynet"
local service = require "service"
local mysql = require 'skynet.db.mysql'
local cluser = require 'cluster'
local setting = require "setting"
local mysqlauto = require "mysql.mysqlauto"
local util = require "util"

local function on_connect(self)
	self:query('set names utf8');
end

local function dump()
	local conf = setting.get("db")
	for name, dbcfg in pairs(conf) do
		local opt = util.copy(dbcfg.opt)
		opt.compact_arrays = false
		opt.on_connect = on_connect
		local con = mysql.connect(opt)
		mysqlauto.dump(con, {name})
		con:disconnect()
	end
end


local _M={}

function _M.dump()
	dump()
end

service.init {
	command = _M,
	info = {"dbdump"},
	init = dump,
	release = nil,
}
