local function myawesomemenu(settings, awful, hotkeys_popup)
    return {
        { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
        { "Manual", settings.terminal .. " -e man awesome" },
        { "Edit Config", settings.editor_cmd .. " " .. awesome.conffile },
        { "Restart", awesome.restart },
        { "Quit", function() awesome.quit() end },
    }
end

local function mymainmenu(settings, awful, beautiful, myawesomemenu)
    return awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "Open Terminal", settings.terminal }
    }
    })
end

local function mylauncher(awful, beautiful, mymainmenu)
    return awful.widget.launcher({ image = beautiful.awesome_icon,
        menu = mymainmenu })
end

return {
    myawesomemenu = myawesomemenu,
    mymainmenu = mymainmenu,
    mylauncher = mylauncher,
}
