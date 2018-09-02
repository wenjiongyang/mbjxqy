Ui = Ui or {}
Ui.UIAnchor = luanet.import_type("UIAnchor")
Ui.GameObject = luanet.import_type("UnityEngine.GameObject")
Ui.CameraMgr = luanet.import_type("CameraMgr")
Ui.Effect = luanet.import_type("RepresentMgr")
Ui.ToolFunction = luanet.import_type("ToolFunction")
Ui.Screen = luanet.import_type("UnityEngine.Screen")
Ui.ResourceLoader = luanet.import_type("ResourceLoader")
local UiManager = luanet.import_type("UiManager")
Ui.UiManager = UiManager
Ui.SoundManager = luanet.import_type("SoundManager")
local CoreDll = luanet.import_type("CoreInterface.CoreDll")
Ui.CoreDll = CoreDll
local Updater = luanet.import_type("Updater")
Ui.Updater = Updater
local Application = luanet.import_type("UnityEngine.Application")
Ui.Application = Application
Ui.FTDebug = luanet.import_type("FtDebug")
Ui.SceneMgr = Ui.SceneMgr or luanet.import_type("UnityEngine.SceneManagement.SceneManager")
Ui.CoroutineManager = Ui.CoroutineManager or luanet.import_type("CoroutineManager")
local TouchMgr = luanet.import_type("TouchMgr")
local SkillController = luanet.import_type("SkillController")
Ui.LAYER_BG = 1
Ui.LAYER_HOME = 2
Ui.LAYER_NORMAL = 3
Ui.LAYER_PANDORA = 4
Ui.LAYER_EXCLUSIVE = 5
Ui.LAYER_POPUP = 6
Ui.LAYER_GUIDE = 7
Ui.LAYER_INFO = 8
Ui.LAYER_LOADING = 9
Ui.LAYER_DEBUG = 10
Ui.BUTTON_STATE = {
  Normal = 0,
  Hover = 1,
  Pressed = 2,
  Disabled = 3
}
local tbUI_EVENT = {
  "tbOnClick",
  "tbOnSubmit",
  "tbOnDoubleClick",
  "tbOnHover",
  "tbOnPress",
  "tbOnSelect",
  "tbOnScroll",
  "tbOnDrag",
  "tbOnDrop",
  "tbOnKey",
  "tbOnDragEnd",
  "tbOnLongPress",
  "tbUiInputOnChange",
  "tbUiPopupOnChange",
  "tbOnCallBack"
}
Ui.tbQualityRGB = {
  "ffffff",
  "62cc40",
  "2fb7ee",
  "e43eff",
  "fdaf07",
  "d6df3d"
}
Ui.bInitVoiceCfg = false
local tbQuickUseItemClass = {
  "RandomItem",
  "TimeCase",
  "AlphaChargeAward",
  "Speaker",
  "SkillBookExp",
  "FurnitureItem",
  "AddPlayerLevel",
  "WeddingWelcome"
}
local tbMeta = {
  __call = function(self, szUiGroup)
    local tbUi = self.tbUi[szUiGroup]
    if not tbUi then
      print(debug.traceback())
    end
    return tbUi
  end
}
setmetatable(Ui, tbMeta)
function Ui:Init()
  self.tbClass = {}
  self.tbUi = {}
  self.WndState = {}
  self.HyperTextHandle = {}
  self.tbWaitingForOpen = {}
  self.tbNotifyMsgDatas = {}
  self.nUnReadNotifyMsgNum = 0
  self.tbCenterMsg = {}
  self.tbPreLoadUi = {}
end
if not Ui.tbClass then
  Ui:Init()
end
function Ui:CreateClass(szClass)
  self.tbClass[szClass] = self.tbClass[szClass] or {}
  return self.tbClass[szClass]
end
function Ui:GetClass(szClass)
  return self.tbClass[szClass]
end
function Ui:MountUi(szUiName)
  if next(self.tbPreLoadUi) then
    table.insert(self.tbPreLoadUi, szUiName)
    return
  end
  table.insert(self.tbPreLoadUi, szUiName)
  print("UiManager.MountUi", szUiName)
  UiManager.MountUi(szUiName)
end
function Ui:OnLoadUiEnd(szUiName)
  for i = #self.tbPreLoadUi, 0, -1 do
    if szUiName == self.tbPreLoadUi[i] then
      table.remove(self.tbPreLoadUi, i)
    end
  end
  if next(self.tbPreLoadUi) then
    local szNexUi = self.tbPreLoadUi[1]
    UiManager.MountUi(szNexUi)
  else
    Ui:OnPreLoadEmpty()
  end
end
function Ui:OnPreLoadEmpty()
  if self.szPreloadState == "loading" then
    Ui:CloseWindow("MapLoading")
    self.szPreloadState = "end"
  end
end
function Ui:PreloadUiList()
  if not self.szPreloadState then
    self.szPreloadState = "loading"
    local tbPreLoadUi = {
      "MessageBox",
      "RoleHead",
      "ChatSmall",
      "FakeJoyStick",
      "SystemNotice",
      "LoadingTips",
      "TopButton",
      "CreateRole",
      "AchievementPanel",
      "NotifyMsgList",
      "MapLoading",
      "WelfareActivity"
    }
    for _, szUiName in ipairs(tbPreLoadUi) do
      self:PreLoadWindow(szUiName)
    end
  end
end
function Ui:PreLoadWindow(szUiName)
  if self.tbUi[szUiName] then
    return
  end
  Ui:MountUi(szUiName)
end
function Ui:OpenWindow(szUiName, ...)
  local bRet = Ui:IsForbidShowUI(szUiName)
  if bRet then
    return
  end
  return self:OpenWindowAtPos(szUiName, -1, -1, ...)
end
function Ui:OpenWindowAtPos(szUiName, nPosX, nPosY, ...)
  local arg = {
    ...
  }
  self:CheckAndRefreshClass(szUiName)
  local tbWnd = self.tbUi[szUiName]
  if not tbWnd then
    Ui:MountUi(szUiName)
    self.tbWaitingForOpen[szUiName] = {
      nPosX,
      nPosY,
      ...
    }
    return
  end
  self.tbWaitingForOpen[szUiName] = nil
  if self:WindowVisible(szUiName) == 1 then
    self:CloseWindowAni(szUiName, false, unpack(arg))
  end
  local nRetCode = 1
  if not tbWnd then
    print("Ui:OpenWindowAtPos", szUiName)
    return
  end
  if tbWnd.CanOpenWnd and tbWnd:CanOpenWnd() == 0 then
    return
  end
  if tbWnd.OnOpen then
    local bRet, nOpenRetCode = Lib:CallBack({
      tbWnd.OnOpen,
      tbWnd,
      unpack(arg)
    })
    nOpenRetCode = nOpenRetCode or 1
    nRetCode = bRet and nOpenRetCode or 0
    if not bRet then
      print(nOpenRetCode)
      Log(debug.traceback())
    end
  end
  if nRetCode == 1 then
    self.WndState[szUiName] = 1
    UiManager.ShowUi(szUiName, nPosX, nPosY, true)
    if tbWnd.OnOpenEnd then
      local bRet, nOpenRetCode = Lib:CallBack({
        tbWnd.OnOpenEnd,
        tbWnd,
        unpack(arg)
      })
      if not bRet then
        print(nOpenRetCode)
        Log(debug.traceback())
      end
    end
    UiNotify.OnNotify(UiNotify.emNOTIFY_WND_OPENED, szUiName)
  else
    self:CloseWindow(szUiName, unpack(arg))
  end
  if self:IsUiHideVisable(szUiName) then
    tbWnd.pPanel:SetActive("Main", false)
    self.tbHideUi[szUiName] = true
  end
  return nRetCode
end
function Ui:CloseWindow(szUiName, ...)
  Ui:CloseWindowAni(szUiName, true, ...)
end
function Ui:CloseWindowAni(szUiName, bShowCloseAni, ...)
  local arg = {
    ...
  }
  local tbWnd = self.tbUi[szUiName]
  if not tbWnd then
    self.tbWaitingForOpen[szUiName] = nil
    return
  end
  if self:WindowVisible(szUiName) ~= 1 then
    return
  end
  if tbWnd.OnClose then
    local bRet, nCloseRetCode = Lib:CallBack({
      tbWnd.OnClose,
      tbWnd,
      unpack(arg)
    })
    if not bRet then
      print(nCloseRetCode)
      Log(debug.traceback())
    end
  end
  if tbWnd.Init then
    local bRet, nInitRetCode = Lib:CallBack({
      tbWnd.Init,
      tbWnd
    })
    if not bRet then
      print(nInitRetCode)
      Log(debug.traceback())
    end
  end
  self.WndState[szUiName] = nil
  UiManager.HideUi(szUiName, bShowCloseAni)
  UiNotify.OnNotify(UiNotify.emNOTIFY_WND_CLOSED, szUiName)
  Pandora:OnWindowClose(szUiName)
end
function Ui:CloseAllWindow()
  for k, v in pairs(self.WndState) do
    Ui:CloseWindow(k)
  end
  self.tbWaitingForOpen = {}
end
function Ui:CloseBlackBgWindow()
  for szUiName, tb in pairs(self.tbUi) do
    if tb.bBlackBg then
      Ui:CloseWindow(szUiName)
    end
  end
end
function Ui:SwitchWindow(szUiName, ...)
  local arg = {
    ...
  }
  if szUiName == "Commander" and Sdk:IsPCVersion() then
    return
  end
  if self:WindowVisible(szUiName) ~= 1 then
    self:OpenWindow(szUiName, unpack(arg))
  else
    self:CloseWindow(szUiName, unpack(arg))
  end
end
function Ui:WindowVisible(szUiName)
  return self.WndState[szUiName]
