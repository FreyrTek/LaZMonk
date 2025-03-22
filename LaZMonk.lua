local addonName, addon = ...  -- Get addon name and namespace

print("LaZMonk: Addon loading...")  -- Debug: Confirm addon starts

-- Initialize LaZMonkDB if it doesn't exist
LaZMonkDB = LaZMonkDB or {}

-- Function to check if the player is a Mistweaver Monk
local function IsMistweaverMonk()
    local _, class = UnitClass("player")  -- e.g., "MONK"
    local spec = GetSpecialization()  -- 1-4 for active spec
    local specID = spec and GetSpecializationInfo(spec)  -- Returns spec ID (270 for Mistweaver)
    local isMistweaver = class == "MONK" and specID == 270
    -- print("LaZMonk: Class = " .. class .. ", Spec ID = " .. (specID or "nil") .. ", Is Mistweaver = " .. tostring(isMistweaver))
    return isMistweaver
end

-- Early exit if not a Mistweaver Monk (but allow initial load for debugging)
-- if not IsMistweaverMonk() then
--     print("LaZMonk: Not a Mistweaver Monk, exiting.")
--     return
-- end

-- Create the parent frame for the group
local groupFrame = CreateFrame("Frame", "LaZMonkGroupFrame", UIParent)
groupFrame:SetSize(128, 192)
groupFrame:SetPoint("CENTER", 0, 0)
groupFrame:SetMovable(true)

-- Create the drag tab
local dragTab = CreateFrame("Frame", "LaZMonkDragTab", groupFrame)
dragTab:SetSize(10, 10)
dragTab:SetPoint("BOTTOM", groupFrame, "TOPRIGHT", 0, 2)
dragTab:EnableMouse(true)
dragTab:SetMovable(true)
dragTab:RegisterForDrag("LeftButton")

local bgTexture = dragTab:CreateTexture(nil, "BACKGROUND")
bgTexture:SetAllPoints(dragTab)
bgTexture:SetColorTexture(0.86, 0.08, 0.24, 1)

local borderTop = dragTab:CreateTexture(nil, "BORDER")
borderTop:SetColorTexture(0, 0, 0, 1)
borderTop:SetPoint("TOPLEFT", dragTab, "TOPLEFT", 0, 0)
borderTop:SetPoint("TOPRIGHT", dragTab, "TOPRIGHT", 0, 0)
borderTop:SetHeight(1)

local borderBottom = dragTab:CreateTexture(nil, "BORDER")
borderBottom:SetColorTexture(0, 0, 0, 1)
borderBottom:SetPoint("BOTTOMLEFT", dragTab, "BOTTOMLEFT", 0, 0)
borderBottom:SetPoint("BOTTOMRIGHT", dragTab, "BOTTOMRIGHT", 0, 0)
borderBottom:SetHeight(1)

local borderLeft = dragTab:CreateTexture(nil, "BORDER")
borderLeft:SetColorTexture(0, 0, 0, 1)
borderLeft:SetPoint("TOPLEFT", dragTab, "TOPLEFT", 0, 0)
borderLeft:SetPoint("BOTTOMLEFT", dragTab, "BOTTOMLEFT", 0, 0)
borderLeft:SetWidth(1)

local borderRight = dragTab:CreateTexture(nil, "BORDER")
borderRight:SetColorTexture(0, 0, 0, 1)
borderRight:SetPoint("TOPRIGHT", dragTab, "TOPRIGHT", 0, 0)
borderRight:SetPoint("BOTTOMRIGHT", dragTab, "BOTTOMRIGHT", 0, 0)
borderRight:SetWidth(1)

dragTab:SetScript("OnDragStart", function(self)
    if self:IsMovable() then
        self:GetParent():StartMoving()
    end
end)
dragTab:SetScript("OnDragStop", function(self)
    self:GetParent():StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetParent():GetPoint()
    LaZMonkDB.position = LaZMonkDB.position or {}
    LaZMonkDB.position.point = point
    LaZMonkDB.position.relativePoint = relativePoint
    LaZMonkDB.position.xOfs = xOfs
    LaZMonkDB.position.yOfs = yOfs
end)

