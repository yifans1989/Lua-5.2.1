
local boolean_array = require("boolean_array")
local print = print
local io = io
local string = string

a = boolean_array.new(20)
print(a)
print(boolean_array.size(a))
for i=1, boolean_array.size(a) do
  boolean_array.set(a, i, i/2)
end
--print(boolean_array.get(a,9))
o = io.open("boolean_array.txt", "w")
for i=1, boolean_array.size(a) do
 o:write(string.format("%s\n", boolean_array.get(a, i)))
	print(boolean_array.get(a,i))
end
o:close()

b = boolean_array.new(30)
print(b)
print(a == b)
print(type(b))

-- test false
print(b.size())
print(a.size(a))
boolean_array.set(io.stdin, 1, 30)
boolean_array.set("test", 1, 30)
boolean_array.set(10, 1, 30)
boolean_array.set(nil, 1, 30)

