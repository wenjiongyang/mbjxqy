Ui.Hotkey = Ui.Hotkey or {}
local Hotkey = Ui.Hotkey
Hotkey.KEY_DESC = {
  {"Backspace", 8},
  {"Tab", 9},
  {"Return", 13},
  {"Pause", 19},
  {"Space", 32},
  {"Del", 127},
  {"↑", 273},
  {"↓", 274},
  {"→", 275},
  {"←", 276}
}
function Hotkey:Init()
  self.tbCallBack = {}
  self.tbKey2Code = {}
  self.tbCode2Key = {}
  for i = 33, 64 do
    self.tbKey2Code[string.char(i)] = i
    self.tbCode2Key[i] = string.char(i)
  end
  for i = 91, 96 do
    self.tbKey2Code[string.char(i)] = i
    self.tbCode2Key[i] = string.char(i)
  end
  for i = 97, 122 do
    self.tbKey2Code[string.char(i - 32)] = i
    self.tbCode2Key[i] = string.char(i - 32)
  end
  for i = 282, 296 do
    self.tbKey2Code["F" .. i - 281] = i
    self.tbCode2Key[i] = "F" .. i - 281
  end
  for i = 0, 9 do
    self.tbKey2Code["Num" .. i] = 256 + i
    self.tbCode2Key[256 + i] = "Num" .. i
  end
  for _, tbInfo in ipairs(self.KEY_DESC) do
    local szKey, nCode = unpack(tbInfo)
    self.tbKey2Code[szKey] = nCode
    self.tbCode2Key[nCode] = szKey
  end
  if not Sdk:IsPCVersion() then
    return
  end
  self:Load()
end
function Hotkey:Load()
  self.tbDefaultSetting = LoadTabFile("Setting/Ui/HotKey.tab", "dss", "KeyId", {
    "KeyId",
    "HotKey",
    "Action"
  })
  local tbRecord = Client:GetUserInfo("HotKeyInfo", -1)
  for nId, tbInfo in pairs(self.tbDefaultSetting) do
    local fnCallBack
    if tbInfo.Action and tbInfo.Action ~= "" then
      fnCallBack = loadstring(tbInfo.Action)
    end
    self:RegisterHotKey(nId, tbRecord[nId] or tbInfo.HotKey, fnCallBack and {fnCallBack})
  end
end
function Hotkey:GetCurSetting()
  local tbRet = {}
  local tbRecord = Client:GetUserInfo("HotKeyInfo", -1)
  for nId, tbInfo in pairs(self.tbDefaultSetting) do
    tbRet[nId] = tbRecord[nId] or tbInfo.HotKey
  end
  return tbRet
end
function Hotkey:Save(tbNewRecord)
  local tbRecord = Client:GetUserInfo("HotKeyInfo", -1)
  for nId, szHotKey in pairs(tbNewRecord) do
    tbRecord[nId] = szHotKey
    Ui.UiManager.RegisterKey(nId, self.tbKey2Code[szHotKey] or -1)
  end
  Client:SaveUserInfo()
end
function Hotkey:RegisterHotKey(nKeyId, szHotKey, tbCallBack)
  self.tbCallBack[nKeyId] = tbCallBack
  Ui.UiManager.RegisterKey(nKeyId, self.tbKey2Code[szHotKey] or -1)
end
function Hotkey:OnHotKey(nKeyId)
  if self.tbCallBack[nKeyId] then
    Lib:CallBack(self.tbCallBack[nKeyId])
  end
end
function Hotkey:OnCheckAnyKey(nKeyCode)
  local szKey = self.tbCode2Key[nKeyCode]
  if not szKey then
    me.CenterMsg("该按键不能被设置为控制键")
  end
  if Ui("OperationSet") and szKey then
    Ui("OperationSet"):OnCheckAnyKeyDown(szKey)
  end
  Ui.UiManager.CheckAnyKeyDown(false)
end
