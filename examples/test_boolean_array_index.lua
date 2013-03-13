-- test cases for boolean_array_obj module 

local boolean_array_index_t = require("boolean_array_index")
local print = print
local io = io
local string = string

a = boolean_array_index_t.new(20)
a[1] = 100
a[2] = 0
--a.set(a,20,1)
print(a)
print(#a)
print(type(a))
for i=1, #a do
  a[i] = i/2;
end
print(a[9])
for i=1, #a do
	print(a[i])
end

b = boolean_array_index_t.new(10)
print(b)
print(a == b)
print(type(b))

-- test false
b:set(io.stdin, 1, 30)
b:set("test", 1, 30)
b:set(10, 1, 30)
b:set(nil, 1, 30)


