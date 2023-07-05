-- Importing global variables into local variables to improve performance and readability
local _G = _G
local SCENE_MANAGER = _G.SCENE_MANAGER
local EVENT_MANAGER = _G.GetEventManager()

-- Checking if SCENE_MANAGER is available, if not, return
if SCENE_MANAGER == nil then
  return
end

-- Checking if EVENT_MANAGER is available, if not, return
if EVENT_MANAGER == nil then
  return
end

-- Assigning constant values to local variables
local BAG_BACKPACK = 1
local LINK_STYLE_DEFAULT = 0

-- Importing specific global variables into local variables
local ZO_MailSendBodyField = _G.ZO_MailSendBodyField
local SLASH_COMMANDS = _G.SLASH_COMMANDS
local GetItemLinkValue = _G.GetItemLinkValue
local GetItemSellValueWithBonuses = _G.GetItemSellValueWithBonuses
local GetItemInfo = _G.GetItemInfo
local GetItemLink = _G.GetItemLink
local GetBagSize = _G.GetBagSize
local zround = _G.zo_round
local ZO_LocalizeDecimalNumber = _G.ZO_LocalizeDecimalNumber
local zo_roundToNearest = _G.zo_roundToNearest
local EVENT_ADD_ON_LOADED = _G.EVENT_ADD_ON_LOADED
local zo_callLater = _G.zo_callLater
local tinsert, tconcat = _G.table.insert, _G.table.concat

-- MailItemsSummaryLP table is created with key-value pairs for various properties
local MailItemsSummaryLP = {
  AddonName = "MailItemsSummaryLP", -- Name of the addon
  major = "1", -- Major version number
  minor = "0", -- Minor version number
  patch = "3", -- Patch version number
  build = "3", -- Build version number
  current_api = 101038, -- Current API version
  future_api = 101039, -- Future API version
}

-- Importing a global variable into a local variable
local LibPrice = _G.LibPrice

-- Function to calculate the price of an item
local function GetItemPrice(itemLink, considerCondition, bagId, slotIndex)
  -- Calculate the default price using provided functions
  local defaultPrice = GetItemLinkValue(itemLink, considerCondition) or GetItemSellValueWithBonuses(bagId, slotIndex)

  -- Use LibPrice addon to get additional price information
  local libPriceValue = LibPrice.ItemLinkToPriceGold(itemLink, "mm", "att", "ttc")
  local price

  -- If LibPrice provides a value, round it and assign it to the 'price' variable
  if libPriceValue then
    price = zround(libPriceValue)
  end

  -- Return the calculated price (either from LibPrice or default)
  return price or defaultPrice
end

-- Main function that calculates the total price of items in the backpack and displays it in the mail body field
local function MISLP()
  -- Check if the mailSend scene is currently being shown, if not, return
  if not SCENE_MANAGER:IsShowing("mailSend") then
    return
  end

  -- Create an empty table to hold the item details and prices
  local ptable = {}

  -- Set the bagId to BAG_BACKPACK
  local bagId = BAG_BACKPACK

  -- Initialize the totalprice variable
  local totalprice = zo_roundToNearest(0, 0)

  -- Set the linkStyle to LINK_STYLE_DEFAULT
  local linkStyle = LINK_STYLE_DEFAULT

  -- Iterate over each slot in the backpack
  for slotIndex = 0, GetBagSize(bagId) - 1 do
    -- Get the item link for the current slot
    local itemLink = GetItemLink(bagId, slotIndex, linkStyle)

    -- Get the stack size and locked status of the item
    local _, stack, _, _, locked, _ = GetItemInfo(bagId, slotIndex)

    -- If the item is locked, calculate its price and add it to the ptable table
    if locked then
      local price = GetItemPrice(itemLink) or 0
      price = zround(price)
      tinsert(
        ptable,
        itemLink
          .. "x"
          .. stack
          .. " "
          .. ZO_LocalizeDecimalNumber(price)
          .. "="
          .. ZO_LocalizeDecimalNumber(stack * price)
      )

      -- Calculate the total price by adding the price of this item to the running total
      totalprice = totalprice + price * stack
    end
  end

  -- Add empty line in ptable
  tinsert(ptable, "")

  -- Add a line showing the total attached value to the ptable
  tinsert(ptable, "Total Attached Value = " .. ZO_LocalizeDecimalNumber(totalprice))

  -- Set the text in ZO_MailSendBodyField to the concatenated strings in ptable table
  ZO_MailSendBodyField:SetText(tconcat(ptable, "\n"))
end

-- Number of milliseconds to wait before registering the slash command
local WAIT_TO_SLASH = 2000

-- Event handler for when the addon is loaded
local function OnAddOnLoaded(_, addonName)
  -- Check if the loaded addon is the MailItemsSummaryLP addon
  if addonName ~= MailItemsSummaryLP.AddonName then
    return
  end

  -- Unregister from the EVENT_ADD_ON_LOADED event
  EVENT_MANAGER:UnregisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED)

  -- Register the slash command "/mislp" to call the MISLP function
  zo_callLater(function()
    SLASH_COMMANDS["/mislp"] = MISLP
  end, WAIT_TO_SLASH)
end

-- Register for the EVENT_ADD_ON_LOADED event with the OnAddOnLoaded event handler
EVENT_MANAGER:RegisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
