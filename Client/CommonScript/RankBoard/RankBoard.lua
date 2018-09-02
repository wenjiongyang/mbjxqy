RankBoard.PAGE_NUM = 7
RankBoard.nRequestDelay = 60
function RankBoard:Init()
  self.tbSetting = LoadTabFile("Setting/rankboard.tab", "sdsdddsssds", "Key", {
    "Key",
    "ID",
    "Name",
    "Type",
    "Refresh",
    "MaxNum",
    "TimeFrame",
    "Tips",
    "Sub",
    "ManualMode",
    "ActivityType"
  })
end
RankBoard:Init()
