Lib.tbTypeOrder = {
  ["nil"] = 1,
  number = 2,
  string = 3,
  userdata = 4,
  ["function"] = 5,
  table = 6
}
Lib.TYPE_COUNT = 6
Lib.tbAwardType = {
  "Exp",
  "Repute",
  "Money",
  "Item"
}
Lib._tbCommonMetatable = {
  __index = function(tb, key)
    return rawget(tb, "_tbBase")[key]
  end
}
Lib.TB_TIME_DESC = {
  {"天", 86400},
  {"小时", 3600},
  {"分钟", 60},
  {"秒", 1}
}
Lib.nRandomSeed = nil
function Lib:randomseed(nSeed)
  self.nRandomSeed = nSeed
end
function Lib:random(nBegin, nEnd)
  self.nRandomSeed = self.nRandomSeed or GetTime()
  self.nRandomSeed = (self.nRandomSeed * 3877 + 29573) % 4294967295
  if nEnd < nBegin then
    nBegin, nEnd = nEnd, nBegin
  end
  return nBegin + self.nRandomSeed % (nEnd - nBegin + 1)
end
function Lib:RandomArray(tbArray)
  local nCount = #tbArray
  if nCount > 1 then
    local tbRand = {
      unpack(tbArray)
    }
    for i = 1, nCount do
      local nMax = #tbRand
      local nRand = MathRandom(nMax)
      tbArray[i] = table.remove(tbRand, nRand)
    end
  end
  return tbArray
