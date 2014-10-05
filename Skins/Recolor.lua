	------------------------------------------------------------
--	Based on FacePaint by Aprikot
	------------------------------------------------------------
local AddonName, ns = ...

local color = ns.Config.Colors.Frame

local frames = {
	"CompactRaidGroup1BorderFrame",
	"CompactRaidGroup2BorderFrame",
	"CompactRaidGroup3BorderFrame",
	"CompactRaidGroup4BorderFrame",
	"CompactRaidGroup5BorderFrame",
	"CompactRaidGroup6BorderFrame",
	"CompactRaidGroup7BorderFrame",
	"CompactRaidGroup8BorderFrame",
	"CompactRaidFrameContainerBorderFrameBorderBottom",
	"CompactRaidFrameContainerBorderFrameBorderBottomLeft",
	"CompactRaidFrameContainerBorderFrameBorderBottomRight",
	"CompactRaidFrameContainerBorderFrameBorderLeft",
	"CompactRaidFrameContainerBorderFrameBorderRight",
	"CompactRaidFrameContainerBorderFrameBorderTop",
	"CompactRaidFrameContainerBorderFrameBorderTopLeft",
	"CompactRaidFrameContainerBorderFrameBorderTopRight",
	
	-- RaidFrameManaged
	"CompactRaidFrameManagerBg",
	"CompactRaidFrameManagerBorderBottom",
	"CompactRaidFrameManagerBorderBottomLeft",
	"CompactRaidFrameManagerBorderBottomRight",
	"CompactRaidFrameManagerBorderRight",
	"CompactRaidFrameManagerBorderTopLeft",
	"CompactRaidFrameManagerBorderTopRight",
	"CompactRaidFrameManagerBorderTop",
	
	-- Minimap
	"MiniMapBattlefieldBorder",
	"MiniMapLFGFrameBorder",
	"MinimapBackdrop",
	"MinimapBorder",
	"MiniMapMailBorder",
	"MiniMapTrackingButtonBorder",
	"MinimapBorderTop",
	"MinimapZoneTextButton",
	"MiniMapWorldMapButton",
	"MiniMapWorldIcon",
	"QueueStatusMinimapButtonBorder",

	-- Action bar
	"ReputationXPBarTexture0",
	"ReputationXPBarTexture1",
	"ReputationXPBarTexture2",
	"ReputationXPBarTexture3",
	"MainMenuBarTexture0",
	"MainMenuBarTexture1",
	"MainMenuBarTexture2",
	"MainMenuBarTexture3",
	"MainMenuXPBarTextureRightCap",
	"MainMenuXPBarTextureMid",
	"MainMenuXPBarTextureLeftCap",
	"MainMenuBarLeftEndCap",
	"MainMenuBarRightEndCap",

	"MainMenuMaxLevelBar0",
	"MainMenuMaxLevelBar1",
	"MainMenuMaxLevelBar2",
	"MainMenuMaxLevelBar3",
	"MainMenuBarMaxLevelBar",
	"MainMenuBarMaxLevelBarTexture0",
	"MainMenuBarMaxLevelBarTexture1",
	"MainMenuBarMaxLevelBarTexture2",
	"MainMenuBarMaxLevelBarTexture3",

	"ReputationWatchBarTexture0",
	"ReputationWatchBarTexture1",
	"ReputationWatchBarTexture2",
	"ReputationWatchBarTexture3",

	"MainMenuXPBarDiv1",
	"MainMenuXPBarDiv2",
	"MainMenuXPBarDiv3",
	"MainMenuXPBarDiv4",
	"MainMenuXPBarDiv5",
	"MainMenuXPBarDiv6",
	"MainMenuXPBarDiv7",
	"MainMenuXPBarDiv8",
	"MainMenuXPBarDiv9",
	"MainMenuXPBarDiv10",
	"MainMenuXPBarDiv11",
	"MainMenuXPBarDiv12",
	"MainMenuXPBarDiv13",
	"MainMenuXPBarDiv14",
	"MainMenuXPBarDiv15",
	"MainMenuXPBarDiv16",
	"MainMenuXPBarDiv17",
	"MainMenuXPBarDiv18",
	"MainMenuXPBarDiv19",
}

local function Paint(obj)
	if not obj or obj:GetObjectType() ~= "Texture" then
		return
	end
	obj:SetVertexColor(unpack(color))
end

ns.RegisterEvent("ADDON_LOADED", function(event, name)
	if name ~= AddonName then return end

	if not IsAddOnLoaded("Blizzard_TimeManager") then
		LoadAddOn("Blizzard_TimeManager")
	end

	Paint(GameTimeFrame:GetPushedTexture())
	Paint(GameTimeFrame:GetNormalTexture())

	Paint(CompactRaidFrameManagerToggleButton:GetRegions())
	Paint(TimeManagerClockButton:GetRegions())

	for _, name in pairs(frames) do
		Paint(_G[name])
	end
end)