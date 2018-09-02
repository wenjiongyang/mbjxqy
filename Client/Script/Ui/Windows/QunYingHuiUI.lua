Require("CommonScript/QunYingHui/QunYingHuiDef.lua")
local tbBattleInfo = Ui:CreateClass("QYHbattleInfo")
local tbDef = QunYingHui.tbDefInfo
local nCalendarID = 11
local nCloseShowTime = 6
function tbBattleInfo:OnOpen(nTime, bHideDmg)
  if self.nTimeTimer then
    Timer:Close(self.nTimeTimer)
    self.nTimeTimer = nil
  end
  if self.nUpdateTimer then
    Timer:Close(self.nUpdateTimer)
    self.nUpdateTimer = nil
  end
  if bHideDmg then
    self.pPanel:SetActive("Container", false)
  else
    self.pPanel:SetActive("Container", true)
  end
  self.pPanel:Label_SetText("Time", Lib:TimeDesc(nTime))
  self.pPanel:Label_SetText("SelfDmgValue", "0")
  self.pPanel:Label_SetText("EnemyDmgValue", "0")
  self.nTimeTimer = Timer:Register(nTime * Env.GAME_FPS, self.OnTotalTime, self)
  self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.OnUpdateTime, self)
  Ui:CloseWindow("QYHAccount")
end
function tbBattleInfo:OnTotalTime()
  self.nTimeTimer = nil
end
function tbBattleInfo:OnUpdateTime()
  self.nUpdateTimer = nil
  if not self.nTimeTimer then
    self.pPanel:Label_SetText("Time", "0")
    return
  end
  local nLastTime = math.floor(Timer:GetRestTime(self.nTimeTimer) / Env.GAME_FPS)
  if nLastTime <= 0 then
    self.pPanel:Label_SetText("Time", "0")
    return
  end
  self.pPanel:Label_SetText("Time", Lib:TimeDesc(nLastTime))
  self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.OnUpdateTime, self)
end
function tbBattleInfo:OnClose()
  if self.nTimeTimer then
    Timer:Close(self.nTimeTimer)
    self.nTimeTimer = nil
  end
  if self.nUpdateTimer then
    Timer:Close(self.nUpdateTimer)
    self.nUpdateTimer = nil
  end
end
function tbBattleInfo:UpdateDmg(tbDmgInfo)
  local nSelfDmg = 0
  local nEnemyDmg = 0
  for nPlayerID, nDmgCount in pairs(tbDmgInfo) do
    if nPlayerID == me.dwID then
      nSelfDmg = nDmgCount
    else
      nEnemyDmg = nDmgCount
    end
  end
  self.pPanel:Label_SetText("SelfDmgValue", tostring(nSelfDmg))
  self.pPanel:Label_SetText("EnemyDmgValue", tostring(nEnemyDmg))
end
function tbBattleInfo:OnLeaveMap()
  Ui:CloseWindow(self.UI_NAME)
end
function tbBattleInfo:OnActiveData()
  local szType, tbData = Player:GetActiveRunTimeData()
  if szType == "QYHbattleInfo" and tbData then
    self:UpdateDmg(tbData)
  end
end
function tbBattleInfo:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_MAP_LEAVE,
      self.OnLeaveMap
    },
    {
      UiNotify.emNOTIFY_ACTIVE_RUNTIME_DATA,
      self.OnActiveData
    }
  }
  return tbRegEvent
end
local tbEntrance = Ui:CreateClass("QYHEntrance")
tbEntrance.tbOnClick = {}
function tbEntrance:OnLoadSetting()
  self.tbJiFenAwardSetting = {}
  local tbFileData = Lib:LoadTabFile("Setting/QunYingHui/WinAward.tab", {JiFen = 1})
  for _, tbInfo in pairs(tbFileData) do
    local tbAllAward = Lib:GetAwardFromString(tbInfo.Awards)
    local tbShowAward = Lib:GetAwardFromString(tbInfo.ExtAward)
    local szShowDesc = tbInfo.ShowExtDesc
    table.insert(self.tbJiFenAwardSetting, {
      nJiFen = tbInfo.JiFen,
      tbAllAward = tbAllAward,
      tbShowAward = tbShowAward,
      szShowDesc = szShowDesc
    })
  end
  table.sort(self.tbJiFenAwardSetting, function(a, b)
    return a.nJiFen < b.nJiFen
  end)
end
tbEntrance:OnLoadSetting()
function tbEntrance:GetPlayerData()
  local nWinCount = me.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveWinCount)
  local nTotalJoin = me.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveTotalJoin)
  local nDayWinCount = me.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveDayWin)
  local nDay = me.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveDayTime)
  local nJiFen = me.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJiFen)
  local nCurDay = Lib:GetLocalDay()
  if nDay ~= nCurDay then
    nDayWinCount = 0
    nJiFen = 0
  end
  return nWinCount, nTotalJoin, nJiFen
end
function tbEntrance:GetPlayerWinRate()
  local nWinCount, nTotalWin = self:GetPlayerData()
  if nTotalWin == 0 then
    return tbDef.fDefWinRate
  end
  return nWinCount / nTotalWin
end
function tbEntrance:OnOpen()
  self:UpdateInfo()
