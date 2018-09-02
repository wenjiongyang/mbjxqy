Require("CommonScript/Player/PlayerEventRegister.lua")
local SdkMgr = luanet.import_type("SdkInterface")
function PlayerEvent:OnLogin(nIsReconnect)
  self.bLogin = true
  if self.tbMapOnEnterParam then
    Lib:CallBack({
      Map.OnEnter,
      Map,
      unpack(self.tbMapOnEnterParam)
    })
    self.tbMapOnEnterParam = nil
  end
  if nIsReconnect == 0 then
    Lib:CallBack({
      Guide.OnLogin,
      Guide
    })
  end
  Lib:CallBack({
    LoginAwards.OnLogin,
    LoginAwards
  })
  Lib:CallBack({
    Recharge.CheckCanBuyVipAward,
    Recharge
  })
  Lib:CallBack({
    Partner.UpdateRedPoint,
    Partner
  })
  Lib:CallBack({
    Strengthen.OnLogin,
    Strengthen,
    me
  })
  Lib:CallBack({
    Item.GoldEquip.OnLogin,
    Item.GoldEquip,
    me
  })
  Lib:CallBack({
    EverydayTarget.OnLogin,
    EverydayTarget
  })
  Lib:CallBack({
    WelfareActivity.OnLogin,
    WelfareActivity,
    nIsReconnect == 1
  })
  Lib:CallBack({
    MarketStall.OnLogin,
    MarketStall
  })
  Lib:CallBack({
    Player.OnLogin_SafeCall,
    Player,
    nIsReconnect
  })
  Lib:CallBack({
    Compose.ValueCompose.CheckShowRedPoint,
    Compose.ValueCompose
  })
  Lib:CallBack({
    Achievement.CheckRedPoint,
    Achievement
  })
  Lib:CallBack({
    Kin.StartRedPointTimer,
    Kin
  })
  Lib:CallBack({
    OnHook.OnLogin,
    OnHook,
    nIsReconnect == 1
  })
  Lib:CallBack({
    ChuangGong.OnLogin,
    ChuangGong,
    nIsReconnect == 1
  })
  Lib:CallBack({
    Sdk.OnLogin,
    Sdk,
    nIsReconnect == 1
  })
  Lib:CallBack({
    Recharge.OnLogin,
    Recharge
  })
  Lib:CallBack({
    Kin.RedBagOnLogin,
    Kin
  })
  Lib:CallBack({
    NewInformation.OnLogin,
    NewInformation
  })
  Lib:CallBack({
    SeriesFuben.OnLogin,
    SeriesFuben
  })
  Lib:CallBack({
    Kin.OnLogin,
    Kin
  })
  Lib:CallBack({
    Sdk.GsdkInit,
    Sdk
  })
  Lib:CallBack({
    ArenaBattle.OnLogin,
    ArenaBattle
  })
  Lib:CallBack({
    Player.CheckMoneyDebtBuff,
    Player
  })
  Lib:CallBack({
    HuaShanLunJian.RequestHSLJStateInfo,
    HuaShanLunJian,
    true
  })
  SendBless.dwSynRoleId = nil
  Lib:CallBack({
    ChatMgr.ChatDecorate.OnLogin,
    ChatMgr.ChatDecorate,
    nIsReconnect == 1
  })
  Lib:CallBack({
    ChatMgr.OnLogin,
    ChatMgr,
    nIsReconnect == 1
  })
  Lib:CallBack({
    House.OnLogin,
    House,
    nIsReconnect == 1
  })
  Lib:CallBack({
    Wedding.OnLogin,
    Wedding,
    nIsReconnect == 1
  })
  if Ui.nLockScreenState then
    Ui:OpenWindow("LockScreenPanel")
  end
  local nDay = tonumber(os.date("%d", GetTime()))
  if IOS and nDay ~= Client:GetFlag("PAY_WARNNING") and me.nLevel >= 14 then
    Client:SetFlag("PAY_WARNNING", nDay)
    me.Msg("请使用游戏内苹果官方渠道储值，我们将会严厉打击非法储值行为。")
  end
  SdkMgr.ReportDataEnterGame("0", Sdk:GetCurAppId(), tostring(SERVER_ID), Login.szReportRoleList)
  if nIsReconnect == 1 then
    Ui:CloseWindow("QuickUseItem")
    Ui:CloseWindow("FloatingWindowDisplay")
    if 0 >= me.dwKinId then
      Ui:CloseWindow("KinDetailPanel")
    end
    Ui:CloseWindow("ProgressBarPanel")
  end
  local pPlayerNpc = me.GetNpc()
  if pPlayerNpc then
    Lib:CallBack({
      AutoFight.UpdateSkillSetting,
      AutoFight
    })
  end
  Lib:CallBack({
    WeatherMgr.OnLogin,
    WeatherMgr
  })
end
function PlayerEvent:OnSyncOrgServerId(nOrgServerId)
  Env.nOrgServerId = nOrgServerId
end
function PlayerEvent:OnDeath(pKiller)
end
function PlayerEvent:OnShapeShift(nNpcTemplateID, nType)
  if IsAlone() == 1 then
    ActionMode:DoForceNoneActMode(me)
  end
