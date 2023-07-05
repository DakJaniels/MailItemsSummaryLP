# MailItemsSummaryMM

Let me go through the code step by step and explain what each section does:

1. The code starts by assigning the value of `SCENE_MANAGER` to a local variable named `SCENE_MANAGER`. It then checks if `SCENE_MANAGER` is nil. If it is nil, the code returns and exits. This check ensures that the `SCENE_MANAGER` variable is available.

2. Next, the code gets the `EVENT_MANAGER` and assigns it to a local variable named `EVENT_MANAGER`. It then checks if `EVENT_MANAGER` is nil. If it is nil, the code returns and exits. This check ensures that the `EVENT_MANAGER` variable is available.

3. The code assigns values to some local variables: `BAG_BACKPACK`, `LINK_STYLE_DEFAULT`, `ZO_MailSendBodyField`, `SLASH_COMMANDS`, `GetItemLinkValue`, `GetItemSellValueWithBonuses`, `GetItemInfo`, `GetItemLink`, `GetBagSize`, and `zo_round`.

4. The code creates a table named `MailItemsSummaryMM` with key-value pairs for addon information such as the name of the addon, version numbers, and API version.

5. The code defines a function named `GetItemPrice` that takes four parameters: `itemLink`, `considerCondition`, `bagId`, and `slotIndex`. This function calculates the price of an item based on its link, condition, bag ID, and slot index. The function first tries to get the price from the `MasterMerchant` addon, and if that fails, it falls back to getting the sell value of the item. The rounded price is returned.

6. The code defines a local function named `MISMM`. This function checks if the "mailSend" scene is currently displayed. If it is not, the function returns and exits. If the scene is displayed, the function creates an empty table named `ptable`.

7. The function then iterates through each slot in the player's backpack and retrieves information about the items in those slots. It checks if an item is locked and calculates its price using the `GetItemPrice` function. It also updates the total price by multiplying the price per item by the stack count.

8. After iterating through all the slots, the function adds the string representation of the total price to the `ptable` table.

9. Finally, the function sets the text of `ZO_MailSendBodyField` (presumably a UI element) to a concatenated string of the elements in `ptable`, separated by newlines.

10. The code defines a constant variable named `WAIT_TO_SLASH` with a value of 2000.

11. The code defines another function named `OnAddOnLoaded` that takes two parameters: `_` and `addonName`. This function is called when the addon is loaded. It checks if the `addonName` parameter is equal to `MailItemsSummaryMM.AddonName`. If they are not equal, the function returns and exits.

12. The function unregisters from the `EVENT_ADD_ON_LOADED` event for the `MailItemsSummaryMM` addon.

13. The function schedules another function to be called after a delay of `WAIT_TO_SLASH` milliseconds. In that callback function, it assigns `MISMM` as the slash command handler for "/mismm".

14. Lastly, the code registers for the `EVENT_ADD_ON_LOADED` event for the `MailItemsSummaryMM` addon and calls the `OnAddOnLoaded` function.

To summarize, this code sets up an addon for ESO that fetches the prices of items in the player's backpack and displays a summary of those prices in the mail send body when the "/mismm" slash command is used.
