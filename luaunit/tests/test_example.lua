local l = require("luaunit")

function test_add_1()
    l.assertEquals(2, (1 + 1))
end

return {
    test_add_1 = test_add_1
}