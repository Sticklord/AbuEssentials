local name, ns = ...

------------------------------------------
-- Buying

local function buildBuyList()
	local list = {}

	local playerClass = select(2, UnitClass('player'))
	local playerLevel = UnitLevel('player')	
	local prof1, prof2 = GetProfessions()

	list["Pandaren Treasure Noodle Soup"] = 5
	list["Deluxe Noodle Soup"] = 5
	list["Noodle Soup"] = 5
	-- Item Name = amount to uphold
	if (playerLevel > 85) then
		list["Tome of the Clear Mind"] = 20
	elseif (playerLevel > 80) then
		list["Dust of Disappearance"] = 20
	elseif (playerLevel <= 80) then
		list["Vanishing Powder"] = 20
	end

	for _,prof in ipairs({prof1, prof2}) do
		local profName = GetProfessionInfo(prof)
		if profName == "Engineering" then
			list["Tinker's Kit"] = 5
		elseif profName == "Enchanting" then
			list["Enchanting Vellum"] = 100
		elseif profName == "Alchemy" then
			list["Crystal Vial"] = 200
		elseif profName == "Inscription" then
			list["Light Parchment"] = 100
		end
	end
	return list
end

local function restock()
	ns:UnregisterEvent("GET_ITEM_INFO_RECEIVED ", restock)

	local list = buildBuyList()
	for  i=1,GetMerchantNumItems() do
		local item,_,price,batch,maxItems = GetMerchantItemInfo(i)
		if list[item] then
			local amount = list[item]
			local need = amount - GetItemCount(item, true)
			if not maxItems == -1 and need > maxItems then	--if not unlimited supply, and I need more than they have
				need = maxItems
			end
			if need > 0 then
				local itemStackCount = select(8, GetItemInfo(item))
				local stacks = 0

				if not itemStackCount then -- We have not seen the item yet
					if need > 5 then
						ns:RegisterEvent("GET_ITEM_INFO_RECEIVED ", restock)
					end
					itemStackCount = 5    -- probably not more than 5
				end

				local rest = need

				if (itemStackCount < need) then
					stacks = math.floor(need / itemStackCount)
					rest = need % itemStackCount
				end

				if stacks > 0 then
					for j=1,stacks do
						BuyMerchantItem(i, itemStackCount)
					end
				end

				if rest > 0 then
					BuyMerchantItem(i, rest)
				end

				if (rest+stacks) > 0 and price > 0 then
					ns:Print("Bought "..item.." x"..need.." ("..GetCoinTextureString(price* (rest +(stacks*itemStackCount)))..")")
				end
			end
		end
    end
end

------------------------------------------
-- Repairs

local function repair()
	local cost = GetRepairAllCost()
	if(CanMerchantRepair() and cost > 0) then
		if CanGuildBankRepair() and cost <= GetGuildBankMoney() and (cost <= GetGuildBankWithdrawMoney() or GetGuildBankWithdrawMoney() == -1) then
			RepairAllItems(1)
			ns:Print("Repair cost using guild funds: ".. GetCoinTextureString(cost))
		elseif cost <= GetMoney() then
			RepairAllItems()
			ns:Print("Repair cost: ".. GetCoinTextureString(cost))
		else
			ns:Print("Not enough money to repair")
		end
	end
end

------------------------------------------
-- Selling