-- Create the mute button
local muteButton = CreateFrame("Button", "LaZMonkMuteButton", groupFrame)
muteButton:SetSize(10, 10)
muteButton:SetPoint("RIGHT", dragTab, "LEFT", -2, 0)
muteButton:EnableMouse(true)

local muteTexture = muteButton:CreateTexture(nil, "BACKGROUND")
muteTexture:SetAllPoints(muteButton)
muteTexture:SetColorTexture(0, 0, 1, 1)

local muteBorderTop = muteButton:CreateTexture(nil, "BORDER")
muteBorderTop:SetColorTexture(0, 0, 0, 1)
muteBorderTop:SetPoint("TOPLEFT", muteButton, "TOPLEFT", 0, 0)
muteBorderTop:SetPoint("TOPRIGHT", muteButton, "TOPRIGHT", 0, 0)
muteBorderTop:SetHeight(1)

local muteBorderBottom = muteButton:CreateTexture(nil, "BORDER")
muteBorderBottom:SetColorTexture(0, 0, 0, 1)
muteBorderBottom:SetPoint("BOTTOMLEFT", muteButton, "BOTTOMLEFT", 0, 0)
muteBorderBottom:SetPoint("BOTTOMRIGHT", muteButton, "BOTTOMRIGHT", 0, 0)
muteBorderBottom:SetHeight(1)

local muteBorderLeft = muteButton:CreateTexture(nil, "BORDER")
muteBorderLeft:SetColorTexture(0, 0, 0, 1)
muteBorderLeft:SetPoint("TOPLEFT", muteButton, "TOPLEFT", 0, 0)
muteBorderLeft:SetPoint("BOTTOMLEFT", muteButton, "BOTTOMLEFT", 0, 0)
muteBorderLeft:SetWidth(1)

local muteBorderRight = muteButton:CreateTexture(nil, "BORDER")
muteBorderRight:SetColorTexture(0, 0, 0, 1)
muteBorderRight:SetPoint("TOPRIGHT", muteButton, "TOPRIGHT", 0, 0)
muteBorderRight:SetPoint("BOTTOMRIGHT", muteButton, "BOTTOMRIGHT", 0, 0)
muteBorderRight:SetWidth(1)

local function UpdateMuteButton()
    if LaZMonkDB.muted then
        muteTexture:SetColorTexture(1, 1, 0, 1)  -- Yellow when muted
    else
        muteTexture:SetColorTexture(0, 0, 1, 1)  -- Blue when unmuted
    end
end

muteButton:SetScript("OnClick", function()
    LaZMonkDB.muted = not LaZMonkDB.muted
    UpdateMuteButton()
    print("LaZMonk: Sound " .. (LaZMonkDB.muted and "muted" or "unmuted"))
end)

-- Mana Tea frame (top-right)
local manaTeaFrame = CreateFrame("Frame", "LaZMonkManaTeaFrame", groupFrame)
manaTeaFrame:SetSize(64, 64)
manaTeaFrame:SetPoint("TOPRIGHT", 0, 0)
manaTeaFrame:EnableMouse(true)

local manaTeaIcon = manaTeaFrame:CreateTexture(nil, "BACKGROUND")
manaTeaIcon:SetAllPoints(manaTeaFrame)
manaTeaIcon:SetTexture(C_Spell.GetSpellTexture(197908))

local manaTeaStackText = manaTeaFrame:CreateFontString(nil, "OVERLAY")
manaTeaStackText:SetFont("Fonts\\FRIZQT__.TTF", 24, "BOLD")
manaTeaStackText:SetPoint("CENTER", manaTeaFrame, "CENTER")
manaTeaStackText:SetTextColor(1, 1, 1, 1)
manaTeaStackText:SetShadowOffset(1, -1)
manaTeaStackText:SetShadowColor(0, 0, 0, 1)

local manaTeaGlow = manaTeaFrame:CreateTexture(nil, "OVERLAY")
manaTeaGlow:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
manaTeaGlow:SetPoint("CENTER", manaTeaFrame, "CENTER")
manaTeaGlow:SetSize(80, 80)
manaTeaGlow:Hide()

-- Renewing Mist frame (top-left)
local renewingMistFrame = CreateFrame("Frame", "LaZMonkRenewingMistFrame", groupFrame)
renewingMistFrame:SetSize(64, 64)
renewingMistFrame:SetPoint("RIGHT", manaTeaFrame, "LEFT", 0, 0)
renewingMistFrame:EnableMouse(true)

