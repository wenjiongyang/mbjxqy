local tbNpc = Npc:GetClass("ActivityQuestion");

function tbNpc:OnDialog()
    if ActivityQuestion:CheckSubmitTask() then
        Dialog:Show(
        {
            Text    = "今日的俠士是否已經拜訪完畢了？對江湖之事是否有了更多的瞭解？",
            OptList = {
                { Text = "完成答題", Callback = function ()
                    ActivityQuestion:TrySubmitTask()
                end},
            },
        }, me, him)
    else
        Npc:ShowDefaultDialog()
    end
end