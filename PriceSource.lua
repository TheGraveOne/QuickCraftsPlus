--============================================================================
-- QuickCrafts: PriceSource.lua
-- Handles fetching prices from Auctionator (or other addons in the future)
--============================================================================

local addonName, addon = ...

--============================================================================
-- PRICE SOURCE DETECTION
--============================================================================

-- Check if Auctionator is available
function addon.PriceSource:IsAvailable()
    -- Check Auctionator API
    if Auctionator and Auctionator.API and Auctionator.API.v1 then
        return true, "Auctionator"
    end
    
    return false, nil
end

-- Get the name of the current price source
function addon.PriceSource:GetSourceName()
    local available, name = self:IsAvailable()
    return name or "None"
end

--============================================================================
-- PRICE FETCHING
--============================================================================

-- Get the auction price for an item by ID
-- Returns: price in copper, or nil if not available
function addon.PriceSource:GetPrice(itemID)
    local itemLink = addon.itemLinks[itemID]
    if not itemLink then
        local name, link = C_Item.GetItemInfo(itemID)
        if link then
            addon.itemLinks[itemID] = link
            itemLink = link
        else
            return nil
        end
    end
    
    -- Try Auctionator API
    if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.GetAuctionPriceByItemLink then
        local success, price = pcall(function()
            return Auctionator.API.v1.GetAuctionPriceByItemLink(addonName, itemLink)
        end)
        if success and price then
            return price
        end
    end
    
    -- Fallback: try by item name
    local itemName = addon.itemNames[itemID] or C_Item.GetItemInfo(itemID)
    if itemName then
        addon.itemNames[itemID] = itemName
        
        if Atr_GetAuctionBuyout then
            return Atr_GetAuctionBuyout(itemName)
        end
        
        if Atr_GetAuctionPrice then
            return Atr_GetAuctionPrice(itemName)
        end
    end
    
    return nil
end

-- Get prices for multiple items at once
-- Returns: table of { [itemID] = price }
function addon.PriceSource:GetPrices(itemIDs)
    local prices = {}
    for _, itemID in ipairs(itemIDs) do
        prices[itemID] = self:GetPrice(itemID)
    end
    return prices
end

--============================================================================
-- AUCTIONATOR SEARCH FUNCTIONS
--============================================================================

-- Check if the Auction House is currently open
function addon.PriceSource:IsAuctionHouseOpen()
    if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
        return true
    end
    return false
end

-- Check if Auctionator search API is available
function addon.PriceSource:CanSearch()
    if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.MultiSearchExact then
        return true
    end
    return false
end

-- Search the Auction House for a recipe's materials and product
-- Returns: true if search started, false if failed
function addon.PriceSource:SearchRecipe(recipe)
    -- Check if AH is open
    if not self:IsAuctionHouseOpen() then
        return false, "Auction House must be open to search"
    end
    
    -- Check if search API is available
    if not self:CanSearch() then
        return false, "Auctionator search API not available"
    end
    
    -- Build list of item names to search
    local searchTerms = {}
    
    -- Add all materials
    for _, mat in ipairs(recipe.materials) do
        local itemName = addon.itemNames[mat.itemID]
        if itemName then
            table.insert(searchTerms, itemName)
        end
    end
    
    -- Add the product
    local productName = addon.itemNames[recipe.product.itemID]
    if productName then
        table.insert(searchTerms, productName)
    end
    
    -- Make sure we have items to search
    if #searchTerms == 0 then
        return false, "No item names loaded yet - try again"
    end
    
    -- Perform the search using Auctionator API
    if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.MultiSearchExact then
        local success, err = pcall(function()
            Auctionator.API.v1.MultiSearchExact(addonName, searchTerms)
        end)
        if success then
            return true, nil
        else
            return false, "Search failed: " .. tostring(err)
        end
    end
    
    return false, "No search method available"
end

-- Search for a single item by ID
function addon.PriceSource:SearchItem(itemID)
    if not self:IsAuctionHouseOpen() then
        return false, "Auction House must be open to search"
    end
    
    local itemName = addon.itemNames[itemID]
    if not itemName then
        return false, "Item name not loaded"
    end
    
    if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.MultiSearchExact then
        local success, err = pcall(function()
            Auctionator.API.v1.MultiSearchExact(addonName, {itemName})
        end)
        if success then
            return true, nil
        else
            return false, "Search failed: " .. tostring(err)
        end
    end
    
    return false, "Search API not available"
end

--============================================================================
-- ITEM DATA LOADING
--============================================================================

-- Load item info (name, link, icon) for an item ID
function addon.PriceSource:LoadItemInfo(itemID, callback)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local itemName, itemLink, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(itemID)
        addon.itemLinks[itemID] = itemLink
        addon.itemNames[itemID] = itemName
        addon.itemIcons[itemID] = itemIcon
        
        if callback then
            callback(itemID, itemName, itemLink, itemIcon)
        end
    end)
end

-- Load item info for all items in recipes
function addon.PriceSource:LoadAllItemInfo(callback)
    local itemIDs = addon:GetAllItemIDs()
    local loadedCount = 0
    local totalCount = 0
    
    -- Count total items
    for _ in pairs(itemIDs) do
        totalCount = totalCount + 1
    end
    
    -- Load each item
    for itemID in pairs(itemIDs) do
        self:LoadItemInfo(itemID, function()
            loadedCount = loadedCount + 1
            if loadedCount >= totalCount and callback then
                callback()
            end
        end)
    end
end

--============================================================================
-- AUCTIONATOR DATABASE UPDATE CALLBACK
--============================================================================

-- Register for Auctionator price database updates
-- Fires after searches complete and prices are updated
function addon.PriceSource:RegisterForPriceUpdates()
    if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.RegisterForDBUpdate then
        local success, err = pcall(function()
            Auctionator.API.v1.RegisterForDBUpdate(addonName, function()
                -- Recalculate all recipes with new prices
                addon.Calculator:CalculateAllRecipes()
                
                -- Recalculate all pigments with new prices
                if addon.PigmentCalculator and addon.PigmentCalculator.CalculateAllPigments then
                    addon.PigmentCalculator:CalculateAllPigments()
                end
                
                -- Refresh the UI if it's open
                if addon.UI and addon.UI.MainFrame and addon.UI.MainFrame:IsShown() then
                    if addon.UI.UpdateAll then
                        addon.UI.UpdateAll()
                    end
                end
            end)
        end)
        if success then
            return true
        end
    end
    return false
end

--============================================================================
-- UTILITY FUNCTIONS
--============================================================================

-- Get item icon texture path
function addon.PriceSource:GetItemIcon(itemID)
    return addon.itemIcons[itemID] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Get item name
function addon.PriceSource:GetItemName(itemID)
    return addon.itemNames[itemID] or "Unknown Item"
end

-- Get item link
function addon.PriceSource:GetItemLink(itemID)
    return addon.itemLinks[itemID]
end

-- Get item display text (removs brackets)
function addon.PriceSource:GetItemDisplayText(itemID, fallbackName)
    local link = addon.itemLinks[itemID]
    if link then
        local displayLink = link:gsub("%[(.-)%]", "%1")
        return displayLink
    end
    -- Fallback to name with white color
    local name = addon.itemNames[itemID] or fallbackName or "Unknown Item"
    return "|cFFFFFFFF" .. name .. "|r"
end
