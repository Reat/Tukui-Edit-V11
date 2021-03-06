if TukuiCF["Chat"].enable ~= true then return end

local TukuiChat = CreateFrame("Frame")
local OnEvent = function(self, event, ...) self[event](self, event, ...) end
TukuiChat:SetScript("OnEvent", OnEvent)

-----------------------------------------------------------------------
-- OVERWRITE GLOBAL FUNC & VAR FROM BLIZZARD
-----------------------------------------------------------------------

-- seconds to wait when chatframe fade, default is 2
CHAT_FRAME_FADE_OUT_TIME = 0

-- seconds to wait when tabs are not on mouseover, default is 1
CHAT_TAB_HIDE_DELAY = 0

-- alpha of the current tab, default in 3.3.5 are 1 for mouseover and 0.4 for nomouseover
CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 1

-- alpha of non-selected and non-alert tabs, defaut on mouseover is 0.6 and on nomouseover, 0.2
CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 1

-- alpha of alerts (example: whisper via another tab)
CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

-- disable minimize system because we don't use this shit at all on classic chat.
FCF_MinimizeFrame = TukuiDB.dummy

-----------------------------------------------------------------------
-- SETUP TUKUI CHATS
-----------------------------------------------------------------------

local _G = _G
local replace = string.gsub
local find = string.find

local replaceschan = {
	['Гильдия'] = '[Г]',
	['Группа'] = '[Гр]',
	['Рейд'] = '[Р]',
	['Лидер рейда'] = '[ЛР]',
	['Объявление рейду'] = '[ОР]',
	['Офицер'] = '[О]',
	['Поле боя'] = '[ПБ]',
	['Лидер поля боя'] = '[ЛПБ]', 
	['Guilde'] = '[G]',
	['Groupe'] = '[GR]',
	['Chef de raid'] = '[RL]',
	['Avertissement Raid'] = '[AR]',
	['Officier'] = '[O]',
	['Champs de bataille'] = '[CB]',
	['Chef de bataille'] = '[CDB]',
	['Guild'] = '[G]',
	['Party'] = '[P]',
	['Party Leader'] = '[PL]',
	['Dungeon Guide'] = '[DG]',
	['Raid'] = '[R]',
	['Raid Leader'] = '[RL]',
	['Raid Warning'] = '[RW]',
	['Officer'] = '[O]',
	['Battleground'] = '[B]',
	['Battleground Leader'] = '[BL]',
	['Gilde'] = '[G]',
	['Gruppe'] = '[Grp]',
	['Gruppenanführer'] = '[GrpL]',
	['Dungeonführer'] = '[DF]',
	['Schlachtzug'] = '[R]',
	['Schlachtzugsleiter'] = '[RL]',
	['Schlachtzugswarnung'] = '[RW]',
	['Offizier'] = '[O]',
	['Schlachtfeld'] = '[BG]',
	['Schlachtfeldleiter'] = '[BGL]',
	['Hermandad'] = '[H]',
	['Grupo'] = '[G]',
	['Líder del grupo'] = '[LG]',
	['Guía de mazmorra'] = '[GM]',
	['Banda'] = '[B]',
	['Líder de banda'] = '[LB]',
	['Aviso de banda'] = '[AB]',
	['Oficial'] = '[O]',
	['CampoDeBatalla'] = '[CB]',
	['Líder de batalla'] = '[LdB]',
	['(%d+)%. .-'] = '[%1]',
}

-- Hide friends micro button (added in 3.3.5)
FriendsMicroButton:SetScript("OnShow", FriendsMicroButton.Hide)
FriendsMicroButton:Hide()

GeneralDockManagerOverflowButton:SetScript("OnShow", GeneralDockManagerOverflowButton.Hide)
GeneralDockManagerOverflowButton:Hide()

