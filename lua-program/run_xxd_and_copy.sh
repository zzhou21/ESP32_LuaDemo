#!/bin/sh

xxd -i luminance.lua    > luminance.h
cp -f luminance.h   ../ESP32C6_Lua5.4.7/main