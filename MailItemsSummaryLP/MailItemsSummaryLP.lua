-- This code is written in Lua programming language

-- SCENE_MANAGER constant is assigned the value of SCENE_MANAGER global variable
local SCENE_MANAGER = SCENE_MANAGER

-- If SCENE_MANAGER is nil, return from the function and stop executing the code
if SCENE_MANAGER == nil then
  return
end

-- EVENT_MANAGER constant is assigned the value of GetEventManager() function
local EVENT_MANAGER = GetEventManager()

-- If EVENT_MANAGER is nil, return from the function and stop executing the code
if EVENT_MANAGER == nil then
  return
end

-- BAG_BACKPACK constant is assigned the value of 1
local BAG_BACKPACK = 1

-- LINK_STYLE_DEFAULT constant is assigned the value of 0
local LINK_STYLE_DEFAULT = 0

-- ZO_MailSendBodyField constant is assigned the value of ZO_MailSendBodyField global variable
local ZO_MailSendBodyField = ZO_MailSendBodyField

-- SLASH_COMMANDS constant is assigned the value of SLASH_COMMANDS global variable
local SLASH_COMMANDS = SLASH_COMMANDS

-- GetItemLinkValue constant is assigned the value of GetItemLinkValue global function
local GetItemLinkValue = GetItemLinkValue

-- GetItemSellValueWithBonuses constant is assigned the value of GetItemSellValueWithBonuses global function
local GetItemSellValueWithBonuses = GetItemSellValueWithBonuses

-- GetItemInfo constant is assigned the value of GetItemInfo global function
local GetItemInfo = GetItemInfo

-- GetItemLink constant is assigned the value of GetItemLink global function
local GetItemLink = GetItemLink

-- GetBagSize constant is assigned the value of GetBagSize global function
local GetBagSize = GetBagSize

-- zround constant is assigned the value of zo_round global function
local zround = zo_round

-- MailItemsSummaryLP table is created with key-value pairs for various properties
local MailItemsSummaryLP = {
  AddonName = "MailItemsSummaryLP", -- Name of the addon
  major = "1", -- Major version number
  minor = "0", -- Minor version number
  patch = "2", -- Patch version number
  build = "2", -- Build version number
  current_api = 101038, -- Current API version
  future_api = 101039, -- Future API version
}

-- LibPrice constant is assigned the value of LibPrice global variable
local LibPrice = LibPrice

-- GetItemPrice function takes parameters itemLink, considerCondition, bagId, slotIndex
function GetItemPrice(itemLink, considerCondition, bagId, slotIndex)
  -- defaultPrice variable is assigned the value of GetItemLinkValue or GetItemSellValueWithBonuses based on condition
  local defaultPrice = GetItemLinkValue(itemLink, considerCondition) or GetItemSellValueWithBonuses(bagId, slotIndex)

  -- libPriceValue, source_key, field_name variables are assigned values from LibPrice.ItemLinkToPriceGold function
  local libPriceValue, source_key, field_name = LibPrice.ItemLinkToPriceGold(itemLink)

  local price
  if libPriceValue then
    -- If libPriceValue is not nil, assign the rounded value of libPriceValue to price
    price = zround(libPriceValue)
  end

  -- Return the value of price if it exists, otherwise return defaultPrice
  return price or defaultPrice
end

-- formatNumber function takes a number as input and returns a formatted string
function formatNumber(value)
  local formatted = value
  while true do
    -- Replace every occurrence of a pattern (^-?%d+)(%d%d%d) in formatted with %1.%2
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")

    -- If no replacements were made, break the loop
    if k == 0 then
      break
    end
  end

  -- Return the formatted string
  return formatted
end

-- MISLP function
function MISLP()
  -- If the current scene is not "mailSend", return from the function and stop executing the code
  if not SCENE_MANAGER:IsShowing("mailSend") then
    return
  end

  -- Create an empty table ptable
  local ptable = {}

  -- Assign the value of BAG_BACKPACK to the variable bagId
  local bagId = BAG_BACKPACK

  -- Assign 0 to totalprice variable
  local totalprice = zo_roundToNearest(0, 0)

  -- Assign the value of LINK_STYLE_DEFAULT to linkStyle variable
  local linkStyle = LINK_STYLE_DEFAULT

  -- Iterate over each slotIndex from 0 to GetBagSize(bagId) - 1
  for slotIndex = 0, GetBagSize(bagId) - 1 do
    -- Get the itemLink at the specified bagId and slotIndex with the given linkStyle
    local itemLink = GetItemLink(bagId, slotIndex, linkStyle)

    -- Get the item information for the specified bagId and slotIndex
    local _, stack, _, _, locked, _ = GetItemInfo(bagId, slotIndex)

    -- If the item is locked
    if locked then
      -- Get the price of the item using GetItemPrice function and assign it to price variable (or 0 if it's nil)
      local price = GetItemPrice(itemLink) or 0

      -- Round the price to the nearest whole number
      price = zround(price)

      -- Concatenate the itemLink, stack, formatted price and total price into a string and insert it into ptable
      table.insert(ptable, itemLink .. "x" .. stack .. " " .. formatNumber(price) .. "=" .. formatNumber(stack * price))

      -- Add the price multiplied by the stack to the totalprice variable
      totalprice = totalprice + price * stack
    end
  end

  -- Insert an empty string into ptable
  table.insert(ptable, "")

  -- Insert a string with the total attached value into ptable
  table.insert(ptable, "Total Attached Value = " .. formatNumber(totalprice))

  -- Set the text of ZO_MailSendBodyField to the concatenated strings in ptable separated by newline characters
  ZO_MailSendBodyField:SetText(table.concat(ptable, "\n"))
end

-- Assign the value of 2000 to WAIT_TO_SLASH constant
local WAIT_TO_SLASH = 2000

-- OnAddOnLoaded function takes parameters _, addonName
function OnAddOnLoaded(_, addonName)
  -- If addonName is not equal to MailItemsSummaryLP.AddonName, return from the function and stop executing the code
  if addonName ~= MailItemsSummaryLP.AddonName then
    return
  end

  -- Unregister the event EVENT_ADD_ON_LOADED for the addonName MailItemsSummaryLP.AddonName
  EVENT_MANAGER:UnregisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED)

  -- Call SLASH_COMMANDS["/mislp"] function after a delay of WAIT_TO_SLASH milliseconds
  zo_callLater(function()
    SLASH_COMMANDS["/mislp"] = MISLP
  end, WAIT_TO_SLASH)
end

-- Register the event EVENT_ADD_ON_LOADED for the addonName MailItemsSummaryLP.AddonName and call OnAddOnLoaded function when triggered
EVENT_MANAGER:RegisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
