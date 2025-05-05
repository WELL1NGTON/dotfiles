-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

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

local blacklisted_snid = setmetatable({}, { __mode = "v" })

--- Make startup notification work for some clients like XTerm. This is ugly
-- but works often enough to be useful.
local function fix_startup_id(c)
    -- Prevent "broken" sub processes created by <code>c</code> to inherit its SNID
    if c.startup_id then
        blacklisted_snid[c.startup_id] = blacklisted_snid[c.startup_id] or c
        return
    end

    if not c.pid then
        return
    end

    -- Read the process environment variables
    local f = io.open("/proc/" .. c.pid .. "/environ", "rb")

    -- It will only work on Linux, that's already 99% of the userbase.
    if not f then
        return
    end

    local value = _VERSION <= "Lua 5.1" and "([^\z]*)\0" or "([^\0]*)\0"
    local snid = f:read("*all"):match("STARTUP_ID=" .. value)
    f:close()

    -- If there is already a client using this SNID, it means it's either a
    -- subprocess or another window for the same process. While it makes sense
    -- in some case to apply the same rules, it is not always the case, so
    -- better doing nothing rather than something stupid.
    if not snid or blacklisted_snid[snid] then
        return
    end

    c.startup_id = snid

    blacklisted_snid[snid] = c
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
-- beautiful.xresources.set_dpi(96)
beautiful.init(awesome_theme)
-- beautiful.xresources.set_dpi(96)

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
local myawesomemenu = {
    {
        "hotkeys",
        function()
            hotkeys_popup.show_help(nil, awful.screen.focused())
        end,
    },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    {
        "quit",
        function()
            awesome.quit()
        end,
    },
}

local mymainmenu = awful.menu({
    items = {
        { "awesome",       myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal },
    },
})

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

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
                mylauncher,
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

    -- INFO: Animated wallpaper: wanted to put this on the "request::wallpaper" signal, but it don't works in there...
    local mpv_name = "awesomewm_wallpaper_mpv" .. tostring(s.index)
    ruled.client.add_rule_source(mpv_name, fix_startup_id, {}, { "awful.spawn", "ruled.client" })
    awful.spawn.single_instance(
        {
            "mpv",
            -- "--x11-bypass-compositor=yes",
            "--no-input-default-bindings",
            "--no-config",
            "--panscan=1.0",
            -- "--fullscreen",
            "--scale=nearest",
            "--no-border",
            "--osc=no",
            "--keepaspect",
            "--stop-screensaver=no",
            "--loop-file=yes",
            "--no-audio",
            "--osd-level=0",
            "--ontop=no",
            "--ontop-level=0",
            -- "--on-all-workspaces",
            "--x11-name=" .. mpv_name,
            "--x11-wid-title=yes",
            "--wid=-1",
            "--window-dragging=no",
            "/home/wellington/Pictures/wallpapers/hyper_light_drifter_fanart--jouney_951--rpixelart.mp4",
        },
        {
            floating = true,
            border_width = 0,
            ontop = false,
            above = false,
            below = true,
            skip_taskbar = true,
            size_hints_honor = false,
            requests_no_titlebar = true,
            honor_padding = false,
            honor_workarea = false,
            x = 0,
            y = 0,
            -- width = 2560,
            -- height = 1440,
            width = 3440,
            height = 1440,
            focus = false,
            focusable = false,
            sticky = true,
            startup_id = mpv_name,
            first_tag = mpv_name,
            titlebars_enabled = false,
            dockable = false,
            class = mpv_name,
            instance = mpv_name,
            screen = s,
            type = "desktop",
            tag = "9",
            is_fixed = true,
            immobilized_vertical = true,
            immobilized_horizontal = true,
            modal = true,
            role = "wallpaper",
            fullscreen = true,
        },
        function(c)
            return c.instance == mpv_name
        end,
        mpv_name,
        function(c)
            -- s.mywibox.ontop = false
            --c.above = false
            c.below = true
            --c:lower()
            -- c:emit_signal("lowered")
        end
    )
