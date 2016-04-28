local skynet = require "skynet"
local mysql = require "mysql"
local CMD = {}
local db_res
local db
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

function CMD.add_account(username,password)
    print("CMD.add_account")
    db_res = db:query("select * from players where username = '"..username.."';" )
    print(dump_db(db_res))
    if #db_res > 0 then then
       return nil
    end
    db_res = db:query("insert into players(username,password,info) values('"..username.."','"..password.."',null)")
    print(dump_db(db_res))
    return 1
end

function CMD.get_account_info(username,password)
    print("CMD.get_account")
    db_res = db:query("select * from players where username = '"..username.."';" )
    print(dump_db(db_res))
    if #db_res > 0 then
        if db_res[1].password == password then
            return db_res[1].info
        end

        return nil

    else
        return nil
    end
end

function CMD.set_account_info(username,info)
    --update players set info='begin' where username ='blackfe';
    db_res = db:query("update players set info='"..info.."' where username ='"..username.."';")
    print( dump_db( db_res ) )
end

local function init_tables(db)
    db_res = db:query("create table players "
                       .."(username varchar(255) primary key, ".. "password varchar(255),".."info mediumblob)")
    print( dump_db( db_res ) )

end

skynet.start(function()

	local function on_connect(db)
		db:query("set charset utf8");
	end
    db=mysql.connect({
		host="127.0.0.1",
        port=3306,
		database="skynet",
		user="root",
		password="1",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	if not db then
		print("failed to connect")
	end
	print("testmysql success to connect to mysql server")

    res = db:query("show tables like 'players'")
    print(dump_db(res))
    if #res ==0 then
        init_tables(db)
    end

    skynet.dispatch("lua",function(_,_,cmd,...)
        assert(db)
        local f = assert(CMD[cmd])
        skynet.ret(skynet.pack(f(...)))
    end)
    -- multiresultset test
end)
