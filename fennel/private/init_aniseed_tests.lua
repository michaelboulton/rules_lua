require("aniseed.fennel")
aniseed_test = require('aniseed.test')
r = aniseed_test["run-all"]()

if (r.tests ~= r["tests-passed"]) then
    error("Tests failed")
end
