Require("CommonScript/Item/XiuLian.lua");

local tbItem = Item:GetClass("XiuLianZhu");
function tbItem:OnUse(pItem)
    local tbDef = XiuLian.tbDef;
    local bRet = XiuLian:CanBuyXiuLianDan(me);
    if bRet then
        me.CallClientScript("Ui:OpenWindow", "CommonShop", "Treasure", "tabAllShop", tbDef.nXiuLianDanID);
        me.CallClientScript("Ui:CloseWindow", "ItemTips");
    else
        me.CallClientScript("Ui:OpenWindow", "FieldPracticePanel");
    end
end

function tbItem:GetTip(pItem)
    local tbDan = Item:GetClass("XiuLianDan");
    local szMsg = "";
    local nCount = tbDan:GetOpenResidueCount(me);
    local nResidueTime = XiuLian:GetXiuLianResidueTime(me);
    szMsg = string.format("剩餘累積修煉時間：[FFFE0D]%s[-]\n累積可使用修煉丹：[FFFE0D]%s次[-]", Lib:TimeDesc(nResidueTime), nCount);
    return szMsg;
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbOpt = {szFirstName = "使用", fnFirst = "UseItem"};
    local bRet = XiuLian:CanBuyXiuLianDan(me);
    if bRet then
        tbOpt.szFirstName = "購買修煉丹";
    end

    return tbOpt;
end