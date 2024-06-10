local SCENE_MANAGER = SCENE_MANAGER
local EVENT_MANAGER = GetEventManager()
local BAG_BACKPACK = 1
local LINK_STYLE_DEFAULT = 0
local ZO_MailSendBodyField = ZO_MailSendBodyField
local SLASH_COMMANDS = SLASH_COMMANDS
local GetItemLinkValue = GetItemLinkValue
local GetItemSellValueWithBonuses = GetItemSellValueWithBonuses
local GetItemInfo = GetItemInfo
local GetItemLink = GetItemLink
local GetBagSize = GetBagSize
local zround = zo_round
local ZO_LocalizeDecimalNumber = ZO_LocalizeDecimalNumber
local zo_roundToNearest = zo_roundToNearest
local EVENT_ADD_ON_LOADED = EVENT_ADD_ON_LOADED
local zo_callLater = zo_callLater
local tinsert = table.insert
local tconcat = table.concat

-- Forward declration.
--- @type function
local MISLP
--- @type function
local GetItemPrice
--- @type function
local OnAddOnLoaded


--- @class MailItemsSummaryLP
local MailItemsSummaryLP = {
  AddonName = "MailItemsSummaryLP";
  major = "1";
  minor = "0";
  patch = "3";
  build = "4";
  current_api = 101042;
  future_api = 101043;
}

local LibPrice = LibPrice

---
--- @param itemLink string
--- @param considerCondition boolean
--- @param bagId Bag
--- @param slotIndex integer
--- @return number
GetItemPrice = function (itemLink, considerCondition, bagId, slotIndex)
  local defaultPrice = GetItemLinkValue(itemLink, considerCondition) or GetItemSellValueWithBonuses(bagId, slotIndex)
  local libPriceValue = LibPrice.ItemLinkToPriceGold(itemLink, "mm", "att", "ttc")
  --- @type number
  local price
  if libPriceValue then
    price = zround(libPriceValue)
  end
  return price or defaultPrice
end

MISLP = function ()
  if not SCENE_MANAGER:IsShowing("mailSend") then
    return
  end
  local ptable = {}
  local bagId = BAG_BACKPACK
  local totalprice = zo_roundToNearest(0, 0)
  local linkStyle = LINK_STYLE_DEFAULT
  local bagSlots = GetBagSize(bagId)
  for slotIndex = 0, bagSlots - 1 do
    local itemLink = GetItemLink(bagId, slotIndex, linkStyle)
    local _, stack, _, _, locked, _, _, _, _ = GetItemInfo(bagId, slotIndex)
    if locked then
      local price = GetItemPrice(itemLink, false, bagId, slotIndex) or 0
      price = zround(price)
      tinsert(ptable,
        itemLink
        .. " x"
        .. stack
        .. " "
        .. ZO_LocalizeDecimalNumber(price)
        .. " = "
        .. ZO_LocalizeDecimalNumber(stack * price)
      )
      --- @type number
      totalprice = totalprice + price * stack
    end
  end
  tinsert(ptable, "")
  tinsert(ptable, "Total Attached Value = " .. ZO_LocalizeDecimalNumber(totalprice))
  ZO_MailSendBodyField:SetText(tconcat(ptable, "\n"))
end

local WAIT_TO_SLASH = 2000

--- @param _ any
--- @param addonName string
OnAddOnLoaded = function (_, addonName)
  if addonName ~= MailItemsSummaryLP.AddonName then
    return
  end
  EVENT_MANAGER:UnregisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED)
  zo_callLater(function ()
    SLASH_COMMANDS["/mislp"] = MISLP
  end, WAIT_TO_SLASH)
end

EVENT_MANAGER:RegisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
