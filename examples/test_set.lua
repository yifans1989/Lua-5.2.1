
local Set = require"set"
local getmetable = getmetatable
local print = print

s1 = Set.new{1,2,3,4,5,6}
s2 = Set.new{4,5,6,7,8}
--s2 = {4,5,6,7,8}
print(s1)
print(type(s1))
print(s2)
print(Set.union(s1,s2))
print(s1+s2)
print(Set.intersection(s1,s2))
print((s1+s2)*s1)

print(s1 <= s2)
print(s1 < s2)
print(s1 >= s2)
print(s1 > s2)
print(s1 == s2 *s1)

print(getmetatable(s1))


