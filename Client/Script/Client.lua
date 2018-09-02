local SdkMgr = luanet.import_type("SdkInterface")
function Client:CallClientScriptWhithPlayer(szFunc, ...)
  local bRet = pcall(me.CallClientScript, szFunc, me, ...)
  if not bRet then
    Log("CallClientScriptWhithPlayer ERR !!", szFunc, ...)
  end
end
function Client:SetFlag(key, value, nId)
  local tbFlag = Client:GetUserInfo("LocalFlags", nId)
  if value == nil then
    value = true
  end
  tbFlag[key] = value
  self:SaveUserInfo()
end
function Client:GetFlag(key, nId)
  local tbFlag = Client:GetUserInfo("LocalFlags", nId)
  return tbFlag[key]
end
function Client:ClearFlag(key, nId)
  local tbFlag = Client:GetUserInfo("LocalFlags", nId)
  tbFlag[key] = nil
  self:SaveUserInfo()
end
function Client:GetUserInfo(szType, nId)
  if not self.tbUserInfo then
    local f = io.open(g_szUserPath .. "User/UserInfo.lua", "r")
    local szFileContent = "return {};"
    if f then
      szFileContent = f:read("*all")
      f:close()
    end
    self.tbTmpEnv = {}
    szFileContent = "setfenv(1, Client.tbTmpEnv); local fnLoad = function () " .. szFileContent .. " end tbUserInfo = fnLoad();"
    local fnFile = loadstring(szFileContent)
    if fnFile then
      fnFile()
    end
    self.tbUserInfo = self.tbTmpEnv.tbUserInfo or {}
  end
  if not nId then
    nId = -1
    if me and me.dwID then
      nId = me.dwID
    end
  end
  self.tbUserInfo[nId] = self.tbUserInfo[nId] or {}
  self.tbUserInfo[nId][szType] = self.tbUserInfo[nId][szType] or {}
  return self.tbUserInfo[nId][szType]
end
function Client:SaveUserInfo()
  local szValue = Lib:Val2Str(self.tbUserInfo)
  local file = io.open(g_szUserPath .. "User/UserInfo.lua", "w+")
  if not file then
    Log("Client:SaveUserInfo ERR ?? file is nil !!" .. g_szUserPath)
    return
  end
  file:write("return" .. szValue)
  file:close()
end
function Client:GetPrivateMsgData()
  if not self.tbPrivateMsg then
    local f = io.open(g_szUserPath .. "User/UserPrivateMsg.lua", "r")
    local szFileContent = "return {};"
    if f then
      szFileContent = f:read("*all")
      f:close()
    end
    self.tbTmpEnv = {}
    szFileContent = "setfenv(1, Client.tbTmpEnv); local fnLoad = function () " .. szFileContent .. " end tbPrivateMsg = fnLoad();"
    local fnFile = loadstring(szFileContent)
    if fnFile then
      fnFile()
    end
    self.tbPrivateMsg = self.tbTmpEnv.tbPrivateMsg or {}
  end
  local nId = me.dwID
  self.tbPrivateMsg[nId] = self.tbPrivateMsg[nId] or {}
  return self.tbPrivateMsg[nId]
end
function Client:SavePrivateMsgData()
  local szValue = Lib:Val2Str(self.tbPrivateMsg)
  local file = io.open(g_szUserPath .. "User/UserPrivateMsg.lua", "w+")
  if not file then
    Log("Client:SavePrivateMsgData ERR ?? file is nil !!" .. g_szUserPath)
    return
  end
  file:write("return" .. szValue)
  file:close()
