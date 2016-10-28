local game_proto = {}

game_proto.c2s = [[
move 1 {
	request {
		pos 0 : Position
	}
	response {
		result 0 : integer
	}
}

playersInfo 2 {
    response {
      player 0 : *MoveInfo
    }
}

myInfo 3 {
    response {
      pos 0 : Position
    }
}
]]

game_proto.s2c = [[
playerMove 1 {
  request {
    player 0 : MoveInfo
  }
}

createObjects 2 {
    request {
        objects 0: *ObjectInfo
    }
}
]]
return game_proto
