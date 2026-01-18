--============================================================================
-- QuickCrafts: UI/PigmentDetailView.lua
-- Detail view - shows full breakdown for a single pigment with herbs and dyes
--============================================================================

local addonName, addon = ...
local L = addon.L
local TEXT = addon.CONST.TEXT

local MainFrame = addon.UI.MainFrame
local PigmentsFrame = addon.UI.PigmentsFrame

--============================================================================
-- PIGMENT DETAIL FRAME
--============================================================================

local PigmentDetailFrame = CreateFrame("Frame", nil, MainFrame)
PigmentDetailFrame:SetAllPoints()
PigmentDetailFrame:Hide()
addon.UI.PigmentDetailFrame = PigmentDetailFrame

local currentPigmentID = nil

--============================================================================
-- BACK BUTTON
--============================================================================

local backBtn = CreateFrame("Button", nil, PigmentDetailFrame, "UIPanelButtonTemplate")
backBtn:SetSize(70, 24)
backBtn:SetPoint("TOPLEFT", 20, -25)
backBtn:SetText(L(TEXT.BTN_BACK))
backBtn:SetScript("OnClick", function()
    PigmentDetailFrame:Hide()
    PigmentsFrame:Show()
end)

--============================================================================
-- SEARCH AH BUTTON
--============================================================================

local searchAHBtn = CreateFrame("Button", nil, PigmentDetailFrame, "UIPanelButtonTemplate")
searchAHBtn:SetSize(90, 24)
searchAHBtn:SetPoint("TOPRIGHT", -20, -25)
searchAHBtn:SetText(L(TEXT.BTN_SEARCH_AH))

searchAHBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L(TEXT.SEARCH_AH_TOOLTIP_TITLE), 1, 0.82, 0)
    GameTooltip:AddLine(L(TEXT.SEARCH_AH_PIGMENT_DESC), 1, 1, 1)
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
    if not currentPigmentID then return end
    
    local pigment = addon:GetPigmentByID(currentPigmentID)
    if not pigment then return end
    
    -- Build search terms
    local searchTerms = {}
    
    -- Add pigment
    local pigmentName = addon.itemNames[pigment.itemID]
    if pigmentName then
        table.insert(searchTerms, pigmentName)
    end
    
    -- Add all herbs
    for _, herb in ipairs(pigment.herbs) do
        local herbName = addon.itemNames[herb.itemID]
        if herbName then
            table.insert(searchTerms, herbName)
        end
    end
    
    -- Add all dyes
    local dyeGroup = addon.Dyes and addon.Dyes[pigment.id]
    if dyeGroup and dyeGroup.dyes then
        for _, dye in ipairs(dyeGroup.dyes) do
            if dye.itemID and dye.itemID > 0 then
                local dyeName = addon.itemNames[dye.itemID]
                if dyeName then
                    table.insert(searchTerms, dyeName)
                end
            end
        end
    end
    
    if #searchTerms == 0 then
        print("|cFFFF0000QuickCrafts:|r " .. L(TEXT.ERR_ITEM_NAMES_NOT_LOADED))
        return
    end
    
    -- Check AH is open
    if not addon.PriceSource:IsAuctionHouseOpen() then
        print("|cFFFF0000QuickCrafts:|r " .. L(TEXT.ERR_AH_MUST_BE_OPEN))
        return
    end
    
    -- Perform search
    if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.MultiSearchExact then
        local success, err = pcall(function()
            Auctionator.API.v1.MultiSearchExact(addonName, searchTerms)
        end)
    else
        print("|cFFFF0000QuickCrafts:|r " .. L(TEXT.ERR_SEARCH_API_NOT_AVAILABLE))
    end
end)

--============================================================================
-- MAIN SCROLL FRAME
--============================================================================

local mainScrollFrame = CreateFrame("ScrollFrame", nil, PigmentDetailFrame, "UIPanelScrollFrameTemplate")
mainScrollFrame:SetSize(470, 380)
mainScrollFrame:SetPoint("TOP", 0, -55)

local detailContent = CreateFrame("Frame", nil, mainScrollFrame)
detailContent:SetSize(450, 700)
mainScrollFrame:SetScrollChild(detailContent)

