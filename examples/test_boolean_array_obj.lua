-- test cases for boolean_array_obj module 

local boolean_array_obj_t = require("boolean_array_obj")
local print = print
local io = io
local string = string

a = boolean_array_obj_t.new(20)
print(a)
print(a.size(a))
print(a:size())
for i=1, a:size() do
  a:set(i, i/2)
end
print(a:get(9))
for i=1, a:size() do
	print(a:get(i))
end

b = boolean_array_obj_t.new(10)
print(b)
print(a == b)
print(type(b))

-- test false
print(b.size())
b:set(io.stdin, 1, 30)
b:set("test", 1, 30)
b:set(10, 1, 30)
b:set(nil, 1, 30)


