local tbNpc   = Npc:GetClass("InDifferShopNpc")

function tbNpc:OnCreate()
    local tbInst = InDifferBattle.tbMapInst[him.nMapId]
    if not tbInst then
        Log(debug.traceback(), him.nMapId)
        return
    end
    if tbInst then
        local tbSellSetting = InDifferBattle.tbDefine.tbSellWarePropSetting[tbInst.nSchedulePos]
        if not tbSellSetting then
            Log(debug.traceback(), him.nMapId)
            return
        end
        local tbCurSellWares = {}
        for i,v in ipairs(tbSellSetting) do
            local nTemplateId, nRandMin, nRandMax = unpack(v)
            if type(nTemplateId) == "table" then
                local nCount = MathRandom(nRandMin, nRandMax)
                local nKindNum = #nTemplateId
                local tbTemp = {};
                for i2=1,nCount do
                    local nTar = nTemplateId[ MathRandom(nKindNum) ]
                    tbTemp[ nTar ] = (tbTemp[nTar] or 0) + 1;
                end
                for k2,v2 in pairs(tbTemp) do
                    tbCurSellWares[k2] = v2
                end
            else
                tbCurSellWares[nTemplateId] = MathRandom(nRandMin, nRandMax)
            end
            
        end
        him.tbCurSellWares = tbCurSellWares;     
    end
end

function tbNpc:OnDialog()
    me.CallClientScript("Ui:OpenWindow", "DreamlandShopPanel",  him.tbCurSellWares, him.nId)    
end