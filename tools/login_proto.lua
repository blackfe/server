local login_proto = {}

login_proto.c2s = [[
.ZoneInfo {
    zoneID  : integer
    name  : string
    ip  : string
}

.RoleInfo {
  zoneID  : integer
}

getSecret {
    request {
        clientkey : string
    }

    response {
        challenge  : string
        serverkey  : string
    }
}

verify {
    request {
        hmac  : string
        token  : string
    }
    response {
        result  : integer
        accountID  : integer
        zones  : *ZoneInfo
        roles  : *RoleInfo
    }
}

login  {
    request {
        etoken   : string
    }
    response {
        result  : integer
        token  : string
    }
}
]]

login_proto.s2c =  [[
]]

return login_proto
