pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- nezha poems
-- by hp7hao

#include ../../../libs/pico8/i18n.lua
#include ./nezhapoems.texts.zhcn.lua

-- no5
pic="`ト`トoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoナoテgboツgcoセgaofoゅgkokoんgnokoをgookoをgmomoわgmonoれgoonoやgcofgcobgbosoみggo█oほgho▒oへggo⬇️oふgfo✽opgeoかgfo●oagaomgafamcfbgaoうgdo웃gaomfamaeffagaoあgbo😐omfaeimaojgaoやomekfaohfbmcfbobfcmcfagaoなolfaeloefamaehmeedmafagaoてolmaemoafambeumafaoつoleqmceufaoちolelbaecmdevfaoたolmaejbbecmbeyfaoそomeaaaehbbebmcezfaoせoneaabeebbebmcejaaepmaoせoomaejmcejaaeqfaoすorfbbbecmcekaaedafegmagaoしosnadabaebmdekaaedafehoすosdcebmcepagehfaoしosdanadaeamdefmaeiagehfaoしosdanadaeamdefmaehahehmaoしosdanadaeamcegmaebabeaakehmaoしornadanadamdegobmadcekaaehoしormadanadamcefaaeaognamcddekfaoさoreadanadamcegmaofnamddjmcfcoさormadanadambehognamidaeamgoすohggocmadanaeambefaaeaogmedcedmadameoすoqfambdaebmaegfaofnamadaeidceamdfaoしoqfamaecmaefaaeaofnadaeideebmcfaoしoqfbmafanamadbeemaoemadbeb`caaecdeeefaoしorfaoamadeebaaeaofdbea`aee`aebddegoしorfaoadgmaeadaoenadaeaaamafaebmafaeaaaebdcebaaecmaoしgaoqfaoadgnaognadaeamaoama`aaaeamafaeaaaeadceaabeamaeboしosnadgnaognadaeafaoamaaa`aeamcebdceaabeamcoしorfaoadgnaohdaeaoafambeamdebddeaaaeamcoしotmadfnaohdaeamiebdbmadcmcfaoしotfamcdcnaohdaebaaeidambdcmcoすoufaneoinadbecadebdbnadcebaaeafaoしoumedcogncdeeaddmbdamadambebfaoしouegdaogncdimjfaoしotfaeeabmaofncdoebdafamafaoしotfaefaaeaoencdneemboすotfaefaa`aeaocnbmadsmbdaoすouefab`aeanbmadwmaoすouefac`aeamadwmaoせoumaeead`aaaeadumaoそoumaeeaf`aebdrmaoたoufaeeag`bebdmmbfaoちovefaf`aaa`cbaeaddmdfaoなovmaeeadeb`aeadbmaddmbnafaoねovfaefacbadcocnadcmaocfamaoにovfaefabbadcodnaddoひovfamaeeaaeaddodmadbmboひowfbeedeodmadbmboひoyfaecdfnaocmadbmaoふozfamadgnaobnamadbmaoふo{madanadeocnadcmaoふo}nadeocnaddoふo~deocnadbmadamaoひo~deocnadcoへo}nadeocnadcoへoxnbocdfocmadbmaoへovnbdanaobnadfocmadbmaoへounadcocdgocdcmaoへovdcobnadgobnadcmaoへovmadanaoanadhobnadcmaoへowmanadjoanadeoはfbmaoxdknbdeoとfcmcebmaownadjbadanademaoせfcmkowdaeadibadanadfoけfbmoeboufaecaaebdfbadanadfoえfbmpebmaecouma`aebaaea`aaaddbcdanademao❎fbmqeemaecmaoveamaeamadbebdcbcdanadfmao…fbmkedmfehmdowdbjadgbdnadgo⬅️fbmoeamiebmeebmaeamboumadlbcdjo░fbm⬇️ebmbedoudanadmbadanadimafboagaoyfbmreemgeamfeamaeamcedmaotfaeadmeabbdjeaaaebmagaorfbmjebmkeamhebmaeamdefmaegotmadbeadeeidjedaaeaoagaokfbmdebmfedmeeamleamdebmbebmbelotdcebdcea`aae`ceadiebabeaaaeafagaodfcmeeamjecmsezotfaeadaebdceaai`addofmadaeefcmoegmmeameecmaesac`boudbebdcaa`aag`beanboenamaoamafamueambedmbeamceamdecmheoab`iovdaebdceaahecdaofmtecmgebmlesac`oougamaebdaendamxebmaeamheamaefmaebmaeoab`voweadbeaaaeimoeamqebmbeimaenab`|ovgamaehmiebmeedmheambeamdexaa`~ab`aabotgaocmaeamuebmjebmaeamderac`|aloogbobfbmgebmfecmleamceamaecmdeoab`wat`doigbobfcmkeamdeamaedmfebmcebmbebmaepac`war`locgdoafcmweamdeamaeemaedmaeoab`waq`socfcmleambebmiecmcevac`yao`ympeamceamceembebmcerab`vaq`▒mrebmbeimbenac`qau`☉meeamdebmdeyac`pat`…"

-- pos for menu
mx=1
my=20
lh=9

function _init()
 tick=0
end

function _update()
 if btnp(4) then
  load("nezhapoems.zhcn.p8")
 end
end

function _draw()
 cls(0)
 draw_bg()
end

function draw_bg()
 rle1(pic,0,0)
end

function draw_poem()
end

function rle1(s,x0,y,tr)
 local x,mw=x0,x0+ord(s,2)-96
--  local x,mw=x0,x0+126
 for i=5,#s,2do
  local col,len=ord(s,i)-96,ord(s,i+1)-96
  -- print(col)
  -- print(len)
  if(col!=tr) line(x,y,x+len-1,y,col)
  -- break
  x+=len if(x>mw) x=x0 y+=1
 end
end

function s2t(s)
 local t={}
 for i=2,#s,2 do
  add(t,ord(s,i-1)*256+ord(s,i)-24672)
 end
 return t
end

function rle2(t,x0,y0,tr)
 local x,y,mw=x0,y0,x0+t[1]
  for i=3,#t do
   local v=t[i]
   local col,len=v\256,v&255
   if(col!=tr) line(x,y,x+len-1,y,col)
   x+=len
  if(x>mw-2) x=x0 y+=1
 end
end

function encode_string()
 w=126
 h=26
 
 t={}
 i,x,y=1,0,0
 len=1

 while y<h do
  local curcol,nxtcol=sget(x,y),sget(x+1,y)
  if nxtcol==curcol and x<w-1
   then len+=1
   else
    t[i]=curcol
    t[i+1]=len
    len=1
    i+=2
  end
  x+=1
  if(x==w)x=0 y+=1
 end

 new_s=new_s..'`'..chr(w-1+96)..'`'..chr(h-1+96)
 for i=1,#t do
  new_s..=chr(t[i]+96)
 end printh(new_s,'@clip')
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
