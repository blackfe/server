local login_proto = {}
login_proto.data = [[
.ZoneInfo {
    iZoneID 0 : integer
    sName 1 : string
    sIP 2 : string
}

.RoleInfo {
    iZoneID 0 : integer
}

Login_GetSecret_CS {
    request {
        sClientkey 0 : string
    }

    response {
        sChallenge 0 : string
        sServerkey 1 : string
    }
}

Login_Verify_CS {
    request {
        sHmac 0 : string
        sToken 1 : string
    }
    response {
        iResult 0 : integer
        iAccountID 1 : integer
        vZones 2 : *ZoneInfo
        vRoles 3 : *RoleInfo
    }
}

Login_CS {
    request {
        sEtoken 0  : string
    }
    response {
        iResult 0 : integer
        sToken 1 : string
    }
}
]]

return login_proto