end
function tbEntrance:UpdateInfo()
  local nWinCount, nTotalJoin, nJiFen = self:GetPlayerData()
  local fWinRate = self:GetPlayerWinRate()
  local nWinRate = math.floor(fWinRate * 100)
  local nJoinCount = DegreeCtrl:GetDegree(me, tbDef.szDegreeDay)
  self.pPanel:SetActive("ScoreTittle", true)
  self.pPanel:Label_SetText("QYHJiFen", tostring(nJiFen))
  self.pPanel:Label_SetText("QYHWinRate", string.format("%d%%", nWinRate))
  self.pPanel:Label_SetText("QYHJoinCount", tostring(nJoinCount))
  local bOpen = Calendar:IsActivityInOpenState("QunYingHui")
  if bOpen then
    self.pPanel:Label_SetText("TxtTips", "群英会已开放")
  else
    self.pPanel:Label_SetText("TxtTips", "群英会暂未开放")
  end
  self.pPanel:Label_SetText("GameTime", "周四")
  self.pPanel:Label_SetText("TimeTittle", "开放时间:")
  self.pPanel:Label_SetText("GameDate", "21:00 - 21:25")
  self.pPanel:Label_SetText("DateTittle", "比赛日:")
  self:UpdateScrollView()
end
function tbEntrance:UpdateScrollView()
  self.tbAllShowInfo = {}
  for _, tbInfo in ipairs(self.tbJiFenAwardSetting) do
    local tbShowInfo = {}
    if not Lib:IsEmptyStr(tbInfo.szShowDesc) then
      tbShowInfo.tbAward = tbInfo.tbShowAward[1]
      tbShowInfo.szShowDesc = tbInfo.szShowDesc
      table.insert(self.tbAllShowInfo, tbShowInfo)
    end
    tbShowInfo = {}
    tbShowInfo.tbAward = tbInfo.tbAllAward[1]
    tbShowInfo.szShowDesc = string.format("达到%s积分可得", tbInfo.nJiFen)
    table.insert(self.tbAllShowInfo, tbShowInfo)
  end
  local function fnSetItem(tbItemObj, nIndex)
    local tbCurList = self.tbAllShowInfo[nIndex]
    if not tbCurList then
      return
    end
    tbItemObj.pPanel:Label_SetText("Integral", tbCurList.szShowDesc)
    tbItemObj.itemframe:SetGenericItem(tbCurList.tbAward)
    tbItemObj.itemframe.fnClick = tbItemObj.itemframe.DefaultClick
  end
  local nUpdateCount = #self.tbAllShowInfo
  self.ScrollView:Update(nUpdateCount, fnSetItem)
end
function tbEntrance.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbEntrance.tbOnClick:BtnApplyList()
  if Map:IsFieldFightMap(me.nMapTemplateId) and me.nFightMode == 1 then
    me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
    local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
    AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function()
      Ui:OpenWindow("QYHEntrance")
    end)
    Ui:CloseWindow("QYHEntrance")
    return
  elseif Map:IsHouseMap(me.nMapTemplateId) or me.nMapTemplateId == Kin.Def.nKinMapTemplateId then
    Map:SwitchMap(10)
    return
  end
  RemoteServer.PlayerSignUpQunYingHui()
end
function tbEntrance.tbOnClick:BtnInfo()
  Ui:OnHelpClicked("QYHHelp")
end
function tbEntrance:OnLeaveMap()
  Ui:CloseWindow(self.UI_NAME)
end
function tbEntrance:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_MAP_LEAVE,
      self.OnLeaveMap
    }
  }
  return tbRegEvent
end
local tbAccount = Ui:CreateClass("QYHAccount")
tbAccount.tbOnClick = {}
function tbAccount.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbAccount:OnOpen(nWinId, tbAllShowInfo)
  Ui:CloseWindow("QYHbattleInfo")
  self:CloseTimer()
  self:UpdateInfo(nWinId, tbAllShowInfo)
end
function tbAccount:CloseTimer()
  if self.nOpenTimer then
    Timer:Close(self.nOpenTimer)
    self.nOpenTimer = nil
  end
end
function tbAccount:OnClose()
  self:CloseTimer()
end
function tbAccount:ClearAllInfo()
  local szArryMain = {"My", "Enemy"}
  for _, szMain in pairs(szArryMain) do
    for nI = 0, 2 do
      self.pPanel:Label_SetText(szMain .. "Name" .. nI, "")
      self.pPanel:Label_SetText(szMain .. "FightValue" .. nI, "-")
      self.pPanel:Label_SetText(szMain .. "DmgValue" .. nI, "-")
      self.pPanel:SetActive(szMain .. "Gray" .. nI, true)
      self.pPanel:SetActive(szMain .. nI, false)
    end
  end
end
function tbAccount:CloseSelfWindow()
  Ui:CloseWindow("QYHAccount")