local renewingMistIcon = renewingMistFrame:CreateTexture(nil, "BACKGROUND")
renewingMistIcon:SetAllPoints(renewingMistFrame)
renewingMistIcon:SetTexture(C_Spell.GetSpellTexture(115151))

local renewingMistChargeText = renewingMistFrame:CreateFontString(nil, "OVERLAY")
renewingMistChargeText:SetFont("Fonts\\FRIZQT__.TTF", 24, "BOLD")
renewingMistChargeText:SetPoint("CENTER", renewingMistFrame, "CENTER")
renewingMistChargeText:SetTextColor(1, 1, 1, 1)
renewingMistChargeText:SetShadowOffset(1, -1)
renewingMistChargeText:SetShadowColor(0, 0, 0, 1)

-- Invoke frame (middle-right)
local invokeFrame = CreateFrame("Frame", "LaZMonkInvokeFrame", groupFrame)
invokeFrame:SetSize(64, 64)
invokeFrame:SetPoint("TOP", manaTeaFrame, "BOTTOM", 0, 0)
invokeFrame:EnableMouse(true)

local invokeIcon = invokeFrame:CreateTexture(nil, "BACKGROUND")
invokeIcon:SetAllPoints(invokeFrame)

local invokeCooldownText = invokeFrame:CreateFontString(nil, "OVERLAY")
invokeCooldownText:SetFont("Fonts\\FRIZQT__.TTF", 14, "BOLD")
invokeCooldownText:SetPoint("CENTER", invokeFrame, "CENTER")
invokeCooldownText:SetTextColor(1, 0, 0, 1)
invokeCooldownText:SetShadowOffset(1, -1)
invokeCooldownText:SetShadowColor(0, 0, 0, 1)

-- Life Cocoon frame (middle-left)
local lifeCocoonFrame = CreateFrame("Frame", "LaZMonkLifeCocoonFrame", groupFrame)
lifeCocoonFrame:SetSize(64, 64)
lifeCocoonFrame:SetPoint("RIGHT", invokeFrame, "LEFT", 0, 0)
lifeCocoonFrame:EnableMouse(true)

local lifeCocoonIcon = lifeCocoonFrame:CreateTexture(nil, "BACKGROUND")
lifeCocoonIcon:SetAllPoints(lifeCocoonFrame)
lifeCocoonIcon:SetTexture(C_Spell.GetSpellTexture(116849))

local lifeCocoonCooldownText = lifeCocoonFrame:CreateFontString(nil, "OVERLAY")
lifeCocoonCooldownText:SetFont("Fonts\\FRIZQT__.TTF", 14, "BOLD")
lifeCocoonCooldownText:SetPoint("CENTER", lifeCocoonFrame, "CENTER")
lifeCocoonCooldownText:SetTextColor(1, 0, 0, 1)
lifeCocoonCooldownText:SetShadowOffset(1, -1)
lifeCocoonCooldownText:SetShadowColor(0, 0, 0, 1)

-- Vivify frame (bottom-left)
local vivifyFrame = CreateFrame("Frame", "LaZMonkVivifyFrame", groupFrame)
vivifyFrame:SetSize(64, 64)
vivifyFrame:SetPoint("TOP", lifeCocoonFrame, "BOTTOM", 0, 0)
vivifyFrame:EnableMouse(true)

local vivifyIcon = vivifyFrame:CreateTexture(nil, "BACKGROUND")
vivifyIcon:SetAllPoints(vivifyFrame)
vivifyIcon:SetTexture(C_Spell.GetSpellTexture(116670))

-- Thunder Focus Tea frame (bottom-right)
local thunderFocusTeaFrame = CreateFrame("Frame", "LaZMonkThunderFocusTeaFrame", groupFrame)
thunderFocusTeaFrame:SetSize(64, 64)
thunderFocusTeaFrame:SetPoint("TOP", invokeFrame, "BOTTOM", 0, 0)
thunderFocusTeaFrame:EnableMouse(true)
thunderFocusTeaFrame:Hide()

