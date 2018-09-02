Require("Script/Sdk.lua")
local RepresentMgr = luanet.import_type("RepresentMgr")
local ReprentEvent = luanet.import_type("ReprentEvent")
local AvatarHeadInfoMgr = luanet.import_type("AvatarHeadInfoMgr")
local NpcViewMgr = luanet.import_type("NpcViewMgr")
local SceneMgr = luanet.import_type("SceneMgr")
local SdkMgr = luanet.import_type("SdkInterface")
Login.szSceneMapName = "choose5"
Login.szSceneCameraName = "Main Camera"
local szCameraObjPathName = "/Npclight/choose4_cam/Camera001_Ctrl001"
local szCameraObjRootName = "/Npclight/choose4_cam"
local szSelectAniDefault = "all_s01"
local szAnimatorController = "select1"
local tbDirectionEffect = {
  "/Npclight/choose4_cam/Camera001_Ctrl001/Main Camera/Choose4_Camera001_Ctrl001_guangyun/changjing_guangyun_Z",
  "/Npclight/choose4_cam/Camera001_Ctrl001/Main Camera/Choose4_Camera001_Ctrl001_guangyun/changjing_guangyun_Y"
}
local tbModelCameraParam = {
  -20.43015,
  12.82514,
  71.63874,
  35,
  90,
  0,
  20
}
local tbModelStandPos = {
  -1076.234,
  81.7,
  22801.2,
  0,
  -137.9619,
  0
}
local tbButtlePosParam = {
  0,
  0,
  0,
  0,
  0,
  6
}
local fnActStandTime = 0.7
local tbNotDeleteEffectId = {
  [9076] = 1,
  [313] = 1,
  [406] = 1,
  [613] = 1,
  [706] = 1
}
Login.nBlackBgSoundId = 8015
local tbDefaultSelRoleInfo = {
  [1] = {
    szSceneSelObjName = "tw_dl",
    szCameraAniSelect = "tw_cam1",
    szFirstSelAniName = "tw_s01",
    szModelShowAniName = "denglu02",
    szFirstSelObjName = "tw_dld",
    fSelAniLen = 1.5,
    nSounId = 8016,
    szFaction = "天王",
    nSex = 0
  },
  [2] = {
    szSceneSelObjName = "em_dl",
    szCameraAniSelect = "em_cam1",
    szFirstSelAniName = "em_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "em_dld",
    fSelAniLen = 1.5,
    nSounId = 8017,
    szFaction = "峨眉",
    nSex = 1
  },
  [3] = {
    szSceneSelObjName = "th_dl",
    szCameraAniSelect = "th_cam1",
    szFirstSelAniName = "th_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "th_dld",
    fSelAniLen = 1.5,
    nSounId = 8018,
    szFaction = "桃花",
    nSex = 1
  },
  [4] = {
    szSceneSelObjName = "xy_dl",
    szCameraAniSelect = "xy_cam1",
    szFirstSelAniName = "xy_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "xy_dld",
    fSelAniLen = 1.5,
    nSounId = 8019,
    szFaction = "逍遥",
    nSex = 0
  },
  [5] = {
    szSceneSelObjName = "wd_dl",
    szCameraAniSelect = "wd_cam1",
    szFirstSelAniName = "wd_s01",
    szModelShowAniName = "Take 001",
    szFirstSelObjName = "wd_dld",
    fSelAniLen = 1.5,
    nSounId = 8020,
    szFaction = "武当",
    nSex = 0
  },
  [6] = {
    szSceneSelObjName = "tr_dl",
    szCameraAniSelect = "tr_cam1",
    szFirstSelAniName = "tr_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "tr_dld",
    fSelAniLen = 1.5,
    nSounId = 8021,
    szFaction = "天忍",
    nSex = 1
  },
  [7] = {
    szSceneSelObjName = "sl_dl",
    szCameraAniSelect = "sl_cam1",
    szFirstSelAniName = "sl_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "sl_dld",
    fSelAniLen = 1.5,
    nSounId = 8022,
    szFaction = "少林",
    nSex = 0
  },
  [8] = {
    szSceneSelObjName = "cy_dl",
    szCameraAniSelect = "cy_cam1",
    szFirstSelAniName = "cy_s01",
    szFirstSelObjName = "cy_dld",
    szFirstSelObjName1 = "/scenes/cy_dld/F4_001_h2",
    szFirstSelObjName2 = "/scenes/cy_dld/F4_001_h3",
    szModelShowAniName1 = "xiongmaodenglu",
    szModelShowAniName2 = "cy_denglu",
    fSelAniLen = 1.5,
    nSounId = 8023,
    szFaction = "翠烟",
    nSex = 1
  },
  [9] = {
    szSceneSelObjName = "tm_dl",
    szCameraAniSelect = "tm_cam1",
    szFirstSelAniName = "tm_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "tm_dld",
    fSelAniLen = 1.5,
    nSounId = 8040,
    szFaction = "唐门",
    nSex = 0
  },
  [10] = {
    szSceneSelObjName = "kl_dl",
    szCameraAniSelect = "kl_cam1",
    szFirstSelAniName = "kl_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "kl_dld",
    fSelAniLen = 1.5,
    nSounId = 8041,
    szFaction = "昆仑",
    nSex = 1
  },
  [11] = {
    szSceneSelObjName = "gaibang_dl",
    szCameraAniSelect = "gaibang_cam1",
    szFirstSelAniName = "gaibang_s01",
    szModelShowAniName = "denglu",
    szFirstSelObjName = "gaibang_dld",
    fSelAniLen = 1.5,
    nSounId = 5971,
    szFaction = "丐帮",
    nSex = 0
  },
  [12] = {
    szSceneSelObjName = "wudu_dl",
    szCameraAniSelect = "wudu_cam1",
    szFirstSelAniName = "wudu_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "wudu_dld",
    szFirstSelObjName1 = "/scenes/wudu_dld/wudu_denglu",
    szFirstSelObjName2 = "/scenes/wudu_dld/wudu_denglu2",
    szModelShowAniName1 = "denglu",
    szModelShowAniName2 = "Take 001",
    fSelAniLen = 1.5,
    nSounId = 5993,
    szFaction = "五毒",
    nSex = 1
  },
  [13] = {
    szSceneSelObjName = "cj_dl",
    szCameraAniSelect = "cj_cam1",
    szFirstSelAniName = "cj_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "cj_dld",
    fSelAniLen = 1.5,
    nSounId = 6010,
    szFaction = "藏剑",
    nSex = 0
  },
  [14] = {
    szSceneSelObjName = "cg_dl",
    szCameraAniSelect = "cg_cam1",
    szFirstSelAniName = "cg_s01",
    szModelShowAniName = "denglu01",
    szFirstSelObjName = "cg_dld",
    fSelAniLen = 1.5,
    nSounId = 6030,
    szFaction = "长歌",
    nSex = 1
  }
}
Login.SERVER_TYPE_NORMAL = 0
Login.SERVER_TYPE_OFFLINE = 1
Login.SERVER_TYPE_RECOMMAND = 2
Login.SERVER_TYPE_NEW = 3
Login.SERVER_TYPE_HOT = 4
Login.SERVER_TYPE_BUSY = 5
Login.ACCOUNT_MAX_ROLE_COUNT = 6
Login.SOUND_BG = {
  10,
  11,
  12,
  17
}
if version_vn then
  Login.SOUND_BG = {
    10,
    11,
    12,
    14,
    16,
    21
  }
