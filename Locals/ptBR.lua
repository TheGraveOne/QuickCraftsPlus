--============================================================================
-- QuickCrafts: Locals/enUS.lua
-- localization for Portuguese
--============================================================================

local addonName, addon = ...

addon.LOCAL_PT = {}

function addon.LOCAL_PT:GetData()
    local TEXT = addon.CONST.TEXT
    
return {
        --====================================================================
        -- STARTUP MESSAGES
        --====================================================================
        
        [TEXT.ADDON_LOADED] = "%s v%s loaded! Price source: %s. Type /calc to open.",
        [TEXT.ADDON_LOADED_NO_PRICE] = "%s v%s loaded! Warning: Auctionator not detected.",

        --====================================================================
        -- SLASH COMMANDS/HELP MENU
        --====================================================================
        
        [TEXT.HELP_TITLE] = "QuickCrafts Commands:",
        [TEXT.HELP_CMD_CALC] = "/calc - Toggle the calculator window",
        [TEXT.HELP_CMD_HELP] = "/calc help - Show this help message",

        --====================================================================
        -- MAIN TITLE (not sure if this one should be translated)
        --====================================================================
        
        [TEXT.WINDOW_TITLE] = "QuickCrafts",

        --====================================================================
        -- TAB NAMES
        --====================================================================
        
        [TEXT.TAB_PIGMENTS] = "Pigments",
        [TEXT.TAB_TRANSMUTES] = "Transmutes",

        --====================================================================
        -- OPTIONS ON MAIN PAGE
        --====================================================================
        
        [TEXT.OPT_AH_CUT] = "5% AH Cut",
        [TEXT.OPT_TRANSMUTE_MASTER] = "Transmute Master",
        [TEXT.BTN_REFRESH] = "Refresh",

        --====================================================================
        -- REFRESH TOOLTIPS
        --====================================================================
        
        [TEXT.REFRESH_TOOLTIP_TITLE] = "Refresh Prices",
        [TEXT.REFRESH_TOOLTIP_DESC] = "Updates prices using last scan from Auctionator.",
        [TEXT.REFRESH_TOOLTIP_HINT] = "Scan AH using Auctionator FIRST, or go into detailed view to do a scan",

        --====================================================================
        -- COLUMN HEADERS ON MAIN PAGE (TRANSMUTES)
        --====================================================================
        
        [TEXT.HEADER_RECIPE] = "Recipe",
        [TEXT.HEADER_COST] = "Cost",
        [TEXT.HEADER_SELL] = "Sell",
        [TEXT.HEADER_PROFIT] = "Profit",

        --====================================================================
        -- COLUMN HEADERS ON MAIN PAGE (PIGMENTS)
        --====================================================================
        
        [TEXT.HEADER_PIGMENT] = "Pigment",
        [TEXT.HEADER_CHEAPEST_HERB] = "Cheapest Herb",
        [TEXT.HEADER_BEST_DYE] = "Best Dye",

        --====================================================================
        -- ROW TOOLTIPS ON MAIN PAGE (PIGMENTS)
        --====================================================================
        
        [TEXT.CLICK_FOR_DETAILS] = "Click for detailed breakdown",
        [TEXT.REQUIRES_HERBS] = "Requires %d herbs",
        [TEXT.CHEAPEST_HERB_LABEL] = "Cheapest herb:",
        [TEXT.BEST_DYE_LABEL] = "Best dye to craft:",
        [TEXT.PROFIT_LABEL] = "Profit:",

        --====================================================================
        -- BUTTONS ON DETAIL VIEWS
        --====================================================================
        
        [TEXT.BTN_BACK] = "< Back",
        [TEXT.BTN_SEARCH_AH] = "Search AH",

        --====================================================================
        -- SEARCH TOOLTIPS ON DETAIL VIEWS
        --====================================================================
        
        [TEXT.SEARCH_AH_TOOLTIP_TITLE] = "Search Auction House",
        [TEXT.SEARCH_AH_TOOLTIP_DESC] = "Opens Auctionator and searches for",
        [TEXT.SEARCH_AH_TOOLTIP_DESC2] = "all materials + the product.",
        [TEXT.SEARCH_AH_MUST_OPEN] = "Auction House must be open!",
        [TEXT.SEARCH_AH_READY] = "Auction House is open - ready!",

        --====================================================================
        -- PIGMENTS DETAIL VIEW TOOLTIP
        --====================================================================
        
        [TEXT.SEARCH_AH_PIGMENT_DESC] = "Searches for herbs, pigment, and dyes.",

        --====================================================================
        -- TRANSMUTE DETAIL VIEWS SECTIONS
        --====================================================================
        
        [TEXT.SECTION_MATERIALS] = "Materials",
        [TEXT.SECTION_PRODUCT] = "Product",

        --====================================================================
        -- SUMMARY ON TRANSMUTE DETAIL VIEW
        --====================================================================
        
        [TEXT.TOTAL_MATERIAL_COST] = "Total Material Cost:",
        [TEXT.EFFECTIVE_COST_MASTERY] = "Effective Cost (w/ Mastery):",
        [TEXT.SALE_AFTER_CUT] = "Sale (after AH cut):",
        [TEXT.PROFIT_COLON] = "PROFIT:",
        [TEXT.MARGIN_SUFFIX] = "margin",

        --====================================================================
        -- PIGMENTS DETAIL VIEW SECTIONS
        --====================================================================
        
        [TEXT.SECTION_CRAFTABLE_DYES] = "Craftable Dyes",
        [TEXT.SECTION_DYES_HIGHLIGHT] = "(most expensive highlighted)",
        [TEXT.SECTION_DYES_NONE] = "(none defined)",
        [TEXT.SECTION_AVAILABLE_HERBS] = "Available Herbs",
        [TEXT.SECTION_HERBS_HIGHLIGHT] = "(cheapest highlighted)",
        [TEXT.SECTION_SUMMARY] = "Summary",

        --====================================================================
        -- SUMMARY ON PIGMENTS DETAIL VIEW
        --====================================================================
        
        [TEXT.CHEAPEST_HERB] = "Cheapest Herb:",
        [TEXT.COST_HERBS] = "Cost (10 herbs):",
        [TEXT.BEST_DYE] = "Best Dye:",
        [TEXT.DYE_SALE] = "Dye Sale (after cut):",

        --====================================================================
        -- STATUS MESSAGES
        --====================================================================
        
        [TEXT.STATUS_AUCTIONATOR_NOT_DETECTED] = "Auctionator not detected!",
        [TEXT.STATUS_UPDATED] = "Updated: %s",
        [TEXT.STATUS_NO_PRICES] = "No prices",
        [TEXT.STATUS_NO_DATA] = "No data",

        --====================================================================
        -- EMPTY MESSAGES
        --====================================================================
        
        [TEXT.EMPTY_PIGMENTS] = "No pigments defined yet.\nEdit Pigments.lua to add pigment data.",
        [TEXT.EMPTY_NO_DYES] = "No dyes defined",

        --====================================================================
        -- ERROR MESSAGES
        --====================================================================
        
        [TEXT.ERR_ITEM_NAMES_NOT_LOADED] = "Item names not loaded yet - try again",
        [TEXT.ERR_AH_MUST_BE_OPEN] = "Auction House must be open to search",
        [TEXT.ERR_SEARCH_API_NOT_AVAILABLE] = "Search API not available",
        [TEXT.ERR_ITEM_NAME_NOT_LOADED] = "Item name not loaded",
        [TEXT.ERR_NO_SEARCH_METHOD] = "No search method available",
        [TEXT.ERR_SEARCH_FAILED] = "Search failed: %s",

        --====================================================================
        -- PRICE FORMATTING ISSUES
        --====================================================================
        
        [TEXT.PRICE_NA] = "N/A",
        [TEXT.UNKNOWN_ITEM] = "Unknown Item",

        --====================================================================
        -- EXTRAS
        --====================================================================
        
        [TEXT.EACH_ABBREV] = "each",
    }
end
