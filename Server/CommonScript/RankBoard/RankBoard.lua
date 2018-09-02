RankBoard.PAGE_NUM = 7; --一页显示7个
RankBoard.nRequestDelay = 60;--同一类的一分钟请求间隔 todo 

function RankBoard:Init()
    self.tbSetting = LoadTabFile(
	    "Setting/rankboard.tab", 
	    "sdsdddsssds", "Key", 
	    {"Key", "ID", "Name", "Type", "Refresh", "MaxNum", "TimeFrame", "Tips", "Sub", "ManualMode", "ActivityType"});

end

RankBoard:Init();