local thunderFocusTeaIcon = thunderFocusTeaFrame:CreateTexture(nil, "BACKGROUND")
thunderFocusTeaIcon:SetAllPoints(thunderFocusTeaFrame)
thunderFocusTeaIcon:SetTexture(C_Spell.GetSpellTexture(116680))

local thunderFocusTeaCooldownText = thunderFocusTeaFrame:CreateFontString(nil, "OVERLAY")
thunderFocusTeaCooldownText:SetFont("Fonts\\FRIZQT__.TTF", 14, "BOLD")
thunderFocusTeaCooldownText:SetPoint("CENTER", thunderFocusTeaFrame, "CENTER")
thunderFocusTeaCooldownText:SetTextColor(1, 0, 0, 1)
thunderFocusTeaCooldownText:SetShadowOffset(1, -1)
thunderFocusTeaCooldownText:SetShadowColor(0, 0, 0, 1)

-- Spell IDs and Aura Names
local MANA_TEA_SPELL_ID = 115867
local RENEWING_MIST_SPELL_ID = 115151
local CHI_JI_SPELL_ID = 325197
local YULON_SPELL_ID = 322118
local LIFE_COCOON_SPELL_ID = 116849
local VIVIFY_SPELL_ID = 116670
local THUNDER_FOCUS_TEA_SPELL_ID = 116680
local VIVACIOUS_VIVIFICATION_AURA = "Vivacious Vivification"

-- Variables
local lastManaTeaStacks = 0
local vivifySoundPlayed = false
local manaTeaTimer = nil
local lastRenewingMistCharges = 0
local wasLifeCocoonOnCooldown = false
local isInitialized = false
local activeInvokeSpellId = nil
local activeInvokeIcon = nil
local celestial_available = true
local last_celestial_state = true
local isFirstInvokeUpdate = true

-- Format cooldown time
local function FormatCooldown(seconds)
    if seconds > 60 then
        return string.format("%dm", math.ceil(seconds / 60))
    elseif seconds > 0 then
        return string.format("%d", math.ceil(seconds))
    else
        return ""
    end
end

-- Sound helper function
local function PlaySoundIfUnmuted(sound, channel)
    if not LaZMonkDB.muted then
        if type(sound) == "number" then
            PlaySound(sound, channel)
        else
            PlaySoundFile(sound, channel)
        end
    end
end

-- Determine active Invoke talent
local function DetermineActiveInvoke()
    if IsPlayerSpell(CHI_JI_SPELL_ID) then
        activeInvokeSpellId = CHI_JI_SPELL_ID
        activeInvokeIcon = C_Spell.GetSpellTexture(CHI_JI_SPELL_ID)
    elseif IsPlayerSpell(YULON_SPELL_ID) then
        activeInvokeSpellId = YULON_SPELL_ID
        activeInvokeIcon = C_Spell.GetSpellTexture(YULON_SPELL_ID)
    else
        activeInvokeSpellId = nil
        activeInvokeIcon = nil
    end
    if activeInvokeSpellId then
        local cooldownInfo = C_Spell.GetSpellCooldown(activeInvokeSpellId)
        celestial_available = cooldownInfo and (cooldownInfo.startTime == 0 or (cooldownInfo.startTime + cooldownInfo.duration - GetTime()) <= 0)
        last_celestial_state = celestial_available
    else
        celestial_available = false
        last_celestial_state = false
    end
end

-- Update Mana Tea
local function UpdateManaTea()
    local name, _, count = AuraUtil.FindAuraByName("Mana Tea", "player", "HELPFUL")
    count = count or 0
    manaTeaStackText:SetText(count > 0 and count or "")
    if count >= 10 then
        manaTeaGlow:Show()
    else
        manaTeaGlow:Hide()
    end
    if count ~= lastManaTeaStacks and isInitialized then
        if count == 10 then
            PlaySoundIfUnmuted(113999, "Master")
            C_Timer.After(0.5, function() PlaySoundIfUnmuted(113999, "Master") end)
        elseif count == 20 then
            PlaySoundIfUnmuted("Interface\\AddOns\\LaZMonk\\Sounds\\20stacks.ogg", "Master")
            if manaTeaTimer then manaTeaTimer:Cancel() end
            manaTeaTimer = C_Timer.NewTimer(60, function()
                if AuraUtil.FindAuraByName("Mana Tea", "player", "HELPFUL") and count == 20 then
                    PlaySoundIfUnmuted("Interface\\AddOns\\LaZMonk\\Sounds\\lazyMonk.ogg", "Master")
                end
            end)
        elseif count < 20 and manaTeaTimer then
            manaTeaTimer:Cancel()
            manaTeaTimer = nil
        end
    end
    lastManaTeaStacks = count
    manaTeaFrame:SetShown(count > 0)
