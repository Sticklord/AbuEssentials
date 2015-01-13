local name, ns = ...

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
			list["Crystal Vial"] = 100
		elseif profName == "Inscription" then
			list["Light Parchment"] = 100
		end
	end
	return list
end

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

local function SellAndRestock(event, ...)

	ns:UnregisterEvent("GET_ITEM_INFO_RECEIVED", SellAndRestock)

	if IsShiftKeyDown() then	
		return
	else
		local cost = GetRepairAllCost()
		if(ns.Config.Vendor.AutoRepair and CanMerchantRepair() and cost > 0) then
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

	local sellBloodySalvageShitGear = IsAltKeyDown() and IsControlKeyDown()
	local sellClass = {
		['Weapon'] = true,
		['Armor'] = true,
	}
			
	if(ns.Config.Vendor.SellGreyCrap) then
		local profit, num = 0, 0
		local bag, slot 
		for bag = 0, 4 do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)

				if link then
					local _, count = GetContainerItemInfo(bag, slot)
					local _, _, quality, iLevel, _, class, _, _, _, _, vendorPrice = GetItemInfo(link)

					if (quality == 0) or
						(sellBloodySalvageShitGear and sellClass[class] and quality <= 3 and iLevel < 500 and IsItemBOE(bag, slot))
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

	if(ns.Config.Vendor.BuyEssentials) then
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
							ns:RegisterEvent("GET_ITEM_INFO_RECEIVED ", SellAndRestock)
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
end

ns:RegisterEvent("MERCHANT_SHOW", SellAndRestock)