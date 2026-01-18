--============================================================================
-- QuickCrafts: UI/TransmutesView.lua
-- TransmutesView view - shows all recipes with quick profit info
--============================================================================

local addonName, addon = ...
local L = addon.L
local TEXT = addon.CONST.TEXT

local MainFrame = addon.UI.MainFrame


local TransmutesFrame = CreateFrame("Frame", nil, MainFrame)
TransmutesFrame:SetAllPoints()
addon.UI.TransmutesFrame = TransmutesFrame

--============================================================================
-- OPTIONS ROW (checkboxes and refresh button)
--============================================================================

local optionsFrame = CreateFrame("Frame", nil, TransmutesFrame)
optionsFrame:SetSize(490, 30)
optionsFrame:SetPoint("TOP", 0, -25)

local ahCutCheck = CreateFrame("CheckButton", "QuickCraftsAHCut", optionsFrame, "UICheckButtonTemplate")
ahCutCheck:SetPoint("LEFT", 10, 0)
ahCutCheck:SetChecked(true)
addon.UI.ahCutCheck = ahCutCheck

local ahCutLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
ahCutLabel:SetPoint("LEFT", ahCutCheck, "RIGHT", 2, 0)
ahCutLabel:SetText(L(TEXT.OPT_AH_CUT))

local masteryCheck = CreateFrame("CheckButton", "QuickCraftsMastery", optionsFrame, "UICheckButtonTemplate")
masteryCheck:SetPoint("LEFT", 120, 0)
masteryCheck:SetChecked(false)
addon.UI.masteryCheck = masteryCheck

local masteryLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
masteryLabel:SetPoint("LEFT", masteryCheck, "RIGHT", 2, 0)
masteryLabel:SetText("|cFFDA70D6" .. L(TEXT.OPT_TRANSMUTE_MASTER) .. "|r")

local refreshBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
refreshBtn:SetSize(70, 22)
refreshBtn:SetPoint("RIGHT", -10, 0)
refreshBtn:SetText(L(TEXT.BTN_REFRESH))

refreshBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L(TEXT.REFRESH_TOOLTIP_TITLE), 1, 0.82, 0)
    GameTooltip:AddLine(L(TEXT.REFRESH_TOOLTIP_DESC), 1, 1, 1)
    GameTooltip:AddLine(L(TEXT.REFRESH_TOOLTIP_HINT))
    GameTooltip:Show()
end)

refreshBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

--============================================================================
-- COLUMN HEADERS (Clickable for sorting)
--============================================================================

local headerFrame = CreateFrame("Frame", nil, TransmutesFrame)
headerFrame:SetSize(490, 22)
headerFrame:SetPoint("TOP", optionsFrame, "BOTTOM", 0, -5)

-- Helper function to create clickable header button (styled like Refresh button)
local function CreateHeaderButton(parent, xPos, text, column)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetHeight(22)
    btn:SetPoint("LEFT", xPos, 0)
    btn:RegisterForClicks("LeftButtonUp")
    
    -- Get the button's text fontstring
    local btnText = btn:GetFontString()
    if not btnText then
        btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn:SetFontString(btnText)
    end
    btn.text = btnText
    btn.text:SetPoint("CENTER", 0, 0)
    btn.text:SetText(text)
    
    -- Auto-size width based on text (with some padding)
    btn:SetWidth(btn.text:GetStringWidth() + 20)
    
    btn.column = column
    
    -- Make sure button can receive clicks
    btn:SetMovable(false)
    btn:SetFrameLevel(headerFrame:GetFrameLevel() + 10)
    
    -- Hover effect - button template handles background highlight
    btn:SetScript("OnEnter", function(self)
        -- Button template handles this
    end)
    
    btn:SetScript("OnLeave", function(self)
        -- Update will be handled by UpdateHeaderIndicators
    end)
    
    return btn
end

-- Create clickable header buttons aligned with column positions
-- Align with row data: name at 50, cost at 200, sell at 290, profit at 360
local headerName = CreateHeaderButton(headerFrame, 50, L(TEXT.HEADER_RECIPE), "name")
local headerCost = CreateHeaderButton(headerFrame, 200, L(TEXT.HEADER_COST), "cost")
local headerSell = CreateHeaderButton(headerFrame, 290, L(TEXT.HEADER_SELL), "sell")
local headerProfit = CreateHeaderButton(headerFrame, 360, L(TEXT.HEADER_PROFIT), "profit")

