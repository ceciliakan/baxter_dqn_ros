local classic = require 'classic'

local MyClass = classic.class("MyClass")

function MyClass:_init(opts)
self.x = opts.x
end

function MyClass:getX()
return self.x
end

local instance_a = MyClass{x = 3}
local instance_b = MyClass{x = 4}
print(instance_a, instance_a:getX())
print(instance_b, instance_b:getX())