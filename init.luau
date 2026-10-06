-- Duck Hub Core Configuration
local GITHUB_USER = "olliecl" 
local REPO_NAME = "Duck-hub"
local BRANCH = "refs/heads/main"
local WHITELIST_FILE = "whitelisted.txt"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-------------------------------------------------------------------------------
-- 1. WHITELIST & DEVELOPER BYPASS SYSTEM
-------------------------------------------------------------------------------
local DeveloperList = {
    ["rggc_holder"] = true, 
    ["xepol1te"] = true, 
    ["o_lliecl"] = true
}

local function CheckWhitelist()
    local usernameStr = string.lower(LocalPlayer.Name)
    if DeveloperList[usernameStr] then return true end
    
    local whitelistUrl = string.format("https://githubusercontent.com", GITHUB_USER, REPO_NAME, BRANCH, WHITELIST_FILE)
    local success, content = pcall(function() return game:HttpGet(whitelistUrl) end)
    
    if success then
        for line in string.gmatch(content, "[^\r\n]+") do
            local cleanLine = string.gsub(line, "%s+", "")
            if cleanLine == tostring(LocalPlayer.UserId) or string.lower(cleanLine) == usernameStr then
                return true
            end
        end
    end
    return false
end

if not CheckWhitelist() then
    LocalPlayer:Kick("Duck Hub: You are not whitelisted to access this script.")
    return
end

-------------------------------------------------------------------------------
-- 2. UI LIBRARY INITIALIZATION
-------------------------------------------------------------------------------
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Duck Hub 🦆",
    SubTitle = "by olliecl & team",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local checkGameUrl = string.format("https://githubusercontent.com", GITHUB_USER, REPO_NAME, BRANCH, tostring(PlaceId))
local gameCheckSuccess, _ = pcall(function() return game:HttpGet(checkGameUrl) end)
local gameSupportedText = gameCheckSuccess and "✅ Supported" or "❌ Not Supported"

local Tabs = {
    Home = Window:AddTab({ Title = "Home Base", Icon = "home" }),
    Trusted = Window:AddTab({ Title = "Trusted Scripts", Icon = "star" }),
    GameModules = Window:AddTab({ Title = "Game Modules", Icon = "gamepad" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- SHARE CONTEXT GLOBALLY FOR GAME FILES TO PIN TO
_G.DuckHubModules = {
    Fluent = Fluent,
    Window = Window,
    GameTab = Tabs.GameModules
}

Tabs.Home:AddParagraph({ Title = "Status", Content = "User: "..LocalPlayer.Name.."\nGame Status: "..gameSupportedText })
Tabs.Home:AddParagraph({ Title = "Credits", Content = "Developed exclusively by and for: RGGC_Holder, Xepol1te, and o_lliecl." })

Tabs.Trusted:AddButton({
    Title = "Load Infinite Yield",
    Callback = function() loadstring(game:HttpGet("https://githubusercontent.com"))() end
})

-------------------------------------------------------------------------------
-- 3. LOAD GAME PROFILE DYNAMICALLY
-------------------------------------------------------------------------------
if gameCheckSuccess then
    -- Run pcall to trap execution errors so if a game script has a bug, the framework stays open
    local ok, err = pcall(function()
        loadstring(game:HttpGet(checkGameUrl))()
    end)
    if not ok then
        warn("Duck Hub Game Script Error: " .. tostring(err))
    end
else
    Tabs.GameModules:AddParagraph({ Title = "Unsupported", Content = "No active map profile configuration mapped." })
end

if DeveloperList[string.lower(LocalPlayer.Name)] then
    Tabs.Developer = Window:AddTab({ Title = "Dev Matrix", Icon = "shield" })
    Tabs.Developer:AddButton({ Title = "Disconnect Client Instance", Callback = function() LocalPlayer:Kick("Shutdown executed.") end })
end

Tabs.Settings:AddDropdown("ThemeDropdown", {
    Title = "Theme Profile", Values = {"Dark", "Light", "Amethyst", "Aqua"}, CurrentValue = "Dark",
    Callback = function(Value) Window:SetTheme(Value) end
})

Window:SelectTab(1)
