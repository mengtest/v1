--agent上的全局变量
local _M = {
	level_info = {},	-- 全服等级信息
	add_info = {},		-- 全服加成信息
	openserver_info = {}, 	--开服信息
}

function _M.get_openserver_time()
	return _M.openserver_info.openservertime;
end

function _M.get_openserver_date()
	return _M.openserver_info.openserverdate;
end

function _M.get_openserver_zerotime()
	return _M.openserver_info.openserverzerotime;
end

function _M.get_openserver_days()
	return _M.openserver_info.openserverdays
end

return _M
