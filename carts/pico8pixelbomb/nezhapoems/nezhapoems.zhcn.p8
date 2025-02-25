pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- nezha poems
-- by hp7hao

#include ../../../libs/pico8/i18n.lua
#include ./nezhapoems.texts.zhcn.lua

-- no8
pic="`ト`トaycalamaeaafm웃fcmlfbmbalmbafcdaiaycalafamaafm⌂fbmpeaakmbasaycblamaaeeam⌂fbmmfambeaakmaekaiaxcclafamaadm⬅️fcmpakmaemagaxcdlamaadm⬅️fcmlfamcajeamaepadaxcdmbeaacm⬅️fdmoajmberabawcfmbacm⬅️fdmoajmaeuawcfmbacm⬅️femnaieamaabesavcgmbacm웃fhmleaaimaaeeqavcgmbeaabm웃fkmieaaimaageoavchmbabm♥fnmheaahmaamejavcgmcabm●fomheaageamaaoehaucalacfmcabm●fomhageamaaseeaucalacflambabm░fqmhafeamaaxeaaucalacelbmbabm⬇️frmhadeambazaulbcelamcacm▒fjmbffmheaaaeamda{aulbcelamcacm█fimefdmdab`aaaeaa🐱atcalbcdlamcadm█fgmlfamaea`aab`ba🐱atcalbcdlamcadeam▒fcmdecmha웃atcalbcdlambafm♥edmfeaa⌂ascalccdlambageam✽edmdeaa😐ascalccclamcaiebmceamnecmmedmcea`aa😐ascaldcblamcapebmjefmjegaa`aa♪ascaldcblamcarermhefaa`aa🅾️arcbldcalamdasekacekag`aa🅾️arcbldcalamdeaayebagehag`ba🅾️aqccldcamfat`ial`baa`bac`aa◆arcbldcamfau`han`ga◆aqccldcamgeaat`gal`hai`aa░cbapcdlccalamhat`fal`iah`ba░cbaocelccalbmgat`fal`jag`aa✽cbancflccalbmgau`eal`ja🅾️caaecolfmgadebal`aaa`fam`iaabbaa`aa웃caabcrlemheaaceaam`aaa`fan`ibadbaa`ba☉abcrlemheaas`bab`ban`aaa`gaabadbaa`aa☉ctlfmhat`aau`hbadbbaa☉csmacalemhat`aad`aaq`hbca~caaicvlcmiay`bao`laabaa|cbahcrmacclbcamheaay`bac`dai`lbbaxccaaccafcrmaccldmgaz`bac`daj`kaabaawcdabcdadcqlamaccldmga○`fai`jaabba}cbmbaccqmacelcmga{`aad`cam`iaabaa█mbabcqmbcdldmea➡️`iaabaa█cbabcpmbcflcmea➡️`iaabaa○caadcpmacglcmea★`haabaeaa⬇️cpmbcglacamdeaa⧗`haabaa⬇️cjmacembcilamcaˇ`gaabaa⬇️cdlacblbcalbmaccmackmca❎`caa`aaaeaa⬇️cclifamacbmackmbaあ`ca✽caljmafbcbmbckmaa▥`baa`aaceaa▒llmafamdcla▥`ba♥llmfckeaaるllmbcmaaebaるllmbcmecaるlkmccledaるlkmccledaこeaa~lkmccmedaうebmca█lkmdcledaあeamgeaa~lkmdcledabeaa♪eaaimafbmfeaa}lkmdcmmaecaaeamaeaa웃mafamaaccaadmafamheaa}lkmbcamacmmaecaaeambeba✽mafdmdeaabeafamjeaaqedaglemfeccomaebaamfeaa{eamaecmbffmdeaabfbmbfamgbaapeameabcdlbcceamdebmbeaaacnmaebmheaaoeaaimdfjmdaamafamcfbmdfamaebaneamefaaacelacdeamceamgaacaeaaacfmacbecmbebadeamdeeaembecabebmbfomcaafbmdfamcfbmceaameambeambeaaacelbmacdmbeamffaeaaambeacimdecafeamhfamhftmdfamdfbmcfameeaajebmhcelcmacdeamcfemaaamafbcimceaakeaaaeaaaeafcmbf{mbfbmgfbmgeaaheamefemaaacclbmbcemafbmdfbeamafbmacimbeaaaeamgabeamdfdmaeamgedmcfdgbfjmffbmieaafeamcfimacclccgmbecmbebaamafamacimaeaaaeamhfamaabmcfemcecmcfjgafrmkeaacecmafcmafhcclcmaccmacbehmcfamacimaaaeamgfeaaebmaflmifumlegmafcmafaeaaamafbmbccldccmdedmefamacimbaamgffmaaaeamafhmaeaaaebmgeamcfmmbfbmlefmcfdmaaacamafbmaaaccldcdmdecmcfccjmbaamffemcaaeamafgmaaamaflmaeamafkaambfamaaaeamkedmefbmaaacbeafbmacdldcembedmbfcmacjmbaamffdmaadeamaffmaaaeaaafneamafjeamcedmlebmefbaacceamafaeacaeacamaldcfmbecmbfcmacimcaamefemaadmcfeebacfnaamafhmhebmkebmdfbabcimbldmaceeamaecmbfcmacimcaaeamdffabmefeeamaacfnmaaafbmbfdmeebmceamjebmdfamaaacjmbldmacfmbebmbfcmacimceaaamdfieamcfdmaeafamaaaeafimeeaaaeamcfdmcfamaaaebmmeamdfbmackmbldmacfmhfamccfmdeaabmcfieamcfdmaeaffmdedabecmefdmaeamafamaaaeemdfbmdecmbfbcamccimaldmacgmhfamdcdmeeaabeamafhmaeamdfcmaeafbmcehmjfemaeamafamaaceemdfcmbecmichldmacgmhfamcefmeeaabebmbfdmaedmcfcejmhfkebmafamaadebcaedmtcfldmachmeeamafbmbegmfebabedabeamhfamaaaedmifnabmafamaaaeaaccfebmffamafbmicdmaldmachmbeamdfcmceemieembeamufpmaabeambaaebcbaacgeamefdmjccmaldcimefemdedmmfamaeamffcmgfvmaacmbeccmmscbldcjmafbmaffmdecmjfdmefgmcfyadebcrmrcaldckmafjmceamhffmffbmafemafxgamaaaebcbeacsmrldclmafjmkfemhf~gbfaeaaaeacaeccembcbmdcgmqldmbcfmbccmafimkfemffomafogcmaaaeeccmpccmpldmccdmbcdmbfimifemhfimafdacmafmgafaeemaeacbmicbmicamoldmdccmbcaldmbflmbfambfamdabmcfambfdmafdaaffmafamaeamafhgbmaefmlccmjcamnldmecamalamalemcflmafbmeebmaaamafbmbfcmbfcmbffmgfdgbfamaaaeacaeem♥ldmhlhmbfimjaaeamgfdmafgmefhgcmaabehm♥lcmilimdfamqeemdfgmefigcfamaaaejmxlamnldmhlkmxegmbeamdfigbfeaaejmxlcmmldmhlkmaldmjebmpfhgefcmanbfbeem○lcmelamfldmhlqmflambedmhfkgffbmbndoagamaeam🐱ldmdlamflemalbmelpmkeemefigefcmafambndoagamaeamzlbmblcmalemdlbmdldmalemclqmjeamaeemcffgdfgmafbndfaoagamacamqlamilemclemblamalamdldmalcmelrmkehmdfmmafbndfaoagamaaamplgmdlnmalcmdldmalbmeltmjelmcfjmbfbgafdoamaeamolkmalrmafclgmdlvmfecadecacedmbfimbfagdfcmqlrfdlifcfblafaldmblxmdecabecaaeaacedmaecmafgmbfagffamplqfhlffdfeldmblwmafamaeamaeaabehabeaaaebacebmbfdmbfagffamplqfklcfdfelamaldmalvfamaaaeamaaceumafbmdgffamolrfklcfdfflamclwmaeaaceaabemmbeamaedmcfamdgffamnltfklafefglvmdeaaaeaaceambeeaaefmbdamafamaeamaeaabmafambeafagefamnltfqfjmalpfcmaecmaebmdegaaefdamafaoafamaabebmdeafagefammlffelafblgfqfclafglmfamiecmdejmaecmbfaoamaedmbedfagdfbmnlafplbfrfblbfilhfalambebaceeafeifadaebmafambeadcmaebmaedfagdfbmmlaf✽falafklhmbabeeamecacfbdcmaoaecdcfbmaeemagdfcmklbf✽fmlffamaacedaoedabmbdbmbfaeaaaebdamaocmaedmagcfilbmclcf✽fnldmbaaeaabeeafebafefaaeamdfaeaaaebmbodfaecmagbfklbmblaf♥fnlcmaeaaaeiaeecafegaaeamafcmaabeamadamaodfaecgaf▤fplamaelaeecadeiaaeamafaoamaabeamcodgafaebgaf▤fpmaegmaeladenmaeaaceambodgaoamaeafagaf❎folacambedmbelacemmaeaaeeambocfaobfamafagaf❎fnlacbmbedmbejadefabefmceaadeamafaocmaoafcgaf❎fnlacbmbedmbejacefadefmdeaabeambfaobmafcmagaf❎fnlacbmbecmaekacegadefmfeaaaeambobfegaf❎fmlaccmbebmcejabegadefmiebfeoafbgaf❎fmlacbmcedmaejabegadegmheaaamafdoafbgaf❎fmlacbmcedmbejaaegadegmiebfaoagaoaffgbf⧗fmlacamfecmaejaaegaeefmjeamafamafegbfˇfmlamheamceiaaegaeefmlebmafいfomgeamcefaaebaaegaeegmlebfいfomlegmaehaeehmlaamafあffgcfgmkedmdehaeeimkebfあffgdfhmjecmdeeabebadehmbeamjeamaf▥ffgdffgafamlegmaeaacebacegmdeamaeamieaf▥fcghffgafamgfamdefmaeaacebaaecmaedmbecmnf▤fdghfhmbfamhehabelmaedmaeamgfamdf▤"

