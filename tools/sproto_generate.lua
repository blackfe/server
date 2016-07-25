local sprotoparser = require "sprotoparser"

local file_list = {
"game_proto",
"login_proto",
"player_info_proto"
}

local types = ""
local protocol = ""

for i,v in ipairs(file_list) do
	local file_proto = require(v)
	if file_proto.type then
		types = types .. file_proto.type
	end
	if file_proto.s2c then
		protocol = protocol .. file_proto.s2c
	end
	
	if file_proto.c2s then
		protocol = protocol .. file_proto.c2s
	end
end
local text = types..protocol
local proto = sprotoparser.parse(text)
sprotoparser.dump(proto)
local data = string.format("local data = \"%s\"\nreturn data",proto)

local f = io.open("sproto_data","w+b")
f:write(data)
f:close()