end
function tbAccount:UpdateInfo(nWinId, tbAllShowInfo)
  self:ClearAllInfo()
  self:CloseTimer()
  self.pPanel:SetActive("Victory", false)
  self.pPanel:SetActive("Failure", false)
  if nWinId > 0 then
    if nWinId == me.dwID then
      self.pPanel:SetActive("Victory", true)
    else
      self.pPanel:SetActive("Failure", true)
    end
  else
    self.nTimeTimer = Timer:Register(nCloseShowTime * Env.GAME_FPS, self.CloseSelfWindow, self)
  end
  if not tbAllShowInfo then
    return
  end
  local tbCurAllShowInfo = {}
  for nPlayerID, tbInfo in pairs(tbAllShowInfo) do
    if nPlayerID == me.dwID then
      tbCurAllShowInfo.My = tbInfo
    else
      tbCurAllShowInfo.Enemy = tbInfo
    end
  end
  for szMain, tbInfo in pairs(tbCurAllShowInfo) do
    for nIndex, tbShow in pairs(tbInfo) do
      self.pPanel:SetActive(szMain .. nIndex, true)
      self.pPanel:SetActive(szMain .. "Gray" .. nIndex, false)
      if nIndex == 0 then
        local szHead, szAtlas = PlayerPortrait:GetPortraitBigIcon(tbShow.nPortrait)
        self.pPanel:Sprite_SetSprite(szMain .. "Head" .. nIndex, szHead, szAtlas)
        self.pPanel:Sprite_SetSprite(szMain .. "Faction" .. nIndex, Faction:GetIcon(tbShow.nFaction))
        self.pPanel:Label_SetText(szMain .. "Level" .. nIndex, tostring(tbShow.nLevel))
        local tbHonorInfo = Player.tbHonorLevelSetting[tbShow.nHonorLevel]
        if tbHonorInfo and tbHonorInfo.ImgPrefix then
          self.pPanel:SetActive(szMain .. "Rank" .. nIndex, true)
          self.pPanel:Sprite_Animation(szMain .. "Rank" .. nIndex, tbHonorInfo.ImgPrefix)
        else
          self.pPanel:SetActive(szMain .. "Rank" .. nIndex, false)
        end
      else
        self[szMain .. "Face" .. nIndex]:SetPartnerFace(tbShow.nTemplateID, tbShow.nQualityLevel, tbShow.nLevel, tbShow.nFightValue)
      end
      self.pPanel:Label_SetText(szMain .. "Name" .. nIndex, tbShow.szName)
      self.pPanel:Label_SetText(szMain .. "FightValue" .. nIndex, tbShow.nFightValue)
      self.pPanel:Label_SetText(szMain .. "DmgValue" .. nIndex, tbShow.nTotalDmg)
    end
  end
end
local tbLeftInfo = Ui:CreateClass("QYHLeftInfo")
local ParamType = {
  None = 0,
  Number = 1,
  String = 2,
  Timer = 3,
  Function = 4
}
function tbLeftInfo:QYHJoinCount()
  local nJoinCount = DegreeCtrl:GetDegree(me, tbDef.szDegreeDay)
  return tostring(nJoinCount)
end
function tbLeftInfo:QYHWinRate()
  local tbEntrance = Ui:GetClass("QYHEntrance")
  local fWinRate = tbEntrance:GetPlayerWinRate()
  local nWinRate = math.floor(fWinRate * 100)
  return tostring(nWinRate)