-- set the chat style
local function SetChatStyle(frame)
	local id = frame:GetID()
	local chat = frame:GetName()

	-- yeah baby
	_G[chat]:SetClampRectInsets(0,0,0,0)
	
	-- Removes crap from the bottom of the chatbox so it can go to the bottom of the screen.
	_G[chat]:SetClampedToScreen(false)
	
	-- Stop the chat chat from fading out
	_G[chat]:SetFading(false)
	
	-- set strata to low
	_G[chat]:SetFrameStrata("LOW")
	
	-- move the chat edit box
	_G[chat.."EditBox"]:ClearAllPoints();
	_G[chat.."EditBox"]:SetPoint("TOPLEFT", TukuiDataLeft, TukuiDB.Scale(2), TukuiDB.Scale(-2))
	_G[chat.."EditBox"]:SetPoint("BOTTOMRIGHT", TukuiDataLeft, TukuiDB.Scale(-2), TukuiDB.Scale(2))
	_G[chat.."EditBox"]:SetFrameLevel(3)
	
	-- Hide textures
	for j = 1, #CHAT_FRAME_TEXTURES do
		_G[chat..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
	end

	-- Removes Default ChatFrame Tabs texture				
	TukuiDB.Kill(_G[format("ChatFrame%sTabLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabMiddle", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabRight", id)])

	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedMiddle", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedRight", id)])
	
	TukuiDB.Kill(_G[format("ChatFrame%sTabHighlightLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabHighlightMiddle", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabHighlightRight", id)])

	-- Killing off the new chat tab selected feature
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedMiddle", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sTabSelectedRight", id)])

	-- Kills off the new method of handling the Chat Frame scroll buttons as well as the resize button
	-- Note: This also needs to include the actual frame textures for the ButtonFrame onHover
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrameUpButton", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrameDownButton", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrameBottomButton", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrameMinimizeButton", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sButtonFrame", id)])
	TukuiDB.Kill(_G["ChatFrameMenuButton"])

	-- Kills off the retarded new circle around the editbox
	TukuiDB.Kill(_G[format("ChatFrame%sEditBoxFocusLeft", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sEditBoxFocusMid", id)])
	TukuiDB.Kill(_G[format("ChatFrame%sEditBoxFocusRight", id)])

	-- Kill off editbox artwork
	local a, b, c = select(6, _G[chat.."EditBox"]:GetRegions()); TukuiDB.Kill (a); TukuiDB.Kill (b); TukuiDB.Kill (c)
	
	-- Disable alt key usage
	_G[chat.."EditBox"]:SetAltArrowKeyMode(false)
	
	-- hide editbox on login
	_G[chat.."EditBox"]:Hide()
	
	-- script to hide editbox instead of fading editbox to 0.35 alpha via IM Style
	_G[chat.."EditBox"]:HookScript("OnEditFocusGained", function(self) self:Show() end)
	_G[chat.."EditBox"]:HookScript("OnEditFocusLost", function(self) self:Hide() end)
	
	-- hide edit box every time we click on a tab
	_G[chat.."Tab"]:HookScript("OnClick", function() _G[chat.."EditBox"]:Hide() end)
	
	-- no mouse over alpha
	_G[chat.."Tab"].noMouseAlpha = 1
	
	-- non-docked chat tabs is semi-transparent on login, need to set alpha to 0.
	if _G[chat.."Tab"].isDocked ~= 1 then
		_G[chat.."Tab"]:SetAlpha(1)
	end
	
	-- create our own texture for edit box
	TukuiChatchatEditBox = _G[chat.."EditBox"]
	local edit = CreateFrame("frame", "TukuiChatchatEditBoxBackground", TukuiChatchatEditBox)
	edit:SetHeight(1)
	edit:SetWidth(1)
	edit:ClearAllPoints()
	edit:SetAllPoints(TukuiDataLeft)
	edit:SetFrameStrata("HIGH")
	edit:SetFrameLevel(2)
	TukuiDB.SetTemplate(edit)
	
	local function colorize(r,g,b)
		edit:SetBackdropBorderColor(r, g, b)
	end
	
	-- update border color according where we talk
	hooksecurefunc("ChatEdit_UpdateHeader", function()
		local type = _G[chat.."EditBox"]:GetAttribute("chatType")
		if ( type == "CHANNEL" ) then
		local id = GetChannelName(_G[chat.."EditBox"]:GetAttribute("channelTarget"))
			if id == 0 then
				colorize(unpack(TukuiCF["Colors"].bordercolor))
			else
				colorize(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b)
			end
		else
			colorize(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b)
		end
	end)	
	
	-- change chat tab color
	hooksecurefunc("FCFTab_UpdateColors", function(chatTab, isSelected) 
		chatTab:GetFontString():SetTextColor(1, 1, 1)
		if ( chatTab.conversationIcon ) then
			chatTab.conversationIcon:SetVertexColor(1, 1, 1) -- changes color of the b.net whisper window icon.
		end
		if isSelected then 
			FCFTab_UpdateColors(chatTab, false) 
		end 
	end)
end

-- Setup chatframes 1 to 10 on login.
local function SetupChat(self, event, addon)
	if addon ~= "Tukui" then return end
	self:UnregisterEvent("ADDON_LOADED")
	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		SetChatStyle(frame)
		FCFTab_UpdateColors(_G["ChatFrame"..i.."Tab"], false) 
		_G["ChatFrame"..i.."TabText"]:SetFont(TukuiCF["Fonts"].font, 12)
		_G["ChatFrame"..i]:SetFont(TukuiCF["Fonts"].font, 12)
	end
	
	-- Remember last channel
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
	
	-- hide Blizzard Chat option that we don't need
	InterfaceOptionsSocialPanelWholeChatWindowClickable:Hide()
	InterfaceOptionsSocialPanelWholeChatWindowClickable:SetScript("OnShow", function(self) self:Hide() end) 
	InterfaceOptionsSocialPanelConversationMode:Hide()
end

local function SetupChatFontSize(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local id = chat:GetID()
		local _, fontSize = FCF_GetChatWindowInfo(id)
		local name = FCF_GetChatWindowInfo(id)
		local point = GetChatWindowSavedPosition(id)

		if fontSize < 12 then		
			FCF_SetChatWindowFontSize(nil, chat, 12)
		else
			FCF_SetChatWindowFontSize(nil, chat, fontSize)
		end
		
		-- set font align to right if a any chat is found at right of your screen.
		if TukuiCF["Chat"].justifyright then
			if i == 4 and name == "Trade / Loot" and point == "BOTTOMRIGHT" or point == "RIGHT" or point == "TOPRIGHT" then 
				chat:SetJustifyH("RIGHT") 
			end
		end
		
		-- force chat position on #1 and #4, needed if we change ui scale or resolution
		if i == 1 then
			chat:ClearAllPoints()
			chat:SetPoint("BOTTOMLEFT", TukuiDataLeft, "TOPLEFT", TukuiDB.Scale(3), TukuiDB.Scale(8))
			FCF_SavePositionAndDimensions(chat)
		elseif i == 4 and name == "Trade / Loot" then
			chat:ClearAllPoints()
			chat:SetPoint("BOTTOMRIGHT", TukuiDataRight, "TOPRIGHT", TukuiDB.Scale(-5), TukuiDB.Scale(8))
			FCF_SavePositionAndDimensions(chat)
		end
	end
end

TukuiChat:RegisterEvent("ADDON_LOADED")
TukuiChat:RegisterEvent("PLAYER_ENTERING_WORLD")
TukuiChat["ADDON_LOADED"] = SetupChat
TukuiChat["PLAYER_ENTERING_WORLD"] = SetupChatFontSize

-- Setup temp chat (BN, WHISPER) when needed.
local function SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
	SetChatStyle(frame)
end
hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

-- Get colors for player classes
local function ClassColors(class)
	if not class then return end
	class = (replace(class, " ", "")):upper()
	local c = RAID_CLASS_COLORS[class]
	if c then
		return string.format("%02x%02x%02x", c.r*255, c.g*255, c.b*255)
	end
end

-- For Player Logins
function CHAT_MSG_SYSTEM(...)
	local login = select(3, find(arg1, "^|Hplayer:(.+)|h%[(.+)%]|h has come online."))
	local classColor = "999999"
	local foundColor = true
	
	if login then
		local found = false
		if GetNumFriends() > 0 then ShowFriends() end
		
		for friendIndex = 1, GetNumFriends() do
			local friendName, _, class = GetFriendInfo(friendIndex)
			if friendName == login then
				classColor = ClassColors(class)
				found = true
				break
			end
		end
		
		if not found then
			if IsInGuild() then GuildRoster() end
			for guildIndex = 1, GetNumGuildMembers(true) do
				local guildMemberName, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(guildIndex)
				if guildMemberName == login then
					classColor = ClassColors(class)
					break
				end
			end
		end
		
	end
	
	if login then
		-- Hook the message function
		local AddMessageOriginal = ChatFrame1.AddMessage
		local function AddMessageHook(frame, text, ...)
			text = replace(text, "^|Hplayer:(.+)|h%[(.+)%]|h", "|Hplayer:%1|h|cff"..classColor.."%2|r|h")
			ChatFrame1.AddMessage = AddMessageOriginal
			return AddMessageOriginal(frame, text, ...)
		end
		ChatFrame1.AddMessage = AddMessageHook
	end
end
TukuiChat:RegisterEvent("CHAT_MSG_SYSTEM")
TukuiChat["CHAT_MSG_SYSTEM"] = CHAT_MSG_SYSTEM

local function AddMessageHook(frame, text, ...)
	-- chan text smaller or hidden
	for k,v in pairs(replaceschan) do
		text = text:gsub('|h%['..k..'%]|h', '|h'..v..'|h')
	end
	text = replace(text, "has come online.", "is now |cff298F00online|r !")
	text = replace(text, "has gone offline.", "is now |cffff0000offline|r !")
	text = replace(text, "ist jetzt online.", "ist jetzt |cff298F00online|r !")
	text = replace(text, "ist jetzt offline.", "ist jetzt |cffff0000offline|r !")
	text = replace(text, "|Hplayer:(.+)|h%[(.+)%]|h has earned", "|Hplayer:%1|h%2|h has earned")
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h whispers:", "From [|Hplayer:%1:%2|h%3|h]:")
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h says:", "[|Hplayer:%1:%2|h%3|h]:")	
	text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h yells:", "[|Hplayer:%1:%2|h%3|h]:")
	return AddMessageOriginal(frame, text, ...)
end

function TukuiDB.ChannelsEdits()
	for i = 1, NUM_CHAT_WINDOWS do
		if ( i ~= 2 ) then
			local frame = _G["ChatFrame"..i]
			AddMessageOriginal = frame.AddMessage
			frame.AddMessage = AddMessageHook
		end
	end
end
TukuiDB.ChannelsEdits()


-- /tt - tell your current target.
for i = 1, 10 do
	local editBox = _G["ChatFrame"..i.."EditBox"]
	editBox:HookScript("OnTextChanged", function(self)
	   local text = self:GetText()
	   if text:len() < 5 then
		  if text:sub(1, 4) == "/tt " then
			 local unitname, realm
			 unitname, realm = UnitName("target")
			 if unitname then unitname = gsub(unitname, " ", "") end
			 if unitname and not UnitIsSameServer("player", "target") then
				unitname = unitname .. "-" .. gsub(realm, " ", "")
			 end
			 ChatFrame_SendTell((unitname or tukuilocal.chat_invalidtarget), ChatFrame1)
		  end
	   end
	end)
end

-----------------------------------------------------------------------------
-- Copy URL
-----------------------------------------------------------------------------

local color = "BD0101"
local pattern = "[wWhH][wWtT][wWtT][\46pP]%S+[^%p%s]"

function string.color(text, color)
	return "|cff"..color..text.."|r"
end

function string.link(text, type, value, color)
	return "|H"..type..":"..tostring(value).."|h"..tostring(text):color(color or "ffffff").."|h"
end

StaticPopupDialogs["LINKME"] = {
	text = "URL COPY",
	button2 = CANCEL,
	hasEditBox = true,
    hasWideEditBox = true,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	whileDead = 1,
	maxLetters = 255,
}

local function f(url)
	return string.link("["..url.."]", "url", url, color)
end

local function hook(self, text, ...)
	self:f(text:gsub(pattern, f), ...)
end

function TukuiDB.LinkMeURL()
	for i = 1, NUM_CHAT_WINDOWS do
		if ( i ~= 2 ) then
			local frame = _G["ChatFrame"..i]
			frame.f = frame.AddMessage
			frame.AddMessage = hook
		end
	end
end
TukuiDB.LinkMeURL()

local f = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(self, link, text, button)
	local type, value = link:match("(%a+):(.+)")
	if ( type == "url" ) then
		local dialog = StaticPopup_Show("LINKME")
		local editbox = _G[dialog:GetName().."WideEditBox"]  
		editbox:SetText(value)
		editbox:SetFocus()
		editbox:HighlightText()
		local button = _G[dialog:GetName().."Button2"]
            
		button:ClearAllPoints()
           
		button:SetPoint("CENTER", editbox, "CENTER", 0, TukuiDB.Scale(-30))
	else
		f(self, link, text, button)
	end
end

------------------------------------------------------------------------
--	No more click on item chat link
------------------------------------------------------------------------

local orig1, orig2 = {}, {}
local GameTooltip = GameTooltip

local linktypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}

local function OnHyperlinkEnter(frame, link, ...)
	local linktype = link:match("^([^:]+)")
	if linktype and linktypes[linktype] then
		GameTooltip:SetOwner(frame, "ANCHOR_TOP", 0, 6)
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end

	if orig1[frame] then return orig1[frame](frame, link, ...) end
end

local function OnHyperlinkLeave(frame, ...)
	GameTooltip:Hide()
	if orig2[frame] then return orig2[frame](frame, ...) end
end

function TukuiDB.HyperlinkMouseover()
	local _G = getfenv(0)
	for i=1, NUM_CHAT_WINDOWS do
		if ( i ~= 2 ) then
			local frame = _G["ChatFrame"..i]
			orig1[frame] = frame:GetScript("OnHyperlinkEnter")
			frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)

			orig2[frame] = frame:GetScript("OnHyperlinkLeave")
			frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
		end
	end
end
TukuiDB.HyperlinkMouseover()

-----------------------------------------------------------------------------
-- Copy on chatframes feature
-----------------------------------------------------------------------------

local lines = {}
local frame = nil
local editBox = nil
local isf = nil

local function CreatCopyFrame()
	frame = CreateFrame("Frame", "CopyFrame", UIParent)
	TukuiDB.SkinFadedPanel(frame)
	if TukuiDB.lowversion == true then
		frame:SetWidth(TukuiDB.Scale(410))
	else
		frame:SetWidth(TukuiDB.Scale(710))
	end
	frame:SetHeight(TukuiDB.Scale(200))
	frame:SetScale(1)
	frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(10))
	frame:Hide()
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", TukuiDB.Scale(8), TukuiDB.Scale(-30))
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", TukuiDB.Scale(-30), TukuiDB.Scale(8))

	editBox = CreateFrame("EditBox", "CopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	if TukuiDB.lowversion == true then
		editBox:SetWidth(TukuiDB.Scale(410))
	else
		editBox:SetWidth(TukuiDB.Scale(710))
	end
	editBox:SetHeight(TukuiDB.Scale(200))
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)

	scrollArea:SetScrollChild(editBox)

	local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

	isf = true
end

local function GetLines(...)
	--[[		Grab all those lines		]]--
	local ct = 1
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			lines[ct] = tostring(region:GetText())
			ct = ct + 1
		end
	end
	return ct - 1
end

local function Copy(cf)
	local _, size = cf:GetFont()
	FCF_SetChatWindowFontSize(cf, cf, 0.01)
	local lineCt = GetLines(cf:GetRegions())
	local text = table.concat(lines, "\n", 1, lineCt)
	FCF_SetChatWindowFontSize(cf, cf, size)
	if not isf then CreatCopyFrame() end
	frame:Show()
	editBox:SetText(text)
	editBox:HighlightText(0)
end

function TukuiDB.ChatCopyButtons()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G[format("ChatFrame%d",  i)]
		local button = CreateFrame("Button", format("ButtonCF%d", i), cf)
		button:SetPoint("BOTTOMRIGHT", 0, 0)
		button:SetHeight(TukuiDB.Scale(20))
		button:SetWidth(TukuiDB.Scale(20))
		button:SetAlpha(0)
		TukuiDB.SetTemplate(button)
		button:SetScript("OnClick", function() Copy(cf) end)
		button:SetScript("OnEnter", function() 
			button:SetAlpha(1) 
		end)
		button:SetScript("OnLeave", function() button:SetAlpha(0) end)
		local tab = _G[format("ChatFrame%dTab", i)]
		tab:SetScript("OnShow", function() button:Show() end)
		tab:SetScript("OnHide", function() button:Hide() end)
	end
end
TukuiDB.ChatCopyButtons()


------------------------------------------------------------------------
--	Enhance/rewrite a Blizzard feature, chatframe mousewheel.
------------------------------------------------------------------------

local ScrollLines = 3 -- set the jump when a scroll is done !
function FloatingChatFrame_OnMouseScroll(self, delta)
	if delta < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			for i = 1, ScrollLines do
				self:ScrollDown()
			end
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			for i = 1, ScrollLines do
				self:ScrollUp()
			end
		end
	end
end
------------------------------------------------------------------------
--	Play sound files system
------------------------------------------------------------------------

-- local SoundSys = CreateFrame("Frame")
-- SoundSys:RegisterEvent("CHAT_MSG_WHISPER")
-- SoundSys:RegisterEvent("CHAT_MSG_BN_WHISPER")
-- SoundSys:HookScript("OnEvent", function(self, event, ...)
	-- if event == "CHAT_MSG_WHISPER" or "CHAT_MSG_BN_WHISPER" then
		-- PlaySoundFile(TukuiDB["media"].whisper)
	-- end
-- end)