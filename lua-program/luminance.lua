
-- switch hex character to integer 
local function hex_to_int(c)
    local byte_val = string.byte(c)
    if byte_val >= string.byte('0') and byte_val <= string.byte('9') then
        return byte_val - string.byte('0')
    elseif byte_val >= string.byte('a') and byte_val <= string.byte('f') then
        return byte_val - string.byte('a') + 10
    elseif byte_val >= string.byte('A') and byte_val <= string.byte('F') then
        return byte_val - string.byte('A') + 10
    else
        return -1
    end
end



local function process_rgb_to_gray(hex_input, width, height)
    local str_len = #hex_input
    if (str_len % 2) ~= 0 then
        return -1
    end

    local bytes_len = str_len // 2

    local MAX_SIZE = 1024 * 1024
    if bytes_len > MAX_SIZE then
        return -2 
    end

    -- convert hex string to a byte array
    -- for example, FF0000 contains FF for r, 00 for g and 00 for b, first F is high and second F is low ( sub(1,1) menas select the first element )
    -- F = 1111, hence FF = 11110000 | 1111 = 11111111 which is 255 in integer
    -- same for 00 and 00, we can get the first 3 element as (255,0,0)
    -- in the end, the result will be (255,0,0,0,255,0,0,0,255)

    local shared_buffer = {}
    for i = 1, bytes_len do
        local high = hex_to_int(hex_input:sub((i-1)*2 + 1, (i-1)*2 + 1))
        local low  = hex_to_int(hex_input:sub((i-1)*2 + 2, (i-1)*2 + 2))
        if high < 0 or low < 0 then
            return -3
        end
        shared_buffer[i] = (high << 4) | low
    end

    -- compute grayscale value for each pixel by luminance formula
    local pixel_count = width * height
    local gray_buffer = {}
    for i = 1, pixel_count do
        local r = shared_buffer[(i-1)*3 + 1] or 0
        local g = shared_buffer[(i-1)*3 + 2] or 0
        local b = shared_buffer[(i-1)*3 + 3] or 0
        local gray_val = ((r * 77) + (g * 150) + (b * 29)) >> 8
        gray_buffer[i] = gray_val
    end

    return pixel_count, gray_buffer
end

function main(hex_input, width, height)
    print("== Lua Luminance Test ==")
    print(string.format("Input Hex: %s", hex_input))
    print(string.format("Width: %d, Height: %d", width, height))
    print("------------------------")

    local ret, gray_data = process_rgb_to_gray(hex_input, width, height)
    if ret < 0 then
        print("failed with error code:", ret)
    else
        print("successful. processed " .. ret .. " pixels.")
        for i = 1, ret do
            print(string.format("pixel %d grayscale: %d", i, gray_data[i]))
        end
    end
end

-- for pc environment
if arg then
    -- get from input: hex, width, height
    -- example input: FF0000FFFF00 2 2
    local cli_hex    = arg[1] or "FF000000FF000000FF"
    local cli_width  = tonumber(arg[2]) or 1
    local cli_height = tonumber(arg[3]) or 3
    
    print("Detected command-line arguments:")
    print("  Hex string :", cli_hex)
    print("  Width      :", cli_width)
    print("  Height     :", cli_height)
    print("===============================")
    
    main(cli_hex, cli_width, cli_height)

end
