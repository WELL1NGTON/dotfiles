---------------------------
-- Default awesome theme --
---------------------------

local rnotification = require("ruled.notification")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local global_themes_path = "/usr/share/awesome/themes/"

local theme = {}

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")

local function get_icon_path(icon_name)
    local theme = Gtk.IconTheme.get_default()
    local info = theme:lookup_icon(icon_name, 48, 0)
    if info then
        return info:get_filename()
    end
    return nil
end

-- theme.font = "Fira Sans 10"
theme.font = "Fira Sans 12"

theme.bg_normal = "#222222"
theme.bg_focus = "#737dcc"
theme.bg_urgent = "#ff0000"
theme.bg_minimize = "#444444"
theme.bg_systray = theme.bg_normal

theme.fg_normal = "#aaaaaa"
theme.fg_focus = "#ffffff"
theme.fg_urgent = "#ffffff"
theme.fg_minimize = "#ffffff"

theme.useless_gap = dpi(3)
theme.border_width = dpi(1)
theme.border_color_normal = "#000000"
theme.border_color_active = "#737dcc"
theme.border_color_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = get_icon_path("pan-end-symbolic")
theme.menu_height = dpi(20)
theme.menu_width = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = get_icon_path("window-close-symbolic")
theme.titlebar_close_button_focus = get_icon_path("window-close")

theme.titlebar_minimize_button_normal = get_icon_path("window-minimize-symbolic")
theme.titlebar_minimize_button_focus = get_icon_path("window-minimize")

theme.titlebar_ontop_button_normal_inactive = get_icon_path("go-top-symbolic")
theme.titlebar_ontop_button_focus_inactive = get_icon_path("go-top")
theme.titlebar_ontop_button_normal_active = get_icon_path("view-paged-symbolic")
theme.titlebar_ontop_button_focus_active = get_icon_path("view-paged")

theme.titlebar_sticky_button_normal_inactive = global_themes_path .. "default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = global_themes_path .. "default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = global_themes_path .. "default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = global_themes_path .. "default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = get_icon_path("view-grid-symbolic")
theme.titlebar_floating_button_focus_inactive = get_icon_path("view-grid")
theme.titlebar_floating_button_normal_active = get_icon_path("airplane-mode-symbolic")
theme.titlebar_floating_button_focus_active = get_icon_path("airplane-mode-symbolic")

theme.titlebar_maximized_button_normal_inactive = get_icon_path("view-fullscreen-symbolic")
theme.titlebar_maximized_button_focus_inactive = get_icon_path("view-fullscreen")
theme.titlebar_maximized_button_normal_active = get_icon_path("view-restore-symbolic")
theme.titlebar_maximized_button_focus_active = get_icon_path("view-restore")

local background_path = "/usr/share/backgrounds/archlinux/landscape.jpg"

if not gfs.file_readable(background_path) then
    background_path = global_themes_path .. "default/background.png"
end
theme.wallpaper = background_path

-- You can use your own layout icons like this:
theme.layout_fairh = global_themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv = global_themes_path .. "default/layouts/fairvw.png"
theme.layout_floating = global_themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier = global_themes_path .. "default/layouts/magnifierw.png"
theme.layout_max = global_themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = global_themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = global_themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft = global_themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile = global_themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop = global_themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral = global_themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle = global_themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw = global_themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne = global_themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw = global_themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse = global_themes_path .. "default/layouts/cornersew.png"

-- Arch awesome icon modified to be blue
-- source: https://sources.archlinux.org/other/artwork/archlinux-artwork-1.6.tar.gz
theme.awesome_icon = themes_path .. "mytheme/archlinux-wm-awesome.svg"
theme.awesome_icon_highlight = themes_path .. "mytheme/archlinux-wm-awesome-highlight.svg"

-- local awesome_icon_data_as_str = io.open(theme.awesome_icon, "r"):read("*all")
-- -- replace 5bb0ff for 80caff
-- awesome_icon_data_as_str = awesome_icon_data_as_str:gsub("5bb0ff", "80caff")
-- -- replace 1a4e89 for 4fa1ff
-- awesome_icon_data_as_str = awesome_icon_data_as_str:gsub("1a4e89", "4fa1ff")

-- theme.awesome_icon_highlighted = awesome_icon_data_as_str



-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

-- Set different colors for urgent notifications.
rnotification.connect_signal("request::rules", function()
    rnotification.append_rule({
        rule = { urgency = "critical" },
        properties = { bg = "#ff0000", fg = "#ffffff" },
    })
end)

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
