local skynet = require "skynet"
local service = require 'service'
local client=require 'robot.client'
local socket=require 'skynet.socket'
local sharedata=require "skynet.sharedata"
local util=require "util"
local log=require "log"
local md5=require "md5"
local timer=require "timer"
local H=client.handler()

skynet.init(function()

end)

local mods = {}

local host,port,id,mod=...
local CMD={}
local roles=nil
local entered=nil
local loaded=0
local running=nil

local battlemap = 1000
local moverange = 8
local movebase=true
local obj={}

local function relogin(self)
	self.exit = true
end

-- local function login(self)
-- 	-- client.push(self,'redeem',{code = 'mh3MA5somdD5803p10'})
-- end

local function save(self)
	log("修改密码次数：%d, 身上余额：%d", self.modify, self.gold)
	if self.modify == 0 then
		client.push(self,'safe_password',{old='',new='aaaaaa'})
	else
		client.push(self,'safe_open',{password='aaaaaa'})
	end
end

function H:safe_info(msg)
	log("保险箱余额：%d", msg.gold)
	self.safe = msg.gold
	-- if msg.transfer then
	-- 	for i,v in ipairs(msg.transfer) do
	-- 		log("%d 赠送给：%s, 金币 %d", v.ti, v.rname,v.amount)
	-- 	end
	-- end
	-- if msg.receive then
	-- 	for i,v in ipairs(msg.receive) do
	-- 		log("%d 收到获赠：%s, 金币 %d", v.ti, v.rname,v.amount)
	-- 	end
	-- end
	local id = {67108881,16777233}
	skynet.sleep(200)
	-- for i,v in ipairs(id) do
	-- 	if v ~= self.rid then
	-- 		client.push(self,'safe_transfer',{tid=v,amount=10000})
	-- 	end
	-- end
	if self.gold > self.safe then
		client.push(self,'safe_save',{amount=100000})
	else
		client.push(self,'safe_draw',{amount=100000})
	end
end

local function bull(self)
	if self.game then
		client.push(self,'enter_game',{gameid=self.game.gameid,roomid=self.game.roomid})
	else
		client.push(self,'enter_game',{gameid='bull',roomid=1})
	end
	while not self.exit do
		skynet.sleep(100)
	end
end

local function cattle(self)
	if self.game then
		client.push(self,'enter_game',{gameid=self.game.gameid,deskid=self.game.deskid})
	else
		client.push(self,'enter_game',{gameid='cattle',deskid=1})
	end
	while not self.exit do
		skynet.sleep(100)
	end
end

local function laba(self,gameid)
	client.push(self,'enter_game',{gameid=gameid,roomid=1})
	while not self.exit do
		skynet.sleep(100)
	end
end

local function baccarat(self)
	if self.game then
		client.push(self,'enter_game',{gameid=self.game.gameid,deskid=self.game.deskid})
	else
		client.push(self,'enter_game',{gameid='baccarat'})
		client.push(self, 'baccarat_play', {deskid=1})
	end
	while not self.exit do
		skynet.sleep(100)
	end
end

local function goldenflower(self)
	if self.game then
		client.push(self,'enter_game',{gameid=self.game.gameid,roomid=self.game.roomid})
	else
		client.push(self,'enter_game',{gameid='goldenflower',roomid=1})
	end
	while not self.exit do
		skynet.sleep(100)
	end
end

local function ddz(self)
	if self.game then
		client.push(self,'enter_game',{gameid=self.game.gameid,roomid=self.game.roomid,deskid=self.game.deskid})
	else
		client.push(self,'enter_game',{gameid='ddz',roomid=1,deskid=1})
	end
	while not self.exit do
		skynet.sleep(100)
	end
end

function H:game_entered(msg)
	log:warn("%s 进入游戏 %s 成功，状态=%d",self.rname,msg.gameid,msg.status)
end

local function run(self)
	math.randomseed(skynet.time())
	local f = mods[mod]
	if f then
		log("start mod %s", mod)
		skynet.fork(function()
			pcall(f,self, mod)
		end)
	end
end

mods["login"] = login
mods["relogin"] = relogin
mods["save"] = save
mods["bull"] = bull
require 'robot.bull'
mods["cattle"] = cattle
require 'robot.cattle'
mods["mary"] = laba
require 'robot.mary'
mods["fruit"] = laba
require 'robot.fruit'
mods["baccarat"] = baccarat
require 'robot.baccarat'
mods["sesx"] = laba
require 'robot.sesx'
mods["hcll"] = laba
require 'robot.hcll'
mods["mlhg"] = laba
require 'robot.mlhg'
mods["yxdc"] = laba
require 'robot.yxdc'
mods["dszb"] = laba
require 'robot.dszb'
mods["xhxm"] = laba
require 'robot.xhxm'
mods["goldenflower"] = goldenflower
require 'robot.goldenflower'
mods["ddz"] = ddz
require 'robot.ddz'
------------------------------------------------------------------------
----------------------------	消息处理	----------------------------
------------------------------------------------------------------------

