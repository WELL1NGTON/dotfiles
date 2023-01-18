---@class Settings
local settings =
{
    ---@type string
    terminal = os.getenv("TERM") or "alacritty",
    ---@type string
    editor = os.getenv("EDITOR") or "nvim",
    ---@type string
    filebrowser = os.getenv("FILEBROWSER") or "pcmanfm",
    ---@type string
    browser = os.getenv("BROWSER") or "firefox",
    ---@type string
    mail = os.getenv("MAIL") or "thunderbird",
    ---@type string
    modkey = "Mod4",
    ---@type string
    altmod = "Mod1",
    ---@type string
    editor_cmd = "",
}

settings.editor_cmd = settings.terminal .. " -e " .. settings.editor;

return settings
