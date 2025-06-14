-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")

-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
local gfs = require("gears.filesystem")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local ruled = require("ruled")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification({
        urgency = "critical",
        title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
        message = message,
    })
end)
-- }}}

-- {{{ Variable definitions

-- TODO: Find a better place for helper methods like fix_startup_id

local function get_icon_path(icon_name)
    local theme = Gtk.IconTheme.get_default()
    local info = theme:lookup_icon(icon_name, 48, 0)
    if info then
        return info:get_filename()
    end
    return nil
end

local function notify_send(msg, title)
    if not title then
        awful.spawn.with_shell({
            "notify-send",
            msg,
        })
    else
        awful.spawn.with_shell({
            "notify-send",
            title,
            msg,
        })
    end
end

-- custom/temporary debug variable
local is_debug_enabled = false

-- boolean to indicate if the titlebars should be visible or hidden
local is_titlebars_visible = false

-- Themes define colours, icons, font and wallpapers.
local awesome_theme = gears.filesystem.get_themes_dir() .. "mytheme/theme.lua"
-- TODO: debug notification, remove
-- naughty.notification({ urgency = 'critical', title = awesome_theme, message = awesome_theme })
if not gfs.file_readable(awesome_theme) then
    awesome_theme = "/usr/share/awesome/themes/default/theme.lua"
end
beautiful.init(awesome_theme)

-- This is used later as the default terminal and editor to run.
local terminal = "kitty"
local editor = os.getenv("EDITOR") or "nvim"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"

-- function helper to show/hide titlebars
local function update_titlebars_visible()
    local current_clients = client.get()
    for _, c in ipairs(current_clients) do
        if is_titlebars_visible then
            awful.titlebar.show(c)
        else
            awful.titlebar.hide(c)
        end
    end
end

-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local my_awesome_menu = {
    {
        "docs",
        function()
            awful.spawn("xdg-open https://awesomewm.org/apidoc/")
        end,
        get_icon_path("text-html"),
    },
    {
        "hotkeys",
        function()
            hotkeys_popup.show_help(nil, awful.screen.focused())
        end,
        get_icon_path("input-keyboard"),
    },
    { "manual",      terminal .. " -e man awesome",         get_icon_path("help-contents") },
    { "edit config", editor_cmd .. " " .. awesome.conffile, get_icon_path("preferences-system") },
    { "restart",     awesome.restart,                       get_icon_path("view-refresh") },
    {
        "quit",
        function()
            awesome.quit()
        end,
        get_icon_path("application-exit"),
    },
}

-- icons specification: https://specifications.freedesktop.org/icon-naming-spec/latest/
-- can check icons installing package gtk3-demos and opening gtk3-icon-browser
local power_menu = {
    { "lock",      function() awful.spawn({ "i3lock", "--pointer=default" }) end, get_icon_path("system-lock-screen") },
    { "sleep",     function() awful.spawn({ "systemctl", "sleep" }) end,          get_icon_path("preferences-desktop-screensaver-symbolic") },
    { "suspend",   function() awful.spawn({ "systemctl", "suspend" }) end,        get_icon_path("system-suspend") },
    { "hibernate", function() awful.spawn({ "systemctl", "hibernate" }) end,      get_icon_path("system-hibernate") },
    { "reboot",    function() awful.spawn({ "systemctl", "reboot" }) end,         get_icon_path("system-reboot") },
    { "shutdown",  function() awful.spawn({ "systemctl", "poweroff" }) end,       get_icon_path("system-shutdown") },
}
local applications_menu = {
    { "app launcher",   function() awful.spawn("rofi -show drun -no-click-to-exit") end,                  get_icon_path("applications-other") },
    { "editor",         editor_cmd,                                                                       get_icon_path("text-editor") },
    { "file manager",   function() awful.spawn("pcmanfm") end,                                            get_icon_path("file-manager") },
    { "screenshot",     function() awful.spawn({ "flameshot", "gui" }) end,                               get_icon_path("flameshot") },
    { "screenshot ocr", function() awful.spawn({ os.getenv("HOME") .. "/.local/bin/flameshot-ocr" }) end, get_icon_path("flameshot") },
    { "terminal",       terminal,                                                                         get_icon_path("kitty") },
    { "web browser",    function() awful.spawn({ "flatpak", "run", "one.ablaze.floorp" }) end,            get_icon_path("browser") },
}

local my_main_menu = awful.menu({
    items = {
        { "applications", applications_menu, get_icon_path("applications-system") },
        { "awesome",      my_awesome_menu,   beautiful.awesome_icon },
        { "power",        power_menu,        get_icon_path("system-shutdown") },
    },
    theme = {
        width = dpi(150),
        height = dpi(24),
        border_width = dpi(2),
        border_color = "#737dcc",
        font = beautiful.menu_font,
    },
})

local my_launcher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = my_main_menu })
my_launcher.forced_width = dpi(42)
my_launcher.valign = "center"
my_launcher.halign = "center"
my_launcher:connect_signal("mouse::enter", function()
    my_launcher.image = beautiful.awesome_icon_highlight
    my_launcher:emit_signal("widget::redraw_needed")
end)
my_launcher:connect_signal("mouse::leave", function()
    my_launcher.image = beautiful.awesome_icon
    my_launcher:emit_signal("widget::redraw_needed")
end)

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.tile,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.magnifier,
        awful.layout.suit.floating,
    })
