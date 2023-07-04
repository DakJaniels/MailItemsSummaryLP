-- Assign the value of SCENE_MANAGER to a local variable named SCENE_MANAGER
local SCENE_MANAGER = SCENE_MANAGER
-- Check if SCENE_MANAGER is nil
if SCENE_MANAGER == nil then
  -- If SCENE_MANAGER is nil, return and exit the code
  return
end
-- Get the EVENT_MANAGER
local EVENT_MANAGER = GetEventManager()
-- Check if EVENT_MANAGER is nil
if EVENT_MANAGER == nil then
  -- If EVENT_MANAGER is nil, return and exit the code
  return
end
-- Assign the value 1 to a local variable named BAG_BACKPACK
local BAG_BACKPACK = 1
-- Assign the value 0 to a local variable named LINK_STYLE_DEFAULT
local LINK_STYLE_DEFAULT = 0
-- Assign the value of ZO_MailSendBodyField to a local variable named ZO_MailSendBodyField
local ZO_MailSendBodyField = ZO_MailSendBodyField
-- Assign the value of SLASH_COMMANDS to a local variable named SLASH_COMMANDS
local SLASH_COMMANDS = SLASH_COMMANDS
-- Assign the value of GetItemLinkValue to a local variable named GetItemLinkValue
local GetItemLinkValue = GetItemLinkValue
-- Assign the value of GetItemSellValueWithBonuses to a local variable named GetItemSellValueWithBonuses
local GetItemSellValueWithBonuses = GetItemSellValueWithBonuses
-- Assign the value of GetItemInfo to a local variable named GetItemInfo
local GetItemInfo = GetItemInfo
-- Assign the value of GetItemLink to a local variable named GetItemLink
local GetItemLink = GetItemLink
-- Assign the value of GetBagSize to a local variable named GetBagSize
local GetBagSize = GetBagSize
-- Assign the value of zo_round to a local variable named zround
local zround = zo_round
-- Create a table named MailItemsSummaryMM with key-value pairs for addon information
local MailItemsSummaryMM = {
  AddonName = "MailItemsSummaryMM", -- Name of the addon
  major = "1", -- Major version number
  minor = "0", -- Minor version number
  patch = "1", -- Patch version number
  build = "1", -- Build version number
  current_api = 101038, -- Current API version
  future_api = 101039, -- Future API version
}
-- Define a function named GetItemPrice that takes itemLink, considerCondition, bagId, and slotIndex as parameters
function GetItemPrice(itemLink, considerCondition, bagId, slotIndex)
  -- Get the default price of the item by calling GetItemLinkValue or GetItemSellValueWithBonuses
  local defaultPrice = GetItemLinkValue(itemLink, considerCondition) or GetItemSellValueWithBonuses(bagId, slotIndex)
  -- Assign the value of MasterMerchant to a local variable named MasterMerchant
  local MasterMerchant = MasterMerchant
  -- Assign the value of LibGuildStore to a local variable named LibGuildStore
  local LibGuildStore = LibGuildStore
  -- Declare a variable named MMPrice
  local MMPrice
  -- Check if MasterMerchant is not nil
  if MasterMerchant then
    -- Check if MasterMerchant is initialized and LibGuildStore is ready
    if MasterMerchant.isInitialized and LibGuildStore.guildStoreReady then
      -- Get item statistics from MasterMerchant and assign it to itemStats
      local statsData = MasterMerchant:itemStats(itemLink, false)
      -- Check if statsData exists and has avgPrice property
      if statsData and statsData.avgPrice then
        -- Round the avgPrice using zround function and assign it to MMPrice
        MMPrice = zround(statsData.avgPrice)
      end
    end
  end
  -- Return MMPrice if it exists, otherwise return defaultPrice
  return MMPrice or defaultPrice
end
-- Define a local function named MISMM
local function MISMM()
  -- Check if mailSend scene is not showing
  if not SCENE_MANAGER:IsShowing("mailSend") then
    -- If mailSend scene is not showing, return and exit the code
    return
  end
  -- Create an empty table named ptable
  local ptable = {}
  -- Assign the value of BAG_BACKPACK to bagId
  local bagId = BAG_BACKPACK
  -- Assign 0 to totalprice using zo_roundToNearest function
  local totalprice = zo_roundToNearest(0, 0)
  -- Assign the value of LINK_STYLE_DEFAULT to linkStyle
  local linkStyle = LINK_STYLE_DEFAULT
  -- Iterate over each slot in the backpack bag
  for slotIndex = 0, GetBagSize(bagId) - 1 do
    -- Get itemLink for the item in the specified slot
    local itemLink = GetItemLink(bagId, slotIndex, linkStyle)
    -- Get item information including stack count and locked status
    local _, stack, _, _, locked, _ = GetItemInfo(bagId, slotIndex)
    -- Check if the item is locked
    if locked then
      -- Get the price of the item from the GetItemPrice function or assign 0 if it doesn't exist
      local price = GetItemPrice(itemLink) or 0
      -- Round the price using zround function
      price = zround(price)
      -- Add a string to ptable with itemLink, stack count, price per item, and total price
      table.insert(ptable, itemLink .. "x" .. stack .. " " .. price .. "=" .. stack * price)
      -- Update the total price by adding the price per item multiplied by stack count
      totalprice = totalprice + price * stack
    end
  end
  -- Add a string representation of the total price to ptable
  table.insert(ptable, tostring(totalprice))
  -- Set the text of ZO_MailSendBodyField to a concatenated string of ptable elements separated by newlines
  ZO_MailSendBodyField:SetText(table.concat(ptable, "\n"))
end
-- Define a constant variable named WAIT_TO_SLASH with a value of 2000
local WAIT_TO_SLASH = 2000
-- Define a function named OnAddOnLoaded that takes _, addonName as parameters
function OnAddOnLoaded(_, addonName)
  -- Check if addonName is equal to MailItemsSummaryMM.AddonName
  if addonName ~= MailItemsSummaryMM.AddonName then
    -- If addonName is not equal to MailItemsSummaryMM.AddonName, return and exit the code
    return
  end
  -- Unregister from the EVENT_ADD_ON_LOADED event for the MailItemsSummaryMM addon
  EVENT_MANAGER:UnregisterForEvent(MailItemsSummaryMM.AddonName, EVENT_ADD_ON_LOADED)
  -- Call a function after a delay using zo_callLater
  zo_callLater(function()
    -- Assign MISMM as the slash command handler for "/mismm"
    SLASH_COMMANDS["/mismm"] = MISMM
  end, WAIT_TO_SLASH)
end
-- Register for the EVENT_ADD_ON_LOADED event for the MailItemsSummaryMM addon and call OnAddOnLoaded function
EVENT_MANAGER:RegisterForEvent(MailItemsSummaryMM.AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