end
function Lib:GetRandomSelect(nCount)
  local tbCurInfo = {}
  return function()
    if #tbCurInfo <= 0 then
      for i = 1, nCount do
        tbCurInfo[i] = i
      end
    end
    local nRandom = MathRandom(#tbCurInfo)
    local nIdx = tbCurInfo[nRandom]
    table.remove(tbCurInfo, nRandom)
    return nIdx
  end
end
function Lib:CopyTB1(tb)
  local tbCopy = {}
  for k, v in pairs(tb) do
    tbCopy[k] = v
  end
  return tbCopy
end
function Lib:CopyTB(tb)
  local tbCopy = {}
  for k, v in pairs(tb) do
    if type(v) == "table" then
      tbCopy[k] = Lib:CopyTB(v)
    else
      tbCopy[k] = v
    end
  end
  return tbCopy
end
function Lib:TypeId(szType)
  if self.tbTypeOrder[szType] then
    return self.tbTypeOrder[szType]
  end
  self.TYPE_COUNT = self.TYPE_COUNT + 1
  self.tbTypeOrder[szType] = self.TYPE_COUNT
  return self.TYPE_COUNT
end
function Lib:ShowTB1(tbVar, szBlank)
  szBlank = szBlank or ""
  for k, v in pairs(tbVar) do
    print(szBlank .. "[" .. self:Val2Str(k) .. "]\t= " .. tostring(v))
  end
end
function Lib:ShowTB(tbVar, szBlank, nCount)
  szBlank = szBlank or ""
  nCount = nCount or 0
  if nCount > 10000 then
    print("ERROE~~ 层数太多，超过了1万次，防止死循环！！！！")
    return 0
  end
  local tbType = {}
  for k, v in pairs(tbVar) do
    local nType = self:TypeId(type(v))
    if not tbType[nType] then
      tbType[nType] = {
        n = 0,
        name = type(v)
      }
    end
    local tbTmp = tbType[nType]
    tbTmp.n = tbTmp.n + 1
    tbTmp[tbTmp.n] = k
  end
  for i = 1, self.TYPE_COUNT do
    if tbType[i] then
      local tbTmp = tbType[i]
      local szType = tbTmp.name
      table.sort(tbTmp)
      for i = 1, tbTmp.n do
        local key = tbTmp[i]
        local value = tbVar[key]
        local str
        if type(key) == "number" then
          str = szBlank .. "[" .. key .. "]"
        else
          str = szBlank .. "." .. key
        end
        if szType == "nil" then
          print(str .. "\t= nil")
        elseif szType == "number" then
          print(str .. "\t= " .. tbVar[key])
        elseif szType == "string" then
          print(str .. "\t= \"" .. tbVar[key] .. "\"")
        elseif szType == "function" then
          print(str .. "()")
        elseif szType == "table" then
          if tbVar[key] == tbVar then
            print(str .. "\t= {...}(self)")
          else
            print(str .. ":")
            self:ShowTB(tbVar[key], str, nCount + 1)
          end
        elseif szType == "userdata" then
          print(str .. "*")
        else
          print(str .. "\t= " .. tostring(tbVar[key]))
        end
      end
    end
  end
end
function Lib:LogTB(tbVar, szBlank, nCount)
  szBlank = szBlank or ""
  nCount = nCount or 0
  if nCount > 10000 then
    Log("ERROE~~ 层数太多，超过了1万次，防止死循环！！！！")
    return 0
  end
  local tbType = {}
  for k, v in pairs(tbVar) do
    local nType = self:TypeId(type(v))
    if not tbType[nType] then
      tbType[nType] = {
        n = 0,
        name = type(v)
      }
    end
    local tbTmp = tbType[nType]
    tbTmp.n = tbTmp.n + 1
    tbTmp[tbTmp.n] = k
  end
  for i = 1, self.TYPE_COUNT do
    if tbType[i] then
      local tbTmp = tbType[i]
      local szType = tbTmp.name
      table.sort(tbTmp)
      for i = 1, tbTmp.n do
        local key = tbTmp[i]
        local value = tbVar[key]
        local str
        if type(key) == "number" then
          str = szBlank .. "[" .. key .. "]"
        else
          str = szBlank .. "." .. key
        end
        if szType == "nil" then
          Log(str .. "\t= nil")
        elseif szType == "number" then
          Log(str .. "\t= " .. tbVar[key])
        elseif szType == "string" then
          Log(str .. "\t= \"" .. tbVar[key] .. "\"")
        elseif szType == "function" then
          Log(str .. "()")
        elseif szType == "table" then
          if tbVar[key] == tbVar then
            Log(str .. "\t= {...}(self)")
          else
            Log(str .. ":")
            self:LogTB(tbVar[key], str, nCount + 1)
          end
        elseif szType == "userdata" then
          Log(str .. "*")
        else
          Log(str .. "\t= " .. tostring(tbVar[key]))
        end
      end
    end
  end
end
function Lib:LogData(...)
  local arg = {
    ...
  }
  for _, value in ipairs(arg) do
    if type(value) == "table" then
      Lib:LogTB(value)
      Log("----------------------------")
    else
      Log(value)
    end
  end
end
function Lib:CompareTB(tableA, tableB)
  for k, v in pairs(tableA) do
    if tableB[k] ~= v then
      return false
    end
  end
  return true
end
function Lib:CountTB(tbVar)
  local nCount = 0
  for _, _ in pairs(tbVar) do
    nCount = nCount + 1
  end
  return nCount
end
function Lib:HaveCountTB(tbVar)
  for _, _ in pairs(tbVar) do
    return true
  end
  return false
end
function Lib:MergeTable(tableA, tableB)
  for _, item in ipairs(tableB) do
    tableA[#tableA + 1] = item
  end
  return tableA
end
function Lib:MergeSameKeyTable(tableA, tableB)
  for key, item in pairs(tableB) do
    tableA[key] = Lib:MergeTable(tableA[key] or {}, item)
  end
  return tableA
end
function Lib:StrVal2Str(szVal)
  szVal = string.gsub(szVal, "\\", "\\\\")
  szVal = string.gsub(szVal, "\"", "\\\"")
  szVal = string.gsub(szVal, "\n", "\\n")
  szVal = string.gsub(szVal, "\r", "\\r")
  return "\"" .. szVal .. "\""
end
function Lib:StrFilterChars(szOrg, tbReplacedChars, szReplaceWith)
  szReplaceWith = szReplaceWith or ""
  local szTmp = szOrg
  for _, c in pairs(tbReplacedChars) do
    c = string.gsub(c, "[().%+%-%*?[^$]", function(s)
      return "%" .. s
    end)
    szTmp = string.gsub(szTmp, c, szReplaceWith)
  end
  return szTmp
end
function Lib:StrTrimColorMark(szOrg)
  return string.gsub(szOrg, "%[[^%[%]]*%]", "")
end
function Lib:StrTrim(szDes, szTrimChar)
  szTrimChar = szTrimChar or " "
  if string.len(szTrimChar) ~= 1 then
    return szDes
  end
  local szRet, nCount = string.gsub(szDes, "(" .. szTrimChar .. "*)([^" .. szTrimChar .. "]*.*[^" .. szTrimChar .. "])(" .. szTrimChar .. "*)", "%2")
  if nCount == 0 then
    return ""
  end
  return szRet
end
function Lib:Val2Str(var, szBlank)
  local szType = type(var)
  if szType == "nil" then
    return "nil"
  elseif szType == "number" then
    return tostring(var)
  elseif szType == "string" then
    return self:StrVal2Str(var)
  elseif szType == "function" then
    local szCode = string.dump(var)
    local arByte = {
      string.byte(szCode, i, #szCode)
    }
    szCode = ""
    for i = 1, #arByte do
      szCode = szCode .. "\\" .. arByte[i]
    end
    return "loadstring(\"" .. szCode .. "\")"
  elseif szType == "table" then
    szBlank = szBlank or ""
    local szTbBlank = szBlank .. "  "
    local szCode = ""
    for k, v in pairs(var) do
      local szPair = szTbBlank .. "[" .. self:Val2Str(k) .. "]\t= " .. self:Val2Str(v, szTbBlank) .. ",\n"
      szCode = szCode .. szPair
    end
    if szCode == "" then
      return "{}"
    else
      return "\n" .. szBlank .. "{\n" .. szCode .. szBlank .. "}"
    end
  elseif szType == "boolean" then
    return var and "true" or "false"
  else
    return "\"" .. tostring(var) .. "\""
  end
end
function Lib:Str2Val(szVal)
  return assert(loadstring("return " .. szVal))()
end
function Lib:NewClass(tbBase, ...)
  local arg = {
    ...
  }
  local tbNew = {_tbBase = tbBase}
  setmetatable(tbNew, self._tbCommonMetatable)
  local tbRoot = tbNew
  local tbInit = {}
  repeat
    tbRoot = rawget(tbRoot, "_tbBase")
    local fnInit = rawget(tbRoot, "init")
    if type(fnInit) == "function" then
      table.insert(tbInit, fnInit)
    end
  until not rawget(tbRoot, "_tbBase")
  for i = #tbInit, 1, -1 do
    local fnInit = tbInit[i]
    if fnInit then
      fnInit(tbNew, unpack(arg))
    end
  end
  return tbNew
end
function Lib:ConcatStr(tbStrElem, szSep)
  szSep = szSep or ","
  return table.concat(tbStrElem, szSep)
end
function Lib:SplitStr(szStrConcat, szSep)
  szSep = szSep or ","
  local tbStrElem = {}
  local tbSpeSep = {
    ["%."] = 1
  }
  local nSepLen = tbSpeSep[szSep] or #szSep
  local nStart = 1
  local nAt = string.find(szStrConcat, szSep)
  while nAt do
    tbStrElem[#tbStrElem + 1] = string.sub(szStrConcat, nStart, nAt - 1)
    nStart = nAt + nSepLen
    nAt = string.find(szStrConcat, szSep, nStart)
  end
  tbStrElem[#tbStrElem + 1] = string.sub(szStrConcat, nStart)
  return tbStrElem
end
function Lib:GetTableFromString(szValue, bKeyNotNumber, bValueNotNumber)
  local tbResult = {}
  local tbLines = Lib:SplitStr(szValue, ";")
  for _, szCell in ipairs(tbLines) do
    if szCell ~= "" then
      local Key, Value = string.match(szCell, "^([^|]+)|([^|]+)$")
      if not Key then
        return
      end
      if not bKeyNotNumber then
        Key = tonumber(Key)
      end
      if not bValueNotNumber then
        Value = tonumber(Value)
      end
      if not Key or not Value then
        return
      end
      tbResult[Key] = Value
    end
  end
  return tbResult
end
function Lib:GetAwardDesCount(tbAllAward, pPlayer)
  local nFaction = pPlayer.nFaction
  local tbAwardDes = {}
  for nIndex, tbAward in pairs(tbAllAward) do
    local tbDes = {}
    local szAwardType = tbAward[1]
    local nAwardType = Player.AwardType[tbAward[1]]
    if nAwardType == Player.award_type_item then
      local szName = KItem.GetItemShowInfo(tbAward[2], nFaction)
      tbDes.szName = szName
      tbDes.szDesc = string.format("%s:%s", szName, tbAward[3])
    elseif nAwardType == Player.award_type_money then
      local szName, szMoneyEmotion = Shop:GetMoneyName(szAwardType)
      tbDes.szName = szName
      tbDes.szDesc = string.format("%s:%s", szName, tbAward[2])
      if szMoneyEmotion and szMoneyEmotion ~= "" then
        tbDes.szEmotionDesc = string.format("%s%s:%s", szMoneyEmotion, szName, tbAward[2])
      end
    elseif nAwardType == Player.award_type_kin_found then
      tbDes.szName = "家族资金"
      tbDes.szDesc = string.format("家族资金%s两", tbAward[2])
    elseif nAwardType == Player.award_type_equip_debris then
      local szName = KItem.GetItemShowInfo(tbAward[2], nFaction)
      tbDes.szName = string.format("%s碎片", szName)
      tbDes.szDesc = string.format("%s碎片:1", szName)
    elseif nAwardType == Player.award_type_basic_exp then
      tbDes.szName = "经验"
      local nCount = tbAward[2] * pPlayer.GetBaseAwardExp()
      if pPlayer.TrueChangeExp then
        nCount = pPlayer.TrueChangeExp(nCount)
      end
      tbDes.szDesc = string.format("经验%s点", nCount)
    elseif nAwardType == Player.award_type_faction_honor then
      tbDes.szName = "门派荣誉"
      tbDes.szDesc = string.format("门派荣誉%s点", tbAward[2])
    elseif nAwardType == Player.award_type_battle_honor then
      tbDes.szName = "战场荣誉"
      tbDes.szDesc = string.format("战场荣誉%s点", tbAward[2])
    end
    local nHave = Lib:CountTB(tbDes)
    if nHave > 0 then
      tbAwardDes[nIndex] = tbDes
    end
  end
  return tbAwardDes
end
function Lib:GetAwardDesCount2(tbAllAward, pPlayer)
  local nFaction = pPlayer and pPlayer.nFaction or 0
  local tbMsgs = {}
  for i, v in ipairs(tbAllAward) do
    local szMsg = ""
    local nAwardType = Player.AwardType[v[1]]
    if nAwardType == Player.award_type_item then
      local szName = KItem.GetItemShowInfo(v[2], nFaction)
      if v[3] == 1 then
        szMsg = szName
      else
        szMsg = string.format("%s*%d", szName, v[3])
      end
    elseif nAwardType == Player.award_type_money then
      local szName = Shop:GetMoneyName(v[1])
      szMsg = string.format("%d%s", v[2], szName)
    else
      szMsg = "其他奖励"
    end
    table.insert(tbMsgs, szMsg)
  end
  return tbMsgs
end
function Lib:Str2LunStr(szTxtStr)
  local szLunStr = string.gsub(szTxtStr, "\\n", "\n")
  return szLunStr
end
function Lib:GetAwardFromString(szAwardInfo)
  local tbResult = {}
  szAwardInfo = string.gsub(szAwardInfo, "\"", "")
  local tbLines = Lib:SplitStr(szAwardInfo, ";")
  if tbLines[#tbLines] == "" then
    tbLines[#tbLines] = nil
  end
  if not tbLines or #tbLines < 1 then
    return {}
  end
  for _, szCell in ipairs(tbLines) do
    if szCell ~= "" then
      local tbItemInfo = Lib:SplitStr(szCell, "|")
      if tbItemInfo[#tbItemInfo] == "" then
        tbItemInfo[#tbItemInfo] = nil
      end
      if tbItemInfo and #tbItemInfo >= 2 then
        for k, v in ipairs(tbItemInfo) do
          local nv = tonumber(v)
          if nv then
            tbItemInfo[k] = nv
          end
        end
        table.insert(tbResult, tbItemInfo)
      end
    end
  end
  return tbResult
end
function Lib:IsTrue(var)
  return var ~= nil and var ~= 0 and var ~= false and var ~= "false" and var ~= ""
end
function Lib:IsEmptyStr(var)
  if type(var) ~= "string" or var == "" or var == " " then
    return true
  end
  return false
end
function Lib:CallBack(tbCallBack)
  local varFunc = tbCallBack[1]
  local szType = type(varFunc)
  local function InnerCall()
    if szType == "function" then
      return tbCallBack[1](unpack(tbCallBack, 2))
    elseif szType == "string" then
      local fnFunc, tbSelf = KLib.GetValByStr(varFunc)
      if fnFunc then
        if tbSelf then
          return fnFunc(tbSelf, unpack(tbCallBack, 2))
        else
          return fnFunc(unpack(tbCallBack, 2))
        end
      else
        return false, "Wrong name string : " .. varFunc
      end
    end
  end
  local tbRet = {
    xpcall(InnerCall, Lib.ShowStack)
  }
  return unpack(tbRet)
end
function Lib:MergeCallBack(tbCallBack, ...)
  local tbCall = {
    unpack(tbCallBack)
  }
  local tbArg = {
    ...
  }
  Lib:MergeTable(tbCall, tbArg)
  return Lib:CallBack(tbCall)
end
function Lib.ShowStack(s)
  Log(debug.traceback(s, 2))
  return s
end
function Lib:IsDerived(tbThis, tbBase)
  if not tbThis or not tbBase then
    return 0
  end
  repeat
    local pBase = rawget(tbThis, "_tbBase")
    if pBase == tbBase then
      return 1
    end
    tbThis = pBase
  until not tbThis
  return 0
end
function Lib:GetTodayZeroHour(nTime)
  local nTimeNow = nTime or GetTime()
  local tbTime = os.date("*t", nTimeNow)
  return nTimeNow - (tbTime.hour * 3600 + tbTime.min * 60 + tbTime.sec)
end
function Lib:GetLocalWeekTime(nTime)
  local nTimeNow = nTime or GetTime()
  local nW = tonumber(os.date("%w", nTimeNow))
  local tbTime = os.date("*t", nTimeNow)
  if nW == 0 then
    nW = 7
  end
  nW = nW - 1
  return nW * 86400 + tbTime.hour * 3600 + tbTime.min * 60 + tbTime.sec
end
function Lib:TransferSecond2NormalTime(nSecondTime)
  local nHour, nMinute, nSecond = 0, 0, 0
  if nSecondTime >= 3600 then
    nHour = math.floor(nSecondTime / 3600)
    nSecondTime = math.floor(nSecondTime % 3600)
  end
  if nSecondTime >= 60 then
    nMinute = math.floor(nSecondTime / 60)
    nSecondTime = math.floor(nSecondTime % 60)
  end
  nSecond = math.floor(nSecondTime)
  return nHour, nMinute, nSecond
end
function Lib:Transfer4LenDigit2CnNum(nDigit)
  if version_vn then
    return tostring(nDigit)
  end
  local tbCnNum = self.tbCnNum
  if not tbCnNum then
    tbCnNum = {
      [1] = "一",
      [2] = "二",
      [3] = "三",
      [4] = "四",
      [5] = "五",
      [6] = "六",
      [7] = "七",
      [8] = "八",
      [9] = "九"
    }
    self.tbCnNum = tbCnNum
  end
  local tb4LenCnNum = self.tb4LenCnNum
  if not tb4LenCnNum then
    tb4LenCnNum = {
      [1] = "",
      [2] = "十",
      [3] = "百",
      [4] = "千"
    }
    self.tb4LenCnNum = tb4LenCnNum
  end
  local nDigitTmp = nDigit
  local nModel = 0
  local nPreNum = 0
  local bOneEver = false
  local szCnNum = ""
  local szNumTmp = ""
  if nDigit == 0 then
    return
  end
  if nDigit >= 10 and nDigit < 20 then
    if nDigit == 10 then
      szCnNum = tb4LenCnNum[2]
    else
      szCnNum = tb4LenCnNum[2] .. tbCnNum[math.floor(nDigit % 10)]
    end
    return szCnNum
  end
  for i = 1, #tb4LenCnNum do
    szNumTmp = ""
    nModel = math.floor(nDigitTmp % 10)
    if nModel ~= 0 then
      szNumTmp = szNumTmp .. tbCnNum[nModel] .. tb4LenCnNum[i]
      if nPreNum == 0 and bOneEver then
        szNumTmp = szNumTmp .. "零"
      end
      bOneEver = true
    end
    szCnNum = szNumTmp .. szCnNum
    nPreNum = nModel
    nDigitTmp = math.floor(nDigitTmp / 10)
    if nDigitTmp == 0 then
      break
    end
  end
  return szCnNum
end
function Lib:TransferDigit2CnNum(nDigit)
  local tbModelUnit = {
    [1] = "",
    [2] = "万",
    [3] = "亿"
  }
  local nDigitTmp = nDigit
  local n4LenNum = 0
  local nPreNum = 0
  local szCnNum = ""
  local szNumTmp = ""
  if nDigit == 0 then
    szCnNum = "零"
    return szCnNum
  end
  if nDigit < 0 then
    nDigitTmp = math.floor(nDigit * -1)
    szCnNum = "负"
  end
  for i = 1, #tbModelUnit do
    szNumTmp = ""
    n4LenNum = math.floor(nDigitTmp % 10000)
    if n4LenNum ~= 0 then
      szNumTmp = self:Transfer4LenDigit2CnNum(n4LenNum)
      szNumTmp = szNumTmp .. tbModelUnit[i]
      if nPreNum > 0 and nPreNum < 1000 or math.floor(n4LenNum % 10) == 0 and i > 1 then
        szNumTmp = szNumTmp .. "零"
      end
    end
    szCnNum = szNumTmp .. szCnNum
    nPreNum = n4LenNum
    nDigitTmp = math.floor(nDigitTmp / 10000)
    if nDigitTmp == 0 then
      break
    end
  end
  return szCnNum
end
function Lib:ThousandSplit(nDigit)
  local szMinus = nDigit > 0 and "" or "-"
  nDigit = math.abs(nDigit)
  local n3T = math.floor(nDigit / 1000000)
  local n2T = math.floor(nDigit % 1000000 / 1000)
  local n1T = nDigit % 1000
  if n3T ~= 0 then
    return string.format("%s%d,%03d,%03d", szMinus, n3T, n2T, n1T)
  elseif n2T ~= 0 then
    return string.format("%s%d,%03d", szMinus, n2T, n1T)
  else
    return string.format("%s%d", szMinus, n1T)
  end
end
function Lib:GetCnTime(nHour)
  local szXiaoshi = ""
  local szShichen = ""
  local nDigit = math.floor(nHour)
  if nHour - nDigit == 0.5 and nDigit > 0 then
    szXiaoshi = self:TransferDigit2CnNum(nDigit) .. "个半小时"
  elseif nHour - nDigit == 0.5 then
    szXiaoshi = "半个小时"
  else
    szXiaoshi = self:TransferDigit2CnNum(nDigit) .. "个小时"
  end
  return szXiaoshi
end
function Lib:TimeDesc(nSec)
  nSec = math.max(0, nSec)
  if nSec < 60 then
    return string.format("%d秒", nSec)
  elseif nSec < 3600 then
    return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60))
  elseif nSec < 86400 then
    return string.format(nSec % 3600 == 0 and "%d小时" or "%.1f小时", nSec / 3600)
  else
    return string.format(nSec % 86400 == 0 and "%d天" or "%.1f天", nSec / 86400)
  end
end
function Lib:TimeDesc2(nSec)
  local nDaySec = 86400
  if nSec < 3600 then
    return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60))
  elseif nSec < nDaySec then
    return string.format("%d小时%d分", nSec / 3600, nSec % 3600 / 60)
  else
    local nSecLeft = nSec % nDaySec
    if nSecLeft == 0 then
      return string.format("%d天", nSec / nDaySec)
    else
      return string.format("%d天%d小时", nSec / nDaySec, nSecLeft / 3600)
    end
  end
end
function Lib:TimeDesc3(nSec)
  if nSec < 3600 then
    return string.format("%02d:%02d", nSec % 3600 / 60, nSec % 60)
  else
    return string.format("%02d:%02d:%02d", nSec / 3600, nSec % 3600 / 60, nSec % 60)
  end
end
function Lib:TimeDesc4(nSec)
  if nSec < 60 then
    return string.format("%d\"", nSec % 60)
  else
    return string.format("%d'%d\"", nSec / 60, nSec % 60)
  end
end
function Lib:TimeDesc5(nSec)
  local nHour, nMin = self:TransferSecond2NormalTime(nSec)
  if nHour > 0 then
    if 0 < math.floor(nHour / 24) then
      return string.format("%d天%d小时%d分", math.floor(nHour / 24), nHour % 24, nMin)
    else
      return string.format("%d小时%d分", nHour, nMin)
    end
  end
  return string.format("%d分", nMin)
end
function Lib:TimeDesc6(nSec)
  nSec = math.max(0, nSec)
  if nSec < 60 then
    return string.format("%d秒", nSec)
  elseif nSec < 3600 then
    return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60))
  elseif nSec < 86400 then
    return string.format("%d小时", math.floor(nSec / 3600))
  else
    return string.format("%d天", math.floor(nSec / 86400))
  end
end
function Lib:TimeDesc7(nTime)
  nTime = math.max(0, nTime)
  local tbTime = os.date("*t", nTime)
  return string.format("%s年%s月%s日%s点", tbTime.year, tbTime.month, tbTime.day, tbTime.hour)
end
function Lib:TimeDesc8(nSec)
  local nHour, nMin = self:TransferSecond2NormalTime(nSec)
  if nHour > 0 then
    return string.format("%d小时%d分", nHour, nMin)
  end
  return string.format("%d分", nMin)
end
function Lib:TimeDesc9(nTime)
  nTime = math.max(0, nTime)
  local tbTime = os.date("*t", nTime)
  return string.format("%s年%s月%s日%s点%s分%s秒", tbTime.year, tbTime.month, tbTime.day, tbTime.hour, tbTime.min, tbTime.sec)
end
function Lib:TimeDesc10(nTime)
  nTime = math.max(0, nTime)
  local tbTime = os.date("*t", nTime)
  return string.format("%s月%s日%s点", tbTime.month, tbTime.day, tbTime.hour)
end
function Lib:TimeDesc11(nTime)
  nTime = math.max(0, nTime)
  local tbTime = os.date("*t", nTime)
  return string.format("%s年%s月%s日", tbTime.year, tbTime.month, tbTime.day)
end
function Lib:TimeDesc12(nSec)
  nSec = math.max(0, nSec)
  if nSec < 60 then
    return string.format("%d秒", nSec)
  elseif nSec < 3600 then
    return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60))
  elseif nSec < 86400 then
    return string.format("%d时%d分%d秒", math.floor(nSec / 3600), math.mod(nSec, 3600) / 60, math.mod(math.mod(nSec, 3600), 60))
  else
    return string.format("%d天", math.floor(nSec / 86400))
  end
end
function Lib:TimeDesc13(nSec)
  nSec = math.max(0, nSec)
  if nSec < 3600 then
    return string.format("%d分", nSec / 60)
  elseif nSec < 86400 then
    return string.format("%d小时", math.floor(nSec / 3600))
  else
    return string.format("%d天", math.ceil(nSec / 86400))
  end
end
function Lib:TimeDesc14(nTime)
  nTime = math.max(0, nTime)
  local tbTime = os.date("*t", nTime)
  return string.format("%s月%s日", tbTime.month, tbTime.day)
end
function Lib:TimeDesc15(nSec)
  nSec = math.max(0, nSec)
  local nDaySec = 86400
  if nSec < 60 then
    return string.format("%d秒", nSec)
  elseif nSec < 3600 then
    return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60))
  elseif nSec < nDaySec then
    return string.format("%d小时%d分", nSec / 3600, nSec % 3600 / 60)
  else
    local nHourLeft = math.floor(nSec % nDaySec / 3600)
    if nHourLeft == 0 then
      return string.format("%d天", nSec / nDaySec)
    else
      return string.format("%d天%d小时", nSec / nDaySec, nHourLeft)
    end
  end
