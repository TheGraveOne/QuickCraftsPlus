--============================================================================
-- QuickCrafts: UI/PigmentsView.lua
-- Pigments view - shows all pigments with cheapest herb info
--============================================================================

local addonName, addon = ...
local L = addon.L
local TEXT = addon.CONST.TEXT

local MainFrame = addon.UI.MainFrame

--============================================================================
-- PIGMENTS FRAME
--============================================================================

local PigmentsFrame = CreateFrame("Frame", nil, MainFrame)
PigmentsFrame:SetAllPoints()
PigmentsFrame:Hide()
addon.UI.PigmentsFrame = PigmentsFrame

--============================================================================
-- OPTIONS ROW (checkbox and refresh button)
--============================================================================

local optionsFrame = CreateFrame("Frame", nil, PigmentsFrame)
optionsFrame:SetSize(490, 30)
optionsFrame:SetPoint("TOP", 0, -25)

-- AH Cut checkbox (shared setting with transmutes)
local ahCutCheck = CreateFrame("CheckButton", "QuickCraftsPigmentAHCut", optionsFrame, "UICheckButtonTemplate")
ahCutCheck:SetPoint("LEFT", 10, 0)
ahCutCheck:SetChecked(true)
addon.UI.pigmentAhCutCheck = ahCutCheck

local ahCutLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
ahCutLabel:SetPoint("LEFT", ahCutCheck, "RIGHT", 2, 0)
ahCutLabel:SetText(L(TEXT.OPT_AH_CUT))

-- Refresh button
local refreshBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
refreshBtn:SetSize(60, 20)
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

local headerFrame = CreateFrame("Frame", nil, PigmentsFrame)
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
-- Align with row data: name starts at 42, herb at 148, dye at 300, profit at 430
local headerName = CreateHeaderButton(headerFrame, 42, L(TEXT.HEADER_PIGMENT), "name")
local headerHerb = CreateHeaderButton(headerFrame, 148, L(TEXT.HEADER_CHEAPEST_HERB), "herb")
local headerDye = CreateHeaderButton(headerFrame, 300, L(TEXT.HEADER_BEST_DYE), "dye")
local headerProfit = CreateHeaderButton(headerFrame, 430, L(TEXT.HEADER_PROFIT), "profit")

local headerSep = PigmentsFrame:CreateTexture(nil, "ARTWORK")
headerSep:SetColorTexture(0.5, 0.5, 0.5, 0.5)
headerSep:SetSize(480, 1)
headerSep:SetPoint("TOP", headerFrame, "BOTTOM", 0, -2)

--============================================================================
-- SORTING FUNCTIONS
--============================================================================

