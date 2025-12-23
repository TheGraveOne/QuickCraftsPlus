--============================================================================
-- QuickCrafts: UI/DetailView.lua
-- Detail view - shows full breakdown for a single recipe
--============================================================================

local addonName, addon = ...
local L = addon.L
local TEXT = addon.CONST.TEXT

local MainFrame = addon.UI.MainFrame
local TransmutesFrame = addon.UI.TransmutesFrame

--============================================================================
-- DETAIL FRAME
--============================================================================

local DetailFrame = CreateFrame("Frame", nil, MainFrame)
DetailFrame:SetAllPoints()
DetailFrame:Hide()
addon.UI.DetailFrame = DetailFrame

local currentRecipeID = nil

--============================================================================
-- BACK BUTTON
--============================================================================

local backBtn = CreateFrame("Button", nil, DetailFrame, "UIPanelButtonTemplate")
backBtn:SetSize(70, 24)
backBtn:SetPoint("TOPLEFT", 20, -25)
backBtn:SetText(L(TEXT.BTN_BACK))
backBtn:SetScript("OnClick", function()
    DetailFrame:Hide()
    TransmutesFrame:Show()
end)

--============================================================================
-- SEARCH AH BUTTON
--============================================================================

local searchAHBtn = CreateFrame("Button", nil, DetailFrame, "UIPanelButtonTemplate")
searchAHBtn:SetSize(90, 24)
searchAHBtn:SetPoint("TOPRIGHT", -20, -25)
searchAHBtn:SetText(L(TEXT.BTN_SEARCH_AH))

-- Tooltip for the search button
searchAHBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L(TEXT.SEARCH_AH_TOOLTIP_TITLE), 1, 0.82, 0)
    GameTooltip:AddLine(L(TEXT.SEARCH_AH_TOOLTIP_DESC), 1, 1, 1)
    GameTooltip:AddLine(L(TEXT.SEARCH_AH_TOOLTIP_DESC2), 1, 1, 1)
    GameTooltip:AddLine(" ")
    if not addon.PriceSource:IsAuctionHouseOpen() then
        GameTooltip:AddLine(L(TEXT.SEARCH_AH_MUST_OPEN), 1, 0.2, 0.2)
    else
        GameTooltip:AddLine(L(TEXT.SEARCH_AH_READY), 0.2, 1, 0.2)
    end
    GameTooltip:Show()
end)

searchAHBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

searchAHBtn:SetScript("OnClick", function()
    if not currentRecipeID then return end
    
    local recipe = addon:GetRecipeByID(currentRecipeID)
    if not recipe then return end
    
    local success, errorMsg = addon.PriceSource:SearchRecipe(recipe)
end)

--============================================================================
-- CONTENT CONTAINER
--============================================================================

local detailContent = CreateFrame("Frame", nil, DetailFrame)
detailContent:SetSize(480, 380)
detailContent:SetPoint("TOP", 0, -55)

--============================================================================
-- RECIPE TITLE
--============================================================================

local detailTitle = detailContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
detailTitle:SetPoint("TOP", 0, -5)
detailTitle:SetText("Recipe Name")
detailTitle:SetTextColor(1, 0.82, 0)

-- Separator under title
local detailSep1 = detailContent:CreateTexture(nil, "ARTWORK")
detailSep1:SetColorTexture(0.5, 0.5, 0.5, 0.5)
detailSep1:SetSize(440, 1)
detailSep1:SetPoint("TOP", detailTitle, "BOTTOM", 0, -10)

--============================================================================
-- MATERIALS SECTION
--============================================================================

local matHeader = detailContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
matHeader:SetPoint("TOPLEFT", 20, -45)
matHeader:SetText("|cFF00FF00" .. L(TEXT.SECTION_MATERIALS) .. "|r")

local materialRows = {}

-- Enable tooltips on the detail content frame
detailContent:EnableMouse(true)
detailContent:SetHyperlinksEnabled(true)

detailContent:SetScript("OnHyperlinkEnter", function(self, linkData, link)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(link)
    GameTooltip:Show()
end)

detailContent:SetScript("OnHyperlinkLeave", function(self)
    GameTooltip:Hide()
end)

detailContent:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
    SetItemRef(link, link, button)
end)

--============================================================================
-- PRODUCT SECTION
--============================================================================

local productHeader = detailContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
productHeader:SetPoint("TOPLEFT", 20, -160)
productHeader:SetText("|cFFDA70D6" .. L(TEXT.SECTION_PRODUCT) .. "|r")

local productIcon = detailContent:CreateTexture(nil, "ARTWORK")
productIcon:SetSize(28, 28)
productIcon:SetPoint("TOPLEFT", 25, -185)