end
function Lib:TimeFullDesc(nSec, nPrecision)
  local nMaxLevel = #self.TB_TIME_DESC
  nPrecision = nPrecision or nMaxLevel
  local szMsg = ""
  local nLastLevel = nMaxLevel
  for nLevel = 1, nMaxLevel do
    local tbTimeDesc = self.TB_TIME_DESC[nLevel]
    local nUnit = tbTimeDesc[2]
    if nSec >= nUnit or nUnit == 1 and szMsg == "" then
      if nLevel > nLastLevel + 1 then
        szMsg = szMsg .. "零"
      end
      szMsg = szMsg .. math.floor(nSec / nUnit) .. tbTimeDesc[1]
      nSec = math.mod(nSec, nUnit)
      nLastLevel = nLevel
      nPrecision = nPrecision - 1
      if nPrecision <= 0 then
        break
      end
    end
  end
  return szMsg
end
function Lib:TimeFullDescEx(nSec)
  local szMsg = ""
  local nLastLevel = #self.TB_TIME_DESC
  for nLevel, tbTimeDesc in ipairs(self.TB_TIME_DESC) do
    local nUnit = tbTimeDesc[2]
    if nSec >= nUnit or nUnit == 1 and szMsg == "" then
      if nLevel > nLastLevel + 1 then
        szMsg = szMsg .. "零"
      end
      szMsg = szMsg .. string.format("%02d" .. tbTimeDesc[1], math.floor(nSec / nUnit))
      nSec = math.mod(nSec, nUnit)
      nLastLevel = nLevel
    end
  end
  return szMsg