end
local tbStandPos = {
  3,
  5,
  1,
  2,
  4,
  6
}
function Login:OpenLoginScene(bShowLoading)
  self.tbSelRoleInfo = Lib:CopyTB(tbDefaultSelRoleInfo)
  self.bMapLoaded = false
  self.bRoleListDone = false
  if bShowLoading then
    Ui:OpenWindow("MapLoading", 0, me.nMapTemplateId)
  end
  if SceneMgr.s_nMapTemplateID == 0 then
    self:BackToRoleList(true)
    self:OnMapLoaded()
  elseif bShowLoading then
    Ui.ToolFunction.LoadMap(self.szSceneMapName, self.szSceneCameraName, 0, false)
  else
    Ui:OpenWindow("MapLoading", 0, 0)
  end
  Ui:PreLoadWindow("CreateRole")
end
function Login:OnSyncRoleListDone()
  Log(">>> role list done !!")
  if self.nCurSelNpc then
    return
  end
  self.bRoleListDone = true
  local tbRole = GetRoleList()
  local tbReportRoleList = {}
  for i, v in ipairs(tbRole) do
    local tbSelInfo = self.tbSelRoleInfo[v.nFaction]
    if not tbSelInfo.tbCreateRole then
      tbSelInfo.tbCreateRole = v
    else
      if not tbSelInfo.tbCreateRole.tbOhters then
        local tbTemp = Lib:CopyTB(tbSelInfo.tbCreateRole)
        tbSelInfo.tbCreateRole.tbOhters = {}
        table.insert(tbSelInfo.tbCreateRole.tbOhters, tbTemp)
      end
      table.insert(tbSelInfo.tbCreateRole.tbOhters, v)
    end
    table.insert(tbReportRoleList, {
      role_id = v.nRoleID,
      role_name = v.szName
    })
  end
  self.szReportRoleList = Lib:EncodeJson(tbReportRoleList)
  SdkMgr.ReportDataLoadRole("0", Sdk:GetCurAppId(), tostring(SERVER_ID), self.szReportRoleList, 2)
  self:OnRoleListDoneAndMapLoaded()
end
function Login:ClearNpcs()
  for i, v in ipairs(self.tbSelRoleInfo) do
    if v.nNpcViewId then
      NpcViewMgr.DestroyUiViewFeature(v.nNpcViewId)
      v.nNpcViewId = nil
    end
    AvatarHeadInfoMgr.DestroyAvatarHeadInfo(v.szFirstSelObjName)
  end
  self:ClearTimers()
end
local function fnOpenCreateRoleWindow(tbRoleInfo, nNpcId, bPlayAni, bCanClick)
  local tbParam = {}
  tbParam.tbRoleInfo = tbRoleInfo
  tbParam.nNpcId = nNpcId
  tbParam.bPlayAni = bPlayAni
  tbParam.tbSelRoleInfo = Login.tbSelRoleInfo
  tbParam.bHasNoCreateRole = Login.bHasNoCreateRole or bCanClick
  if Ui:WindowVisible("CreateRole") == 1 then
    if bPlayAni then
      Ui("CreateRole"):PlayUiAnimation("CreateRolePanel")
    else
      Ui("CreateRole"):OnOpen(tbParam)
    end
  else
    Ui:OpenWindow("CreateRole", tbParam)
  end
  if nNpcId then
    AvatarHeadInfoMgr.SetAvatarHeadInfoVisible(tbRoleInfo.szFirstSelObjName, true)
  end
end
function Login:UpdateRoleHeadInfo(nFaction, tbCreateRole)
  local szBanInfo = ""
  if tbCreateRole.nBanEndTime < 0 or tbCreateRole.nBanEndTime > 0 and tbCreateRole.nBanEndTime > GetTime() then
    szBanInfo = "(已冻结)"
  end
  local v = self.tbSelRoleInfo[nFaction]
  AvatarHeadInfoMgr.SetAvatarHeadInfo(v.szFirstSelObjName, tbCreateRole.szName, szBanInfo, string.format("%d级", tbCreateRole.nLevel))
