local lpeg=require "lpeg"
local skynet = require "skynet"
local uniq = require "uniq.c"
local ext=require "ext.c"

local floor = math.floor

local mathrandom = math.random

--
--[[
--重读时service_uniq失效，需要特殊处理
--]]

local _M={}

_M.split=ext.split_string
_M.split_row=ext.splitrow_string

--utf8字符长度，中文长度也为1
function _M.stringlen(str)
	local _,len = string.gsub(str,"[^\128-\193]","")
	return len
end

function _M.copy(t)
	local r={}
	for k,v in pairs(t) do
		if type(v)=='table' then
			r[k]=_M.copy(v)
		else
			r[k]=v
		end
	end
	return r
end

-- is_search_key 默认为查找value
function _M.find(t, search_val, is_search_key)
	for k,v in pairs(t) do
		if not is_search_key then
			if v == search_val then
				return true
			end
		else
			if k == search_val then
				return true
			end
		end
	end
	return false
end

function _M.ser_function(v)
	local info=debug.getinfo(v)
	local src=info.short_src
	local line=info.linedefined
	return string.format("\"%s\"--[[%s:%d]]",v,src,line)
end

function _M.ser_table(t, flag)
	local mark={}
	local assign={}
	local function _ser(tbl,parent,dep)
		dep=dep or 1
		mark[tbl]=parent
		local tmp={}
		for k,v in pairs(tbl) do
			local key=k
			if type(k)=="number" then
				key="[" ..k.."]"
			elseif tonumber(k) then
				key="[\""..k.."\"]"
			elseif type(k)=="string" then
				key=k
			elseif type(k)=="function" then
				key="[\"".._M.ser_function(k).."\"]"
			else
				key=string.format("[\"%s:%p\"]",k,type(k))
			end
			local space="\n"..string.rep("\t",dep)
			if type(v)=="table" then
				local dotkey=parent.."."..key
				if mark[v] then
					table.insert(assign,dotkey.."="..mark[v])
				else
					table.insert(tmp,space..key.."=".._ser(v,dotkey,dep+1))
				end
			elseif type(v)=="function" then
				table.insert(tmp,space..key.."=".._M.ser_function(v))
			elseif type(v)=="string" then
				table.insert(tmp,space..key.."='"..tostring(v).."'")
			else
				table.insert(tmp,space..key.."="..tostring(v))
			end
		end
		return "{"..table.concat(tmp,",").."\n"..string.rep("\t",dep-1).."}"
	end
	local flag = flag and (" -> "..flag) or ""
	return _ser(t,"r")..flag
end

function _M.dumptable(t)
	return _M.ser_table(t)
end

function _M.dump(o, flag)
	local t=type(o)
	if t=="table" then
		return _M.ser_table(o, flag)
	elseif t=="function" then
		return _M.ser_function(o)
	elseif t=="string" then
		return string.format("\"%s\"",string.gsub(o,"\"","\\\""))
	elseif t=="number" then
		return tostring(o)
	elseif t=="nil" then
		return "nil"
	else
		return string.format("not type:%s",t)
	end
end

function _M.pdump(o, flag)
	print(_M.dump(o, flag))
end

function _M.sdump(o, flag)
	return _M.dump(o, flag)
end

function _M.save(o, fname)
	local f = io.open(fname,"w")
	f:write(_M.dump(o))
	f:close()
end

function _M.exit(...)
	skynet.sleep(50)
	os.exit(1)
end

function _M.tablesize(table)
	local count = 0

	for k,v in pairs(table) do
		count = count + 1
	end

	return count
end

function _M.array_str(array)
	local str
	if array then
		for i, v in ipairs(array or {}) do
			if str then str = str..";" else str = "" end
			str=str..table.concat(v,':')
		end
	else
		str = ""
	end
	return str
end

function _M.str_array(str)
	local array = {}
	local lines = _M.split(str, ";")
	for i, s in ipairs(lines) do
		local t = {}
		for i, v in ipairs(_M.split(s, ":")) do
			t[i] = tonumber(v)
		end
		table.insert(array, t)
	end
	return array
