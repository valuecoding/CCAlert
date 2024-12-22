-- ##############################################
-- #                                            #
-- #                CC Alert                    #
-- #           c0ded by enjoymygripz            #
-- ##############################################

local addonName, addonTable = ...
local CCAlert = CreateFrame("Frame", "CCAlertFrame", UIParent)

-- Events
CCAlert:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
CCAlert:RegisterEvent("GROUP_ROSTER_UPDATE")
CCAlert:RegisterEvent("ZONE_CHANGED_NEW_AREA")

--------------------------------------------------------------------------------
-- 1) Sichere Spell-API (The War Within / Patch 11.0.7)
--------------------------------------------------------------------------------
local function SafeGetSpellInfo(spellId)
    if C_Spell and C_Spell.GetSpellInfo then
        local name, _, icon = C_Spell.GetSpellInfo(spellId)
        return name, icon
    elseif GetSpellInfo then
        local name, _, icon = GetSpellInfo(spellId)
        return name, icon
    end
    return nil, nil
end

--------------------------------------------------------------------------------
-- 2) SavedVariables
--------------------------------------------------------------------------------
CCAlertSettings = {
    alertSize = 100,
    alertPosition = { x = 0, y = 150 },
    -- Falls "Master" nicht klappt, kannst du hier testweise "SFX", "Dialog" etc. eintragen.
    soundChannel = "Master",
    enabledSpells = {
        [118]    = true, -- Polymorph
        [5782]   = true, -- Fear
        [33786]  = true, -- Cyclone
        [51514]  = true, -- Hex
        [20066]  = true, -- Repentance
        [360806] = true, -- Sleep Walk
        [207684] = true, -- Sigil of Misery
        [6358]   = true, -- Seduction
    },
}

--------------------------------------------------------------------------------
-- 3) Backup-Symbole, falls SafeGetSpellInfo kein Icon liefert
--------------------------------------------------------------------------------
local CC_SPELLS = {
    [118]    = { icon = "Interface\\Icons\\Spell_nature_polymorph",         name = "Polymorph" },
    [5782]   = { icon = "Interface\\Icons\\Spell_shadow_possession",        name = "Fear" },
    [33786]  = { icon = "Interface\\Icons\\Spell_nature_earthbind",         name = "Cyclone" },
    [51514]  = { icon = "Interface\\Icons\\Spell_shaman_hex",               name = "Hex" },
    [20066]  = { icon = "Interface\\Icons\\Spell_holy_prayerofhealing",     name = "Repentance" },
    [360806] = { icon = "Interface\\Icons\\Ability_xavius_dreamsimulacrum", name = "Sleep Walk" },
    [207684] = { icon = "Interface\\Icons\\Ability_demonhunter_sigilofmisery", name = "Sigil of Misery" },
    [6358]   = { icon = "Interface\\Icons\\Spell_shadow_seduction",         name = "Seduction" },
}

--------------------------------------------------------------------------------
-- 4) Gegner feststellen rein über Hostile-Flag aus dem Combat-Log
--------------------------------------------------------------------------------
local function IsEnemy(sourceFlags)
    return bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0
end

--------------------------------------------------------------------------------
-- 5) Frame erstellen für den Alert
--------------------------------------------------------------------------------
local function CreateAlertFrame()
    if not CCAlert.alertFrame then
        CCAlert.alertFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        CCAlert.alertFrame:SetSize(CCAlertSettings.alertSize, CCAlertSettings.alertSize)
        CCAlert.alertFrame:SetPoint("CENTER", UIParent, "CENTER", CCAlertSettings.alertPosition.x, CCAlertSettings.alertPosition.y)

        CCAlert.alertFrame:SetBackdrop({
            bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile     = false,
            edgeSize = 2,
        })
        CCAlert.alertFrame:SetBackdropColor(0, 0, 0, 0.7)
        CCAlert.alertFrame:SetBackdropBorderColor(1, 0, 0, 1)

        CCAlert.alertFrame.texture = CCAlert.alertFrame:CreateTexture(nil, "ARTWORK")
        CCAlert.alertFrame.texture:SetAllPoints()
        CCAlert.alertFrame.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        CCAlert.alertFrame:Hide()

        -- Drag-and-drop
        CCAlert.alertFrame:SetMovable(true)
        CCAlert.alertFrame:EnableMouse(true)
        CCAlert.alertFrame:RegisterForDrag("LeftButton")
        CCAlert.alertFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        CCAlert.alertFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local _, _, _, x, y = self:GetPoint()
            CCAlertSettings.alertPosition.x = x
            CCAlertSettings.alertPosition.y = y
        end)
    end
end

