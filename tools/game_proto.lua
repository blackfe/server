
local game_proto = {}
game_proto.data = [[]] .. require(player_info_proto.data)
game_proto.data = game_proto.data .. [[
.Position {
  x 0 : integer
  y 1 : integer
  z 2 : integer
  o 3 : integer
}

.MoveInfo {
  iAccount 0 : integer
  stPos 1 : Position
}

.ObjectInfo {
    iID 0 : integer
    iType 1 : integer
    sData 2 : string
}

Game_PlayersInfo_SC {
    response {
      stPlayer 0 : *MoveInfo
      stTest 1 : PlayerInfo
    }
}

Game_MyInfo_SC {
    response {
      stPos 0 : Position
    }
}
]]

return game_proto