end
function Login:OnRoleListDoneAndMapLoaded()
  if not self.bMapLoaded or not self.bRoleListDone then
    return
  end
  for nFaction, v in pairs(self.tbSelRoleInfo) do
    AvatarHeadInfoMgr.AddHeadUiToGameObj(v.szFirstSelObjName)
    local tbCreateRole = v.tbCreateRole
    if tbCreateRole then
      self:UpdateRoleHeadInfo(nFaction, tbCreateRole)
    else
      AvatarHeadInfoMgr.SetAvatarHeadInfo(v.szFirstSelObjName, "", "", "")
    end
    AvatarHeadInfoMgr.SetAvatarHeadInfoVisible(v.szFirstSelObjName, false)
  end
  self.bMapLoaded = nil
  self.bRoleListDone = nil
  local bHasNoCreateRole = true
  for i, v in ipairs(self.tbSelRoleInfo) do
    if v.tbCreateRole then
      bHasNoCreateRole = false
      break
    end
  end
  self.bHasNoCreateRole = bHasNoCreateRole
  local tbUi = Ui("Login") or Ui("MapLoading")
  if tbUi then
    local tbSceenszie = tbUi.pPanel:Panel_GetSize("Main")
    if tbSceenszie.y ~= 0 then
      local fnFov = -8.982446054797416 * (tbSceenszie.x / tbSceenszie.y - 1.778646) + 26
      if fnFov > 0 then
        Ui.CameraMgr.DirectChangeCameraFov(fnFov)
      end
    end
  end
  Ui:CloseWindow("Login")
  if not bHasNoCreateRole then
    self:OnPlayCGEnd()
  else
    Ui.CameraMgr.SetMainCameraActive(false)
    Ui.ToolFunction.PlayCGMovie(true)
  end
end
function Login:OnPlayCGEnd()
  Ui:CloseWindow("LoginBg")
  Ui.UiManager.DestroyUi("LoginBg")
  Ui.CameraMgr.SetMainCameraActive(true)
  Ui:UpdateSoundSetting()
  self.nCurSelNpc = nil
  for i, v in ipairs(self.tbSelRoleInfo) do
    if v.tbCreateRole then
    end
  end
  local tbLastLoginfo = Client:GetUserInfo("LoginRole", -1)
  local tbRoles = GetRoleList()
  local dwRoleId = tbLastLoginfo[GetAccountName()]
  if dwRoleId then
    local bFind = false
    for i, v in ipairs(tbRoles) do
      if v.nRoleID == dwRoleId then
        bFind = true
        break
      end
    end
    if not bFind then
      dwRoleId = nil
    end
  end
  if not dwRoleId then
    local nMaxLevel = 0
    for i, v in ipairs(tbRoles) do
      if nMaxLevel < v.nLevel then
        dwRoleId = v.nRoleID
        nMaxLevel = v.nLevel
      end
    end
  end
  local bHasNoCreateRole = true
  if dwRoleId then
    for i, v in ipairs(self.tbSelRoleInfo) do
      if v.tbCreateRole then
        if v.tbCreateRole.nRoleID == dwRoleId then
          bHasNoCreateRole = false
        elseif v.tbCreateRole.tbOhters then
          for nIndex, v2 in ipairs(v.tbCreateRole.tbOhters) do
            if v2.nRoleID == dwRoleId then
              self:SwitchRoleSelIndex(v.tbCreateRole, nIndex)
              bHasNoCreateRole = false
              break
            end
          end
        end
        if not bHasNoCreateRole then
          self:SelRole(i, true)
          break
        end
      end
    end
  end
  if bHasNoCreateRole then
    self.bHasNoCreateRole = true
    local nDefaultSel = IS_OLD_SERVER and MathRandom(#self.tbSelRoleInfo - 2) or MathRandom(#self.tbSelRoleInfo)
    self:SelRole(nDefaultSel, false)
  end
  self.bHasNoCreateRole = nil
end
function Login:SwitchRoleSelIndex(tbCreateRole, nIndex)
  local tbOhters = tbCreateRole.tbOhters
  if tbOhters and nIndex then
    local v = tbOhters[nIndex]
    if v then
      local tbReapalce = Lib:CopyTB(v)
      for k2, v2 in pairs(tbReapalce) do
        tbCreateRole[k2] = v2
      end
      local tbNewtbOhters = {tbReapalce}
      for i = nIndex + 1, #tbOhters do
        table.insert(tbNewtbOhters, tbOhters[i])
      end
      for i = 1, nIndex - 1 do
        table.insert(tbNewtbOhters, tbOhters[i])
      end
      tbCreateRole.tbOhters = tbNewtbOhters
      Login:UpdateRoleHeadInfo(tbCreateRole.nFaction, tbCreateRole)
    end
  end
end
function Login:PlayFirsetCamerAni()
end
function Login:OnMapLoaded()
  if not IOS and Ui:WindowVisible("MapLoading") == 1 then
    Ui.CameraMgr.SetMainCameraActive(false)
  end
  self.bMapLoaded = true
  self.nCurSelNpc = nil
  for nFaction, v in pairs(self.tbSelRoleInfo) do
    v.tbCreateRole = nil
    if v.szSceneObjName then
    end
  end
  self:PlayFirsetCamerAni()
  Ui:PreloadUiList()
  Ui:OpenWindow("LoginBg")
  Ui:CloseWindow("MessageBox")
  self:OnRoleListDoneAndMapLoaded()
end
function Login:ClearTimers()
end
function Login:SelRole(nNpcId, bAtuoChoose)
  if self.nCurSelNpc == nNpcId then
    return
  end
  self:ClearTimers()
  local v = self.tbSelRoleInfo[nNpcId]
  assert(v)
  Ui:CloseWindow("CreateRole")
  Ui:CloseWindow("ShowSkillPreView")
  local nDelayTime = 0
  if not self.nCurSelNpc then
    if not bAtuoChoose then
      Ui:PlaySceneSound(Login.nBlackBgSoundId)
      Ui:OpenWindow("BgBlackAll")
      Timer:Register(5, function()
        Ui:CloseWindow("BgBlackAll")
        RepresentMgr.SetSceneObjActive(v.szSceneSelObjName, true)
        Ui:PlayUISound(v.nSounId)
        local fAniLength = RepresentMgr.PlayActivedSceneAnimation(szCameraObjRootName, v.szCameraAniSelect)
        Timer:Register(Env.GAME_FPS * fAniLength, function()
          fnOpenCreateRoleWindow(v, nNpcId)
        end)
      end)
    else
      RepresentMgr.SetSceneObjActive(v.szFirstSelObjName, true)
      RepresentMgr.PlayActivedSceneAnimation(szCameraObjRootName, v.szCameraAniSelect)
      if v.szFirstSelObjName2 and v.szModelShowAniName2 then
        RepresentMgr.SetActivedSceneAnimationEnd(v.szFirstSelObjName1, v.szModelShowAniName1)
        RepresentMgr.SetActivedSceneAnimationEnd(v.szFirstSelObjName2, v.szModelShowAniName2)
      else
        RepresentMgr.SetActivedSceneAnimationEnd(v.szFirstSelObjName, v.szModelShowAniName)
      end
      RepresentMgr.SetActivedSceneAnimationEnd(szCameraObjRootName, v.szCameraAniSelect)
      fnOpenCreateRoleWindow(v, nNpcId)
    end
  else
    local v_old = self.tbSelRoleInfo[self.nCurSelNpc]
    RepresentMgr.SetSceneObjActive(v_old.szSceneSelObjName, false)
    RepresentMgr.SetSceneObjActive(v_old.szFirstSelObjName, false)
    AvatarHeadInfoMgr.SetAvatarHeadInfoVisible(v_old.szFirstSelObjName, false)
    Ui:OpenWindow("BgBlackAll")
    Timer:Register(5, function()
      Ui:CloseWindow("BgBlackAll")
      RepresentMgr.SetSceneObjActive(v.szSceneSelObjName, true)
      Ui:PlayUISound(v.nSounId)
      local fAniLength = RepresentMgr.PlayActivedSceneAnimation(szCameraObjRootName, v.szCameraAniSelect)
      Timer:Register(Env.GAME_FPS * fAniLength, function()
        fnOpenCreateRoleWindow(v, nNpcId)
      end)
    end)
  end
  self.nCurSelNpc = nNpcId
end
function Login:HideAllSkillPreview()
  NpcViewMgr.SetCameraActive(false)
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_LOAD_RES_FINISH, self)
  for i, v in ipairs(self.tbSelRoleInfo) do
    if v.nNpcViewId then
      NpcViewMgr.SetUiViewFeatureActive(v.nNpcViewId, false)
    end
  end
  if self.nPreviewActIndex and self.nCurSelNpc then
    local v = self.tbSelRoleInfo[self.nCurSelNpc]
    if v.nNpcViewId then
      NpcViewMgr.HideEffect(v.nNpcViewId, true)
    end
  end
  if self.nPreviewTimer then
    Timer:Close(self.nPreviewTimer)
    self.nPreviewTimer = nil
  end
  if self.nPreviewEndTimer then
    Timer:Close(self.nPreviewEndTimer)
    self.nPreviewEndTimer = nil
  end
