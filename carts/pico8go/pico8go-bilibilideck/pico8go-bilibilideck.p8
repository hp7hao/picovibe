pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- pico-8 test program for xwd communication
-- this program initializes gpio memory and handles two-way communication

-- constants
gpio_base = 0x5f80
magic_count = 4
magic_size = magic_count * 4
cmd_offset = 16      -- command byte is at offset 16
length_offset = 17   -- length byte is at offset 17
payload_offset = 18  -- payload starts at offset 18
flag_offset = 16     -- flag is at offset 16
max_payload = 110

-- magic values for identification
magic_values = {
  0x46c7.2002,
  0x6e44.ab77,
  0xd67f.dcbe,
  0x4d98.77d2
}

-- flag values
flag_command = 0
flag_response = 1

-- command types
cmd_none = 0x00
cmd_ping = 0x01
cmd_message = 0x02
cmd_reset = 0x03

-- initialize gpio memory
function init_gpio()
  -- write magic values
  for i=1,magic_count do
    poke4(gpio_base + (i-1)*4, magic_values[i])
  end
  
  -- clear command area
  for i=magic_size,0x128 do
    poke(gpio_base + i, 0)
  end
  
  -- set initial flag
  poke(gpio_base + flag_offset, -1)
end

-- send command to xwd
function send_command(cmd_type, message)
  -- write command type at offset 16
  poke(gpio_base + cmd_offset, cmd_type)
  
  -- write message length at offset 17
  local msg_len = #message
  if msg_len > max_payload then msg_len = max_payload end
  poke(gpio_base + length_offset, msg_len)
  
  -- write message starting at offset 18
  for i=1,msg_len do
    poke(gpio_base + payload_offset + i-1, ord(sub(message,i,i)))
  end
  
  -- set command flag at offset 16
  poke(gpio_base + flag_offset, flag_command)
  
  -- debug output
  print("sent cmd: "..cmd_type.." len: "..msg_len)
  print("cmd at: "..(gpio_base + cmd_offset))
  print("len at: "..(gpio_base + length_offset))
  print("payload at: "..(gpio_base + payload_offset))
  return true
end

-- check for responses
function check_response()
  local flag = peek(gpio_base + flag_offset)
  
  if flag == flag_response then
    -- get response length
    local length = peek(gpio_base + length_offset)
    if length > max_payload then length = max_payload end
    
    -- read response
    local response = ""
    for i=0,length-1 do
      response = response..chr(peek(gpio_base + payload_offset + i))
    end
    
    -- clear response flag
    --poke(gpio_base + flag_offset, flag_command)
    
    return response
  end
  
  return nil
end

-- test commands
function test_commands()
  -- send ping
  if send_command(cmd_ping, "ping_from_pico8") then
    print("ping sent")
  else
    print("failed to send ping")
  end
end

function _init()
  init_gpio()
  print("pico-8 xwd test program")
  print("sending test commands...")
  
  -- debug: display hexadecimal representation of magic values
  print("magic values as seen by pico-8:")
  for i=1,magic_count do
    local magic_hex = ""
    local val = magic_values[i]
    for j=1,8 do
      local digit = val & 0xf
      if digit < 10 then
        magic_hex = tostr(digit) .. magic_hex
      else
        magic_hex = chr(ord("a") + digit - 10) .. magic_hex
      end
      val = flr(val >> 4)
      if val == 0 then break end
    end
    print("magic "..i..": 0x"..magic_hex)
  end
  
  -- debug: read back values directly
  print("reading back values from memory:")
  for i=1,magic_count do
    local mem_addr = gpio_base + (i-1)*4
    local value = peek4(mem_addr)
    print("memory at 0x"..tostr(mem_addr)..": 0x"..tohex(value))
  end
end

-- helper function to convert number to hex string
function tohex(val)
  local s = ""
  for i=0,7 do
    local digit = val & 0xf
    if digit < 10 then
      s = tostr(digit)..s
    else
      s = chr(ord("a") + digit - 10)..s
    end
    val = flr(val / 16)
    if val == 0 then break end
  end
  return s
end

tick=0

function _update()
  -- check for responses
  local flag = peek(gpio_base + flag_offset)
  if flag == flag_response then
    local response = check_response()
    if response then
      print("response: "..response)
    end
  end
  
  -- handle input
  if btnp(4) then -- x button
    if send_command(cmd_message, "bilibili:followers 267559613") then
      print("message sent")
    end
  end
  tick=tick+1
end

function _draw()
  cls()
  print("pico-8 xwd test program", 32, 32, 7)
  print("press x: send message", 32, 48, 7)
  print("press o: send ping", 32, 56, 7)
  print("press square: send reset", 32, 64, 7)
  print("press esc to exit", 32, 72, 7)
  print(tick)
  print("flag "..peek(gpio_base+flag_offset))
  print("len  "..peek(gpio_base+length_offset))
  print("f    "..peek4(gpio_base+payload_offset))
end 
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
