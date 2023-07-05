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
local MailItemsSummaryMM = {
  AddonName = "MailItemsSummaryMM",
  major = "1",
  minor = "0",
  patch = "1",
  build = "1",
  current_api = 101038,
  future_api = 101039,
}
function GetItemPrice(itemLink, considerCondition, bagId, slotIndex)
  local defaultPrice = GetItemLinkValue(itemLink, considerCondition) or GetItemSellValueWithBonuses(bagId, slotIndex)
  local MasterMerchant = MasterMerchant
  local LibGuildStore = LibGuildStore
  local TamrielTradeCentrePrice = TamrielTradeCentrePrice
  local MMPrice
  if MasterMerchant then
    if MasterMerchant.isInitialized and LibGuildStore.guildStoreReady then
      local statsData = MasterMerchant:itemStats(itemLink, false)
      if statsData and statsData.avgPrice then
        MMPrice = zround(statsData.avgPrice)
      end
    end
  end

  if TamrielTradeCentrePrice then
    local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    if priceInfo and priceInfo.SuggestedPrice then
      TTCPrice = zround(priceInfo.SuggestedPrice)
    end
  end
  return MMPrice or TTCPrice or defaultPrice
end
local function MISMM()
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
      table.insert(ptable, itemLink .. "x" .. stack .. " " .. price .. "=" .. stack * price)
      totalprice = totalprice + price * stack
    end
  end
  table.insert(ptable, tostring(totalprice))
  ZO_MailSendBodyField:SetText(table.concat(ptable, "\n"))
end
local WAIT_TO_SLASH = 2000
function OnAddOnLoaded(_, addonName)
  if addonName ~= MailItemsSummaryMM.AddonName then
    return
  end
  EVENT_MANAGER:UnregisterForEvent(MailItemsSummaryMM.AddonName, EVENT_ADD_ON_LOADED)
  zo_callLater(function()
    SLASH_COMMANDS["/mismm"] = MISMM
  end, WAIT_TO_SLASH)
end
EVENT_MANAGER:RegisterForEvent(MailItemsSummaryMM.AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