end
function Lib:FrameTimeDesc(nFrame)
  local nSec = math.floor(nFrame / Env.GAME_FPS)
  return self:TimeDesc(nSec)
end
function Lib:LoadTabFile(szFileName, tbNumColName, bOutsidePackage)
  local tbData = KLib.LoadTabFile(szFileName, 1, bOutsidePackage or 0)
  if not tbData then
    return
  end
  tbNumColName = tbNumColName or {}
  local tbColName = tbData[1]
  tbData[1] = nil
  local tbRet = {}
  for nRow, tbDataRow in pairs(tbData) do
    local tbRow = {}
    tbRet[nRow - 1] = tbRow
    for nCol, szName in pairs(tbColName) do
      if tbNumColName[szName] then
        tbRow[szName] = tonumber(tbDataRow[nCol]) or 0
      else
        tbRow[szName] = tbDataRow[nCol]
      end
    end
  end
  return tbRet
end
function Lib:LoadIniFile(szFileName, nTranslateFlag, nOutSidePack)
  if nTranslateFlag == nil then
    nTranslateFlag = 1
  end
  if nOutSidePack == nil then
    nOutSidePack = 0
  end
  return KLib.LoadIniFile(szFileName, nTranslateFlag, nOutSidePack)
end
function Lib:SmashTable(tb)
  local nLen = #tb
  for n, value in pairs(tb) do
    local nRand = MathRandom(nLen)
    tb[n] = tb[nRand]
    tb[nRand] = value
  end