end)
-- }}}

-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper({
        screen = s,
        widget = {
            {
                image = beautiful.wallpaper,
                horizontal_fit_policy = "fit",
                vertical_fit_policy = "fit",
                upscale = true,
                downscale = true,
                widget = wibox.widget.imagebox,
            },
            valign = "center",
            halign = "center",
            tiled = false,
            widget = wibox.container.background,
        },
    })
end)
-- }}}

-- {{{ Wibar

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox({
        screen = s,
        buttons = {
            awful.button({}, 1, function()
                awful.layout.inc(1)
            end),
            awful.button({}, 3, function()
                awful.layout.inc(-1)
            end),
            -- awful.button({}, 4, function()
            --     awful.layout.inc(-1)
            -- end),
            -- awful.button({}, 5, function()
            --     awful.layout.inc(1)
            -- end),
        },
    })

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist({
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({}, 1, function(t)
                t:view_only()
            end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end),
            -- awful.button({}, 4, function(t)
            --     awful.tag.viewprev(t.screen)
            -- end),
            -- awful.button({}, 5, function(t)
            --     awful.tag.viewnext(t.screen)
            -- end),
        },
    })

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist({
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({}, 1, function(c)
                c:activate({ context = "tasklist", action = "toggle_minimization" })
            end),
            awful.button({}, 3, function()
                awful.menu.client_list({ theme = { width = 250 } })
            end),
            -- awful.button({}, 4, function()
            --     awful.client.focus.byidx(-1)
            -- end),
            -- awful.button({}, 5, function()
            --     awful.client.focus.byidx(1)
            -- end),
        },
    })

    s.is_wibar_visible_locked = false
    s.is_wibar_last_vis_manual = false
    s.mywibox_lock_state = wibox.widget {
        text = "",
        widget = wibox.widget.textbox,
        get_lock_state_text = function()
            if s.is_wibar_visible_locked then
                return " "
            end
            return ""
        end,
        update_text = function()
            s.mywibox_lock_state.text = s.mywibox_lock_state.get_lock_state_text()
        end
    }

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "top",
        margins = {
            left = dpi(5),
            top = dpi(5),
            right = dpi(5),
            bottom = dpi(0),
        },
        border_width = dpi(2), -- TODO: need to be ontop because of animated wallpaper (mpv), but this is not optimal because fullscreen
        -- applications will be behind the wibox. Need to find a fix for this so that ontop isn't needed anymore
        ontop = true,
        border_color = "#232d5c",
        shape = function(cr, width, height)
            return gears.shape.rounded_rect(cr, width, height, 5)
        end,
        screen = s,
        type = "dock",
        widget = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                my_launcher,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            {             -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                mykeyboardlayout,
                wibox.widget.systray(),
                mytextclock,
                s.mywibox_lock_state,
                s.mylayoutbox,
            },
        },
    })
end)

