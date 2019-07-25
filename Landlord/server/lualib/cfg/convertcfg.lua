local _M = {}
local util = require "util"
local table_insert = table.insert
setmetatable(_M, {__index=function( )
	return function(...) return ... end
end})

function _M.affix(tab)
	local ret = {}
	for i, v in pairs(tab) do
		local ty = v.type
		v.aection = {util.copy(v.aection1),
					util.copy(v.aection2),
					util.copy(v.aection3),
			}
		ret[ty] = ret[ty] or {} 
		table_insert(ret[ty], v)
	end
	return ret
end

function _M.mary_blood(tab)
	local ret = {}
	for k,v in pairs(tab) do
		table.sort( v.roller, function (a,b)
            return a[2]<b[2] 
        end )
        ret[k]=v
	end
	return ret
end

function _M.sesx_blood(tab)
	local ret = {}
	for k,v in pairs(tab) do
		table.sort( v.roller, function (a,b)
            return a[2]<b[2] 
        end )
        ret[k]=v
	end
	return ret
end

function _M.fruit_blood(tab)
	local ret = {}
	for k,v in pairs(tab) do
		table.sort( v.roller, function (a,b)
            return a[2]<b[2] 
        end )
        ret[k]=v
	end
	return ret
end

function _M.hcll_blood(tab)
	local ret = {}
	for k,v in pairs(tab) do
		table.sort( v.roller, function (a,b)
            return a[2]<b[2] 
        end )
        ret[k]=v
	end
	return ret
end

function _M.mlhg_blood(tab)
	local ret = {}
	for k,v in pairs(tab) do
		table.sort( v.roller, function (a,b)
            return a[2]<b[2] 
        end )
        table.sort( v.roller_la, function (a,b)
            return a[2]<b[2] 
        end )
        ret[k]=v
	end
	return ret
end

function _M.yxdc_blood(tab)
	local ret = {}
	for k,v in pairs(tab) do
		table.sort( v.roller, function (a,b)
            return a[2]<b[2] 
        end )
        ret[k]=v
	end
	return ret
end

return _M
