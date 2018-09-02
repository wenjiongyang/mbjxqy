local tbUi = Ui:CreateClass("Comment")
function tbUi:OnOpen()
  if not version_tx then
    return 0
  end
  if Client:IsCloseIOSEntry() then
    return 0
  end
  if not IOS and not WINDOWS then
    return 0
  end
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnRefuse()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnComplaints()
  if version_tx then
    if Sdk:IsLoginByQQ() then
      Sdk:OpenUrl("http://s.p.qq.com/pub/jump?d=AABI2v3z&_wv=1027")
    else
      Sdk:OpenUrl("http://game.weixin.qq.com/cgi-bin/h5/static/community/club_detail.html?jsapi=1&banner_need=1&appid=wxacbfe7e1bb3e800f&topic_id=4198085&auth_type=2&ssid=12")
    end
  else
    Sdk:OpenUrl("http://jxqy.qq.com/")
  end
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnPraise()
  if IOS then
    local szId
    if version_tx then
      szId = "1086842482"
    elseif version_hk then
      szId = "1132435921"
    elseif version_tw then
      szId = "1132436180"
    elseif version_xm then
      szId = "1159225159"
    end
    if szId then
      Ui.CoreDll.IOSOpenUrl("itms-apps://itunes.apple.com/app/id" .. szId)
    end
  elseif ANDROID then
    if version_tx then
      Sdk:OpenUrl("http://appicsh.qq.com/cgi-bin/appstage/trans_page?task_id=957")
    else
      local szPackageName
      if version_hk then
        szPackageName = "com.efun.jxqy.hk"
      elseif version_tw then
        szPackageName = "com.efun.jxqy.tw"
      elseif version_xm then
        szPackageName = "com.efun.jxqy.sm"
      end
      if szPackageName then
        Ui.Application.OpenURL("https://play.google.com/store/apps/details?id=" .. szPackageName)
      end
    end
  else
    me.CenterMsg("假装去评论了！")
  end
  RemoteServer.TLogClickPraise()
  Ui:CloseWindow(self.UI_NAME)
end
