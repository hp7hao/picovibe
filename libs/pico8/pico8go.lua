-- p8go runtime v0
-- MIRROR of projects/xwsdk/p8mod/src/p8go_runtime.lua
-- Do not edit here; update the xwsdk source and re-mirror.
-- Drift is tracked by REQ-PICOVIBE-004 in docs/specs/picovibe_spec.md.
p8go={}
local _b=0x5f80
local _s=0
local function _w(cmd,ch,msg)
 _s=(_s+1)%256
 ch=ch or ""
 msg=msg or ""
 poke(_b,0)
 poke(_b+1,_s)
 poke(_b+2,112) poke(_b+3,56) poke(_b+4,103) poke(_b+5,111) poke(_b+6,33)
 poke(_b+7,cmd)
 poke(_b+8,#ch)
 poke(_b+9,#msg)
 for i=1,min(#ch,8) do poke(_b+9+i,ord(ch,i)) end
 for i=1,min(#msg,13) do poke(_b+17+i,ord(msg,i)) end
 local c=0
 for i=0,30 do c=(c+peek(_b+i))%256 end
 poke(_b+31,c)
end
function p8go.has(_) return peek(_b+2)==112 and peek(_b+3)==56 end
function p8go.ipc_send(ch,msg) _w(1,ch,msg) end
function p8go.vibe(ms,strength) p8go.ipc_send("haptic",chr(1)..chr(ms%256)..chr(flr((strength or 1)*255))) end
function p8go.vibe_stop() p8go.ipc_send("haptic",chr(2)) end
function p8go.ach_unlock(id) p8go.ipc_send("ach",chr(1)..id) end
function p8go.ach_progress(id,v,t) p8go.ipc_send("ach",chr(2)..id..":"..v..":"..t) end