end
function tbLeftInfo:Init()
  if self.tbType then
    return
  end
  tbLeftInfo.tbType = {
    QunYingHui = {
      tbTipsCfg = {
        {
          type = ParamType.Number,
          szTitle = XT("当前场内人数：%s")
        },
        {
          type = ParamType.Function,
          szTitle = XT("今日剩余次数：%s"),
          szFun = "QYHJoinCount"
        },
        {
          type = ParamType.Function,
          szTitle = XT("胜率：%s%%"),
          szFun = "QYHWinRate"
        }
      },
      nAllowMap = tbDef.nPrepareTempMapID
    },
    QunYingHuiEnd = {
      tbTipsCfg = {
        {
          type = ParamType.None,
          szTitle = XT("本次活动已结束")
        }
      },
      nAllowMap = tbDef.nPrepareTempMapID
    },
    Battle = {
      tbTipsCfg = {
        {
          type = ParamType.Timer,
          szTitle = XT("匹配时间：%s")
        },
        {
          type = ParamType.Number,
          szTitle = XT("场内人数：%s")
        }
      },
      tAllowMaps = {
        Battle.READY_MAP_ID,
        Battle.ZONE_READY_MAP_ID
      },
      szHelpTips = "BattleHelp"
    },
    BattleClose = {
      tbTipsCfg = {
        {
          type = ParamType.None,
          szTitle = XT("本次战场活动已结束")
        }
      },
      tAllowMaps = {
        Battle.READY_MAP_ID,
        Battle.ZONE_READY_MAP_ID
      },
      szHelpTips = "BattleHelp"
    },
    BattleMoba = {
      tbTipsCfg = {
        {
          type = ParamType.Timer,
          szTitle = XT("匹配时间：%s")
        },
        {
          type = ParamType.Number,
          szTitle = XT("场内人数：%s")
        }
      },
      tAllowMaps = {
        Battle.READY_MAP_ID,
        Battle.ZONE_READY_MAP_ID
      },
      szHelpTips = "BattleMobaHelp"
    },
    InDifferBattle = {
      tbTipsCfg = {
        {
          type = ParamType.Timer,
          szTitle = XT("匹配时间：%s")
        },
        {
          type = ParamType.Number,
          szTitle = XT("场内人数：%s")
        }
      },
      nAllowMap = InDifferBattle.tbDefine.nReadyMapTemplateId,
      szHelpTips = "InDifferBattleHelp",
      bRight = true
    },
    InDifferBattleClose = {
      tbTipsCfg = {
        {
          type = ParamType.None,
          szTitle = XT(" 本次心魔幻境报名已结束")
        }
      },
      nAllowMap = InDifferBattle.tbDefine.nReadyMapTemplateId,
      szHelpTips = "InDifferBattleHelp",
      bRight = true
    },
    KinBattle = {
      tbTipsCfg = {
        {
          type = ParamType.Number,
          szTitle = XT("一号场人数：%s")
        },
        {
          type = ParamType.Number,
          szTitle = XT("二号场人数：%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("\n开启时间：%s")
        }
      },
      nAllowMap = KinBattle.PRE_MAP_ID
    },
    TeamBattlePre = {
      tbTipsCfg = {
        {
          type = ParamType.Timer,
          szTitle = XT("匹配时间：%s")
        },
        {
          type = ParamType.String,
          szTitle = XT("场内人数：%s")
        }
      },
      nAllowMap = tbDef.nPrepareTempMapID,
      szHelpTips = "TeamBattleHelp",
      bRight = true
    },
    TeamBattleFight = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("正处于：%s")
        },
        {
          type = ParamType.Number,
          szTitle = XT("\n本队总伤害输出：%s")
        },
        {
          type = ParamType.Number,
          szTitle = XT("对方总伤害输出：%s")
        }
      },
      bNotShowLeave = true
    },
    FactionBattlePrepare = {
      tbTipsCfg = {
        {
          type = ParamType.Number,
          szTitle = XT("报名人数：%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("开启时间：%s")
        }
      },
      nAllowMap = FactionBattle.PREPARE_MAP_TAMPLATE_ID,
      szHelpTips = "FactionBattleHelp",
      szType = "FactionBattle"
    },
    FactionBattleFreePK = {
      tbTipsCfg = {
        {
          type = ParamType.Number,
          szTitle = XT("积分：%s")
        },
        {
          type = ParamType.Number,
          szTitle = XT("当前排名：%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("本阶段剩余时间：%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("复活倒计时：%s"),
          nResetTime = FactionBattle.FREEDOM_PK_REVIVE_TIME
        },
        {
          type = ParamType.Number,
          szTitle = XT("当前阶段：%s / 3")
        }
      },
      nAllowMap = FactionBattle.FREEPK_MAP_TAMPLATE_ID,
      bNotShowLeave = true,
      szType = "FactionBattle"
    },
    FactionBattlePrepareElimination = {
      tbTipsCfg = {
        {
          type = ParamType.Timer,
          szTitle = XT("16强赛开启：%s")
        }
      },
      nAllowMap = FactionBattle.PREPARE_MAP_TAMPLATE_ID,
      szHelpTips = "FactionBattleHelp",
      szType = "FactionBattle",
      bShowFactionReport = true
    },
    FactionBattleElimination = {
      tbTipsCfg = {
        {
          type = ParamType.Number,
          szTitle = XT("造成伤害：%s")
        },
        {
          type = ParamType.Number,
          szTitle = XT("受到伤害：%s")
        }
      },
      nAllowMap = FactionBattle.PREPARE_MAP_TAMPLATE_ID,
      bNotShowLeave = true,
      szType = "FactionBattle"
    },
    FactionBattleOut = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("当前阶段：%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("本阶段剩余时间：%s")
        }
      },
      nAllowMap = FactionBattle.PREPARE_MAP_TAMPLATE_ID,
      szHelpTips = "FactionBattleHelp",
      szType = "FactionBattle",
      bShowFactionReport = true
    },
    FactionBattleRest = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("下一阶段：%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("距离下阶段：%s")
        }
      },
      nAllowMap = FactionBattle.PREPARE_MAP_TAMPLATE_ID,
      szHelpTips = "FactionBattleHelp",
      szType = "FactionBattle",
      bShowFactionReport = true
    },
    FactionBattleEnd = {
      tbTipsCfg = {
        {
          type = ParamType.None,
          szTitle = XT("本届门派竞技圆满结束")
        }
      },
      nAllowMap = FactionBattle.PREPARE_MAP_TAMPLATE_ID,
      szHelpTips = "FactionBattleHelp",
      szType = "FactionBattle",
      bShowFactionReport = true
    },
    WhiteTigerFuben = {
      tbTipsCfg = {
        {
          type = ParamType.Timer,
          szTitle = XT("开启时间：%s")
        }
      },
      nAllowMap = Fuben.WhiteTigerFuben.PREPARE_MAPID,
      szHelpTips = "WhiteTigerFubenHelp"
    },
    DomainBattleFire = {
      tbTipsCfg = {
        {
          type = ParamType.None,
          szTitle = XT("攻城战后休整")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("剩余时间：%s"),
          fnFuncOnTimeUp = function()
            Ui:CloseWindow("QYHLeftInfo")
          end
        }
      },
      nAllowMap = Kin.Def.nKinMapTemplateId,
      bRight = true,
      bNotShowLeave = true
    },
    BiWuZhaoQinFirst = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("准备时间：%s")
        },
        {
          type = ParamType.String,
          szTitle = XT("当前状态：%s")
        }
      },
      nAllowMap = BiWuZhaoQin.nPreMapTID,
      bRight = true,
      szType = "BiWuZhaoQin",
      tbLeaveBtn = {"BtnLeave"},
      bNotShowLeave = true
    },
    BiWuZhaoQinFight = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("等待匹配：%s")
        },
        {
          type = ParamType.String,
          szTitle = XT("当前状态：%s")
        }
      },
      nAllowMap = BiWuZhaoQin.nPreMapTID,
      bRight = true,
      szType = "BiWuZhaoQin",
      tbLeaveBtn = {"BtnLeave"},
      bNotShowLeave = true
    },
    BiWuZhaoQinFinal = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("休息时间：%s")
        },
        {
          type = ParamType.String,
          szTitle = XT("当前状态：%s")
        }
      },
      nAllowMap = BiWuZhaoQin.nPreMapTID,
      bRight = true,
      szType = "BiWuZhaoQin",
      tbLeaveBtn = {"BtnLeave", "BtnReport"},
      bNotShowLeave = true
    },
    BiWuZhaoQinAuto = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("战斗阶段：%s")
        },
        {
          type = ParamType.String,
          szTitle = XT("当前状态：%s")
        }
      },
      nAllowMap = BiWuZhaoQin.nPreMapTID,
      bRight = true,
      szType = "BiWuZhaoQin",
      tbLeaveBtn = {"BtnLeave"},
      bNotShowLeave = true
    },
    BiWuZhaoQinAutoFinal = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("%s")
        },
        {
          type = ParamType.Timer,
          szTitle = XT("战斗阶段：%s")
        },
        {
          type = ParamType.String,
          szTitle = XT("当前状态：%s")
        }
      },
      nAllowMap = BiWuZhaoQin.nPreMapTID,
      bRight = true,
      szType = "BiWuZhaoQin",
      tbLeaveBtn = {"BtnLeave", "BtnReport"},
      bNotShowLeave = true
    },
    BiWuZhaoQinEnd = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = XT("%s")
        }
      },
      nAllowMap = BiWuZhaoQin.nPreMapTID,
      bRight = true,
      szType = "BiWuZhaoQin",
      tbLeaveBtn = {"BtnLeave", "BtnReport"},
      bNotShowLeave = true
    },
    LunJianPreMap = {
      tbTipsCfg = {
        {
          type = ParamType.Timer,
          szTitle = XT("匹配时间：%s")
        },
        {
          type = ParamType.String,
          szTitle = XT("比赛场数：%s")
        }
      },
      tAllowMaps = {
        HuaShanLunJian.tbDef.tbPrepareGame.nPrepareMapTID,
        WuLinDaHui.tbDef.tbPrepareGame.nPrepareMapTID
      },
      bRight = true
    },
    LunJianFinalsPlayMap = {
      tbTipsCfg = {
        {
          type = ParamType.Timer,
          szTitle = XT("%s")
        }
      },
      tAllowMaps = {
        HuaShanLunJian.tbDef.tbFinalsGame.nFinalsMapTID,
        WuLinDaHui.tbDef.tbFinalsGame.nFinalsMapTID
      },
      bRight = true
    },
    PeekPlayer = {
      tbTipsCfg = {
        {
          type = ParamType.String,
          szTitle = "远程观战中"
        }
      },
      bRight = true,
      szType = "PeekPlayer",
      tbLeaveBtn = {"BtnLeave"}
    }
  }
