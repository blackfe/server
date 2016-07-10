local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"
local CMD = {}
local db_res
local db
local tables = {}
local function dump_db(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local function deal_sql(sql)
    --skynet.error("sql:"..sql)
    db_res = db:query(sql)
    --skynet.error(dump_db(db_res))
    return db_res
end


function CMD.get(tb,cond)
    local sqlStr = "select * from " .. tb .. " where COND;"
    local condStr = ""
    local i = 1
    for k,v in pairs(cond) do
        if i ~= 1 then
            condStr = condStr .. " and "
        end
        i = i + 1
        condStr = condStr .. k .. " = '" .. v .. "' "
    end
    sqlStr = string.gsub(sqlStr,"COND",condStr)
    local data=  deal_sql(sqlStr)
    return data
end

function CMD.add(tb,cond)
    local sqlStr = "insert into " .. tb .. "(COLUMNS) values(VALUES);"
    local colStr = ""
    local valueStr = ""
    local i = 1
    for k,v in pairs(cond) do
        if i ~= 1 then
            colStr = colStr .. ","
            valueStr = valueStr .. ","
        end
        i = i + 1
        colStr = colStr .. k
        if type(v) == "string" then
            valueStr = valueStr .. "'"..v.."'"
        else
            valueStr = valueStr .. v
        end
    end
    sqlStr = string.gsub(sqlStr,"COLUMNS",colStr)
    sqlStr = string.gsub(sqlStr,"VALUES",valueStr)
    deal_sql(sqlStr)
end

function CMD.set(tb,setCond,whereCond)
    local sqlStr = "update " .. tb .. " set VALUES where CONDS;"

    local valueStr = ""
    local condStr = ""

    local i = 1
    for k,v in pairs(setCond) do
        if i ~= 1 then
            valueStr = valueStr .. ","
        end
        i = i + 1
        valueStr = valueStr .. k .. " = "
        if type(v) == "string" then
            valueStr = valueStr .. "'" .. v .. "'"
        else
            valueStr = valueStr .. v
        end
    end

    i = 1
    for k,v in pairs(whereCond) do
        if i ~= 1 then
            condStr = condStr .. " and "
        end

        i = i + 1
        condStr = condStr .. k .. " = "
        if type(v) == "string" then
            condStr = condStr .. "'" .. v .. "'"
        else
            condStr = condStr .. v
        end
    end

    sqlStr = string.gsub(sqlStr,"VALUES",valueStr)
    sqlStr = string.gsub(sqlStr,"CONDS",condStr)
    deal_sql(sqlStr)
end

local function insert_to_server_state(name)
    deal_sql("insert into server_state (servername,count) values('"..name.."',0);")
end

local function create_login_table(name)
    deal_sql("create table " .. name
                 .."(username varchar(255) primary key, password varchar(255), accountID varchar(255),roleInfo mediumblob);")
    insert_to_server_state(name)
end

local function create_game_table(name)
    deal_sql("create table " .. name
                 .."(accountID varchar(255) primary key, ".. "data mediumblob);")
    insert_to_server_state(name)
end

local function create_state_table()
    deal_sql("create table server_state (servername varchar(255) primary key, count integer);")
end


function CMD.register(name)
    res = deal_sql("show tables like '" .. name .. "'")
    if #res == 0 then
        if string.find(name,"login") ~= nil then
            create_login_table(name)
        elseif string.find(name,"game") ~= nil then
            create_game_table(name)
        end
    end
end

skynet.start(function()

	local function on_connect(db)
		db:query("set charset utf8");
    end
    skynet.register("GAMESQL")
    db=mysql.connect({
		host="127.0.0.1",
        port=3306,
		database="skynet",
		user="root",
        password="62544872",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	if not db then
        skynet.error("failed to connect")
	end
    skynet.error("testmysql success to connect to mysql server")

    res = deal_sql("show tables like 'server_state';")
    if #res == 0 then
        create_state_table()
    end

    skynet.dispatch("lua",function(_,_,cmd,...)
                        assert(db)
                        local f = assert(CMD[cmd])
                        skynet.ret(skynet.pack(f(...)))
    end)
    -- multiresultset test
end)
