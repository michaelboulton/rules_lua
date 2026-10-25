maths_mod = require("lua.busted_test.maths")

describe("Adding more numbers", function()
    it("Can add 2 to a negative number", function()
        assert.are.equal(1, maths_mod.add_2(-1))
    end)
end)