end
function Ui:CheckAndRefreshClass(szUiName)
  local tbWnd = self.tbUi[szUiName]
  if tbWnd and tbWnd.szClass and tbWnd._tbBase ~= self.tbClass[tbWnd.szClass] then
    print("Class Reload", tbWnd.UI_NAME, tbWnd.szClass)
    if tbWnd.RegisterEvent then
      local tbReg = tbWnd:RegisterEvent()
      for _, tbEvent in pairs(tbReg) do
        UiNotify:UnRegistNotify(tbEvent[1], tbEvent[3] or tbWnd)
      end
    end
    self:CreateUiLuaObj(tbWnd.pPanel, tbWnd.szClass, tbWnd.UI_NAME)
  end
end
function Ui:CreateUiLuaObj(pObj, szClass, szUiName)
  local tbClass = self.tbClass[szClass]
  local tbWnd
  if not tbClass then
    print("[ERR] UI \"" .. szClass .. "\" Class is not Exist")
    return
  else
    tbWnd = Lib:NewClass(tbClass)
    tbWnd.UI_NAME = szUiName
    tbWnd.szClass = szClass
    self.tbUi[szUiName] = tbWnd
    tbWnd.pPanel = pObj
    tbWnd._ListOfCom = {}
    if tbWnd.OnCreate then
      tbWnd:OnCreate()
    end
    if tbWnd.RegisterEvent then
      local tbReg = tbWnd:RegisterEvent()
      for _, tbEvent in pairs(tbReg) do
        UiNotify:RegistNotify(tbEvent[1], tbEvent[2], tbEvent[3] or tbWnd)
      end
    end
  end
  Ui:OnLoadUiEnd(szUiName)
  return tbWnd
end
function Ui:OnDestroyUi(szUiName)
  if not self.tbUi[szUiName] then
    return
  end
  local tbWnd = self.tbUi[szUiName]
  self.tbUi[szUiName] = nil
  self.WndState[szUiName] = nil
  self:OnDestroyWndCom(tbWnd)
end
function Ui:OnDestroyWndCom(tbWnd)
  if tbWnd.RegisterEvent then
    local tbReg = tbWnd:RegisterEvent()
    for _, tbEvent in pairs(tbReg) do
      UiNotify:UnRegistNotify(tbEvent[1], tbEvent[3] or tbWnd)
    end
  end
  for i, szComName in ipairs(tbWnd._ListOfCom) do
    if tbWnd[szComName] then
      self:OnDestroyWndCom(tbWnd[szComName])
    end
  end
  if tbWnd.OnDestroyUi then
    tbWnd:OnDestroyUi()
  end
end
function Ui:CreateComLua(pObj, tbParent, szSelfName)
  local tbClass = self.tbClass[pObj.UiClass]
  local tbCom
  if not tbClass then
    print("[ERR] " .. (tbParent.UI_NAME or "Unknow Ui") .. " WndCom \"" .. pObj.UiClass .. "\" Class is not Exist!")
    return
  else
    tbCom = Lib:NewClass(tbClass)
    tbCom.pPanel = pObj
    tbCom._ListOfCom = {}
    tbCom.szClass = pObj.UiClass
    tbCom.root = tbParent
    if tbParent then
      tbParent[szSelfName] = tbCom
      table.insert(tbParent._ListOfCom, szSelfName)
    end
    if tbCom.OnCreate then
      tbCom:OnCreate()
    end
  end
  return tbCom
end
function Ui:RegisterEvent(pObj, tbLuaObj)
  for nEventKey, szEvent in pairs(tbUI_EVENT) do
    if tbLuaObj[szEvent] then
      for szWndName, _ in pairs(tbLuaObj[szEvent]) do
        pObj:RegisterEvent(nEventKey, szWndName)
      end
    end
  end
end
function Ui:OnUiLoadEnd(pObj, tbLuaObj)
  Ui:RegisterEvent(pObj, tbLuaObj)
  if self.tbWaitingForOpen[tbLuaObj.UI_NAME] then
    Ui:OpenWindowAtPos(tbLuaObj.UI_NAME, unpack(self.tbWaitingForOpen[tbLuaObj.UI_NAME]))
  end
end
function Ui:OnWndEvent(nEventKey, tbLuaObj, szWnd, ...)
  local szEvent = tbUI_EVENT[nEventKey]
  if not szEvent then
    print("[OnWndEvent] Ui Event unexist!!!", nEventKey)
    return
  end
  if not tbLuaObj or not tbLuaObj[szEvent] then
    print("Ui or Callback Table is unexist", szEvent)
    return
  end
  local fnCallback = tbLuaObj[szEvent][szWnd]
  if not fnCallback then
    return
  end
  fnCallback(tbLuaObj, szWnd, ...)
  Operation:MarkOperate()
end
function Ui:InitGame()
  Ui.tbPlayerHeadMgr:Init()
  Guide:RegisterEvent()
  Ui.Hotkey:Init()
  UiNotify:RegistNotify(UiNotify.emNOTIFY_GAME_INIT_FINISH, self.OnGameInitFinish, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_PLAYER_DATA_END, self.OnEnterGame, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self.OnConnectLost, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_FIGHT_STATE, self.ChangeFightState, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_CONNECT_SERVER, self.OnStartConnectServer, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_CONNECT_SERVER_END, self.OnConnectServerEnd, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_IFLY_IAT_RESULT, self.OnVoice2TxtResult, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self.OnMapLoaded, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnMapEnter, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_PARTNER_ADD, self.OnCompanionShow, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_RECONNECT_FAILED, self.OnReConnectFaild, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_ITEM, self.CheckHasCanQuickUseItem, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_TEAM_UPDATE, self.TeamUpdate, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_DROP_ITEM_TYPE, self.OnDropItemType, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT, self.ChangeAutoFight, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_ADD_SKILL, self.OnAddFightSkill, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_REMOVE_SKILL_STATE, self.OnRemoveSkillState, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_RECORD_BEGIN, self.OnScreenRecordStart, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_RECORD_END, self.OnScreenRecordEnd, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL, TeamMgr.OnLevelChanged, TeamMgr)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_CREATE_ROLE_RESPOND, Sdk.OnRoleCreate, Sdk)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_SHAPE_SHIFT, self.AddShapeShift, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_REMOVE_SHAPE_SHIFT, self.RemoveShapeShift, self)
end
function Ui:AddShapeShift()
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
end
function Ui:RemoveShapeShift()
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
  Timer:Register(1, self.UpdateNpcCurHP, self)
end
function Ui:UpdateNpcCurHP()
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  if pNpc.nCurLife > pNpc.nMaxLife then
    pNpc.RestoreHP()
  end
end
function Ui:ChangeQuickUseOpen(nStart)
  local FloatingWindowDisplay = self:GetClass("FloatingWindowDisplay")
  if nStart == 1 and Ui:WindowVisible("FloatingWindowDisplay") == 1 then
    Ui:CloseWindow("FloatingWindowDisplay")
  end
  if nStart == 0 and 0 < #FloatingWindowDisplay.tbShowQueue then
    local nPop = FloatingWindowDisplay.tbShowQueue[#FloatingWindowDisplay.tbShowQueue]
    if me.GetItemInBag(nPop) then
      Ui:OpenWindow("FloatingWindowDisplay", nPop)
    end
  end
end
function Ui:TeamUpdate(szType)
  if szType == "TeamUpdate" then
    AutoFight:OnUpdateTeamInfo()
  end
end
function Ui:ChangeAutoFight()
  local bAuto = AutoFight:IsAuto()
  if bAuto then
    ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_none)
  end
end
function Ui:OnAddFightSkill(nSkillID, nLevel)
  Lib:CallBack({
    FightSkill.OnAddFightSkill,
    FightSkill,
    nSkillID,
    nLevel
  })
end
function Ui:OnRemoveSkillState(nSkillID)
  Lib:CallBack({
    FightSkill.OnRemoveSkillState,
    FightSkill,
    nSkillID
  })
end
function Ui:OnDropItemType(nType)
  if nType == Item.DROP_OBJ_TYPE_SPE then
    Ui.SoundManager.PlayUISound(8005)
  elseif nType == Item.DROP_OBJ_TYPE_MONEY then
    Ui.SoundManager.PlayUISound(8004)
  elseif nType == Item.DROP_OBJ_TYPE_ITEM then
    Ui.SoundManager.PlayUISound(8006)
  end
end
function Ui:CanQuickItem(szClass)
  for _, szName in pairs(tbQuickUseItemClass) do
    if string.find(szClass, szName) ~= nil then
      return true
    end
  end
  return false
end
function Ui:CheckHasCanQuickUseItem(nItemId, bNew, nNumber)
  if not Login.bEnterGame then
    return
  end
  bNew = bNew and bNew == 1 and true or false
  local pItem = me.GetItemInBag(nItemId)
  if pItem and pItem.nEquipPos and pItem.nEquipPos ~= -1 then
    Item.GoldEquip:UpdateSuitAttri(me)
    Item.GoldEquip:UpdateTrainAttri(me, pItem.nEquipPos)
  end
  local tbEquip = me.GetEquips(1)
  local FloatingWindowDisplay = self:GetClass("FloatingWindowDisplay")
  if nItemId then
    if pItem and pItem.nEquipPos and pItem.nEquipPos ~= -1 and (pItem.nFactionLimit == 0 or pItem.nFactionLimit == me.nFaction) then
      if nNumber <= 0 then
        FloatingWindowDisplay:HaveUse(nItemId)
      elseif not tbEquip[pItem.nEquipPos] and Item:CheckUsable(pItem, pItem.szClass) == 1 and pItem.nPos == Item.EITEMPOS_BAG then
        for nTempy = 1, nNumber do
          table.insert(FloatingWindowDisplay.tbShowQueue, nItemId)
        end
        if self.nFightState == 0 and me.GetItemInBag(nItemId) then
          Ui:OpenWindow("FloatingWindowDisplay", nItemId)
        end
      end
      return
    end
    if Ui:CanQuickItem(pItem.szClass) and (bNew or nNumber ~= 0) then
      if nNumber <= 0 then
        FloatingWindowDisplay:HaveUse(nItemId)
      elseif Item:CheckUsable(pItem, pItem.szClass) == 1 then
        for nTempy = 1, nNumber do
          table.insert(FloatingWindowDisplay.tbShowQueue, nItemId)
        end
        if self.nFightState == 0 and me.GetItemInBag(nItemId) then
          Ui:OpenWindow("FloatingWindowDisplay", nItemId)
        end
      end
      return
    end
  end
