--============================================================================
-- QuickCrafts: UI/MainFrame.lua
-- Main window frame and shared UI elements
--============================================================================

local addonName, addon = ...
local L = addon.L
local TEXT = addon.CONST.TEXT

--============================================================================
-- MAIN FRAME CREATION
--============================================================================

local MainFrame = CreateFrame("Frame", "QuickCraftsFrame", UIParent, "BackdropTemplate")
MainFrame:SetFrameStrata("HIGH") -- setting frame to high to show above other panels
MainFrame:SetSize(530, 520)
MainFrame:SetPoint("CENTER")
MainFrame:SetMovable(true)
MainFrame:EnableMouse(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)
MainFrame:SetClampedToScreen(true)
MainFrame:Hide()

-- Store reference in addon namespace
addon.UI.MainFrame = MainFrame

-- Set backdrop (background and border)
MainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

--============================================================================
-- TITLE BAR
--============================================================================

local titleBg = MainFrame:CreateTexture(nil, "ARTWORK")
titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
titleBg:SetSize(280, 64)
titleBg:SetPoint("TOP", 0, 12)

local titleText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("TOP", 0, 0)
titleText:SetText(L(TEXT.WINDOW_TITLE))
titleText:SetTextColor(1, 0.82, 0)

addon.UI.TitleText = titleText

--============================================================================
-- CLOSE BUTTON
--============================================================================

local closeBtn = CreateFrame("Button", nil, MainFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function() 
    MainFrame:Hide() 
end)

--============================================================================
-- TAB BUTTONS
--============================================================================

local currentTab = "pigments"
addon.UI.currentTab = currentTab

local function CreateTab(name, displayText, xOffset)
    local tab = CreateFrame("Button", nil, MainFrame, "BackdropTemplate")
    tab:SetSize(130, 30)
    tab:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", xOffset, 12)
    
    -- Tab background
    tab:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    
    -- Tab text
    tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tab.text:SetPoint("CENTER", 0, 0)
    tab.text:SetText(displayText)
    
    -- Store the tab name
    tab.tabName = name
    
    -- Hover effect
    tab:SetScript("OnEnter", function(self)
        if currentTab ~= self.tabName then
            self:SetBackdropColor(0.3, 0.3, 0.4, 1)
        end
    end)
    
    tab:SetScript("OnLeave", function(self)
        if currentTab ~= self.tabName then
            self:SetBackdropColor(0.15, 0.15, 0.2, 1)
        end
    end)
    
    return tab
end

local pigmentsTab = CreateTab("pigments", L(TEXT.TAB_PIGMENTS), 20)
local transmuteTab = CreateTab("transmutes", L(TEXT.TAB_TRANSMUTES), 155)

addon.UI.transmuteTab = transmuteTab
addon.UI.pigmentsTab = pigmentsTab

local function UpdateTabAppearance()
    if currentTab == "transmutes" then
        transmuteTab:SetBackdropColor(0.2, 0.2, 0.3, 1)
        transmuteTab.text:SetTextColor(1, 0.82, 0)
        pigmentsTab:SetBackdropColor(0.15, 0.15, 0.2, 1)
        pigmentsTab.text:SetTextColor(0.6, 0.6, 0.6)
    else
        pigmentsTab:SetBackdropColor(0.2, 0.2, 0.3, 1)
        pigmentsTab.text:SetTextColor(1, 0.82, 0)
        transmuteTab:SetBackdropColor(0.15, 0.15, 0.2, 1)
        transmuteTab.text:SetTextColor(0.6, 0.6, 0.6)
    end
end

--============================================================================
-- TAB SELECTION FUNCTION
--============================================================================

local function SelectTab(tabName)
    currentTab = tabName
    addon.UI.currentTab = tabName
    
    -- Update tab visuals
    UpdateTabAppearance()
    
    -- Hide all content frames
    if addon.UI.TransmutesFrame then addon.UI.TransmutesFrame:Hide() end
    if addon.UI.DetailFrame then addon.UI.DetailFrame:Hide() end
    if addon.UI.PigmentsFrame then addon.UI.PigmentsFrame:Hide() end
    if addon.UI.PigmentDetailFrame then addon.UI.PigmentDetailFrame:Hide() end
    
    if tabName == "transmutes" then
        -- Show transmutes screen
        if addon.UI.TransmutesFrame then
            addon.UI.TransmutesFrame:Show()
            if addon.UI.UpdateTransmutesView then
                addon.UI.UpdateTransmutesView()
            end
        end
    elseif tabName == "pigments" then
        -- Show pigments screen
        if addon.UI.PigmentsFrame then
            addon.UI.PigmentsFrame:Show()
            if addon.UI.UpdatePigmentsView then
                addon.UI.UpdatePigmentsView()
            end
        end
    end
end

addon.UI.SelectTab = SelectTab

-- Tab click handlers
transmuteTab:SetScript("OnClick", function()
    SelectTab("transmutes")
end)

pigmentsTab:SetScript("OnClick", function()
    SelectTab("pigments")
end)

-- Initialize tab appearance
UpdateTabAppearance()

--============================================================================
-- KEYBOARD HANDLING
--============================================================================

MainFrame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        -- Check which view is showing and handle accordingly
        if addon.UI.PigmentDetailFrame and addon.UI.PigmentDetailFrame:IsShown() then
            addon.UI.PigmentDetailFrame:Hide()
            if addon.UI.PigmentsFrame then
                addon.UI.PigmentsFrame:Show()
            end
        elseif addon.UI.DetailFrame and addon.UI.DetailFrame:IsShown() then
            addon.UI.DetailFrame:Hide()
            if addon.UI.TransmutesFrame then
                addon.UI.TransmutesFrame:Show()
            end
        else
            self:Hide()
        end
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end)

--============================================================================
-- SHOW/HIDE HANDLERS
--============================================================================

MainFrame:SetScript("OnShow", function(self)
    -- Also raising frame incase "HIGH" strata does not work 
    self:Raise()
    -- Load settings into checkboxes
    if addon.UI.ahCutCheck then
        addon.UI.ahCutCheck:SetChecked(addon:GetSetting("ahCut"))
    end
    if addon.UI.pigmentAhCutCheck then
        addon.UI.pigmentAhCutCheck:SetChecked(addon:GetSetting("ahCut"))
    end
    if addon.UI.masteryCheck then
        addon.UI.masteryCheck:SetChecked(addon:GetSetting("mastery"))
    end
    
    -- Update tab appearance
    UpdateTabAppearance()
    
    -- Select the current tab
    SelectTab(currentTab)
end)

--============================================================================
-- PUBLIC FUNCTIONS
--============================================================================

-- Toggle the main frame visibility
function addon.UI:Toggle()
    if MainFrame:IsShown() then
        MainFrame:Hide()
    else
        MainFrame:Show()
    end
end

-- Show the main frame
function addon.UI:Show()
    MainFrame:Show()
end

-- Hide the main frame
function addon.UI:Hide()
    MainFrame:Hide()
end

-- Check if main frame is shown
function addon.UI:IsShown()
    return MainFrame:IsShown()
end
