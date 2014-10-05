--[======================================================[
		Mail
			Adds a open all button in the mail
			and prints total cash recieved
--]======================================================]
local AddonName, ns = ...

local LOOTDELAY = 0.5
local MAX_LOOPS = 10
local cashCount, onlyCash, origInboxFrame_OnClick

local Mail = CreateFrame('Frame', "AbuMail", UIParent)
local button 
local DEBUG = false
local function PRINT(...)
	if DEBUG then
		print(...)
	end
end
local function breathe(self, elapsed)
	self.ticker = self.ticker + elapsed

	if (self.delay < self.ticker) then
		self.delay = 0
		self.ticker = 0
		self:ProcessMail()
	end
end

local function checkBagSize()
	local totalFree = 0
	for i=0, NUM_BAG_SLOTS do
		local numberOfFreeSlots = GetContainerNumFreeSlots(i)
		totalFree = totalFree + numberOfFreeSlots
	end
	return totalFree
end

function Mail:ProcessMail()
	if not InboxFrame:IsVisible() then return self:StopMail() end

	local _, _, _, _, money, CODAmount, _, numItems = GetInboxHeaderInfo(self.index)
	numItems = (not numItems) and 0 or numItems

	PRINT("------- Check Mail: #"..self.index.." ---------")
	if (money < 1) and (onlyCash or numItems == 0) or (CODAmount > 0) then
		self.index = self.index - 1
		PRINT("|  Nope, already looted, new mail: #"..self.index)
		_, _, _, _, money, CODAmount, _, numItems = GetInboxHeaderInfo(self.index)
		numItems = (not numItems) and 0 or numItems
	else
		PRINT("| Yep, this isnt looted")
	end

	if self.index <= 0 then 
		return self:StopMail() 
	end

	PRINT("| Money = "..money, "numitems: "..numItems,"CODAmount: ",CODAmount)

	if (money > 0) then
		PRINT("| NoItems, looting money: ", money)
		TakeInboxMoney(self.index)
		self.delay = LOOTDELAY
		if money and money > 0 then
			cashCount = cashCount + money
		end
	elseif (not onlyCash) and (numItems > 0) and (CODAmount <= 0) and (checkBagSize() > 0) then
		PRINT("| Looting MAIL",self.index,"items; ", numItems)
		TakeInboxItem(self.index)
		self.delay = LOOTDELAY
	end
	
	PRINT("------- End of mail #"..self.index.." ---------")
end

function Mail:StopMail(msg)
	self:SetScript('OnUpdate', nil)
	self:UnregisterEvent("UI_ERROR_MESSAGE")

	if origInboxFrame_OnClick then
		_G.InboxFrame_OnClick = origInboxFrame_OnClick
	end
	if msg then
		ns.Print(msg)
	end
	if cashCount > 0 then
		ns.Print('Earned '..GetCoinTextureString(cashCount)..' from mailbox.')
		cashCount = 0
	end
	button:Enable()
end

function Mail:GetMail(grabOnlyCash)
	if GetInboxNumItems() > 0 then
		self:RegisterEvent("UI_ERROR_MESSAGE")
		button:Disable()

		self.index = GetInboxNumItems()
		self.delay = 0
		self.ticker = 0

		onlyCash = grabOnlyCash
		self:RegisterEvent("UI_ERROR_MESSAGE")

		origInboxFrame_OnClick = InboxFrame_OnClick
		_G.InboxFrame_OnClick = function() end

		self:SetScript('OnUpdate', breathe)	
	end
end

function Mail:UI_ERROR_MESSAGE(event, arg1)
	if arg1 == ERR_INV_FULL then
		self:StopMail('Your bags are full!')
	end
end

local function Load(event, ...)
	local self = Mail
	cashCount = 0

	if not button then -- Create Grab All Button
		button = CreateFrame("Button", "AbuMail", InboxFrame, "UIPanelButtonTemplate")
		button:SetWidth(120)
		button:SetHeight(25)
		button:SetPoint("CENTER", InboxFrame, "TOP", -36, -399)
		button:SetText("Open All")
		button:RegisterEvent("MODIFIER_STATE_CHANGED")
		button:SetScript("OnEvent", function(self, event, key, state)
			if key ~= "LSHIFT" then return; end
			if state == 1 then
				self:SetText("Take Money")
			else
				self:SetText("Open All")
			end
		end)

		button:SetScript("OnClick", function() Mail:GetMail(IsShiftKeyDown()) end)
		button:SetFrameLevel(button:GetFrameLevel() + 1)
	end

	self:SetScript("OnEvent", function(self, event, ...) 
		if self[event] then 
			return self[event](self, event, ...) 
		end 
	end)
end

ns.RegisterEvent("PLAYER_LOGIN", Load)