end
function tbLeftInfo:GetParamDesc(nParamType, nParamIndex)
  if nParamType == ParamType.Number or nParamType == ParamType.String then
    return tostring(self.tbParam[nParamIndex])
  elseif nParamType == ParamType.Timer then
    local szContent = ""
    if type(self.tbParam[nParamIndex]) == "table" then
      szContent = self.tbParam[nParamIndex][1] or ""
    end
    if self.tbTimerList[nParamIndex] and self.tbTimerList[nParamIndex] > 0 then
      local nLastTime = math.floor(Timer:GetRestTime(self.tbTimerList[nParamIndex]) / Env.GAME_FPS)
      if nLastTime <= 0 then
        nLastTime = 0
      end
      return szContent .. Lib:TimeDesc(nLastTime)
    else
      return szContent .. Lib:TimeDesc(0)
    end
  elseif nParamType == ParamType.Function then
    local tbInfo = self.tbCurInfo.tbTipsCfg[nParamIndex]
    if self[tbInfo.szFun] then
      return self[tbInfo.szFun](self)
    end
  end
  return ""
end
function tbLeftInfo:RefreshContent()
  local szContent = ""
  local nParamIndex = 1
  local bRefreshTimer = false
  for _, cfg in ipairs(self.tbCurInfo.tbTipsCfg) do
    if cfg.type == ParamType.Timer then
      bRefreshTimer = true
      if not self.tbTimerList[nParamIndex] and self.tbParam[nParamIndex] then
        local nCurTimer = 0
        if type(self.tbParam[nParamIndex]) == "table" then
          nCurTimer = self.tbParam[nParamIndex][2] or 0
        else
          nCurTimer = self.tbParam[nParamIndex]
        end
        if nCurTimer > 0 then
          self.tbTimerList[nParamIndex] = Timer:Register(nCurTimer * Env.GAME_FPS, self.TimeUp, self, nParamIndex)
        end
      end
    end
    szContent = string.format(nParamIndex == 1 and "%s%s" or [[
%s
%s]], szContent, string.format(cfg.szTitle, self:GetParamDesc(cfg.type, nParamIndex)))
    nParamIndex = nParamIndex + 1
  end
  self.pPanel:Label_SetText("Content", szContent)
  local contentSize = self.pPanel:Label_GetPrintSize("Content")
  if not self.bgSize or contentSize.x ~= self.bgSize.x or contentSize.y ~= self.bgSize.y then
    self.pPanel:Widget_SetSize("Bg", contentSize.x, contentSize.y + 10)
    self.bgSize = contentSize
  end
  if bRefreshTimer and not self.nUpdateTimer then
    self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.OnUpdateTime, self)
  end
