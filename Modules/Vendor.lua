local AddonName, ns = ...

local function buildBuyList()
	local list = {}

	local playerClass = select(2, UnitClass('player'))
	local playerLevel = UnitLevel('player')	
	local prof1, prof2 = GetProfessions()
	local profs = {prof1, prof2}

	list["Pandaren Treasure Noodle Soup"] = 5
	list["Deluxe Noodle Soup"] = 5
	list["Noodle Soup"] = 5
	-- Item Name = amount to uphold
	if (playerLevel > 85) then
		list["Tome of the Clear Mind"] = 40
	elseif (playerLevel > 80) then
		list["Dust of Disappearance"] = 20
	elseif (playerLevel <= 80) then
		list["Vanishing Powder"] = 20
	end

	for _,prof in ipairs(profs) do
		local profName = GetProfessionInfo(prof)
		if profName == "Engineering" then
			list["Tinker's Kit"] = 20
		elseif profName == "Enchanting" then
			list["Enchanting Vellum"] = 40
		elseif profName == "Alchemy" then
			list["Crystal Vial"] = 80
		elseif profName == "Leatherworking" then
			list["Eternium Thread"] = 20
		elseif profName == "Inscription" then
			list["Light Parchment"] = 100
		end
	end
	return list
end

local function SellAndRestock(event, ...)

	local AutoRepair = ns.Config.Vendor.AutoRepair
	local SellGreyCrap = ns.Config.Vendor.SellGreyCrap
	local BuyEssentials = ns.Config.Vendor.BuyEssentials
	ns.UnregisterEvent("GET_ITEM_INFO_RECEIVED", SellAndRestock)

	if IsModifierKeyDown() then	
		return
	else
		local cost = GetRepairAllCost()
		if(AutoRepair == true and CanMerchantRepair() and cost > 0) then
			if CanGuildBankRepair() and cost <= GetGuildBankMoney() and (cost <= GetGuildBankWithdrawMoney() or GetGuildBankWithdrawMoney() == -1) then
				RepairAllItems(1)
				ns.Print("Repair cost using guild funds: ".. GetCoinTextureString(cost))
			elseif cost <= GetMoney() then
				RepairAllItems()
				ns.Print("Repair cost: ".. GetCoinTextureString(cost))
			else
				ns.Print("Not enough money to repair")
			end
		end
	end
			
	if(SellGreyCrap == true) then
		local profit = 0
		local bag, slot 
		for bag = 0, 4 do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				local bText, iCount, bLocked, bQuality, bRead = GetContainerItemInfo(bag, slot)

				if link and (select (3, GetItemInfo(link))==0) then
					local iName, iLink, iRarity, iLvl, iMinLvl, iType, iSType, iStack, iEqLoc, iText, iPrice = GetItemInfo(link)
					UseContainerItem(bag, slot)
					profit = profit + ( iCount * iPrice )
				end
			end
		end
		if profit > 0 then
			ns.Print("Sold greys for: "..GetCoinTextureString(profit))
		end
	end

	if(BuyEssentials == true) then
		local list = buildBuyList()
		for  i=1,GetMerchantNumItems() do
			local item,_,price,batch,maxItems = GetMerchantItemInfo(i)
			if list[item] then
				local amount = list[item]
				local need = amount - GetItemCount(item)
				if not maxItems == -1 and need > maxItems then	--if not unlimited supply, and I need more than they have
					need = maxItems
				end
				if need > 0 then
					local itemStackCount = select(8, GetItemInfo(item))
					local stacks = 0

					if not itemStackCount then -- We have not seen the item yet
						if need > 5 then
							ns.RegisterEvent("GET_ITEM_INFO_RECEIVED ", SellAndRestock)
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
						ns.Print("Bought: "..item.." x"..need.." ("..GetCoinTextureString(price* (rest +(stacks*itemStackCount)))..")")
					end
				end
			end
	    end
	end
end

ns.RegisterEvent("MERCHANT_SHOW", SellAndRestock)