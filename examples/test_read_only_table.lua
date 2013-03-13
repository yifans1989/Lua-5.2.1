-- 
--tests for read only table
-- 
local read_only_t = require "read_only_table"
local print = print
local getmetatable = getmetatable

days, size = read_only_t.read_only_table{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Satureday"}
print(days[1])
print(days[2])
print(days[3])
print(days[4])
print(days[5])
print(days[6])
print(days[7])
print(#days)  --get size of proxy table
print(#getmetatable(days).__index)  --get size of original table 
for i=1, size do print(days[i]) end

--days[2] = "Noday"
getmetatable(days).__index[2] = "Noday" --change original table 
for i=1, #getmetatable(days).__index do print(days[i]) end

str1, size = read_only_t.read_only_table("Sunday")
print(getmetatable(str1).__index)
