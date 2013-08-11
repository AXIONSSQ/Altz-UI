﻿local T, C, L, G = unpack(select(2, ...))
local oUF = AltzUF or oUF

oUF.colors.power["MANA"] = {0, 0.8, 1}
oUF.colors.power["RAGE"] = {.9, .1, .1}
oUF.colors.power["FUEL"] = {0, 0.55, 0.5}
oUF.colors.power["FOCUS"] = {.9, .5, .1}
oUF.colors.power["ENERGY"] = {.9, .9, .1}
oUF.colors.power["AMMOSLOT"] = {0.8, 0.6, 0}
oUF.colors.power["RUNIC_POWER"] = {.1, .9, .9}
oUF.colors.power["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61}
oUF.colors.power["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17}

oUF.colors.reaction[1] = {255/255, 30/255, 60/255}
oUF.colors.reaction[2] = {255/255, 30/255, 60/255}
oUF.colors.reaction[3] = {255/255, 30/255, 60/255}
oUF.colors.reaction[4] = {1, 1, 0}
oUF.colors.reaction[5] = {0.26, 1, 0.22}
oUF.colors.reaction[6] = {0.26, 1, 0.22}
oUF.colors.reaction[7] = {0.26, 1, 0.22}
oUF.colors.reaction[8] = {0.26, 1, 0.22}

oUF.colors.smooth = {1,0,0, 1,1,0, 1,1,0}

local classicon_colors = { --monk/paladin/preist
	{150/255, 0/255, 40/255},
	{220/255, 20/255, 40/255},
	{255/255, 50/255, 90/255},
	{255/255, 80/255, 120/255},
	{255/255, 110/255, 160/255},
}

local cpoints_colors = { -- combat points
	{220/255, 40/255, 0/255},
	{255/255, 110/255, 0/255},
	{255/255, 150/255, 0/130},
	{255/255, 200/255, 0/255},
	{255/255, 255/255, 0/255},
}

--=============================================--
--[[                 Functions               ]]--
--=============================================--
local function multicheck(check, ...)
    for i=1, select("#", ...) do
        if check == select(i, ...) then return true end
    end
    return false
end
--=============================================--
--[[             MouseOn update              ]]--
--=============================================--
T.OnMouseOver = function(self)
    local OnEnter = function(self)
		UnitFrame_OnEnter(self)
		self.isMouseOver = true
		for _, element in ipairs(self.mouseovers) do
			element:ForceUpdate()
		end
    end
    local OnLeave = function(self)
		UnitFrame_OnLeave(self)
		self.isMouseOver = false
		for _, element in ipairs(self.mouseovers) do
			element:ForceUpdate()
		end
    end
    self:SetScript("OnEnter", OnEnter)
    self:SetScript("OnLeave", OnLeave)
end
--=============================================--
--[[               Some update               ]]--
--=============================================--
T.Updatehealthbar = function(self, unit, min, max)
	local r, g, b
	local perc
	
	if max ~= 0 then perc = min/max else perc = 1 end
	
	if self.value then
		if min > 0 and min < max then
			self.value:SetText(T.ShortValue(min).." "..T.hex(1, 1, 0)..math.floor(min/max*100+.5).."|r")
		elseif min > 0 and self.__owner.isMouseOver and UnitIsConnected(unit) then
			self.value:SetText(T.ShortValue(min))
		elseif aCoreCDB["UnitframeOptions"]["alwayshp"] then
			self.value:SetText(T.ShortValue(min))
		else
			self.value:SetText(nil)
		end
	end
	
	if min > 0 and min < max then
		self.ind:Show()
	else
		self.ind:Hide()
	end
	
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		r, g, b = .6, .6, .6
	elseif not UnitIsConnected(unit) then
		r, g, b = .3, .3, .3
	elseif UnitIsGhost(unit) then
		r, g, b = .6, .6, .6
	elseif UnitIsDead(unit) then
		r, g, b = 1, 0, 0
	elseif (unit == "pet") then
		local _, playerclass = UnitClass("player")
		if aCoreCDB["UnitframeOptions"]["classcolormode"] then
			r, g, b = unpack(oUF.colors.class[playerclass])
		else
			r, g, b = oUF.ColorGradient(perc, 1, unpack(oUF.colors.smooth))
		end
	elseif(UnitIsPlayer(unit)) then
		local _, unitclass = UnitClass(unit)
		if aCoreCDB["UnitframeOptions"]["classcolormode"] then
			if unitclass then r, g, b = unpack(oUF.colors.class[unitclass]) else r, g, b = 1, 1, 1 end
		else
			r, g, b = oUF.ColorGradient(perc, 1, unpack(oUF.colors.smooth))
		end
	elseif unit then
		if aCoreCDB["UnitframeOptions"]["classcolormode"] then
			r, g, b = unpack(oUF.colors.reaction[UnitReaction(unit, "player") or 5])
		else
			r, g, b = oUF.ColorGradient(perc, 1, unpack(oUF.colors.smooth))
		end
	end
	
	if aCoreCDB["OtherOptions"]["style"] == 1 then
		self:GetStatusBarTexture():SetGradient("VERTICAL", r, g, b, r/3, g/3, b/3)
	else
		self:SetStatusBarColor(r, g, b)
	end
	
	if aCoreCDB["OtherOptions"]["style"] ~= 3 then
		self:SetValue(max - self:GetValue()) 
	end
end

T.Updatepowerbar = function(self, unit, min, max)
	local r, g, b
	local type = select(2, UnitPowerType(unit))
	local powercolor = oUF.colors.power[type] or oUF.colors.power.FUEL
	
	if self.value then
		if self.__owner.isMouseOver and type == 'MANA' and UnitIsConnected(unit) then
			self.value:SetText(T.hex(unpack(powercolor))..T.ShortValue(min)..'|r')
		elseif (min > 0 and min < max) or aCoreCDB["UnitframeOptions"]["alwayspp"] then
			if type == 'MANA' then
				self.value:SetText(T.hex(1, 1, 1)..math.floor(min/max*100+.5)..'|r'..T.hex(1, .4, 1)..'%|r')
			else
				self.value:SetText(T.hex(unpack(powercolor))..T.ShortValue(min)..'|r')
			end
		else
			self.value:SetText(nil)
		end
	end
	
	if aCoreCDB["UnitframeOptions"]["classcolormode"] then
		r, g, b = unpack(powercolor)
	elseif UnitIsPlayer(unit) then
		local _, unitclass = UnitClass(unit)
		if unitclass then r, g, b = unpack(oUF.colors.class[unitclass]) else r, g, b = 1, 1, 1 end
	else
		r, g, b = unpack(oUF.colors.reaction[UnitReaction(unit, 'player') or 5])
	end
	
	if aCoreCDB["OtherOptions"]["style"] == 1 then
		self:GetStatusBarTexture():SetGradient("VERTICAL", r, g, b, r/3, g/3, b/3)
	else
		self:SetStatusBarColor(r, g, b)
	end
end

local PostAltUpdate = function(altpp, min, cur, max)
	altpp.value:SetText(cur)
	
	local self = altpp.__owner
    local tPath, r, g, b = UnitAlternatePowerTextureInfo(self.unit, 2)
	
	if not tPath then return end
	
    if tPath:match("STONEGUARDAMETHYST_HORIZONTAL_FILL.BLP") then
		altpp:SetStatusBarColor(.7, .3, 1)
	elseif tPath:match("STONEGUARDCOBALT_HORIZONTAL_FILL.BLP") then
		altpp:SetStatusBarColor(.1, .8, 1)
	elseif tPath:match("STONEGUARDJADE_HORIZONTAL_FILL.BLP") then
		altpp:SetStatusBarColor(.5, 1, .2)
	elseif tPath:match("STONEGUARDJASPER_HORIZONTAL_FILL.BLP") then
        altpp:SetStatusBarColor(1, 0, 0)
    end
end

local PostEclipseUpdateVisibility = function(self, unit)
	self.directionIsLunar = GetEclipseDirection()
	if self.value then
		if self.directionIsLunar == "moon" then
			self.value:SetTextColor(1, .6, 0)
			self.SolarBar.dir:Show()
			self.LunarBar.dir:Hide()		
		elseif self.directionIsLunar == "sun" then
			self.value:SetTextColor(0, .4, 1)
			self.SolarBar.dir:Hide()
			self.LunarBar.dir:Show()
		else
			self.value:SetTextColor(1, 1, 1)
			self.SolarBar.dir:Hide()
			self.LunarBar.dir:Hide()
		end
	end	

end

local PostEclipseUpdateAura = function(self, unit)
    if self.hasSolarEclipse then
        self.bd:SetBackdropBorderColor(1, .6, 0)
        self.bd:SetBackdropColor(1, .6, 0)
    elseif self.hasLunarEclipse then
        self.bd:SetBackdropBorderColor(0, .4, 1)
        self.bd:SetBackdropColor(0, .4, 1)
    else
        self.bd:SetBackdropBorderColor(0, 0, 0)
        self.bd:SetBackdropColor(0, 0, 0)
    end
end

local PostEclipseDirectionChange = function(self, unit)
	if self.value then
		if self.directionIsLunar == "moon" then
			self.value:SetTextColor(1, .6, 0)
			self.SolarBar.dir:Show()
			self.LunarBar.dir:Hide()		
		elseif self.directionIsLunar == "sun" then
			self.value:SetTextColor(0, .4, 1)
			self.SolarBar.dir:Hide()
			self.LunarBar.dir:Show()
		else
			self.value:SetTextColor(1, 1, 1)
			self.SolarBar.dir:Hide()
			self.LunarBar.dir:Hide()
		end
	end	
end

local PostEclipseUpdatePower = function(self, unit)
	if self.value then
		self.value:SetText(math.abs(UnitPower('player', SPELL_POWER_ECLIPSE)))
	end
end

local CpointsPostUpdate = function(element, cur)
	for i = 1, 5 do
		if cur == MAX_COMBO_POINTS then
			element[i]:SetStatusBarColor(unpack(cpoints_colors[MAX_COMBO_POINTS]))
		else
			element[i]:SetStatusBarColor(unpack(cpoints_colors[i]))
		end
	end
end

local ClassIconsPostUpdate = function(element, cur, max, maxchange)
	for i = 1, 5 do
		if max > 0 and cur == max then
			element[i]:SetStatusBarColor(unpack(classicon_colors[max]))
		else
			element[i]:SetStatusBarColor(unpack(classicon_colors[i]))
		end
		if maxchange then
			element[i]:SetWidth((aCoreCDB["UnitframeOptions"]["width"]+3)/max-3)
		end		
	end
end

local PostUpdateRunesType = function(self, rune, rid, alt)
	if rune.value then
		local colors = oUF.colors.runes[GetRuneType(rid) or alt]
		rune.value:SetTextColor(colors[1], colors[2], colors[3])
	end
end

local PostUpdateRunes = function(self, rune, rid, start, duration, runeReady)
	if rune.value then
		if runeReady then
			rune.value:SetText("")
		else
			rune:HookScript("OnUpdate", function(self, elapsed)
				local duration = self.duration + elapsed
				if duration >= self.max or duration <= 0 then
					rune.value:SetText("")
				else
					rune.value:SetText(T.FormatTime(self.max - duration))
				end
			end)
		end
	end
end

local CombatPostUpdate = function(self, inCombat)
	if inCombat then
		self.__owner.Resting:Hide()
	elseif IsResting() then 
		self.__owner.Resting:Show()
	end
end

function UpdatePrep()
    local numOpps = GetNumArenaOpponentSpecs()
    if numOpps > 0 then
        for i=1, 5 do
            if not _G["oUF_AltzArena"..i] then return end
            local s = GetArenaOpponentSpec(i)
            local _, spec, class, texture = nil, "UNKNOWN", "UNKNOWN", "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK"
				
            if s and s > 0 then
                _, spec, _, texture, _, _, class = GetSpecializationInfoByID(s)
            end

            if (i <= numOpps) then
                if class and spec then
                    local color = oUF.colors.class[class]
					--print("职业"..class.."颜色"..color.r.."  "..color.g.."  "..color.b)
                    _G["oUF_AltzArena"..i].prepFrame.SpecClass:SetText(spec.."  -  "..LOCALIZED_CLASS_NAMES_MALE[class])
                    _G["oUF_AltzArena"..i].prepFrame.Health:SetStatusBarColor(color.r, color.g, color.b)
                    _G["oUF_AltzArena"..i].prepFrame.Icon:SetTexture(G.media.blank)
                    _G["oUF_AltzArena"..i].prepFrame:Show()
                end
            else
                _G["oUF_AltzArena"..i].prepFrame:Hide()
            end
        end
    else
        for i=1, 5 do
            if not _G["oUF_AltzArena"..i] then return end
            _G["oUF_AltzArena"..i].prepFrame:Hide()
        end
    end
end
--=============================================--
--[[                 Castbars                ]]--
--=============================================--

local uc = {1, 0, 0}
local tk
if aCoreCDB["UnitframeOptions"]["independentcb"]  then -- 独立施法条
	tk = {0, 0, 0}
elseif aCoreCDB["OtherOptions"]["style"] == 1 or aCoreCDB["OtherOptions"]["style"] == 3 then -- 透明或者经典主题
	tk = {0, 0, 0}
else -- 深色主题
	tk = {1, 1, 1}
end

local cbwidth, cbheight
if aCoreCDB["UnitframeOptions"]["independentcb"] then
	cbheight = aCoreCDB["UnitframeOptions"]["cbheight"]
	cbwidth = aCoreCDB["UnitframeOptions"]["cbwidth"]
else
	cbheight = aCoreCDB["UnitframeOptions"]["height"]
	cbwidth = aCoreCDB["UnitframeOptions"]["width"]
end

local ChannelSpells = {
	[GetSpellInfo(129197)] = 3, --精神鞭笞（乱）
	[GetSpellInfo(124468)] = 3, --精神鞭笞
	[GetSpellInfo(32000)] = 5, --精神灼烧
	[GetSpellInfo(47540)] = 2, --苦修（第一跳立即生效）
	[GetSpellInfo(64843)] = 4, --神圣赞美诗
	[GetSpellInfo(64901)] = 4, --希望圣歌
	
	[GetSpellInfo(10)] = 8, --暴风雪
	[GetSpellInfo(5143)] = 5, --奥术飞弹
	[GetSpellInfo(12051)] = 3, --唤醒（第一跳立即生效）

	[GetSpellInfo(1120)] = 6, --吸取灵魂
	[GetSpellInfo(689)] = 6, --吸取生命
	[GetSpellInfo(108371)] = 6, --生命收割
	[GetSpellInfo(4629)] = 6, --火焰之雨
	[GetSpellInfo(1949)] = 14, --地狱烈焰（第一跳立即生效）
	[GetSpellInfo(755)] = 6, --生命通道
	[GetSpellInfo(103103)] = 4, --灾难之握
	
	[GetSpellInfo(740)] = 4, --宁静
	[GetSpellInfo(16914)] = 10, --飓风
}

local PostCastStart = function(castbar, unit)
    if unit == "player" then
		castbar.IBackdrop:SetBackdropBorderColor(0, 0, 0)
	else
		if castbar.interrupt then
		    castbar.IBackdrop:SetBackdropBorderColor(uc[1], uc[2], uc[3])
        else
            castbar.IBackdrop:SetBackdropBorderColor(0, 0, 0)
        end
    end
end

local PostChannelStart = function(castbar, unit, spell)

    if unit == "player" then
		castbar.IBackdrop:SetBackdropBorderColor(0, 0, 0)
	else
		if castbar.interrupt then
		    castbar.IBackdrop:SetBackdropBorderColor(uc[1], uc[2], uc[3])
        else
            castbar.IBackdrop:SetBackdropBorderColor(0, 0, 0)
        end
    end
	
	if aCoreCDB["UnitframeOptions"]["channelticks"] then
		if unit == "player" and ChannelSpells[spell] then
			if #castbar.Ticks ~= 0 then
				for i = 1, #castbar.Ticks do
					castbar.Ticks[i]:Hide()
				end
			end
			castbar.tick = ChannelSpells[spell]
			for i = 1, (castbar.tick-1) do
				if not castbar.Ticks[i] then
					castbar.Ticks[i] = castbar:CreateTexture(nil, "OVERLAY")
					castbar.Ticks[i]:SetTexture(tk[1], tk[2], tk[3])
					castbar.Ticks[i]:SetSize(2, cbheight)
				else
					castbar.Ticks[i]:Show()
				end
				castbar.Ticks[i]:SetPoint("RIGHT", castbar, "RIGHT", -cbwidth/castbar.tick*i, 0)
			end
			--print("start")
		end
	end
end

local PostChannelUpdate = function(castbar, unit, spell)
	if aCoreCDB["UnitframeOptions"]["channelticks"] then
		if unit == "player" and ChannelSpells[spell] then
			if #castbar.Ticks ~= 0 then
				for i = 1, #castbar.Ticks do
					castbar.Ticks[i]:Hide()
				end
			end
			castbar.tick = ChannelSpells[spell] + 1
			for i = 1, (castbar.tick-1) do
				if not castbar.Ticks[i] then
					castbar.Ticks[i] = castbar:CreateTexture(nil, "OVERLAY")
					castbar.Ticks[i]:SetTexture(tk[1], tk[2], tk[3])
					castbar.Ticks[i]:SetSize(2, cbheight)
				else
					castbar.Ticks[i]:Show()
				end
				if i == 1 then
					castbar.Ticks[i]:SetPoint("RIGHT", castbar, "RIGHT", cbwidth*castbar.delay/castbar.max, 0)
				else
					castbar.Ticks[i]:SetPoint("RIGHT", castbar, "RIGHT", cbwidth*(castbar.delay/castbar.max-(1+castbar.delay/castbar.max)/(castbar.tick-1)*(i-1)), 0)
				end
			end
			--print("update")
		end
	end
end

local PostChannelStop = function(castbar, unit, spell)
	if aCoreCDB["UnitframeOptions"]["channelticks"] then
		if unit == "player" then
			if #castbar.Ticks ~= 0 then
				for i = 1, #castbar.Ticks do
					castbar.Ticks[i]:Hide()
				end
			end
		end
	end
end

local CustomTimeText = function(castbar, duration)
    if castbar.casting then
        castbar.Time:SetFormattedText("|cff97FFFF%.1f/%.1f|r", duration, castbar.max)
    elseif castbar.channeling then
        castbar.Time:SetFormattedText("|cff97FFFF%.1f/%.1f|r", castbar.max - duration, castbar.max)
    end
end

local CustomDelayText = function(castbar, duration)
    if castbar.casting then
        castbar.Time:SetFormattedText("|cff97FFFF%.1f/%.1f|r|cff8A8A8A(%.1f)|r", duration, castbar.max, -castbar.delay)
    elseif castbar.channeling then
        castbar.Time:SetFormattedText("|cff97FFFF%.1f/%.1f|r|cff8A8A8A(%.1f)|r", castbar.max - duration, castbar.max, -castbar.delay)
    end
end

local CreateCastbars = function(self, unit)
    local u = unit:match("[^%d]+")
    if multicheck(u, "target", "player", "focus", "boss") then
        local cb = CreateFrame("StatusBar", G.uiname..unit.."Castbar", self)
		if aCoreCDB["OtherOptions"]["style"] == 1 then
			cb:SetStatusBarTexture(G.media.blank)
		else
			cb:SetStatusBarTexture(G.media.ufbar)
		end
		cb:SetStatusBarColor(0, 0, 0, 0)
		cb:SetAllPoints(self)
        cb:SetFrameLevel(2)
		
        cb.Spark = cb:CreateTexture(nil, "OVERLAY")
		cb.Spark:SetTexture("Interface\\UnitPowerBarAlt\\Generic1Player_Pill_Flash")
        cb.Spark:SetBlendMode("ADD")
        cb.Spark:SetAlpha(1)
        cb.Spark:SetSize(8, aCoreCDB["UnitframeOptions"]["height"]*2)

        cb.Time = T.createnumber(cb, "OVERLAY", 14, "OUTLINE", "CENTER")
		if unit == "player" then
			cb.Time:SetFont(G.norFont, 15, "OUTLINE")
			cb.Time:SetPoint("TOP", cb, "BOTTOM", 0, -10)
		else
			cb.Time:SetPoint("BOTTOMRIGHT", cb, "TOPRIGHT", -3, -3)
		end
        cb.CustomTimeText = CustomTimeText
		cb.CustomDelayText = CustomDelayText
		
        cb.Text =  T.createtext(cb, "OVERLAY", 14, "OUTLINE", "CENTER")
		if u == "boss" then
			cb.Text:SetPoint("BOTTOMLEFT", 3, -3)
		else
			cb.Text:SetPoint("BOTTOM", 0, -3)
		end
		
        cb.Icon = cb:CreateTexture(nil, "ARTWORK")
        cb.Icon:SetSize(aCoreCDB["UnitframeOptions"]["cbIconsize"], aCoreCDB["UnitframeOptions"]["cbIconsize"])
        cb.Icon:SetTexCoord(.1, .9, .1, .9)
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -7, -aCoreCDB["UnitframeOptions"]["height"]*(1-aCoreCDB["UnitframeOptions"]["hpheight"]))

		cb.IBackdrop = T.createBackdrop(cb, cb.Icon)
		
        if unit == "player" then
            cb.SafeZone = cb:CreateTexture(nil, "OVERLAY")
            cb.SafeZone:SetTexture(G.media.blank)
            cb.SafeZone:SetVertexColor( 1, 1, 1, .5)
			
			if aCoreCDB["UnitframeOptions"]["independentcb"] then
				cb:ClearAllPoints()
				cb:SetSize(aCoreCDB["UnitframeOptions"]["cbwidth"], aCoreCDB["UnitframeOptions"]["cbheight"])
				cb.movingname = L["玩家施法条"]
				cb.point = {
						healer = {a1 = "TOP", parent = "UIParent", a2 = "CENTER", x = 0, y = -150},
						dpser = {a1 = "TOP", parent = "UIParent", a2 = "CENTER", x = 0, y = -150},
					}
				T.CreateDragFrame(cb)
				
				cb:SetStatusBarColor( .35, .65, 1, 1)
				cb.bd = T.createBackdrop(cb, cb, 1)
				cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -7, 0)
				cb.Spark:SetSize(8, aCoreCDB["UnitframeOptions"]["cbheight"]*2)
				
				cb.Time:ClearAllPoints()
				if aCoreCDB["UnitframeOptions"]["timepos"] == "CENTER" then
					cb.Time:SetPoint("BOTTOM", cb, "TOP", 0, 3)
				elseif aCoreCDB["UnitframeOptions"]["timepos"] == "LEFT" then
					cb.Time:SetPoint("BOTTOMLEFT", cb, "TOPLEFT", 0, 3)
					cb.Time:SetJustifyH("LEFT")
				elseif aCoreCDB["UnitframeOptions"]["timepos"] == "RIGHT" then
					cb.Time:SetPoint("BOTTOMRIGHT", cb, "TOPRIGHT", 0, 3)
					cb.Time:SetJustifyH("RIGHT")
				elseif aCoreCDB["UnitframeOptions"]["timepos"] == "BOTTOM" then
					cb.Time:SetPoint("TOP", cb, "BOTTOM", 0, -3)
				end
				
				cb.Text:ClearAllPoints()
				if aCoreCDB["UnitframeOptions"]["namepos"] == "CENTER" then
					cb.Text:SetPoint("BOTTOM", cb, "TOP", 0, 3)
				elseif aCoreCDB["UnitframeOptions"]["namepos"] == "LEFT" then
					cb.Text:SetPoint("BOTTOMLEFT", cb, "TOPLEFT", 0, 3)
					cb.Text:SetJustifyH("LEFT")
				elseif aCoreCDB["UnitframeOptions"]["namepos"] == "RIGHT" then
					cb.Text:SetPoint("BOTTOMRIGHT", cb, "TOPRIGHT", 0, 3)
					cb.Text:SetJustifyH("RIGHT")
				elseif aCoreCDB["UnitframeOptions"]["namepos"] == "BOTTOM" then
					cb.Text:SetPoint("TOP", cb, "BOTTOM", 0, -3)
				end
			end
        end
		
		cb.Ticks = {}
        cb.PostCastStart = PostCastStart
        cb.PostChannelStart = PostChannelStart
		cb.PostChannelUpdate = PostChannelUpdate
		cb.PostChannelStop = PostChannelStop
		
        self.Castbar = cb
    end