end
function PlayerEvent:OnLevelUp(nNewLevel)
  print("PlayerEvent:OnLevelUp", nNewLevel)
  Guide:OnLevelUp(nNewLevel)
  Partner:UpdateRedPoint()
  ChangeName:CheckShowRedPoint()
  WelfareActivity:OnLevelUp()
  Ui.SoundManager.PlayUISound(8008)
  Player:FlyChar(nNewLevel)
  NewInformation:PushLocalInformation()
  Activity:CheckRedPoint()
  TeamMgr:OnMyInfoChange()
  Recharge:CheckNewLevel()
  Sdk:OnLevelUp()
  TeacherStudent:OnLevelUp()
  ChatMgr.ChatDecorate:ChatDecorateGuide(nNewLevel)
end
function PlayerEvent:StartAutoPath(nDesX, nDesY, nPathLen, nPathSize)
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  if IsAlone() == 0 then
    if not Map:IsForbidRide(me.nMapTemplateId) and nPathLen > AutoRunSpeed.tbDef.nMinRunLen and not House:IsIndoor(me) then
      local pEquip = me.GetEquipByPos(Item.EQUIPPOS_HORSE)
      if pEquip then
        ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_ride)
      end
    end
    local bRet = AutoRunSpeed:CheckCanMapRunSpeed(me, nPathLen)
    if bRet then
      RemoteServer.StartMapAutoRunSpeed(nDesX, nDesY, nPathLen)
      me.bStartAutoRunSpeed = true
    end
  end
  if nPathLen >= 2000 then
    me.bStartAutoPath = true
    Player:UpdateHeadState()
  end
end
function PlayerEvent:StopAutoPath(nStopType)
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  if IsAlone() == 0 then
    local nMapTID = pNpc.nMapTemplateId
    if Map:IsRunSpeedMap(nMapTID) and me.bStartAutoRunSpeed then
      RemoteServer.StopMapAutoRunSpeed()
      me.bStartAutoRunSpeed = false
    end
  end
  me.bStartAutoPath = false
  Player:UpdateHeadState()
end
function PlayerEvent:OnCloseToNpc(nCurNpcId, nCurNpcTemplateId, nLastNpcId)
  if not self.tbCloseToNpc then
    self.tbCloseToNpc = LoadTabFile("Setting/Npc/NearToTips.tab", "d", "nNpcTemplateId", {
      "nNpcTemplateId"
    })
  end
  if nCurNpcId > 0 and not self.tbCloseToNpc[nCurNpcTemplateId] then
    nCurNpcId = 0
    nCurNpcTemplateId = 0
  end
  if nCurNpcId > 0 and Ui:WindowVisible("RoleHeadPop") ~= 1 then
    Ui:OpenWindow("RoleHeadPop", {nCurNpcId}, true)
  else
    UiNotify.OnNotify(UiNotify.emNOTIFY_CLOSE_TO_NCP, nCurNpcId, nLastNpcId)
  end
end
function PlayerEvent:OnChangeFaction(nFactionId, nOldFacionID)
  if Ui:WindowVisible("HomeScreenBattle") == 1 then
    Ui:OpenWindow("HomeScreenBattle")
  end
  if Ui:WindowVisible("RoleHead") == 1 then
    Ui:OpenWindow("RoleHead")
  end
  local tbOrgPos = AutoFight:ClearAutoSetting()
  AutoFight.tbOrgSetting = tbOrgPos
  AutoFight:GetSetting()
  AutoFight.tbOrgSetting = nil
  AutoFight:SaveSetting()
  Log("PlayerEvent OnChangeFaction", nFactionId, nOldFacionID)
end
function PlayerEvent:OnReConnectZoneClient()
  Lib:CallBack({
    Strengthen.OnLogin,
    Strengthen,
    me,
    true
  })
  Lib:CallBack({
    Item.GoldEquip.OnLogin,
    Item.GoldEquip,
    me
  })
  Ui:ChangeFightState(me.nFightMode)
  Ui:GetClass("FloatingWindowDisplay").tbShowQueue = {}
  Ui:CloseWindow("FloatingWindowDisplay")
  Ui:CloseWindow("FightPowerTip")
  ChatMgr.nInitPrivateList = 0
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
end
PlayerEvent:RegisterGlobal("OnLogin", PlayerEvent.OnLogin, PlayerEvent)
PlayerEvent:RegisterGlobal("OnDeath", PlayerEvent.OnDeath, PlayerEvent)
PlayerEvent.nRegisterIdOnLevelUp = PlayerEvent:RegisterGlobal("OnLevelUp", PlayerEvent.OnLevelUp, PlayerEvent)
PlayerEvent:RegisterGlobal("StartAutoPath", PlayerEvent.StartAutoPath, PlayerEvent)
PlayerEvent:RegisterGlobal("StopAutoPath", PlayerEvent.StopAutoPath, PlayerEvent)
PlayerEvent:RegisterGlobal("OnCloseToNpc", PlayerEvent.OnCloseToNpc, PlayerEvent)
PlayerEvent:RegisterGlobal("ShapeShift", PlayerEvent.OnShapeShift, PlayerEvent)
PlayerEvent:RegisterGlobal("OnChangeFaction", PlayerEvent.OnChangeFaction, PlayerEvent)
