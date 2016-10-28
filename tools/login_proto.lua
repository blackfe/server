local sparser = require "sprotoparser"

local login_proto = {}

login_proto.c2s = [[
getSecret 1 {
    request {
        clientkey 0 : string
    }

    response {
        challenge 0 : string
        serverkey 1 : string
    }
}

verify 2 {
    request {
        hmac 0 : string
        token 1 : string
    }
    response {
        result 0 : integer
        accountID 1 : integer
        zones 2 : *ZoneInfo
        roles 3 : *RoleInfo
    }
}

login 3 {
    request {
        etoken 0  : string
    }
    response {
        result 0 : integer
        token 1 : string
    }
}
]]

login_proto.s2c = [[
]]

return login_proto
