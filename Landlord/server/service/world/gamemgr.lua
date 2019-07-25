local skynet = require "skynet"
local service = require "service"
local sharedata = require "skynet.sharedata"

local game_cfg
skynet.init(function()
	game_cfg = sharedata.query("game_config")
end)

local games = {}

local _M = {}

function _M.get(name)
	return games[name]
end

local function init()
	for k,v in pairs(game_cfg) do
		if v.open > 0 then
			local game = skynet.newservice("world/game", k)
			games[k] = game
		end
	end
end

local function release()
	for name,game in pairs(games) do
		skynet.call(game, "lua", "stop");
	end
end

service.init {
	command=_M,
	info=nil,
	init=init,
	release=release,
}
