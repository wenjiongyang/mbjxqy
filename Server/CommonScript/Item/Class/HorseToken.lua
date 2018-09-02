local tbItem = Item:GetClass("HorseToken")
tbItem.szEvolutionTimeFrame = "OpenLevel79"
tbItem.szEvolutionTimeFrame2 = "OpenLevel99"
tbItem.szEvolutionTimeFrame3 = "OpenLevel119"

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbUseSetting = {szFirstName = "兌換", fnFirst = "UseItem"};

    if GetTimeFrameState(self.szEvolutionTimeFrame) == 1 then
        tbUseSetting.szSecondName = "升階"        
        tbUseSetting.fnSecond = function ()
            Ui:CloseWindow("ItemTips")
            Ui:OpenWindow("EquipmentEvolutionPanel", "Type_EvolutionHorse")
        end
    end

    return tbUseSetting;        
end

function tbItem:OnUse(pItem)
    local tbExchangeItem = Item:GetClass("ExchangeItem")
    return  tbExchangeItem:OnUse(pItem)
end

function tbItem:GetIntrol(dwTemplateId)
    local tbBase = KItem.GetItemBaseProp(dwTemplateId)
    local szBaseTip = tbBase.szIntro
    if GetTimeFrameState(self.szEvolutionTimeFrame) == 1 then
        szBaseTip = szBaseTip .. "\n\n可以將50級烏雲踏雪，升階為70級絕影"
    end
    if GetTimeFrameState(self.szEvolutionTimeFrame2) == 1 then
        szBaseTip = szBaseTip .. "\n可以將70級絕影，升階為90級萬里煙雲照"
    end
    if GetTimeFrameState(self.szEvolutionTimeFrame3) == 1 then
        szBaseTip = szBaseTip .. "\n可以將90級萬里煙雲照，升階為 110級追風呼雷豹"
    end
    return szBaseTip
end