end
local fnPreLoadActEffectRes = function(tbAct)
  if not tbAct then
    return
  end
  local nEffectId = tbAct[3]
  if nEffectId then
    PreloadResource:AddPreloadEffectRes(0, nEffectId)
  end
  for i = 4, #tbAct do
    local delay, effectid, bullectTime = unpack(tbAct[i])
    PreloadResource:AddPreloadEffectRes(0, effectid)
  end
end
function Login:StartPlayerActAni()
  local v = self.tbSelRoleInfo[self.nCurSelNpc]
  local nViewId = v.nNpcViewId
  if not nViewId then
    return
  end
  local tbAct = v.tbSkillPreviewActName[self.nPreviewActIndex]
  local nAntiTime = tbAct[2]
  if nAntiTime ~= 0 then
    NpcViewMgr.PlayAnimation(nViewId, tbAct[1], 0.1, 2)
  else
    nAntiTime = NpcViewMgr.PlayAnimation(nViewId, tbAct[1], 0.1, 1)
  end
  local nEffectId = tbAct[3]
  if nEffectId then
    if tbNotDeleteEffectId[nEffectId] then
      NpcViewMgr.PlayNpcEffect(nViewId, nEffectId)
    else
      NpcViewMgr.PlayNpcEffectBullect(nViewId, nEffectId)
    end
    for i = 4, #tbAct do
      local delay, effectid, bullectTime = unpack(tbAct[i])
      if delay > 0 then
        Timer:Register(math.floor(Env.GAME_FPS * delay), function()
          NpcViewMgr.PlayNpcEffectBullect(nViewId, effectid, bullectTime, unpack(tbButtlePosParam))
        end)
      else
        NpcViewMgr.PlayNpcEffectBullect(nViewId, effectid, bullectTime, unpack(tbButtlePosParam))
      end
    end
  end
  fnPreLoadActEffectRes(v.tbSkillPreviewActName[self.nPreviewActIndex + 2])
  assert(nAntiTime > 0)
  self.nPreviewTimer = Timer:Register(math.floor(Env.GAME_FPS * nAntiTime), function()
    self.nPreviewTimer = nil
    self:PreviewPlayerAniEnd()
  end)
