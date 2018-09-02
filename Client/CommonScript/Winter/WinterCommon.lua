Activity.Winter = Activity.Winter or {}
local Winter = Activity.Winter
Winter.nTangYuanItemId = 3525
Winter.nJiaoZiItemId = 3524
Winter.nGatherFirstJoinActive = 20
Winter.nGatherAnswerRightActive = 20
Winter.nGatherAnswerWrongActive = 20
Winter.nLimitLevel = 20
Winter.nTangYuanValidTime = 86400
Winter.nJiaoZiValidTime = 86400
Winter.nSendJiaoZiCount = 1
function Winter:GetTangYuanItemId()
  return Winter.nTangYuanItemId
end
function Winter:GetJiaoZiItemId()
  return Winter.nJiaoZiItemId
end