local headerSep = TransmutesFrame:CreateTexture(nil, "ARTWORK")
headerSep:SetColorTexture(0.5, 0.5, 0.5, 0.5)
headerSep:SetSize(480, 1)
headerSep:SetPoint("TOP", headerFrame, "BOTTOM", 0, -2)

--============================================================================
-- SORTING FUNCTIONS
--============================================================================

-- Update header visual indicators (arrows and colors)
local function UpdateHeaderIndicators()
    local sortColumn = addon:GetSetting("sortColumn")
    local sortDirection = addon:GetSetting("sortDirection")
    
    local headers = {
        name = headerName,
        cost = headerCost,
        sell = headerSell,
        profit = headerProfit,
    }
    
    -- Sort direction indicators: use simple symbols
    local sortIndicator = (sortDirection == "desc") and " -" or " +"
    
    -- Map column names to TEXT constants
    local textMap = {
        name = TEXT.HEADER_RECIPE,
        cost = TEXT.HEADER_COST,
        sell = TEXT.HEADER_SELL,
        profit = TEXT.HEADER_PROFIT,
    }
    
    for col, header in pairs(headers) do
        local baseText = L(textMap[col])
        
        if sortColumn == col then
            header.text:SetText(baseText .. sortIndicator)
            header.text:SetTextColor(1, 0.82, 0) -- Gold for active
            -- Auto-resize button when text changes
            header:SetWidth(header.text:GetStringWidth() + 20)
        else
            header.text:SetText(baseText)
            header.text:SetTextColor(0.9, 0.9, 0.9) -- Light gray for inactive (button style)
            -- Auto-resize button when text changes
            header:SetWidth(header.text:GetStringWidth() + 20)
        end
    end
end

-- Sort recipes by the current sort settings
local function GetSortedRecipes()
    local recipes = {}
    
    -- Build table with all recipe data
    for _, recipe in ipairs(addon.Recipes) do
        local data = addon.calculatedData[recipe.id]
        if data then
            table.insert(recipes, {
                recipe = recipe,
                data = data,
            })
        end
    end
    
    -- Get sort settings
    local sortColumn = addon:GetSetting("sortColumn")
    local sortDirection = addon:GetSetting("sortDirection")
    local isDesc = (sortDirection == "desc")
    
    -- Sort function
    table.sort(recipes, function(a, b)
        local aVal, bVal
        
        if sortColumn == "name" then
            aVal = a.recipe.name or ""
            bVal = b.recipe.name or ""
        elseif sortColumn == "cost" then
            -- Use effective cost if mastery is enabled and it's a transmute
            local hasMastery = addon:GetSetting("mastery")
            if hasMastery and a.recipe.isTransmute then
                aVal = a.data.effectiveCost or -999999999
            else
                aVal = a.data.totalMatCost or -999999999
            end
            if hasMastery and b.recipe.isTransmute then
                bVal = b.data.effectiveCost or -999999999
            else
                bVal = b.data.totalMatCost or -999999999
            end
        elseif sortColumn == "sell" then
            aVal = a.data.saleAfterCut or -999999999
            bVal = b.data.saleAfterCut or -999999999
        elseif sortColumn == "profit" then
            aVal = a.data.profit or -999999999
            bVal = b.data.profit or -999999999
        else
            -- Default to profit if unknown
            aVal = a.data.profit or -999999999
            bVal = b.data.profit or -999999999
        end
        
        if isDesc then
            return aVal > bVal
        else
            return aVal < bVal
        end
    end)
    
    return recipes
end

-- Handle header click to change sort
local function OnHeaderClick(column)
    local currentColumn = addon:GetSetting("sortColumn")
    local currentDirection = addon:GetSetting("sortDirection")
    
    if currentColumn == column then
        -- Toggle direction if clicking same column
        local newDirection = (currentDirection == "desc") and "asc" or "desc"
        addon:SetSetting("sortDirection", newDirection)
    else
        -- Set new column and default to desc
        addon:SetSetting("sortColumn", column)
        addon:SetSetting("sortDirection", "desc")
    end
    
    -- Force recalculation and refresh view
    addon.Calculator:CalculateAllRecipes()
end