end
function Ui:OnCompanionShow(nPartnerId, nIsSync)
  if not Login.bEnterGame or nIsSync == 1 then
    return
  end
  if not self:GetClass("CompanionShow").tbShowCompanion then
    self:GetClass("CompanionShow").tbShowCompanion = {}
  end
  if self:WindowVisible("CardPickingResult") == 1 or self.tbWaitingForOpen.CardPickingResult then
    table.insert(self:GetClass("CompanionShow").tbShowCompanion, nPartnerId)
    return
  end
  table.insert(self:GetClass("CompanionShow").tbShowCompanion, nPartnerId)
  if self:WindowVisible("CompanionShow") ~= 1 then
    Ui:OpenWindow("CompanionShow", self:GetClass("CompanionShow").tbShowCompanion[1], 0)
  end
end
function Ui:CloseCompanion(tbCompanion, nType)
  if #tbCompanion > 0 then
    Ui:OpenWindow("CompanionShow", tbCompanion[1], nType)
  end
end
function Ui:AnormalCloseCompanion()
  self.bNowCompanionShow = false
end
function Ui:OnGameInitFinish()
  Ui.ToolFunction.LoadMap(Login.szSceneMapName, Login.szSceneCameraName, 0, false)
  Ui:UpdateSoundSetting()
  Ui:UpdateDrawLevel()
  Lib:CallBack({
    PreloadResource.SetOnceRecycle,
    PreloadResource,
    true
  })
  Operation:InitGamesir()
  Lib:CallBack({
    FightSkill.InitResetMagicType,
    FightSkill
  })
end
function Ui:ClearSysNotifyCation()
  Log("Ui:ClearSysNotifyCation==============")
  if ANDROID then
    UiManager.CleanNotification(1)
  elseif IOS then
    UiManager.CleanNotification(0)
    UiManager.CleanNotification(0)
  end
end
function Ui:SetSysNotifyCation()
  if not Login.bEnterGame then
    return
  end
  self:ClearSysNotifyCation()
  local tbSysNotiy = Calendar:GetSysNotiyTable()
  local tbMySysNotify = Client:GetUserInfo("MySysNotify", -1)
  local nNowScends = Lib:GetTodaySec()
  for i, v in ipairs(tbSysNotiy) do
    if not tbMySysNotify[v.szKey] and v.tbTimeGroup then
      for i2, nScends in ipairs(v.tbTimeGroup) do
        if v.bRepeat or nScends > nNowScends then
          local nHour = math.floor(nScends / 3600)
          local nMinute = math.floor((nScends - nHour * 3600) / 60)
          UiManager.NotificationMessage(v.szMsg, nHour, nMinute, v.bRepeat, 1)
        end
      end
    end
  end
end
function Ui:OnStartConnectServer()
  Ui:OpenWindow("LoadingTips")
end
function Ui:OnConnectServerEnd(bConnect)
  if bConnect == 0 then
    self:ReConnectFail()
    Log("connect fail !!")
  end
  Ui:CloseWindow("LoadingTips")
  Log("OnConnectServerEnd", bConnect)
end
function Ui:OnEnterGame(bReconnect)
  if not Login.bEnterGame then
    Login.bEnterGame = true
    Login:ClearNpcs()
  end
  self:GetClass("FloatingWindowDisplay").tbShowQueue = {}
  Login:StopSceneSound()
  self:CloseWindow("CreateRole")
  if bReconnect ~= 1 then
    FriendShip:InitBlackList()
    ChatMgr:InitPrivateList()
  end
  self.nFightState = nil
  self:ChangeFightState(me.nFightMode)
  Ui:ClearSysNotifyCation()
  if Ui:WindowVisible("Login") ~= 1 then
    UiManager.DestroyUi("Login")
  end
  if Ui:WindowVisible("LoginBg") ~= 1 then
    UiManager.DestroyUi("LoginBg")
  end
  Operation:ConnectGamesir()
end
function Ui:OnLeaveGame()
  TeamMgr:OnLeaveGame()
  Boss:ClearData()
  FriendShip:InitData()
  MapExplore:ClearData()
  Mail:Clear()
  Kin:ClearCache()
  ChatMgr:OnLeaveGame()
  RankBoard:ClientInit()
  Shop:ClinetInit()
  Calendar.tbSysNotiy = nil
  FactionBattle:OnLeave()
  Survey:Init()
  Kin:StopRedPointTimer()
  Forbid:OnLeaveGame()
  Kin:EscortFinishInfoClear()
  DomainBattle:ClearData()
  for i, v in ipairs(self.tbNotifyMsgDatas) do
    table.remove(self.tbNotifyMsgDatas, 1)
  end
  self.nUnReadNotifyMsgNum = 0
  Player.nServerIdentity = nil
  FightSkill.tbFightSkillSlot = {}
  Activity:ClearData()
  Player.tbServerSyncData = {}
end
function Ui:OnMapLoaded(nMapTemplateId)
  local tbMapSetting = Map:GetMapSetting(nMapTemplateId)
  Ui:OpenWindow("HomeScreenMiniMap")
  Ui:UpdateDrawMapFog()
  Ui:UpateUseRes()
  Ui:UpdateMainUi()
  Ui:CheckAutoHide()
end
function Ui:OnMapEnter(nMapTemplateId)
  Ui:UpdateMapLoadResPath(nMapTemplateId)
  if self.nLockScreenState then
    Ui:OpenWindow("LockScreenPanel")
  end
end
function Ui:DestroyLoadShowUi()
  self.tbLoadShowUI = nil
end
function Ui:UpdateLoadShowUI(nMapTemplateId)
  if not self.tbLoadShowUI or self.tbLoadShowUI.nMapTID ~= nMapTemplateId then
    return
  end
  local tbShowUI = self.tbLoadShowUI.tbUi or {}
  for szWnd, _ in pairs(tbShowUI) do
    self:OpenWindow(szWnd)
  end
end
function Ui:SetLoadShowUI(tbLoad)
  self.tbLoadShowUI = tbLoad
  local pNpc = me.GetNpc()
  if pNpc then
    self:UpdateLoadShowUI(me.nMapTemplateId)
  end
end
function Ui:ForbidShowUI(szUI, nMapTemplateId, bForbid)
  self.tbForbidShowUI = self.tbForbidShowUI or {}
  self.tbForbidShowUI[szUI] = nil
  if not bForbid then
    return
  end
  self.tbForbidShowUI[szUI] = nMapTemplateId
  if Ui:WindowVisible(szUI) == 1 then
    Ui:CloseWindow(szUI)
  end
end
function Ui:IsForbidShowUI(szUI)
  self.tbForbidShowUI = self.tbForbidShowUI or {}
  local nMapTemplateId = self.tbForbidShowUI[szUI]
  if not nMapTemplateId then
    return false
  end
  if nMapTemplateId ~= me.nMapTemplateId then
    return false
  end
  return true
end
function Ui:HyperTextClickHandle(szText, posX, posY)
  self.HyperTextHandle:Handle(szText, posX, posY)
end
function Ui:OnServerMsgBox(szMsg, nCallbackCount, tbBtn, bIsServer, szNotTipsType, nTime, tbLight)
  local tbOpt = {}
  for i = 1, nCallbackCount do
    table.insert(tbOpt, {
      function(nSelect)
        Dialog:OnMsgBoxSelect(nSelect, bIsServer)
      end,
      i
    })
  end
  if szNotTipsType and self:CheckNotShowTips(szNotTipsType) then
    Dialog:OnMsgBoxSelect(1, bIsServer)
    return
  end
  Ui:OpenWindow("MessageBox", szMsg, tbOpt, tbBtn, szNotTipsType, nTime, false, tbLight)
end
function Ui:OnChangeFile(szFileName, szDebugPath)
  szDebugPath = string.gsub(szDebugPath, "\\", "/")
  szFileName = string.gsub(szFileName, "\\", "/")
  szFileName = string.sub(szFileName, string.len(szDebugPath) + 1)
  if string.find(szFileName, ".lua$") then
    Ui:OpenWindow("Reload", szFileName)
  end
end
function Ui:OnConnectLost()
  if IsAlone() ~= 1 then
    Ui:ResetCameraAni()
  end
  if not self.bForRetrunLogin and not self.bKickOffline and Ui:WindowVisible("Login") ~= 1 and not self.tbWaitingForOpen.Login then
    local nTimeNow = GetTime()
    self.nNextReconnectTime = self.nNextReconnectTime or 0
    if PlayerEvent.bLogin and nTimeNow >= self.nNextReconnectTime then
      self.nNextReconnectTime = nTimeNow + 10
      self:ReconnectServer()
    else
      Ui:OpenWindow("MessageBox", "与服务器断开连接", {
        {
          self.ReconnectServer,
          self
        },
        {
          self.ReturnToLogin,
          self
        }
      }, {
        "重连",
        "返回首页"
      }, nil, nil, true)
    end
  end
  ChatMgr:OnLostConnect()
  Map:OnLostConnect()
  House:OnConnectLost()