end
function Client:GetDirFileData(szFileName)
  self.tbFileDirData = self.tbFileDirData or {}
  if not self.tbFileDirData[szFileName] then
    local f = io.open(string.format("%sUser/%s.lua", g_szUserPath, szFileName), "r")
    local szFileContent = "return {};"
    if f then
      szFileContent = f:read("*all")
      f:close()
    end
    self.tbTmpEnv = {}
    szFileContent = "setfenv(1, Client.tbTmpEnv); local fnLoad = function () " .. szFileContent .. " end tbTmpData = fnLoad();"
    local fnFile = loadstring(szFileContent)
    if fnFile then
      fnFile()
    end
    self.tbFileDirData[szFileName] = self.tbTmpEnv.tbTmpData or {}
  end
  return self.tbFileDirData[szFileName]
end
function Client:SaveDirFileData(szFileName)
  local szValue = Lib:Val2Str(self.tbFileDirData[szFileName])
  local file = io.open(string.format("%sUser/%s.lua", g_szUserPath, szFileName), "w+")
  if not file then
    Log("Client:SaveDirFileData ERR ?? file is nil !!" .. szFileName)
    return
  end
  file:write("return" .. szValue)
  file:close()
end
function Client:GetLocalFileContent(szFileName, szDir)
  local szFileContent
  local f = io.open((szDir or g_szUserPath) .. szFileName, "r")
  if not f then
    return szFileContent
  end
  szFileContent = f:read("*all")
  f:close()
  return szFileContent
end
function Client:OnStartup()
  collectgarbage("setpause", 80)
  SdkMgr.SetReportIsOpen(Sdk.OPEN_REPORT_DATA)
  Fuben:Load()
  ValueItem:Init()
  OutputTable:AnalyseFubenOutput()
  Task:Setup()
  TeamBattle:Init()
  CardPicker:Init()
  Ui.UiManager.m_nMaxUiCount = 10
  local tbJuanZhouItem = Item:GetClass("JuanZhou")
  Lib:CallBack({
    tbJuanZhouItem.LoadSetting,
    tbJuanZhouItem
  })
  Lib:CallBack({
    Client.ClearLog,
    Client
  })
  Lib:CallBack({
    Client.ClearImgCache,
    Client
  })
  Lib:CallBack({
    Sdk.OnClientStart,
    Sdk
  })
  Lib:CallBack({
    Map.InitSetting,
    Map
  })
end
function Client:ClearLog()
  local szLogDir = g_szUserPath .. "logs/Client"
  if IOS then
    szLogDir = Ui.ToolFunction.LibarayPath .. "/logs/Client"
  end
  local tbAllFiles = {}
  local tbRes = TraverseDir(szLogDir)
  for _, szPath in pairs(tbRes) do
    local szFileName = string.match(szPath, "logs/Client/([0-9_]*).log$")
    if szFileName then
      local nYear, nMonth, nDay, nHour, nMin, nSec = string.match(szFileName, "^(%d+)_(%d+)_(%d+)_(%d+)_(%d+)_(%d+)$")
      if nYear then
        nYear = tonumber(nYear)
        nMonth = tonumber(nMonth)
        nDay = tonumber(nDay)
        nHour = tonumber(nHour)
        nMin = tonumber(nMin)
        nSec = tonumber(nSec)
        local nTime = Lib:GetSecFromNowData({
          year = nYear,
          month = nMonth,
          day = nDay,
          hour = nHour,
          min = nMin,
          sec = nSec
        })
        table.insert(tbAllFiles, {nTime, szPath})
      end
    end
  end
  table.sort(tbAllFiles, function(a, b)
    return a[1] > b[1]
  end)
  for i = 21, #tbAllFiles do
    os.remove(tbAllFiles[i][2])
    Log("[Client] RemoveLog ", tbAllFiles[i][2])
  end
end
function Client:ClearImgCache()
  local nNextClearTime = Client:GetFlag("NextClearImgCache") or 0
  local nNow = GetTime()
  if nNextClearTime > nNow then
    return
  end
  Client:SetFlag("NextClearImgCache", nNow + 86400)
  local szLogDir = Ui.ToolFunction.LibarayPath .. "/ImgCache"
  local tbRes = TraverseDir(szLogDir)
  for _, szPath in pairs(tbRes) do
    os.remove(szPath)
  end
  Log("[Client] ClearImgCache")
