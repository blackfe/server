
local game_proto = {}
game_proto.type = [[
.package {
  type : integer
  session : integer
}

.Position {
  x : integer
  y : integer
  z : integer
  o : integer
}

.MoveInfo {
  account : integer
  pos : Position
}

.ObjectInfo {
    id : integer
    type : integer
    data : string
}
]]

game_proto.c2s = [[
move {
	request {
		pos : Position
	}
	response {
		result : integer
	}
}

playersInfo {
    response {
      player : *MoveInfo
    }
}

myInfo {
    response {
      pos : Position
    }
}
]]

game_proto.s2c = [[
playerMove {
  request {
    player : MoveInfo
  }
}

createObjects {
    request {
        objects : *ObjectInfo
    }
}
]]

return game_proto
