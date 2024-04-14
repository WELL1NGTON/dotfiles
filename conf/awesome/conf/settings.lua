---@class (exact) Settings
---@field terminal string
---@field editor string
---@field filebrowser string
---@field browser string
---@field mail string
---@field modkey string
---@field altmod string
---@field editor_cmd string
local settings = {
	terminal = os.getenv("TERM") or "alacritty",
	editor = os.getenv("EDITOR") or "nvim",
	filebrowser = os.getenv("FILEBROWSER") or "pcmanfm",
	browser = os.getenv("BROWSER") or "firefox",
	mail = os.getenv("MAIL") or "thunderbird",
	modkey = "Mod4",
	altmod = "Mod1",
	editor_cmd = "",
}

settings.editor_cmd = settings.terminal .. " -e " .. settings.editor

return settings
