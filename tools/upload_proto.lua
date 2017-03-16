local upload_proto = {}
upload_proto.data = [[
Upload_CheckUpload_CS {
    request {
        sVer 0 : string
        iLastZoneID 1 : integer
    }
    response {
        iUpdateType 0 : integer
        sURL 1 : string
    }
}
]]

return upload_proto