end
function Login:PreviewPlayerAniEnd()
  local v = self.tbSelRoleInfo[self.nCurSelNpc]
  local nViewId = v.nNpcViewId
  if not nViewId then
    return
  end
  NpcViewMgr.HideEffect(nViewId)
  local tbAct = v.tbSkillPreviewActName[self.nPreviewActIndex + 1]
  if tbAct and string.find(tbAct[1], "at") then
    self:PreviewPlayerAniNext()
    return
  end
  NpcViewMgr.PlayAnimation(nViewId, "st", 0.3, 2)
  self.nPreviewEndTimer = Timer:Register(math.floor(Env.GAME_FPS * fnActStandTime), function()
    self.nPreviewEndTimer = nil
    self:PreviewPlayerAniNext()
  end)
end
function Login:PreviewPlayerAniNext()
  local v = self.tbSelRoleInfo[self.nCurSelNpc]
  local nViewId = v.nNpcViewId
  if not nViewId then
    return
  end
  self.nPreviewActIndex = self.nPreviewActIndex + 1
  local tbAct = v.tbSkillPreviewActName[self.nPreviewActIndex]
  if not tbAct then
    Ui:OpenWindow("ShowSkillPreView")
    return
  end
  self:StartPlayerActAni()
end
function Login:PreviewLoadBodyFinish(nViewId, bNotFirst)
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_LOAD_RES_FINISH, self)
  local v = self.tbSelRoleInfo[self.nCurSelNpc]
  if v.nNpcViewId ~= nViewId then
    return
  end
  assert(Ui:WindowVisible("ShowSkillPreView") == 1)
  self.nPreviewActIndex = 1
  if bNotFirst then
    self:StartPlayerActAni()
  else
    Timer:Register(5, function()
      self:StartPlayerActAni()
    end)
  end
  Ui("ShowSkillPreView"):OnPlay()
end
function Login:ShowSkillPreview()
  assert(self.nCurSelNpc)
  assert(Ui:WindowVisible("ShowSkillPreView") == 1)
  local v = self.tbSelRoleInfo[self.nCurSelNpc]
  if v.nNpcViewId then
    NpcViewMgr.SetUiViewFeatureActive(v.nNpcViewId, true)
    self:PreviewLoadBodyFinish(v.nNpcViewId, true)
  else
    fnPreLoadActEffectRes(v.tbSkillPreviewActName[1])
    fnPreLoadActEffectRes(v.tbSkillPreviewActName[2])
    v.nNpcViewId = NpcViewMgr.CreateSceneViewFeature(unpack(tbModelStandPos))
    local tbPlayerInfo = KPlayer.GetPlayerInitInfo(self.nCurSelNpc)
    NpcViewMgr.ChangePartBody(v.nNpcViewId, tbPlayerInfo.nBodyResId)
    NpcViewMgr.ChangeNpcPart(v.nNpcViewId, 1, tbPlayerInfo.nWeaponResId)
    UiNotify:RegistNotify(UiNotify.emNOTIFY_LOAD_RES_FINISH, self.PreviewLoadBodyFinish, self)
  end
  NpcViewMgr.SetCameraActive(true)
end
function Login:SelPreNpc()
  local nStandPos = 1
  for i, v in ipairs(tbStandPos) do
    if v == self.nCurSelNpc then
      nStandPos = i
      break
    end
  end
  local nNext = nStandPos + 1
  if nNext > #tbStandPos then
    nNext = 1
  end
  self:SelRole(tbStandPos[nNext])
end
function Login:SelNexNpc()
  local nStandPos = 1
  for i, v in ipairs(tbStandPos) do
    if v == self.nCurSelNpc then
      nStandPos = i
      break
    end
  end
  local nPre = nStandPos - 1
  if nPre < 1 then
    nPre = #tbStandPos
  end
  self:SelRole(tbStandPos[nPre])
end
function Login:BackToRoleList(bHideWindow)
  if not bHideWindow then
    fnOpenCreateRoleWindow(nil, nil, nil, true)
  end
  if self.nCurSelNpc then
    RepresentMgr.SetSceneObjActive(self.tbSelRoleInfo[self.nCurSelNpc].szSceneSelObjName, false)
    RepresentMgr.SetSceneObjActive(self.tbSelRoleInfo[self.nCurSelNpc].szFirstSelObjName, false)
    self.nCurSelNpc = nil
  end
  self:PlayFirsetCamerAni()
end
function Login:EnterXinShouFuben()
  assert(self.nCurSelNpc)
  local v = self.tbSelRoleInfo[self.nCurSelNpc]
  if XinShouLogin:CheckEnterFuben(self.nCurSelNpc) then
    Ui:CloseWindow("CreateRole")
  end
  XinShouLogin:EnterFuben(self.nCurSelNpc)
end
function Login:LoginRole(dwRoleId)
  assert(self.nCurSelNpc)
  local tbLastLoginfo = Client:GetUserInfo("LoginRole", -1)
  tbLastLoginfo[GetAccountName()] = dwRoleId
  if me.nMapTemplateId ~= 0 then
    LoginRole(dwRoleId)
    Lib:CallBack({
      Pandora.OnLogin,
      Pandora,
      dwRoleId,
      self.nCurSelNpc
    })
    return
  end
  SdkMgr.SetReportTime()
  LoginRole(dwRoleId)
  if not self.nTimerCheckTimeOutLogin then
    self.nTimerCheckTimeOutLogin = Timer:Register(Env.GAME_FPS * 4, function()
      self.nTimerCheckTimeOutLogin = nil
      if not PlayerEvent.bLogin then
        SdkMgr.ReportDataEnterGame("98002", Sdk:GetCurAppId(), tostring(SERVER_ID), Login.szReportRoleList)
      end
    end)
  end
  Lib:CallBack({
    Pandora.OnLogin,
    Pandora,
    dwRoleId,
    self.nCurSelNpc
  })
