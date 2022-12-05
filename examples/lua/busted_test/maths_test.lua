maths_mod = require("lua.busted_test.maths")

describe("Adding numbers", function()
    it("Can add 2", function()
        assert.are.equal(4, maths_mod.add_2(2))
    end)
end)
