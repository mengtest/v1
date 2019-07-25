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

function _M.parse(csv,file)
	local lines = split(csv,'\r\n')
	local headline = lines[1]
	local headtable = parse_row(headline)
	table.remove(lines,1)

	local tb = {}
	for i,row in ipairs(lines) do
		local ct = parse_row(row)
		assert(ct ~= nil,string.format("%s,line:%d,content:[%s]",file,i,row))
		table.insert(tb,ct)
	end
	return tb,headtable
end

return _M
