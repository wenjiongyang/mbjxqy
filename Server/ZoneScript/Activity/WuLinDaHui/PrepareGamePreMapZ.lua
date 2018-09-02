if not MODULE_ZONESERVER then
    return
end


local tbDef    = WuLinDaHui.tbDef;
local tbPreMapLogic = HuaShanLunJian.tbBasePreMapLogic;
local tbPreMapHSLJ = Map:GetClass(HuaShanLunJian.tbDef.tbPrepareGame.nPrepareMapTID);
local tbPreMap = Map:GetClass(tbDef.tbPrepareGame.nPrepareMapTID);

tbPreMap.OnCreate = tbPreMapHSLJ.OnCreate
tbPreMap.OnDestroy = tbPreMapHSLJ.OnDestroy
tbPreMap.OnEnter = tbPreMapHSLJ.OnEnter
tbPreMap.OnLeave = tbPreMapHSLJ.OnLeave
tbPreMap.OnLogin = tbPreMapHSLJ.OnLogin


local tbPlayMap         = Map:GetClass(tbDef.tbPrepareGame.nPlayMapTID);
local tbPlayMapHSLJ 	= Map:GetClass(HuaShanLunJian.tbDef.tbPrepareGame.nPlayMapTID);

tbPlayMap.OnCreate = tbPlayMapHSLJ.OnCreate
tbPlayMap.OnDestroy = tbPlayMapHSLJ.OnDestroy
tbPlayMap.OnEnter = tbPlayMapHSLJ.OnEnter
tbPlayMap.OnLeave = tbPlayMapHSLJ.OnLeave
tbPlayMap.OnLogin = tbPlayMapHSLJ.OnLogin

--重载
function tbPreMapLogic:OnCreate(nMapId)
    self.nMapId = nMapId;
    self.tbEnterFighTeam = {};
    self.nEnterFightTeam = 0;
    self.tbAllPlayerInfo = {};
    
    CallZoneClientScript(-1,  "WuLinDaHui:OnPreMapCreate", nMapId, WuLinDaHui.nOpenMathTime, WuLinDaHui.nCurGameType)
end

--重载
function tbPreMapLogic:GetHSLJBattleInfoShowInfoHelp()
    return "WLDHPre" .. WuLinDaHui.nCurGameType;
end