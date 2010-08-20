local Unitframes  = TukuiCF["Unitframes"]

if not Unitframes.enable then return end

------------------------------------------------------------------------
--	Textures and Fonts
------------------------------------------------------------------------

local empath = TukuiCF["Textures"].empath
local font = TukuiCF["Fonts"].font

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	self.colors = TukuiDB.oUF_colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = TukuiDB.SpawnMenu
	self:SetAttribute('type2', 'menu')
	
	self.Backdrop = CreateFrame("Frame", nil, self)
	TukuiDB.CreateUFBackdrop(self.Backdrop, 1, 1, "TOPLEFT", 0, 0)
	self.Backdrop:SetPoint("TOPLEFT", -TukuiDB.mult, TukuiDB.mult)
	self.Backdrop:SetPoint("BOTTOMRIGHT", TukuiDB.mult, -TukuiDB.mult)

	self:SetAttribute('initial-height', TukuiDB.Scale(37))
	self:SetAttribute('initial-width', (TukuiCF["Panels"].infowidth / 5) - 2.5)
	
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", TukuiDB.mult, -TukuiDB.mult)
	health:SetPoint("TOPRIGHT", -TukuiDB.mult, TukuiDB.mult)
	health:SetHeight(30)
	health:SetStatusBarTexture(empath)

	local healthBg = health:CreateTexture(nil, "BORDER")
	healthBg:SetAllPoints()
	healthBg:SetTexture(empath)
	healthBg:SetVertexColor(.05, .05, .05)

	local healthBorder = CreateFrame("Frame", nil, health)
	TukuiDB.CreateUFBorder(healthBorder, 1, 1, "TOPLEFT", 0, 0)
	healthBorder:SetAllPoints()
	healthBorder:SetFrameLevel(20)
	
	local power = CreateFrame("StatusBar", nil, self)
	power:SetHeight(TukuiDB.Scale(4))
	power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
	power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
	power:SetStatusBarTexture(empath)

	local powerBg = power:CreateTexture(nil, "BORDER")
	powerBg:SetAllPoints()
	powerBg:SetTexture(empath)
	powerBg:SetVertexColor(.05, .05, .05)
	powerBg.multiplier = 0.3

	local powerBorder = CreateFrame("Frame", nil, power)
	TukuiDB.CreateUFBorder(powerBorder, 1, 1, "TOPLEFT", 0, 0)
	powerBorder:SetAllPoints()
	
	local name = TukuiDB.SetFontString(health, font, 12)
	name:SetPoint("CENTER", 0, TukuiDB.mult)
	
	local leader = TukuiDB.SetFontString(health, font, 12)
	leader:SetPoint("LEFT", TukuiDB.Scale(2), TukuiDB.mult)
	self:Tag(leader, '[Tukui:leader][Tukui:dps_dead]')--[Tukui:dps_afk]')
	
	local masterlooter = TukuiDB.SetFontString(health, font, 12)
	masterlooter:SetPoint("RIGHT", -TukuiDB.mult, TukuiDB.mult)
	self:Tag(masterlooter, '[Tukui:rmlooter]')
	
	if Unitframes.showsmooth then
		health.Smooth = true
		power.Smooth = true
	end
	if Unitframes.classcolor then
		health.colorReaction = true
		health.colorClass = true
		health.colorDisconnected = true
		healthBg.multiplier = 0.3
		
		power.colorPower = true

		self:Tag(name, '[Tukui:dps_name_offline]')
	else
		health.colorReaction = false
		health.colorClass = false
		health:SetStatusBarColor(.15, .15, .15)
		
		power.colorClass = true

		self:Tag(name, '[Tukui:getnamecolor][Tukui:dps_name_offline]')
	end
	
	self.Health = health
	self.Health.bg = healthBg
	self.Health.border = healthBorder
	
	self.Power = power
	self.Power.bg = powerBg
	self.Power.border = power.border

	self.Name = name
	
	if Unitframes.aggro then
		table.insert(self.__elements, TukuiDB.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', TukuiDB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', TukuiDB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', TukuiDB.UpdateThreat)
    end

	if Unitframes.showsymbols then
		RaidIcon = healthBorder:CreateTexture(nil, 'OVERLAY')
		RaidIcon:SetHeight(TukuiDB.Scale(13))
		RaidIcon:SetWidth(TukuiDB.Scale(13))
		RaidIcon:SetPoint("BOTTOM", self, "TOP", 0, -TukuiDB.Scale(4))
		self.RaidIcon = RaidIcon
	end
	
	local readyCheck = health:CreateTexture(nil, "OVERLA")
	readyCheck:SetAllPoints(health)
	readyCheck:SetTexture(empath)
	readyCheck:SetBlendMode("ADD")
	readyCheck:SetVertexColor(0, 0, 0, 0)
	self:RegisterEvent('READY_CHECK', TukuiDB.ReadyCheck)
	self:RegisterEvent('READY_CHECK_CONFIRM', TukuiDB.ReadyCheck)
	self:RegisterEvent('READY_CHECK_FINISHED', TukuiDB.ReadyCheck)
	self.readyCheck = readyCheck
	
	if Unitframes.debuffhighlight then
		local debuffHighlight = self.Backdrop:CreateTexture(nil, "OVERLAY")
		debuffHighlight:SetPoint("TOPLEFT", TukuiDB.mult, -TukuiDB.mult)
		debuffHighlight:SetPoint("BOTTOMRIGHT", -TukuiDB.mult, TukuiDB.mult)
		debuffHighlight:SetTexture(empath)
		debuffHighlight:SetBlendMode("DISABLE")
		debuffHighlight:SetVertexColor(0, 0, 0, 0)
		self.DebuffHighlight = debuffHighlight
		self.DebuffHighlightAlpha = 1
		self.DebuffHighlightFilter = Unitframes.debuff_filter
	end

	if Unitframes.showrange then
		local range = { insideAlpha = 1, outsideAlpha = Unitframes.ooralpha }
		self.Range = range
	end

	if Unitframes.aurawatch then
		TukuiDB.createAuraWatch(self,unit)
    end

	if Unitframes.healcomm then
		self.HealCommBar = CreateFrame('StatusBar', nil, health)
		self.HealCommBar:SetAllPoints()
		self.HealCommBar:SetStatusBarTexture(health:GetStatusBarTexture():GetTexture())
		self.HealCommBar:SetStatusBarColor(0, 1, 0, 0.50)
		self.HealCommBar:SetPoint('LEFT', health, 'LEFT')
		self.allowHealCommOverflow = Unitframes.showoverflow
	end

	-- NEED TO DO!
	-- LFD icons
	
	-- this is needed to be sure vehicle have good health/power color
	-- aswell to be sure the name is displayed/updated correctly
	self:RegisterEvent("UNIT_PET", TukuiDB.updateAllElements)
	
	return self
end

oUF:RegisterStyle("TukuiHealRaid", Shared)

oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealRaid")
	
	local raid = {}
	for i = 1, Unitframes.raidgroups do
		local raidgroup = self:SpawnHeader("oUF_TukuiHealRaid"..i, nil, "raid",
																	"groupFilter", tostring(i),
																	"showRaid", true, 
																	"xOffset", TukuiDB.Scale(3),
																	"point", "LEFT")
		table.insert(raid, raidgroup)
		if i == 1 then
			if Unitframes.healermode then 
				raidgroup:SetPoint("BOTTOM", TukuiDataBottom, "TOP", 0, TukuiDB.Scale(90))
			else
				raidgroup:SetPoint("BOTTOMLEFT", TukuiChatLeftTabs, "TOPLEFT", 0, TukuiDB.Scale(3))
			end
		else
			if Unitframes.healermode then 
				raidgroup:SetPoint("BOTTOM", raid[i-1], "TOP", 0, TukuiDB.Scale(3))
			else
				raidgroup:SetPoint("BOTTOMLEFT", raid[i-1], "TOPLEFT", 0, TukuiDB.Scale(3))
			end
		end
	end
end)