end

--=============================================--
--[[                   Auras                 ]]--
--=============================================--
local iconsize = (aCoreCDB["UnitframeOptions"]["width"]+3)/aCoreCDB["UnitframeOptions"]["auraperrow"]-3
local PostCreateIcon = function(auras, icon)
    icon.icon:SetTexCoord(.07, .93, .07, .93)

    icon.count:ClearAllPoints()
    icon.count:SetPoint("BOTTOMRIGHT", 0, -3)
    icon.count:SetFontObject(nil)
    icon.count:SetFont(G.numFont, iconsize*.65, "OUTLINE")
    icon.count:SetTextColor(.9, .9, .1)

	icon.overlay:SetTexture(G.media.blank)
	icon.overlay:SetDrawLayer("BACKGROUND")
    icon.overlay:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    icon.overlay:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

	icon.bd = T.createBackdrop(icon, icon, 0)

	icon.remaining =  T.createnumber(icon, "OVERLAY", iconsize*.55, "OUTLINE", "CENTER")
    icon.remaining:SetPoint("TOPLEFT", 0, 5)

    if aCoreCDB["UnitframeOptions"]["auraborders"] then
        auras.showDebuffType = true
	else
		auras.showDebuffType = false
	end
end

local CreateAuraTimer = function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed

    if self.elapsed < .2 then return end
    self.elapsed = 0

    local timeLeft = self.expires - GetTime()
    if timeLeft <= 0 then
        self.remaining:SetText(nil)
    else
        self.remaining:SetText(T.FormatTime(timeLeft))
    end