end)

-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function()
        mymainmenu:toggle()
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
        mymainmenu:show()
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
    awful.key({ modkey }, "Return", function()
        awful.spawn(terminal)
    end, { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey }, "r", function()
        awful.screen.focused().mypromptbox:run()
    end, { description = "run prompt", group = "launcher" }),
    awful.key({ modkey }, "p", function()
        menubar.show()
    end, { description = "show the menubar", group = "launcher" }),
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
        awful.spawn({ "flameshot-ocr" })
    end, { description = "screenshot ocr to clip", group = "awesome" }),
    awful.key({ modkey }, "Escape", function()
        awful.spawn.easy_async({ "light-locker-command", "-l" })
    end, { description = "lock the screen with lighdm", group = "awesome" }),
    awful.key({ modkey }, ".", function()
        awful.spawn({ "flatpak", "run", "it.mijorus.smile" })
    end, { description = "emojis", group = "awesome" }),
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
        properties = { screen = 1, tag = "2" },
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
    -- cbatticon: applet for battery status
    -- "cbatticon",
    -- flameshot: screenshot tool
    "flameshot",
    -- blueman-applet: applet for bluetooth
    "blueman-applet",
    -- picom: compositor
    { "picom",                              "-b" },
    -- caffeine: prevent screen from going to sleep
    -- "caffeine start",
    -- nm-applet: applet for network manager
    "nm-applet",
    -- required for polkit authentication (not in path by default)
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    --
    -- "light-locker",
    --
    { "dbus-update-activation-environment", "--all" },
    --
    { "gnome-keyring-daemon",               "--start",                                  "--components=secrets" },
    --
    { "xbindkeys",                          "-f",                                       "${XDG_CONFIG_HOME}/xbindkeys/config" },
    { "playerctld",                         "daemon" },
    -- { "dex",                                "/usr/share/applications/torguard.desktop" },
    { "dex",                                "/usr/share/applications/protonvpn.desktop" },
    -- { "flatpak",                            "run",                                     "it.mijorus.smile",                   "--start-hidden" },
    -- Default Keyboard config
    -- US International
    { "setxkbmap",                          "us",                                       "-variant",                           "intl" },
    -- PT-BR ABNT2
    -- { "setxkbmap",                          "-model",                                   "pc105",                              "-layout", "br", "-variant", "abnt2" }
}
--awful.spawn({ "systemd-run", "--user", "--unit", "light-locker", "light-locker" })

-- List of apps to start once on start-up but startup notification protocol is
-- not supported, and therefore the startup_id required by spawn.once and
-- spawn.single_instance is not available.
-- https://awesomewm.org/doc/api/classes/client.html#client.startup_id
local autorun_apps_no_startup_id = {
    -- pasystray: applet for pulseaudio volume control
    { "pasystray", "--key-grabbing" },
    -- pcmanfm: file manager
    { "pcmanfm",   "--daemon-mode", "--no-desktop" },
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

if autorun then
    for app = 1, #autorun_apps do
        awful.spawn.single_instance(autorun_apps[app])

        if is_debug_enabled then
            awful.spawn.with_shell("notify-send 'Test' '" .. get_only_app_name(autorun_apps[app]) .. "'")
        end
    end

    for app = 1, #autorun_apps_no_startup_id do
        -- manually check if the app is already running (this is slower)
        if not isRunning(autorun_apps_no_startup_id[app]) then
            awful.spawn.single_instance(autorun_apps_no_startup_id[app])
        end

        if is_debug_enabled then
            awful.spawn.with_shell("notify-send 'Test' '" .. get_only_app_name(autorun_apps_no_startup_id[app]) .. "'")
        end
    end
end

-- }}}

-- make all titlebars hidden by default
update_titlebars_visible()

-- Set master factor 65%/35%
local tags = root.tags()
for _, t in ipairs(tags) do
    t.master_width_factor = 0.50
end

-- vim:fileencoding=utf-8:foldmethod=marker
