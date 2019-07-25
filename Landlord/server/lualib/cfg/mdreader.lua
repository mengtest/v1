local lpeg = require "lpeg"
local _M = {}

local function split(s,sep)
	sep = lpeg.P(sep)
  	local elem = lpeg.C((1 - sep)^0)
  	local p = lpeg.Ct(elem * (sep * elem)^0)
  	return lpeg.match(p, s)
end

local _field = '"' * lpeg.Cs(((lpeg.P(1) - '"') + lpeg.P'""' / '"')^0) * '"' + lpeg.C((1 - lpeg.S',\n"')^0)
local _record = _field * (',' * _field)^0 * (lpeg.P'\n' + -1)

local function parse_row(s)
	local pat = lpeg.Ct(_record)
 	return lpeg.match(pat, s)
end

function _M.load(file)
	local fd = assert(io.open(file,"r"))
 	local content = fd:read("*a")
 	return _M.parse(content,file)
end

function _M.parse(md,file)
	local lines = split(md,'\n')
	local headline = lines[1]
	local sizes = parse_row(headline)
	local size = sizes[1] * sizes[2]
	table.remove(lines,1)
	local i = 0
	local tb = {
		w = math.floor(sizes[1]),
		h = math.floor(sizes[2]),
		d = {}
	}
	for _,row in ipairs(lines) do
		local cts = split(row,',')
		for _,ct in ipairs(cts) do
			local d = tonumber(ct)
			if d then
				tb.d[i]=d
				i = i + 1
				if i >= size then
					return tb
				end
			end
		end
	end
	exit("loadmap[ %s ] size = %d,num = %d",file, size, i)
	return nil
end

return _M