end

local whitelist = {
	["123059"] = true,  -- 动摇意志
}

local PostUpdateIcon = function(icons, unit, icon, index, offset)
	local name, _, _, _, _, duration, expirationTime, _, _, _, SpellID = UnitAura(unit, index, icon.filter)

	if icon.isPlayer or UnitIsFriend("player", unit) or not icon.isDebuff or aCoreCDB["UnitframeOptions"]["AuraFilterwhitelist"][tostring(SpellID)] or whitelist[tostring(SpellID)] then
		icon.icon:SetDesaturated(false)
		if duration and duration > 0 then
			icon.remaining:Show()
		else
			icon.remaining:Hide()
		end
		icon.count:Show()
	else
		icon.icon:SetDesaturated(true) -- grey other's debuff casted on enemy.
		icon.overlay:Hide()
		icon.remaining:Hide()
		icon.count:Hide()
	end
		
	if duration then
		icon.bd:Show() -- if the aura is not a gap icon show it"s bd
	end
		
	icon.expires = expirationTime
	icon:SetScript("OnUpdate", CreateAuraTimer)
end

local PostUpdateGapIcon = function(auras, unit, icon, visibleBuffs)
	icon.bd:Hide()
	icon.remaining:Hide()
end

local CustomFilter = function(icons, unit, icon, ...)
	local SpellID = select(11, ...)
	if icon.isPlayer then -- show all my auras
		return true
	elseif UnitIsFriend("player", unit) and (not aCoreCDB["UnitframeOptions"]["AuraFilterignoreBuff"] or icon.isDebuff) then
		return true
	elseif not UnitIsFriend("player", unit) and (not aCoreCDB["UnitframeOptions"]["AuraFilterignoreDebuff"] or not icon.isDebuff) then
		return true
	elseif aCoreCDB["UnitframeOptions"]["AuraFilterwhitelist"][tostring(SpellID)] then
		return true
	end
