local inspect = require("inspect")

_M = {}

_M.do_inspect = function(inspected)
    return inspect(inspected)
end

return _M