s1="cover"
s2="selectready"
s=s1
selected=1

-- pos for menu
mx=1
my=20
lh=9

function _init()
 tick=0
end

function _update()
 cls(0)
--  print(ord(pics[2],0))
--  print(ord(pics[2],1))
--  print(ord(pics[2],2))
--  print(ord(pics[2],3))
--  t=s2t(test2)
--  rle2(t,0,0)
 if s==s1 then
  if tick>120 then
   s=s2
  end
 elseif s==s2 then
  if btnp(3) then
   selected=selected+1
   if selected>4 then selected=1 end
  elseif btnp(2) then
   selected=selected-1
   if selected<1 then selected=4 end
  elseif btnp(5) then
   if selected==1 then
    load("nezhapoems_01.zhcn.p8")
   end
  end
 end
 tick+=1
end

function _draw()
 draw_bg()
 draw_title()
 if s==s2 then
  draw_selection()
 end
end

function draw_bg()
 rle1(pic,0,0)
end

function draw_title()
 _t("title1",86,109)
 _t("title2",46,118)
end

function draw_selection()
 if selected==1 then
  _t("poem1",mx,my,14)
 else
  _t("poem1",mx,my)

 end
 if selected==2 then
  _t("poem2",mx,my+lh,14)
 else
  _t("poem2",mx,my+lh)
 end

 if selected==3 then
  _t("poem3",mx,my+lh*2,14)
 else
  _t("poem3",mx,my+lh*2)
 end

 if selected==4 then
  _t("poem4",mx,my+lh*3,14)
 else
  _t("poem4",mx,my+lh*3)
 end
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
