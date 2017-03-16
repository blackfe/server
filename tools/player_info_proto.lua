local player_proto = {}
player_proto.data = [[
.Skill {
    iID  0 : integer
    iLevel 1 : integer
}
.Base {
  iHP  0 : integer
  iLevel 1 : integer
  vSkillList 2 : *Skill
}
]]

return player_proto