-- Store OnHeaderClick for later use after UpdateTransmutesView is defined
local function SetupHeaderClickHandlers()
    local function RefreshView()
        if addon.UI.UpdateTransmutesView then
            addon.UI.UpdateTransmutesView()
        end
    end
    
    headerName:SetScript("OnClick", function(self, button)
        OnHeaderClick("name")
        RefreshView()
    end)
    headerCost:SetScript("OnClick", function(self, button)
        OnHeaderClick("cost")
        RefreshView()
    end)
    headerSell:SetScript("OnClick", function(self, button)
        OnHeaderClick("sell")
        RefreshView()
    end)
    headerProfit:SetScript("OnClick", function(self, button)
        OnHeaderClick("profit")
        RefreshView()
    end)
end

-- Set up click handlers after buttons are created
SetupHeaderClickHandlers()

--============================================================================
-- RECIPE ROWS
--============================================================================

local recipeRows = {}
addon.UI.recipeRows = recipeRows

local function CreateRecipeRow(index, recipe)
    local row = CreateFrame("Button", nil, TransmutesFrame)
    row:SetSize(490, 36)
    row:SetPoint("TOP", headerSep, "BOTTOM", 0, -5 - ((index - 1) * 38))
    
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Product icon
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(20, 20)
    row.icon:SetPoint("LEFT", 12, 0)
    
    -- Recipe name
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.nameText:SetPoint("LEFT", 50, 0)
    row.nameText:SetWidth(140)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetText(recipe.name)
    
    -- Cost
    row.costText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.costText:SetPoint("LEFT", 200, 0)
    row.costText:SetWidth(80)
    row.costText:SetJustifyH("LEFT")
    row.costText:SetText("...")
    
    -- Sell price
    row.sellText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.sellText:SetPoint("LEFT", 290, 0)
    row.sellText:SetWidth(80)
    row.sellText:SetJustifyH("LEFT")
    row.sellText:SetText("...")
    
    -- Profit
    row.profitText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.profitText:SetPoint("LEFT", 360, 0)
    row.profitText:SetWidth(65)
    row.profitText:SetJustifyH("LEFT")
    row.profitText:SetText("...")

    -- Craft button (actions via modifiers)
    row.craftBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.craftBtn:SetSize(50, 22)
    row.craftBtn:SetPoint("RIGHT", -10, 0)
    row.craftBtn:SetText("Craft")
    row.craftBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    row.craftBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Quick Craft", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: Craft 1", 1, 1, 1)
        GameTooltip:AddLine("Right-click: Craft X", 1, 1, 1)
        GameTooltip:AddLine("Shift-click: Craft Max Profitable", 1, 1, 1)
        GameTooltip:AddLine("Ctrl-click: Open Recipe", 1, 1, 1)
        GameTooltip:Show()
    end)
    row.craftBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    row.craftBtn:SetScript("OnClick", function(_, button)
        if not addon.Crafting then
            print("|cFF00CCFFQuickCrafts|r: Crafting module not loaded.")
            return
        end

        -- Ctrl-click: just open/select the recipe
        if IsControlKeyDown() then
            addon.Crafting:OpenRecipe(recipe)
            return
        end

        -- Shift-click: craft max profitable (profit > 0 and have mats)
        if IsShiftKeyDown() then
            local data = addon.calculatedData and addon.calculatedData[recipe.id]
            if not data or not data.hasAllPrices or not data.productPrice then
                print("|cFF00CCFFQuickCrafts|r: Missing price data. Click Refresh and try again.")
                return
            end
            if (data.profit or 0) <= 0 then
                print("|cFF00CCFFQuickCrafts|r: Not profitable right now.")
                return
            end

            local maxCraftable = math.huge
            for _, mat in ipairs(recipe.materials or {}) do
                local owned = GetItemCount(mat.itemID, true) or 0
                local possible = math.floor(owned / (mat.amount or 1))
                if possible < maxCraftable then
                    maxCraftable = possible
                end
            end
            if maxCraftable == math.huge then maxCraftable = 0 end
            if maxCraftable < 1 then
                print("|cFF00CCFFQuickCrafts|r: You don't have the materials for this craft.")
                return
            end

            addon.Crafting:Craft(recipe, maxCraftable)
            return
        end

        -- Right-click: prompt Craft X
        if button == "RightButton" then
            addon.Crafting:PromptCraftX(recipe)
            return
        end

        -- Default: craft 1
        addon.Crafting:Craft(recipe, 1)
    end)
    
    -- Click to view details
    row:SetScript("OnClick", function()
        addon.UI.ShowDetailView(recipe.id)
    end)
    
    -- Tooltip on hover
    row:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(recipe.name, 1, 0.82, 0)
        GameTooltip:AddLine(L(TEXT.CLICK_FOR_DETAILS), 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    row.recipe = recipe
    return row
end

-- Initialize all recipe rows
local function InitializeRecipeRows()
    for i, recipe in ipairs(addon.Recipes) do
        recipeRows[recipe.id] = CreateRecipeRow(i, recipe)
    end
end

--============================================================================
-- STATUS TEXT
--============================================================================

local statusText = TransmutesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
--statusText:SetPoint("BOTTOM", 0, 50)
statusText:SetTextColor(0.7, 0.7, 0.7)
statusText:SetText("")
addon.UI.statusText = statusText

--============================================================================
-- UPDATE FUNCTION
--============================================================================

local function UpdateTransmutesView()
    -- Check if price source is available
    local available, sourceName = addon.PriceSource:IsAvailable()
    if not available then
        statusText:SetText("|cFFFF0000" .. L(TEXT.STATUS_AUCTIONATOR_NOT_DETECTED) .. "|r")
        return
    end
    
    statusText:SetText("")
    
    -- Calculate all recipes
    addon.Calculator:CalculateAllRecipes()
    
    -- Get sorted recipes
    local sortedRecipes = GetSortedRecipes()
    
    -- Update header indicators
    UpdateHeaderIndicators()
    
    -- Update each row based on sorted order
    for index, item in ipairs(sortedRecipes) do
        local recipe = item.recipe
        local data = item.data
        local row = recipeRows[recipe.id]
        
        if row and data then
            -- Reposition row based on sort order
            row:ClearAllPoints()
            row:SetPoint("TOP", headerSep, "BOTTOM", 0, -5 - ((index - 1) * 38))
            
            -- Update icon
            row.icon:SetTexture(addon.PriceSource:GetItemIcon(recipe.product.itemID))
            
            -- Update cost (show effective cost if mastery enabled)
            if data.hasAllPrices then
                if addon:GetSetting("mastery") and recipe.isTransmute then
                    row.costText:SetText(addon.Calculator:FormatGoldCompact(data.effectiveCost))
                else
                    row.costText:SetText(addon.Calculator:FormatGoldCompact(data.totalMatCost))
                end
            else
                row.costText:SetText("|cFFFF0000???|r")
            end
            
            -- Update sell price
            if data.productPrice then
                row.sellText:SetText(addon.Calculator:FormatGoldCompact(data.saleAfterCut))
            else
                row.sellText:SetText("|cFFFF0000???|r")
            end
            
            -- Update profit
            row.profitText:SetText(addon.Calculator:FormatProfit(data.profit))
        end
    end
    
    statusText:SetText(string.format(L(TEXT.STATUS_UPDATED), date("%H:%M:%S")))
end

-- Store reference for other files to call
addon.UI.UpdateTransmutesView = UpdateTransmutesView

--============================================================================
-- UPDATE ALL (transmutes + detail views + pigments if open)
--============================================================================

local function UpdateAll()
    -- Update transmutes
    UpdateTransmutesView()
    if addon.UI.DetailFrame and addon.UI.DetailFrame:IsShown() then
        addon.UI.UpdateDetailView()
    end
    
    -- Update pigments
    if addon.PigmentCalculator and addon.PigmentCalculator.CalculateAllPigments then
        addon.PigmentCalculator:CalculateAllPigments()
    end
    if addon.UI.PigmentsFrame and addon.UI.PigmentsFrame:IsShown() then
        if addon.UI.UpdatePigmentsView then
            addon.UI.UpdatePigmentsView()
        end
    end
    if addon.UI.PigmentDetailFrame and addon.UI.PigmentDetailFrame:IsShown() then
        if addon.UI.UpdatePigmentDetailView then
            addon.UI.UpdatePigmentDetailView()
        end
    end
end

addon.UI.UpdateAll = UpdateAll

--============================================================================
-- EVENT HANDLERS
--============================================================================

refreshBtn:SetScript("OnClick", UpdateAll)

ahCutCheck:SetScript("OnClick", function(self)
    addon:SetSetting("ahCut", self:GetChecked())
    -- Sync with pigments checkbox
    if addon.UI.pigmentAhCutCheck then
        addon.UI.pigmentAhCutCheck:SetChecked(self:GetChecked())
    end
    UpdateAll()
end)

masteryCheck:SetScript("OnClick", function(self)
    addon:SetSetting("mastery", self:GetChecked())
    UpdateAll()
end)

InitializeRecipeRows()

-- Initialize header indicators on load
UpdateHeaderIndicators()
