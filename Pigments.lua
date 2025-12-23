--============================================================================
-- QuickCrafts: Pigments.lua
-- Pigment definitions for WoW Housing
--============================================================================

local addonName, addon = ...

addon.Pigments = {
    {
        id = "black_dye_pigment",
        name = "Black Dye Pigment",
        itemID = 262639,
        herbCost = 10,
        herbs = {
            { itemID = 3818, name = "Fadeleaf" },
            { itemID = 22785, name = "Felweed" },
            { itemID = 36905, name = "Lichbloom" },
            { itemID = 52985, name = "Azshara's Veil" },
            { itemID = 89639, name = "Desecrated Herb" },
            { itemID = 109128, name = "Nagrand Arrowbloom" },
            { itemID = 128304, name = "Yseralline Seed" },
            { itemID = 152505, name = "Riverbud" },
            { itemID = 169701, name = "Death Blossom" },
            { itemID = 191470, name = "Writhebark Q1" },
            { itemID = 191471, name = "Writhebark Q2" },
            { itemID = 191472, name = "Writhebark Q3" },
            { itemID = 210805, name = "Blessing Blossom Q1" },
            { itemID = 210806, name = "Blessing Blossom Q2" },
            { itemID = 210807, name = "Blessing Blossom Q3" },
        },
    },
    {
        id = "blue_dye_pigment",
        name = "Blue Dye Pigment",
        itemID = 262643,
        herbCost = 10,
        herbs = {
			{ itemID = 109124, name = "Frostweed" },
			{ itemID = 765, name = "Silverleaf" },
			{ itemID = 22789, name = "Terocone" },
			{ itemID = 36906, name = "Icethorn" },
			{ itemID = 52984, name = "Stormvine" },
			{ itemID = 72235, name = "Silkweed" },
			{ itemID = 124102, name = "Dreamleaf" },
			{ itemID = 152507, name = "Akunda's Bite" },
			{ itemID = 169701, name = "Death Blossom" },
			{ itemID = 191467, name = "Bubble Poppy Q1" },
			{ itemID = 191468, name = "Bubble Poppy Q2" },
			{ itemID = 191469, name = "Bubble Poppy Q3" },
			{ itemID = 210799, name = "Luredrop Q1" },
			{ itemID = 210800, name = "Luredrop Q2" },
			{ itemID = 210801, name = "Luredrop Q3" },
        },
    },
    {
        id = "brown_dye_pigment",
        name = "Brown Dye Pigment",
        itemID = 262642,
        herbCost = 10,
        herbs = {
            { itemID = 2450, name = "Briarthorn" },
            { itemID = 22786, name = "Dreaming Glory" },
            { itemID = 36903, name = "Adder's Tongue" },
            { itemID = 52983, name = "Cinderbloom" },
            { itemID = 89639, name = "Desecrated Herb" },
            { itemID = 109126, name = "Gorgrond Flytrap" },
            { itemID = 124103, name = "Foxflower" },
            { itemID = 152511, name = "Sea Stalk" },
            { itemID = 168589, name = "Marrowroot" },
            { itemID = 191470, name = "Writhebark Q1" },
            { itemID = 191471, name = "Writhebark Q2" },
            { itemID = 191472, name = "Writhebark Q3" },
            { itemID = 210796, name = "Mycobloom Q1" },
            { itemID = 210797, name = "Mycobloom Q2" },
            { itemID = 210798, name = "Mycobloom Q3" },
        },
    },
    {
        id = "green_dye_pigment",
        name = "Green Dye Pigment",
        itemID = 262647, 
        herbCost = 10,
        herbs = {
            { itemID = 2452, name = "Swiftthistle" },
            { itemID = 22785, name = "Felweed" },
            { itemID = 36903, name = "Adder's Tongue" },
            { itemID = 52985, name = "Azshara's Veil" },
            { itemID = 72234, name = "Green Tea Leaf" },
            { itemID = 109128, name = "Nagrand Arrowbloom" },
            { itemID = 124102, name = "Dreamleaf" },
            { itemID = 152505, name = "Riverbud" },
            { itemID = 170554, name = "Vigil's Torch" },
			{ itemID = 191467, name = "Bubble Poppy Q1" },
			{ itemID = 191468, name = "Bubble Poppy Q2" },
			{ itemID = 191469, name = "Bubble Poppy Q3" },
            { itemID = 210805, name = "Blessing Blossom Q1" },
            { itemID = 210806, name = "Blessing Blossom Q2" },
            { itemID = 210807, name = "Blessing Blossom Q3" },
        },
    },
    {
        id = "orange_dye_pigment",
        name = "Orange Dye Pigment",
        itemID = 262656, 
        herbCost = 10,
        herbs = {
            { itemID = 13464, name = "Golden Sansam" },
            { itemID = 22792, name = "Nightmare Vine" },
            { itemID = 36901, name = "Goldclover" },
            { itemID = 52986, name = "Heartblossom" },
            { itemID = 72237, name = "Rain Poppy" },
            { itemID = 109125, name = "Fireweed" },
            { itemID = 124103, name = "Foxflower" },
            { itemID = 152509, name = "Siren's Pollen" },
            { itemID = 168583, name = "Widowbloom" },
            { itemID = 191470, name = "Writhebark Q1" },
            { itemID = 191471, name = "Writhebark Q2" },
            { itemID = 191472, name = "Writhebark Q3" },
			{ itemID = 210799, name = "Luredrop Q1" },
			{ itemID = 210800, name = "Luredrop Q2" },
			{ itemID = 210801, name = "Luredrop Q3" },
        },
    },
    {
        id = "purple_dye_pigment",
        name = "Purple Dye Pigment",
        itemID = 262625, 
        herbCost = 10,
        herbs = {
            { itemID = 3356, name = "Kingsblood" },
            { itemID = 22793, name = "Mana Thistle" },
            { itemID = 36907, name = "Talandra's Rose" },
            { itemID = 52987, name = "Twilight Jasmine" },
            { itemID = 79011, name = "Fool's Cap" },
            { itemID = 109129, name = "Talador Orchid" },
            { itemID = 124101, name = "Aethril" },
            { itemID = 168487, name = "Zin'anthid" },
            { itemID = 170554, name = "Vigil's Torch" },
            { itemID = 191460, name = "Hochenblume Q1" },
            { itemID = 191461, name = "Hochenblume Q2" },
            { itemID = 191462, name = "Hochenblume Q3" },
            { itemID = 210802, name = "Orbinid Q1" },
            { itemID = 210803, name = "Orbinid Q2" },
            { itemID = 210804, name = "Orbinid Q3" },
        },
    },
    {
        id = "red_dye_pigment",
        name = "Red Dye Pigment",
        itemID = 262655,  
        herbCost = 10,
        herbs = {
            { itemID = 785, name = "Mageroyal" },
            { itemID = 22791, name = "Netherbloom" },
            { itemID = 36904, name = "Tiger Lily" },
            { itemID = 52983, name = "Cinderbloom" },
            { itemID = 72237, name = "Rain Poppy" },
            { itemID = 109125, name = "Fireweed" },
            { itemID = 151565, name = "Astral Glory" },
            { itemID = 152506, name = "Star Moss" },
            { itemID = 168583, name = "Widowbloom" },
            { itemID = 191464, name = "Saxifrage Q1" },
            { itemID = 191465, name = "Saxifrage Q2" },
            { itemID = 191466, name = "Saxifrage Q3" },
            { itemID = 210808, name = "Arathor's Spear Q1" },
            { itemID = 210809, name = "Arathor's Spear Q2" },
            { itemID = 210810, name = "Arathor's Spear Q3" },
        },
    },
    {
        id = "teal_dye_pigment",
        name = "Teal Dye Pigment",
        itemID = 262628,
        herbCost = 10,
        herbs = {
            { itemID = 2453, name = "Bruiseweed" },
            { itemID = 22789, name = "Terocone" },
            { itemID = 36905, name = "Lichbloom" },
            { itemID = 52984, name = "Stormvine" },
            { itemID = 72235, name = "Silkweed" },
            { itemID = 109127, name = "Starflower" },
            { itemID = 128304, name = "Yseralline Seed" },
            { itemID = 152509, name = "Siren's Pollen" },
            { itemID = 168589, name = "Marrowroot" },
            { itemID = 191460, name = "Hochenblume Q1" },
            { itemID = 191461, name = "Hochenblume Q2" },
            { itemID = 191462, name = "Hochenblume Q3" },
            { itemID = 210802, name = "Orbinid Q1" },
            { itemID = 210803, name = "Orbinid Q2" },
            { itemID = 210804, name = "Orbinid Q3" },
        },
    },
    {
        id = "white_dye_pigment",
        name = "White Dye Pigment",
        itemID = 260947,
        herbCost = 10,
        herbs = {
            { itemID = 2447, name = "Peacebloom" },
            { itemID = 22787, name = "Ragveil" },
            { itemID = 36906, name = "Icethorn" },
            { itemID = 52988, name = "Whiptail" },
            { itemID = 79010, name = "Snow Lily" },
            { itemID = 109129, name = "Talador Orchid" },
            { itemID = 124104, name = "Fjarnskaggl" },
            { itemID = 152508, name = "Winter's Kiss" },
            { itemID = 168586, name = "Rising Glory" },
            { itemID = 191464, name = "Saxifrage Q1" },
            { itemID = 191465, name = "Saxifrage Q2" },
            { itemID = 191466, name = "Saxifrage Q3" },
            { itemID = 210796, name = "Mycobloom Q1" },
            { itemID = 210797, name = "Mycobloom Q2" },
            { itemID = 210798, name = "Mycobloom Q3" },
        },
    },
    {
        id = "yellow_dye_pigment",
        name = "Yellow Dye Pigment",
        itemID = 262648, 
        herbCost = 10,
        herbs = {
            { itemID = 8838, name = "Sungrass" },
            { itemID = 22786, name = "Dreaming Glory" },
            { itemID = 36901, name = "Goldclover" },
            { itemID = 52988, name = "Whiptail" },
            { itemID = 72234, name = "Green Tea Leaf" },
            { itemID = 109126, name = "Gorgrond Flytrap" },
            { itemID = 124104, name = "Fjarnskaggl" },
            { itemID = 152511, name = "Sea Stalk" },
            { itemID = 168586, name = "Rising Glory" },
            { itemID = 191464, name = "Saxifrage Q1" },
            { itemID = 191465, name = "Saxifrage Q2" },
            { itemID = 191466, name = "Saxifrage Q3" },
            { itemID = 210808, name = "Arathor's Spear Q1" },
            { itemID = 210809, name = "Arathor's Spear Q2" },
            { itemID = 210810, name = "Arathor's Spear Q3" },
        },
    },
}