-- Enable hyperlinks for item tooltips
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
-- PIGMENT TITLE
--============================================================================

local detailTitle = detailContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
detailTitle:SetPoint("TOP", 0, -5)
detailTitle:SetText("Pigment Name")
detailTitle:SetTextColor(1, 0.82, 0)

--============================================================================
-- OPTIONS ROW (checkboxes)
--============================================================================

local optionsFrame = CreateFrame("Frame", nil, PigmentDetailFrame)
optionsFrame:SetSize(490, 30)
optionsFrame:SetPoint("TOP", 0, -25)

local buyPigmentsCheck = CreateFrame("CheckButton", "QuickCraftsBuyPigments", optionsFrame, "UICheckButtonTemplate")
buyPigmentsCheck:SetPoint("LEFT", backBtn, "RIGHT", 20, 0)
buyPigmentsCheck:SetChecked(false)
addon.UI.buyPigmentsCheck = buyPigmentsCheck

local buyPigmentsLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
buyPigmentsLabel:SetPoint("LEFT", buyPigmentsCheck, "RIGHT", 2, 0)
buyPigmentsLabel:SetText(L(TEXT.OPT_BUY_PIGMENTS))

buyPigmentsCheck:SetScript("OnClick", function(self)
    addon:SetSetting("buyPigments", self:GetChecked())
    addon.UI.UpdatePigmentDetailView()
end)

--============================================================================
-- DYES SECTION
--============================================================================

local dyesHeader = detailContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dyesHeader:SetPoint("TOPLEFT", 15, -35)
dyesHeader:SetText("|cFFDA70D6" .. L(TEXT.SECTION_CRAFTABLE_DYES) .. "|r " .. L(TEXT.SECTION_DYES_HIGHLIGHT))

-- Container for dye rows
local dyeContainer = CreateFrame("Frame", nil, detailContent)
dyeContainer:SetSize(420, 1)
dyeContainer:SetPoint("TOPLEFT", 15, -55)
local dyeRows = {}

--============================================================================
-- HERBS SECTION
--============================================================================

local herbsHeader = detailContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
herbsHeader:SetPoint("TOPLEFT", 15, -200)
herbsHeader:SetText("|cFF00FF00" .. L(TEXT.SECTION_AVAILABLE_HERBS) .. "|r " .. L(TEXT.SECTION_HERBS_HIGHLIGHT))

-- Container for herb rows
local herbContainer = CreateFrame("Frame", nil, detailContent)
herbContainer:SetSize(420, 1)
herbContainer:SetPoint("TOPLEFT", 15, -220)

local herbRows = {}

--============================================================================
-- SUMMARY SECTION
--============================================================================

local summaryHeader = detailContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
summaryHeader:SetPoint("TOPLEFT", 15, -450)
summaryHeader:SetText("|cFFFFCC00" .. L(TEXT.SECTION_SUMMARY) .. "|r")

local summarySep = detailContent:CreateTexture(nil, "ARTWORK")
summarySep:SetColorTexture(0.5, 0.5, 0.5, 0.5)
summarySep:SetSize(420, 1)
summarySep:SetPoint("TOPLEFT", summaryHeader, "BOTTOMLEFT", 0, -5)

-- Cheapest Herb
local cheapestHerbLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
cheapestHerbLabel:SetPoint("TOPLEFT", summarySep, "BOTTOMLEFT", 0, -12)
cheapestHerbLabel:SetText(L(TEXT.CHEAPEST_HERB))

local cheapestHerbValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
cheapestHerbValue:SetPoint("LEFT", cheapestHerbLabel, "RIGHT", 10, 0)
cheapestHerbValue:SetWidth(280)
cheapestHerbValue:SetJustifyH("LEFT")

-- Total Cost
local totalCostLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
totalCostLabel:SetPoint("TOPLEFT", cheapestHerbLabel, "BOTTOMLEFT", 0, -8)
totalCostLabel:SetText(L(TEXT.COST_HERBS))

local totalCostValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
totalCostValue:SetPoint("LEFT", totalCostLabel, "RIGHT", 10, 0)

