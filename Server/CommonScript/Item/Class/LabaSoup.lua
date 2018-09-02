local tbItem = Item:GetClass("LabaSoup")

tbItem.nSkillId = 2316
tbItem.nBuffDuration = 23*3600
tbItem.nExpAddRate = 0.6

function tbItem:OnUse(it)
	if self:HasDrank(me) then
		me.CenterMsg("少俠已喝過臘八粥了，還是稍後再喝吧")
		return 0
	end

	me.AddSkillState(self.nSkillId, 1, 1, Env.GAME_FPS*self.nBuffDuration, 1, 1)
	me.CenterMsg("你喝了一碗臘八粥")
	me.Msg("你喝了一碗臘八粥")

	return 1
end

function tbItem:HasDrank(pPlayer)
	return pPlayer.GetNpc().GetSkillState(self.nSkillId)
end

function tbItem:GetExpAddRate(pPlayer)
	return self:HasDrank(pPlayer) and self.nExpAddRate or 0
end