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
-- COLUMN HEADERS
--============================================================================

local headerFrame = CreateFrame("Frame", nil, TransmutesFrame)
headerFrame:SetSize(490, 20)
headerFrame:SetPoint("TOP", optionsFrame, "BOTTOM", 0, -5)

local headerName = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
headerName:SetPoint("LEFT", 50, 0)
headerName:SetText("|cFFAAAACC" .. L(TEXT.HEADER_RECIPE) .. "|r")

local headerCost = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
headerCost:SetPoint("LEFT", 200, 0)
headerCost:SetText("|cFFAAAACC" .. L(TEXT.HEADER_COST) .. "|r")

local headerSell = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
headerSell:SetPoint("LEFT", 290, 0)
headerSell:SetText("|cFFAAAACC" .. L(TEXT.HEADER_SELL) .. "|r")

local headerProfit = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
headerProfit:SetPoint("LEFT", 380, 0)
headerProfit:SetText("|cFFAAAACC" .. L(TEXT.HEADER_PROFIT) .. "|r")

local headerSep = TransmutesFrame:CreateTexture(nil, "ARTWORK")
headerSep:SetColorTexture(0.5, 0.5, 0.5, 0.5)
headerSep:SetSize(480, 1)
headerSep:SetPoint("TOP", headerFrame, "BOTTOM", 0, -2)

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
    row.profitText:SetPoint("LEFT", 380, 0)
    row.profitText:SetWidth(70)
    row.profitText:SetJustifyH("LEFT")
    row.profitText:SetText("...")
    
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
    
    -- Update each row
    for _, recipe in ipairs(addon.Recipes) do
        local row = recipeRows[recipe.id]
        local data = addon.calculatedData[recipe.id]
        
        if row and data then
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