end
function Ui:ShowVersionTips()
  if IOS then
    Ui:OpenWindow("MessageBox", "检查到有新的版本，点击确定前往更新", {
      {
        function()
          CoreDll.IOSOpenUrl("itms-apps://itunes.apple.com/app/id1086842482")
        end
      }
    }, {"确认"}, nil, nil, true)
  else
    Ui:OpenWindow("MessageBox", "检查到有新的版本，请重新下载新版本的客户端", {
      {
        function()
          Application.OpenURL(Updater.s_szPackUrl)
        end
      }
    }, {"确认"}, nil, nil, true)
    local file = io.open(Updater.s_szPersistentDataPath .. Updater.s_szGrayUpdateFile, "w+")
    file:write(tostring(SERVER_VERSION))
    file:close()
  end
end
function Ui:ShowNewPackTips()
  if Updater.s_szPackUrl and Updater.s_szPackUrl ~= "" then
    if IOS then
      Ui:OpenWindow("MessageBox", "检查到有新的版本，点击确定前往更新", {
        {
          function()
            CoreDll.IOSOpenUrl("itms-apps://itunes.apple.com/app/id1086842482")
          end
        },
        {}
      }, {"确认", "取消"}, nil, nil, true)
    else
      Ui:OpenWindow("MessageBox", "检查到有新的版本，请重新下载新版本的客户端", {
        {
          function()
            Application.OpenURL(Updater.s_szPackUrl)
          end
        },
        {}
      }, {"确认", "取消"}, nil, nil, true)
    end
  end
end
function Ui:OnReConnectFaild(bCode)
  local szTipMsg
  if bCode == 4 then
    szTipMsg = "您的帐号已在别处登录"
  elseif bCode == 5 then
    Ui:ShowVersionTips()
    return
  else
    szTipMsg = "请重新登录"
  end
  if szTipMsg then
    self.bForRetrunLogin = true
    local function fnReturnLogin()
      self:ReturnToLogin()
      self.bForRetrunLogin = nil
    end
    Ui:OpenWindow("MessageBox", szTipMsg, {
      {fnReturnLogin}
    }, {"确定"}, nil, nil, true)
  end
end
function Ui:OnShowKickMsg(szMsg)
  self.bKickOffline = true
  local function fnReturnLogin()
    self:ReturnToLogin()
    self.bKickOffline = nil
  end
  Ui:OpenWindow("MessageBox", szMsg, {
    {fnReturnLogin}
  }, {"确定"}, nil, nil, true)
end
function Ui:ReConnectFail()
  Ui:OpenWindow("MessageBox", "重连失败", {
    {
      self.ReconnectServer,
      self
    },
    {
      self.ReturnToLogin,
      self
    }
  }, {
    "重试",
    "返回首页"
  }, nil, nil, true)
end
function Ui:ResetCameraAni()
  if not Login.bEnterGame then
    return
  end
  Ui:SetForbiddenOperation(false)
  Ui.CameraMgr.LeaveCameraAnimationState()
  Ui.CameraMgr.RestoreCameraRotation()
end
function Ui:ReconnectServer()
  ReconnectServer()
  Log("Ui ReconnectServer")
end
function Ui:ReturnToLogin()
  self.nLockScreenState = nil
  Loading.nCurLeaveMapId = nil
  PlayerEvent.bLogin = false
  Ui:OnLogoutFinish()
end
function Ui:OnLogoutFinish()
  if PauseRemoteServerReconnect then
    PauseRemoteServerReconnect(1000)
  end
  Map:OnLeave(me.nMapTemplateId, me.nMapId)
  self:OnLeaveGame()
  CloseMap()
  Login.bEnterGame = false
  self:CloseAllWindow()
  Guide:Clear()
  Ui:ShowAllRepresentObj(true)
  Login:OpenLoginScene(true)
  Lib:CallBack({
    Pandora.OnLogout,
    Pandora
  })
  Lib:CallBack({
    Kin.OnLogout,
    Kin
  })
  Lib:CallBack({
    TeacherStudent.OnLogout,
    TeacherStudent
  })
  Lib:CallBack({
    ImperialTomb.OnLogout,
    ImperialTomb
  })
  Lib:CallBack({
    WelfareActivity.OnLogout,
    WelfareActivity
  })
  Lib:CallBack({
    TimeFrame.OnClientLogout,
    TimeFrame
  })
  Lib:CallBack({
    Wedding.OnLogout,
    Wedding
  })
  ClearTssCacheData()
end
local _tbWndForFightState = {
  [0] = {
    "HomeScreenBattle",
    "RoleHead",
    "TopButton",
    "HomeScreenTask",
    "HomeScreenExpBar",
    "ChatSmall",
    "FakeJoyStick",
    "HomeScreenMiniMap"
  },
  [1] = {
    "HomeScreenBattle",
    "RoleHead",
    "TopButton",
    "PkMode",
    "HomeScreenTask",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenMiniMap",
    "BattleTopButton"
  }
}
local _tbHideWndState = {
  [Ui.STATE_DEFAULT] = {
    "BattleTopButton",
    "HomeScreenBattle"
  },
  [Ui.STATE_ASYNC_BATTLE] = {},
  [Ui.STATE_HIDE_ALL] = {
    "HomeScreenBattle"
  },
  [Ui.STATE_GAME_FIGHT] = {
    "RoleHead",
    "HomeScreenBattle",
    "PkMode",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenMiniMap"
  },
  [Ui.STATE_SPECIAL_FIGHT] = {
    "RoleHead",
    "PkMode",
    "FakeJoyStick",
    "HomeScreenBattle"
  },
  [Ui.STATE_MAPEXPLORE] = {
    "HomeScreenTask",
    "HomeScreenMiniMap",
    "HomeScreenBattle",
    "TopButton",
    "BattleTopButton"
  },
  [Ui.STATE_TEAM_BATTLE] = {
    "RoleHead",
    "HomeScreenTask",
    "HomeScreenBattle",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall"
  },
  [Ui.STATE_WATCH_FIGHT] = {
    "ChatSmall",
    "FakeJoyStick"
  },
  [Ui.STATE_MINI_MAP] = {
    "RoleHead",
    "HomeScreenBattle",
    "HomeScreenTask",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "BattleTopButton"
  },
  [Ui.STATE_FUBEN] = {
    "RoleHead",
    "HomeScreenBattle",
    "HomeScreenTask",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenMiniMap",
    "BattleTopButton"
  },
  [Ui.STATE_BOSS] = {
    "RoleHead",
    "PkMode",
    "HomeScreenBattle",
    "HomeScreenTask",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenMiniMap"
  },
  [Ui.STATE_TEAMBATTLE] = {
    "RoleHead",
    "HomeScreenBattle",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall"
  },
  [Ui.STATE_WhiteTigerFuben] = {
    "RoleHead",
    "PkMode",
    "HomeScreenBattle",
    "HomeScreenTask",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenMiniMap",
    "BattleTopButton"
  },
  [Ui.STATE_DomainBattle] = {
    "RoleHead",
    "HomeScreenBattle",
    "HomeScreenMiniMap",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenTask"
  },
  [Ui.STATE_ArenaBattleWait] = {
    "HomeScreenTask",
    "HomeScreenMiniMap",
    "RoleHead",
    "ChatSmall",
    "HomeScreenBattle"
  },
  [Ui.STATE_ArenaBattleMain] = {
    "PkMode",
    "BattleTopButton"
  },
  [Ui.STATE_ArenaBattleFight] = {
    "RoleHead",
    "HomeScreenBattle",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall"
  },
  [Ui.STATE_HSLJMap] = {
    "RoleHead",
    "HomeScreenTask",
    "HomeScreenBattle",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenMiniMap"
  },
  [Ui.STATE_HSLJFinalsMap] = {
    "RoleHead",
    "HomeScreenTask",
    "HomeScreenBattle",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenMiniMap"
  },
  [Ui.STATE_IMPERIAL_TOMB] = {
    "RoleHead",
    "PkMode",
    "HomeScreenBattle",
    "HomeScreenTask",
    "HomeScreenExpBar",
    "HomeScreenMiniMap",
    "FakeJoyStick",
    "ChatSmall",
    "BattleTopButton"
  },
  [Ui.STATE_HSLJPKMap] = {
    "RoleHead",
    "HomeScreenTask",
    "HomeScreenBattle",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall"
  },
  [Ui.STATE_IMPERIAL_ROOM] = {
    "RoleHead",
    "PkMode",
    "HomeScreenBattle",
    "HomeScreenTask",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "BattleTopButton"
  },
  [Ui.STATE_INDIFFER_BATTLE] = {
    "RoleHead",
    "HomeScreenBattle",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenTask"
  },
  [Ui.STATE_Selfie] = {
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall"
  },
  [Ui.STATE_BiWuZhaoQinPreMap] = {
    "RoleHead",
    "HomeScreenBattle",
    "HomeScreenExpBar",
    "FakeJoyStick",
    "ChatSmall",
    "HomeScreenMiniMap"
  },
  [Ui.STATE_WeddingTour] = {
    "ChatSmall",
    "FakeJoyStick",
    "HomeScreenExpBar"
  },
  [Ui.STATE_WeddingFuben] = {
    "ChatSmall",
    "FakeJoyStick",
    "RoleHead",
    "HomeScreenExpBar"
  },
  [Ui.STATE_WeddingEngaged] = {
    "ChatSmall",
    "FakeJoyStick",
    "HomeScreenMiniMap",
    "RoleHead",
    "HomeScreenExpBar"
  }
}
local tbWndForFightState = {}
for nState, tbInfo in pairs(_tbWndForFightState) do
  tbWndForFightState[nState] = {}
  for _, szWnd in ipairs(tbInfo) do
    tbWndForFightState[nState][szWnd] = 1
  end
