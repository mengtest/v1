
--[[ method
	value = (base + extra) * (1000 + percent) / 1000
]]

--[[ update
	0 = none  	-- 属性更新不通知客户端
	1 = self  	-- 只通知自己
	2 = around  -- 广播给周围玩家
]]

-- ["name"] = id,update,ismoney
local register={
	-- 1级属性
	["strength"] = {1,1},			-- 力量
	["agility"] = {2,1},			-- 灵巧
	["vitality"] = {3,1},			-- 体质
	["tenacity"] = {4,1},			-- 坚韧
	["intellig"] = {5,1},			-- 念力
	-- 战斗相关属性
	["attack"] = {20,1},			-- 攻击 attack
	["defense"] = {21,1},			-- 防御 defense
	["ignoredefense"] = {22,1},		-- 忽略防御 ignore defense
	["ignoredefenseodds"] = {23,0},	-- 忽略防御率	ignore defense odds
	["parry"] = {24,1},				-- 格挡 parry
	["parryodds"] = {25,1},			-- 格挡率 parry odds
	["ignoreparry"] = {26,1},		-- 破格挡 ignore parry
	["ignoreparryodds"] = {27,0},	-- 破格挡率	ignore parry odds
	["parryreduce"] = {28,1},		-- 格挡减伤 parry reduce
	["hit"] = {29,1},				-- 命中 hit
	["hitodds"] = {30,0},			-- 命中率 hit odds
	["dodge"] = {31,1},				-- 闪避 dodge
	["dodgeodds"] = {32,0},			-- 闪避率 dodge odds
	["hp"] = {33,2},				-- 生命 hp
	["hpmax"] = {34,2},				-- 最大生命 max hp
	["resumehp"] = {35,1},			-- 生命恢复 resume hp
	["damage"] = {36,1},			-- 最终伤害 damage
	["ignoredamage"] = {37,1},		-- 免伤 ignore damage
	["crit"] = {38,1},				-- 暴击值 crit
	["critodds"] = {39,0},			-- 暴击率 crit odds
	["ignorecrit"] = {40,1},		-- 抗暴击值 ignore crit
	["ignorecritodds"] = {41,0},	-- 抗暴击率 ignore crit odds
	["crithurt"] = {42,1},			-- 暴击伤害 crit hurt
	["ignorecrithurt"] = {43,1},	-- 抗暴击伤害 ignore crit hurt
	["skillhurt"] = {44,1},			-- 技能固定伤害 skill hurt
	["hurt"] = {45,1},				-- 固定伤害 hurt
	["ignorehurt"] = {46,1},		-- 固定伤害减免 ignore hurt
	["movespeed"] = {47,2},			-- 移动速度 move speed
	["skillhurtpct"] = {48,0},		-- 技能百分比伤害 skill hurt percent
	["injuredpct"] = {49,0},		-- 受伤增加百分比 injured percent
	["monsterhurt"] = {50,0},		-- 对怪固定伤害增加 monster hurt
	["monsterhurtpct"] = {51,0},	-- 对怪百分比伤害增加 monster hurt percent
	["elitebosshurt"] = {52,0},		-- 对精英和boss固定伤害增加 elite hurt
	["elitebosshurtpct"] = {53,0},	-- 对精英和boss百分比伤害增加 elite hurt percent
	["ignoreheal"] = {54,0},		-- 治疗量消弱 ignore heal
	["ignoremonsterhurt"] = {55,0},	-- 怪物伤害减免 ignore monster hurt
	["shield"] = {56,0},			-- 护盾 shield
	["antihurt"] = {57,0},			-- 反伤 anti hurt
	["job1hurt"] = {58,0},			-- 对游侠增伤
	["job1ignore"] = {59,0},		-- 对游侠免伤
	["job2hurt"] = {60,0},			-- 对战士增伤
	["job2ignore"] = {61,0},		-- 对战士免伤
	["job3hurt"] = {62,0},			-- 对奶妈增伤
	["job3ignore"] = {63,0},		-- 对奶妈免伤
	["finalhurt"] = {64,0},			-- 增伤

	-- 元素属性
	["radiation"] = {100,1},		-- 辐射
	["electric"] = {101,1},			-- 电磁
	["forzen"] = {102,1},			-- 冰冻
	["virus"] = {103,1},			-- 病毒
	["flame"] = {104,1},			-- 火焰
	["radiationadd"] = {105,0},		-- 辐射增伤
	["electricadd"] = {106,0},		-- 电磁增伤
	["forzenadd"] = {107,0},		-- 冰冻增伤
	["virusadd"] = {108,0},			-- 病毒增伤
	["flameadd"] = {109,0},			-- 火焰增伤
	["radiationresist"] = {110,0},	-- 辐射抗性
	["electricresist"] = {111,0},	-- 电磁抗性
	["forzenresist"] = {112,0},		-- 冰冻抗性
	["virusresist"] = {113,0},		-- 病毒抗性
	["flameresist"] = {114,0},		-- 火焰抗性
	["radiationreduce"] = {115,0},	-- 辐射衰弱
	["electricreduce"] = {116,0},	-- 电磁衰弱
	["forzenreduce"] = {117,0},		-- 冰冻衰弱
	["virusreduce"] = {118,0},		-- 病毒衰弱
	["flamereduce"] = {119,0},		-- 火焰衰弱
	--宠物属性
	["petdamage"] = {120,0},		-- 宠物伤害
	["petpercent"] = {121,0},		-- 宠物百分比伤害
	["pethurt"] = {122,0},			-- 宠物增伤
	["pethitodds"] = {123,0},		-- 宠物命中率
	["petcritodds"] = {124,0},		-- 宠物暴击率

	["uavexp"] = {125,0},			-- 无人机每秒怒气值

	-- 战斗无关属性
	["level"] = {200,2},			-- 角色等级
	["abnormal"] = {201,2},			-- 角色异常状态 abnormal state
	["gold"] = {202,1,1},				-- 金币
	["binddiamond"] = {203,1,1},		-- 绑定钻石
	["diamond"] = {204,1,1},			-- 钻石
	["point"] = {205,1},			-- 属性点-废弃
	["equipbreakexp"] = {206,1},	-- 探宝币-废弃
	["enchantmaterial"] = {207,1,1},	-- 精铁
	["exp"] = {208,0},				-- 经验
	["power"] = {209,1},			-- 战斗力
	["status"] = {210,2},			-- 角色状态(0:正常,1:死亡,2:战斗)
	["mount"] = {211,2},			-- 骑乘状态(0:未骑乘,1:骑乘中)
	["ignore"] = {212,1},			-- 免疫异常
 	["genelockcoin"] = {213,1,1},		-- 基因锁货币
	["geniuspoint"] = {214,1,1},		-- 天赋点
	["geniusbule"] = {215,1,1},		-- 天赋蓝金
	["geniuspurple"] = {216,1,1},		-- 天赋紫金
	["pk"] = {217,2},				-- pk值
	["vip"] = {218,2},				-- vip等级
	["vipexp"] = {219,1},			-- vip经验
	["skillcoin"] = {220,1},		-- 技能升级货币-废弃
	["pkstatus"] = {221,2},         -- pk状态 - (0 和平状态 1 pk状态)
	["titleuseid"] = {222,2},		-- 使用称号的id
	["escortflag"] = {223,2}, 	 	-- 运镖劫镖者标记（0：无 1：运镖 2：劫镖）
	["signetexp"] = {224,1}, 		-- 印记经验
	["meritoriousservice"] = {225,1,1}, --功勋
	["nobilityid"] = {226,2,1},		-- 爵位
	["uavchip"] = {228,1,1},			-- 无人机合金
	["gatherstatus"] = {229, 2},    -- 采集状态(0：无 1：采集)
	["offlinerewardtime"] = {230, 1}, 	--离线奖励剩余时间
	["geniusgreen"] = {231,1,1},		-- 天赋绿金
	["chargediamond"] = {232,0,1}, 	-- 充值钻石（增加此数量，会同步增加钻石数量）
	["lotterycoin"] = {233,1,1},		-- 寻宝积分
	["clientsetting"] = {234,2}, 	-- 需要同步的客户端设置
	["expdrug"] = {236,1},			-- 经验药倍率
	--
	["corpscoins"] = {301,1,1}, 		-- 军团币
	["techcoins"] = {302,1,1},		-- 科技币、军团贡献
}

local _M = {}

function _M.init()
	_M.register = register
	_M.attrs_name = {}
	_M.attrs_id = {}
	for name,v in pairs(register) do
		local id = v[1]
		_M.attrs_id[id] = name
		_M.attrs_id[id+1000] = name.."_p"
		_M.attrs_id[id+2000] = name.."_e"
		_M.attrs_id[id+3000] = name.."_b"

		_M.attrs_name[name] = id
		_M.attrs_name[name.."_p"] = id + 1000
		_M.attrs_name[name.."_e"] = id + 2000
		_M.attrs_name[name.."_b"] = id + 3000
	end
end

function _M.get_id(name)
	return _M.attrs_name[name]
end

function _M.get_name(id)
	return _M.attrs_id[id]
end

function _M.is_money(name)
	local d = register[name]
	if d then
		return d[3]
	end
	return nil
end


local skynet = require "skynet"
skynet.init(function()
	_M.init(); 	--require即初始化
end);

return _M