-- Update header visual indicators (arrows and colors)
local function UpdateHeaderIndicators()
    local sortColumn = addon:GetSetting("pigmentSortColumn")
    local sortDirection = addon:GetSetting("pigmentSortDirection")
    
    local headers = {
        name = headerName,
        herb = headerHerb,
        dye = headerDye,
        profit = headerProfit,
    }
    
    -- Sort direction indicators: use simple symbols
    local sortIndicator = (sortDirection == "desc") and " -" or " +"
    
    -- Map column names to TEXT constants
    local textMap = {
        name = TEXT.HEADER_PIGMENT,
        herb = TEXT.HEADER_CHEAPEST_HERB,
        dye = TEXT.HEADER_BEST_DYE,
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

-- Sort pigments by the current sort settings
local function GetSortedPigments()
    local pigments = {}
    
    -- Build table with all pigment data
    for _, pigment in ipairs(addon.Pigments) do
        local data = addon.pigmentData[pigment.id]
        if data then
            table.insert(pigments, {
                pigment = pigment,
                data = data,
            })
        end
    end
    
    -- Get sort settings
    local sortColumn = addon:GetSetting("pigmentSortColumn")
    local sortDirection = addon:GetSetting("pigmentSortDirection")
    local isDesc = (sortDirection == "desc")
    
    -- Sort function
    table.sort(pigments, function(a, b)
        local aVal, bVal
        
        if sortColumn == "name" then
            aVal = a.pigment.name or ""
            bVal = b.pigment.name or ""
        elseif sortColumn == "herb" then
            -- Sort by cheapest herb price
            aVal = (a.data.cheapestHerb and a.data.cheapestHerb.price) or -999999999
            bVal = (b.data.cheapestHerb and b.data.cheapestHerb.price) or -999999999
        elseif sortColumn == "dye" then
            -- Sort by best dye price
            aVal = (a.data.bestDye and a.data.bestDye.price) or -999999999
            bVal = (b.data.bestDye and b.data.bestDye.price) or -999999999
        elseif sortColumn == "profit" then
            -- Sort by dye profit if available, otherwise pigment profit
            aVal = (a.data.dyeProfit or a.data.profit) or -999999999
            bVal = (b.data.dyeProfit or b.data.profit) or -999999999
        else
            -- Default to profit if unknown
            aVal = (a.data.dyeProfit or a.data.profit) or -999999999
            bVal = (b.data.dyeProfit or b.data.profit) or -999999999
        end
        
        if isDesc then
            return aVal > bVal
        else
            return aVal < bVal
        end
    end)
    
    return pigments
end

-- Handle header click to change sort
local function OnHeaderClick(column)
    local currentColumn = addon:GetSetting("pigmentSortColumn")
    local currentDirection = addon:GetSetting("pigmentSortDirection")
    
    if currentColumn == column then
        -- Toggle direction if clicking same column
        local newDirection = (currentDirection == "desc") and "asc" or "desc"
        addon:SetSetting("pigmentSortDirection", newDirection)
    else
        -- Set new column and default to desc
        addon:SetSetting("pigmentSortColumn", column)
        addon:SetSetting("pigmentSortDirection", "desc")
    end
    
    -- Force recalculation and refresh view - use the function reference directly
    if addon.PigmentCalculator and addon.PigmentCalculator.CalculateAllPigments then
        addon.PigmentCalculator:CalculateAllPigments()
    end
    -- Call UpdatePigmentsView after it's defined (it will be in scope when clicked)
end

-- Store OnHeaderClick for later use after UpdatePigmentsView is defined
local function SetupHeaderClickHandlers()
    local function RefreshView()
        if addon.UI.UpdatePigmentsView then
            addon.UI.UpdatePigmentsView()
        end
    end
    
    headerName:SetScript("OnClick", function(self, button)
        OnHeaderClick("name")
        RefreshView()
    end)
    headerHerb:SetScript("OnClick", function(self, button)
        OnHeaderClick("herb")
        RefreshView()
    end)
    headerDye:SetScript("OnClick", function(self, button)
        OnHeaderClick("dye")
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
-- SCROLL FRAME FOR PIGMENT ROWS
--============================================================================

local scrollFrame = CreateFrame("ScrollFrame", nil, PigmentsFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(470, 330)  -- Wider and account for bottom tabs
scrollFrame:SetPoint("TOP", headerSep, "BOTTOM", -10, -5)

local scrollContent = CreateFrame("Frame", nil, scrollFrame)
scrollContent:SetSize(450, 1) -- Height will be set dynamically
scrollFrame:SetScrollChild(scrollContent)

--============================================================================
-- PIGMENT ROWS
--============================================================================

local pigmentRows = {}
addon.UI.pigmentRows = pigmentRows

-- Create a single pigment row
local function CreatePigmentRow(index, pigment)
    local row = CreateFrame("Button", nil, scrollContent)
    row:SetSize(460, 40)
    row:SetPoint("TOP", scrollContent, "TOP", 0, -((index - 1) * 42))
    
    -- Highlight on hover
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Pigment icon
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(28, 28)
    row.icon:SetPoint("LEFT", 8, 0)
    
    -- Pigment name
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.nameText:SetPoint("LEFT", 42, 0)
    row.nameText:SetWidth(100)
    row.nameText:SetJustifyH("LEFT")
    -- Shorten name: "Brown Dye Pigment" -> "Brown"
    local shortName = pigment.name:gsub(" Dye Pigment", "")
    row.nameText:SetText(shortName)
    
    -- Cheapest herb icon
    row.herbIcon = row:CreateTexture(nil, "ARTWORK")
    row.herbIcon:SetSize(20, 20)
    row.herbIcon:SetPoint("LEFT", 148, 0)
    
    -- Cheapest herb name and price
    row.herbText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.herbText:SetPoint("LEFT", 172, 5)
    row.herbText:SetWidth(120)
    row.herbText:SetJustifyH("LEFT")
    row.herbText:SetText("...")
    
    -- Herb price per unit
    row.herbPriceText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.herbPriceText:SetPoint("LEFT", 172, -7)
    row.herbPriceText:SetWidth(120)
    row.herbPriceText:SetJustifyH("LEFT")
    row.herbPriceText:SetTextColor(0.7, 0.7, 0.7)
    row.herbPriceText:SetText("")
    
    -- Best dye icon
    row.dyeIcon = row:CreateTexture(nil, "ARTWORK")
    row.dyeIcon:SetSize(20, 20)
    row.dyeIcon:SetPoint("LEFT", 300, 0)
    
    -- Best dye name
    row.dyeText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.dyeText:SetPoint("LEFT", 324, 5)
    row.dyeText:SetWidth(100)
    row.dyeText:SetJustifyH("LEFT")
    row.dyeText:SetText("...")
    
    -- Best dye price
    row.dyePriceText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.dyePriceText:SetPoint("LEFT", 324, -7)
    row.dyePriceText:SetWidth(100)
    row.dyePriceText:SetJustifyH("LEFT")
    row.dyePriceText:SetTextColor(0.7, 0.7, 0.7)
    row.dyePriceText:SetText("")
    
    -- Profit (now shows dye profit if available, otherwise pigment profit)
    row.profitText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.profitText:SetPoint("LEFT", 430, 0)
    row.profitText:SetWidth(60)
    row.profitText:SetJustifyH("LEFT")
    row.profitText:SetText("...")
    
    -- Click to view details
    row:SetScript("OnClick", function()
        addon.UI.ShowPigmentDetailView(pigment.id)
    end)
    
    -- Tooltip on hover
    row:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(pigment.name, 1, 0.82, 0)
        GameTooltip:AddLine(string.format(L(TEXT.REQUIRES_HERBS), pigment.herbCost or 10), 1, 1, 1)
        
        local data = addon.pigmentData[pigment.id]
        if data then
            if data.cheapestHerb then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L(TEXT.CHEAPEST_HERB_LABEL), 0.5, 1, 0.5)
                GameTooltip:AddDoubleLine("  " .. data.cheapestHerb.name, 
                    addon.Calculator:FormatGoldCompact(data.cheapestHerb.price) .. " each", 
                    1, 1, 1, 1, 1, 1)
            end
            
            if data.bestDye then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L(TEXT.BEST_DYE_LABEL), 1, 0.5, 1)
                GameTooltip:AddDoubleLine("  " .. data.bestDye.name,
                    addon.Calculator:FormatGoldCompact(data.bestDye.price),
                    1, 1, 1, 1, 1, 1)
                if data.dyeProfit then
                    GameTooltip:AddDoubleLine("  " .. L(TEXT.PROFIT_LABEL),
                        addon.Calculator:FormatProfit(data.dyeProfit),
                        0.7, 0.7, 0.7, 1, 1, 1)
                end
            end
        end
        
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L(TEXT.CLICK_FOR_DETAILS), 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    
    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    row.pigment = pigment
    return row
end

-- Initialize all pigment rows
local function InitializePigmentRows()
    for i, pigment in ipairs(addon.Pigments) do
        pigmentRows[pigment.id] = CreatePigmentRow(i, pigment)
    end
    
    -- Set scroll content height
    local totalHeight = #addon.Pigments * 42
    scrollContent:SetHeight(math.max(totalHeight, 1))
end

--============================================================================
-- STATUS TEXT
--============================================================================

local statusText = PigmentsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
--statusText:SetPoint("BOTTOM", 0, 50)
statusText:SetTextColor(0.7, 0.7, 0.7)
statusText:SetText("")
addon.UI.pigmentStatusText = statusText

--============================================================================
-- EMPTY STATE MESSAGE
--============================================================================

local emptyText = PigmentsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
emptyText:SetPoint("CENTER", 0, 0)
emptyText:SetTextColor(0.6, 0.6, 0.6)
emptyText:SetText(L(TEXT.EMPTY_PIGMENTS))
emptyText:Hide()
addon.UI.pigmentEmptyText = emptyText

--============================================================================
-- UPDATE FUNCTION
--============================================================================

local function UpdatePigmentsView()
    -- Check if we have any pigments
    if #addon.Pigments == 0 then
        emptyText:Show()
        scrollFrame:Hide()
        headerFrame:Hide()
        headerSep:Hide()
        statusText:SetText("")
        return
    else
        emptyText:Hide()
        scrollFrame:Show()
        headerFrame:Show()
        headerSep:Show()
    end
    
    -- Check if price source is available
    local available, sourceName = addon.PriceSource:IsAvailable()
    if not available then
        statusText:SetText("|cFFFF0000" .. L(TEXT.STATUS_AUCTIONATOR_NOT_DETECTED) .. "|r")
        return
    end
    
    statusText:SetText("")
    
    -- Calculate all pigments
    addon.PigmentCalculator:CalculateAllPigments()
    
    -- Get sorted pigments
    local sortedPigments = GetSortedPigments()
    
    -- Update header indicators
    UpdateHeaderIndicators()
    
    -- Update each row based on sorted order
    for index, item in ipairs(sortedPigments) do
        local pigment = item.pigment
        local data = item.data
        local row = pigmentRows[pigment.id]
        
        if row and data then
            -- Reposition row based on sort order
            row:ClearAllPoints()
            row:SetPoint("TOP", scrollContent, "TOP", 0, -((index - 1) * 42))
            -- Update pigment icon
            row.icon:SetTexture(addon.PriceSource:GetItemIcon(pigment.itemID))
            
            -- Update cheapest herb info
            if data.cheapestHerb then
                row.herbIcon:SetTexture(addon.PriceSource:GetItemIcon(data.cheapestHerb.itemID))
                row.herbIcon:Show()
                -- Shorten herb name if needed
                local herbName = data.cheapestHerb.name
                if #herbName > 12 then
                    herbName = herbName:sub(1, 11) .. "..."
                end
                row.herbText:SetText(herbName)
                row.herbPriceText:SetText(addon.Calculator:FormatGoldCompact(data.cheapestHerb.price) .. " " .. L(TEXT.EACH_ABBREV))
            else
                row.herbIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                row.herbText:SetText("|cFFFF0000" .. L(TEXT.STATUS_NO_PRICES) .. "|r")
                row.herbPriceText:SetText("")
            end
            
            -- Update best dye info
            if data.bestDye then
                row.dyeIcon:SetTexture(addon.PriceSource:GetItemIcon(data.bestDye.itemID))
                row.dyeIcon:Show()
                -- Shorten dye name - remove "Dye" suffix
                local dyeName = data.bestDye.name:gsub(" Dye$", "")
                if #dyeName > 10 then
                    dyeName = dyeName:sub(1, 9) .. "..."
                end
                row.dyeText:SetText(dyeName)
                row.dyePriceText:SetText(addon.Calculator:FormatGoldCompact(data.bestDye.price))
            else
                row.dyeIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                row.dyeIcon:Hide()
                row.dyeText:SetText("|cFF888888N/A|r")
                row.dyePriceText:SetText("")
            end
            
            -- Update profit - show dye profit if available, otherwise pigment profit
            if data.dyeProfit then
                row.profitText:SetText(addon.Calculator:FormatProfit(data.dyeProfit))
            else
                row.profitText:SetText(addon.Calculator:FormatProfit(data.profit))
            end
        end
    end
    
    -- Update scroll content height
    local totalHeight = #sortedPigments * 42
    scrollContent:SetHeight(math.max(totalHeight, 1))
    
    statusText:SetText(string.format(L(TEXT.STATUS_UPDATED), date("%H:%M:%S")))
end

addon.UI.UpdatePigmentsView = UpdatePigmentsView

--============================================================================
-- EVENT HANDLERS
--============================================================================

refreshBtn:SetScript("OnClick", function()
    UpdatePigmentsView()
    if addon.UI.PigmentDetailFrame and addon.UI.PigmentDetailFrame:IsShown() then
        addon.UI.UpdatePigmentDetailView()
    end
end)

ahCutCheck:SetScript("OnClick", function(self)
    addon:SetSetting("ahCut", self:GetChecked())
    -- Sync with other checkboxes
    if addon.UI.ahCutCheck then
        addon.UI.ahCutCheck:SetChecked(self:GetChecked())
    end
    UpdatePigmentsView()
    addon.UI.UpdatePigmentsView()
end)

--============================================================================
-- INITIALIZATION
--============================================================================

-- Defer initialization until after ADDON_LOADED
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2.5, function()
            InitializePigmentRows()
            -- Initialize header indicators on load
            UpdateHeaderIndicators()
        end)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