end
local tbHideWndState = {}
for nState, tbInfo in pairs(_tbHideWndState) do
  tbHideWndState[nState] = {}
  for _, szWnd in ipairs(tbInfo) do
    tbHideWndState[nState][szWnd] = 1
  end
end
Ui.AUTO_HIDE_FORBID = {fight = true}
function Ui:IsAutoHide()
  local szMapType = Map:GetClassDesc(me.nMapTemplateId)
  if me.nFightMode ~= 0 and not self.AUTO_HIDE_FORBID[szMapType] then
    return true
  end
  return false
end
function Ui:CheckAutoHide()
  if Ui:IsAutoHide() then
    UiManager.SwitchAutoHide(true)
    UiNotify.OnNotify(UiNotify.emNOTIFY_UI_AUTO_HIDE, true)
  else
    UiManager.SwitchAutoHide(false)
    UiNotify.OnNotify(UiNotify.emNOTIFY_UI_AUTO_HIDE, false)
  end
end
function Ui:ChangeFightState(nFightState)
  print("Ui:ChangeFightState", nFightState)
  self:ChangeQuickUseOpen(nFightState)
  Ui:CheckAutoHide()
  if self.nFightState ~= nFightState then
    self.nFightState = nFightState
    self:UpdateMainUi()
  end
  Player:UpdateHeadState()
  Guide:OnChangeFightMode(nFightState)
end
function Ui:ChangeUiState(nState, bHideWnd)
  if nState and tbHideWndState[nState] then
    self.tbHideStateUi = tbHideWndState[nState]
  else
    self.tbHideStateUi = nil
  end
  self.nChangeUiState = nState
  self.bHideStateWnd = bHideWnd
  Ui:UpdateMainUi()
end
function Ui:UpdateMainUi()
  local bFigthUi = self.nFightState == 1 or self.nFightState == 2
  local tbShowUi = bFigthUi and tbWndForFightState[1] or tbWndForFightState[0]
  local tbHideUi = bFigthUi and tbWndForFightState[0] or tbWndForFightState[1]
  for szUi, _ in pairs(tbHideUi) do
    self:CloseWindow(szUi)
  end
  for szUi, _ in pairs(tbShowUi) do
    local bOpenWindow = false
    if not self.tbHideStateUi then
      bOpenWindow = true
    elseif self.tbHideStateUi[szUi] and not self.bHideStateWnd then
      bOpenWindow = true
    elseif not self.tbHideStateUi[szUi] and self.bHideStateWnd then
      bOpenWindow = true
    end
    if bOpenWindow then
      self:OpenWindow(szUi)
    else
      self:CloseWindow(szUi)
    end
  end
end
function Ui:IsFightOpenBoxPk(nMapTemplateId)
  if BossLeader:IsBossLeaderMap(nMapTemplateId) or Fuben.WhiteTigerFuben:IsMyMap(nMapTemplateId) or ImperialTomb:IsTombMap(nMapTemplateId) then
    return true
  end
  return false
end
function Ui:OnPlayCameraAnimationFinish()
  Fuben:OnPlayCameraAnimationFinish()
  CameraAnimation:OnPlayCameraAnimationFinish()
  House:OnPlayCameraAnimationFinish()
end
function Ui:OnWorldNotify(szMsg, nSenderId, bIsRollMsg)
  if nSenderId == 0 or bIsRollMsg == 1 then
    if Ui:WindowVisible("SystemNotice") ~= 1 then
      Ui:OpenWindow("SystemNotice", szMsg)
    else
      Ui("SystemNotice"):ShowMsg(szMsg)
    end
  end
  if nSenderId == 0 then
    return
  end
  local bCanSend = false
  for _, nId in pairs(ChatMgr.SystemMsgType or {}) do
    if nSenderId == nId then
      bCanSend = true
      break
    end
  end
  if not bCanSend then
    return
  end
  ChatMgr:OnChannelMessage(ChatMgr.ChannelType.System, nSenderId, "", 0, 0, 0, szMsg)
end
function Ui:DropAward(nPosX, nPosY, tbAward)
  local tbDropInfo = {}
  for _, tbInfo in pairs(tbAward) do
    local awardType = Player.AwardType[tbInfo[1] or "nil"]
    if awardType == Player.award_type_money then
      local szName = Shop:GetMoneyName(tbInfo[1])
      local nObjID = Shop:GetMoneyObjId(tbInfo[1])
      if nObjID then
        tbDropInfo.tbUserDef = tbDropInfo.tbUserDef or {}
        table.insert(tbDropInfo.tbUserDef, {
          nObjID = nObjID,
          szTitle = string.format("%s * %s", szName, tbInfo[2])
        })
      end
    elseif awardType == Player.award_type_item then
      tbDropInfo.tbItem = tbDropInfo.tbItem or {}
      table.insert(tbDropInfo.tbItem, {
        nItemId = tbInfo[2],
        nCount = tbInfo[3]
      })
    end
  end
  me.DropItemInPos(nPosX, nPosY, tbDropInfo)
end
function Ui:SetCompareTipsPos()
  local tbEquipTips = Ui("EquipTips")
  local tbCompareTips = Ui("CompareTips")
  tbEquipTips.pPanel:ChangePosition("Main", 133, 234)
  tbCompareTips.pPanel:ChangePosition("Main", -270, 234)
end
function Ui:SetTipsPos()
  local tbEquipTips = Ui("EquipTips")
  tbEquipTips.pPanel:ChangePosition("Main", -84, 234)
end
function Ui:OnScreenClick(szUi, szClickUi)
  local tbWnd = Ui(szUi)
  if tbWnd and tbWnd.OnScreenClick then
    tbWnd:OnScreenClick(szClickUi)
  end
end
function Ui:OpenTaskDialog(nTaskId, nNpcId, nDialogId, nState)
  local tbDlg = self:GetClass("SituationalDialogue")
  local nLookToNpcId = tbDlg:CheckLookToNpc(nDialogId)
  if nLookToNpcId then
    Npc.NpcShow:LookToNpc(nLookToNpcId, function()
      Ui:OpenTaskDialog(nTaskId, nNpcId, nDialogId, nState)
    end)
    return
  end
  Ui:OpenWindow("SituationalDialogue", "ShowTaskDialog", nTaskId, nNpcId, nDialogId, nState)
end
function Ui:TryPlaySitutionalDialog(nDialogId, bIsOnce, tbCallBack)
  local tbDlg = self:GetClass("SituationalDialogue")
  local nLookToNpcId = tbDlg:CheckLookToNpc(nDialogId)
  if nLookToNpcId then
    Npc.NpcShow:LookToNpc(nLookToNpcId, function()
      Ui:TryPlaySitutionalDialog(nDialogId, bIsOnce, tbCallBack)
    end)
    return
  end
  if bIsOnce then
    local tbData = Client:GetUserInfo("SituationalDialogue")
    tbData[me.dwID] = tbData[me.dwID] or {}
    if tbData[me.dwID][nDialogId] then
      if tbCallBack then
        local function fnCallback()
          Lib:CallBack(tbCallBack)
        end
        Timer:Register(1, fnCallback)
      end
      return
    end
    tbData[me.dwID][nDialogId] = 1
    Client:SaveUserInfo()
  end
  Ui:OpenWindow("SituationalDialogue", "ShowNormalDialog", nDialogId, tbCallBack)
end
function Ui:BatchPlaySceneAnimation(szObjectName, nStartIdx, nEndIdx, szAnimationName, nSpeed, bFinishHide)
  for i = nStartIdx, nEndIdx do
    Ui.Effect.PlaySceneAnimation(szObjectName .. i, szAnimationName, nSpeed or 1, bFinishHide)
  end
end
function Ui:OnSceneAniFinish(szObjectName, szAnimationName)
end
function Ui:SetForbiddenOperation(bForbidden, bNotJoyStick)
  local bJoyStick = true
  if bForbidden then
    bJoyStick = false
    bForbidden = true
  else
    bJoyStick = true
    bForbidden = false
  end
  self.bIsForbiddenOperation = bForbidden
  UiManager.SetForbiddenOperation(bForbidden)
  if not bNotJoyStick then
    Operation:SetJoyStickUp()
    if Login.bEnterGame then
      me.StopDirection()
    end
    TouchMgr.SetJoyStick(bJoyStick)
    if not bJoyStick then
      SkillController.SetJoyStick(false)
    end
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_FORBIDDEN_OPERATION, bForbidden)
  Log("ForbiddenOperation", bForbidden and "true" or "false")
end
Ui.tbUiToHide = {
  "ChatSmall",
  "FakeJoyStick",
  "HomeScreenMiniMap",
  "TopButton",
  "HomeScreenTask",
  "RoleHead",
  "HomeScreenExpBar",
  "HomeScreenFuben",
  "HomeScreenBattle",
  "Guide",
  "BattleTopButton",
  "QYHLeavePanel",
  "HomeScreenVoice"
}
function Ui:IsUiHideVisable(szWnd)
  if not self.bHideAlllUi then
    return false
  end
  for _, szUi in pairs(Ui.tbUiToHide) do
    if szWnd == szUi then
      return true
    end
  end
  return false
end
Ui.tbHideUi = Ui.tbHideUi or {}
function Ui:SetAllUiVisable(bShow)
  self.bHideAlllUi = false
  if not bShow then
    self.bHideAlllUi = true
  end
  if not bShow then
    for _, szUi in pairs(Ui.tbUiToHide) do
      if Ui:WindowVisible(szUi) == 1 and Ui(szUi).pPanel:IsActive("Main") then
        self.tbHideUi[szUi] = true
        Ui(szUi).pPanel:SetActive("Main", false)
      end
    end
  else
    for szUi in pairs(self.tbHideUi) do
      if Ui:WindowVisible(szUi) == 1 then
        Ui(szUi).pPanel:SetActive("Main", true)
      end
    end
    self.tbHideUi = {}
  end
