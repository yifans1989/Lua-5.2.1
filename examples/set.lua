-- lua set module extend 
-------------------------------------------- 
module(..., package.seeall)

local getmetatable = getmetatable
local setmetatable = setmetatable
local package = package
local table = table
local error = error
local ipairs = ipairs
local pairs = pairs
local print = print

local Set = {}
local mt = {}

-- pbulic information
Set.VERSION = "0.0.1"

function Set.new(l)
	local set = {}
	setmetatable(set, mt)
	for _, v in ipairs(l) do set[v] = true end
	return set
end

function Set.union(a, b)
	if (getmetatable(a) ~= mt or getmetatable(b) ~= mt) then
		error("attempt to 'add' a set with no-set value", 2)
	end
	local res = Set.new{}
	for k in pairs(a) do res[k] = true end
	for k in pairs(b) do res[k] = true end
	return res
end

function Set.intersection(a, b)
	if (getmetatable(a) ~= mt or getmetatable(b) ~= mt) then
		error("attempt to 'mul' a set with no-set value", 2)
	end
	local res = Set.new{}
	for k in pairs(a) do
		res[k] = b[k]
	end
	return res
end

function Set.tostring(set)
	local l = {}
	for e in pairs(set) do
		l[#l+1] = e
	end
	return "{" .. table.concat(l, ", ") .. "}"
end

function Set.print(s)
	print(Set.tostring(s))
end

mt.__add = Set.union
mt.__mul = Set.intersection
mt.__tostring = Set.tostring
--mt.__metatable = "not allowed"

mt.__le = function(a, b)
	for k in pairs(a) do 
		if not b[k] then return false end
	end
	return true
end

mt.__lt = function(a, b)
	return a <= b and not (b <= a)
end

mt.__eq = function(a, b)
	return a <= b and b <= a
end

return Set