end
function Login:Init()
  self.tbRandomName1 = LoadTabFile("Setting/RandomName/Xing.tab", "s", nil, {"Name"})
  self.tbRandomName2 = LoadTabFile("Setting/RandomName/Ming.tab", "s", nil, {"Name"})
  self.tbRandomName3 = LoadTabFile("Setting/RandomName/Female.tab", "s", nil, {"Name"})
  if not self.tbRandomName1 or not self.tbRandomName2 then
    Log("error Login:Init , load RandomName ")
  end
  Login.tbAccSerInfo = {}
  self.ClientSet = Lib:LoadIniFile("Setting/Client.ini")
  self.ClientSet.Network.GatewayPort = tonumber(self.ClientSet.Network.GatewayPort)
  self.ClientSet.Sdk.Skip = self.ClientSet.Sdk.Skip == "1"
end
if not Login.tbRandomName1 then
  Login:Init()
end
function Login:GetRandomName(nSex, nFaction)
  if nFaction then
    nSex = self.tbSelRoleInfo[nFaction].nSex
  end
  local nPreIndx = MathRandom(#self.tbRandomName1)
  local tbRandomMing = self.tbRandomName2
  if nSex and nSex == 1 then
    tbRandomMing = self.tbRandomName3
  end
  local nSuffiIndx = MathRandom(#tbRandomMing)
  local szName = tbRandomMing[nSuffiIndx].Name
  for i = 1, 3 do
    szName = self.tbRandomName1[nPreIndx].Name .. tbRandomMing[nSuffiIndx].Name
    if CheckNameAvailable(szName) then
      break
    end
  end
  return szName
end
function Login:CheckNameinValid(szName)
  if not szName or szName == "" then
    Ui:OpenWindow("MessageBox", "请输入您的角色名")
    return
  end
  if version_tx then
    local nlen = Lib:Utf8Len(szName)
    if nlen < 2 or nlen > 6 then
      Ui:OpenWindow("MessageBox", "名字长度需要在2~6个汉字内")
      return
    end
    if string.find(szName, "%w") then
      Ui:OpenWindow("MessageBox", "名字长度需要在2~6个汉字内")
      return
    end
    if not CheckNameAvailable(szName) then
      Ui:OpenWindow("MessageBox", "名字中包含非法字符")
      return
    end
  elseif version_th and MAX_ROLE_NAME_LEN > 42 then
    local szNameLen = Lib:Utf8Len(szName)
    if szNameLen < 4 then
      Ui:OpenWindow("MessageBox", "您的名字太短")
      return
    end
    if szNameLen > 14 then
      Ui:OpenWindow("MessageBox", "您的名字过长")
      return
    end
    if not CheckNameAvailable(szName) then
      Ui:OpenWindow("MessageBox", "名字中包含非法字符")
      return
    end
    if string.find(szName, "^%d") then
      Ui:OpenWindow("MessageBox", "名字不可以数字开头")
      return
    end
  else
    local szNameLen = string.len(szName)
    if version_vn and szNameLen < 6 then
      Ui:OpenWindow("MessageBox", "您的名字太短")
      return
    end
    if szNameLen > 18 then
      Ui:OpenWindow("MessageBox", "您的名字过长")
      return
    end
    if not CheckNameAvailable(szName) then
      Ui:OpenWindow("MessageBox", "名字中包含非法字符")
      return
    end
    if string.find(szName, "^%d") then
      Ui:OpenWindow("MessageBox", "名字不可以数字开头")
      return
    end
  end
  return true
end
function Login:OnSynAccSerInfo(...)
  local tbData = {}
  for i, v in ipairs({
    ...
  }) do
    tbData[v[1]] = v[2]
  end
  Login.tbAccSerInfo[GetAccountName()] = tbData
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_ACC_SER_INFO)
end
function Login:GetAccSerInfo()
  return Login.tbAccSerInfo[GetAccountName()] or {}
end
Login.tbCREATE_ROLE_RESPOND_CODE = {
  "已经有大侠叫这个名字了！请重新输入！",
  "名字中包含非法字符，请重新输入",
  "角色名必须是2-6个字，请重新输入",
  "角色名必须是2-6个字，请重新输入",
  "服务器人数过多，无法创建新角色",
  "无法创建角色",
  "服务器关闭创建角色功能",
  "此名字只能由指定帐号使用",
  string.format("一个帐号下最多创建%d个角色", Login.ACCOUNT_MAX_ROLE_COUNT)
}
function Login:OnCreateRoleRespond(nCode, nRoleID)
  if nCode ~= 0 then
    Ui:OpenWindow("MessageBox", self.tbCREATE_ROLE_RESPOND_CODE[nCode] or "未知错误！创建角色失败！", {
      {}
    }, {"同意"})
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_CREATE_ROLE_RESPOND, nCode, nRoleID)
  Log("OnCreateRoleRespond", nCode, nRoleID)
end
function Login:PlaySceneSound()
  if not self.nBackSoundPlayed then
    local tbLoginMusic = Client:GetUserInfo("LoginMusicIndex", -1)
    local nIndex = tbLoginMusic[1] or 0
    nIndex = nIndex + 1
    if nIndex > #self.SOUND_BG then
      nIndex = 1
    end
    Ui:PlaySceneSound(self.SOUND_BG[nIndex])
    tbLoginMusic[1] = nIndex
    Client:SaveUserInfo()
    self.nBackSoundPlayed = self.SOUND_BG[nIndex]
  end
end
function Login:StopSceneSound()
  if self.nBackSoundPlayed then
    Ui:StopSceneSound(self.nBackSoundPlayed)
  end
  self.nBackSoundPlayed = nil
end
function Login:CheckShowUserProtol()
  if not version_tx then
    return
  end
  local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
  if tbInfo[1] then
    return
  end
  Ui:OpenWindow("AgreementPanel")