--============================================================================
-- HELPER FUNCTIONS
--============================================================================

-- Get a pigment by its ID
function addon:GetPigmentByID(pigmentID)
    for _, pigment in ipairs(self.Pigments) do
        if pigment.id == pigmentID then
            return pigment
        end
    end
    return nil
end

-- Get all item IDs used in pigments (for preloading)
function addon:GetAllPigmentItemIDs()
    local itemIDs = {}
    for _, pigment in ipairs(self.Pigments) do
        -- Add pigment itself
        itemIDs[pigment.itemID] = true
        -- Add all herbs
        for _, herb in ipairs(pigment.herbs) do
            itemIDs[herb.itemID] = true
        end
    end
    return itemIDs
end

-- Get pigment count
function addon:GetPigmentCount()
    return #self.Pigments
end

-- Combine all item IDs (recipes + pigments) for preloading
local originalGetAllItemIDs = addon.GetAllItemIDs
function addon:GetAllItemIDs()
    local itemIDs = {}
    
    -- Get recipe item IDs
    for _, recipe in ipairs(self.Recipes) do
        itemIDs[recipe.product.itemID] = true
        for _, mat in ipairs(recipe.materials) do
            itemIDs[mat.itemID] = true
        end
    end
    
    -- Get pigment item IDs
    for _, pigment in ipairs(self.Pigments) do
        itemIDs[pigment.itemID] = true
        for _, herb in ipairs(pigment.herbs) do
            itemIDs[herb.itemID] = true
        end
    end
    
    return itemIDs
end