end
function tbLeftInfo:OnOpen(szType, tbParam)
  self:Init()
  self.szType = szType
  self.tbCurInfo = self.tbType[szType]
  if not self.tbCurInfo then
    return 0
  end
  self.pPanel:SetActive("BtnInfo", self.tbCurInfo.szHelpTips and true or false)
  self:CloseTimer()
  self.tbParam = tbParam
  self:SetSide()
  self:RefreshContent()
  self:UpdateLeavePanel()
  self:UpdateReportPanel()
end
function tbLeftInfo:UpdateReportPanel()
  if self.tbCurInfo.bShowFactionReport and FactionBattle:Is16thDataReady() then
    if not Ui:WindowVisible("FactionReportPanel") then
      Ui:OpenWindow("FactionReportPanel")
    end
  else
    Ui:CloseWindow("FactionReportPanel")
  end
end
function tbLeftInfo:UpdateLeavePanel()
  if not self.tbCurInfo.bNotShowLeave then
    if Ui:WindowVisible("QYHLeavePanel") then
      UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, self.tbCurInfo.szType, {"BtnLeave"}, true)
    else
      Ui:OpenWindow("QYHLeavePanel", self.tbCurInfo.szType)
    end
  else
    UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, self.tbCurInfo.szType, {"BtnLeave"}, false)
  end
  if self.tbCurInfo.tbLeaveBtn then
    local tbLeaveBtn = Lib:CopyTB(self.tbCurInfo.tbLeaveBtn)
    if Ui:WindowVisible("QYHLeavePanel") then
      UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, self.tbCurInfo.szType, tbLeaveBtn, true)
    else
      local tbBtn = {}
      for _, szBtn in pairs(tbLeaveBtn) do
        tbBtn[szBtn] = true
      end
      Ui:OpenWindow("QYHLeavePanel", self.tbCurInfo.szType, tbBtn)
    end
  end
end
function tbLeftInfo:SetSide()
  local bRight = self.tbCurInfo.bRight
  local nSide = bRight and Ui.UIAnchor.Side.Right or Ui.UIAnchor.Side.Left
  self.pPanel:Anchor_SetInfo("Main", true, nSide, bRight and -0.22 or 0, 0.42, true, true)
  self.pPanel:ChangeRotate("Bg", 0, bRight and -180 or 0, 0, 0)
  self.pPanel:ChangePosition("BtnInfo", bRight and -140 or 135, bRight and 38 or 48.5, 0)
  self.pPanel:ChangePosition("Content", bRight and -115 or -113, 59, 0)
end
function tbLeftInfo:OnClose()
  self:CloseTimer()
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, self.tbCurInfo.szType, {"BtnLeave"}, false)
end
function tbLeftInfo:TimeUp(nParamIndex)
  local tbCtg = self.tbCurInfo.tbTipsCfg[nParamIndex]
  if tbCtg.fnFuncOnTimeUp then
    tbCtg.fnFuncOnTimeUp()
  end
  local nResetTime = tbCtg.nResetTime
  if not nResetTime then
    self.tbTimerList[nParamIndex] = -1
    return
  end
  self.tbTimerList[nParamIndex] = Timer:Register(nResetTime * Env.GAME_FPS, self.TimeUp, self, nParamIndex)
end
function tbLeftInfo:OnEnterMap(nTemplateMapId)
  if self.tbCurInfo.tAllowMaps then
    local bFind = false
    for i, v in ipairs(self.tbCurInfo.tAllowMaps) do
      if v == nTemplateMapId then
        bFind = true
        break
      end
    end
    if not bFind then
      Ui:CloseWindow(self.UI_NAME)
    end
  end
  if self.tbCurInfo.nAllowMap and nTemplateMapId ~= self.tbCurInfo.nAllowMap then
    Ui:CloseWindow(self.UI_NAME)
  end
end
function tbLeftInfo:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_MAP_ENTER,
      self.OnEnterMap
    },
    {
      UiNotify.emNOTIFY_QYHLEFT_INFO_UPDATE,
      self.UpdateInfo
    },
    {
      UiNotify.emNOTIFY_FACTION_TOP_CHANGE,
      self.UpdateReportPanel
    }
  }
  return tbRegEvent
end
function tbLeftInfo:OnUpdateTime()
  self.nUpdateTimer = nil
  self:RefreshContent()
end
function tbLeftInfo:CloseCounterTimer()
  if self.tbTimerList then
    for _, nTimerId in pairs(self.tbTimerList) do
      if nTimerId > 0 then
        Timer:Close(nTimerId)
      end
    end
  end
  self.tbTimerList = {}
