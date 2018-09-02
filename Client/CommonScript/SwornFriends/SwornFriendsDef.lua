SwornFriends.Def = {
  nMinPlayer = 2,
  nMaxPlayer = 4,
  nMinLevel = 70,
  nMinImitity = 30,
  nTitleHeadMin = 1,
  nTitleHeadMax = 4,
  nTitleTailMin = 1,
  nTitleTailMax = 2,
  nPersonalTitleMin = 1,
  nPersonalTitleMax = 4,
  nConnectItemId = 3368,
  nPersonalTitleItemId = 3370,
  nTitleId = 6501,
  nConnectDistance = 500,
  nCityNpcId = 629,
  nCityMapId = 10,
  nSwornMapId = 10,
  szText1 = "黄天在上，后土在下。我",
  szText2 = "今日义结金兰，此后有福同享，有难同当，同心协力，不离不弃，守望相助，肝胆相照。天地作证，山河为盟，一生坚守，誓不相违！",
  nSwornTextInterval = 0.2,
  nActionWaitTime = 3,
  nConnectActId = 4,
  nConnectSkillDelay = 5,
  tbSkillCastPoint = {17597, 18563},
  tbConnectPos = {
    {17015, 18689},
    {17015, 18416},
    {17114, 18970},
    {17114, 18115}
  },
  nTeamBuffId = 1085,
  nTeamBuffLevel = 1,
  nTeamBuffDuration = 259200,
  nMaxSavePerScriptData = 500
}
if version_vn then
  SwornFriends.Def.nTitleHeadMin = 4
  SwornFriends.Def.nTitleHeadMax = 12
  SwornFriends.Def.nTitleTailMin = 4
  SwornFriends.Def.nTitleTailMax = 8
  SwornFriends.Def.nPersonalTitleMin = 4
  SwornFriends.Def.nPersonalTitleMax = 8
elseif version_th then
  SwornFriends.Def.nTitleHeadMin = 6
  SwornFriends.Def.nTitleHeadMax = 10
  SwornFriends.Def.nTitleTailMin = 3
  SwornFriends.Def.nTitleTailMax = 6
  SwornFriends.Def.nPersonalTitleMin = 6
  SwornFriends.Def.nPersonalTitleMax = 10
end
