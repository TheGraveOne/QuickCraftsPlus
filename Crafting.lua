--============================================================================
-- QuickCrafts: Crafting.lua
-- Profession-agnostic crafting helpers (Retail) for selecting/crafting recipes.
--
-- Design goals:
--  * Best-effort + safe: user should open the relevant profession/crafting UI.
--  * Works for ANY recipe type available via C_TradeSkillUI (Alchemy, Inscription,
--    player housing dyes, etc.)
--  * Accepts either a recipeID directly OR can resolve a recipeID by output itemID
--    (and optionally name) from the currently open profession.
--============================================================================

local addonName, addon = ...

addon.Crafting = addon.Crafting or {}

local function qcPrint(msg)
    print("|cFF00CCFFQuickCraftsPlus|r: " .. tostring(msg))
end

-- Debug logging (disabled by default). Toggle with: /run QuickCraftsPlusDB.debug=true
local function qcDebug(...)
    if _G.QuickCraftsPlusDB and _G.QuickCraftsPlusDB.debug then
        print(...)
    end
end

local function isTradeSkillReady()
    if not C_TradeSkillUI then return false end
    if C_TradeSkillUI.IsTradeSkillReady then
        return C_TradeSkillUI.IsTradeSkillReady()
    end
    return false
end

function addon.Crafting:IsAvailable()
    return C_TradeSkillUI
        and C_TradeSkillUI.GetAllRecipeIDs
        and C_TradeSkillUI.GetRecipeInfo
        and C_TradeSkillUI.CraftRecipe
end

local function getItemIDFromLink(link)
    if not link then return nil end
    local itemID = link:match("item:(%d+)")
    if itemID then return tonumber(itemID) end
    return nil
end

-- Cache outputItemID -> recipeID for the currently open profession.
addon.Crafting._outputToRecipeID = addon.Crafting._outputToRecipeID or {}

function addon.Crafting:ClearCache()
    wipe(self._outputToRecipeID)
end

function addon.Crafting:EnsureReadyOrWarn()
    if not self:IsAvailable() then
        qcPrint("Crafting API not available on this client.")
        return false
    end
    if not isTradeSkillReady() then
        qcPrint("Open the relevant profession/crafting window first, then try again.")
        return false
    end
    return true
end

function addon.Crafting:SelectRecipeID(recipeID)
    if not recipeID then return false end
    if C_TradeSkillUI.SetRecipeID then
        C_TradeSkillUI.SetRecipeID(recipeID)
        return true
    end
    if TradeSkillFrame and TradeSkillFrame.RecipeList and TradeSkillFrame.RecipeList.SelectRecipe then
        pcall(function() TradeSkillFrame.RecipeList:SelectRecipe(recipeID) end)
        return true
    end
    return false
end

-- Best-effort: resolve a recipeID in the CURRENTLY OPEN profession by output itemID.
function addon.Crafting:FindRecipeIDByOutputItemID(outputItemID)
    if not self:IsAvailable() then return nil end
    outputItemID = tonumber(outputItemID)
    if not outputItemID then return nil end

    if self._outputToRecipeID[outputItemID] then
        return self._outputToRecipeID[outputItemID]
    end

    if not C_TradeSkillUI.GetRecipeOutputItemData then
        return nil
    end

    local all = C_TradeSkillUI.GetAllRecipeIDs()
    if not all then return nil end

    for _, recipeID in ipairs(all) do
        local out = C_TradeSkillUI.GetRecipeOutputItemData(recipeID)
        if out then
            -- Depending on the recipe type, output data may include:
            --  * out.itemID (preferred)
            --  * out.hyperlink (fallback)
            local outItemID = tonumber(out.itemID) or getItemIDFromLink(out.hyperlink)
            if outItemID == outputItemID then
                self._outputToRecipeID[outputItemID] = recipeID
                return recipeID
            end
        end
    end

    return nil
end

-- Resolve recipeID from a "recipe spec".
-- Supported shapes:
--  * { recipeID = 123 }
--  * { outputItemID = 12345 }
--  * QuickCrafts recipe tables: { name=..., product={itemID=...}, ... }
function addon.Crafting:ResolveRecipeID(spec)
    if type(spec) ~= "table" then return nil end

    if spec.recipeID then
        return spec.recipeID
    end

    -- Prefer explicit outputItemID when present.
    -- Support multiple table shapes used across the addon:
    --  * Transmutes recipes: { product = { itemID = ... } }
    --  * Dyes entries:       { itemID = ... }
    --  * Generic:            { outputItemID = ... }
    local outputItemID = spec.outputItemID or spec.itemID
    if not outputItemID and spec.product and spec.product.itemID then
        outputItemID = spec.product.itemID
    end
    if outputItemID then
        local rid = self:FindRecipeIDByOutputItemID(outputItemID)
        if rid then return rid end
    end

    -- Fallback: match by name within the currently open profession.
    if spec.name then
        local all = C_TradeSkillUI.GetAllRecipeIDs()
        if all then
            for _, recipeID in ipairs(all) do
                local info = C_TradeSkillUI.GetRecipeInfo(recipeID)
                if info and info.name == spec.name then
                    return recipeID
                end
            end
        end
    end

    return nil
end

function addon.Crafting:OpenRecipe(spec)
    if not self:EnsureReadyOrWarn() then return false end

    local recipeID = self:ResolveRecipeID(spec)
    if not recipeID then
        qcPrint("Couldn't find that recipe in the currently open profession window.")
        return false
    end

    self:SelectRecipeID(recipeID)
    return true
