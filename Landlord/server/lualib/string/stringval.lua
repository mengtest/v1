--[[
--用于获取语言包字符串
--]]
local skynet = require "skynet"
local sharedata=require "skynet.sharedata"
local log = require "log"

local server_string_config = nil;

local format = string.format;

local attr_cache_name = {};

local mod = {};

function mod.getstringval(key, ...)
	local val = server_string_config[key];
	if( not val) then
		log:warn("stringval : getstringval : un config string val[%s]", tostring(key));
		return format(key, ...);
	end
	--assert(val, "undefined key : ".. tostring(key));
	return format(val, ...);
end

--
skynet.init(function()
	server_string_config = sharedata.query("namestr");
end);

return mod;
