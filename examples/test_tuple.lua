local tuple = require "tuple"

x = tuple.new(0, 100, "hello", 32, 200, {}, 77)
print(x(1))
print(x(2))
print(x(10))
print(x())
print(x(0))
print(x(-3))