--------------------------------------------------------------------------------
-- 6) Icon bestimmen
--------------------------------------------------------------------------------
local function GetSafeSpellIcon(spellId)
    local _, dynamicIcon = SafeGetSpellInfo(spellId)
    if dynamicIcon then
        return dynamicIcon
    end
    local fallback = CC_SPELLS[spellId] and CC_SPELLS[spellId].icon
    if fallback then
        return fallback
    end
    return "Interface\\Icons\\Inv_misc_questionmark"
end

--------------------------------------------------------------------------------
-- 7) Alarm anzeigen (Bild + Sound)
--------------------------------------------------------------------------------
local function ShowAlert(spellId, isTest)
    CreateAlertFrame()
    local texture = GetSafeSpellIcon(spellId)
    CCAlert.alertFrame.texture:SetTexture(texture)
    CCAlert.alertFrame:SetAlpha(1)
    CCAlert.alertFrame:Show()

    -- Sound abspielen
    -- Wenn du die Default-Sounds nicht hörst, nutze z.B.:
    -- PlaySound(SOUNDKIT.RAID_WARNING, CCAlertSettings.soundChannel)
    PlaySound(8959, CCAlertSettings.soundChannel)

    -- 2 Sek. anzeigen, außer im Test
    if not isTest then
        C_Timer.After(2, function()
            CCAlert.alertFrame:Hide()
        end)
    end
end

--------------------------------------------------------------------------------
-- 8) Event-Handler
--------------------------------------------------------------------------------
CCAlert:SetScript("OnEvent", function(self, event)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, _, _, spellID = CombatLogGetCurrentEventInfo()

        -- Alarm nur beim Cast-Start, egal auf wen
        if subEvent == "SPELL_CAST_START"
           and CCAlertSettings.enabledSpells[spellID]
           and IsEnemy(sourceFlags)
        then
            ShowAlert(spellID, false)
        end

    elseif event == "GROUP_ROSTER_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
        -- Aktuell kein spezielles Handling nötig
    end
end)

--------------------------------------------------------------------------------
-- 9) Einstellungs-Panel (GUI)
--------------------------------------------------------------------------------
local function CreateSettingsPanel()
    local frame = CreateFrame("Frame", "CCAlertSettingsPanel", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(400, 500)
    frame:SetPoint("CENTER")
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -30)
    frame.title:SetText("CC Alert Settings")

    local sizeSlider = CreateFrame("Slider", "CCAlertSizeSlider", frame, "OptionsSliderTemplate")
    sizeSlider:SetPoint("TOP", frame, "TOP", 0, -70)
    sizeSlider:SetMinMaxValues(50, 200)
    sizeSlider:SetValue(CCAlertSettings.alertSize)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetScript("OnValueChanged", function(self)
        CCAlertSettings.alertSize = self:GetValue()
        if CCAlert.alertFrame then
            CCAlert.alertFrame:SetSize(CCAlertSettings.alertSize, CCAlertSettings.alertSize)
        end
    end)

    sizeSlider.text = sizeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeSlider.text:SetPoint("BOTTOM", sizeSlider, "TOP", 0, 5)
    sizeSlider.text:SetText("Alert Size")

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -120)
    scrollFrame:SetSize(360, 200)

    local scrollChild = CreateFrame("Frame")
    scrollChild:SetSize(360, 200)
    scrollFrame:SetScrollChild(scrollChild)

    local yOffset = 0
    for spellId, data in pairs(CC_SPELLS) do
        local checkBox = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")
        checkBox:SetPoint("TOPLEFT", 0, yOffset)
        checkBox:SetChecked(CCAlertSettings.enabledSpells[spellId])
        checkBox.text = checkBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        checkBox.text:SetPoint("LEFT", checkBox, "RIGHT", 5, 0)
        checkBox.text:SetText(data.name)

        checkBox:SetScript("OnClick", function(self)
            CCAlertSettings.enabledSpells[spellId] = self:GetChecked()
        end)

        yOffset = yOffset - 30
    end

    local testButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    testButton:SetPoint("BOTTOM", frame, "BOTTOM", -60, 40)
    testButton:SetSize(120, 30)
    testButton:SetText("Test Alert")
    testButton:SetScript("OnClick", function()
        ShowAlert(118, true) -- Polymorph
    end)

    local hideButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    hideButton:SetPoint("BOTTOM", frame, "BOTTOM", 60, 40)
    hideButton:SetSize(120, 30)
    hideButton:SetText("Hide Alert")
    hideButton:SetScript("OnClick", function()
        if CCAlert.alertFrame then
            CCAlert.alertFrame:Hide()
        end
    end)

    local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    footer:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    footer:SetText("c0ded by enjoymygripz")

    return frame
end

local settingsPanel = CreateSettingsPanel()

SLASH_CCALERT1 = "/ccalert"
SlashCmdList["CCALERT"] = function(msg)
    settingsPanel:Show()
end