end
function tbLeftInfo:CloseUpdateTimer()
  if self.nUpdateTimer then
    Timer:Close(self.nUpdateTimer)
    self.nUpdateTimer = nil
  end
end
function tbLeftInfo:CloseTimer()
  self:CloseCounterTimer()
  self:CloseUpdateTimer()
end
function tbLeftInfo:UpdateInfo(tbParam, szType)
  if szType and szType ~= self.szType then
    self:CloseTimer()
    self:OnOpen(szType, tbParam)
    return
  end
  for nParamIndex, cfg in pairs(self.tbCurInfo.tbTipsCfg) do
    if tbParam[nParamIndex] then
      self.tbParam[nParamIndex] = tbParam[nParamIndex]
      if cfg.type == ParamType.Timer and self.tbTimerList[nParamIndex] then
        if self.tbTimerList[nParamIndex] > 0 then
          Timer:Close(self.tbTimerList[nParamIndex])
        end
        self.tbTimerList[nParamIndex] = nil
      end
    end
  end
  self:RefreshContent()
  self:UpdateReportPanel()
end
tbLeftInfo.tbOnClick = tbLeftInfo.tbOnClick or {}
function tbLeftInfo.tbOnClick:BtnInfo()
  if not self.tbCurInfo or not self.tbCurInfo.szHelpTips then
    return
  end
  Ui:OnHelpClicked(self.tbCurInfo.szHelpTips)
end
local tbLeaveUI = Ui:CreateClass("QYHLeavePanel")
tbLeaveUI.tbTypePos = {
  Default = {
    BtnLeave = {
      tbPos = {-0.17, 0.31}
    },
    BtnWitnessWar = {
      tbPos = {-0.28, 0.3}
    },
    BtnChallenge = {
      tbPos = {-0.23, 0.18}
    },
    BtnReport = {
      tbPos = {-0.73, 0.26}
    }
  },
  FactionBattle = {
    BtnLeave = {
      tbPos = {-0.15, 0.43}
    }
  },
  ArenaBattle = {
    BtnLeave = {
      tbPos = {-0.17, 0.22}
    },
    BtnWitnessWar = {
      tbPos = {-0.27, 0.18}
    },
    BtnChallenge = {
      tbPos = {-0.28, 0.22}
    }
  },
  HSLJ = {
    BtnLeave = {
      tbPos = {-0.15, 0.29}
    },
    BtnWitnessWar = {
      tbPos = {-0.27, 0.18}
    },
    BtnChallenge = {
      tbPos = {-0.28, 0.22}
    }
  },
  CommonWatch = {
    BtnLeave = {
      tbPos = {-0.15, 0.29}
    },
    BtnWitnessWar = {
      tbPos = {-0.27, 0.18}
    },
    BtnChallenge = {
      tbPos = {-0.28, 0.22}
    }
  },
  ImperialTomb = {
    BtnLeave = {
      tbPos = {-0.25, 0.18}
    }
  },
  ImperialTombBoss = {
    BtnLeave = {
      tbPos = {-0.15, 0.3}
    }
  },
  XinShouFuben = {
    BtnChallenge = {
      tbPos = {-0.13, 0.38}
    }
  },
  BiWuZhaoQin = {
    BtnLeave = {
      tbPos = {-0.17, 0.31}
    },
    BtnWitnessWar = {
      tbPos = {-0.28, 0.3}
    },
    BtnChallenge = {
      tbPos = {-0.23, 0.18}
    },
    BtnReport = {
      tbPos = {-0.25, 0.15}
    }
  },
  PeekPlayer = {
    BtnLeave = {
      tbPos = {-0.15, 0.3}
    }
  }
}
tbLeaveUI.tbBtnTextName = {
  Default = {BtnChallenge = "挑战"},
  XinShouFuben = {BtnChallenge = "跳过"}
}
tbLeaveUI.tbMapCloseCall = {
  ArenaBattle = function()
    RemoteServer.LeaveArenaBattle()
  end,
  ImperialTomb = function()
    ImperialTomb:LeaveRequest()
  end,
  ImperialTombBoss = function()
    ImperialTomb:LeaveRequest()
  end,
  PeekPlayer = function()
    RemoteServer.StopPeek()
  end
}
tbLeaveUI.tbMapWatchCall = {
  FactionBattle = function()
    if not Ui:WindowVisible("WatchMenuPanel") then
      Ui:OpenWindowAtPos("WatchMenuPanel", 250, 30, FactionBattle:GetWatchData())
    end
  end,
  ArenaBattle = function()
    Ui:OpenWindowAtPos("WatchMenuPanel", 265, -40, ArenaBattle:GetWatchData())
  end,
  CommonWatch = function()
    local tbShowData = CommonWatch:GetWatchShowInfo()
    Ui:OpenWindowAtPos("WatchMenuPanel", 250, 30, tbShowData)
  end,
  HSLJ = function()
    if WuLinDaHui:IsInMap(me.nMapTemplateId) then
      RemoteServer.DoRequesWLDH("SyncFinalsWatchData")
    else
      RemoteServer.DoRequesHSLJ("SyncFinalsWatchData")
    end
    local tbShowData = HuaShanLunJian:GetHSLJFinalsWatchTeam()
    Ui:OpenWindowAtPos("WatchMenuPanel", 250, 30, tbShowData, "HSLJTeam")
  end
}
tbLeaveUI.tbMapChallengeCall = {
  ArenaBattle = function()
    Ui:OpenWindow("ChallengerPanel")
  end,
  XinShouFuben = function()
    XinShouLogin:RequestSkipFuben()
  end
}
tbLeaveUI.tbMapReportCall = {
  BiWuZhaoQin = function()
    Ui:OpenWindow("FightTablePanel", "BiWuZhaoQin")
  end
}
tbLeaveUI.tbBtn = {
  BtnLeave = "BtnLeave",
  BtnWitnessWar = "BtnWitnessWar",
  BtnChallenge = "BtnChallenge",
  BtnReport = "BtnReport"
}
tbLeaveUI.tbBtnTeXiao = {BtnChallenge = "texiao"}
function tbLeaveUI:OnOpen(szType, tbBtnType)
  szType = szType or "Default"
  self.szType = szType
  self:UpdateButtonPos()
  if tbBtnType then
    for szType, szBtnName in pairs(self.tbBtn) do
      if tbBtnType[szType] then
        self.pPanel:SetActive(szBtnName, true)
      else
        self.pPanel:SetActive(szBtnName, false)
      end
    end
  else
    for szType, szBtnName in pairs(self.tbBtn) do
      if szBtnName == "BtnLeave" then
        self.pPanel:SetActive(szBtnName, true)
      else
        self.pPanel:SetActive(szBtnName, false)
      end
    end
  end
  local tbBtnTextName = self.tbBtnTextName[szType] or self.tbBtnTextName.Default
  for szBtnName, szTextName in pairs(tbBtnTextName) do
    self.pPanel:Button_SetText(szBtnName, szTextName)
  end
  for szUiName, szTeXiaoName in pairs(self.tbBtnTeXiao) do
    self[szUiName].pPanel:SetActive(szTeXiaoName, false)
  end