end

--[[
--从array table中随机一个元素
--@param t : 数据源
--@param isdel : 是否从table中删除随机出的元素
--@return : [1]元素值 [2]下标
--]]
function _M.random_table(t, isdel)
	if( #t <= 0) then return nil end
	local randomindex = mathrandom(1, #t);
	if( isdel == true) then
		local val = t[randomindex];
		table.remove(t, randomindex);
		return val, randomindex;
	end
	return t[randomindex], randomindex;
end

--[[
--输入百分率，返回是否命中
--@param per : 0-100
--@return : true:命中 false:未命中
--]]
function _M.random_per(per)
	if( per <= 0) then return false end
	if( per >= 100) then return true end
	local randomindex = mathrandom(1, 100);
	return per >= randomindex;
end

--[[
--输入万分率，返回是否命中
--]]
function _M.random_basispoint(per)
	if( per <= 0) then return false end
	if( per >= 10000) then return true end
	local randomindex = mathrandom(1, 10000);
	return per >= randomindex;
end

--[[
--对table中的元素求和
--]]
function _M.table_sum(t)
	if( not t) then
		return 0;
	end
	local n = 0;
	for k, v in pairs(t) do
		n = n + v;
	end
	return n;
end

function _M.LaBaGetIdByWeight(tab)
    local all = 0
    for k,v in pairs(tab) do
        all = all + v[2]
    end
    local rand_num = math.random(1,all)
    local current = 0
    for key, value in ipairs(tab) do
        if(current < rand_num and rand_num <= (value[2] + current))then
            return value[1]
        else
            current = current + value[2]
        end
    end
end

pdump=_M.pdump
exit=_M.exit

-------------------------------time part-------------------------------

-- @return    time Unix时间戳 * 100
function _M.now()
	return skynet.tick()
end

-- @function  判断2个时间戳是否为同一天
-- @parameter time   Unix时间戳
-- @return    true or false
function _M.same_day(ti1,ti2)
	local t1 = tonumber(os.date("%Y%m%d", ti1))
	local t2 = tonumber(os.date("%Y%m%d", ti2))
	return t1 == t2
end

-- @function  获取当前/指定时间戳的日期
-- @parameter time   Unix时间戳 * 100
-- @return    number 获取当前/指定时间戳日期 eg:20160606
function _M.get_date_from_time(time)
	if not time then
		return tonumber(os.date("%Y%m%d", skynet.time()))
	else
		return tonumber(os.date("%Y%m%d", math.floor(time / 100)))
	end
end

-- @function  获取指定日期[,指定时间]的时间戳
-- @parameter date number eg:19990909
-- @parameter time string eg:h:m:s -> "100901" or h:m -> "1009"[s默认为00]
-- @return    time Unix时间戳 * 100
function _M.get_time_from_date(date, time)
	if type(date) == "string" then
		date = tonumber(date)
	end
	if type(time) == "number" then
		time = tostring(time)
	end
	local y = math.floor(date / 10000)
	local m = math.fmod(math.floor(date / 100), 100)
	local d = math.fmod(date, 100)
	local h = 0
	local m_ = 0
	local s = 0
	if time then
		if string.len(time) == 4 then
			time = time .. "00"
		end
		if string.len(time) == 6 then
			h = math.floor(time / 10000)
			m_ = math.fmod(math.floor(time / 100), 100)
			s = math.fmod(time, 100)
		end
	end
	local r = os.time({year = y, month = m, day = d, hour = h, min = m_, sec = s})
	return r * 100
end

-- @function  获取当前/指定日期的零点的时间戳
-- @parameter number 当前/指定日期 eg:20160606
-- @return    time   Unix时间戳 * 100
function _M.get_zero_time(date)
	if not date then
		local today_date = _M.get_date_from_time()
		date = today_date
	end
	return _M.get_time_from_date(date)
end

-- @function  得到当前/指定时间戳的各时间项
-- @parameter Unix时间戳 * 100
-- @return    tab {年 月 日 时 分 秒 星期(0为星期日，1-6为星期1到星期六)}
function _M.get_date_times(time)
	local date = nil
	if not time then
		date = os.date("*t", skynet.time())
	else
		date = os.date("*t", math.floor(time / 100))
	end
	return {year = date.year, month = date.month, day = date.day,
			hour = date.hour, min = date.min, sec = date.sec,
			wday = date.wday - 1}
end

-- 获取本周一零点时间戳 * 100
function _M.get_monday_zero_time()
	local times = _M.get_date_times()
	local wday = times.wday
	local offset_day
	if wday == 0 then
		offset_day = 6
	else
		offset_day = wday - 1
	end
	return _M.get_zero_time() - offset_day * 86400 * 100
end

-- 获取下周一零点时间戳 * 100
function _M.get_nextmonday_zero_time()
	local times = _M.get_date_times()
	local wday = times.wday
	local offset_day
	if wday == 0 then
		offset_day = 1
	else
		offset_day = 8 - wday
	end
	return _M.get_zero_time() + offset_day * 86400 * 100
end

--[[
--获取当天从0点开始的秒数
--]]
function _M.get_seconds_from_day_zero_time(t)
	local d = _M.get_date_times(t);
	return d.hour * 3600 + d.min * 60 + d.sec;
end

--[[
--]]
function _M.get_time_from_ymd_hms_cfg(d, t)
	if( not t) then
		t = {0,0,0};
	end
	local r = os.time({year = d[1], month = d[2], day = d[3], hour = t[1], min = t[2], sec = t[3]});
	return r * 100;
end

--[[
--从字符串 00:00:00 得到秒数
--@param timestr :
--@return
--]]
function _M.get_seconds_from_hms_str(timestr)
	local t = _M.split(timestr, ":");
	return _M.get_second_from_hms_cfg(t);
end

--[[
--获取从某一天0点的时间到另一天0点的天数
--@param ts1 : 某一天的0点时间戳*100
--@param ts2 : 另一天的0点时间戳*100
--@return : 从某一天开始到另一天的天数，10月1日0点到10月1日2点，返回1天
--]]
function _M.get_days_between_timestamp(ts1, ts2)
	local ts1_zero = _M.get_zero_time(_M.get_date_from_time(ts1))
	local ts2_zero = _M.get_zero_time(_M.get_date_from_time(ts2))
	local day = (ts2_zero - ts1_zero) / 8640000
	if ts2 >= ts2_zero then
		day = day + 1
	end
	return day
end

--[[
--获取从指定0点的时间到当前的天数
--@param zt : 某一天的0点时间戳*100
--@return : 从zt开始到今天的天数，10月1日0点到10月2日0点，返回1天
--]]
function _M.get_days_from_zero_time(zt)
	local now_zero_time = _M.get_zero_time();
	return floor((now_zero_time - zt) / 8640000);
end

--[[
--获取从指定时间到当前时间的天数
--@param t : 时间戳*100
--@return : 从zt开始到今天的天数，10月1日0点到10月2日0点，返回1天
--]]
function _M.get_days_from_time(t)
	local zero_time = _M.get_zero_time(_M.get_date_from_time(t));
	return _M.get_days_from_zero_time(zero_time);
end

--[[
--从配置格式 00|00|00 得到 当前 UTC 时间
--@param cfgtimestr : 形如 {21,59,59} 21点59分59秒
--@return
--]]
function _M.get_time_from_hms_cfg(cfgtimestr)
	local curdaysec = _M.get_second_from_hms_cfg(cfgtimestr);
	local zero = _M.get_zero_time();
	local final = zero / 100 + curdaysec;
	return final;
end

--[[
--从配置格式 得到具体秒数
--@param cfgtimestr : 形如 {01,01,01} 得到 3600+60+1=3661秒
--return
--]]
function _M.get_second_from_hms_cfg(t)
	return t[1] * 3600 + t[2] * 60 + t[3];
end

--得到形如 201322
function _M.get_week_num( t )
	return tonumber( os.date( "%Y%W" , ( t or skynet.time() ) ) );
end

--得到形如 201708
function _M.get_month_num(t)
	return tonumber( os.date( "%Y%m" , ( t or skynet.time() ) ) );
end

--得到形如 [1-31]
function _M.get_days_num(t)
	return tonumber( os.date( "%d" , ( t or skynet.time() ) ) );
end

--[[
--得到指定时间当月最后一天的时间戳
--]]
function _M.get_month_last_date_time(year, month, hour, min)
	local now = skynet.time();
	year = year or os.date("%Y", now);
	month = (month or os.date("%m", now));
	hour = hour or 0;
	min = min or 0;
	return os.time({year=year,month=month+1,day=0,hour=hour,min=min,sec=0});
end

--====================================区域计算 点计算 开始====================================

--[[
--点是否在区域内
--@param point : 点坐标 {x,y}
--@param area : 区域矩形 {lx, ly, rx, ry}
--@return :
--]]
function _M.is_point_in_area(area, point)
	return (area[1] <= point.x and point.x <= area[3] and area[4] <= point.y and point.y <= area[2]);
end

--[[
--角度转弧度
--@param angle : 角度 0~360
--@return : 弧度
--]]
function _M.angle2radian(angle)
	return math.floor(angle % 360 * math.pi / 180 * 100000);
end
--====================================区域计算 点计算 结束====================================

-- 以pairs序，传入有weight字段的表，返回权重随机项
-- t {{weight=xx,}, ...}
function _M.weight_rand_by_weight(t)
	assert(type(t) == "table" , "weight_rand_by_weight error")
	if not next(t) then
		return nil
	end
	local weight = 0
	for _, v in pairs(t) do
		weight = weight + v.weight
	end

	local rand = math.random(0, weight)
	local cur_total = 0
	for _, v in pairs(t) do
		if rand <= v.weight + cur_total then
			return v
		else
			cur_total = cur_total + v.weight
		end
	end
end

-- 以ipairs序，传入权重的idx返回权重随机项
-- t {{[1]=x,[2]=x,[3]=x,[4]=权重}, ...}  eg: idx 4
function _M.weight_rand_by_idx(t, idx)
	assert(type(t) == "table" and idx, "weight_rand_by_idx error")
	if not next(t) then
		return nil
	end
	local total = 0
	local tab = {}
	local check = {}

	local weight = 0
	for i=1,#t do
		local min = total + 1
		local d = t[i]
		if type(d) == "table" and #d >= idx then
			weight = d[idx]
		end
		total = total + weight
		check[i] = {min = min, max = total}
	end
	tab.total = total
	tab.check = check

	local idx = 1
	local rand = math.random(0, tab.total)
	for i,v in ipairs(tab.check) do
		if rand >= v.min and rand <= v.max then
			idx = i
			break
		end
	end
	return t[idx]
end

-- ipairs数组合并到ref_tab中
function _M.array_combine_ref1(ref_tab, ...)
	if not ref_tab or type(ref_tab) ~= "table" then
		return {}
	end
	local tmp = {...}
	for _,v in ipairs(tmp) do
		if type(v) ~= "table" then
			return {}
		end
		for _,v1 in ipairs(v) do
			table.insert(ref_tab, v1)
		end
	end
end

-- ipair序表值 随机排列
function _M.shuffle(t)
	assert(type(t) == "table", "shuffle not table error")
	if not next(t) then
		return t
	end
	local n
	for i=2,#t do
		n = math.random(i)
		t[i], t[n] = t[n], t[i]
	end
	return t
end

--
function _M.get_service_uniq()
	return _M.service_uniq;
end

skynet.init(function()
	_M.service_uniq = uniq.id(1);
end);

return _M
