local AddonName, ns = ...
local ndt, npt, ndt2, npt2

local function ndt_OnClick(self)
	if not PVEFrame:IsVisible() then
		PVEFrame_ToggleFrame()
		if PVPUIFrame:IsVisible() then
			PVPUIFrame_ToggleFrame()
		end
	end
end

local function npt_OnClick(self)
	if not PVPUIFrame:IsVisible() then
		TogglePVPUI()
		if PVEFrame:IsVisible() then
			PVEFrame_ToggleFrame()
		end
	end
end

local function SetUp()
	if not PVPUIFrame then
		TogglePVPUI()
		TogglePVPUI()
	end
	ndt = CreateFrame("CheckButton", nil, PVEFrame, "SpellBookSkillLineTabTemplate")
	ndt:Show()
	ndt:SetPoint("TOPLEFT", PVEFrame, "TOPRIGHT", 0, -35)
	ndt:SetFrameStrata("LOW")
	ndt.tooltip = DUNGEONS_BUTTON
	ndt:SetNormalTexture("Interface\\ICONS\\Achievement_Dungeon_Outland_Dungeon_Hero")

	npt = CreateFrame("CheckButton", nil, ndt, "SpellBookSkillLineTabTemplate")
	npt:Show()
	npt:SetPoint("TOPLEFT", ndt, "BOTTOMLEFT", 0, -15)
	npt.tooltip = PVP
	npt:SetNormalTexture("Interface\\PVPFrame\\RandomPVPIcon")

	ndt:SetScript("OnClick", ndt_OnClick)
	npt:SetScript("OnClick", npt_OnClick)
	ndt:SetScript("OnShow", function()
		ndt:SetChecked(true)
		npt:SetChecked(false)
	end)

	ndt2 = CreateFrame("CheckButton", nil, PVPUIFrame, "SpellBookSkillLineTabTemplate")
	ndt2:Show()
	ndt2:SetPoint("TOPLEFT", PVPUIFrame, "TOPRIGHT", 0, -35)
	ndt2:SetFrameStrata("LOW")
	ndt2.tooltip = DUNGEONS_BUTTON
	ndt2:SetNormalTexture("Interface\\ICONS\\Achievement_Dungeon_Outland_Dungeon_Hero")

	npt2 = CreateFrame("CheckButton", nil, ndt2, "SpellBookSkillLineTabTemplate")
	npt2:Show()
	npt2:SetPoint("TOPLEFT", ndt2, "BOTTOMLEFT", 0, -15)
	npt2.tooltip = PVP
	npt2:SetNormalTexture("Interface\\PVPFrame\\RandomPVPIcon")
	
	ndt2:SetScript("OnClick", ndt_OnClick)
	npt2:SetScript("OnClick", npt_OnClick)
	ndt2:SetScript("OnShow", function()
		ndt2:SetChecked(false)
		npt2:SetChecked(true)
	end)
end

ns.RegisterEvent("PLAYER_ENTERING_WORLD", SetUp)