end
function tbLeaveUI:UpdateButtonPos()
  for szButtonType, szButtonName in pairs(self.tbBtn) do
    local nBtnX, nBtnY, nPosX, nPosY
    if self.tbTypePos[self.szType] and self.tbTypePos[self.szType][szButtonType] and self.tbTypePos[self.szType][szButtonType].tbPos then
      nBtnX = self.tbTypePos[self.szType][szButtonType].tbPos[1]
      nBtnY = self.tbTypePos[self.szType][szButtonType].tbPos[2]
    end
    local tbPos = self.tbTypePos.Default[szButtonType].tbPos
    nPosX = nBtnX or tbPos[1] or -0.17
    nPosY = nBtnY or tbPos[2] or 0.31
    self.pPanel:Anchor_SetInfo(szButtonName, true, Ui.UIAnchor.Side.Right, nPosX, nPosY, true, true)
  end
end
function tbLeaveUI:SetBtnWitnessWar(szType, bActive)
  self.pPanel:SetActive("BtnWitnessWar", bActive)
  if bActive then
    self.szCallWitnessType = szType
  else
    self.szCallWitnessType = nil
  end
end
tbLeaveUI.tbOnClick = {}
function tbLeaveUI.tbOnClick:BtnLeave()
  if self.szType and self.tbMapCloseCall[self.szType] then
    self.tbMapCloseCall[self.szType]()
    return
  end
  local szMsg = "确定要离开活动？"
  if me.nMapTemplateId == Fuben.WhiteTigerFuben.PREPARE_MAPID then
    szMsg = string.format("确定要离开%s？", Map:GetMapName(Fuben.WhiteTigerFuben.PREPARE_MAPID))
  end
  RemoteServer.PlayerLeaveMap(szMsg)
end
function tbLeaveUI.tbOnClick:BtnWitnessWar()
  local szType = self.szCallWitnessType or self.szType
  if szType and self.tbMapWatchCall[szType] then
    self.tbMapWatchCall[szType]()
  end
end
function tbLeaveUI.tbOnClick:BtnChallenge()
  if self.szType and self.tbMapChallengeCall[self.szType] then
    self.tbMapChallengeCall[self.szType]()
  end
end
function tbLeaveUI.tbOnClick:BtnReport()
  if self.szType and self.tbMapReportCall[self.szType] then
    self.tbMapReportCall[self.szType]()
  end
end
function tbLeaveUI:RefreshBtn(szBattleType, tbType, bShow)
  if not tbType or not next(tbType) then
    return
  end
  self.szType = szBattleType
  self:UpdateButtonPos()
  bShow = bShow or false
  for _, szType in pairs(tbType) do
    if self.tbBtn[szType] then
      self.pPanel:SetActive(self.tbBtn[szType], bShow)
    end
  end
end
function tbLeaveUI:RefreshBtnTeXiao(tbType, bShow)
  if not tbType or not next(tbType) then
    return
  end
  bShow = bShow or false
  for _, szType in pairs(tbType) do
    if self.tbBtn[szType] then
      self[self.tbBtn[szType]].pPanel:SetActive("texiao", bShow)
    end
  end
end
function tbLeaveUI:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_REFRESH_QYH_BTN,
      self.RefreshBtn,
      self
    },
    {
      UiNotify.emNOTIFY_REFRESH_QYH_BTN_TEXIAO,
      self.RefreshBtnTeXiao,
      self
    }
  }
  return tbRegEvent
end