end
function Login:AllowLogin()
  local nNextLoginTime = Client:GetFlag("NextLoginTime") or 0
  local nLeftWaitingTime = nNextLoginTime - os.time()
  local fnWait = function()
  end
  local fnTimeUp = function()
    Ui:CloseWindow("MessageBox")
  end
  if nLeftWaitingTime > 0 then
    Ui:OpenWindow("MessageBox", "由于连续登录失败多次\n请于[ffff00]%d[-]秒后进行尝试", {
      {fnWait},
      nil,
      {fnTimeUp}
    }, {"确认"}, nil, nLeftWaitingTime)
  end
  return nLeftWaitingTime <= 0
end
function Login:SetNextLoginTime()
  local nFailCount = Client:GetFlag("LoginFailCount") or 0
  nFailCount = nFailCount + 1
  Client:SetFlag("LoginFailCount", nFailCount)
  local nNextLoginTime = os.time()
  if nFailCount >= 6 and version_tx then
    nNextLoginTime = nNextLoginTime + 300
  elseif nFailCount >= 3 then
    nNextLoginTime = nNextLoginTime + 10
  end
  Client:SetFlag("NextLoginTime", nNextLoginTime)
end
function Login:ResetNextLoginTime()
  Client:ClearFlag("NextLoginTime")
  Client:ClearFlag("LoginFailCount")
end
function Login:ConnectGateWay(szAccount, szAuthInfo, nPlatfrom)
  local NetworkSet = Login.ClientSet.Network
  local szGatewayIP = NetworkSet.GatewayIP
  local nGatewayPort = NetworkSet.GatewayPort
  if Sdk:IsLoginByQQ() then
    if IOS or Sdk:IsLoginForIOS() then
      szGatewayIP = NetworkSet.iOSQQGatewayIP or szGatewayIP
      nGatewayPort = tonumber(NetworkSet.iOSQQGatewayPort) or nGatewayPort
    else
      szGatewayIP = NetworkSet.AndroidQQGatewayIP or szGatewayIP
      nGatewayPort = tonumber(NetworkSet.AndroidQQGatewayPort) or nGatewayPort
    end
  elseif Sdk:IsLoginByWeixin() then
    if IOS or Sdk:IsLoginForIOS() then
      szGatewayIP = NetworkSet.iOSWXGatewayIP or szGatewayIP
      nGatewayPort = tonumber(NetworkSet.iOSWXGatewayPort) or nGatewayPort
    else
      szGatewayIP = NetworkSet.AndroidWXGatewayIP or szGatewayIP
      nGatewayPort = tonumber(NetworkSet.AndroidWXGatewayPort) or nGatewayPort
    end
  elseif Sdk:IsLoginByGuest() then
    szGatewayIP = NetworkSet.GuestGatewayIP or szGatewayIP
    nGatewayPort = tonumber(NetworkSet.GuestGatewayPort) or nGatewayPort
  end
  szGatewayIP = Ui.FTDebug.szGatewayIP == "" and szGatewayIP or Ui.FTDebug.szGatewayIP
  nGatewayPort = Ui.FTDebug.nGatewayPort <= 0 and nGatewayPort or Ui.FTDebug.nGatewayPort
  Login:ClearFreeFlowInfo()
  Login:ClearPfLoginInfo()
  if Sdk:IsLoginForIOS() then
    local bPCVersion, szRegisterChannel, szInstallChannel, szOfferId = Sdk:GetLoginExtraInfo()
    ConnectGateway(szGatewayIP, nGatewayPort, szAccount, szAuthInfo, nPlatfrom or Sdk.ePlatform_None, bPCVersion, szRegisterChannel, szInstallChannel, szOfferId)
  else
    ConnectGateway(szGatewayIP, nGatewayPort, szAccount, szAuthInfo, nPlatfrom or Sdk.ePlatform_None)
  end
  local nLoginWaitingTime = version_xm and 15 or 8
  Ui:OpenWindow("LoadingTips", "正在登录剑侠情缘..", nLoginWaitingTime, function()
    Login:SetNextLoginTime()
    Ui:AddCenterMsg("登入超时, 请重新登入")
    Ui:CloseWindow("LoadingTips")
  end)
end
function Login:GetEquipId()
  if ANDROID then
    return Ui.UiManager.GetEquipId() or ""
  elseif IOS then
    return GetAppleEquipId() or ""
  else
    return "PC"
  end
end
function Login:GetICCID()
  if ANDROID then
    return Ui.UiManager.GetICCID() or ""
  elseif IOS then
    return ""
  else
    return ""
  end
end
function Login:GetPhoneBasicInfo()
  local szModel, nPlatfrom, nNetWorkType, nTelecomOper, nPlatFriends, nGameVersion = "PC", 2, 0, 0, #FriendShip.tbPlatFriendsInfo, GAME_VERSION
  local szEquipId = Login:GetEquipId()
  local nLoginChanalId = Sdk:GetLoginChannelId()
  if ANDROID then
    szModel = Ui.ToolFunction.GetPhoneModel()
    nPlatfrom = 1
    nNetWorkType = Ui.ToolFunction.GetNetWorkType()
    nTelecomOper = Ui.ToolFunction.GetTelecomOper()
  elseif IOS then
    szModel = GetAppleModelName()
    nPlatfrom = 0
    nNetWorkType = GetAppletNetWorkType()
    nTelecomOper = GetAppletTelecomOper()
  end
  szEquipId = tostring(szEquipId) or "unkown"
  szModel = tostring(szModel) or "unkown"
  szEquipId = Sdk:IsPCVersion() and Sdk:GetAssistChannelId() or szEquipId
  return szEquipId, szModel, nPlatfrom, nNetWorkType, nTelecomOper, nLoginChanalId, nPlatFriends, nGameVersion, Sdk:GetMsdkInfoStr() or "{}"
end
function Login:GetLoginRoleProtocolParams()
  local nIsEmulator = 0
  if ANDROID then
    nIsEmulator = Ui.ToolFunction.IsEmulator() and 1 or 0
  end
  return nIsEmulator
