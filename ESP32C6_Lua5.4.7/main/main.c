#include <stdio.h>
#include <inttypes.h>
#include "sdkconfig.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_chip_info.h"
#include "esp_spi_flash.h"
#include "esp_log.h"
#include "esp_system.h"

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "luminance.h"

#define LOG_TAG "Lua"

void log_memory_usage(const char *message)
{
    ESP_LOGI(LOG_TAG, "Free heap: %d, Min free heap: %d, Largest free block: %d, %s",
        heap_caps_get_free_size(MALLOC_CAP_DEFAULT),
        heap_caps_get_minimum_free_size(MALLOC_CAP_DEFAULT),
        heap_caps_get_largest_free_block(MALLOC_CAP_DEFAULT),
        message);
}

void run_embedded_lua(const char *lua_script, size_t lua_script_len)
{
    ESP_LOGI(LOG_TAG, "Starting Lua test.");
    log_memory_usage("Start of test");

    lua_State *L = luaL_newstate();
    if (!L) {
        ESP_LOGE(LOG_TAG, "Failed to create new Lua state");
        return;
    }
    log_memory_usage("After luaL_newstate");

    luaL_openlibs(L);
    log_memory_usage("After luaL_openlibs");

    if (luaL_loadbuffer(L, lua_script, lua_script_len, "embedded_lua_script") == LUA_OK) {
        if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
            ESP_LOGE(LOG_TAG, "Error running Lua script: %s", lua_tostring(L, -1));
            lua_pop(L, 1);
        } else {
            lua_getglobal(L, "main");
            if (!lua_isfunction(L, -1)) {
                ESP_LOGE(LOG_TAG, "'main' is not a valid function");
                lua_pop(L, 1);
            } else {
                const char *pixel = "FF000000FF000000FF";
                int w = 1;
                int h = 3;
                lua_pushstring(L, pixel);
                lua_pushinteger(L, w);
                lua_pushinteger(L, h);
                if (lua_pcall(L, 3, 0, 0) != LUA_OK) {
                    ESP_LOGE(LOG_TAG, "Error calling main(): %s", lua_tostring(L, -1));
                    lua_pop(L, 1);
                }
            }
        }
    } else {
        ESP_LOGE(LOG_TAG, "Error loading Lua script: %s", lua_tostring(L, -1));
        lua_pop(L, 1);
    }

    log_memory_usage("After executing Lua script");
    lua_close(L);
    log_memory_usage("After lua_close");
    ESP_LOGI(LOG_TAG, "End of Lua test.");
}

void app_main(void)
{
    ESP_LOGI(LOG_TAG, "--------------------------------");
    run_embedded_lua((const char *)luminance_lua, (size_t)luminance_lua_len);
    ESP_LOGI(LOG_TAG, "--------------------------------");
}
