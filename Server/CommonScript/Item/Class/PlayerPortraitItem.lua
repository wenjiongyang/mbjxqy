local tbItem = Item:GetClass("PlayerPortraitItem")

function tbItem:OnUse(it)
    local nMySex    = Gift:CheckSex(me.nFaction)
    local nPortrait = KItem.GetItemExtParam(it.dwTemplateId, nMySex)
    if not nPortrait then
        Log("[PlayerPortraitItem Setting Err]", it.dwTemplateId)
        return
    end

    PlayerPortrait:AddPortrait(me, nPortrait)
    PlayerPortrait:ChangePortrait(me, nPortrait)
    me.CenterMsg("恭喜獲得了一個新的角色頭像！已自動更換！")
    Log("[PlayerPortraitItem OnUse]", it.dwId, me.dwID, nPortrait)
    return 1
end


--不区分性别，全部给
local tbItem_NoSex = Item:GetClass("PlayerPortraitItem_NoSex")
function tbItem_NoSex:OnUse(it)
    local nChangePor
    for i = 1, 99 do
        local nPortrait = KItem.GetItemExtParam(it.dwTemplateId, i)
        if not nPortrait or nPortrait <= 0 then
            return 1
        end

        PlayerPortrait:AddPortrait(me, nPortrait)
        if not nChangePor and PlayerPortrait:CheckFaction(me, nPortrait) then
            nChangePor = nPortrait
            PlayerPortrait:ChangePortrait(me, nPortrait)
            me.CenterMsg("恭喜獲得了新的角色頭像！已自動更換！")
        end
        Log("[PlayerPortraitItem_NoSex OnUse]", it.dwId, me.dwID, nPortrait)
    end
end