local sharedata=require 'skynet.sharedata'
local convertcfg=require 'cfg.convertcfg' 
local log = require 'log'
local mdreader = require 'cfg.mdreader'
local _M={}

--[[
group_load 多个表合成一个表保
[group_name]={"table1","table2","table3"}
]]

local group_load={
	--equip={"equip","item"},
}

local function load_luacfgs(list)
	local r={}
	for _,name in pairs(list) do
		local tmp = string.gsub(name,"%.",'/')
		local f=string.format("cfg/%s.lua",tmp)
		local file=assert(io.open(f))
		local source=file:read("*a")
		file:close()
		log("open file %s",f)
		local fun,err = load(source,'@'..f,"t",{})
		if not fun then
			assert(false, err)
		end
		local t=fun()
		--local t=assert(load(source,'@'..f,"t",{})())
		for k,v in pairs(t) do
			assert(not r[k],string.format("dumplicate key %s.%s",name,k))
			r[k]=v
		end
	end
	return r
end

local function load_cfglist(loadlist)
	local allt={}
	for node,list in pairs(group_load) do
		for _,name in ipairs(list) do
			assert(not allt[name],"cfg must merge less than 2 times")
			allt[name]={node,list}
		end
	end
	local loadt={}
	for _,name in ipairs(loadlist) do
		local grp=allt[name]
		if grp then
			loadt[grp[1]]=load_luacfgs(grp[2])
		else
			loadt[name] = convertcfg[name](load_luacfgs{name})
		end
	end
	return loadt
end

local function set_cfg(method,datas)
	for name,t in pairs(datas) do
		method(name,t)
	end
end

local function get_allloadlist()
	local lfs=require "lfs"
	local loadlist={}
	local function load(rootpath, pre)
		for file in lfs.dir(rootpath) do
			if string.sub(file,1,1) ~= "." then
				local path = rootpath.."/"..file
				local attr = lfs.attributes(path)
				if attr.mode == "directory" then
					load(path, file)
				else
					local pos=string.find(file,".lua$")
					if pos then
						local name=string.sub(file,1,pos-1)
						assert(#name>0)
						if pre then
							table.insert(loadlist,pre.."."..name)
						else
							table.insert(loadlist,name)
						end
					end
				end
			end
		end
	end
	load("cfg")
	return loadlist
end

local function loadmap(method, name)
	local f=string.format("cfg/map/%s.md",name)
	local r = mdreader.load(f)
	method("map_"..name,r)
end

local function loadallmap( method )
	local lfs=require "lfs"
	for file in lfs.dir("cfg/map/") do
		if file ~= "." and file ~= ".." then
			local pos=string.find(file,".md$")
			if pos then
				local name=string.sub(file,1,pos-1)
				loadmap(method,name)
			end			
		end
	end
end

function _M.loadall()
	set_cfg(sharedata.new,load_cfglist(get_allloadlist()))
	-- loadallmap(sharedata.new)
end

function _M.load(name, ...)
	set_cfg(sharedata.new,load_cfglist{name, ...})
end

function _M.reloadmap(name)
	-- loadmap(sharedata.update,name)
end

function _M.reload(name, ...)
	set_cfg(sharedata.update,load_cfglist{name, ...})
end

function _M.reloadall()
	set_cfg(sharedata.update,load_cfglist(get_allloadlist()))
end

function _M.get(name)
	return sharedata.query(name)
end


return _M
