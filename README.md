# ESP32_LuaDemo

## Changes to luminance.lua
Global main()：
Changed local function main(...) to function main(...) so that it’s accessible via lua_getglobal(L, "main") in C.

No auto-execution：
Removed the script’s final call to main(), letting the C code decide when (and with which parameters) to invoke main().

## Changes to main.c
Embedded Lua Script：
Included "luminance.h" (generated by xxd -i) so we can access the Lua script as a byte array.

Lua State and Function Call：
Created a new Lua state with luaL_newstate(), opened standard libraries, then loaded and executed the embedded script. After that, retrieved the global main function, pushed arguments (e.g., pixel data, width, height), and called it via lua_pcall(L, ...).


