--[======================================================[
		Mail
			Adds a open all button in the mail
			and prints total cash recieved
--]======================================================]
local _, ns = ...
if (not ns.Config.EnableMailModule) then return; end

local LOOTDELAY = 0.6
local MAX_LOOPS = 5
local onlyCash, origInboxFrame_OnClick

local Mail = CreateFrame('Frame', "AbuMail", UIParent)
local button

local bacon = {
	["The Postmaster"] = true,
}

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

local sameIndexCount, lastIndex = 0, 0
function Mail:ProcessMail()
	if not InboxFrame:IsVisible() then return self:StopMail() end

	local _, _, sender, subject, money, CODAmount, _, numItems, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(self.index)
	numItems = (not numItems) and 0 or numItems
	money = (not money) and 0 or money

	if (money <= 0) and (onlyCash or numItems == 0) or (CODAmount > 0) then
		if (money <= 0) and (numItems <= 0) and bacon[sender] then
			DeleteInboxItem(self.index)
			self.delay = LOOTDELAY
			return
		end

		self.index = self.index - 1
		_, _, sender, subject, money, CODAmount, _, numItems, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(self.index)
		numItems = (not numItems) and 0 or numItems
	elseif (sameIndexCount > MAX_LOOPS) then
		self.index = self.index - 1
		sameIndexCount = 0
	end
	if self.index <= 0 then 
		return self:StopMail() 
	end

	if (money > 0) then
		TakeInboxMoney(self.index)
		self.delay = LOOTDELAY
		if money and money > 0 and (self.lastMoneyLooted ~= self.index) then
			self.cashCount = self.cashCount + money
			self.lastMoneyLooted = self.index
		end
	elseif (not onlyCash) and (numItems > 0) and (CODAmount <= 0) and (checkBagSize() > 0) then

		AutoLootMailItem(self.index)
		self.delay = LOOTDELAY
	end

	if ( self.index == lastIndex ) then
		sameIndexCount = sameIndexCount + 1
	else
		sameIndexCount = 0
	end
	lastIndex = self.index
end

function Mail:StopMail(msg)
	self:SetScript('OnUpdate', nil)
	self:UnregisterEvent("UI_ERROR_MESSAGE")

	if origInboxFrame_OnClick then
		_G.InboxFrame_OnClick = origInboxFrame_OnClick
	end
	if msg then
		ns:Print(msg)
	end
	if self.cashCount > 0 then
		ns:Print('Earned '..GetCoinTextureString(self.cashCount)..' from mailbox.')
		self.cashCount = 0
	end
	local _, totalLeft = GetInboxNumItems()
	if (totalLeft == 0) then
		MiniMapMailFrame:Hide()
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
		self.lastMoneyLooted = -1

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
	Mail.cashCount = 0

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
				self.takeMoney = true
			else
				self:SetText("Open All")
				self.takeMoney = false
			end
		end)

		button:SetScript("OnClick", function(self) Mail:GetMail(self.takeMoney) end)
		button:SetFrameLevel(button:GetFrameLevel() + 1)
	end

	Mail:SetScript("OnEvent", function(self, event, ...) 
		if self[event] then 
			return self[event](self, event, ...) 
		end 
	end)
end

ns:RegisterEvent("PLAYER_LOGIN", Load)