end

-- Update Renewing Mist
local function UpdateRenewingMist()
    local chargeInfo = C_Spell.GetSpellCharges(RENEWING_MIST_SPELL_ID)
    local charges = chargeInfo and chargeInfo.currentCharges or 0
    renewingMistChargeText:SetText(charges > 0 and charges or "")
    renewingMistFrame:SetShown(charges > 0)
    if isInitialized and lastRenewingMistCharges == 0 and charges == 1 then
        PlaySoundIfUnmuted("Interface\\AddOns\\LaZMonk\\Sounds\\healingMist.ogg", "Master")
    end
    lastRenewingMistCharges = charges
end

-- Update Invoke
local function UpdateInvoke()
    if not activeInvokeSpellId then
        invokeFrame:Hide()
        celestial_available = false
        last_celestial_state = false
        isFirstInvokeUpdate = true
        invokeCooldownText:SetText("")
        return
    end
    local cooldownInfo = C_Spell.GetSpellCooldown(activeInvokeSpellId)
    local remaining = cooldownInfo and (cooldownInfo.startTime > 0 and (cooldownInfo.startTime + cooldownInfo.duration - GetTime())) or 0
    local isOffCooldown = remaining <= 0
    invokeCooldownText:SetText(FormatCooldown(remaining))
    if isOffCooldown and not celestial_available then
        celestial_available = true
    end
    if isFirstInvokeUpdate then
        if celestial_available then
            invokeIcon:SetTexture(activeInvokeIcon)
            invokeFrame:Show()
        else
            invokeFrame:Hide()
        end
        last_celestial_state = celestial_available
        isFirstInvokeUpdate = false
    elseif celestial_available ~= last_celestial_state then
        if celestial_available then
            invokeIcon:SetTexture(activeInvokeIcon)
            invokeFrame:Show()
            if isInitialized then
                PlaySoundIfUnmuted("Interface\\AddOns\\LaZMonk\\Sounds\\celestial.ogg", "Master")
            end
        else
            invokeFrame:Hide()
        end
        last_celestial_state = celestial_available
    elseif celestial_available then
        invokeIcon:SetTexture(activeInvokeIcon)
    end
end

-- Update Life Cocoon
local function UpdateLifeCocoon()
    local cooldownInfo = C_Spell.GetSpellCooldown(LIFE_COCOON_SPELL_ID)
    local remaining = cooldownInfo and (cooldownInfo.startTime > 0 and (cooldownInfo.startTime + cooldownInfo.duration - GetTime())) or 0
    local isOffCooldown = remaining <= 0
    lifeCocoonCooldownText:SetText(FormatCooldown(remaining))
    if isOffCooldown then
        lifeCocoonFrame:Show()
        if wasLifeCocoonOnCooldown and isInitialized then
            PlaySoundIfUnmuted("Interface\\AddOns\\LaZMonk\\Sounds\\cacoon.ogg", "Master")
        end
        wasLifeCocoonOnCooldown = false
    else
        lifeCocoonFrame:Hide()
        wasLifeCocoonOnCooldown = true
    end
end

-- Update Vivify
local function UpdateVivify()
    local name = AuraUtil.FindAuraByName(VIVACIOUS_VIVIFICATION_AURA, "player", "HELPFUL")
    if name then
        vivifyFrame:Show()
        if not vivifySoundPlayed and isInitialized then
            PlaySoundIfUnmuted(5274, "Master")
            --PlaySoundIfUnmuted("Interface\\AddOns\\LaZMonk\\Sounds\\FreeHeal.ogg", "Master")
            vivifySoundPlayed = true
        end
    else
        vivifyFrame:Hide()
        vivifySoundPlayed = false
    end
end

