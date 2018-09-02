
if (not FightSkill.tbStatereplaceregular) then
	FightSkill.tbStateReplaceRegular = {};
end

local tbRegular = FightSkill.tbStateReplaceRegular;

tbRegular.tbReplaceRegular = 
{
	-- 新来的强制替换
	tbForceReplace = 
	{
		{1291},--明王镇魂
	},
	
	-- 等级高的替换 
	tbLevelReplace = 
	{
	},
	-- 时间多的替换
	tbTimeReplace = 
	{
		{4542,4543}, --阳春白雪
	},
	-- 自身的优先
	tbRelation = 
	{	
		{246,247}, --气盖八荒
		{645,646}, --真武七截
		{341,342}, --佛心慈佑
		{818,819}, --雪影
		{4015,4016}, --淬毒术
		{4341,4342}, --百毒穿心
		{4509,4510}, --云生结海
	},
	-- 魔法属性值较大的优先，设为一组内的技能需要有且仅有一条魔法属性，且是相同属性，才会生效
	-- 若技能填入如下组，则该技能本身的替代规则也由默认的等级优先，变为大数值优先
	tbMagicValue = 
	{
	},
	--已有此buff,不会刷新buff
	tbFirstRecValue =
	{
		{1766}, --镇狱破天劲_子1	
	},
	--如果以前存在此buff，则buff等级+1，即叠加
	tbSuperpose = 
	{
		{221},--霸王怒吼_子
		{241},--惊雷破天
		{245},--中级·霸王怒吼_子
		{225},--一骑当千_子
		{228},--血战八方_子4
		{279},--立地成佛_子
		{512},--直捣黄龙_子2
		{523},--龙跃于渊_子1
		{562},--悲酥清风
		{628},--太极无意_增命中
		{2647},--行云阵_子
		{743}, --魔焰七杀	
		{744}, --魔焰七杀_自身BUFF	
		{2675}, --满江红_buff	
		{2872}, --镇狱破天劲_子1	
		{2534}, --嚎叫
		{3448}, --高级·霸王怒吼_子
		{4020}, --心眼
		{4119}, --混元乾坤_增闪避
		{4120}, --混元乾坤_减闪避
		{4040}, --初级·迷影纵_叠抗
		{4045}, --中级·迷影纵_叠抗
		{4057}, --高级·迷影纵_叠抗
		{4219}, --滑不留手
		{4223}, --游龙决_子1
		{4411}, --心剑
		{4432}, --映波锁澜
		{4462}, --高级·峰插云景
		{4489}, --心剑-新手
	},
	--如果以前存在此buff，且等级和类型一样，则叠加剩余时间
	tbTimeAdd = 
	{
	},
	-- 开关buff
	tbSwitch =
	{
	},
	-- 属性合成，只支持回血和回蓝两条属性
	tbMerge =
	{
	},
	tbDotMerge=
	{
		{4301,4302,4303,4304,4309,4333,4335,4339,4346},
	},
	--如果以前存在此buff，且等级和类型一样，则替换剩余时间
	tbTimeRefresh=
	{	
	},
}

function tbRegular:AdjustSkillRegular()
	local tbSkillCheck = {};
	for _, tbRegular in pairs(self.tbReplaceRegular) do
		for _, tbSkillId in ipairs(tbRegular) do
			for _, nSkillId in ipairs(tbSkillId) do
				assert(not tbSkillCheck[nSkillId]);
				tbSkillCheck[nSkillId] = 1;
			end
		end
	end
end

tbRegular:AdjustSkillRegular();


function tbRegular:GetConflictingSkillList(nDesSkillId)
	for _, tbRegular in pairs(self.tbReplaceRegular) do
		for _, tbSkillId in ipairs(tbRegular) do
			for _, nSkillId in ipairs(tbSkillId) do
				if (nDesSkillId == nSkillId) then
					return tbSkillId;
				end
			end
		end
	end
end

function tbRegular:GetStateGroupReplaceType(nDesSkillId)
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbForceReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 1;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbLevelReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 2;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeReplace) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 3;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbRelation) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 4;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbMagicValue) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 5;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbFirstRecValue) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 6;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbSuperpose) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 7;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeAdd) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 8;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbDotMerge) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 9;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbSwitch) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 10;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbMerge) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 11;
			end
		end
	end
	
	for _, tbSkillId in ipairs(self.tbReplaceRegular.tbTimeRefresh) do
		for _, nSkillId in ipairs(tbSkillId) do
			if (nDesSkillId == nSkillId) then
				return 12;
			end
		end
	end	
	return 0;
end
