local l = require("luaunit")

local r = require("runfiles")
local loaded = r.rlocation("tests/my_example_runfile.txt")

fdokfd()
function test_add_1()
    l.assertEquals(2, (1 + 1))
    l.assertEquals(4, (1 + 1))
end

return {
    test_add_1 = test_add_1
}