local lu = require('luaunit')
local mod = require("lua.dependency.inspect_input")

TestSuite = {}

function TestSuite:testInspect()
    lu.assertEquals(mod.do_inspect({ b = 1 }), [[{
  b = 1
}]])
end

-- Run
lu:setVerbosity(1)
lu:set_verbosity(1)
lu:SetVerbosity(1)

local results = lu.run()

os.exit(results)
