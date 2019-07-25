local lpeg=require "lpeg"
local sep = lpeg.P('/')
local elem = lpeg.C((1 - sep)^1)
local p = sep*(elem*sep)^0*elem^0

local function split(s)
	if s=="/" then return "base" end
	return lpeg.match(p, s)
end

local database={}

local function query(db, key, ...)
	if key == nil then
		return db
	else
		return query(db[key], ...)
	end
end

local select=select
local function update(db, key, value, ...)
	if select("#",...) == 0 then
		local ret = db[key]
		db[key] = value
		return ret, value
	else
		if db[key] == nil then
			db[key] = {}
		end
		return update(db[key], value, ...)
	end
end

local function index(k,...)
	local d = database[k]
	if d then
		return query(d, ...)
	end
end

local mt={}
function mt:__index(k)
	return index(split(k))
end

function mt:__call(k,v)
	return update(database,split(k),v)
end

function mt:__pairs()
	return pairs(database)
end

function mt:__newindex(k,v)
	assert(false)
end

return setmetatable({},mt)