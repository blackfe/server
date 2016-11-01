local upload_proto = {}
upload_proto.types = [[
.package {
    type 0 : integer
    session 1 : integer
}
]]


upload_proto.c2s = [[
checkUpload 1 {
    request {
        ver 0 : string
        lastZoneID 1 : integer
    }
    response {
        bUpdate 0 : integer
        sURL 1 : string
    }
}
]]

upload_proto.s2c = [[
]]

return upload_proto