-- Update Thunder Focus Tea
local function UpdateThunderFocusTea()
    local cooldownInfo = C_Spell.GetSpellCooldown(THUNDER_FOCUS_TEA_SPELL_ID)
    local remaining = cooldownInfo and (cooldownInfo.startTime > 0 and (cooldownInfo.startTime + cooldownInfo.duration - GetTime())) or 0
    local isOffCooldown = remaining <= 0
    thunderFocusTeaCooldownText:SetText(FormatCooldown(remaining))
    thunderFocusTeaFrame:SetShown(isOffCooldown)
end

-- Handle spell casts
local function OnSpellCast(unit, _, spellId)
    if unit == "player" and isInitialized then
        if spellId == YULON_SPELL_ID or spellId == CHI_JI_SPELL_ID then
            PlaySoundIfUnmuted("Interface\\AddOns\\LaZMonk\\Sounds\\sausage.ogg", "Master")
            celestial_available = false
        end
    end
end

-- Refresh all icons
local function RefreshIcons()
    manaTeaIcon:SetTexture(C_Spell.GetSpellTexture(197908))
    renewingMistIcon:SetTexture(C_Spell.GetSpellTexture(115151))
    lifeCocoonIcon:SetTexture(C_Spell.GetSpellTexture(116849))
    vivifyIcon:SetTexture(C_Spell.GetSpellTexture(116670))
    thunderFocusTeaIcon:SetTexture(C_Spell.GetSpellTexture(116680))
    if activeInvokeSpellId then
        invokeIcon:SetTexture(activeInvokeIcon)
    end
end

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:SetScript("OnEvent", function(self, event, unit, ...)
    if event == "UNIT_AURA" and unit == "player" then
        UpdateManaTea()
        UpdateVivify()
    elseif event == "SPELL_UPDATE_CHARGES" then
        UpdateRenewingMist()
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        UpdateInvoke()
        UpdateLifeCocoon()
        UpdateThunderFocusTea()
    elseif event == "PLAYER_TALENT_UPDATE" then
        --print("LaZMonk: Talent update detected")
        if not IsMistweaverMonk() then
            groupFrame:Hide()
            return
        end
        lastManaTeaStacks = 0
        if manaTeaTimer then manaTeaTimer:Cancel() manaTeaTimer = nil end
        lastRenewingMistCharges = 0
        celestial_available = true
        last_celestial_state = true
        isFirstInvokeUpdate = true
        wasLifeCocoonOnCooldown = false
        vivifySoundPlayed = false
        DetermineActiveInvoke()
        RefreshIcons()
        UpdateManaTea()
        UpdateRenewingMist()
        UpdateInvoke()
        UpdateLifeCocoon()
        UpdateVivify()
        UpdateThunderFocusTea()
        groupFrame:Show()  -- Ensure frame is visible after talent update
    elseif event == "PLAYER_LOGIN" then
        --print("LaZMonk: Player login detected")
        if not IsMistweaverMonk() then
            groupFrame:Hide()
            return
        end
        LaZMonkDB.muted = LaZMonkDB.muted or false  -- Default to unmuted
        UpdateMuteButton()
        if LaZMonkDB and LaZMonkDB.position then
            local pos = LaZMonkDB.position
            groupFrame:ClearAllPoints()
            groupFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        end
        DetermineActiveInvoke()
        RefreshIcons()
        UpdateManaTea()
        UpdateRenewingMist()
        UpdateInvoke()
        UpdateLifeCocoon()
        UpdateVivify()
        UpdateThunderFocusTea()
        isInitialized = true
        groupFrame:Show()  -- Force show on login
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        OnSpellCast(unit, ...)
    end
end)

-- Slash command
SLASH_LAZMONK1 = "/lazmonk"
SlashCmdList["LAZMONK"] = function(msg)
    if msg == "toggle" then
        if groupFrame:IsShown() then
            groupFrame:Hide()
            print("LaZMonk: Frame hidden")
        else
            groupFrame:Show()
            print("LaZMonk: Frame shown")
        end
    elseif msg == "togglesound" then
        LaZMonkDB.muted = not LaZMonkDB.muted
        UpdateMuteButton()
        print("LaZMonk: Sound " .. (LaZMonkDB.muted and "muted" or "unmuted"))
    else
        print("LaZMonk: Use '/lazmonk toggle' to show or hide the frame, or '/lazmonk togglesound' to toggle sound")
    end
end

print("LaZMonk: Addon fully loaded")