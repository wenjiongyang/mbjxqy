Require("Script/Fuben/XinShouFuben/XinShouDef.lua")
local tbDef = XinShouLogin.tbDef
local tbFuben = Fuben:CreateFubenClass("XinShouFuben")
function tbFuben:OnCreate()
end
function tbFuben:OnJoin(pPlayer)
  pPlayer.nFightMode = 1
  Ui:OpenWindow("HomeScreenFuben", "XinShouFuben")
  Log("XinShouFuben On Join")
end
function tbFuben:OnMapLoaded()
  Ui:ChangeUiState(Ui.STATE_SPECIAL_FIGHT, false)
  local npcRep = Ui.Effect.GetNpcRepresent(me.GetNpc().nId)
  if npcRep then
    npcRep:ShowHeadUI(false)
  end
  self:Start()
end
function tbFuben:OnOut(pPlayer)
  Ui:CloseWindow("HomeScreenFuben")
  Log("XinShouFuben On Out")
end
function tbFuben:GameWin()
  XinShouLogin.nPlayCGAnimation = tbDef.nPlayXinShouCG
  PreloadResource:PushPreloadCGAni(tbDef.nPlayXinShouCG)
  XinShouLogin.bFinishFuben = true
  XinShouLogin:LoginServer()
  self:Close()
  Log("XinShouFuben On Game Win")
end
function tbFuben:OnShowTaskDialog(nLockId, nDialogId, bIsOnce, nDealyTime)
  if nDealyTime and nDealyTime > 0 then
    Timer:Register(Env.GAME_FPS * nDealyTime, self.OnShowTaskDialog, self, nLockId, nDialogId, bIsOnce)
    return
  end
  Ui:TryPlaySitutionalDialog(nDialogId, bIsOnce, {
    self.UnLock,
    self,
    nLockId
  })
end
function tbFuben:OnCloseDynamicObstacle(szObsName)
  CloseDynamicObstacle(me.nMapId, szObsName)
end
function tbFuben:OnDoCommonAct(szNpcGroup, nActId, nActEventId, bLoop, nFrame)
  if not szNpcGroup then
    local pNpc = me.GetNpc()
    if pNpc then
      pNpc.DoCommonAct(nActId or 1, nActEventId or 0, bLoop or 0, nFrame or 0)
    end
    return
  end
  for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup] or {}) do
    local pNpc = KNpc.GetById(nNpcId)
    if pNpc then
      pNpc.DoCommonAct(nActId or 1, nActEventId or 0, bLoop or 0, nFrame or 0)
    end
  end
end
function tbFuben:OnPostXinshouData(nIndex)
  Login:PostXinshouFubenData(nIndex)
end
function tbFuben:OnOpenCreatNamePanel()
  Ui:OpenWindow("CreateNameInput", XinShouLogin.tbRoleInfo.nFaction)
end
function tbFuben:OnDirectShowNameInput()
  self:OnTlog(7)
  self:PreLoadWindow("SituationalDialogue")
  self:PreLoadWindow("CreateNameInput")
  self.tbLock[43]:StartLock()
  self:UnLock(43)
end
function tbFuben:OnCreateRoleRespond(nRoleId)
  self:UnLock(44)
  Ui:CloseWindow("CreateNameInput")
  XinShouLogin.tbRoleInfo.nRoleID = nRoleId
end
function tbFuben:OnOpenBgBlackAll()
  if Ui:WindowVisible("BgBlackAll") == 1 then
    return
  end
  Ui:OpenWindow("BgBlackAll")
end
function tbFuben:GameLost()
  Ui:ChangeUiState()
  self:Close()
  Log("XinShouFuben On Game Lost")
end
function tbFuben:OnLog(...)
  Log(...)
end
function tbFuben:OnShowPlayer(bShow)
  Ui.Effect.ShowNpcRepresentObj(me.GetNpc().nId, bShow)
end
function tbFuben:OnTlog(nVal)
  LogBeforeLogin(nVal)
end