end

function addon.Crafting:Craft(spec, quantity)
    qcDebug(
        "QC Craft called",
        "quantity=", quantity,
        "specItem=", spec and (spec.recipeID or spec.itemID or (spec.product and spec.product.itemID)) or "nil"
    )

    if not self:EnsureReadyOrWarn() then
        qcDebug("QC Craft aborted: EnsureReadyOrWarn failed")
        return false
    end

    quantity = tonumber(quantity) or 1
    if quantity < 1 then quantity = 1 end

    qcDebug("QC Craft normalized quantity=", quantity)

    local recipeID = self:ResolveRecipeID(spec)
    qcDebug("QC Craft resolved recipeID=", recipeID)

    if not recipeID then
        qcPrint("Couldn't find that recipe in the currently open profession window.")
        return false
    end

    -- Select first so the player sees what's being crafted.
    self:SelectRecipeID(recipeID)

    qcDebug("QC Craft calling C_TradeSkillUI.CraftRecipe", recipeID, quantity)

    local ok, err = pcall(function()
        C_TradeSkillUI.CraftRecipe(recipeID, quantity)
    end)
    if not ok then
        qcPrint("Craft failed: " .. tostring(err))
        qcDebug("QC Craft pcall error:", err)
        return false
    end

    qcDebug("QC Craft success")
    
    -- Refresh UI after a short delay to allow inventory to update
    C_Timer.After(0.3, function()
        if addon.UI and addon.UI.currentTab then
            if addon.UI.currentTab == "pigments" then
                if addon.UI.UpdatePigmentsView then
                    addon.UI.UpdatePigmentsView()
                end
                if addon.UI.UpdatePigmentDetailView then
                    addon.UI.UpdatePigmentDetailView()
                end
            elseif addon.UI.currentTab == "transmutes" then
                if addon.UI.UpdateTransmutesView then
                    addon.UI.UpdateTransmutesView()
                end
                if addon.UI.UpdateDetailView then
                    addon.UI.UpdateDetailView()
                end
            end
        end
    end)
    
    return true
end

--============================================================================
-- Craft X popup
--============================================================================

if not StaticPopupDialogs then
    qcPrint("StaticPopupDialogs not available.")
    return
end

StaticPopupDialogs["QUICKCRAFTS_CRAFT_X"] = {
    text = "Craft how many?",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    editBoxWidth = 64,
    maxLetters = 4,

    OnShow = function(self)
        -- StaticPopup handlers can be invoked with `self` not being the dialog frame on some clients.
        -- Prefer the visible dialog for our popup "which".
        local dialog = (StaticPopup_FindVisible and StaticPopup_FindVisible("QUICKCRAFTS_CRAFT_X")) or self
        if dialog and not dialog.editBox and dialog.GetParent then
            dialog = dialog:GetParent()
        end

        -- Find the edit box robustly.
        local eb = (dialog and dialog.editBox)
        if not eb and dialog and dialog.GetName then
            eb = _G[dialog:GetName() .. "EditBox"]
        end
        if not eb then
            -- Fallback: scan common StaticPopup frames.
            for i = 1, 4 do
                local frame = _G["StaticPopup" .. i]
                local edit = _G["StaticPopup" .. i .. "EditBox"]
                if frame and frame.which == "QUICKCRAFTS_CRAFT_X" and edit then
                    dialog = frame
                    eb = edit
                    break
                end
            end
        end

        if not eb then
            qcDebug("QC OnShow: could not find edit box")
            return
        end

        eb:SetText("1")
        eb:HighlightText()
        eb:SetFocus()
    end,

    OnAccept = function(self, data)
        local dialog = (StaticPopup_FindVisible and StaticPopup_FindVisible("QUICKCRAFTS_CRAFT_X")) or self
        if dialog and not dialog.editBox and dialog.GetParent then
            dialog = dialog:GetParent()
        end

        -- Find edit box robustly.
        local eb = (dialog and dialog.editBox)
        if not eb and dialog and dialog.GetName then
            eb = _G[dialog:GetName() .. "EditBox"]
        end
        if not eb then
            for i = 1, 4 do
                local frame = _G["StaticPopup" .. i]
                local edit = _G["StaticPopup" .. i .. "EditBox"]
                if frame and frame.which == "QUICKCRAFTS_CRAFT_X" and edit then
                    dialog = frame
                    eb = edit
                    break
                end
            end
        end

        local qtyText = eb and eb:GetText() or ""
        local qty = tonumber(qtyText)
        local spec = data

        qcDebug("QC OnAccept fired", "qtyText=", tostring(qtyText), "qty=", qty, "hasData=", spec and "yes" or "no")

        if not (qty and qty > 0) then
            qcDebug("QC OnAccept: invalid qty")
            return
        end
        if not spec then
            qcDebug("QC OnAccept: spec is nil (popup data missing)")
            return
        end

        qcDebug("QC OnAccept: calling Craft() now")
        addon.Crafting:Craft(spec, math.floor(qty))
    end,

    EditBoxOnEnterPressed = function(self)
        self:GetParent().button1:Click()
    end,

    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function addon.Crafting:PromptCraftX(spec)
    qcDebug("QC PromptCraftX called. spec=", spec and "yes" or "no")

    local dialog = StaticPopup_Show("QUICKCRAFTS_CRAFT_X", nil, nil, spec)
    qcDebug("QC PromptCraftX StaticPopup_Show returned", dialog and "dialog" or "nil")
end
