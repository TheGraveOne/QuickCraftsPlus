--============================================================================
-- QuickCrafts: Calculator.lua
-- Handles all profit calculations
--============================================================================

local addonName, addon = ...

--============================================================================
-- FORMATTING FUNCTIONS
--============================================================================

-- Format copper to gold string with colors (e.g., "125g 50s 25c")
function addon.Calculator:FormatGold(copper)
    if not copper or copper == 0 then 
        return "|cFF888888N/A|r" 
    end
    
    local negative = copper < 0
    copper = math.abs(copper)
    
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copperVal = math.floor(copper % 100)
    
    local str = ""
    if gold > 0 then
        str = string.format("|cFFFFD700%d|rg ", gold)
    end
    if silver > 0 or gold > 0 then
        str = str .. string.format("|cFFC0C0C0%d|rs ", silver)
    end
    str = str .. string.format("|cFFB87333%d|rc", copperVal)
    
    if negative then
        str = "|cFFFF0000-|r" .. str
    end
    
    return str
end

-- Format copper to compact gold string (e.g., "125.5g")
function addon.Calculator:FormatGoldCompact(copper)
    if not copper or copper == 0 then 
        return "N/A" 
    end
    local gold = copper / 10000
    return string.format("%.1fg", gold)
end

-- Format profit with color (green positive, red negative)
function addon.Calculator:FormatProfit(copper)
    if not copper then 
        return "|cFF888888N/A|r" 
    end
    if copper >= 0 then
        return "|cFF00FF00+" .. self:FormatGoldCompact(copper) .. "|r"
    else
        return "|cFFFF0000" .. self:FormatGoldCompact(copper) .. "|r"
    end
end

-- Format percentage with color
function addon.Calculator:FormatPercent(percent)
    if not percent then
        return ""
    end
    if percent >= 0 then
        return string.format("|cFF00FF00%.1f%%|r", percent)
    else
        return string.format("|cFFFF0000%.1f%%|r", percent)
    end
end

--============================================================================
-- CALCULATION FUNCTIONS
--============================================================================

-- Calculate profit data for a single recipe
-- Returns a table with all calculated values
function addon.Calculator:CalculateRecipe(recipe)
    local data = {
        recipe = recipe,
        materialCosts = {},
        totalMatCost = 0,
        productPrice = nil,
        effectiveCost = 0,
        saleAfterCut = 0,
        profit = nil,
        margin = nil,
        hasAllPrices = true,
    }
    
    -- Get material costs
    for _, mat in ipairs(recipe.materials) do
        local price = addon.PriceSource:GetPrice(mat.itemID)
        if price then
            local totalPrice = price * mat.amount
            data.materialCosts[mat.itemID] = {
                unitPrice = price,
                amount = mat.amount,
                totalPrice = totalPrice,
                name = mat.name,
            }
            data.totalMatCost = data.totalMatCost + totalPrice
        else
            data.hasAllPrices = false
            data.materialCosts[mat.itemID] = {
                unitPrice = nil,
                amount = mat.amount,
                totalPrice = nil,
                name = mat.name,
            }
        end
    end
    
    -- Get product price
    data.productPrice = addon.PriceSource:GetPrice(recipe.product.itemID)
    if not data.productPrice then
        data.hasAllPrices = false
    end
    
    -- Calculate effective cost (with mastery if applicable)
    data.effectiveCost = data.totalMatCost
    local hasMastery = addon:GetSetting("mastery")
    if hasMastery and recipe.isTransmute and data.totalMatCost > 0 then
        -- Transmute Mastery gives 20% more items on average
        -- So effective cost per item = totalCost / 1.2
        data.effectiveCost = math.floor(data.totalMatCost / 1.2)
    end
    
    -- Calculate sale price after AH cut
    if data.productPrice then
        local ahCut = addon:GetSetting("ahCut")
        if ahCut then
            data.saleAfterCut = math.floor(data.productPrice * 0.95)
        else
            data.saleAfterCut = data.productPrice
        end
    end
    
    -- Calculate profit and margin
    if data.hasAllPrices then
        data.profit = data.saleAfterCut - data.effectiveCost
        if data.effectiveCost > 0 then
            data.margin = (data.profit / data.effectiveCost) * 100
        end
    end
    
    return data
end

-- Calculate profit data for all recipes
-- Stores results in addon.calculatedData
function addon.Calculator:CalculateAllRecipes()
    for _, recipe in ipairs(addon.Recipes) do
        addon.calculatedData[recipe.id] = self:CalculateRecipe(recipe)
    end
end

-- Get calculated data for a recipe
function addon.Calculator:GetRecipeData(recipeID)
    return addon.calculatedData[recipeID]
end

--============================================================================
-- ANALYSIS FUNCTIONS
--============================================================================

-- Get the most profitable recipe
function addon.Calculator:GetMostProfitable()
    local bestRecipe = nil
    local bestProfit = nil
    
    for _, recipe in ipairs(addon.Recipes) do
        local data = addon.calculatedData[recipe.id]
        if data and data.profit then
            if not bestProfit or data.profit > bestProfit then
                bestProfit = data.profit
                bestRecipe = recipe
            end
        end
    end
    
    return bestRecipe, bestProfit
end

-- Get recipes sorted by profit (highest first)
function addon.Calculator:GetRecipesByProfit()
    local sorted = {}
    
    for _, recipe in ipairs(addon.Recipes) do
        local data = addon.calculatedData[recipe.id]
        if data then
            table.insert(sorted, {
                recipe = recipe,
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