-- Best Dye
local bestDyeLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
bestDyeLabel:SetPoint("TOPLEFT", totalCostLabel, "BOTTOMLEFT", 0, -12)
bestDyeLabel:SetText(L(TEXT.BEST_DYE))

local bestDyeValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
bestDyeValue:SetPoint("LEFT", bestDyeLabel, "RIGHT", 10, 0)
bestDyeValue:SetWidth(280)
bestDyeValue:SetJustifyH("LEFT")

-- Dye Sale Price
local dyeSaleLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dyeSaleLabel:SetPoint("TOPLEFT", bestDyeLabel, "BOTTOMLEFT", 0, -8)
dyeSaleLabel:SetText(L(TEXT.DYE_SALE))

local dyeSaleValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dyeSaleValue:SetPoint("LEFT", dyeSaleLabel, "RIGHT", 10, 0)

--============================================================================
-- PROFIT SECTION
--============================================================================

local profitSep = detailContent:CreateTexture(nil, "ARTWORK")
profitSep:SetColorTexture(0.3, 0.6, 0.3, 0.8)
profitSep:SetSize(420, 1)
profitSep:SetPoint("TOPLEFT", dyeSaleLabel, "BOTTOMLEFT", 0, -15)

local profitLabel = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
profitLabel:SetPoint("TOPLEFT", profitSep, "BOTTOMLEFT", 0, -12)
profitLabel:SetText(L(TEXT.PROFIT_COLON))

local profitValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
profitValue:SetPoint("LEFT", profitLabel, "RIGHT", 20, 0)

local marginValue = detailContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
marginValue:SetPoint("LEFT", profitValue, "RIGHT", 15, 0)

--============================================================================
-- UPDATE FUNCTION
--============================================================================