end

local BossAuraFilter = function(icons, unit, icon, ...)
	local SpellID = select(11, ...)
	if icon.isPlayer or not icon.isDebuff then -- show buff and my auras
		return true
	elseif whitelist[tostring(SpellID)] then
		return true
	end
end

blacklist ={
	["36032"] = true, -- Arcane Charge
	["134122"] = true, --Blue Beam
	["134123"] = true, --Red Beam
	["134124"] = true, --Yellow Beam
	["124275"] = true, --轻度醉拳
	["124274"] = true, --中度醉拳
	["124273"] = true, --重度醉拳
	--["80354"] = true, --时空错位
	--["124273"] = true, --心满意足
}

local PlayerDebuffFilter = function(icons, unit, icon, ...)
	local SpellID = select(11, ...)
	if blacklist[tostring(SpellID)] then
		return false
	else
		return true
	end
end

local CreateAuras = function(self, unit)
	local u = unit:match("[^%d]+")
    if multicheck(u, "target", "focus", "boss", "arena", "player", "pet") then
		local Auras = CreateFrame("Frame", nil, self)
		Auras:SetHeight(aCoreCDB["UnitframeOptions"]["height"]*2)
		Auras:SetWidth(aCoreCDB["UnitframeOptions"]["width"]-2)
		Auras.gap = true
		Auras.disableCooldown = true
		if G.myClass == "MAGE" then
			Auras.showStealableBuffs = true 
		end
		Auras.size = iconsize
		Auras.spacing = 3
		Auras.PostCreateIcon = PostCreateIcon
		Auras.PostUpdateIcon = PostUpdateIcon
		Auras.PostUpdateGapIcon = PostUpdateGapIcon
		
		if unit == "target" or unit == "focus" then
			Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 14)
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "UP"
			Auras.numDebuffs = aCoreCDB["UnitframeOptions"]["auraperrow"]
			Auras.numBuffs = aCoreCDB["UnitframeOptions"]["auraperrow"]
			if unit == "target" and (aCoreCDB["UnitframeOptions"]["AuraFilterignoreBuff"] or aCoreCDB["UnitframeOptions"]["AuraFilterignoreDebuff"]) then
				Auras.CustomFilter = CustomFilter
			end
		elseif aCoreCDB["UnitframeOptions"]["playerdebuffenable"] and unit == "player" then
			Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, aCoreCDB["UnitframeOptions"]["height"]*-(aCoreCDB["UnitframeOptions"]["hpheight"]-1)+8)
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "UP"
			Auras.numDebuffs = aCoreCDB["UnitframeOptions"]["playerdebuffnum"]
			Auras.numBuffs = 0
			Auras.size = (aCoreCDB["UnitframeOptions"]["width"]+3)/aCoreCDB["UnitframeOptions"]["playerdebuffnum"]-3
			Auras.CustomFilter = PlayerDebuffFilter
		elseif unit == "pet" then
			Auras:SetWidth(aCoreCDB["UnitframeOptions"]["widthpet"]-2)
			Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 5)
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "UP"
			Auras.numDebuffs = 5
			Auras.numBuffs = 0
		elseif u == "boss" then -- boss 1-5
			Auras:SetWidth(aCoreCDB["UnitframeOptions"]["widthboss"]-2)
			Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 14)
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "UP"	
			Auras.numDebuffs = 6
			Auras.numBuffs = 3
			Auras.CustomFilter = BossAuraFilter
		elseif u == "arena" then
			Auras:SetWidth(aCoreCDB["UnitframeOptions"]["widthboss"]-2)
			Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 14)
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "UP"
			Auras.numDebuffs = ceil(aCoreCDB["UnitframeOptions"]["widthboss"]/((aCoreCDB["UnitframeOptions"]["width"]+3)/aCoreCDB["UnitframeOptions"]["auraperrow"]-3))-1
			Auras.numBuffs = ceil(aCoreCDB["UnitframeOptions"]["widthboss"]/((aCoreCDB["UnitframeOptions"]["width"]+3)/aCoreCDB["UnitframeOptions"]["auraperrow"]-3))-1
		end
		self.Auras = Auras
	end