-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function()
        my_main_menu:toggle()
    end),
    -- awful.button({}, 4, awful.tag.viewprev),
    -- awful.button({}, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
    awful.key({ modkey }, "w", function()
        my_main_menu:show()
    end, { description = "show main menu", group = "awesome" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey }, "x", function()
        awful.prompt.run({
            prompt = "Run Lua code: ",
            textbox = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval",
        })
    end, { description = "lua execute prompt", group = "awesome" }),
    awful.key({ modkey }, "Tab", function()
        awful.spawn("rofi -show window -modi windowcd,window")
    end, { description = "rofi window switcher (all windows)", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "Tab", function()
        awful.spawn("rofi -show windowcd -modi windowcd,window")
    end, { description = "rofi window switcher (all windows)", group = "awesome" }),
    awful.key({ "Mod1" }, "Tab", function()
        awful.spawn("rofi -show windowcd -modi windowcd,window")
    end, { description = "rofi window switcher (current workspace)", group = "awesome" }),
    awful.key({ "Mod1", "Shift" }, "Tab", function()
        awful.spawn("rofi -show window -modi windowcd,window")
    end, { description = "rofi window switcher (current workspace)", group = "awesome" }),
    awful.key({ modkey }, "Return", function()
        awful.spawn(terminal)
    end, { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey }, "r", function()
        awful.spawn("rofi -show run")
    end, { description = "run prompt in rofi", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "r", function()
        awful.screen.focused().mypromptbox:run()
    end, { description = "run prompt", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "p", function()
        menubar.show()
    end, { description = "show the menubar", group = "launcher" }),
    awful.key({ modkey, "Control" }, "p", function()
        awful.spawn("rofi-rbw")
    end, { description = "show the menubar", group = "launcher" }),
    awful.key({ modkey, "Control" }, "o", function()
        awful.spawn({ terminal, "-e", "cotp" })
    end, { description = "show the menubar", group = "launcher" }),
    awful.key({ modkey }, "p", function()
        awful.spawn("rofi -show drun")
    end, { description = "show rofi as launcher", group = "launcher" }),
    awful.key({ modkey }, "b", function()
        local myscreen = awful.screen.focused()
        myscreen.mywibox.visible = not myscreen.mywibox.visible
        myscreen.is_wibar_last_vis_manual = true
    end, { description = "toggle statusbar", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "b", function()
        local myscreen = awful.screen.focused()
        myscreen.is_wibar_visible_locked = not myscreen.is_wibar_visible_locked
        myscreen.mywibox_lock_state.update_text()
    end, { description = "toggle statusbar locked", group = "awesome" }),

    -- my custom keybindings
    awful.key({ modkey, "Shift" }, "t", function()
        is_titlebars_visible = not is_titlebars_visible
        update_titlebars_visible()
    end, {
        description = "temporary tests enable/disable titlebars",
        group = "awesome",
    }),
    awful.key({ modkey, "Shift" }, "s", function()
        awful.spawn({ "flameshot", "gui" })
    end, { description = "take a screenshot with flameshot", group = "awesome" }),
    awful.key({ modkey, "Control" }, "s", function()
        awful.spawn(os.getenv("HOME") .. "/.local/bin/" .. "flameshot-ocr")
    end, { description = "screenshot ocr to clip", group = "awesome" }),
    awful.key({ modkey }, "Escape", function()
        awful.spawn({ "i3lock", "--pointer=default" })
    end, { description = "lock the screen with lighdm", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "Escape", function()
        awful.spawn("rofi -show p -modi p:rofi-power-menu")
    end, { description = "show power menu", group = "awesome" }),
    awful.key({ "Control", "Shift" }, "Escape", function()
        awful.spawn({ terminal, "-e", "bpytop" })
    end, { description = "show power menu", group = "awesome" }),
    awful.key({ modkey }, ".", function()
        awful.spawn({ "rofi", "-show", "emoji", "-modi", "emoji" })
    end, { description = "show emoji picker", group = "awesome" }),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
    awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
    --awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "j", function()
        awful.client.focus.byidx(1)
    end, { description = "focus next by index", group = "client" }),
    awful.key({ modkey }, "k", function()
        awful.client.focus.byidx(-1)
    end, { description = "focus previous by index", group = "client" }),
    awful.key({ modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end, { description = "go back", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:activate({ raise = true, context = "key.unminimize" })
        end
    end, { description = "restore minimized", group = "client" }),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift" }, "j", function()
        awful.client.swap.byidx(1)
    end, { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function()
        awful.client.swap.byidx(-1)
    end, { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey }, "l", function()
        awful.tag.incmwfact(0.05)
    end, { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey }, "h", function()
        awful.tag.incmwfact(-0.05)
    end, { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function()
        awful.tag.incnmaster(1, nil, true)
    end, { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function()
        awful.tag.incnmaster(-1, nil, true)
    end, { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function()
        awful.tag.incncol(1, nil, true)
    end, { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function()
        awful.tag.incncol(-1, nil, true)
    end, { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey }, "space", function()
        awful.layout.inc(1)
    end, { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function()
        awful.layout.inc(-1)
    end, { description = "select previous", group = "layout" }),
})

awful.keyboard.append_global_keybindings({
    awful.key({
        modifiers = { modkey },
        keygroup = "numrow",
        description = "only view tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    }),
    awful.key({
        modifiers = { modkey, "Control" },
        keygroup = "numrow",
        description = "toggle tag",
        group = "tag",
        on_press = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    }),
    awful.key({
        modifiers = { modkey, "Shift" },
        keygroup = "numrow",
        description = "move focused client to tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    }),
    awful.key({
        modifiers = { modkey, "Control", "Shift" },
        keygroup = "numrow",
        description = "toggle focused client on tag",
        group = "tag",
        on_press = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    }),
    awful.key({
        modifiers = { modkey },
        keygroup = "numpad",
        description = "select layout directly",
        group = "layout",
        on_press = function(index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }),
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate({ context = "mouse_click" })
        end),
        awful.button({ modkey }, 1, function(c)
            c:activate({ context = "mouse_click", action = "mouse_move" })
        end),
        awful.button({ modkey }, 3, function(c)
            c:activate({ context = "mouse_click", action = "mouse_resize" })
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey }, "f", function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end, { description = "toggle fullscreen", group = "client" }),
        awful.key({ modkey, "Shift" }, "c", function(c)
            c:kill()
        end, { description = "close", group = "client" }),
        awful.key(
            { modkey, "Control" },
            "space",
            awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }
        ),
        awful.key({ modkey, "Control" }, "Return", function(c)
            c:swap(awful.client.getmaster())
        end, { description = "move to master", group = "client" }),
        awful.key({ modkey }, "o", function(c)
            c:move_to_screen()
        end, { description = "move to screen", group = "client" }),
        awful.key({ modkey }, "t", function(c)
            c.ontop = not c.ontop
        end, { description = "toggle keep on top", group = "client" }),
        awful.key({ modkey }, "n", function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, { description = "minimize", group = "client" }),
        awful.key({ modkey }, "m", function(c)
            c.maximized = not c.maximized
            c:raise()
        end, { description = "(un)maximize", group = "client" }),
        awful.key({ modkey, "Control" }, "m", function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end, { description = "(un)maximize vertically", group = "client" }),
        awful.key({ modkey, "Shift" }, "m", function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end, { description = "(un)maximize horizontally", group = "client" }),
    })
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule({
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        },
    })

    -- Floating clients.
    ruled.client.append_rule({
        id = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "Sxiv",
                "Tor Browser",
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
                "awakened-poe-trade",
                "exiled-exchange-2"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
                ".*is sharing your screen.",
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            },
        },
        except_any = {
            instance = {
                "crx__.*", -- Microsoft Edge PWA apps
            },
        },
        properties = { floating = true },
    })

    -- Path of exile
    ruled.client.append_rule({
        id = "poe-trade",
        rule_any = {
            class = {
                "awakened-poe-trade",
                "exiled-exchange-2",
            },
        },
        properties = {
            floating = true,
            -- ontop = true,
            focus = false,
            focusable = false,
            titlebars_enabled = false,
            requests_no_titlebar = true,
            -- above = true,
            honor_padding = false,
            honor_workarea = false,
            x = 0,
            y = 0,
            width = 2560,
            height = 1440,
            skip_taskbar = true,
            size_hints_honor = false,
            dockable = false,
            is_fixed = true,
            immobilized_vertical = true,
            immobilized_horizontal = true,
            modal = true,
            role = "overlay",
            -- fullscreen = true,
            border_width = 0,
        },
    })

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule({
        id = "titlebars",
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true },
    })

    ruled.client.append_rule({
        rule_any = { name = ".*is sharing your screen." },
        properties = {
            floating = true,
            border_width = 0,
        }
    })

    ruled.client.append_rule({
        -- Steam floating windows
        id = "steam-popup",
        rule_any = {
            name = {
                "Friends List",
                "Steam - News",
                "Steam - Screenshot Uploader",
                "Steam - Web Helper",
                "Steam - Update",
            },
        },
        properties = {
            floating = true,
            placement = awful.placement.centered,
            ontop = true,
            skip_taskbar = true,
        },
    })

    ruled.client.append_rule({
        id = "floating-ontop",
        rule_any = {
            class = {
                "TorGuard",
                "Protonvpn-app",
                "protonvpn-app",
                "Proton VPN",
                "Peek",
                "peek",
                "smile",
                "pritunl",
            },
        },
        properties = {
            floating = true,
            ontop = true,
            skip_taskbar = true,
            sticky = true,
        },
    })

    ruled.client.append_rule({
        id = "inside-client",
        rule_any = {
            class = {
                "smile",
            },
        },
        properties = {
            floating = true,
            placement = awful.placement.under_mouse,
            -- placement = function(c)
            --
            -- end
        },
    })
    -- Set Floorp to always map on the tag named "2" on screen 1.
    ruled.client.append_rule({
        rule = { class = "floorp" },
        except = { name = "WhatsApp — Ablaze Floorp" },
        properties = { screen = 1, tag = "1" },
    })
    -- Set Thunderbird to always map on the tag named "8" on screen 1.
    ruled.client.append_rule({
        rule = { class = "thunderbird" },
        properties = { screen = 1, tag = "8" },
    })
    -- Set Steam to always map on the tag named "9" on screen 1.
    ruled.client.append_rule({
        rule = { class = "steam" },
        properties = { screen = 1, tag = "9" },
    })
    -- Set Heroic to always map on the tag named "9" on screen 1.
    ruled.client.append_rule({
        rule = { class = "heroic" },
        properties = { screen = 1, tag = "9" },
    })
    -- Set Spotify to always map on the tag named "9" on screen 1.
    ruled.client.append_rule({
        rule = { class = "Spotify" },
        properties = { screen = 1, tag = "9" },
    })
    -- Set "chat" to always map on the tag named "7" on screen 1.
    ruled.client.append_rule({
        rule_any = {
            class = {
                "discord",
                "TelegramDesktop",
                "zapzap",
                "ZapZap",
                "whatsapp",
                "teams-for-linux",
            },
            name = {
                "WhatsApp Web"
            }
        },
        properties = { screen = 1, tag = "7", floating = false },
    })
    -- Rules for xwinwrap "wallpaper"
    ruled.client.append_rule({
        id         = "xwinwrap",
        rule_any   = { class = { "xwinwrap" } },
        properties = {
            floating             = true,
            below                = true,
            ontop                = false,
            focusable            = false,
            skip_taskbar         = true,
            sticky               = true,
            titlebars_enabled    = false,
            requests_no_titlebar = true,
            x                    = 0,
            y                    = 0,
            width                = awful.screen.focused().geometry.width,
            height               = awful.screen.focused().geometry.height,
            border_width         = 0,
            type                 = "desktop",
        }
    })
end)
-- }}}

-- {{{ Titlebars

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = {
        awful.button({}, 1, function()
            c:activate({ context = "titlebar", action = "mouse_move" })
        end),
        awful.button({}, 3, function()
            c:activate({ context = "titlebar", action = "mouse_resize" })
        end),
    }

    awful.titlebar(c).widget = {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal,
        },
        {     -- Middle
            { -- Title
                halign = "center",
                widget = awful.titlebar.widget.titlewidget(c),
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal,
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal(),
        },
        layout = wibox.layout.align.horizontal,
    }
    if not is_titlebars_visible then
        awful.titlebar.hide(c)
    end
end)

-- }}}

-- {{{ Notifications

beautiful.notification_icon_size = 100
ruled.notification.connect_signal("request::rules", function()
    -- All notifications will match this rule.
    ruled.notification.append_rule({
        rule = {},
        properties = {
            screen = awful.screen.preferred,
            implicit_timeout = 3,
            position = "bottom_right",
            border_width = dpi(2),
            border_color = "#737dcc",
            opacity = 0.2,
        },
    })
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box({ notification = n })
end)

-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("button::press", function(c)
    c:activate({ context = "mouse_move", raise = false })
end)

client.connect_signal("property::fullscreen", function(c)
    local s = c.screen
    if s.is_wibar_visible_locked then
        return
    end
    if not client.focus then -- if some window enter in fullscreen without focus, ignore...
        return
    end
    if c.fullscreen then
        s.mywibox.visible = false
        s.is_wibar_last_vis_manual = false
    else
        s.mywibox.visible = true
        s.is_wibar_last_vis_manual = false
    end
end)

client.connect_signal("focus", function(c)
    local s = c.screen
    if s.is_wibar_visible_locked or s.is_wibar_last_vis_manual then
        return
    end
    if c.fullscreen then
        s.mywibox.visible = false
    else
        s.mywibox.visible = true
    end
end)

-- Apps start with awesome {{{

-- enable autorun apps
local autorun = true

-- List of apps to start once on start-up
local autorun_apps = {
    -- ----------------------- flameshot: screenshot tool ----------------------- --
    "flameshot",
    -- ------------------ blueman-applet: applet for bluetooth ------------------ --
    "blueman-applet",
    -- ---------------------------- picom: compositor --------------------------- --
    { "picom",                "-b" },
    -- -------------- caffeine: prevent screen from going to sleep -------------- --
    -- "caffeine start",
    -- ------------------ nm-applet: applet for network manager ----------------- --
    "nm-applet",
    -- ------------ system-config-printer-applet: applet for printer ------------ --
    "system-config-printer-applet",
    -- ------- required for polkit authentication (not in path by default) ------ --
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    -- -------------- gnome-keyring: daemon for password management ------------- --
    { "gnome-keyring-daemon", "--start",                                  "--components=secrets" },
    -- ---------------- xbindkeys: daemon for keyboard shortcuts ---------------- --
    -- { "xbindkeys",                          "-f",                                       os.getenv("XDG_CONFIG_HOME") .. "/xbindkeys/config" },
    -- playerctld: daemon for controlling music players
    { "playerctld",           "daemon" },
    --
    -- { "dex",                                "/usr/share/applications/torguard.desktop" },
    { "dex",                  "/usr/share/applications/protonvpn.desktop" },
    -- { "flatpak",                            "run",                                     "it.mijorus.smile",                   "--start-hidden" },
    -- --------------------------- clip persist script -------------------------- --
    os.getenv("HOME") .. "/.local/bin/clip-persist",
    os.getenv("HOME") .. "/.local/bin/set-wallpaper",
    os.getenv("HOME") .. "/.local/bin/set-animated-wallpaper",
}

-- List of apps to start once on start-up but startup notification protocol is
-- not supported, and therefore the startup_id required by spawn.once and
-- spawn.single_instance is not available.
-- https://awesomewm.org/doc/api/classes/client.html#client.startup_id
local autorun_apps_no_startup_id = {
    -- pasystray: applet for pulseaudio volume control
    { "pasystray", "--key-grabbing" },
    -- pcmanfm: file manager
    { "pcmanfm",   "--daemon-mode", "--no-desktop" },
    -- ------------------ cbatticon: applet for battery status ------------------ --
    -- "cbatticon",
}

local function get_only_app_name(app)
    local app_name = ""
    if type(app) == "table" then
        app_name = app[1]
    else
        app_name = app
    end
    -- remove parameters
    app_name = string.gmatch(app_name, "([^%s]+)")()
    -- remove path
    app_name = string.gsub(app_name, "(.*/)(.*)", "%2")
    -- remove extension
    app_name = string.gsub(app_name, "(.*)%..*", "%1")
    return app_name
end

local function isRunning(app)
    local app_name = get_only_app_name(app)
    local f = io.popen("pgrep -x " .. app_name)
    if f == nil then
        return false
    end
    local pid = f:read("*n")
    f:close()
    if pid then
        return true
    else
        return false
    end
end

awful.spawn.with_shell("killall -q picom")
awful.spawn.with_shell("killall -q nm-applet")
awful.spawn.with_shell("killall -q blueman-applet")
awful.spawn.with_shell("killall -q flameshot")

if autorun then
    for app = 1, #autorun_apps do
        awful.spawn.single_instance(autorun_apps[app])

        if is_debug_enabled then
            notify_send(get_only_app_name(autorun_apps[app]), "Debug: autorun app started")
        end
    end

    for app = 1, #autorun_apps_no_startup_id do
        -- manually check if the app is already running (this is slower)
        if not isRunning(autorun_apps_no_startup_id[app]) then
            awful.spawn.single_instance(autorun_apps_no_startup_id[app])
        end

        if is_debug_enabled then
            notify_send(get_only_app_name(autorun_apps_no_startup_id[app]), "Debug: autorun app (custom start) started")
        end
    end
end

-- }}}

-- make all titlebars hidden by default
update_titlebars_visible()

local tags = root.tags()
for _, t in ipairs(tags) do
    t.master_width_factor = 0.50
end

-- vim:fileencoding=utf-8:foldmethod=marker