end
function Lib:IsEmptyTB(tb)
  return _G.next(tb) == nil
end
function Lib:LoadBits(nInt32, nBegin, nEnd)
  if nEnd < nBegin then
    local _ = nBegin
    nBegin = nEnd
    nEnd = _
  end
  if nBegin < 0 or nEnd >= 32 then
    return 0
  end
  nInt32 = nInt32 % 2 ^ (nEnd + 1)
  nInt32 = nInt32 / 2 ^ nBegin
  return math.floor(nInt32)
end
function Lib:SetBits(nInt32, nBits, nBegin, nEnd)
  if nEnd < nBegin then
    local _ = nBegin
    nBegin = nEnd
    nEnd = _
  end
  nBits = nBits % 2 ^ (nEnd - nBegin + 1)
  nBits = nBits * 2 ^ nBegin
  nInt32 = nInt32 % 2 ^ nBegin + nInt32 - nInt32 % 2 ^ (nEnd + 1)
  nInt32 = nInt32 + nBits
  return nInt32
end
function Lib:GetTableBit(tb, nPos)
  assert(nPos >= 0, "Lib:GetTableBit nPos = " .. nPos)
  local nIndex = math.floor(nPos / 32)
  local nRealPos = nPos % 32
  if not tb or not tb[nIndex] then
    return 0
  end
  return self:LoadBits(tb[nIndex], nRealPos, nRealPos)
end
function Lib:SetTableBit(tb, nPos, nBit)
  assert(nPos >= 0, "Lib:GetTableBit nPos = " .. nPos)
  local nIndex = math.floor(nPos / 32)
  local nRealPos = nPos % 32
  if not nBit or nBit ~= 0 then
    nBit = 1
  end
  tb[nIndex] = tb[nIndex] or 0
  tb[nIndex] = self:SetBits(tb[nIndex], nBit, nRealPos, nRealPos)
end
function Lib:GetTodaySec(nTime)
  return Lib:GetLocalDayTime(nTime)
end
function Lib:ParseTodayTime(szDateTime)
  local nHour, nMinute, nSecond = string.match(szDateTime, "(%d+):(%d+):(%d+)")
  if not nHour then
    nHour, nMinute = string.match(szDateTime, "(%d+):(%d+)")
  end
  nSecond = nSecond or 0
  local nTime = nHour * 3600 + nMinute * 60 + nSecond
  return nTime
end
function Lib:GetLuaGMTSec()
  if not self.nLuaGMTSec then
    local now = os.time()
    self.nLuaGMTSec = os.difftime(now, os.time(os.date("!*t", now)))
  end
  return self.nLuaGMTSec
end
function Lib:GetGMTSec()
  local nGMTSec = 0
  if MODULE_GAMESERVER or MODULE_ZONESERVER then
    nGMTSec = Lib:GetLuaGMTSec()
  else
    nGMTSec = GetLogicGMTSec()
    if nGMTSec == -1 then
      nGMTSec = Lib:GetLuaGMTSec()
    end
  end
  return nGMTSec
end
function Lib:LocalDate(szFormat, nSec)
  if MODULE_GAMECLIENT then
    nSec = nSec + GetLogicGMTSec() - Lib:GetLuaGMTSec()
  end
  return os.date(szFormat, nSec)
end
function Lib:GetLocalDayTime(nUtcSec)
  local nLocalSec = (nUtcSec or GetTime()) + self:GetGMTSec()
  return math.mod(nLocalSec, 86400)
end
function Lib:GetLocalDayHour(nUtcSec)
  local nLocalSec = (nUtcSec or GetTime()) + self:GetGMTSec()
  local nDaySec = math.mod(nLocalSec, 86400)
  return math.floor(nDaySec / 3600)
end
function Lib:GetLocalDay(nUtcSec)
  local nLocalSec = (nUtcSec or GetTime()) + self:GetGMTSec()
  return math.floor(nLocalSec / 86400)
end
function Lib:GetTimeByLocalDay(nLocalDay)
  local nLocalSec = nLocalDay * 86400
  return nLocalSec - self:GetGMTSec()
