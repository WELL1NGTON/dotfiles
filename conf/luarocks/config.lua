-- LuaRocks configuration

rocks_trees = {
   { name = "user", root =  (os_getenv("XDG_DATA_HOME") or (home .. '/.local/share')) .. "/luarocks"  };
   { name = "system", root = "/usr" };
}

