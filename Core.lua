local name, ns = ...

_G['AbuGlobal'] = {
	GlobalConfig = ns.GlobalConfig,
	SetupFrameForSliding = ns.SetupFrameForSliding,
	UIFrameFadeIn = ns.UIFrameFadeIn,
	UIFrameFadeOut = ns.UIFrameFadeOut,
	CreateBorder = ns.CreateBorder,
}
---------------------------------------------------------------------------
--								COMMANDS								 --
---------------------------------------------------------------------------

--Reeeeeload
_G.SLASH_RELOADUI1 = '/rl'
SlashCmdList.RELOADUI = ReloadUI

--Stacked
_G.SLASH_FSTACK1 = '/fs'
SlashCmdList.FSTACK = function(msg) SlashCmdList.FRAMESTACK(msg) end

-- gm 
_G.SLASH_HELP1 = '/gm'
_G.SLASH_HELP2 = '/ticket'
SlashCmdList.HELP = ToggleHelpFrame

--ItemID
_G.SLASH_ITEMID1 = '/itemid'
SlashCmdList.ITEMID = function(msg) 
	local _, link = GetItemInfo(msg) 
	if link then 
		ChatFrame1:AddMessage(msg .. " has item ID: " .. link:match("item:(%d+):")) 
	end 
end
----------------------------------------
--Antiafk hihihi
local function UnAfk()
	local button = _G[StaticPopup_Visible("CAMP").."Button1"]
	if button then
		button:Click()
	end
end

_G.SLASH_UNAFK1 = '/antiafk'
local isUnAfk = false
SlashCmdList.UNAFK = function(msg)
	if (not isUnAfk) then
		ns:RegisterEvent("PLAYER_CAMPING", UnAfk)
		ns:Print("Anti AFK Mode: ON")
	else
		ns:UnregisterEvent("PLAYER_CAMPING", UnAfk)
		ns:Print("Anti AFK Mode: OFF")
	end
	isUnAfk = not isUnAfk
end

-----------------------------------
-- add delay to macros
_G.SLASH_IN1 = "/in"
_G.SLASH_IN2 = "/timer"

local box = _G.MacroEditBox

SlashCmdList.IN = function(input)
	local time, cmd = input:match'^([^%s]+)%s+(.*)$'
	time = tonumber(time)
	if (not time) or (not cmd) then return; end

	C_Timer.After(math.max(time, 0.01), function()
		box:GetScript("OnEvent")(box, "EXECUTE_CHAT_LINE", cmd)
	end)
end
