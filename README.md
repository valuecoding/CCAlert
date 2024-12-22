# CC Alert

**CC Alert** is a lightweight and customizable addon for World of Warcraft that helps players stay aware of enemy crowd control (CC) casts in PvP battles. Designed to improve reaction times, this addon displays real-time alerts for critical CC spells, ensuring you never miss an important enemy ability.

## Features

- **Real-Time Alerts:** Receive visual and audio notifications when enemies cast key CC spells like Polymorph, Fear, Cyclone, and more.
- **Customizable Alerts:** Adjust the size and position of alerts to suit your preferences.
- **Test Mode:** Easily test alert functionality and layout with a simple test button.
- **Selective CC Monitoring:** Enable or disable specific CC spells through a scrollable settings panel.

## Installation

1. **Download the Files:**
   - Download the `CCAlert.lua` and `CCAlert.toc` files from this repository.

2. **Create Addon Folder:**
   - Navigate to your World of Warcraft installation directory:
     ```
     World of Warcraft/
       _retail_/
         Interface/
           AddOns/
     ```
   - Create a new folder named `CCAlert` inside the `AddOns` directory.

3. **Place Files:**
   - Move the downloaded `CCAlert.lua` and `CCAlert.toc` files into the newly created `CCAlert` folder.

4. **Enable the Addon:**
   - Launch World of Warcraft.
   - On the character selection screen, click the "AddOns" button in the lower left corner.
   - Ensure that **CC Alert** is enabled in the list.
   - Click "Okay" to apply the changes.

## Customization

### Changing Alert Sounds

1. **Open the `CCAlert.lua` File:**
   - Navigate to the addon directory:
     ```
     World of Warcraft/
       _retail_/
         Interface/
           AddOns/
             CCAlert/
               CCAlert.lua
     ```

2. **Modify the Sound Channel:**
   - Locate the `CCAlertSettings` table and change the `soundChannel` value to your preferred channel (e.g., `"SFX"`, `"Dialog"`).
     ```lua
     CCAlertSettings = {
         alertSize = 100,
         alertPosition = { x = 0, y = 150 },
         soundChannel = "SFX", -- Options: "Master", "SFX", "Dialog", etc.
         enabledSpells = { ... },
     }
     ```

3. **Change the Alert Sound (Optional):**
   - In the `ShowAlert` function, replace the `PlaySound` line with a different `SOUNDKIT` constant if desired.
     ```lua
     PlaySound(SOUNDKIT.RAID_WARNING, CCAlertSettings.soundChannel)
     ```
   - **Note:** A list of available `SOUNDKIT` constants can be found on [Wowpedia](https://wow.gamepedia.com/SOUNDKIT_API).

### Adding and Customizing CC Spells

1. **Find the Spell ID and Icon:**
   - Visit [Wowhead](https://www.wowhead.com/) and search for the desired spell.
   - Note the **Spell ID** and the **Icon Name** (found below the spell icon on the spell's page).

2. **Edit the `CCAlert.lua` File:**

   - **Enable the Spell:**
     ```lua
     CCAlertSettings.enabledSpells = {
         [118]    = true, -- Polymorph
         [5782]   = true, -- Fear
         -- Add your new spell ID below
         [12345]  = true, -- New CC Spell
     }
     ```

   - **Add Spell Details:**
     ```lua
     CC_SPELLS = {
         [118]    = { icon = "Interface\\Icons\\Spell_nature_polymorph",        name = "Polymorph" },
         [5782]   = { icon = "Interface\\Icons\\Spell_shadow_possession",       name = "Fear" },
         -- Add your new spell details below
         [12345]  = { icon = "Interface\\Icons\\Spell_custom_newcc",           name = "New CC Spell" },
     }
     ```

3. **Save and Reload:**
   - Save the `CCAlert.lua` file.
   - In-game, type `/reload` to apply the changes.

## Feedback and Support

Your feedback is invaluable! If you encounter issues, have feature requests, or want additional CC spells added, please leave a comment in the repository's issues section. I strive to implement improvements and address your needs as effectively as possible.

---

**Note:** Ensure you always use the latest version of **CC Alert** and check for updates regularly to benefit from the newest features and bug fixes.