end
function Ui:IsTipsNeverShow(szType)
  local tbSplit = Lib:SplitStr(szType or "", "|")
  return tbSplit[#tbSplit] == "NEVER"
end
function Ui:CheckNotShowTips(szType)
  local bNever = self:IsTipsNeverShow(szType)
  local tbRecord
  if bNever then
    tbRecord = Client:GetUserInfo("ClientNeverTips")
    tbRecord.tbRecord = tbRecord.tbRecord or {}
    return tbRecord.tbRecord[szType]
  else
    tbRecord = Client:GetUserInfo("ClientDailyTips")
    if not tbRecord.nDate or tbRecord.nDate ~= Lib:GetLocalDay() then
      tbRecord.nDate = Lib:GetLocalDay()
      tbRecord.tbOldRecord = tbRecord.tbRecord or {}
      tbRecord.tbRecord = {}
    end
    tbRecord.tbOldRecord = tbRecord.tbOldRecord or tbRecord.tbRecord or {}
    return tbRecord.tbRecord[szType], tbRecord.tbOldRecord[szType]
  end
end
function Ui:SetNotShowTips(szType, value)
  local bNever = self:IsTipsNeverShow(szType)
  local tbRecord
  local bChange = false
  value = value and 1 or nil
  if bNever then
    tbRecord = Client:GetUserInfo("ClientNeverTips")
    tbRecord.tbRecord = tbRecord.tbRecord or {}
  else
    tbRecord = Client:GetUserInfo("ClientDailyTips")
    if not tbRecord.nDate or tbRecord.nDate ~= Lib:GetLocalDay() then
      tbRecord.nDate = Lib:GetLocalDay()
      tbRecord.tbOldRecord = tbRecord.tbRecord or {}
      tbRecord.tbRecord = {}
    end
    tbRecord.tbOldRecord = tbRecord.tbOldRecord or tbRecord.tbRecord or {}
    if tbRecord.tbOldRecord[szType] ~= value then
      tbRecord.tbOldRecord[szType] = value
      bChange = true
    end
  end
  if tbRecord.tbRecord[szType] ~= value then
    tbRecord.tbRecord[szType] = value
    bChange = true
  end
  if bChange then
    Client:SaveUserInfo()
  end
end
function Ui:OnStartVoiceConflict()
  me.CenterMsg(XT("实时语音开启中，不能使用语音聊天"))
end
function Ui:StartVoice(fnCheckStart)
  if self.nVoiceEndDelayTimer then
    me.CenterMsg(XT("录音失败，请稍后再试"))
    return
  end
  if not self.bInitVoiceCfg then
    if not version_tx then
      self.UiManager.SetKGSpeachRecognize(false)
    else
      self.UiManager.SetKGSpeachRecognize(true)
    end
    self.bInitVoiceCfg = true
  end
  if fnCheckStart and not fnCheckStart() then
    return
  end
  self.fnVoiceCallBack = nil
  local fileIdHigh, fileIdLow = FileServer:CreateFileId()
  if ANDROID or IOS then
    Ui:SetMusicVolume(0)
    Ui:SetSoundEffect(0)
    ChatMgr:CloseChatRoomTmp()
    local nRet = 0
    local bUseApolloVoice = ChatMgr:CheckUseApollo()
    if bUseApolloVoice then
      nRet = ChatMgr:StartApolloVoice(fileIdHigh, fileIdLow)
    else
      nRet = UiManager.StartListen(fileIdHigh, fileIdLow)
    end
    if nRet == 0 then
      ChatMgr:StopVoice()
      self:OpenWindow("VoiceRecord")
      ChatMgr.bStartedVoice = true
    else
      ChatMgr:CheckMusicVolume()
      me.CenterMsg("开启语音失败")
    end
  end
end
function Ui:EndVoice(fnCallback, bCancel)
  self:CloseWindow("VoiceRecord")
  if not ChatMgr.bStartedVoice then
    return
  end
  ChatMgr.bStartedVoice = false
  ChatMgr:RestoreChatRoomTmp()
  ChatMgr:CheckMusicVolume()
  if ANDROID or IOS then
    local bUseApolloVoice = ChatMgr:CheckUseApollo()
    if bUseApolloVoice then
      ChatMgr:StopApolloVoice()
    else
      self.UiManager.StopListen()
    end
  end
  self.nVoiceEndDelayTimer = Timer:Register(ChatMgr.VOICE_END_DELAY * Env.GAME_FPS, function()
    self.nVoiceEndDelayTimer = nil
  end)
  ChatMgr:AutoPlayNextVoice()
  self.fnVoiceCallBack = nil
  if bCancel then
    me.CenterMsg("您取消了语音输入")
    return
  end
  if not bCancel and fnCallback then
    self.fnVoiceCallBack = fnCallback
  end
end
function Ui:ChangeVoiceState(bCancel)
  if ANDROID or IOS then
    local tbVoiceRecord = Ui("VoiceRecord")
    if tbVoiceRecord then
      tbVoiceRecord:ChangeVoiceState(bCancel)
    end
  end
end
function Ui:OnVoice2TxtResult(szTxt, fileIdHigh, fileIdLow, filePath, voiceTime)
  if self.fnVoiceCallBack then
    if fileIdHigh == 0 then
      me.CenterMsg("语音发送失败")
    end
    self.fnVoiceCallBack(szTxt, fileIdHigh, fileIdLow, filePath, voiceTime)
  end
  self.fnVoiceCallBack = nil
  if self.nVoiceEndDelayTimer then
    Timer:Close(self.nVoiceEndDelayTimer)
    self.nVoiceEndDelayTimer = nil
  end
end
function Ui:OpenQuickUseItem(nItemId, szBtnName)
  if Ui:WindowVisible("QuickUseItem") ~= 1 then
    Ui:OpenWindow("QuickUseItem", nItemId, szBtnName)
  else
    Ui("QuickUseItem"):Update(szBtnName)
  end
end
function Ui:PlayEffect(nResId, nX, nY, nZ, bRenderPos)
  if bRenderPos then
    Ui.Effect.PlayRenderEffect(nResId, 0, nX or 0, nY or 0, nZ or 0)
    return
  end
  if not (nX and nY) or nX == 0 or nY == 0 then
    nZ, nX, nY = me.GetWorldPos()
    nZ = 0
  end
  Ui.Effect.PlayEffect(nResId, nX, nY, nZ or 0)
end
function Ui:PlayCameraEffect(nResId)
  Ui.Effect.PlayRenderEffect(nResId, 1)
end
function Ui:PlayNpcSond(nSoundID)
  if self.nCurSondId then
    self:StopDialogueSound(self.nCurSondId, 500)
  end
  self.nCurSondId = nSoundID
  self:PlayDialogueSound(nSoundID)
end
function Ui:PlaySceneSound(nSoundID)
  if not nSoundID or nSoundID <= 0 then
    return
  end
  Ui.SoundManager.PlaySceneSound(nSoundID)
end
function Ui:StopSceneSound(nSoundID, nDuration)
  nDuration = nDuration or 1
  Ui.SoundManager.StopSceneSound(nSoundID, nDuration)
end
function Ui:PlayDialogueSound(nSoundID)
  if not nSoundID or nSoundID <= 0 then
    return
  end
  Ui.SoundManager.PlayDialogueSound(nSoundID)
end
function Ui:StopDialogueSound(nSoundID, nDuration)
  nDuration = nDuration or 1
  Ui.SoundManager.StopDialogueSound(nSoundID, nDuration)
end
function Ui:PlayUISound(nSoundID)
  if not nSoundID or nSoundID <= 0 then
    return
  end
  Ui.SoundManager.PlayUISound(nSoundID)
end
Ui.nSceneSoundScale = Ui.nSceneSoundScale or 100
Ui.nDialogueSoundScale = Ui.nDialogueSoundScale or 100
Ui.nEffectSoundScale = Ui.nEffectSoundScale or 100
function Ui:SetSceneSoundScale(nScale)
  if Ui.nSceneSoundScale == nScale then
    return
  end
  Ui.nSceneSoundScale = nScale
  local tbUserSet = Ui:GetPlayerSetting()
  Ui.SoundManager.SetSceneVolume(tbUserSet.fMusicVolume * (Ui.nSceneSoundScale / 100))
end
function Ui:SetDialogueSoundScale(nScale)
  if Ui.nDialogueSoundScale == nScale then
    return
  end
  Ui.nDialogueSoundScale = nScale
  local tbUserSet = Ui:GetPlayerSetting()
  Ui.SoundManager.SetDialogueVolume(tbUserSet.fMusicVolume * (Ui.nDialogueSoundScale / 100))
end
function Ui:SetEffectSoundScale(nScale)
  if Ui.nEffectSoundScale == nScale then
    return
  end
  Ui.nEffectSoundScale = nScale
  local tbUserSet = Ui:GetPlayerSetting()
  Ui.SoundManager.SetUIVolume(tbUserSet.fSoundEffectVolume * (Ui.nEffectSoundScale / 100))
  Ui.SoundManager.SetOtherVolume(tbUserSet.fSoundEffectVolume * (Ui.nEffectSoundScale / 100))
end
function Ui:SetMusicVolume(fVolume, bSave)
  Ui.SoundManager.SetSceneVolume(fVolume * (Ui.nSceneSoundScale / 100))
  Ui.SoundManager.SetDialogueVolume(fVolume * (Ui.nDialogueSoundScale / 100))
  if bSave then
    local tbUserSet = Ui:GetPlayerSetting()
    tbUserSet.fMusicVolume = fVolume
  end
end
function Ui:SetSoundEffect(fVolume, bSave)
  Ui.SoundManager.SetUIVolume(fVolume * (Ui.nEffectSoundScale / 100))
  Ui.SoundManager.SetOtherVolume(fVolume * (Ui.nEffectSoundScale / 100))
  if bSave then
    local tbUserSet = Ui:GetPlayerSetting()
    tbUserSet.fSoundEffectVolume = fVolume
  end
end
function Ui:ShowComboKillCount(nComboCount, bNotHide)
  if Ui:WindowVisible("HomeScreenBattleInfo") ~= 1 then
    Ui:OpenWindow("HomeScreenBattleInfo", nil, nil, nComboCount)
  else
    local tbWndUi = Ui("HomeScreenBattleInfo")
    if bNotHide then
      tbWndUi:PlayComboAni(nComboCount)
    else
      tbWndUi:PlayComboAni(nComboCount, tbWndUi.nShowComboTime)
    end
  end
end
Ui.tbDefDrawLevel = {
  nHeight = 1,
  nMiddle = 2,
  nLow = 3
}
Ui.nRenderFPS = Ui.nRenderFPS or 0
function Ui:SetRenderFPS(nSetFPS)
  local nRenderFPS = nSetFPS
  if not nRenderFPS then
    local tbUserSet = Ui:GetPlayerSetting()
    if tbUserSet.nDrawLevel == self.tbDefDrawLevel.nHeight then
      nRenderFPS = 60
    else
      nRenderFPS = 30
    end
  end
  if Ui.bOnSaveBatteryMode then
    nRenderFPS = 15
  end
  if Ui.nRenderFPS == nRenderFPS then
    return
  end
  SetVSyncFPS(nRenderFPS, 0)
  if IOS then
    if nRenderFPS == 45 then
      SetVSyncFPS(nRenderFPS, 1)
      Ui.Effect.SetVSyncFPS(60)
    elseif nRenderFPS == 15 then
      SetVSyncFPS(nRenderFPS, 1)
      Ui.Effect.SetVSyncFPS(30)
    else
      Ui.Effect.SetVSyncFPS(nRenderFPS)
    end
  else
    Ui.Effect.SetVSyncFPS(nRenderFPS)
  end
  Ui.nRenderFPS = nRenderFPS
  Log("SetRenderFPS", nRenderFPS)
end
function Ui:UpdateDrawLevel()
  self:SetRenderFPS()
  local tbUserSet = Ui:GetPlayerSetting()
  self:SetMaxShowNpcCount(tbUserSet.nMaxPlayerCount)
  self:UpdateDrawMapFog()
  Ui:UpateUseRes()
  Log("UpdateDrawLevel", tbUserSet.nDrawLevel)
end
Ui.tbCanLoadResCount = {
  {
    nMin = 0,
    nMax = 0,
    nCount = 2
  },
  {
    nMin = 1,
    nMax = 8,
    nCount = 30
  },
  {
    nMin = 9,
    nMax = 19,
    nCount = 40
  },
  {
    nMin = 20,
    nMax = 29,
    nCount = 50
  },
  {
    nMin = 30,
    nMax = 999999,
    nCount = 100
  }
}
function Ui:UpdateCanLoadResPath(nShowCount)
  if not nShowCount then
    return
  end
  self.nLoadResShowCount = nShowCount
  for _, tbInfo in pairs(Ui.tbCanLoadResCount) do
    if nShowCount >= tbInfo.nMin and nShowCount <= tbInfo.nMax then
      Ui.Effect.SetCanLoadResPath(1, tbInfo.nCount)
      return
    end
  end
  Ui.Effect.SetCanLoadResPath(1, 10)
end
function Ui:SetMaxShowNpcCount(nMaxCount, bSave)
  local nCurCount = nMaxCount
  if nCurCount >= 30 then
    nCurCount = 66
  end
  Ui.Effect.SetMaxShowNpcCount(nCurCount)
  if bSave then
    local tbUserSet = Ui:GetPlayerSetting()
    tbUserSet.nMaxPlayerCount = nMaxCount
  end
  Ui:UpdateCanLoadResPath(nCurCount)
  Log("Ui SetMaxShowNpcCount", nMaxCount, nCurCount)
end
Ui.tbLoadResPathMap = {
  [1041] = 1,
  [1042] = 1,
  [1043] = 1,
  [1044] = 1,
  [1045] = 1,
  [1046] = 1,
  [1056] = 1,
  [1047] = 1,
  [1057] = 1
}
function Ui:UpdateMapLoadResPath(nMapTemplateId)
  if Ui.tbLoadResPathMap[nMapTemplateId] then
    Ui.Effect.SetCanLoadResPath(1, 256)
  else
    local nCount = self.nLoadResShowCount or 10
    Ui:UpdateCanLoadResPath(nCount)
  end
end
function Ui:CheckUpdateUseRes()
  if IOS or not me then
    return false
  end
  local pNpc = me.GetNpc()
  if not pNpc then
    return false
  end
  local bUsePerformance = Map:IsPerformance(pNpc.nMapTemplateId)
  local tbUserSet = Ui:GetPlayerSetting()
  if tbUserSet.nDrawLevel ~= self.tbDefDrawLevel.nLow then
    bUsePerformance = false
  end
  return bUsePerformance
end
function Ui:GetUseLowRes()
  if not me then
    return true
  end
  local pNpc = me.GetNpc()
  if not pNpc then
    return true
  end
  local bUsePerformance = Map:IsPerformance(pNpc.nMapTemplateId)
  return bUsePerformance
end
function Ui:UpateUseRes()
  local tbUserSet = Ui:GetPlayerSetting()
  local bUsePerformance = Ui:GetUseLowRes()
  if tbUserSet.nDrawLevel == self.tbDefDrawLevel.nLow then
    bUsePerformance = true
  end
  Ui.Effect.SetUseLowRes(bUsePerformance)
  local bRetcode = Ui:CheckUpdateUseRes()
  if bRetcode then
    self:SetRenderFPS(24)
  else
    self:SetRenderFPS()
  end
end
function Ui:LoadPerformanceSetting()
  self.tbPerformanceSetting = {}
  local tbFileData = Lib:LoadTabFile("Setting/PerformanceSetting.tab", {IsFog = 1, ShowPlayerCount = 1})
  for _, tbInfo in pairs(tbFileData) do
    if Lib:IsEmptyStr(tbInfo.DrawLevel) then
      tbInfo.nDrawLevel = self.tbDefDrawLevel.nLow
    else
      tbInfo.nDrawLevel = tonumber(tbInfo.DrawLevel)
    end
    self.tbPerformanceSetting[tbInfo.Type] = tbInfo
  end
  local tbDefInfo = {
    IsFog = 0,
    ShowPlayerCount = 10,
    nDrawLevel = self.tbDefDrawLevel.nLow
  }
  if IOS then
    tbDefInfo.IsFog = 1
    tbDefInfo.ShowPlayerCount = 15
  end
  self.tbPerformanceSetting["-1"] = tbDefInfo
end
Ui.tbDeviceIOSPerformance = {
  iPhone = 7,
  iPod = 7,
  iPad = 5
}
function Ui:GetIOSPerformanceInfo(szType)
  local tbIOSPerformance = {
    IsFog = 1,
    ShowPlayerCount = 20,
    nDrawLevel = Ui.tbDefDrawLevel.nMiddle
  }
  for szDevice, nVersion in pairs(self.tbDeviceIOSPerformance) do
    local _, _, nCurVersion, nNextVersion = string.find(szType, szDevice .. "(%d),(%d)")
    if nCurVersion then
      nCurVersion = tonumber(nCurVersion)
      if nVersion <= nCurVersion then
        return tbIOSPerformance
      end
    end
  end
end
function Ui:GetPerformanceInfo(szType)
  if not self.tbPerformanceSetting then
    Ui:LoadPerformanceSetting()
  end
  local tbInfo = self.tbPerformanceSetting[szType]
  if tbInfo then
    return tbInfo
  end
  if IOS then
    tbInfo = Ui:GetIOSPerformanceInfo(szType)
  end
  if tbInfo then
    return tbInfo
  end
  return self.tbPerformanceSetting["-1"]
end
function Ui:UpdateDrawMapFog()
  if not me then
    return
  end
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local tbUserSet = Ui:GetPlayerSetting()
  local tbMap = {
    [999] = 1,
    [1] = 1
  }
  local bShow = false
  if tbMap[pNpc.nMapTemplateId] and tbUserSet.nIsFog == 1 then
    bShow = true
  end
  if not Map:IsHouseMap(pNpc.nMapTemplateId) then
    Ui.Effect.ShowFog(bShow)
  end
end
function Ui:ClearCanLoadResPath()
  if Ui.Effect then
    Ui.Effect.ClearCanLoadResPath()
  end
end
function Ui:GetPlayerSetting()
  local tbUserSet = Client:GetUserInfo("PlayerSetting", -1)
  tbUserSet.fSoundEffectVolume = tbUserSet.fSoundEffectVolume or 1
  tbUserSet.fMusicVolume = tbUserSet.fMusicVolume or 1
  local szDeviceMode, tbDefPerformance
  if not (tbUserSet.nDrawLevel and tbUserSet.nMaxPlayerCount) or not tbUserSet.nIsFog then
    szDeviceMode = Ui:GetDeviceModel()
    tbDefPerformance = self:GetPerformanceInfo(szDeviceMode)
  end
  if not tbUserSet.nDrawLevel then
    tbUserSet.nDrawLevel = tbDefPerformance.nDrawLevel
  end
  if not tbUserSet.nMaxPlayerCount then
    tbUserSet.nMaxPlayerCount = tbDefPerformance.ShowPlayerCount
  end
  if not tbUserSet.nIsFog then
    tbUserSet.nIsFog = tbDefPerformance.IsFog
  end
  return tbUserSet
end
function Ui:GetDeviceModel()
  if WINDOWS then
    return "Windows"
  end
  return self.UiManager.GetDeviceModel()
end
function Ui:UpdateSoundSetting()
  local tbUserSet = Ui:GetPlayerSetting()
  Ui:SetMusicVolume(tbUserSet.fMusicVolume)
  Ui:SetSoundEffect(tbUserSet.fSoundEffectVolume)
end
function Ui:ShowAllRepresentObj(bShow)
  Ui.Effect.ShowAllRepresentObj(bShow)
end
function Ui:OnAniCommander(tbTable, szCommander)
  Ui.tbAniCommander = tbTable
  local szLoadString = "local self = Ui.tbAniCommander; " .. szCommander
  local fnExc = loadstring(szLoadString)
  if fnExc then
    xpcall(fnExc, Lib.ShowStack)
  end
end
function Ui:AddCenterMsg(szMsg, bSysMsg, nSysMsgType)
  local szCenterMsgUi = "GetNotice"
  if not self.tbUi[szCenterMsgUi] or self:WindowVisible(szCenterMsgUi) ~= 1 then
    self:OpenWindow(szCenterMsgUi)
  end
  if type(szMsg) ~= "string" and type(szMsg) ~= "number" then
    return
  end
  szMsg = tostring(szMsg)
  szMsg = KLib.CutUtf8(szMsg, KLib.GetUtf8Len(szMsg))
  table.insert(self.tbCenterMsg, szMsg)
  if bSysMsg then
    me.Msg(szMsg, nSysMsgType)
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_CENTER_MSG)
end
function Ui:FetchCenterMsg()
  local tbRet = self.tbCenterMsg
  self.tbCenterMsg = {}
  return tbRet
