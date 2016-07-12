local player_proto = {}
player_proto.player_info = [[
.Skill {
    id : integer
    level : integer
}
.Base {
  hp : integer
  level : integer
  skillList : *Skill
}
]]

return player_proto