local function signin(self,token)
	local userid='robot'..tostring(id)
	local msg=assert(client.request(self,300,'signin',{
		channel=0,
		token=token,
		username="a8"..userid,
		password=md5.sumhexa("a8"..userid)
	}))
	log('signin %d',msg.e)
	self.login = msg
end

function H:verify(msg)
	signin(self, msg.token)
end

function H:player_obj(msg)
	self.rid = msg.rid
	self.rname = msg.rname
	self.game = msg.game
	self.gold = msg.gold
	self.modify = msg.modify
	log:debug("%s(%d) in game",self.rname,self.rid)
	if self.game then
		log:warn("%s is in %s",self.rname,self.game.gameid)
	end
	skynet.sleep(50)
	run(self)
end

function H:player_gold(msg)
	for _,v in ipairs(msg.info) do
		if self.rid == v.rid then
			log:debug("玩家金币刷新")
			log:debug("rid(%s) gold=%s", v.rid, v.gold)
			self.gold = v.gold
		end
	end
end

local function login_loop()
	log('login_loop start %d',id)
	local fd
	skynet.sleep(100)
	if not fd then
		fd=assert(socket.open(host,port),host,port)
	end
	if not fd then
		return login_loop()
	end
	log('login_loop open fd %d',fd)
	local self={fd=fd}
	skynet.fork(function()
		local ok,err=xpcall(client.dispatch,debug.traceback,self)
		if not ok then
			log(err)
		end
	end)

	log("login_loop fd %d",fd)
	while not self.login do
		skynet.sleep(100)
	end

	local msg=self.login
	if msg.e~=0 then
		socket.close(fd)
		return login_loop()
	end
	socket.close(fd)
	return msg.uid,msg.auth,msg.token,msg.servers
end

local function createrole(self,uid)
	local msg=assert(client.request(self,500,'create_role',{
		rname="robot_"..uid,
		job=math.random(1,3),
	}))
	return msg
end

local function login(self)
	assert(roles[1])
	local msg=assert(client.request(self,1000,'login',{rid=roles[1].rid}))
	local e=msg.e
	if e~=0 then
		log("login failure %d(%s)",e,msg.m)
	end
	-- run(self)
	return e
end

local function game_auth(self,uid,auth,token)
	local ti=math.random(1000000000,9999999999)
	local msg=assert(client.request(self,500,'game_auth',{
		ti=ti,
		token=md5.sumhexa(token..ti),
		auth=auth,
		uid=uid,
		sid=0,
	}))
	local e=msg.e
	roles = msg.roles
	if e==0 then
		if not roles[1] then	-- recv role_list message
			log("not role plz createrole")
			local e=createrole(self,uid).e
			if e==0 then
				log("createrole ok")
			end
			return e
		end
	else
		log:error("game_auth failure(%d)",e)
	end
	return e
end

local function game_loop(uid,auth,token,serverinfo)
	log('game_loop start %d',id)
	local fd
	skynet.sleep(100)
	if not fd then
		fd=assert(socket.open(serverinfo.ip,serverinfo.port))
	end
	if not fd then
		return
	end
	log('game_loop open fd %d',fd)
	local self=setmetatable({fd=fd},{__gc=function(t)
		if socket.invalid(fd) then
	 		socket.close(fd)
		end
	end})
	skynet.fork(function()
		local ok,err=pcall(client.dispatch,self)
		if not ok then
			log(err)
		end
	end)
	if game_auth(self,uid,auth,token)~=0 then
		return
	end
	log("game_auth fd %d",fd)
	if login(self)~=0 then
		return
	end
	log("game_loop %d",fd)
	log("ping start")
	while not self.exit do
		skynet.sleep(100)
		client.push(self,'ping',{})
	end
	socket.close(fd)
end

local function loop()
	while true do
		local ok,uid,auth,token,serverinfo=xpcall(login_loop,debug.traceback)
		if not ok then
			log("login error(%s)",uid)
		else
			local ok,err=xpcall(game_loop,debug.traceback,uid,auth,token,serverinfo)
			if not ok then
				log("game error(%s)",err)
			end
		end
	end
end


service.init{
	command=CMD,
	require ={},
	init=function()
		client.init('*.s2c','*.c2s')
		skynet.fork(loop)
	end
}