local function UpdatePigmentDetailView()
    if not currentPigmentID then return end
    
    local data = addon.pigmentData[currentPigmentID]
    if not data then return end
    
    local pigment = data.pigment
    
    -- Update title with item link
    detailTitle:SetText(addon.PriceSource:GetItemDisplayText(pigment.itemID, pigment.name))
    
    -- Hide all existing dye rows
    for _, row in pairs(dyeRows) do
        if row.frame then row.frame:Hide() end
    end
    
    -- Get and sort dyes by price (highest first)
    local dyeGroup = addon.Dyes and addon.Dyes[pigment.id]
    local dyeYOffset = 0
    local dyeCount = 0
    
    if dyeGroup and dyeGroup.dyes and #dyeGroup.dyes > 0 then
        dyesHeader:SetText("|cFFDA70D6Craftable Dyes|r (most expensive highlighted)")
        
        local sortedDyes = {}
        for _, dye in ipairs(dyeGroup.dyes) do
            if dye.itemID and dye.itemID > 0 then
                local priceData = data.dyePrices[dye.itemID]
                table.insert(sortedDyes, {
                    dye = dye,
                    price = priceData and priceData.price or nil
                })
            end
        end
        table.sort(sortedDyes, function(a, b)
            if not a.price then return false end
            if not b.price then return true end
            return a.price > b.price
        end)
        
        dyeCount = #sortedDyes
        
        for i, dyeInfo in ipairs(sortedDyes) do
            local dye = dyeInfo.dye
            local price = dyeInfo.price
            local isBest = data.bestDye and dye.itemID == data.bestDye.itemID
            
            if not dyeRows[i] then
                dyeRows[i] = {
                    frame = CreateFrame("Frame", nil, dyeContainer),
                }
                local row = dyeRows[i]
                row.frame:SetSize(420, 24)

                -- tooltips added
                row.frame:EnableMouse(true)
                row.frame:SetHyperlinksEnabled(true)
                row.frame:SetScript("OnHyperlinkEnter", function(self, linkData, link)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(link)
                    GameTooltip:Show()
                end)
                row.frame:SetScript("OnHyperlinkLeave", function(self)
                    GameTooltip:Hide()
                end)
                row.frame:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
                    SetItemRef(link, link, button)
                end)

                row.highlight = row.frame:CreateTexture(nil, "BACKGROUND")
                row.highlight:SetAllPoints()
                row.highlight:SetColorTexture(0.8, 0.4, 1, 0.2)
                
                row.icon = row.frame:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(20, 20)
                row.icon:SetPoint("LEFT", 5, 0)
                
                row.name = row.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.name:SetPoint("LEFT", 30, 0)
                row.name:SetWidth(220)
                row.name:SetJustifyH("LEFT")
                
                row.price = row.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.price:SetPoint("RIGHT", -60, 0)
                row.price:SetJustifyH("RIGHT")

                row.profit = row.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.profit:SetPoint("RIGHT", row.price, "LEFT", -15, 0)
                row.profit:SetJustifyH("RIGHT")

                -- Craft button (actions via modifiers)
                row.craftBtn = CreateFrame("Button", nil, row.frame, "UIPanelButtonTemplate")
                row.craftBtn:SetSize(50, 20)
                row.craftBtn:SetPoint("RIGHT", -5, 0)
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
            end
            
            local row = dyeRows[i]
            row.frame:SetPoint("TOPLEFT", dyeContainer, "TOPLEFT", 0, -dyeYOffset)
            row.frame:Show()
            
            row.icon:SetTexture(addon.PriceSource:GetItemIcon(dye.itemID))
            -- Use item link for hover tooltips
            row.name:SetText(addon.PriceSource:GetItemDisplayText(dye.itemID, dye.name))
            
            -- Calculates price text that is shown
            if price then
                row.price:SetText(addon.Calculator:FormatGoldCompact(price))
                if isBest then
                    row.price:SetTextColor(0.9, 0.5, 1)
                    row.highlight:Show()
                else
                    row.price:SetTextColor(1, 1, 1)
                    row.highlight:Hide()
                end
            else
                row.price:SetText("|cFF888888N/A|r")
                row.highlight:Hide()
            end

            -- Calculates profit text that is shown
            local pigmentCost = nil
            if addon:GetSetting("buyPigments") then
                pigmentCost = addon.PriceSource:GetPrice(pigment.itemID)
            else
                pigmentCost = data.totalCost
            end

            local outputCount = dye.outputCount or 1
            local pigmentAmount = dye.pigmentAmount or 1
            if price and pigmentCost then
                local saleValue = price * outputCount
                local saleAfterAHCut = saleValue
                -- If auction house cut is enabled, include in calculation
                if addon:GetSetting("ahCut") then
                    saleAfterAHCut = math.floor(saleValue * 0.95)
                end
                local dyeProfit = saleAfterAHCut - (pigmentCost * pigmentAmount)
                row.profit:SetText(addon.Calculator:FormatProfit(dyeProfit))
            -- If you do not have an AH price for the pigment
            elseif addon:GetSetting("buyPigments") and not pigmentCost then
                row.profit:SetText("|cFF888888N/A|r")
            else
                row.profit:SetText("")
            end

            -- Wire craft button for this dye
            if row.craftBtn then
                local craftSpec = {
                    recipeID = dye.recipeID,
                    outputItemID = dye.itemID,
                    name = dye.name,
                }
                row.craftBtn:SetScript("OnClick", function(_, button)
                    if not addon.Crafting then
                        print("|cFF00CCFFQuickCrafts|r: Crafting module not loaded.")
                        return
                    end

                    -- Ctrl-click: just open/select the recipe
                    if IsControlKeyDown() then
                        addon.Crafting:OpenRecipe(craftSpec)
                        return
                    end

                    -- Shift-click: craft max profitable (profit > 0 and have pigments)
                    if IsShiftKeyDown() then
                        if not price then
                            print("|cFF00CCFFQuickCrafts|r: Missing dye price. Click Refresh and try again.")
                            return
                        end

                        local pigmentCostForCalc = pigmentCost
                        if addon:GetSetting("buyPigments") and not pigmentCostForCalc then
                            print("|cFF00CCFFQuickCrafts|r: Missing pigment price. Click Refresh and try again.")
                            return
                        end

                        local saleValue = price * outputCount
                        local saleAfterAHCut = saleValue
                        if addon:GetSetting("ahCut") then
                            saleAfterAHCut = math.floor(saleValue * 0.95)
                        end
                        local dyeProfit = saleAfterAHCut - ((pigmentCostForCalc or 0) * pigmentAmount)
                        if dyeProfit <= 0 then
                            print("|cFF00CCFFQuickCrafts|r: Not profitable right now.")
                            return
                        end

                        local ownedPigments = GetItemCount(pigment.itemID, true) or 0
                        local maxCraftable = math.floor(ownedPigments / pigmentAmount)
                        if maxCraftable < 1 then
                            print("|cFF00CCFFQuickCrafts|r: You don't have the pigments for this craft.")
                            return
                        end

                        addon.Crafting:Craft(craftSpec, maxCraftable)
                        return
                    end

                    -- Right-click: prompt Craft X
                    if button == "RightButton" then
                        addon.Crafting:PromptCraftX(craftSpec)
                        return
                    end

                    -- Default: craft 1
                    addon.Crafting:Craft(craftSpec, 1)
                end)
            end

            
            dyeYOffset = dyeYOffset + 24
        end
    else
        dyesHeader:SetText("|cFFDA70D6" .. L(TEXT.SECTION_CRAFTABLE_DYES) .. "|r " .. L(TEXT.SECTION_DYES_NONE))
    end
    
    -- Position herbs section after dyes
    local herbsSectionY = -55 - dyeYOffset - 25
    herbsHeader:ClearAllPoints()
    herbsHeader:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 15, herbsSectionY)
    herbContainer:ClearAllPoints()
    herbContainer:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 15, herbsSectionY - 20)
    
    -- Hide all existing herb rows
    for _, row in pairs(herbRows) do
        if row.frame then row.frame:Hide() end
    end
    
    -- Sort herbs by price (cheapest first)
    local sortedHerbs = {}
    for _, herb in ipairs(pigment.herbs) do
        local priceData = data.herbPrices[herb.itemID]
        table.insert(sortedHerbs, {
            herb = herb,
            price = priceData and priceData.price or nil
        })
    end
    table.sort(sortedHerbs, function(a, b)
        if not a.price then return false end
        if not b.price then return true end
        return a.price < b.price
    end)
    
    -- Create/update herb rows
    local herbYOffset = 0
    for i, herbInfo in ipairs(sortedHerbs) do
        local herb = herbInfo.herb
        local price = herbInfo.price
        local isCheapest = data.cheapestHerb and herb.itemID == data.cheapestHerb.itemID
        
        if not herbRows[i] then
            herbRows[i] = {
                frame = CreateFrame("Frame", nil, herbContainer),
            }
            local row = herbRows[i]
            row.frame:SetSize(420, 22)

            -- tooltips added
            row.frame:EnableMouse(true)
            row.frame:SetHyperlinksEnabled(true)
            row.frame:SetScript("OnHyperlinkEnter", function(self, linkData, link)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(link)
                GameTooltip:Show()
            end)
            row.frame:SetScript("OnHyperlinkLeave", function(self)
                GameTooltip:Hide()
            end)
            row.frame:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
                SetItemRef(link, link, button)
            end)
            
            row.highlight = row.frame:CreateTexture(nil, "BACKGROUND")
            row.highlight:SetAllPoints()
            row.highlight:SetColorTexture(0, 1, 0, 0.15)
            
            row.icon = row.frame:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(18, 18)
            row.icon:SetPoint("LEFT", 5, 0)
            
            row.name = row.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.name:SetPoint("LEFT", 28, 0)
            row.name:SetWidth(280)
            row.name:SetJustifyH("LEFT")
            
            row.price = row.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.price:SetPoint("RIGHT", -5, 0)
            row.price:SetJustifyH("RIGHT")
        end
        
        local row = herbRows[i]
        row.frame:SetPoint("TOPLEFT", herbContainer, "TOPLEFT", 0, -herbYOffset)
        row.frame:Show()
        
        row.icon:SetTexture(addon.PriceSource:GetItemIcon(herb.itemID))
        -- Use item link for hover tooltips
        row.name:SetText(addon.PriceSource:GetItemDisplayText(herb.itemID, herb.name))
        
        if price then
            row.price:SetText(addon.Calculator:FormatGoldCompact(price))
            if isCheapest then
                row.price:SetTextColor(0, 1, 0)
                row.highlight:Show()
            else
                row.price:SetTextColor(1, 1, 1)
                row.highlight:Hide()
            end
        else
            row.price:SetText("|cFF888888N/A|r")
            row.highlight:Hide()
        end
        
        herbYOffset = herbYOffset + 22
    end
    
    -- Position summary section
    local summarySectionY = herbsSectionY - 20 - herbYOffset - 20
    summaryHeader:ClearAllPoints()
    summaryHeader:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 15, summarySectionY)
    
    -- Update summary values
    if data.cheapestHerb then
        local herbDisplay = addon.PriceSource:GetItemDisplayText(data.cheapestHerb.itemID, data.cheapestHerb.name)
        cheapestHerbValue:SetText(herbDisplay .. " @ " .. addon.Calculator:FormatGoldCompact(data.cheapestHerb.price))
    else
        cheapestHerbValue:SetText("|cFF888888" .. L(TEXT.PRICE_NA) .. "|r")
    end
    
    if data.totalCost then
        totalCostValue:SetText(addon.Calculator:FormatGold(data.totalCost))
    else
        totalCostValue:SetText("|cFF888888" .. L(TEXT.PRICE_NA) .. "|r")
    end
    
    if data.bestDye then
        local dyeDisplay = addon.PriceSource:GetItemDisplayText(data.bestDye.itemID, data.bestDye.name)
        bestDyeValue:SetText(dyeDisplay)
        dyeSaleLabel:Show()
        dyeSaleValue:Show()
        if data.dyeSaleAfterCut then
            dyeSaleValue:SetText(addon.Calculator:FormatGold(data.dyeSaleAfterCut))
        else
            dyeSaleValue:SetText("|cFF888888" .. L(TEXT.PRICE_NA) .. "|r")
        end
    else
        bestDyeValue:SetText("|cFF888888" .. L(TEXT.EMPTY_NO_DYES) .. "|r")
        dyeSaleLabel:Hide()
        dyeSaleValue:Hide()
    end
    
    -- Update profit
    local profit = data.dyeProfit or data.profit
    local margin = data.dyeMargin or data.margin
    
    if profit then
        if profit >= 0 then
            profitValue:SetText("|cFF00FF00" .. addon.Calculator:FormatGold(profit) .. "|r")
        else
            profitValue:SetText("|cFFFF0000" .. addon.Calculator:FormatGold(profit) .. "|r")
        end
        
        if margin then
            marginValue:SetText(addon.Calculator:FormatPercent(margin) .. " " .. L(TEXT.MARGIN_SUFFIX))
        else
            marginValue:SetText("")
        end
    else
        profitValue:SetText("|cFF888888" .. L(TEXT.PRICE_NA) .. "|r")
        marginValue:SetText("")
    end
    
    -- Set scroll content height
    local totalHeight = math.abs(summarySectionY) + 180
    detailContent:SetHeight(totalHeight)
end

addon.UI.UpdatePigmentDetailView = UpdatePigmentDetailView

--============================================================================
-- SHOW PIGMENT DETAIL VIEW
--============================================================================

local function ShowPigmentDetailView(pigmentID)
    currentPigmentID = pigmentID
    
    -- Load checkbox(s) states
    buyPigmentsCheck:SetChecked(addon:GetSetting("buyPigments"))

    -- Recalculate data for this pigment
    local pigment = addon:GetPigmentByID(pigmentID)
    if pigment then
        addon.pigmentData[pigmentID] = addon.PigmentCalculator:CalculatePigment(pigment)
    end
    
    -- Hide other frames
    if addon.UI.TransmutesFrame then
        addon.UI.TransmutesFrame:Hide()
    end
    if addon.UI.DetailFrame then
        addon.UI.DetailFrame:Hide()
    end
    PigmentsFrame:Hide()
    
    PigmentDetailFrame:Show()
    UpdatePigmentDetailView()
end

addon.UI.ShowPigmentDetailView = ShowPigmentDetailView
