--------------------------------------------------------------------------------
--      Copyright (c) 2015 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
local Mathf = require "mathf"
local sqrt = Mathf.Sqrt
local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget
local clamp = Mathf.Clamp
local acos	= math.acos

local vector2 = {}
-- local get = tolua.initget(vector2)

vector2.__index = function(t,k)
	local var = rawget(vector2, k)
	
	-- if var == nil then							
	-- 	var = rawget(get, k)
		
	-- 	if var ~= nil then
	-- 		return var(t)
	-- 	end
	-- end
	
	return var
end

vector2.__call = function(t, x, y)
	return vector2.New(x, y)
end

function vector2.New(x, y)
	local v = {x = x or 0, y = y or 0}
	setmetatable(v, vector2)	
	return v
end

function vector2:Set(x,y)
	if x==nil then
		self.x=0;
		self.y=0;
		return;
	end
	if(type(x)=="number") then
		self.x=x;
		self.y=y or self.y;
	else
		self.x=x.x or self.x;
		self.y=x.y or self.y;
	end
end

function vector2:Get()
	return self.x, self.y
end

function vector2:SqrMagnitude()
	return self.x * self.x + self.y * self.y
end

function vector2:Clone()
	return vector2.New(self.x, self.y)
end

function vector2:Normalize()
	local v = self:Clone()
	return v:SetNormalize()	
end

function vector2:SetNormalize()
	local num = self:Magnitude()	
	
	if num == 1 then
		return self
    elseif num > 1e-05 then    
        self:Div(num)
    else    
        self:Set(0,0)
	end 

	return self
end

function vector2.Dot(lhs, rhs)
	return lhs.x * rhs.x + lhs.y * rhs.y
end

function vector2.Angle(from, to)
	return acos(clamp(vector2.Dot(from:Normalize(), to:Normalize()), -1, 1)) * 57.29578
end

function vector2.AngleR(from, to)
	return acos(clamp(vector2.Dot(from:Normalize(), to:Normalize()), -1, 1));
end

function vector2.Distance(va, vb)
	return sqrt((va.x - vb.x)*(va.x - vb.x) + (va.y - vb.y)* (va.y - vb.y))
end


function vector2.Magnitude(v2)
	return sqrt(v2.x * v2.x + v2.y * v2.y)
end

function vector2:Div(d)
	self.x = self.x / d
	self.y = self.y / d	
	
	return self
end

function vector2:Mul(d)
	self.x = self.x * d
	self.y = self.y * d
	
	return self
end

function vector2:Add(b)
	self.x = self.x + b.x
	self.y = self.y + b.y
	
	return self
end

function vector2:Sub(b)
	self.x = self.x - b.x
	self.y = self.y - b.y
	
	return
end

vector2.__tostring = function(self)
	return string.format("[%f,%f]", self.x, self.y)
end

vector2.__div = function(va, d)
	return vector2.New(va.x / d, va.y / d)
end

vector2.__mul = function(va, d)
	return vector2.New(va.x * d, va.y * d)
end

vector2.__add = function(va, vb)
	return vector2.New(va.x + vb.x, va.y + vb.y)
end

vector2.__sub = function(va, vb)
	return vector2.New(va.x - vb.x, va.y - vb.y)
end

vector2.__unm = function(va)
	return vector2.New(-va.x, -va.y)
end

vector2.__eq = function(va,vb)
	return va.x == vb.x and va.y == vb.y
end

-- 获得一个向量到另一个向量特定距离的新向量, 移动方向 vt1 → vt2
-- vt1 vt2 	vector2
-- dist 	运动距离
function vector2.Get_Pos(vt1, vt2, dist)
	-- 由两个向量直接计算新向量坐标
	local pos = {}
	local vt3 = vt2 - vt1
	vt3:SetNormalize()
	local new = vt3:Mul(dist):Add(vt1)
	pos.x = math.floor(new.x)
	pos.y = math.floor(new.y)
	-- local dir = vector2.AngleR(vt1, vt2)
	-- pos.dir = math.floor(dir * 100000)
	pos.flag = 0
	return pos
end

-- 获取以vt2为圆心，r为半径，在rand_angle角度内，指向vt1的新的向量
function vector2.Get_Circle_Pos(vt1, vt2, r, angle)
	local vec = vt1 - vt2
	local radian = math.rad(angle)
	local new_x = math.cos(radian) * vec.x - math.sin(radian) * vec.y
	local new_y = math.cos(radian) * vec.y + math.sin(radian) * vec.x
	local new = vector2.New(new_x, new_y)
	new:SetNormalize()
	new = new:Mul(r):Add(vt2)
	return new
end

-- get.up 		= function() return vector2.New(0,1) end
-- get.right	= function() return vector2.New(1,0) end
-- get.zero	= function() return vector2.New(0,0) end
-- get.one		= function() return vector2.New(1,1) end

-- get.magnitude 		= vector2.Magnitude
-- get.normalized 		= vector2.Normalize
-- get.sqrMagnitude 	= vector2.SqrMagnitude

-- UnityEngine.vector2 = vector2
setmetatable(vector2, vector2)
return vector2
