-- 
--a module for create read only table
-- 
------------------------------------------------------------------
local error = error
local setmetatble = setmetatable

--module("read_only_table", package.seeall)
module(..., package.seeall)

function read_only_table(t)
  if type(t) ~= "table" then 
    error("'table' expected") 
    return
  end
   
  local proxy = {}
  local mt = {
     __index = t,
     __newindex = function (t, k, v)
       error("attempt to update a read-only table", 2)
     end
   }
  setmetatable(proxy, mt)
  return proxy, #t
end