end
function Ui:ShowBlackMsg(szMsg, bSysMsg)
  if bSysMsg then
    me.Msg(szMsg)
  end
  self:OpenWindow("TaskNotice", szMsg)
end
function Ui:OnAniEnd(tbWndCom, szAni)
  if tbWndCom.OnAniEnd then
    tbWndCom:OnAniEnd(szAni)
  end
  if tbWndCom.UI_NAME then
    UiNotify.OnNotify(UiNotify.emNOTIFY_ANIMATION_FINISH, tbWndCom.UI_NAME, szAni)
  end
end
function Ui:StartProcess(szMsg, nInterval)
  Ui:OpenWindow("NpcStrip", szMsg, nInterval)
end
function Ui:CloseProcess()
  local bProcessShow = Ui:WindowVisible("NpcStrip") == 1
  UiNotify.OnNotify(UiNotify.emNOTIFY_BREAK_GENERALPROCESS, bProcessShow)
  Ui:CloseWindow("NpcStrip")
end
function Ui:NpcBubbleTalk(npc, szContent, nDuration, nMaxCount, nDealyTime)
  if nDealyTime and nDealyTime > 0 then
    Timer:Register(nDealyTime * Env.GAME_FPS, self.NpcBubbleTalk, self, npc, szContent, nDuration, nMaxCount)
    return
  end
  local tbNpcInfo = {}
  if type(npc) == "number" then
    tbNpcInfo[1] = npc
  elseif type(npc) == "table" then
    tbNpcInfo = npc
  end
  local nCount = 1
  for i, nNpcId in pairs(tbNpcInfo) do
    local pNpc = KNpc.GetById(nNpcId)
    if pNpc then
      if nMaxCount and nMaxCount < nCount then
        break
      end
      pNpc.BubbleTalk(szContent, tostring(nDuration))
      nCount = nCount + 1
    end
  end
