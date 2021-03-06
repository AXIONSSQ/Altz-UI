local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	TradePlayerEnchantInset:DisableDrawLayer("BORDER")
	TradePlayerItemsInset:DisableDrawLayer("BORDER")
	TradeRecipientEnchantInset:DisableDrawLayer("BORDER")
	TradeRecipientItemsInset:DisableDrawLayer("BORDER")
	TradePlayerInputMoneyInset:DisableDrawLayer("BORDER")
	TradeRecipientMoneyInset:DisableDrawLayer("BORDER")
	TradeRecipientBG:Hide()
	TradePlayerEnchantInsetBg:Hide()
	TradePlayerItemsInsetBg:Hide()
	TradePlayerInputMoneyInsetBg:Hide()
	TradeRecipientEnchantInsetBg:Hide()
	TradeRecipientItemsInsetBg:Hide()
	TradeRecipientMoneyBg:Hide()
	TradeRecipientPortraitFrame:Hide()
	TradeRecipientBotLeftCorner:Hide()
	TradeRecipientLeftBorder:Hide()
	select(4, TradePlayerItem7:GetRegions()):Hide()
	select(4, TradeRecipientItem7:GetRegions()):Hide()
	TradeFramePlayerPortrait:Hide()
	TradeFrameRecipientPortrait:Hide()

	F.ReskinPortraitFrame(TradeFrame, true)
	F.Reskin(TradeFrameTradeButton)
	F.Reskin(TradeFrameCancelButton)
	F.ReskinInput(TradePlayerInputMoneyFrameGold)
	F.ReskinInput(TradePlayerInputMoneyFrameSilver)
	F.ReskinInput(TradePlayerInputMoneyFrameCopper)

	TradePlayerInputMoneyFrameSilver:SetPoint("LEFT", TradePlayerInputMoneyFrameGold, "RIGHT", 1, 0)
	TradePlayerInputMoneyFrameCopper:SetPoint("LEFT", TradePlayerInputMoneyFrameSilver, "RIGHT", 1, 0)

	local function reskinButton(bu)
		bu:SetNormalTexture("")
		bu:SetPushedTexture("")
		bu.icon:SetTexCoord(.08, .92, .08, .92)
		bu.IconBorder:SetAlpha(0)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		F.CreateBDFrame(bu, .25)
	end

	for i = 1, MAX_TRADE_ITEMS do
		_G["TradePlayerItem"..i.."SlotTexture"]:Hide()
		_G["TradePlayerItem"..i.."NameFrame"]:Hide()
		_G["TradeRecipientItem"..i.."SlotTexture"]:Hide()
		_G["TradeRecipientItem"..i.."NameFrame"]:Hide()

		reskinButton(_G["TradePlayerItem"..i.."ItemButton"])
		reskinButton(_G["TradeRecipientItem"..i.."ItemButton"])
	end
end)