local productName = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
productName:SetPoint("LEFT", productIcon, "RIGHT", 10, 0)
productName:SetText("Product Name")

local productPrice = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
productPrice:SetPoint("TOPRIGHT", -25, -190)
productPrice:SetText("0g")

--============================================================================
-- SUMMARY SECTION
--============================================================================

-- Separator
local detailSep2 = detailContent:CreateTexture(nil, "ARTWORK")
detailSep2:SetColorTexture(0.5, 0.5, 0.5, 0.5)
detailSep2:SetSize(440, 1)
detailSep2:SetPoint("TOP", 0, -225)

-- Total Material Cost
local summaryMatCostLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryMatCostLabel:SetPoint("TOPLEFT", 20, -240)
summaryMatCostLabel:SetText(L(TEXT.TOTAL_MATERIAL_COST))

local summaryMatCostValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryMatCostValue:SetPoint("TOPRIGHT", -25, -240)
summaryMatCostValue:SetText("0g")

-- Effective Cost (with Mastery)
local summaryEffCostLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryEffCostLabel:SetPoint("TOPLEFT", 20, -260)
summaryEffCostLabel:SetText("|cFFDA70D6" .. L(TEXT.EFFECTIVE_COST_MASTERY) .. "|r")

local summaryEffCostValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryEffCostValue:SetPoint("TOPRIGHT", -25, -260)
summaryEffCostValue:SetText("")

-- Sale After AH Cut
local summarySaleLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summarySaleLabel:SetPoint("TOPLEFT", 20, -285)
summarySaleLabel:SetText(L(TEXT.SALE_AFTER_CUT))

local summarySaleValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summarySaleValue:SetPoint("TOPRIGHT", -25, -285)
summarySaleValue:SetText("0g")

--============================================================================
-- PROFIT SECTION
--============================================================================

local profitSep = detailContent:CreateTexture(nil, "ARTWORK")
profitSep:SetColorTexture(0.3, 0.6, 0.3, 0.8)
profitSep:SetSize(440, 1)
profitSep:SetPoint("TOP", 0, -310)

local profitLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
profitLabel:SetPoint("TOPLEFT", 20, -325)
profitLabel:SetText(L(TEXT.PROFIT_COLON))

local profitValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
profitValue:SetPoint("LEFT", profitLabel, "RIGHT", 20, 0)
profitValue:SetText("|cFF00FF000g|r")

local marginValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
marginValue:SetPoint("LEFT", profitValue, "RIGHT", 20, 0)
marginValue:SetText("")

--============================================================================
-- UPDATE FUNCTION
--============================================================================

