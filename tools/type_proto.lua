local type_proto = [[
.package {
	type 0 : integer
	session 1 : integer
}

.ZoneInfo {
    zoneID 0 : integer
    name 1 : string
    ip 2 : string
}

.RoleInfo {
  zoneID 0 : integer
}

.Skill {
    id 0 : integer
    level 1 : integer
}
.Base {
  hp 0 : integer
  level 1 : integer
  skillList 2 : *Skill
}

.Position {
  x 0 : integer
  y 1 : integer
  z 2 : integer
  o 3 : integer
}

.MoveInfo {
  account 0 : integer
  pos 1 : Position
}

.ObjectInfo {
    id 0 : integer
    type 1 : integer
    data 2 : string
}

]]

return type_proto
