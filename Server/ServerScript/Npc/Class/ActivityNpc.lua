local tbNpc = Npc:GetClass("ActivityNpc");

function tbNpc:OnDialog()
    if not version_vn then
        Dialog:Show(
        {
            Text    = "你找我什麼事？",
            OptList = {
                { Text = "與情緣書", Callback = self.PlaySound, Param = {self, 17} },
                { Text = "劍俠情", Callback = self.PlaySound, Param = {self, 10} },
                { Text = "大英雄", Callback = self.PlaySound, Param = {self, 21} },
                { Text = "愛的廢墟", Callback = self.PlaySound, Param = {self, 10020} },
                { Text = "畫地為牢", Callback = self.PlaySound, Param = {self, 11} },
                { Text = "三生三世", Callback = self.PlaySound, Param = {self, 12} },
                { Text = "停止播放", Callback = self.RestartPlayMapSound, Param = {self} },
                { Text = "你先忙！", Callback = function () end},
            },
        }, me, him);
    else
        Dialog:Show(
        {
            Text    = "你找我什麼事？",
            OptList = {
                { Text = "劍俠情緣", Callback = self.PlaySound, Param = {self, 10} },
                { Text = "大英雄", Callback = self.PlaySound, Param = {self, 21} },
                { Text = "劍俠情", Callback = self.PlaySound, Param = {self, 16} },
                { Text = "畫地為牢", Callback = self.PlaySound, Param = {self, 11} },
                { Text = "三生緣", Callback = self.PlaySound, Param = {self, 12} },
                { Text = "我們去找到你", Callback = self.PlaySound, Param = {self, 14} },
                { Text = "停止播放", Callback = self.RestartPlayMapSound, Param = {self} },
                { Text = "你先忙！", Callback = function () end},
            },
        }, me, him);    
    end    
end

function tbNpc:PlaySound(nSoundID)
    me.CallClientScript("Map:PlaySceneOneSound", nSoundID);
end

function tbNpc:RestartPlayMapSound()
    me.CallClientScript("Map:RestartPlayMapSound");
end