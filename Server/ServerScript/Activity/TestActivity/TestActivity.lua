
local tbActivity = Activity:GetClass("TestActivity");

tbActivity.tbTimerTrigger = 
{
	[1] = {szType = "PassedTime", Day = 2,         Trigger = "Step_ActivityOpen"},			-- 几天后开始活动，现在是预告
	[3] = {szType = "Timer",      Time = 3600 * 2, Trigger = "SortKin"},					-- 隔多久更新一次
}

tbActivity.tbTrigger = 
{
	Init = 
	{
	},
    Start = 
    {
    },
    End = 
    {
    },
}