end
function Lib:GetLocalWeek(nUtcSec)
  local nLocalDay = self:GetLocalDay(nUtcSec)
  return math.floor((nLocalDay + 3) / 7)
end
function Lib:GetLocalWeekEndTime(nUtcSec)
  local nWeekDay = Lib:GetLocalWeek(nUtcSec)
  return (nWeekDay * 7 + 4) * 86400 - Lib:GetGMTSec()
end
function Lib:GetLocalWeekDay(nUtcSec)
  local nLocalDay = self:GetLocalDay(nUtcSec)
  return (nLocalDay + 3) % 7 + 1
end
function Lib:GetTimeByWeek(nWeek, nDay, nHour, nMin, nSec)
  if not (nWeek and nDay) or nWeek <= 0 then
    return nil
  end
  nDay = nDay + (nWeek - 1) * 7 + 4
  return os.time({
    year = 1970,
    month = 1,
    day = nDay,
    hour = nHour,
    min = nMin,
    sec = nSec
  })
end
function Lib:GetTimeNum(timestamp)
  timestamp = timestamp or GetTime()
  local tbTime = os.date("*t", timestamp)
  return tbTime.year * 10000 + tbTime.month * 100 + tbTime.day
end
function Lib:GetTimeStr(nTimestamp)
  nTimestamp = nTimestamp or GetTime()
  local tbTime = os.date("*t", nTimestamp)
  return string.format("%d-%.2d-%.2d", tbTime.year, tbTime.month, tbTime.day)
end
function Lib:GetTimeStr2(nTimestamp)
  nTimestamp = nTimestamp or GetTime()
  local tbTime = os.date("*t", nTimestamp)
  return string.format("%.2d-%.2d %.2d:%.2d", tbTime.month, tbTime.day, tbTime.hour, tbTime.min)
end
function Lib:GetTimeStr3(nTimestamp)
  nTimestamp = nTimestamp or GetTime()
  local tbTime = os.date("*t", nTimestamp)
  return string.format("%d-%.2d-%.2d %.2d:%.2d", tbTime.year, tbTime.month, tbTime.day, tbTime.hour, tbTime.min)
end
function Lib:GetTimeStr4(nTimestamp)
  nTimestamp = nTimestamp or GetTime()
  local tbTime = os.date("*t", nTimestamp)
  return string.format("%d-%.2d-%.2d %.2d:%.2d:%.2d", tbTime.year, tbTime.month, tbTime.day, tbTime.hour, tbTime.min, tbTime.sec)
end
function Lib:GetLocalMonth(nUtcSec)
  local tbTime = os.date("*t", nUtcSec or GetTime())
  return (tbTime.year - 1970) * 12 + tbTime.month - 1
end
function Lib:GetLocalSeason(nUtcSec)
  local tbTime = os.date("*t", nUtcSec or GetTime())
  return (tbTime.year - 1970) * 4 + math.ceil(tbTime.month / 3) - 1
end
function Lib:GetLocalYear(nUtcSec)
  local tbTime = os.date("*t", nUtcSec or GetTime())
  return tbTime.year - 1970
end
function Lib:GetMonthDay(nUtcSec)
  local tbTime = os.date("*t", nUtcSec or GetTime())
  return tbTime.day
end
function Lib:GetTimeByWeekInMonth(nUtcSec, nWeek, nDay, nHour, nMin, nSec)
  if nWeek == 0 then
    return
  end
  nHour = nHour or 0
  nMin = nMin or 0
  nSec = nSec or 0
  local nDstDay = 0
  if nWeek > 0 then
    local tbTime = os.date("*t", nUtcSec or GetTime())
    local nMonthFirstDay = self:GetLocalDay(os.time({
      year = tbTime.year,
      month = tbTime.month,
      day = 1
    }))
    local nMonthFirstWeekDay = (nMonthFirstDay + 3) % 7 + 1
    nWeek = nDay < nMonthFirstWeekDay and nWeek or nWeek - 1
    nDstDay = nDay - nMonthFirstWeekDay + nMonthFirstDay + nWeek * 7
  else
    local tbTime = os.date("*t", nUtcSec or GetTime())
    local nMonthLastDay = self:GetLocalDay(os.time({
      year = tbTime.month == 12 and tbTime.year + 1 or tbTime.year,
      month = tbTime.month == 12 and 1 or tbTime.month + 1,
      day = 1
    })) - 1
    local nMonthLastWeekDay = (nMonthLastDay + 3) % 7 + 1
    nWeek = nDay > nMonthLastWeekDay and nWeek or nWeek + 1
    nDstDay = nDay - nMonthLastWeekDay + nMonthLastDay + nWeek * 7
  end
  return nDstDay * 3600 * 24 + nHour * 3600 + nMin * 60 + nSec - self:GetGMTSec()
end
function Lib:GetDate2Time(nDate)
  local nDate = tonumber(nDate)
  if nDate == nil then
    return
  end
  local nSecd = 0
  local nMin = 0
  local nHour = 0
  local nDay = 0
  local nMon = 0
  local nYear = 0
  if string.len(nDate) == 8 then
    nDay = math.mod(nDate, 100)
    nMon = math.mod(math.floor(nDate / 100), 100)
    nYear = math.mod(math.floor(nDate / 10000), 10000)
  elseif string.len(nDate) == 10 then
    nHour = math.mod(nDate, 100)
    nDay = math.mod(math.floor(nDate / 100), 100)
    nMon = math.mod(math.floor(nDate / 10000), 100)
    nYear = math.mod(math.floor(nDate / 1000000), 10000)
  elseif string.len(nDate) == 12 then
    nMin = math.mod(nDate, 100)
    nHour = math.mod(math.floor(nDate / 100), 100)
    nDay = math.mod(math.floor(nDate / 10000), 100)
    nMon = math.mod(math.floor(nDate / 1000000), 100)
    nYear = math.mod(math.floor(nDate / 100000000), 10000)
  elseif string.len(nDate) == 14 then
    nSecd = math.mod(nDate, 100)
    nMin = math.mod(math.floor(nDate / 100), 100)
    nHour = math.mod(math.floor(nDate / 10000), 100)
    nDay = math.mod(math.floor(nDate / 1000000), 100)
    nMon = math.mod(math.floor(nDate / 100000000), 100)
    nYear = math.mod(math.floor(nDate / 10000000000), 10000)
  else
    return 0
  end
  local tbData = {
    year = nYear,
    month = nMon,
    day = nDay,
    hour = nHour,
    min = nMin,
    sec = nSecd
  }
  local nSec = Lib:GetSecFromNowData(tbData)
  return nSec
end
function Lib:GetSecFromNowData(tbData)
  local nSecTime = os.time(tbData)
  return nSecTime
end
function Lib:HourMinNumber2TimeDesc(nTime)
  local nMin = math.mod(nTime, 100)
  local nHour = math.floor(nTime / 100)
  local szMin = nMin
  if nMin < 10 then
    szMin = "0" .. nMin
  end
  local szTime = nHour .. ":" .. szMin
  return szTime