end

--=============================================--
--[[              Unit Frames                ]]--
--=============================================--

local func = function(self, unit)
	local u = unit:match("[^%d]+")
	
	T.OnMouseOver(self)
    self:RegisterForClicks"AnyUp"
	self.mouseovers = {}
	
	-- highlight --
	self.hl = self:CreateTexture(nil, "HIGHLIGHT")
    self.hl:SetAllPoints()
    self.hl:SetTexture(G.media.barhightlight)
    self.hl:SetVertexColor( 1, 1, 1, .3)
    self.hl:SetBlendMode("ADD")

	-- backdrop --
	self.bg = CreateFrame("Frame", nil, self)
	self.bg:SetFrameLevel(0)
	self.bg:SetAllPoints(self)
	self.bg.tex = self.bg:CreateTexture(nil, "BACKGROUND")
    self.bg.tex:SetAllPoints()
	if aCoreCDB["OtherOptions"]["style"] == 1 then
		self.bg.tex:SetTexture(G.media.blank)
		self.bg.tex:SetVertexColor(0, 0, 0, 0)	
	else
		self.bg.tex:SetTexture(G.media.ufbar)
		self.bg.tex:SetVertexColor(0, 0, 0)
	end
	
    -- height, width and scale --
	if multicheck(u, "targettarget", "focustarget", "pet") then
        self:SetSize(aCoreCDB["UnitframeOptions"]["widthpet"], aCoreCDB["UnitframeOptions"]["height"])
	elseif u == "boss" or u == "arena" then
		self:SetSize(aCoreCDB["UnitframeOptions"]["widthboss"], aCoreCDB["UnitframeOptions"]["height"])
	else
	    self:SetSize(aCoreCDB["UnitframeOptions"]["width"], aCoreCDB["UnitframeOptions"]["height"])
    end
    self:SetScale(aCoreCDB["UnitframeOptions"]["scale"])
	
	-- shadow border for health bar --
    self.backdrop = T.createBackdrop(self, self, 0) -- this also use for dispel border
	
	-- health bar --
    local hp = T.createStatusbar(self, "ARTWORK", nil, nil, 1, 1, 1, 1)
	hp:SetFrameLevel(2)
	hp:SetAllPoints(self)
    hp.frequentUpdates = true
	
	if aCoreCDB["OtherOptions"]["style"] == 1 then
		hp.bg:SetGradientAlpha("VERTICAL", .5, .5, .5, .5, 0, 0, 0,0)
	else
		hp.bg:SetGradientAlpha("VERTICAL", .2,.2,.2,.15,.25,.25,.25,.6)
	end
	
	-- health text --
	if not (unit == "targettarget" or unit == "focustarget" or unit == "pet") then
		hp.value =  T.createnumber(hp, "OVERLAY", aCoreCDB["UnitframeOptions"]["valuefontsize"], "OUTLINE", "RIGHT")
		hp.value:SetPoint("BOTTOMRIGHT", self, -4, -2)
	end
	
	-- little black line to make the health bar more clear
	hp.ind = hp:CreateTexture(nil, "OVERLAY", 1)
    hp.ind:SetTexture("Interface\\Buttons\\WHITE8x8")
	hp.ind:SetVertexColor(0, 0, 0)
	hp.ind:SetSize(1, self:GetHeight())
	if aCoreCDB["OtherOptions"]["style"] ~= 3 then
		hp.ind:SetPoint("RIGHT", hp:GetStatusBarTexture(), "LEFT", 0, 0)
	else
		hp.ind:SetPoint("LEFT", hp:GetStatusBarTexture(), "RIGHT", 0, 0)
	end
	
	-- reverse fill health --
	if aCoreCDB["OtherOptions"]["style"] ~= 3 then
		hp:SetReverseFill(true)
	end
	
    self.Health = hp
	self.Health.PostUpdate = T.Updatehealthbar
	tinsert(self.mouseovers, self.Health)
	
	-- portrait 只有样式1和样式2才有肖像
	if aCoreCDB["OtherOptions"]["style"] ~= 3 and aCoreCDB["UnitframeOptions"]["portrait"] and multicheck(u, "player", "target", "focus", "boss", "arena") then
		local Portrait = CreateFrame('PlayerModel', nil, self)
		Portrait:SetFrameLevel(1) -- blow hp
		Portrait:SetPoint("TOPLEFT", 1, 0)
		Portrait:SetPoint("BOTTOMRIGHT", -1, 1)
		Portrait:SetAlpha(aCoreCDB["UnitframeOptions"]["portraitalpha"])
		self.Portrait = Portrait
	end
	
	-- power bar --
    if not (unit == "targettarget" or unit == "focustarget") then
		local pp = T.createStatusbar(self, "ARTWORK", aCoreCDB["UnitframeOptions"]["height"]*-(aCoreCDB["UnitframeOptions"]["hpheight"]-1), nil, 1, 1, 1, 1)
		pp:SetFrameLevel(2)
		pp:SetPoint"LEFT"
		pp:SetPoint"RIGHT"
		pp:SetPoint("TOP", self, "BOTTOM", 0, -1)
		pp.frequentUpdates = true
		
		pp.bg:SetGradientAlpha("VERTICAL", .2,.2,.2,.15,.25,.25,.25,.6)

		-- backdrop for power bar --	
		pp.bd = T.createBackdrop(pp, pp, 1)
		
		-- power text --
		if not multicheck(u, "pet", "boss", "arena") then
			pp.value =  T.createnumber(pp, "OVERLAY", aCoreCDB["UnitframeOptions"]["valuefontsize"], "OUTLINE", "LEFT")
			pp.value:SetPoint("BOTTOMLEFT", self, 4, -2)
		end

		self.Power = pp
		self.Power.PostUpdate = T.Updatepowerbar
		tinsert(self.mouseovers, self.Power)
    end

	-- altpower bar --
    if multicheck(u, "player", "boss", "pet") then
		local altpp = T.createStatusbar(self, "ARTWORK", 5, nil, 1, 1, 0, 1)
		if unit == "pet" then
			altpp:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -5)
			altpp:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -5)
		else
			altpp:SetPoint("TOPLEFT", _G["oUF_AltzPlayer"].Power, "BOTTOMLEFT", 0, -5)
			altpp:SetPoint("TOPRIGHT", _G["oUF_AltzPlayer"].Power, "BOTTOMRIGHT", 0, -5)
		end
		
		altpp.bg:SetGradientAlpha("VERTICAL", .2,.2,.2,.15,.25,.25,.25,.6)
		altpp.bd = T.createBackdrop(altpp, altpp, 1)

		altpp.value =  T.createtext(altpp, "OVERLAY", 11, "OUTLINE", "CENTER")
		altpp.value:SetPoint"CENTER"

		self.AltPowerBar = altpp
		self.AltPowerBar.PostUpdate = PostAltUpdate
    end

	-- little thing around unit frames --
    local leader = hp:CreateTexture(nil, "OVERLAY")
    leader:SetSize(12, 12)
    leader:SetPoint("BOTTOMLEFT", hp, "BOTTOMLEFT", 5, -5)
    self.Leader = leader

	local assistant = hp:CreateTexture(nil, "OVERLAY")
    assistant:SetSize(12, 12)
    assistant:SetPoint("BOTTOMLEFT", hp, "BOTTOMLEFT", 5, -5)
	self.Assistant = assistant
	
    local masterlooter = hp:CreateTexture(nil, "OVERLAY")
    masterlooter:SetSize(12, 12)
    masterlooter:SetPoint("LEFT", leader, "RIGHT")
    self.MasterLooter = masterlooter
	
    local ricon = hp:CreateTexture(nil, "OVERLAY")
    ricon:SetPoint("CENTER", hp, "CENTER", 0, 0)
    ricon:SetSize(20, 20)
    self.RaidIcon = ricon
	
	-- name --
    local name =  T.createtext(self.Health, "OVERLAY", 13, "OUTLINE", "LEFT")
	name:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 3, 9)
    if unit == "player" or unit == "pet" then
        name:Hide()
	elseif multicheck(u, "targettarget", "focustarget", "boss", "arena") then
		if aCoreCDB["UnitframeOptions"]["nameclasscolormode"] then
			self:Tag(name, "[Altz:color][Altz:shortname]")
		else
			self:Tag(name, "[Altz:shortname]")
		end
    elseif aCoreCDB["UnitframeOptions"]["nameclasscolormode"] then
		self:Tag(name, "[difficulty][level][shortclassification]|r [Altz:color][name] [status]")
    else
		self:Tag(name, "[difficulty][level][shortclassification]|r [name] [status]")
    end
    self.Name = name
	
    if aCoreCDB["UnitframeOptions"]["castbars"] then
        CreateCastbars(self, unit)
    end
	
	if aCoreCDB["UnitframeOptions"]["auras"] then
		CreateAuras(self, unit)
	end
	
	self.FadeMinAlpha = aCoreCDB["UnitframeOptions"]["fadingalpha"]
	self.FadeInSmooth = 0.4
	self.FadeOutSmooth = 1.5
	self.FadeCasting = true
	self.FadeCombat = true
	self.FadeTarget = true
	self.FadeHealth = true
	self.FadePower = true
	self.FadeHover = true
