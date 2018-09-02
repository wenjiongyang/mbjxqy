local tbUi = Ui:CreateClass("DreamlandJoinPanel")
tbUi.szIntro = "介绍：\n·[FFFE0D]3人组队[-]跨服无差别竞技，[FFFE0D]60级[-]及以上侠士可参与\n·幻境中所有侠士固定[FFFE0D]80级、不携带同伴、初始拥有相同的战力水平[-]，门派将在幻境开始后从[FFFE0D]随机6个[-]中选择\n·通过[FFFE0D]开启宝箱、击杀小怪、击杀其他侠士[-]等来获取资源提升能力\n·幻境中每位侠士仅有[FFFE0D]1条命[-]，队友之间的配合尤为重要\n·幻境中共有25个区域，分4个阶段进行，每个阶段结束后会有90秒休整时间并且关闭若干个区域。第4阶段将在最后一个区域进行决战，最终将以[FFFE0D]队伍存活人数、队伍总积分、存活队员总战力[-]判定优胜队伍。\n"
tbUi.tbShowItemList = {
  {
    "Item",
    3469,
    1
  },
  {
    "Item",
    3468,
    1
  },
  {
    "Item",
    3467,
    1
  },
  {
    "Item",
    3494,
    1
  },
  {
    "Item",
    3854,
    1
  },
  {"Contrib", 0}
}
function tbUi:OnOpen()
  self.pPanel:Label_SetText("TipTxtDesc", self.szIntro)
  self.pPanel:Label_SetText("RemainTime", string.format("%d/%d", DegreeCtrl:GetDegree(me, "InDifferBattle"), DegreeCtrl:GetMaxDegree("InDifferBattle", me)))
  self.pPanel:Label_SetText("MatchTxt", self:GetQualifyText())
  local szQulifyType = InDifferBattle:GetCurOpenQualifyType()
  if szQulifyType and InDifferBattle:IsQualifyInBattleType(me, szQulifyType) then
    self.pPanel:SetActive("Mark", true)
    self.pPanel:Label_SetText("MarkTxt", InDifferBattle.tbBattleTypeSetting[szQulifyType].szName .. "赛")
  else
    self.pPanel:SetActive("Mark", false)
  end
  for i = 1, 7 do
    local tbGrid = self["itemframe" .. i]
    local tbInfo = self.tbShowItemList[i]
    if tbInfo then
      tbGrid.pPanel:SetActive("Main", true)
      tbGrid:SetGenericItem(tbInfo)
      tbGrid.fnClick = tbGrid.DefaultClick
    else
      tbGrid.pPanel:SetActive("Main", false)
    end
  end
end
function tbUi:GetQualifyText()
  local tbQualifyList = {}
  for i, v in ipairs(InDifferBattle.tbBattleTypeList) do
    local tbSetting = InDifferBattle.tbBattleTypeSetting[v]
    if tbSetting.szOpenTimeFrame and GetTimeFrameState(tbSetting.szOpenTimeFrame) == 1 and v ~= "Year" then
      table.insert(tbQualifyList, v)
    end
  end
  if #tbQualifyList == 0 then
    return ""
  end
  local str = ""
  local nNow = GetTime()
  local nToday = Lib:GetLocalDay()
  for i, v in ipairs(tbQualifyList) do
    if str ~= "" then
      str = str .. [[


]]
    end
    local tbSetting = InDifferBattle.tbBattleTypeSetting[v]
    str = str .. string.format("[92D2FF]%s赛资格：[-]", tbSetting.szName)
    if InDifferBattle:IsQualifyInBattleType(me, v) then
      str = str .. "[00FF00]已获得[-]\n[92D2FF]比赛时间：[-]"
      local nCurOpenBattleTime = InDifferBattle:GetNextOpenTime(v, nNow - 3600)
      local nMatchDay = Lib:GetLocalDay(nCurOpenBattleTime)
      if nMatchDay == nToday then
        str = string.format("%s今晚%d:%d", str, tbSetting.OpenTimeHour, tbSetting.OpenTimeMinute)
      else
        str = string.format("%s%s[FFFE0D](%d天后)[-]", str, Lib:GetTimeStr3(nCurOpenBattleTime), nMatchDay - nToday)
      end
    else
      str = str .. "[FF0000]未获得[-]\n[92D2FF]获得方式：[-]"
      local szPreType = tbQualifyList[i - 1]
      szPreType = szPreType or "Normal"
      local tbPreSetting = InDifferBattle.tbBattleTypeSetting[szPreType]
      local nNeedGrade = tbSetting.nNeedGrade
      local szGrade = InDifferBattle.tbDefine.tbEvaluationSetting[nNeedGrade].szName
      str = string.format("%s%s心魔幻境获得[FFFE0D]%s[-]以上评价", str, tbPreSetting.szName, szGrade)
    end
  end
  return str
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnSingle()
  if TeamMgr:HasTeam() then
    me.CenterMsg("您当前已经有队伍")
    return
  end
  InDifferBattle:DoSignUp()
end
function tbUi.tbOnClick:BtnTeam()
  if not TeamMgr:HasTeam() then
    me.CenterMsg("您当前没有队伍")
    return
  end
  InDifferBattle:DoSignUp()
end
