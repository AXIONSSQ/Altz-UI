﻿local T, C, L, G = unpack(select(2, ...))

if not aCoreCDB["TooltipOptions"]["showspellID"] or not aCoreCDB["TooltipOptions"]["enabletip"] then return end

hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
	local id = select(11,UnitBuff(...))
	if id then
		self:AddLine(" ")
		self:AddDoubleLine("SpellID:",format(G.classcolor.."%s|r",id))
		self:Show()
	end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	local id = select(11,UnitDebuff(...))
	if id then
		self:AddLine(" ")
		self:AddDoubleLine("SpellID:",format(G.classcolor.."%s|r",id))
		self:Show()
	end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	local id = select(11,UnitAura(...))
	if id then
		self:AddLine(" ")
		self:AddDoubleLine("SpellID:",format(G.classcolor.."%s|r",id))
		self:Show()
	end
end)

hooksecurefunc("SetItemRef", function(link)
	if string.find(link,"^spell:") then
		local id = string.sub(link,7)
		ItemRefTooltip:AddLine(" ")
		ItemRefTooltip:AddDoubleLine("SpellID:",format(G.classcolor.."%s|r",id))
		ItemRefTooltip:Show()
	end
end)

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:SetScript("OnEvent", function(self, _, addon)
	if addon == "Blizzard_TalentUI" then

		for i = 1, 7 do
			for j = 1, 3 do
				local bu = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
				bu.nospellid = true
			end
		end

		for i = 1, 6 do
			for j = 1, 3 do
				local pvpbu = PlayerTalentFramePVPTalents.Talents["Tier"..i]["Talent"..j]
				pvpbu.nospellid = true
			end
		end

	end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local parent = self:GetOwner()
	if parent and parent.nospellid then
		return
	end

	local id = select(3,self:GetSpell())
	if id then
		self:AddLine(" ")
		self:AddDoubleLine("SpellID:",format(G.classcolor.."%s|r",id))
		self:Show()
	end
end)