end

local UnitSpecific = {

    --========================--
    --  Player
    --========================--
    player = function(self, ...)
        func(self, ...)
		
        -- Runes, Shards, HolyPower and so on --
        if multicheck(G.myClass, "DEATHKNIGHT", "WARLOCK", "PALADIN", "MONK", "SHAMAN", "PRIEST", "MAGE", "ROGUE", "DRUID") then
            local count
            if G.myClass == "DEATHKNIGHT" then 
                count = 6
			elseif G.myClass == "WARLOCK" then
				count = 4
            elseif G.myClass == "PALADIN" or G.myClass == "PRIEST" or G.myClass == "MONK" then
                count = 5
			elseif G.myClass == "SHAMAN" then
				count = 4
			elseif G.myClass == "MAGE" then
				count = 6
			elseif G.myClass == "ROGUE" or G.myClass == "DRUID" then
				count = 5 -- combopoints
            end

            local bars = CreateFrame("Frame", nil, self)
			bars:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)
            bars:SetSize(aCoreCDB["UnitframeOptions"]["width"], 10)

            for i = 1, count do
				if G.myClass == "PALADIN" then
					bars[i] = T.createStatusbar(bars, "ARTWORK", aCoreCDB["UnitframeOptions"]["height"]*-(aCoreCDB["UnitframeOptions"]["hpheight"]-1), (aCoreCDB["UnitframeOptions"]["width"]+2)/HOLY_POWER_FULL-3, 1, 1, 1, 1)
				elseif G.myClass == "PRIEST" then
					bars[i] = T.createStatusbar(bars, "ARTWORK", aCoreCDB["UnitframeOptions"]["height"]*-(aCoreCDB["UnitframeOptions"]["hpheight"]-1), (aCoreCDB["UnitframeOptions"]["width"]+2)/PRIEST_BAR_NUM_ORBS-3, 1, 1, 1, 1)
				elseif G.myClass == "MONK" then
					bars[i] = T.createStatusbar(bars, "ARTWORK", aCoreCDB["UnitframeOptions"]["height"]*-(aCoreCDB["UnitframeOptions"]["hpheight"]-1), (aCoreCDB["UnitframeOptions"]["width"]+2)/4-3, 1, 1, 1, 1)
				else
					bars[i] = T.createStatusbar(bars, "ARTWORK", aCoreCDB["UnitframeOptions"]["height"]*-(aCoreCDB["UnitframeOptions"]["hpheight"]-1), (aCoreCDB["UnitframeOptions"]["width"]+2)/count-3, 1, 1, 1, 1)
				end
				
                if i == 1 then
                    bars[i]:SetPoint("BOTTOMLEFT", bars, "BOTTOMLEFT")
                else
                    bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", 3, 0)
                end

				bars[i].bg:Hide()
                bars[i].bd = T.createBackdrop(bars[i], bars[i], 1)
            end

            if G.myClass == "DEATHKNIGHT" then
				if aCoreCDB["UnitframeOptions"]["runecooldown"] then
					for i = 1, 6 do
						bars[i].value = T.createtext(bars[i], "OVERLAY", aCoreCDB["UnitframeOptions"]["valuefs"], "OUTLINE", "CENTER")
						bars[i].bg:Show()
						bars[i].bg.multiplier = .3
						bars[i].bg:SetAlpha(.6)
						bars[i].value:SetPoint("CENTER")
					end
				end
                self.Runes = bars
				self.Runes.PostUpdateType = PostUpdateRunesType		
				self.Runes.PostUpdateRune = PostUpdateRunes
            elseif G.myClass == "WARLOCK" then
				if aCoreCDB["UnitframeOptions"]["demonicfuryvalue"] then
					bars.ShowValue = true
					bars.Valuefs = aCoreCDB["UnitframeOptions"]["valuefs"]
				end
                self.WarlockSpecBars = bars
            elseif G.myClass == "PALADIN" or G.myClass == "PRIEST" or G.myClass == "MONK" then
                self.ClassIcons = bars
				self.ClassIcons.UpdateTexture = function() end
				self.ClassIcons.PostUpdate = ClassIconsPostUpdate
			elseif G.myClass == "SHAMAN" then
				if aCoreCDB["UnitframeOptions"]["totemcooldown"] then
					bars.ShowValue = true
					bars.Valuefs = aCoreCDB["UnitframeOptions"]["valuefs"]
				end
				self.TotemBar = bars
			elseif G.myClass == "MAGE" then
				self.ArcaneCharge = bars
			elseif G.myClass == "ROGUE" or G.myClass == "DRUID" then
			    self.CPoints = bars
				self.CPoints.PostUpdate = CpointsPostUpdate
            end
        end
	
		-- eclipse bar --
        if G.myClass == "DRUID" then
            local ebar = CreateFrame("Frame", nil, self)
		    local Ewidth,Eheight
			Ewidth = aCoreCDB["UnitframeOptions"]["width"]
			Eheight = aCoreCDB["UnitframeOptions"]["height"]*-(aCoreCDB["UnitframeOptions"]["hpheight"]-1)
			
            ebar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 3)
			ebar:SetSize(Ewidth, Eheight)
            ebar.bd = T.createBackdrop(ebar, ebar, 1)

            local lbar = T.createStatusbar(ebar, "ARTWORK", Eheight, Ewidth, .2, .9, 1, 1)
			lbar:SetFrameLevel(ebar:GetFrameLevel())
			lbar.dir = lbar:CreateTexture(nil, "OVERLAY")
			lbar.dir:SetSize(Eheight+5, Eheight+5)
			lbar.dir:SetPoint("LEFT", lbar:GetStatusBarTexture(), "RIGHT", 5, 1)
			lbar.dir:SetTexture("Interface\\AddOns\\Aurora\\media\\arrow-right-active")
			lbar.dir:SetVertexColor(0, .4, 1)
			lbar.dir:Hide()
			lbar.bg:Hide()
            lbar:SetPoint("LEFT", ebar, "LEFT")
            ebar.LunarBar = lbar
			
            local sbar = T.createStatusbar(ebar, "ARTWORK", Eheight, Ewidth, 1, 1, 0.15, 1)
			sbar:SetFrameLevel(ebar:GetFrameLevel())
			sbar.dir = sbar:CreateTexture(nil, "OVERLAY")
			sbar.dir:SetSize(Eheight+5, Eheight+5)
			sbar.dir:SetPoint("RIGHT", sbar, "LEFT", -5, 1)
			sbar.dir:SetTexture("Interface\\AddOns\\Aurora\\media\\arrow-left-active")
			sbar.dir:SetVertexColor(1, .6, 0)
			sbar.dir:Hide()
			sbar.bg:Hide()
            sbar:SetPoint("LEFT", lbar:GetStatusBarTexture(), "RIGHT")
            ebar.SolarBar = sbar

            ebar.Spark = sbar:CreateTexture(nil, "OVERLAY")
			ebar.Spark:SetSize(1, Eheight)
            ebar.Spark:SetTexture(G.media.blank)
			ebar.Spark:SetVertexColor(0, 0, 0)
            ebar.Spark:SetPoint("CENTER", sbar:GetStatusBarTexture(), "LEFT", 0, 0)
			
			if aCoreCDB["UnitframeOptions"]["eclipsevalue"] then
				ebar.value = T.createtext(ebar, "OVERLAY", aCoreCDB["UnitframeOptions"]["valuefs"], "OUTLINE", "CENTER")
				ebar.value:SetPoint("CENTER")
			end
			
            self.EclipseBar = ebar
			self.EclipseBar.PostUnitAura = PostEclipseUpdateAura
			self.EclipseBar.PostDirectionChange = PostEclipseDirectionChange		
			self.EclipseBar.PostUpdatePower = PostEclipseUpdatePower
			self.EclipseBar.PostUpdateVisibility = PostEclipseUpdateVisibility		
        end
		
		-- Zzz
		local Resting = self.Power:CreateTexture(nil, 'OVERLAY')
		Resting:SetSize(18, 18)
		Resting:SetTexture(G.media.reseting)
		Resting:SetDesaturated(true)
		Resting:SetVertexColor( 0, 1, 0)
		Resting:SetPoint("RIGHT", self.Power, "RIGHT", -5, 0)
		self.Resting = Resting
		
		-- Combat
		local Combat = self.Power:CreateTexture(nil, "OVERLAY")
		Combat:SetSize(18, 18)
		Combat:SetTexture(G.media.combat)
		Combat:SetDesaturated(true)
		Combat:SetPoint("RIGHT", self.Power, "RIGHT", -5, 0)
		Combat:SetVertexColor( 1, 1, 0)
		self.Combat = Combat		
		self.Combat.PostUpdate = CombatPostUpdate
		
		-- PvP
		if aCoreCDB["UnitframeOptions"]["pvpicon"] then
			local PvP = self:CreateTexture(nil, 'OVERLAY')
			PvP:SetSize(35, 35)
			PvP:SetPoint("CENTER", self, "TOPRIGHT", 5, -5)
			self.PvP = PvP
		end
    end,

    --========================--
    --  Target
    --========================--
    target = function(self, ...)
        func(self, ...)
			-- threat bar --	
		if aCoreCDB["UnitframeOptions"]["showthreatbar"] then
			local threatbar = T.createStatusbar(UIParent, "ARTWORK", nil, nil, 0.25, 0.25, 0.25, 1)
			threatbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -3)
			threatbar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 0, -5)
			threatbar.bd = T.createBackdrop(threatbar, threatbar, 1)
			threatbar.bg:Hide()
			self.ThreatBar = threatbar
		end
    end,

    --========================--
    --  Focus
    --========================--
    focus = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Focus Target
    --========================--
    focustarget = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Pet
    --========================--
    pet = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Target Target
    --========================--
    targettarget = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Boss
    --========================--
    boss = function(self, ...)
        func(self, ...)
    end,
	
	--========================--
    --  Arena
    --========================--
    arena = function(self, ...)
        func(self, ...)
		
        if not self.prepFrame then
            self.prepFrame = CreateFrame("Frame", self:GetName().."PrepFrame", UIParent)
            self.prepFrame:SetFrameStrata("BACKGROUND")
            self.prepFrame:SetAllPoints(self)
			self.prepFrame.Health = T.createStatusbar(self.prepFrame, "MEDIUM", nil, nil, 1, 1, 1, 1)
			self.prepFrame.Health.bg:Hide()
			self.prepFrame.Health:SetAllPoints(self.prepFrame)
			self.prepFrame.Health.bd = T.createBackdrop(self.prepFrame.Health, self.prepFrame.Health, 0) 

			self.prepFrame.Icon = self.prepFrame:CreateTexture(nil, "OVERLAY")
			self.prepFrame.Icon:SetPoint("LEFT", self.prepFrame, "RIGHT", 5, 0)	
			self.prepFrame.Icon:SetSize(aCoreCDB["UnitframeOptions"]["height"], aCoreCDB["UnitframeOptions"]["height"])
            self.prepFrame.Icon:SetTexCoord(.08, .92, .08, .92)
			self.prepFrame.Icon.bd = T.createBackdrop(self.prepFrame, self.prepFrame.Icon, 0) 			

            self.prepFrame.SpecClass =  T.createtext(self.prepFrame.Health, "OVERLAY", 13, "OUTLINE", "CENTER")
            self.prepFrame.SpecClass:SetPoint("CENTER")
        end

        local specIcon = CreateFrame("Frame", nil, self)
		specIcon:SetSize(aCoreCDB["UnitframeOptions"]["height"], aCoreCDB["UnitframeOptions"]["height"])
		specIcon:SetPoint("LEFT", self, "RIGHT", 5, 0)
		specIcon.bd = T.createBackdrop(specIcon, specIcon, 0)
        self.PVPSpecIcon = specIcon

		local trinkets = CreateFrame("Frame", nil, self)
		trinkets:SetSize(aCoreCDB["UnitframeOptions"]["height"], aCoreCDB["UnitframeOptions"]["height"])
		trinkets:SetPoint("LEFT", specIcon, "RIGHT", 5, 0)
		trinkets.bd = T.createBackdrop(trinkets, trinkets, 0)
        trinkets.trinketUseAnnounce = true
        trinkets.trinketUpAnnounce = true
        self.Trinket = trinkets
    end,
}

