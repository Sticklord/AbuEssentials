local AddonName, ns = ...

local nst, ngt, nst2, ngt2

local function NST_OnClick(self)
	if GuildFrame and GuildFrame:IsVisible() then
		ToggleFriendsFrame()
		ToggleGuildFrame()
	else
		self:SetChecked(true)
	end
end

local function NGT_OnClick(self)
	if FriendsFrame and FriendsFrame:IsVisible() then
		ToggleGuildFrame()
		ToggleFriendsFrame()
		GuildFrameTab2:Click()
	else
		self:SetChecked(true)
	end
end

local function CreateOtherButtons(event, ...)
	if (not ... == "Blizzard_GuildUI") or nst2 then return end
	nst2 = CreateFrame("CheckButton", nil, GuildFrame, "SpellBookSkillLineTabTemplate")
	nst2:Show()
	nst2:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 2, -45)
	nst2.tooltip = SOCIAL_LABEL
	nst2:SetNormalTexture("Interface\\ICONS\\INV_Scroll_03")
	
	ngt2 = CreateFrame("CheckButton", nil, nst2, "SpellBookSkillLineTabTemplate")
	ngt2:Show()
	ngt2.tooltip = GUILD
	ngt2:SetPoint("TOPLEFT", nst2, "BOTTOMLEFT", 0, -15)
	if GetGuildTabardFileNames() then
		ngt2:SetNormalTexture("Interface\\SpellBook\\GuildSpellbooktabBG")
		ngt2.TabardEmblem:Show()
		ngt2.TabardIconFrame:Show()
		SetLargeGuildTabardTextures("player", ngt2.TabardEmblem, ngt2:GetNormalTexture(), ngt2.TabardIconFrame)
	else
		ngt2:SetNormalTexture("Interface\\GuildFrame\\GuildLogo-NoLogo")
	end

	nst2:SetScript("OnClick", NST_OnClick)
	ngt2:SetScript("OnClick", NGT_OnClick)
	
	nst2:SetScript("OnShow", function()
		nst2:SetChecked(false)
		ngt2:SetChecked(true)
	end)
end

local function CreateButtons()
	nst = CreateFrame("CheckButton", nil, FriendsFrame, "SpellBookSkillLineTabTemplate")
	nst:Show()
	nst:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 2, -45)
	nst:SetFrameStrata("LOW")
	nst.tooltip = SOCIAL_LABEL
	nst:SetNormalTexture("Interface\\ICONS\\INV_Scroll_03")

	ngt = CreateFrame("CheckButton", nil, nst, "SpellBookSkillLineTabTemplate")
	ngt:Show()
	ngt:SetPoint("TOPLEFT", nst, "BOTTOMLEFT", 0, -15)
	ngt:SetFrameStrata("LOW")
	ngt.tooltip = GUILD
	if GetGuildTabardFileNames() then
		ngt:SetNormalTexture("Interface\\SpellBook\\GuildSpellbooktabBG")
		ngt.TabardEmblem:Show()
		ngt.TabardIconFrame:Show()
		SetLargeGuildTabardTextures("player", ngt.TabardEmblem, ngt:GetNormalTexture(), ngt.TabardIconFrame)
	else
		ngt:SetNormalTexture("Interface\\GuildFrame\\GuildLogo-NoLogo")
	end
	
	nst:SetScript("OnClick", NST_OnClick)
	ngt:SetScript("OnClick", NGT_OnClick)
	nst:SetScript("OnShow", function()
		nst:SetChecked(true)
		ngt:SetChecked(false)
	end)
	
	CreateButtons = nil
end

FriendsFrame:HookScript("OnShow", function()
	if CreateButtons then
		CreateButtons()
	end
end)

ns.RegisterEvent("ADDON_LOADED", CreateOtherButtons)