end
function Client:Activate()
  Operation:DealDelayOffline()
  Lib:CallBack({
    WeatherMgr.Activity,
    WeatherMgr
  })
  return true
end
function Client:SetPlayerDir(nDir, nMapTemplateId)
  if not nDir or not nMapTemplateId then
    return
  end
  me.nSetDirMapTId = nMapTemplateId
  me.nSetDirDir = nDir
  self:DoSetPlayerDir()
end
function Client:DoSetPlayerDir(bConfirm)
  if not me.nSetDirMapTId or not me.nSetDirDir then
    return
  end
  if me.nMapTemplateId ~= me.nSetDirMapTId then
    return
  end
  if not bConfirm then
    Timer:Register(5, self.DoSetPlayerDir, self, true)
    return
  end
  me.GetNpc().SetDir(me.nSetDirDir)
  me.nSetDirMapTId = nil
end
function Client:DoCommand(szCmd)
  Log("GmCmd[" .. tostring(me and me.szName) .. "]:", szCmd)
  local fnCmd, szMsg = loadstring(szCmd, "[GmCmd]")
  if not fnCmd then
    Log("Do GmCmd failed:" .. szMsg)
  else
    return fnCmd()
  end
end
function Client:GetCurServerInfo()
  local tbLastLoginfo = Client:GetUserInfo("Login", -1)
  local tbMyLogin = tbLastLoginfo[GetAccountName()]
  return SERVER_ID or "", tbMyLogin.szName
end
function Client:GetItem()
  local nItemId, nItemCount
  local function fnItemCountCallBack(szInput)
    nItemCount = tonumber(szInput)
    if not nItemCount then
      return 1
    end
    GMCommand(string.format("me.AddItem(%d,%d)", nItemId, nItemCount))
  end
  local function fnItemIdCallBack(szInput)
    nItemId = tonumber(szInput)
    if not nItemId then
      return 1
    end
    Ui:OpenWindow("InputBox", "输入道具数量", fnItemCountCallBack)
    return 1
  end
  Ui:OpenWindow("InputBox", "输入道具ID", fnItemIdCallBack)
end
function Client:GMGetImitity()
  local fnImitityCallBack = function(szInput)
    local nImitity = tonumber(szInput)
    if not nImitity then
      return 1
    end
    GMCommand(string.format("GM:ForceTeamSetImitity(%d)", nImitity))
  end
  Ui:OpenWindow("InputBox", "输入亲密度", fnImitityCallBack)
end
function Client:GMGetLoverId(szCmd)
  local function fnLoverIdCallBack(szInput)
    local dwID = tonumber(szInput)
    if not dwID then
      return 1
    end
    GMCommand(string.format(szCmd or "GM:MakeMarry(%d)", dwID))
  end
  Ui:OpenWindow("InputBox", "输入对方ID", fnLoverIdCallBack)
end
function Client:ReportQQGM()
  local nReportType, szReportData
  local function fnItemCountCallBack(szInput)
    szReportData = szInput
    if not szReportData or szReportData == "" then
      return 1
    end
    GMCommand(string.format("AssistClient:ReportQQScore(me, %d, %s, 0, 1)", nReportType, szReportData))
  end
  local function fnItemIdCallBack(szInput)
    nReportType = tonumber(szInput)
    if not nReportType then
      return 1
    end
    Ui:OpenWindow("InputBox", "输入报告数据", fnItemCountCallBack)
    return 1
  end
  Ui:OpenWindow("InputBox", "输入报告类型ID", fnItemIdCallBack)
end
function Client:IsCloseIOSEntry()
  if IOS then
    return Client:GetFlag("CloseIOSEntry")
  end
  return false
end
function Client:IsTssEnable()
  if not Sdk:IsMsdk() then
    return false
  end
  return true
end
function Client:IsOnlyUseIPv4()
  return false
end