end
function Ui:OnScreenRecordStart(nRet)
  if nRet == 1 then
    me.CenterMsg("Record Start")
    self:OpenWindow("ScreenRecord")
  else
    me.CenterMsg("Record Start Failed!!!!!")
  end
end
function Ui:OnScreenRecordEnd()
end
function Ui:DoLeftInfoUpdate(...)
  UiNotify.OnNotify(UiNotify.emNOTIFY_QYHLEFT_INFO_UPDATE, ...)
end
function Ui:OnHelpClicked(szName)
  Ui:OpenWindow("GeneralHelpPanel", szName)
end
function Ui:SwitchSaveBatteryMode(bForceClose)
  self.bOnSaveBatteryMode = not self.bOnSaveBatteryMode
  if bForceClose then
    self.bOnSaveBatteryMode = nil
  end
  local tbUserSet = Ui:GetPlayerSetting()
  if self.bOnSaveBatteryMode then
    Ui.nLastUserDrawLevel = tbUserSet.nDrawLevel
    Ui.ToolFunction.SetScreenBrightness(Ui.SCREEN_BRIGH_LOW)
    tbUserSet.nDrawLevel = Ui.tbDefDrawLevel.nLow
  else
    Ui.ToolFunction.SetScreenBrightness(Ui.SCREEN_BRIGH_NORMAL)
    local tbDefPerformance = self:GetPerformanceInfo(Ui:GetDeviceModel())
    tbUserSet.nDrawLevel = Ui.nLastUserDrawLevel or tbDefPerformance.nDrawLevel
  end
  Ui:UpdateDrawLevel()
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_SAVE_BATTERY_MODE)
end
function Ui:ShowDebugInfo(bShow)
  self.bShowDebugInfo = bShow
  self.FTDebug.bShowDebugInfo = bShow
end
function Ui:SetDebugInfo(szInfo, fX, fY, fWight, fHeight)
  if not self.bShowDebugInfo then
    return
  end
  self.FTDebug.SetDebugInfo(szInfo, fX or 0, fY or 0, fWight or 1024, fHeight or 768)
end
function Ui:OnCallFromUnity(szFunc, ...)
  return false
end
function Ui:LoadUiSetting()
  self.tbUiSetting = LoadTabFile("Setting/Ui/Load.tab", "sd", "Name", {
    "Name",
    "BackBtnClose"
  })
end
Ui:LoadUiSetting()
function Ui:OnReturnPressed()
  local szTopPanelName = UiManager.GetTopPanelName()
  if Lib:IsEmptyStr(szTopPanelName) then
    Operation:OnTouchReturn()
  elseif self.tbUiSetting[szTopPanelName] then
    Operation:OnTouchReturn(szTopPanelName, self.tbUiSetting[szTopPanelName].BackBtnClose == 1)
  end
end
Ui.tbTempShowAwards = {}
Ui.nLastShowLogway = -1
function Ui:MergeShowAwardTips(tbAward, nLogWay, bHideMsg)
  if Ui.nLastShowLogway ~= nLogWay then
    if next(self.tbTempShowAwards) then
      Ui:OpenAwardUi(self.tbTempShowAwards, self.nLastShowLogway)
      self.tbTempShowAwards = {}
    end
    self.nLastShowLogway = nLogWay
  end
  for i, v in ipairs(tbAward) do
    table.insert(self.tbTempShowAwards, v)
  end
  if not self.nTimerMergeAwardTips then
    self.nTimerMergeAwardTips = Timer:Register(7, function()
      if next(self.tbTempShowAwards) then
        Ui:OpenAwardUi(self.tbTempShowAwards, self.nLastShowLogway, bHideMsg)
        self.tbTempShowAwards = {}
      end
      self.nTimerMergeAwardTips = nil
    end)
  end
end
function Ui:HideOthers(tbShowNpcIds)
  self:SetAllUiVisable(false)
  self:ShowAllRepresentObj(false)
  for _, nId in ipairs(tbShowNpcIds) do
    self.Effect.ShowNpcRepresentObj(nId, true)
  end
end
function Ui:ShowOthers()
  self:SetAllUiVisable(true)
  self:ShowAllRepresentObj(true)
end
function Ui:NotfifyGetAward(tbAward, bMsg, bShowUi, nLogReazon)
  if bMsg then
    local tbAwardDes = Lib:GetAwardDesCount(tbAward, me)
    local szLogWay = Env.tbLogWayDesc[nLogReazon]
    szLogWay = Lib:IsEmptyStr(szLogWay) and "" or string.format("（%s）", szLogWay)
    for _, tbDes in pairs(tbAwardDes) do
      local szMsg = ""
      if tbDes.szEmotionDesc and tbDes.szEmotionDesc ~= "" then
        szMsg = string.format("获得%s%s", tbDes.szEmotionDesc, szLogWay)
      else
        szMsg = string.format("获得%s%s", tbDes.szDesc, szLogWay)
      end
      me.CenterMsg(szMsg, true)
    end
  elseif bShowUi then
    self:OpenAwardUi(tbAward, nLogReazon)
  end
end
function Ui:OpenAwardUi(tbAward, nLogReazon, bHideMsg)
  Ui:OpenWindow("AwardTips", tbAward, nLogReazon)
  if not bHideMsg then
    self:SendChatTip(tbAward, nLogReazon)
  end
end
function Ui:SendChatTip(tbAward, nLogWay)
  local tbAwardDes = Lib:GetAwardDesCount(tbAward, me)
  for _, tbDes in pairs(tbAwardDes) do
    local szLogWay = Env.tbLogWayDesc[nLogWay]
    szLogWay = Lib:IsEmptyStr(szLogWay) and "" or string.format("（%s）", szLogWay)
    local szMsg = Lib:IsEmptyStr(tbDes.szEmotionDesc) and string.format("获得%s%s", tbDes.szDesc or "", szLogWay) or string.format("获得%s%s", tbDes.szEmotionDesc or "", szLogWay)
    me.Msg(szMsg)
  end
end
function Ui:OnHotKey(nKey)
  Ui.Hotkey:OnHotKey(nKey)
end
function Ui:OnCheckAnyKey(nKey)
  Ui.Hotkey:OnCheckAnyKey(nKey)
end