end
function Lib:ParseDateTime(szDateTime)
  local year, month, day, hour, minute, second = string.match(szDateTime, "(%d+)/(%d+)/(%d+) (%d+):(%d+):?(%d?%d?)")
  if not year then
    year, month, day, hour, minute, second = string.match(szDateTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):?(%d?%d?)")
  end
  if not year then
    year, month, day, hour, minute, second = string.match(szDateTime, "(%d+)%.(%d+)%.(%d+) (%d+):(%d+):?(%d?%d?)")
  end
  second = second or 0
  if not year then
    year, month, day = string.match(szDateTime, "(%d+)/(%d+)/(%d+)")
    hour, minute, second = 0, 0, 0
  end
  if not year then
    year, month, day = string.match(szDateTime, "(%d+)-(%d+)-(%d+)")
    hour, minute, second = 0, 0, 0
  end
  if not year then
    year, month, day = string.match(szDateTime, "(%d+).(%d+).(%d+)")
    hour, minute, second = 0, 0, 0
  end
  if not year then
    Log("Lib:ParseDateTime 时间字符串格式不合法" .. szDateTime)
    return
  end
  local nSec = os.time({
    year = year,
    month = month,
    day = day,
    hour = hour,
    min = minute,
    sec = second
  })
  if MODULE_GAMECLIENT and GetLogicGMTSec() ~= -1 then
    nSec = nSec - GetLogicGMTSec() + Lib:GetLuaGMTSec()
  end
  return nSec
end
function Lib:IntIpToStrIp(nIp)
  if nIp == nil then
    return ""
  end
  local tbIp = {}
  tbIp[1] = self:LoadBits(nIp, 0, 7)
  tbIp[2] = self:LoadBits(nIp, 8, 15)
  tbIp[3] = self:LoadBits(nIp, 16, 23)
  tbIp[4] = self:LoadBits(nIp, 24, 31)
  local szIp = string.format("%d.%d.%d.%d", tbIp[1], tbIp[2], tbIp[3], tbIp[4])
  return szIp
end
function Lib:IsInteger(val)
  if not val or type(val) ~= "number" then
    return 0
  elseif math.floor(val) == val then
    return 1
  end
  return 0
end
function Lib:HasNonChineseChars(s)
  if version_vn then
    return false
  end
  local tbUtf8 = self:GetUft8Chars(s)
  for _, c in ipairs(tbUtf8) do
    if string.byte(c) <= 127 then
      return true
    end
  end
  return false
end
function Lib:GetUft8Chars(s)
  local nTotalLen = string.len(s)
  local nCurIdx = 1
  local tbResult = {}
  while nTotalLen >= nCurIdx do
    local c = string.byte(s, nCurIdx)
    if c > 0 and c <= 127 then
      table.insert(tbResult, string.sub(s, nCurIdx, nCurIdx))
      nCurIdx = nCurIdx + 1
    elseif c >= 194 and c <= 223 then
      table.insert(tbResult, string.sub(s, nCurIdx, nCurIdx + 1))
      nCurIdx = nCurIdx + 2
    elseif c >= 224 and c <= 239 then
      table.insert(tbResult, string.sub(s, nCurIdx, nCurIdx + 2))
      nCurIdx = nCurIdx + 3
    elseif c >= 240 and c <= 244 then
      table.insert(tbResult, string.sub(s, nCurIdx, nCurIdx + 3))
      nCurIdx = nCurIdx + 4
    end
  end
  return tbResult
end
function Lib:Utf8Len(s)
  if s and type(s) == "string" then
    return KLib.GetUtf8Len(s)
  else
    return 0
  end
end
function Lib:CutUtf8(s, nLen, nCharLen)
  return KLib.CutUtf8(s, nLen, nCharLen)
end
function Lib:InitTable(tb, ...)
  local tbIdx = {
    ...
  }
  for _, key in ipairs(tbIdx) do
    tb[key] = tb[key] or {}
    tb = tb[key]
  end
  return tb
end
function Lib:GetMaxTimeFrame(tbTimeFrame)
  local szCurTimeFrame = ""
  local nCurTimeFrameTime = -1
  for szTimeFrame, _ in pairs(tbTimeFrame) do
    if szTimeFrame ~= "-1" and GetTimeFrameState(szTimeFrame) == 1 then
      local nOpenTime = CalcTimeFrameOpenTime(szTimeFrame)
      if nCurTimeFrameTime < nOpenTime then
        nCurTimeFrameTime = nOpenTime
        szCurTimeFrame = szTimeFrame
      end
    end
  end
  return szCurTimeFrame
end
function Lib:GetCountInTable(tbItems, fnEqual, param)
  local nCount = 0
  for _, tbItem in pairs(tbItems) do
    if fnEqual(tbItem, param) then
      nCount = nCount + 1
    end
  end
  return nCount
end
function Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
  local fOfX = nX2 - nX1
  local fOfY = nY2 - nY1
  return fOfX * fOfX + fOfY * fOfY
end
function Lib:GetDistance(nX1, nY1, nX2, nY2)
  local fDist = Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
  return math.sqrt(fDist)
end
function Lib:GetServerOpenDay()
  local nCreateTime = GetServerCreateTime()
  local nToday = Lib:GetLocalDay()
  return nToday - Lib:GetLocalDay(nCreateTime) + 1
end
function Lib:IsDiffDay(nOffset, nTime1, nTime2)
  nTime2 = nTime2 or GetTime()
  local nDay1 = self:GetLocalDay(nTime1 - nOffset)
  local nDay2 = self:GetLocalDay(nTime2 - nOffset)
  return nDay1 ~= nDay2
end
function Lib:IsDiffWeek(nTime1, nTime2, nOffset)
  nOffset = nOffset or 0
  local nWeek1 = self:GetLocalWeek(nTime1 - nOffset)
  local nWeek2 = self:GetLocalWeek(nTime2 - nOffset)
  return nWeek1 ~= nWeek2
end
function Lib:SecondsToDays(nSeconds)
  return math.floor(nSeconds / 86400)
end
function Lib:StrFillL(szStr, nLen, szFilledChar)
  szStr = tostring(szStr)
  szFilledChar = szFilledChar or " "
  local nRestLen = nLen - string.len(szStr)
  local nNeedCharNum = math.floor(nRestLen / string.len(szFilledChar))
  szStr = szStr .. string.rep(szFilledChar, nNeedCharNum)
  return szStr
end
function Lib:StrFillR(szStr, nLen, szFilledChar)
  szStr = tostring(szStr)
  szFilledChar = szFilledChar or " "
  local nRestLen = nLen - string.len(szStr)
  local nNeedCharNum = math.floor(nRestLen / string.len(szFilledChar))
  szStr = string.rep(szFilledChar, nNeedCharNum) .. szStr
  return szStr
end
function Lib:StrFillC(szStr, nLen, szFilledChar)
  szStr = tostring(szStr)
  szFilledChar = szFilledChar or " "
  local nRestLen = nLen - string.len(szStr)
  local nNeedCharNum = math.floor(nRestLen / string.len(szFilledChar))
  local nLeftCharNum = math.floor(nNeedCharNum / 2)
  local nRightCharNum = nNeedCharNum - nLeftCharNum
  szStr = string.rep(szFilledChar, nLeftCharNum) .. szStr .. string.rep(szFilledChar, nRightCharNum)
  return szStr
end
function Lib:IsFileExsit(strFilePath)
  local file, err = io.open(strFilePath, "rb")
  if not file then
    return false
  end
  file:close()
  return true
