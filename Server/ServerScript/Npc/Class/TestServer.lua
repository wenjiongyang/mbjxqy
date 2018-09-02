local tbNpc	= Npc:GetClass("TestServer");

--npc被创建
function tbNpc:OnCreate()
	Log(" 呸！我是 %s", him.szName);
end

-- 定义对话事件
function tbNpc:OnDialog(szParam)
	print("tbNpc:OnDialog " .. szParam);
end

-- 定义死亡事件
function tbNpc:OnDeath(pNpcKiller)
end
