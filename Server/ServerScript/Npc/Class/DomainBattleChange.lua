--领土战召唤出来的变身npc
local tbNpc = Npc:GetClass("DomainBattleChange") 

function tbNpc:OnDialog(szParam)
	if me.dwKinId ~= him.dwKinId then
		return
	end

	local _,_ ,szText, nChangeSkillId, nDuraTime= string.find(szParam, "(.*)|(%d+)|(%d+)")
	nChangeSkillId = tonumber(nChangeSkillId)
	nDuraTime = tonumber(nDuraTime)
	Dialog:Show(
	{
	    Text    = him.szDefaultDialogInfo or "",
	    OptList = {
	        { Text = "變身" .. szText, Callback = DomainBattle.OnSelectNpcDialog, Param = {DomainBattle, him.nId, nChangeSkillId, szText, nDuraTime} },
	    },
	}, me)

end