end
function Lib:ReadFileBinary(strFilePath)
  local file, err = io.open(strFilePath, "rb")
  if not file then
    return nil
  end
  local len = file:seek("end")
  file:seek("set")
  local data = file:read("*all")
  file:close()
  return data, len
end
function Lib:WriteFileBinary(strFilePath, szData)
  local file, err = io.open(strFilePath, "wb")
  if not file then
    return false
  end
  file:write(szData)
  file:close()
  return true
end
function Lib:GetTableSize(tbRoot)
  local tbChecked = {}
  local function fnGetSize(tb)
    local nSize = debug.gettablesize(tb)
    for _, value in pairs(tb) do
      if type(value) == "table" and not tbChecked[value] then
        tbChecked[value] = true
        nSize = nSize + fnGetSize(value)
      end
    end
    return nSize
  end
  local nSize = fnGetSize(tbRoot)
  tbChecked = nil
  return nSize
end
function Lib:GetTableSizeNew(tbRoot)
  local tbChecked = {}
  local function fnGetSize(tb)
    local nSize = debug.gettablesizenew(tb)
    for _, value in pairs(tb) do
      if type(value) == "table" and not tbChecked[value] then
        tbChecked[value] = true
        nSize = nSize + fnGetSize(value)
      end
    end
    return nSize
  end
  local nSize = fnGetSize(tbRoot)
  tbChecked = nil
  return nSize
end
function Lib:DecodeJson(szJson)
  return cjson.decode(szJson)
end
function Lib:EncodeJson(value)
  return cjson.encode(value)
end
function Lib:IsInArray(tbArray, xCheck)
  for _, v in ipairs(tbArray) do
    if v == xCheck then
      return true
    end
  end
  return false
end
function Lib:GetRandomTable(tbRateTable, szRateKey)
  local nTotalRate = 0
  local tbTmpRate = {}
  szRateKey = szRateKey or "nRate"
  for key, tbEntry in pairs(tbRateTable) do
    local nRate = tbEntry[szRateKey]
    if nRate then
      nTotalRate = nTotalRate + nRate
      table.insert(tbTmpRate, {key = key, nRate = nTotalRate})
    end
  end
  if nTotalRate <= 0 then
    return nil
  end
  local nRandomRate = MathRandom(nTotalRate)
  for _, tbRateInfo in ipairs(tbTmpRate) do
    if nRandomRate <= tbRateInfo.nRate then
      return tbRateTable[tbRateInfo.key], tbRateInfo.key
    end
  end
  return nil
end
function Lib:CallZ2SOrLocalScript(nConnectIdx, szFunc, ...)
  local bRet = false
  if not MODULE_ZONESERVER then
    if string.find(szFunc, ":") then
      local szTable, szFunc = string.match(szFunc, "^(.*):(.*)$")
      local tb = loadstring("return " .. szTable)()
      if tb and tb[szFunc] then
        bRet = Lib:CallBack({
          tb[szFunc],
          tb,
          ...
        })
      end
    else
      local func = loadstring("return " .. szFunc)()
      bRet = Lib:CallBack({
        func,
        ...
      })
    end
  elseif nConnectIdx then
    CallZoneClientScript(nConnectIdx, szFunc, ...)
    bRet = true
  end
  if not bRet then
    Log("Error CallZ2SOrLocalScript Error", debug.traceback(), nConnectIdx, szFunc, ...)
  end
end
function Lib:UrlEncode(str)
  local pattern = "[^%w%d%._%-%* ]"
  str = string.gsub(str, pattern, function(c)
    local c = string.format("%%%02X", string.byte(c))
    return c
  end)
  str = string.gsub(str, " ", "+")
  return str
end
function Lib:SortStrByAlphabet(tbSort)
  table.sort(tbSort, function(k1, k2)
    local nMax1 = #k1
    local nMax2 = #k2
    local nKLen = math.min(nMax1, nMax2)
    for i = 1, nKLen do
      local b1 = string.byte(k1, i)
      local b2 = string.byte(k2, i)
      if b1 ~= b2 then
        return b1 < b2
      end
    end
    return nMax1 < nMax2
  end)
  return tbSort
end
function Lib:GetTimeFrameRemainDay(szTimeFrame)
  if GetTimeFrameState(szTimeFrame) == 1 then
    return 0
  end
  local nOpenTime = CalcTimeFrameOpenTime(szTimeFrame)
  return Lib:GetLocalDay(nOpenTime) - Lib:GetLocalDay()
end
function Lib:GetDifferentRandomNum(nCount)
  assert(nCount > 0)
  local nLastNum = 0
  return function()
    if nCount == 1 then
      return 1
    end
    if nLastNum == 0 then
      nLastNum = MathRandom(1, nCount)
      return nLastNum
    end
    local nNum = MathRandom(1, nCount - 1)
    if nNum < nLastNum then
      nLastNum = nNum
    else
      nLastNum = nNum + 1
    end
    return nLastNum
  end
end
function Lib:GetDifferentRandomSelect(tbInfo)
  local nCount = #tbInfo
  local nLastIndex = 0
  return function()
    if nCount == 0 then
      return
    end
    local nCurIndex
    if nCount == 1 then
      nCurIndex = 1
    elseif nLastIndex == 0 then
      nCurIndex = MathRandom(1, nCount)
    else
      nCurIndex = MathRandom(1, nCount - 1)
      if nCurIndex >= nLastIndex then
        nCurIndex = nCurIndex + 1
      end
    end
    nLastIndex = assert(nCurIndex)
    return tbInfo[nLastIndex]
  end
end
function Lib:GetDifferentEntry(tbInfo)
  local tbUnselected = {}
  local nCount = #tbInfo
  for nIndex = 1, nCount do
    table.insert(tbUnselected, nIndex)
  end
  return function()
    if #tbUnselected <= 0 then
      return
    end
    local nSelect = MathRandom(1, #tbUnselected)
    local nIndex = tbUnselected[nSelect]
    table.remove(tbUnselected, nSelect)
    return tbInfo[nIndex], nIndex
  end
end
function Lib:GetMonthDayCount(nTime)
  local tbTime = os.date("*t", nTime or GetTime())
  return tonumber(os.date("%d", os.time({
    year = tbTime.year,
    month = tbTime.month + 1,
    day = 0
  })))
end
function Lib:IsLeapYear(nYear)
  return nYear % 4 == 0 and nYear % 100 ~= 0 or nYear % 400 == 0
end
local nMinMonthSec = 2419200
function Lib:GetDiffMonth(nTimeFrom, nTimeTo)
  if nTimeTo - nTimeFrom < nMinMonthSec then
    return 0
  end
  local tbFromDate = os.date("*t", nTimeFrom)
  local tbToDate = os.date("*t", nTimeTo)
  local nFromDay = tbFromDate.day
  local nToDay = tbToDate.day
  if nFromDay > nToDay then
    local bLastDay = nToDay >= 28 and self:GetMonthDayCount(nTimeTo) == nToDay
    if not bLastDay then
      tbToDate.month = tbToDate.month - 1
    end
  end
  return tbToDate.year * 12 + tbToDate.month - (tbFromDate.year * 12 + tbFromDate.month)
end
