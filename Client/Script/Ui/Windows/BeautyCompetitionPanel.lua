local tbUi = Ui:CreateClass("BeautyCompetitionPanel")
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_BEAUTY_FRIEND_LIST,
      self.UpdateList,
      self
    }
  }
  return tbRegEvent
end
function tbUi:OnOpen()
  Activity.BeautyPageant:RequestSignUpFriend()
  self:UpdateList()
end
function tbUi:UpdateList()
  local tbPlayerMap = Activity.BeautyPageant:GetSignUpFriendList()
  local tbList = {}
  for nPlayerId, _ in pairs(tbPlayerMap) do
    local tbData = FriendShip:GetFriendDataInfo(nPlayerId)
    if tbData then
      local tbInfo = {
        nPlayerId = nPlayerId,
        szName = tbData.szName,
        nLevel = tbData.nLevel,
        nFaction = tbData.nFaction,
        nPortrait = tbData.nPortrait,
        nHonorLevel = tbData.nHonorLevel,
        nImity = tbData.nImity
      }
      table.insert(tbList, tbInfo)
    end
  end
  local fnImitySort = function(a, b)
    return a.nImity > b.nImity
  end
  table.sort(tbList, fnImitySort)
  local function fnSetItem(tbItem, nIndex)
    local tbInfo = tbList[nIndex]
    tbItem.pPanel:Label_SetText("lbRoleName", tbInfo.szName)
    tbItem.pPanel:Label_SetText("lbLevel", tostring(tbInfo.nLevel))
    if tbInfo.nHonorLevel > 0 then
      tbItem.pPanel:SetActive("PlayerTitle", true)
      tbItem.pPanel:Sprite_Animation("PlayerTitle", "Title" .. tbInfo.nHonorLevel .. "_")
    else
      tbItem.pPanel:SetActive("PlayerTitle", false)
    end
    local szSprite, szAtlas = PlayerPortrait:GetPortraitIcon(tbInfo.nPortrait)
    if not Lib:IsEmptyStr(szSprite) and not Lib:IsEmptyStr(szAtlas) then
      tbItem.pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas)
    end
    tbItem.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbInfo.nFaction))
    function tbItem.BtnGive.pPanel.OnTouchEvent()
      self:VoteFor(tbInfo)
    end
  end
  self.ScrollView:Update(tbList, fnSetItem)
  self.pPanel:SetActive("Tip", #tbList <= 0)
end
function tbUi:VoteFor(tbInfo)
  Ui.HyperTextHandle:Handle(string.format("[url=openBeautyUrl:PlayerPage, %s][-]", string.format(Activity.BeautyPageant.szPlayerUrl, tbInfo.nPlayerId, Sdk:GetServerId())))
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnOther()
  Activity.BeautyPageant:OpenMainPage()
  Ui:CloseWindow(self.UI_NAME)
end