local sellCrap, updateSellCrapButton
do
	local tip, ITEM_BIND_ON_EQUIP = nil, ITEM_BIND_ON_EQUIP
	local function IsItemBOE(bag, slot)
		if not tip then
			tip = CreateFrame("GameTooltip")
			tip.left = {}
			for i = 1, 4 do
				local L,R = tip:CreateFontString(), tip:CreateFontString()
				L:SetFontObject(GameFontNormal)
				R:SetFontObject(GameFontNormal)
				tip:AddFontStrings(L,R)
				tip.left[i] = L
			end
		end
	    tip:SetOwner(UIParent,"ANCHOR_NONE")
	    tip:ClearLines()
	    tip:SetBagItem(bag, slot) -- Can see already soulbound items with this

	    local isBOE
	    for i = 3, 4 do
	    	if (tip.left[i]:GetText() == ITEM_BIND_ON_EQUIP) then
	    		tip:Hide()
				return true
			end
	    end
		tip:Hide()
		return false
	end

	local sellClass = {
		['Weapon'] = true,
		['Armor'] = true,
	}

	function sellCrap(sellLowlevelGreens)
		local profit, num = 0, 0
		local bag, slot 
		for bag = 0, 4 do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)

				if link then
					local _, count, _, _, _, _, _, _, noValue = GetContainerItemInfo(bag, slot)
					local _, _, quality, iLevel, _, class, _, _, _, _, vendorPrice = GetItemInfo(link)

					if noValue and (quality == 0) or
						(sellLowlevelGreens and sellClass[class] and quality <= 3 and iLevel < 500 and IsItemBOE(bag, slot))
					then
						UseContainerItem(bag, slot)
						num = num + count
						profit = profit + ( count * vendorPrice )
					end
				end
			end
		end
		if profit > 0 then
			ns:Print("Sold ".. num .." items for: "..GetCoinTextureString(profit))
		end
	end

	function updateSellCrapButton()
		local button = MerchantFrame.SellCrapButton

		for bag = 0, 4 do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link then
					local _, count = GetContainerItemInfo(bag, slot)
					local _, _, quality, iLevel, _, class, _, _, _, _, vendorPrice = GetItemInfo(link)

					if (quality == 0) or (sellClass[class] and quality <= 3 and iLevel < 500 and IsItemBOE(bag, slot))then
						button:Enable()
						button:GetNormalTexture():SetVertexColor(1,1,1,1)
						button:GetNormalTexture():SetDesaturated(false)
						return;
					end
				end
			end
		end
		button:Disable()
		button:GetNormalTexture():SetVertexColor(1,1,1,.6)
		button:GetNormalTexture():SetDesaturated(true)
	end
end

hooksecurefunc("MerchantFrame_Update", function() -- Also fires when an item is sold etc.
	local f = _G.MerchantFrame
	if (not f.SellCrapButton) then
		local txt = f.txt or f:CreateFontString(nil, nil, "GameFontHighlightSmall")
		txt:SetPoint("BOTTOMLEFT", 20, 63)
		txt:SetText('Sell')
		f.SellCrapText = txt

		local b = f.b or CreateFrame("Button", "MerchantSellCrapButton", f)
		b:SetSize(34,34)
		b:SetPoint("TOP", txt, "BOTTOM", 0, 0)
		b:SetPushedTexture[[Interface\PaperDollInfoFrame\UI-GearManager-Button-Pushed]]
		b:GetPushedTexture():SetTexCoord(6/64,1-6/64,0,1)
		b:SetNormalTexture[[Interface\PaperDollInfoFrame\UI-GearManager-Button]]
		b:GetNormalTexture():SetTexCoord(6/64,1-6/64,0,1)
		b:SetHighlightTexture[[Interface\Buttons\ButtonHilight-Square]]

		b:SetScript('OnEnter', function(self, motion)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText("Sell items of grey value and\nBoE's below 500 itemlevel.");
			GameTooltip:Show();
		end)
		b:SetScript("OnLeave", function(self, motion)
			GameTooltip_Hide()
		end)
		b:SetScript("OnClick", function(self, button, down)
			sellCrap(true);
			GameTooltip:Hide();
		end)
		f.SellCrapButton = b
	end

	if ( f.selectedTab == 1 ) then
		MerchantRepairText:SetPoint("CENTER", f, "BOTTOMLEFT", 108, 68)
		MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 122, 30)
		f.SellCrapText:Show()
		f.SellCrapButton:Show()
		updateSellCrapButton()
	else
		f.SellCrapText:Hide()
		f.SellCrapButton:Hide()
	end
end)

------------------------------------------
-- MAIN

ns:RegisterEvent("MERCHANT_SHOW", function(event, ...)
	if IsShiftKeyDown() then return; end

	if(ns.Config.Vendor.AutoRepair) then
		repair()
	end

	if(ns.Config.Vendor.SellGreyCrap) then
		sellCrap(IsAltKeyDown() and IsControlKeyDown())
	end

	if(ns.Config.Vendor.BuyEssentials) then
		restock()
	end
end)