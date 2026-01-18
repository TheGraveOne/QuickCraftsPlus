--============================================================================
-- QuickCrafts: Constants.lua
-- Constant definitions for localization keys and other shared values
--============================================================================

local addonName, addon = ...

addon.CONST = {}

--============================================================================
-- LOCALIZATION TEXT IDS
--============================================================================

addon.CONST.TEXT = {
    -- Addon Load Messages
    ADDON_LOADED = "ADDON_LOADED",
    ADDON_LOADED_NO_PRICE = "ADDON_LOADED_NO_PRICE",

    -- Slash Commands
    HELP_TITLE = "HELP_TITLE",
    HELP_CMD_CALC = "HELP_CMD_CALC",
    HELP_CMD_HELP = "HELP_CMD_HELP",

    -- Main Window
    WINDOW_TITLE = "WINDOW_TITLE",

    -- Tab Names
    TAB_PIGMENTS = "TAB_PIGMENTS",
    TAB_TRANSMUTES = "TAB_TRANSMUTES",

    -- Options
    OPT_AH_CUT = "OPT_AH_CUT",
    OPT_TRANSMUTE_MASTER = "OPT_TRANSMUTE_MASTER",
    OPT_BUY_PIGMENTS = "OPT_BUY_PIGMENTS",
    BTN_REFRESH = "BTN_REFRESH",

    -- Refresh Button Tooltip
    REFRESH_TOOLTIP_TITLE = "REFRESH_TOOLTIP_TITLE",
    REFRESH_TOOLTIP_DESC = "REFRESH_TOOLTIP_DESC",
    REFRESH_TOOLTIP_HINT = "REFRESH_TOOLTIP_HINT",

    -- Column Headers - Transmutes
    HEADER_RECIPE = "HEADER_RECIPE",
    HEADER_COST = "HEADER_COST",
    HEADER_SELL = "HEADER_SELL",
    HEADER_PROFIT = "HEADER_PROFIT",

    -- Column Headers - Pigments
    HEADER_PIGMENT = "HEADER_PIGMENT",
    HEADER_CHEAPEST_HERB = "HEADER_CHEAPEST_HERB",
    HEADER_BEST_DYE = "HEADER_BEST_DYE",

    -- Row Tooltips
    CLICK_FOR_DETAILS = "CLICK_FOR_DETAILS",
    REQUIRES_HERBS = "REQUIRES_HERBS",
    CHEAPEST_HERB_LABEL = "CHEAPEST_HERB_LABEL",
    BEST_DYE_LABEL = "BEST_DYE_LABEL",
    PROFIT_LABEL = "PROFIT_LABEL",

    -- Detail View - Buttons
    BTN_BACK = "BTN_BACK",
    BTN_SEARCH_AH = "BTN_SEARCH_AH",

    -- Detail View - Search Tooltip
    SEARCH_AH_TOOLTIP_TITLE = "SEARCH_AH_TOOLTIP_TITLE",
    SEARCH_AH_TOOLTIP_DESC = "SEARCH_AH_TOOLTIP_DESC",
    SEARCH_AH_TOOLTIP_DESC2 = "SEARCH_AH_TOOLTIP_DESC2",
    SEARCH_AH_MUST_OPEN = "SEARCH_AH_MUST_OPEN",
    SEARCH_AH_READY = "SEARCH_AH_READY",

    -- Detail View - Pigment Search Tooltip
    SEARCH_AH_PIGMENT_DESC = "SEARCH_AH_PIGMENT_DESC",

    -- Detail View - Sections
    SECTION_MATERIALS = "SECTION_MATERIALS",
    SECTION_PRODUCT = "SECTION_PRODUCT",

    -- Detail View - Summary
    TOTAL_MATERIAL_COST = "TOTAL_MATERIAL_COST",
    EFFECTIVE_COST_MASTERY = "EFFECTIVE_COST_MASTERY",
    SALE_AFTER_CUT = "SALE_AFTER_CUT",
    PROFIT_COLON = "PROFIT_COLON",
    MARGIN_SUFFIX = "MARGIN_SUFFIX",

    -- Pigment Detail View - Sections
    SECTION_CRAFTABLE_DYES = "SECTION_CRAFTABLE_DYES",
    SECTION_DYES_HIGHLIGHT = "SECTION_DYES_HIGHLIGHT",
    SECTION_DYES_NONE = "SECTION_DYES_NONE",
    SECTION_AVAILABLE_HERBS = "SECTION_AVAILABLE_HERBS",
    SECTION_HERBS_HIGHLIGHT = "SECTION_HERBS_HIGHLIGHT",
    SECTION_SUMMARY = "SECTION_SUMMARY",

    -- Pigment Detail View - Summary
    CHEAPEST_HERB = "CHEAPEST_HERB",
    COST_HERBS = "COST_HERBS",
    BEST_DYE = "BEST_DYE",
    DYE_SALE = "DYE_SALE",

    -- Status Messages
    STATUS_AUCTIONATOR_NOT_DETECTED = "STATUS_AUCTIONATOR_NOT_DETECTED",
    STATUS_UPDATED = "STATUS_UPDATED",
    STATUS_NO_PRICES = "STATUS_NO_PRICES",
    STATUS_NO_DATA = "STATUS_NO_DATA",

    -- Empty States
    EMPTY_PIGMENTS = "EMPTY_PIGMENTS",
    EMPTY_NO_DYES = "EMPTY_NO_DYES",

    -- Error Messages
    ERR_ITEM_NAMES_NOT_LOADED = "ERR_ITEM_NAMES_NOT_LOADED",
    ERR_AH_MUST_BE_OPEN = "ERR_AH_MUST_BE_OPEN",
    ERR_SEARCH_API_NOT_AVAILABLE = "ERR_SEARCH_API_NOT_AVAILABLE",
    ERR_ITEM_NAME_NOT_LOADED = "ERR_ITEM_NAME_NOT_LOADED",
    ERR_NO_SEARCH_METHOD = "ERR_NO_SEARCH_METHOD",
    ERR_SEARCH_FAILED = "ERR_SEARCH_FAILED",

    -- Price Formatting
    PRICE_NA = "PRICE_NA",
    UNKNOWN_ITEM = "UNKNOWN_ITEM",

    -- Misc UI Elements
    EACH_ABBREV = "EACH_ABBREV",
    
    -- Inventory Display
    INVENTORY_COUNT = "INVENTORY_COUNT",
    CAN_CRAFT = "CAN_CRAFT",
    INSUFFICIENT_MATERIALS = "INSUFFICIENT_MATERIALS",
    NONE_MATERIALS = "NONE_MATERIALS",
}

--============================================================================
-- LOCALE CODES
--============================================================================

addon.CONST.LOCALS = {
    EN = "enUS",
    DE = "deDE",
    FR = "frFR",
    ES = "esES",
    MX = "esMX",
    PT = "ptBR",
    IT = "itIT",
    RU = "ruRU",
    KO = "koKR",
    CN = "zhCN",
    TW = "zhTW",
}
