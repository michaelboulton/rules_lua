local l = require("luaunit")

function test_add_1()
    l.assertEquals(2, (1 + 1))
    l.assertEquals(4, (2 + 2))
end

function test_load_runfile()
    local r = require("runfiles")
    local loaded = r.rlocation("tests/my_example_runfile.txt")

    l.assertNotNil(loaded)

    for line in io.lines(loaded)do
        l.assertEquals(line, "Hello")
    end
end

return {
    test_add_1 = test_add_1,
    test_load_runfile = test_load_runfile,
}