local EventFrame = CreateFrame("Frame", nil, UIParent)
RegisterStateDriver(EventFrame, "visibility", "[petbattle] hide; show")

oUF:RegisterStyle("Altz", func)
for unit,layout in next, UnitSpecific do
    oUF:RegisterStyle("Altz - " .. unit:gsub("^%l", string.upper), layout)
end

local spawnHelper = function(self, unit)
    if(UnitSpecific[unit]) then
        self:SetActiveStyle("Altz - " .. unit:gsub("^%l", string.upper))
    elseif(UnitSpecific[unit:match("[^%d]+")]) then -- boss1 -> boss
        self:SetActiveStyle("Altz - " .. unit:match("[^%d]+"):gsub("^%l", string.upper))
    else
        self:SetActiveStyle"Altz"
    end

    local object = self:Spawn(unit)
	object:SetParent(EventFrame)
    return object
end

EventFrame:RegisterEvent("ADDON_LOADED")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

function EventFrame:ADDON_LOADED(arg1)
	if arg1 ~= "AltzUI" then return end
	
	oUF:Factory(function(self)
		local playerframe = spawnHelper(self, "player")
		playerframe.movingname = L["玩家头像"]
		playerframe.point = {
			healer = {a1 = "TOPRIGHT", parent = "UIParent", a2 = "BOTTOM", x = -180, y = 200},
			dpser = {a1 = "TOP", parent = "UIParent", a2 = "BOTTOM", x = 0, y = 180},
		}
		T.CreateDragFrame(playerframe)
		
		local petframe = spawnHelper(self, "pet")
		petframe.movingname = L["宠物头像"]
		petframe.point = {
			healer = {a1 = "RIGHT", parent = playerframe:GetName(), a2 = "LEFT", x = -10, y = 0},
			dpser = {a1 = "RIGHT", parent = playerframe:GetName(), a2 = "LEFT", x = -10, y = 0},
		}
		T.CreateDragFrame(petframe)
		
		local targetframe = spawnHelper(self, "target")
		targetframe.movingname = L["目标头像"]
		targetframe.point = {
			healer = {a1 = "TOPLEFT", parent = "UIParent", a2 = "BOTTOM", x = 180, y = 200},
			dpser = {a1 = "TOPLEFT", parent = "UIParent", a2 = "BOTTOM", x = 150, y = 250},
		}
		T.CreateDragFrame(targetframe)
	
		local totframe = spawnHelper(self, "targettarget")
		totframe.movingname = L["目标的目标头像"]
		totframe.point = {
			healer = {a1 = "LEFT", parent = targetframe:GetName(), a2 = "RIGHT" , x = 10, y = 0},
			dpser = {a1 = "LEFT", parent = targetframe:GetName(), a2 = "RIGHT" , x = 10, y = 0},
		}
		T.CreateDragFrame(totframe)
	
		local focusframe = spawnHelper(self, "focus")
		focusframe.movingname = L["焦点头像"]
		focusframe.point = {
			healer = {a1 = "BOTTOM", parent = targetframe:GetName(), a2 = "BOTTOM" , x = 0, y = 180},
			dpser = {a1 = "BOTTOM", parent = targetframe:GetName(), a2 = "BOTTOM" , x = 0, y = 180},
		}
		T.CreateDragFrame(focusframe)		
		
		local ftframe = spawnHelper(self, "focustarget")
		ftframe.movingname = L["焦点的目标头像"]
		ftframe.point = {
			healer = {a1 = "LEFT", parent = focusframe:GetName(), a2 = "RIGHT" , x = 10, y = 0},
			dpser = {a1 = "LEFT", parent = focusframe:GetName(), a2 = "RIGHT" , x = 10, y = 0},
		}
		T.CreateDragFrame(ftframe)
	
		local bossframes = {}
		if aCoreCDB["UnitframeOptions"]["bossframes"] then
			for i = 1, MAX_BOSS_FRAMES do
				bossframes["boss"..i] = spawnHelper(self,"boss" .. i)
			end
			for i = 1, MAX_BOSS_FRAMES do
				bossframes["boss"..i].movingname = L["首领头像"..i]
				if i == 1 then
					bossframes["boss"..i].point = {
						healer = {a1 = "TOPRIGHT", parent = "UIParent", a2 = "TOPRIGHT" , x =  -80, y = -300},
						dpser = {a1 = "TOPRIGHT", parent = "UIParent", a2 = "TOPRIGHT" , x =  -80, y = -300},
					}
				else
					bossframes["boss"..i].point = {
						healer = {a1 = "TOP", parent = bossframes["boss"..(i-1)]:GetName(), a2 = "BOTTOM" , x = 0, y = -40},
						dpser = {a1 = "TOP", parent = bossframes["boss"..(i-1)]:GetName(), a2 = "BOTTOM" , x = 0, y = -40},
					}
				end			
			end
			for i = 1, MAX_BOSS_FRAMES do
				T.CreateDragFrame(bossframes["boss"..i])
			end
		end
		
		local arenaframes = {}
		if aCoreCDB["UnitframeOptions"]["arenaframs"] then
			for i = 1, 5 do
				arenaframes["arena"..i] = spawnHelper(self,"arena"..i)
			end
			for i = 1, 5 do
				arenaframes["arena"..i].movingname = L["竞技场敌人头像"..i]
				if i == 1 then
					arenaframes["arena"..i].point = {
						healer = {a1 = "TOPRIGHT", parent = "UIParent", a2 = "TOPRIGHT" , x = -140, y = -340},
						dpser = {a1 = "TOPRIGHT", parent = "UIParent", a2 = "TOPRIGHT" , x = -140, y = -340},
					}
				else
					arenaframes["arena"..i].point = {
						healer = {a1 = "TOP", parent = arenaframes["arena"..(i-1)]:GetName(), a2 = "BOTTOM" , x = 0, y = -40},
						dpser = {a1 = "TOP", parent = arenaframes["arena"..(i-1)]:GetName(), a2 = "BOTTOM" , x = 0, y = -40},
					}
				end
				T.CreateDragFrame(arenaframes["arena"..i])				
			end
		end
	end)
	
	EventFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	EventFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
	EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function EventFrame:ARENA_OPPONENT_UPDATE()
	for i=1, 5 do
        if not _G["oUF_AltzArena"..i] then return end
        _G["oUF_AltzArena"..i].prepFrame:Hide()
    end
end

function EventFrame:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	UpdatePrep()
end

function EventFrame:PLAYER_ENTERING_WORLD()
	UpdatePrep()
end

PetCastingBarFrame:Hide()
PetCastingBarFrame:UnregisterAllEvents()