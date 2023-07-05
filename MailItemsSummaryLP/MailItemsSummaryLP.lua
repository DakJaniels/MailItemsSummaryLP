local SCENE_MANAGER = SCENE_MANAGER
if SCENE_MANAGER == nil then
  return
end
local EVENT_MANAGER = GetEventManager()
if EVENT_MANAGER == nil then
  return
end
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
local MailItemsSummaryLP = {
  AddonName = "MailItemsSummaryLP",
  major = "1",
  minor = "0",
  patch = "2",
  build = "2",
  current_api = 101038,
  future_api = 101039,
}

local LibPrice = LibPrice

local function GetItemPrice(itemLink, considerCondition, bagId, slotIndex)
  local defaultPrice = GetItemLinkValue(itemLink, considerCondition) or GetItemSellValueWithBonuses(bagId, slotIndex)
  local libPriceValue = LibPrice.ItemLinkToPriceGold(itemLink, "mm", "att", "ttc")
  local price
  if libPriceValue then
    price = zround(libPriceValue)
  end
  return price or defaultPrice
end

local function formatNumber(value)
  local formatted = value
  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
    if k == 0 then
      break
    end
  end
  return formatted
end

local function MISLP()
  if not SCENE_MANAGER:IsShowing("mailSend") then
    return
  end
  local ptable = {}
  local bagId = BAG_BACKPACK
  local totalprice = zo_roundToNearest(0, 0)
  local linkStyle = LINK_STYLE_DEFAULT
  for slotIndex = 0, GetBagSize(bagId) - 1 do
    local itemLink = GetItemLink(bagId, slotIndex, linkStyle)
    local _, stack, _, _, locked, _ = GetItemInfo(bagId, slotIndex)
    if locked then
      local price = GetItemPrice(itemLink) or 0
      price = zround(price)
      table.insert(ptable, itemLink .. "x" .. stack .. " " .. formatNumber(price) .. "=" .. formatNumber(stack * price))
      totalprice = totalprice + price * stack
    end
  end
  table.insert(ptable, "")
  table.insert(ptable, "Total Attached Value = " .. formatNumber(totalprice))
  ZO_MailSendBodyField:SetText(table.concat(ptable, "\n"))
end

local WAIT_TO_SLASH = 2000

local function OnAddOnLoaded(_, addonName)
  if addonName ~= MailItemsSummaryLP.AddonName then
    return
  end
  EVENT_MANAGER:UnregisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED)
  zo_callLater(function()
    SLASH_COMMANDS["/mislp"] = MISLP
  end, WAIT_TO_SLASH)
end
EVENT_MANAGER:RegisterForEvent(MailItemsSummaryLP.AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
