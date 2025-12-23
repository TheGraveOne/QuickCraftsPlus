--============================================================================
-- QuickCrafts: PigmentCalculator.lua
-- Handles pigment profit calculations
--============================================================================

local addonName, addon = ...

addon.PigmentCalculator = {}

addon.pigmentData = {}

--============================================================================
-- CALCULATION FUNCTIONS
--============================================================================

-- Calculate data for a single pigment
-- Returns a table with best dye, cheapest herb, all herb prices, costs, and profit
function addon.PigmentCalculator:CalculatePigment(pigment)
    local data = {
        pigment = pigment,
        herbPrices = {},        -- { [itemID] = { price, name } }
        cheapestHerb = nil,     -- { itemID, name, price }
        herbCost = pigment.herbCost or 10,
        totalCost = nil,        -- cheapestHerb.price * herbCost
        pigmentPrice = nil,     -- AH price of the pigment
        saleAfterCut = nil,     -- After 5% AH cut (for selling pigment)
        profit = nil,           -- Profit from selling pigment
        margin = nil,
        hasAnyHerbPrice = false,
        hasPigmentPrice = false,
        -- Dye data
        dyePrices = {},         -- { [itemID] = { price, name } }
        bestDye = nil,          -- { itemID, name, price }
        dyeSaleAfterCut = nil,  -- After 5% AH cut (for selling dye)
        dyeProfit = nil,        -- Profit from selling best dye
        dyeMargin = nil,
        hasAnyDyePrice = false,
    }
    
    -- Get prices for all herbs
    local cheapestPrice = nil
    local cheapestHerbID = nil
    local cheapestHerbName = nil
    
    for _, herb in ipairs(pigment.herbs) do
        local price = addon.PriceSource:GetPrice(herb.itemID)
        data.herbPrices[herb.itemID] = {
            price = price,
            name = herb.name,
        }
        
        if price then
            data.hasAnyHerbPrice = true
            if not cheapestPrice or price < cheapestPrice then
                cheapestPrice = price
                cheapestHerbID = herb.itemID
                cheapestHerbName = herb.name
            end
        end
    end
    
    -- Store cheapest herb info
    if cheapestPrice then
        data.cheapestHerb = {
            itemID = cheapestHerbID,
            name = cheapestHerbName,
            price = cheapestPrice,
        }
        data.totalCost = cheapestPrice * data.herbCost
    end
    
    -- Get pigment price
    data.pigmentPrice = addon.PriceSource:GetPrice(pigment.itemID)
    if data.pigmentPrice then
        data.hasPigmentPrice = true
        
        -- Calculate sale after AH cut
        local ahCut = addon:GetSetting("ahCut")
        if ahCut then
            data.saleAfterCut = math.floor(data.pigmentPrice * 0.95)
        else
            data.saleAfterCut = data.pigmentPrice
        end
    end
    
    -- Calculate pigment profit and margin
    if data.totalCost and data.saleAfterCut then
        data.profit = data.saleAfterCut - data.totalCost
        if data.totalCost > 0 then
            data.margin = (data.profit / data.totalCost) * 100
        end
    end
    
    -- Get dye prices and find the best one
    local dyeGroup = addon.Dyes and addon.Dyes[pigment.id]
    if dyeGroup and dyeGroup.dyes then
        local bestDyePrice = nil
        local bestDyeID = nil
        local bestDyeName = nil
        
        for _, dye in ipairs(dyeGroup.dyes) do
            if dye.itemID and dye.itemID > 0 then
                local price = addon.PriceSource:GetPrice(dye.itemID)
                data.dyePrices[dye.itemID] = {
                    price = price,
                    name = dye.name,
                }
                
                if price then
                    data.hasAnyDyePrice = true
                    if not bestDyePrice or price > bestDyePrice then
                        bestDyePrice = price
                        bestDyeID = dye.itemID
                        bestDyeName = dye.name
                    end
                end
            end
        end
        
        -- Store best dye info
        if bestDyePrice then
            data.bestDye = {
                itemID = bestDyeID,
                name = bestDyeName,
                price = bestDyePrice,
            }
            
            -- Calculate dye sale after AH cut
            local ahCut = addon:GetSetting("ahCut")
            if ahCut then
                data.dyeSaleAfterCut = math.floor(bestDyePrice * 0.95)
            else
                data.dyeSaleAfterCut = bestDyePrice
            end
            
            -- Calculate dye profit and margin (herbs -> pigment -> dye)
            if data.totalCost then
                data.dyeProfit = data.dyeSaleAfterCut - data.totalCost
                if data.totalCost > 0 then
                    data.dyeMargin = (data.dyeProfit / data.totalCost) * 100
                end
            end
        end
    end
    
    return data
end

-- Calculate data for all pigments
function addon.PigmentCalculator:CalculateAllPigments()
    for _, pigment in ipairs(addon.Pigments) do
        addon.pigmentData[pigment.id] = self:CalculatePigment(pigment)
    end
end

-- Get calculated data for a pigment
function addon.PigmentCalculator:GetPigmentData(pigmentID)
    return addon.pigmentData[pigmentID]
end

--============================================================================
-- ANALYSIS FUNCTIONS
--============================================================================

-- Get the most profitable pigment
function addon.PigmentCalculator:GetMostProfitable()
    local bestPigment = nil
    local bestProfit = nil
    
    for _, pigment in ipairs(addon.Pigments) do
        local data = addon.pigmentData[pigment.id]
        if data and data.profit then
            if not bestProfit or data.profit > bestProfit then
                bestProfit = data.profit
                bestPigment = pigment
            end
        end
    end
    
    return bestPigment, bestProfit
end

-- Get pigments sorted by profit (highest first)
function addon.PigmentCalculator:GetPigmentsByProfit()
    local sorted = {}
    
    for _, pigment in ipairs(addon.Pigments) do
        local data = addon.pigmentData[pigment.id]
        if data then
            table.insert(sorted, {
                pigment = pigment,
                data = data,
                profit = data.profit or -999999999
            })
        end
    end
    
    table.sort(sorted, function(a, b)
        return a.profit > b.profit
    end)
    
    return sorted
end