end
function Login:GetIDFA()
  if IOS then
    return GetAppleIdfa() or ""
  end
  return ""
end
Login.tbXinshouTransmitData = {
  gamename = "jxft",
  os = "other",
  channelcode = Sdk:GetLoginChannelId(),
  equdid = Login:GetEquipId(),
  dbname = "",
  stat_time = "2015-03-09 15:00:00",
  accountid = "",
  roleid = "",
  msg = "",
  eventid = 800
}
if ANDROID then
  Login.tbXinshouTransmitData.os = "android"
elseif IOS then
  Login.tbXinshouTransmitData.os = "ios"
end
function Login:PostXinshouFubenData(nIndex)
  local tbData = self.tbXinshouTransmitData
  tbData.stat_time = os.date("%Y-%m-%d %H:%M:%S")
  tbData.accountid = GetAccountName()
  tbData.roleid = me.dwID
  tbData.msg = string.format("unlock:%d", nIndex)
  tbData.dbname = Client:GetCurServerInfo()
  Ui.UiManager.PostWebRequest(Lib:EncodeJson(tbData))
end
function Login:OnNotifyAccountBanned(banTime, szErrorMsg)
  local szMsgBoxType = "MessageBox"
  local nPivot
  local szMsg = ""
  if banTime == -100 then
    szMsgBoxType = "MessageBoxBig"
    nPivot = 3
    szMsg = szErrorMsg ~= "" and szErrorMsg or XT("您的账号已被家长设定为暂时无法登录游戏。\n如有疑问，请拨打服务热线0755-86013799进行咨询。共筑绿色健康游戏环境，感谢您的理解与支持。")
  else
    szErrorMsg = szErrorMsg or "违反游戏规则"
    local szErrorMsg, nNoTimeNotice = string.gsub(szErrorMsg, "(%[no_time_notice%])", "")
    if banTime == -1 then
      szMsg = string.format(XT("%s, 被永久冻结。"), szErrorMsg)
    elseif banTime == -2 or nNoTimeNotice > 0 then
      szMsg = szErrorMsg
    else
      szMsg = string.format(XT("%s，解除时间: %s。"), szErrorMsg, Lib:GetTimeStr3(banTime))
    end
  end
  Ui:OpenWindow(szMsgBoxType, szMsg, nil, nil, nPivot)
end
function Login:IsAutoLogin()
  return not self.bIgnoreAutoLogin
end
function Login:SetAutoLogin(bAuto)
  self.bIgnoreAutoLogin = not bAuto
end
function Login:ClearFreeFlowInfo()
  self.bFreeFlow = nil
  self.szFreeFlowWorldIp = nil
  self.szFreeFlowFileServerIp = nil
end
function Login:IsFreeFlow()
  return self.bFreeFlow or false
end
function Login:FreeFlowReceived()
  return self.bFreeFlow ~= nil
end
function Login:GetFileServerFreeIp()
  if self.bFreeFlow then
    return self.szFreeFlowFileServerIp
  end
end
function Login:SetFreeFlowInfo(nFree, szFreeIp)
  Log("Login:SetFreeFlowInfo", nFree, szFreeIp)
  self.bFreeFlow = nFree == 1
  local tbFreeFlowIp = Lib:SplitStr(szFreeIp, ";")
  self.szFreeFlowWorldIp = tbFreeFlowIp[1]
  self.szFreeFlowFileServerIp = tbFreeFlowIp[2]
  Log("FreeFlowWorldUrl:", self.szFreeFlowWorldIp)
  Log("FreeFlowFileServerUrl:", self.szFreeFlowFileServerIp)
end
function Login:LoginServerRsp(szAddr, nPort)
  Log("Login:LoginServerRsp", szAddr, nPort)
  if self.bFreeFlow and self.szFreeFlowWorldIp then
    szAddr = self.szFreeFlowWorldIp
  end
  ConnectWorldServer(szAddr, nPort)
end
function Login:CheckRoleCountLimit()
  local tbRole = GetRoleList()
  if #tbRole >= self.ACCOUNT_MAX_ROLE_COUNT then
    Ui:OpenWindow("MessageBox", string.format("每个帐号下最多创建%d个角色，少侠可以在游戏内对已有角色进行转门派操作", self.ACCOUNT_MAX_ROLE_COUNT))
    return
  end
  return true
end
function Login:OnQueryPfInfoRsp(szPfInfoJson)
  Log("OnQueryPfInfoRsp", szPfInfoJson)
  local tbPfInfo = Lib:DecodeJson(szPfInfoJson) or {}
  if tbPfInfo.ret ~= 0 then
    me.CenterMsg(tbPfInfo.msg)
    return
  end
  Sdk:SetServerPfInfo(tbPfInfo.pf, tbPfInfo.pfKey)
  if self.nGateWayVerrifyRetCode then
    UiNotify.OnNotify(UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP, self.nGateWayVerrifyRetCode)
  end
end
function Login:OnGatewayHandSuccess(nRetCode)
  Log("OnGatewayHandSuccess", nRetCode)
  if not Sdk:IsLoginForIOS() or nRetCode ~= 0 then
    UiNotify.OnNotify(UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP, nRetCode)
    return
  end
  if Sdk:HasServerPfInfo() then
    UiNotify.OnNotify(UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP, nRetCode)
  else
    self.nGateWayVerrifyRetCode = nRetCode
  end
end
function Login:ClearPfLoginInfo()
  self.nGateWayVerrifyRetCode = nil
  Sdk:SetServerPfInfo(nil, nil)
end
if not Login.bRegisterInit then
  UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_ROLE_LIST_DONE, Login.OnSyncRoleListDone, Login)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_GATEWAY_HANDED, Login.OnGatewayHandSuccess, Login)
  Login.bRegisterInit = true
end
