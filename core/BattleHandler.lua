require("functions")
local Handler = require("Handler")
local CMD = {}
local BattleHandler = class("BattleHandler",Handler)

function BattleHandler:ctor()
   self:pushMethod(self.cmds,"createObjects")
end

function BattleHandler:createObjects()
end


return BattleHandler
