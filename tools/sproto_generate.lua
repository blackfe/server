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


function table.serialize(t)  
    local mark={}  
    local assign={}  
  
    local function table2str(t, parent)  
        mark[t] = parent  
        local ret = {}
        if isArray(t) then  
            for i,v in pairs(t) do  
                local k = tostring(i)  
                local dotkey = parent.."["..k.."]"  
                local t = type(v)  
                if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then  
                    --ignore  
                elseif t == "table" then  
                    if mark[v] then  
                        table.insert(assign, dotkey.."="..mark[v])  
                    else  
                        table.insert(ret, table2str(v, dotkey))  
                    end  
                elseif t == "string" then  
                    table.insert(ret, string.format("%q", v))  
                elseif t == "number" then  
                    if v == math.huge then  
                        table.insert(ret, "math.huge")  
                    elseif v == -math.huge then  
                        table.insert(ret, "-math.huge")  
                    else  
                        table.insert(ret,  tostring(v))  
                    end  
                else  
                    table.insert(ret,  tostring(v))  
                end
            end  
        else  
            for f,v in pairs(t) do  
                local k = type(f)=="number" and "["..f.."]" or f  
                if type(f)=="string" then k = "[\""..f.."\"]" end
                local t = type(v)
                if v==nil or type(k)=="table" then --过滤掉key是表，值是空这种属性，如{ {}=nil }
                elseif t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then  
                    --ignore  
                elseif t == "table" then
                    -- mark和assign的目的是用来输出link关系，但是这里加点会导致语法错误
                    -- 比如表 t = { vhehe={1,2}; vxixi=vhehe; } 会输出 {["vhehe"]={1,2}}_.["vxixi"]=_.["vhehe"]
                    -- 正确的输出应该是{["vhehe"]={1,2}}_["vxixi"]=_["vhehe"],“_”后面不加“.”
                    --local dotkey = parent..(type(f)=="number" and k or "."..k)
                    local dotkey = parent..(type(f)=="number" and k or k)
                    if mark[v] then  
                        table.insert(assign, dotkey.."="..mark[v])  
                    else  
                        table.insert(ret, string.format("%s=%s", k, table2str(v, dotkey)))  
                    end  
                elseif t == "string" then  
                    table.insert(ret, string.format("%s=%q", k, v))  
                elseif t == "number" then  
                    if v == math.huge then  
                        table.insert(ret, string.format("%s=%s", k, "math.huge"))  
                    elseif v == -math.huge then  
                        table.insert(ret, string.format("%s=%s", k, "-math.huge"))  
                    else  
                        table.insert(ret, string.format("%s=%s", k, tostring(v)))  
                    end  
                else  
                    table.insert(ret, string.format("%s=%s", k, tostring(v)))  
                end
            end  
        end  
  
        return "{"..table.concat(ret,",").."}"
        --return "{"..table.concat(ret,",\r\n").."}"
    end  
  
    if type(t) == "table" then  
        return string.format("%s%s",  table2str(t,"_"), table.concat(assign," "))  
    else  
        return tostring(t)  
    end  
end  
--反序列化一个Table  
function table.unserialize(str)  
    if str == nil or str == "nil" then  
        return nil  
    elseif type(str) ~= "string" then  
        EMPTY_TABLE = {}  
        return EMPTY_TABLE  
    elseif #str == 0 then  
        EMPTY_TABLE = {}  
        return EMPTY_TABLE  
    end  
  
    local code, ret = pcall(loadstring(string.format("do local _=%s return _ end", str)))  
  
    if code then  
        return ret  
    else  
        EMPTY_TABLE = {}  
        return EMPTY_TABLE  
    end  
end



local f = io.open("sproto_data","w+b")
local newData = table.serialize(proto)
f:write(newData)
f:close()
