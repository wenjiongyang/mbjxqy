Env.GAME_FPS = 15
Env.LOGIC_MAX_DIR = 64
Env.INT_MAX = 2147483647
Env.Cross_Activity_Open = true
if version_vn then
  Env.Cross_Activity_Open = false
end
Env.LogRound_FAIL = 0
Env.LogRound_SUCCESS = 1
Env.LogRound_DRAW = 2
local tbLogWayDesc = {}
local tbLogWaySet = LoadTabFile("Setting/LogWay.tab", "sds", nil, {
  "WayName",
  "Value",
  "Desc"
})
for i, v in ipairs(tbLogWaySet) do
  Env[v.WayName] = v.Value
  tbLogWayDesc[v.Value] = v.Desc
end
Env.tbLogWayDesc = tbLogWayDesc