local function UpdateDetailView()
    if not currentRecipeID then return end
    
    local data = addon.calculatedData[currentRecipeID]
    if not data then return end
    
    local recipe = data.recipe
    
    -- Update title with item link
    detailTitle:SetText(addon.PriceSource:GetItemDisplayText(recipe.product.itemID, recipe.name))
    
    -- Hide all existing material rows
    for _, row in pairs(materialRows) do
        row.icon:Hide()
        row.name:Hide()
        row.price:Hide()
    end
    
    -- Create/update material rows
    for i, mat in ipairs(recipe.materials) do
        -- Create row elements if they don't exist
        if not materialRows[i] then
            materialRows[i] = {
                icon = detailContent:CreateTexture(nil, "ARTWORK"),
                name = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight"),
                price = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight"),
            }
            materialRows[i].icon:SetSize(24, 24)
            materialRows[i].name:SetWidth(300)
            materialRows[i].name:SetJustifyH("LEFT")
        end
        
        local row = materialRows[i]
        local yOffset = -65 - ((i - 1) * 28)
        
        -- Position and show icon
        row.icon:ClearAllPoints()
        row.icon:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 25, yOffset)
        row.icon:SetTexture(addon.PriceSource:GetItemIcon(mat.itemID))
        row.icon:Show()
        
        -- Position and show name with item link
        row.name:ClearAllPoints()
        row.name:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 55, yOffset - 3)
        local itemDisplay = addon.PriceSource:GetItemDisplayText(mat.itemID, mat.name)
        row.name:SetText(string.format("%dx %s", mat.amount, itemDisplay))
        row.name:Show()
        
        -- Position and show price
        row.price:ClearAllPoints()
        row.price:SetPoint("TOPRIGHT", detailContent, "TOPRIGHT", -25, yOffset - 3)
        local matData = data.materialCosts[mat.itemID]
        if matData and matData.totalPrice then
            row.price:SetText(addon.Calculator:FormatGold(matData.totalPrice))
        else
            row.price:SetText("|cFFFF0000" .. L(TEXT.STATUS_NO_DATA) .. "|r")
        end
        row.price:Show()
    end
    
    -- Adjust product section position based on number of materials
    local matCount = #recipe.materials
    local productYOffset = -65 - (matCount * 28) - 20
    
    productHeader:ClearAllPoints()
    productHeader:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 20, productYOffset)
    
    productIcon:ClearAllPoints()
    productIcon:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 25, productYOffset - 25)
    productIcon:SetTexture(addon.PriceSource:GetItemIcon(recipe.product.itemID))
    
    productName:SetText(addon.PriceSource:GetItemDisplayText(recipe.product.itemID, recipe.name))
    
    if data.productPrice then
        productPrice:SetText(addon.Calculator:FormatGold(data.productPrice))
    else
        productPrice:SetText("|cFFFF0000" .. L(TEXT.STATUS_NO_DATA) .. "|r")
    end
    productPrice:ClearAllPoints()
    productPrice:SetPoint("TOPRIGHT", detailContent, "TOPRIGHT", -25, productYOffset - 28)
    
    -- Adjust summary section position
    local summaryYOffset = productYOffset - 65
    
    detailSep2:ClearAllPoints()
    detailSep2:SetPoint("TOP", detailContent, "TOP", 0, summaryYOffset)
    
    summaryMatCostLabel:ClearAllPoints()
    summaryMatCostLabel:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 20, summaryYOffset - 15)
    summaryMatCostValue:ClearAllPoints()
    summaryMatCostValue:SetPoint("TOPRIGHT", detailContent, "TOPRIGHT", -25, summaryYOffset - 15)
    summaryMatCostValue:SetText(addon.Calculator:FormatGold(data.totalMatCost))
    
    -- Show/hide effective cost based on mastery setting
    summaryEffCostLabel:ClearAllPoints()
    summaryEffCostLabel:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 20, summaryYOffset - 38)
    summaryEffCostValue:ClearAllPoints()
    summaryEffCostValue:SetPoint("TOPRIGHT", detailContent, "TOPRIGHT", -25, summaryYOffset - 38)
    
    if addon:GetSetting("mastery") and recipe.isTransmute then
        summaryEffCostLabel:Show()
        summaryEffCostValue:Show()
        summaryEffCostValue:SetText(addon.Calculator:FormatGold(data.effectiveCost))
    else
        summaryEffCostLabel:Hide()
        summaryEffCostValue:Hide()
    end
    
    -- Sale after AH cut
    local saleYOffset = summaryYOffset - 60
    summarySaleLabel:ClearAllPoints()
    summarySaleLabel:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 20, saleYOffset)
    summarySaleValue:ClearAllPoints()
    summarySaleValue:SetPoint("TOPRIGHT", detailContent, "TOPRIGHT", -25, saleYOffset)
    summarySaleValue:SetText(addon.Calculator:FormatGold(data.saleAfterCut))
    
    -- Profit display
    local profitYOffset = saleYOffset - 30
    
    profitSep:ClearAllPoints()
    profitSep:SetPoint("TOP", detailContent, "TOP", 0, profitYOffset + 5)
    
    profitLabel:ClearAllPoints()
    profitLabel:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 20, profitYOffset - 15)
    profitValue:ClearAllPoints()
    profitValue:SetPoint("LEFT", profitLabel, "RIGHT", 20, 0)
    marginValue:ClearAllPoints()
    marginValue:SetPoint("LEFT", profitValue, "RIGHT", 20, 0)
    
    if data.profit then
        if data.profit >= 0 then
            profitValue:SetText("|cFF00FF00" .. addon.Calculator:FormatGold(data.profit) .. "|r")
        else
            profitValue:SetText("|cFFFF0000" .. addon.Calculator:FormatGold(data.profit) .. "|r")
        end
        
        if data.margin then
            marginValue:SetText(addon.Calculator:FormatPercent(data.margin) .. " " .. L(TEXT.MARGIN_SUFFIX))
        else
            marginValue:SetText("")
        end
    else
        profitValue:SetText("|cFF888888N/A|r")
        marginValue:SetText("")
    end
end

addon.UI.UpdateDetailView = UpdateDetailView

--============================================================================
-- SHOW DETAIL VIEW
--============================================================================

local function ShowDetailView(recipeID)
    currentRecipeID = recipeID
    TransmutesFrame:Hide()
    DetailFrame:Show()
    UpdateDetailView()
end

addon.UI.ShowDetailView = ShowDetailView
