local AddonName, ns = ...

if (not ns.Config.PopBubbles) then return; end

local 	select, pairs, GetCVarBool = 
		select, pairs, GetCVarBool

local function isBubble(frame)
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	local region = frame:GetRegions()
	return region:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]
end

local function popBubble(frame, ...)
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			local f, s = region:GetFont()
			region:SetFont(f, s, 'OUTLINE')
		end
	end
	frame:SetBackdrop(nil)
	frame:SetClampedToScreen(false)
	frame.isBubblePopped = true

	if (...) then 
		popBubble(...)
	end
end

local function hookBubbles(...)
	for i = 1, select('#', ...) do
		local frame = select(i, ...)
		if isBubble(frame) and not frame.isBubblePopped then
			popBubble(frame)
		end
	end
end

do
	local events = {
		CHAT_MSG_SAY = "chatBubbles", 
		CHAT_MSG_YELL = "chatBubbles",
		CHAT_MSG_PARTY = "chatBubblesParty", 
		CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
		CHAT_MSG_MONSTER_SAY = "chatBubbles", 
		CHAT_MSG_MONSTER_YELL = "chatBubbles", 
		CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
	}

	local numChildren = -1
	local WorldFrame = WorldFrame
	local f = CreateFrame('Frame')
	f:Hide()
	
	f:SetScript('OnEvent', function(self, event)
		if GetCVarBool(events[event]) then
			local count = WorldFrame:GetNumChildren()
			if(count ~= numChildren) then
				numChildren = count
				self.elapsed = 0
				if not self:IsShown() then
					self:Show()
				end
			end
		end
	end)

	for k, v in pairs(events) do
		f:RegisterEvent(k)
	end
	
	f:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < 0.1 then return; end
		self:Hide()
		hookBubbles(WorldFrame:GetChildren())
	end)
end