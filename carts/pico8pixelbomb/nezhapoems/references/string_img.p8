pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--string-based logo & graphics
--rendering system 2.0
--by jadelombax

function _init()
 pics={picnic,antiriad,ryu,zlogo,mmlogo,smblogo,pullfrog,hotfoot}
 mode,sel,hud,tic=1,1,1,0
 new_s=""
end

function _update()
 cls(info[sel][3])
 b=btnp()
 mode=mid(1,mode+b\8%2-b\4%2,2)
 if mode==1 then
  sel=mid(1,sel+b%4\2-b%2,#pics)
  x=63-(ord(pics[sel],2)-96)\2
  y=63-(ord(pics[sel],4)-96)\2
  
  rle1(pics[sel],x,y,info[sel][3])
  
  if(btnp(❎))hud*=-1
  if hud>0 then
   ?'⬅️➡️:select      ❎:toggle hud',3,1,7
   ?'⬇️:encode string',3,7
   ?'cpu:'..(stat(1)*100)..'%',3,110
   ?'compressed string size:'..(info[sel][1]/1024)..'kb',3,116
   ?'size using spritesheet:'..(info[sel][2]/32)..'kb',3,122
  end
  
 else
  if(btnp(❎))encode_string()tic=45
  if #new_s>1 then
   nx=63-(ord(new_s,2)-96)\2
   ny=63-(ord(new_s,4)-96)\2
   rle1(new_s,nx,ny)
   ?'cpu:'..stat(1),1,1,13
  end
  ?'⬆️:back',1,116,13
  ?'❎:encode string',1,122
  if(tic>0) print('string posted to clipboard',15,80,11)tic-=1
 end
end

mmlogo="`み`{`xhd`fhd`bhg`bhf`chh`y`wde`ddf`add`edc`gdi`x`vnf`cnf`bnc`fnc`gnc`bne`w`ugg`aghaagi`agdaagd`aaagcabge`v`teqaaei`aed`aed`aaaecacee`u`sldaalf`aleaa`ald`fld`bldablk`t`rgdabgd`aaagfaagdaf`ageabgdaagl`s`qldaclcacleabldaf`aleabldablc`aablf`r`pgdac`agaadgfaa`agj`aaagkaagcadgf`q`ogdac`badgfabgk`aabgkaagcadgf`p`qad`cac`cae`bad`gae`bad`bac`caf`r`mgg`daa`dgg`aadgiaeggab`dacgf`n`lgh`ggiadgkadgiaa`dabgg`m`kgi`fgi`egk`egj`fgg`l`jgj`dgkaa`cgm`caagl`cabgg`k`igk`cgkab`bggaagf`caagn`aacgg`j`hgdaagg`agmaa`cggaagg`cgpacgg`i`ggdabguaa`bggacgg`baaggabghabgg`h`fedacekaaehaa`cegaa`aaaeg`baaehadeo`g`eldac`aliaclhaa`blgab`aablg`aaalhafln`f`dgdac`bghacgiaa`agu`aaaghaggm`e`cldac`clfaelhaa`blu`aaalh`cafll`d`bgdac`dgdae`agiaa`agwaagi`dafgk`c`agdac`egbaf`bgiaa`aggaigg`aaagh`fafgj`bgdac`faf`cgiaa`aggakggaagi`gafgi`bad`gad`fai`baw`aai`jak`c`aad`hab`hai`bag`iag`bah`laj`bad`rai`bag`kag`aai`mai"
pullfrog="`ク`○`ibl`○bq`…`fbq`{bu`🅾️`dbfkjbd`ybdkobd`♪`cbdkobc`wbcknjckbbc`😐`bbcknjbkbbb`ebg`dbf`abbcakmjekbbb`😐`abckojbkbbb`dbi`bbjcaknjckcbb`😐bcklcckebb`cbckebfkdbdcbksbb`😐bbcaklbbcbkdbb`bbckgbdkfbdcbkrbb`😐bbcaklbccakcbc`bbbcakdjbkabccakdjbkabdcckncabc`😐bbcckkbbkdbb`cbbcakdjbkabccakdjbkabfcakfcgbj`rbg`nbdcgkjbc`cbbcbkgbbcakgbb`abccakfbs`dbh`cbi`m`abicakibc`dbccckebbcckebb`bbbcakjbfkfbd`bbj`abckebc`l`cbgcakgcabg`abecbkdbdcbkdbb`bbbcbkjbckjbfkfbekgbc`k`hbbcbkfbocakdbecakdbb`bbccakjbbkfcakbjbkabdkejbkabccakejbkabc`j`hbccakfbekbbckbbccakdbb`abbcakdbb`cbbcakjbacakebacbkajbkabccakejbkbbbcakbccjbkbbb`j`ibbcakebecakbbbcakbbccakdbecakdbc`bbbcakibbcakebbcakdbccakibbcakbbbcakdbb`j`ibbcbkdbb`abbcakcbakcbccakebdcakdbd`abbcakfcbbccbkebakdbdcakdcckbbbcakcbacakdbc`i`ibccakdbb`abbcakgbccakgbbcakfbb`abbcakfbfcbkhbecbkcbbcakbbbcbkibb`i`jbbcakdbb`abbcakgbccakgbbcakfbb`abbcakfbc`abccakibecakdbacakbbccbkhbb`i`jbbcakcbc`abbcbkebdcbkebccbkdbc`abbcakfbb`cbbcakdcbkdbdcbkfbecbkgbb`i`jbbcbkbbb`bbccbkcbfcbkbcabecdbc`bbbcakfbb`cbbcbkbbbcckbbecckcbc`abccdkdbb`i`jbccbbc`cbcccbc`bbccbbd`abh`cbbcbkebb`cbccbbecbbc`abdccbkcakdbb`i`kbf`ebg`dbg`cbf`dbccakdbc`dbm`cbqcakdbb`i`lbd`gbe`fbd`pbbcbkcbb`fbd`cbd`fbhkcbdcakcbc`i`∧bcccbc`|bbcakajbkabccakcbb`j`❎bg`}bbcakajbkabckdbb`j`▤be`~bbcakjbc`j`めbbcakibc`k`めbbcbkfcabc`l`めbccfbd`m`もbk`n`やbh`p"
hotfoot="`ツ`ymhibmgitmji⌂m~igma`fmaibma`emaitma`hmhi⬇️ma`rmb`hmhma`fmaibma`emv`om✽`rmb`omama`fmaibma`emb`rmb`oma`nmb`rmb`rmb`omama`fmaibma`emb`rmb`oma`nmb`rmb`rmb`omama`fmaibma`emb`rmb`oma`nmb`rmb`rmb`nmbma`fmaibma`emb`rmb`oma`nmb`rmb`rmb`nmaiama`fmaibma`emb`rmf`fmg`mmb`rmb`fmf`fmf`fmeiala`flaibla`elb`rlaidla`flaiela`mmala`rlb`flaidla`flaidla`flaiela`fld`elb`flamdla`flaidla`flaiela`flamgla`flamdla`flb`flaidla`flaidla`flaiela`olb`flaidla`flaidla`flaiela`flaigla`flaidla`flb`flaidla`flaidla`flaiela`olb`flaidla`flaidla`flaiela`fleicla`flaidla`flb`flaidla`elbidla`flaiela`olb`flaidla`elbidla`flaiela`jlaicla`flaidla`elc`flaidla`elaiela`flaiela`olb`flaidla`elaiela`flaiela`jlaicla`flaidla`elaiala`flaiclb`elaiela`flaiela`olb`flaiclb`elaiela`flaiela`jlaicla`flaiclb`elaiala`flaicla`flaiela`flaiela`olb`flaicla`flaiela`flaiela`jlaicla`flaicla`flaiala`flaicla`flaiela`flaiela`flc`flb`flaicla`flaiela`flaiela`jlaicla`flaicla`flaiala`flaicla`flaiela`flaiela`flaiala`flb`flaicla`flaiela`flaiela`jlaicla`flaicla`flaiala`flaicla`flaiela`flaiela`flaiala`flb`fle`flaiela`flaiela`fleicla`fle`flaiala`fle`flaiela`flaiela`flaiala`flb`qlaiela`flaiela`flaigla`qlaiala`qlaiela`flaiega`fgaiaga`fgb`qgaiega`fgaiega`fgaigga`qgaiaga`qgaiega`fgaiega`fgaiaga`fgb`qgaiega`fgaiega`fgaigga`qgaiaga`qgaiega`fgaiega`fgaiaga`fgb`qgaieghiegb`egaigga`qgaiaga`pgbieghiega`fgaiaga`fgb`pgbisggigga`pgbiaga`pgaisghiagi`pgai🐱ga`pgaibga`pgaisiqgri🐱gribgris"
picnic="`ト`トl{anlmarliaglda░lsablhaplaamlaaclbablcacliaglda⬇️lsaclbabldabldavlcablbaclcablkaglca🐱ltablbacleaelcaqliabllabldaglba▒lvaalbablfaaldarllabljaclbailba█lvaeliarlnacljablaaklba○lwaqleaelsabllablda♥luablfailbabl☉ablfa●ltacldabliael●aclga✽ltabldaclhaclaabl●ablia░lzabliabl∧a⬇️lよa▒lなabldablka○lなaclbaclla~lにablbablna}lねablpa}lねacloa}lとablcadlla~lたablbaclcadlka~lかablhaclbablaadlaaclja}lかaclbabldabldacleablja|llocl➡️ablbacleaelcahlia{ljodgboal➡️aalbablfaalda🅾️liocgeoal…aeliaglda✽lgodgfoal➡️aqlia⬇️lfodggobl∧ailbablia▒leodgioal⬆️abliaelja○ldodgjobl★aclhaclaablma|ldodgkoal★abliablra{ldodgkoalにa}ldodgkoalのazleocgkoalのazlfodgioalのazlgoggeoalのazlhoeggoblぬazlhoegioalにazlgofgjoalそabldazlfoggjoalそaclcazgelaohgioblそablcazgfomgdoalつablaazghohgaocgboblてa|ghofgdoelつablaa{grodlつaclaa{groclてablcazgroclcoageoblせaygsoeghoalすaygsoeghoblさazgrofgioblこazgsoegjoblくa{gtoegkoelうa{gvoggkoblいa{gxofgkoblあa{oegtoegkocl▥a{ofgsoggiocl▥a{oggroogaocl▥aaiaayohgqleocl⬆️ialoaaibaxoigplいiaoaialniaobiaawojgnlうobiblmiaobiaawokgklえivawoqgdlsodl♥iwavoogaoagelmodgeobl░ixavopghljodghoal🐱izauoqghlgoggil█i{auougdopggoal○i{auolgaoこie`bik`bihatoにif`bik`bihatlにi}atfなi○aslなi○asmafとi█armaoaf●mbf⬇️ijdjioapmbobf🐱mdoaf🐱i░aomcoaf▒mfoaf█i✽aombocfmmcfnmhobf~i♥anmdoamafkmdoaflmhodf|ijorilanmhffmhoafimkobmbg{ihovijanmwoamafemqfzihoxijammgoam☉gyigoziiammgobm☉gxigoziiamm⧗gbmbgsifozihanm▤gtidozifapmあgeaagaaagjidozifapmいgaaagcaaglicozifapm웃iamrgaaagaaaggcageicoyifaqm☉iagaiamoaambaagaabgbaagccagcabicoqeaogifaqm🐱namfiamdaamkaambaegaacgbcagaacidcaoccaojeaogifarm▒naganamfcamdaamdaamdaamacamaaacaahgacaad`aiccaoccaofedogiccaicafccadccabm🐱namgcamacbmaabmdaamaacmacbaacaaacaagcaaacb`bidcaibcboacaocfagamboccaoaiechaaclaam🐱cakamfccmdaamacamaaambadccaacaabcaaacaaccbgb`biccaiachfagambcaibcbiaclabclm🐱kamckamccamfabcb`aaamaabcaaaccaacfaacahbgdcnfagambc█m█kamakamfcbmdcb`aaa`acb`acdaacdabcdhcgfhkcbfagambc█m█kcmdkamacbmeca`aaacbkaceabccaacehbgbcdgbheibhefagambbac○mxkamfkbmakamakambkacbkacemacbkbcnhegbcdgbhdiacajaiahdfagambbbhcc{mxkamfkbmakfcbkacbkcmacbkbcmhggacdgabbhbidjaiahcedbahbcahac{mukamckamckdmakicbkjcjhrifhkc|mhjamlkbmbkbmakocakkchhacahsidbbhic}mgjagajamlkamakcmakdnakxcdhxibbbhgcahbcukacgmhjamjkbmakinaganakycah⬇️cahbcvkacgmckamdcamfkamacckamakjnacakyhckbh○cahacbkacgkacdkacgkacgmckamckcmdkbmacakcmakkcakxhekahgkahnkahfkahacdkacbkbcckacdkacgkccakaccmckbmakcmdkamakamak…hakahbkchmkbhdkahakccakacakacbkbcckacekacbkacckdcdmckbmbkacakamakamakambk➡️hakahbkchckchakchckahekahbkjcckccckacbkacbkecdkbmakcmakacakamakbcbmakけhakchekahakkcakacakgcbkbcakecdkhcakacakdcakたhakwcakdcakacckacdkkcakわcakbcakbcdkacdkゅcbkdcakccakbcdkacdkょcckacakacakbcakbcdkbcckアcbkacakacakbcakbcikエcfkacjkオcfkbchkょcakacakccdkcchkょcakbcakbcekbchkょcakbcakacgkachkょclkachkアckkbcgkkiakらcgkacckbcgkjiagaiakよcdkacbkacckbcgkkiakりcckacbkacbkacikdjakfcakdiakやcbkbcakacbkacikcjagajakiiagaiakるcbkacekbcbkdjacakjiakれcbkacbkacbkccakacjkfcakるcckacbkacakdkacakbcakbcakbcakfcakんcakfkacbkacakbcakbcakコkacakacbkacbkacbkカcakckacakbcakbcakacbkコkacjkコkナ"
antiriad="`ト`ト`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`sdaheda`eh●`う`sdahfda`ddah░`え`tdahfda`ddah🐱`お`udahfda`phe`udb`▤`vdahg`ohe`thd`❎`nhfda`bdahg`fdahd`che`chdda`bdahd`dhf`gdahd`ldahfda`bdahfda`l`mdahg`chh`edahd`che`bdahdda`bdahd`chh`fdahd`lhgda`bdahg`l`ldahh`chhda`ddahd`che`bdahdda`bdahd`bhj`edahd`khhda`bdahh`k`lhi`chida`cdahd`che`bdahdda`bdahddahl`ddahd`khhda`bdahhda`j`khj`chjda`bdahd`che`bdahdda`bdahi`bhg`cdahd`jhida`bdahi`j`jdahj`chl`adahd`che`bdahdda`bdahh`dhg`bdahd`idahida`bdahj`i`jhk`chedahgdahd`che`bdahdda`bdahg`fhg`adahd`hdahjda`bdahjda`h`idahk`chdda`adahk`che`bdahdda`bdahfda`ghfdbhd`hhkda`bdahk`h`ddahada`adahfdahe`chdda`chj`che`bdahdda`bdaht`adahd`cda`chgdahdda`bdahddbhf`g`dhcdahg`ahe`chdda`cdahi`che`bdahdda`bdahs`bdahd`bdahbda`ahfdbhdda`bdahdda`ahfda`f`chk`bhe`chdda`ddahh`che`bdahdda`bdahddahm`cdahd`adahjda`bhdda`bdahdda`bhf`f`bdahjda`bhe`chdda`edahg`che`bdahdda`bdahd`bdahj`ddahddahk`chdda`bdahdda`bdahf`e`bhk`che`chdda`fdahf`che`bdahdda`ehb`cdahh`edahddahj`dhdda`bdahdda`chfda`d`cdahh`dhe`chdda`gdahe`che`bdahd`abaleba`dhg`fdahd`bhi`dhdda`bdahdda`dhf`d`ddahfda`dhe`chdda`hdahd`che`bdahbda`ali`dhg`edahd`chgda`dhdda`bdahdda`dhg`c`dhhda`che`chdda`hdahd`che`bdahada`alaba`abaldgamala`dhg`ddahd`chhda`chdda`bdahdda`ehfda`b`chjda`bhe`chdda`hdahd`chdda`cda`alb`cbadagcdalb`ddahf`cdahd`bhjda`bhdda`bdahdda`edahf`b`bdahkda`ahe`chdda`hdahd`chc`abalb`bbalc`bdahbiagalcba`abalbhg`bdahd`ahldbhdda`bdahq`b`bhs`chdda`hdahd`cdb`blcba`alebadahadaleba`alddaheda`adahcda`ahrda`bdahp`c`adahf`adahk`chdda`hdahd`bbalcbbgbbblfdbhalf`alagbbalcmahcda`adahada`ahgdahkda`bdaho`d`ahf`cdahj`chdda`hdcmaldgcla`alcbaldbbdb`abalebalcbalagclcmaba`cdahf`chjda`bdahn`e`ahf`ddahi`chdda`gbaldgflb`alcbb`nlcbblcgdledaheda`dhida`bdahm`f`bhd`fdahh`chdda`eldgdldbd`alc`gda`glcbeldgdlcbahc`fhhda`bdahl`g`chbda`gdahg`chdda`ebalagbldbelc`alcba`dbalc`ebalbbblcbeldgblamahb`hhgda`bdahk`h`ode`edc`gbalbbdlhbblbba`dmagblama`dlcbblhbclcba`ada`jdf`ddj`i`fd|`bbblm`abalb`clbgblbba`bbalbbbllbb`aha`cdz`l`fh~daballbclbba`aldgalcba`abalbbclkbbhbda`ah|`k`gh○`olc`aldgald`alc`nhd`adah{`l`hh~`bbc`bbb`jldgald`ibc`bbc`ahc`adah{`m`ih|`blebd`ili`ibdle`ddahz`n`●baleba`abalabhlbba`elcbglabb`alf`♪`●baleba`bbalhba`blbgalaba`abaliba`blfba`😐`✽lbgaldba`cbaleba`clfba`clf`dbalg`⬅️`⬇️balcgalcba`abc`hljba`hbb`bldgalc`⌂`⬇️balh`blbbfldba`dbaldbglaba`abalh`⌂`⬇️balh`bbaliba`bbe`blj`bbalhba`웃`⬇️belcba`cbalfba`bbalgba`bbalfba`cldbe`웃`☉balb`fbc`dlk`dbc`ebalb`◆`░balcbbla`jbald`cda`bbaldba`jla`abalcba`⌂`⬇️bale`ibb`alddhbalcbc`jle`⌂`⬇️lf`ilbba`alb`jbalb`alc`ileba`웃`🐱balbbalabb`hbalc`abalada`imalaba`alc`ibbld`웃`🐱baldba`ibalbba`bba`bdb`cdb`bba`bbalb`jldba`웃`▒balfba`hba`alc`ddaia`cia`elcbb`hbalf`☉`▒lh`ebalfba`ddagaibgbda`dlg`ebalh`♥`○baldba`blc`dbalfbb`ddbiadb`elg`elc`bbaldba`✽`}balg`abalc`dbalg`ddbiagadb`dbalg`elcbblg`░`}baljba`ebalfmadb`biagaicgada`adagbibmald`fldbalf`░`~balfbc`fbaldiagbiada`bdaibdaib`bdaibgcdalc`gbclfba`░`○lbbb`bbc`fbalciagbiada`ddaic`cdbiagdmalb`gbc`bbalc`✽`🅾️balbdagdiada`ddaiada`eiagdmalaba`ˇ`♪ldbaoagcdc`idciagaoaiabalcba`⧗`😐le`aiagbiadaib`hiaoagaidda`ale`★`😐le`bdaiadagcib`ddaiagdiada`cle`★`😐le`diageda`cgfibdcmald`★`😐le`adb`adageoaia`aiageibgbibdald`★`😐ledagbda`adaiagcoaia`aiagcoaiadbgddald`★`😐legdda`adbicdcicdb`adaiagbiadald`★`😐balabcgcia`qdaidmabc`★`…dagbiada`fdd`gdaiagbia`∧`…icda`fdaibdagadc`cdagdda`∧`◆dagada`cba`cdaiedc`bdagcoaib`∧`🅾️bagbdbia`abb`bdaic`aic`bgcid`aba`ˇ`🅾️bagbdaiada`aba`ddc`adcgcibdc`alb`ˇ`♪badagbib`abalaba`cdaibdcgbiadc`dlbba`⬆️`🅾️iagaibdabblaba`cdc`adbibda`gbalaba`⬆️`⬅️balabaiagbia`bbalabagamb`qbalcba`➡️`⌂balbbagbia`albba`cgbmbbb`llfba`…`♪iagbia`alcbbgamagabb`nldbb`➡️`⌂ba`aiagbiada`alaba`abamabagambdambba`pbb`…`☉lcdaibdb`alabadd`abadaba`abamaba`kbalgba`🅾️`♥ld`adaiadeiagbia`adbgbda`lbaliba`♪`●balabd`adb`adaiagdoada`abamadcbbma`hbblbbg`♪`●lcbd`bdaiageiadb`aba`bmagama`ibilc`😐`{bcmbbamahbma`abalgdaiagdibdd`bdc`ibbljba`ahdmahamcbc`○`ubbmcoahaoiba`abfhaiagbidgbia`pbbldbgmaoagaocgaochcmdba`z`pmdhaolbeoamaba`cdaicdbgcibda`ibc`gbb`ebamaobgaoegaoihambbb`v`kbamdhaoemahaobmabambhboegdochada`adcgaiada`dba`dgaocgaba`docdamahbodhamabfmaoomabc`r`hbcmbhaohmbhbodgaoagloa`eda`dmaob`dgdoa`dmagaocheokhcmchgmdbamabb`p`hbcmbhbofhambhaofggoageoaba`gmaocba`dmahaoc`dbahboggkocmboihambbamabb`p`gbdmahbokhbmbhaolhambba`cbamaoeha`hba`ehaocglocgaodmaobgbohhamabb`abc`m`gmabcmahbohgcocmbbbhbodhamabbdaghochaba`mdaiahboegioagbodmaobgdohhamabambbb`m`hba`abbmaoahaokmboemeocmboagdoadamaba`piagbda`chbocggofmaobgfogmbbc`o`ibcmdhbmahamahbmahaocgeocgaoagbobhabambba`tdaiagbiada`ebamaojhamahaocgboghcmbbamaba`p`lmabamehcoegboagiobmb`yiagcia`gmaofhamahaocgdoihamcbb`q`nbcmahcokggobma`zdaiagcia`dbahbmeoahambhaomhbmabb`t`rbamcoahaocgaodgaoagaoh`zibdaibdahboigbocbamaohhambba`aba`v`tba`abbmchboahaomma`tbahama`adaicdahaoageocgcobhaochamfbd`y`zba`abdheoahaoghabbmaocmaba`jmaobmadaiadbmaoahaojdaoahamfba`▒`🐱ba`abbmghdoeha`jmaochamabamahdmibambba`♥`◆bamg`kmbbamebbmaba`abb`…`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ`ニ"
ryu="`░`に`qde`p`pdbbddb`n`odabadbbeda`m`ofadabadbbdda`m`ofbdabadebada`l`obafabafbbafadaeabada`l`ndabadbfabbfadafadb`l`nbadaoadanadaaboadb`m`jfaea`aeafadaoadaoagaaadb`o`hgafagbeafbnadboanaobdb`n`ddegafaeagafanaoadboeda`n`cdanaocdagafagafadaobnadanaoadd`n`bdanaocgbfbgadboanadcnaobdafaea`dfa`h`bdaoefbgbnadanadaoadanadcffgafa`h`bdaodnafbgafaoanadboadanbdafcgafagbfc`g`bdanaobnadafbganboadaoaddfagafagcdanbda`h`adanadcnbdafagadanbhadanaoadbfagafagafadaocnada`g`adanaobnaocdafadbhbdffagcoeda`gdaoadanaoadanaobdafadbhcdanaobnafagafbdanaocda`gdaobnbdcnaddhcdegbfanaocnbda`gdaobdaocnadbhbdahcdanaobdagbdanfdb`fdanadaocnbdbhbdbhadffagafadanddc`fdcofhddcaaobdbfagcdh`edbncocnahedanaaadcgafagbdbnadbnadanada`e`adbnddchcdcgafagbfcgadanedanada`e`adanidbfagbfagcfddcnbdd`e`adangdcfdgdfeddnaoanadb`d`adanadanddbffgcfedcndobda`d`bdffodaoadenboada`d`gfodaoadbaadh`c`geafndbobnadahadcnadb`c`heafndcoadbhadbnbda`c`hacfiacdanaobdbhadbnbda`c`haaeaandcoadahadbnada`d`heafaajeafbaanaocdahadd`d`geafcageafedcnahadd`e`gfdaaeafaabeafdeafbdanb`add`f`feafcabfbeaaaeafeeafbdb`k`febfbabfcabfeeafb`m`feafbeaabfcabfeeafb`m`ffdabfcabffeb`m`eeafdabeafbabffeaaa`m`deafbgbfaabfaebabeaffea`m`dfbgcfaabeafbabfh`m`ceafageabeafbabfcgcfaea`m`cfagffaaaeafbabfbgefa`m`beafagffaaaeafbaafbgffaea`l`bfbgffceafdggfa`l`bfaghfceafcggfa`l`aeafaghfceafcggfaea`k`aeafaggfcebfcggeb`k`afaggfdebfcggfaea`k`afagffbgafb`beafbggfaea`k`afaghfbea`beafbggfb`keafaghfbea`beafcgffbea`jeafbgffbea`dfcgffagafaea`ieafegbfbeafa`deafagafagffagafaea`heafk`efbgafagafagcfagafaea`heafhgafaea`eeafagcfegafb`heafggbfaea`feafagcfgea`geaffgbfbea`geafagbfgea`g`afkea`feafjea`g`afkea`geafj`g`aeafjea`geafjea`f`aeafj`ifjea`f`aeafiea`ieafiea`f`aaafiea`jfj`f`aaafj`jeafj`e`bfj`jeafiea`e`bfj`keafiea`d`afl`jeafgdb`e`afheafaea`keafgdc`d`beafeea`aea`leafgnadb`d`cdbfbdb`neafaeafaeafbdanbda`d`cdanbdd`nea`afa`adbncdb`c`bdanddanada`qdanfdb`b`adanfdc`odcnedb`bdanddanbdc`odaobdhdanadcnbdd`odanaoadaoadaoadanadbnadaoadanaoanadc`pdk"
zlogo="`る`웃`●hc`aha`aha`ahc`eha`chc`bhb`ahc`ahb`bhb`ghb`ahc`k`♥ha`bha`aha`aha`gha`cha`cha`cha`cha`aha`aha`aha`eha`aha`aha`m`♥ha`bhc`ahb`fha`chb`bha`chb`bha`aha`aha`aha`eha`aha`ahb`l`en|`fha`bha`aha`aha`gha`cha`cha`aha`aha`cha`aha`aha`aha`eha`aha`aha`m`dnah|ba`eha`bha`aha`ahc`ehc`ahc`ahc`ahc`aha`aha`ahc`ehb`bha`m`dnah{ba`こ`cnahebonahfba`さ`cnahdba`nnahgba`さ`bnahdba`onahfbanp`anj`dnk`jng`j`bnahcba`onahbbahcba`anahobanahiba`cnahjnb`hnahfba`i`anahcba`onahbbanahcba`bnahebenahcba`abanahfba`enahknaba`gnaheba`i`anahbba`pnahbbahcba`dnahdba`dnahcba`bnaheba`gnahebanaheba`gnahdba`inahbba`pnahbbanahbba`enahdba`enahbba`bnaheba`gnaheba`anaheba`enahfba`hnahaba`pnahbbanahcba`enahdba`enahbba`bnaheba`gnaheba`bnaheba`dnahfba`h`aba`qnahbbanahbba`fnahdba`enahbba`bnaheba`gnaheba`bnaheba`dnahfba`h`rnahbbanahbba`gnahdba`fnahaba`bnaheba`gnaheba`cnahdba`cnahgba`h`qnahbbanahcba`gnahdba`fnahaba`bnaheba`gnaheba`cnaheba`bnahhba`g`qnahbbanahbba`hnahdba`dna`anahaba`bnaheba`gnaheba`cnaheba`bnahhba`g`pnahbbanahbba`inahdba`cnahaba`aba`cnaheba`gnaheba`dnahdba`bnahbbanahdba`g`onahcbanahbba`inahdba`bnahbba`enaheba`gnaheba`dnahdba`anahcbanaheba`f`onahfba`jnahdbanbhcba`enaheba`gnaheba`dnahdba`anahcbanaheba`f`nnahfba`knahjba`enaheba`gnaheba`dnahdba`anahbba`bnahdba`f`mnahbbbhcba`knahdbchcba`enaheba`gnaheba`dnahdba`anahbba`bnahdba`f`mnahbbanahbba`lnahdba`bbahbba`enaheba`gnaheba`dnahdbanahcbancheba`e`lnahfba`mnahdba`cbahaba`ana`cnaheba`dna`bnaheba`dnahdbanahlba`e`knahbbahdba`mnahdba`dba`anahaba`bnaheba`cnahaba`anaheba`dnahdbanahlba`e`knahabanahcba`nnahdba`fnahaba`bnaheba`cnahaba`anaheba`cnahebanahbbdnaheba`e`jnahbbanahbba`onahdba`fnahaba`bnaheba`cnahaba`anaheba`cnahdbanahcba`dnaheba`d`inahbbanahcba`onahdba`enahbba`bnaheba`bnahbba`anaheba`cnahdbanahcba`dnaheba`d`inahbbanahbba`pnahdba`enahbba`bnaheba`bnahbba`anaheba`bnahebanahbba`enaheba`d`hnahbbanahbba`qnahdba`enahbba`bnaheba`bnahbba`anaheba`bnahdbanahcba`fnahdba`d`gnahbbanahcba`qnahdba`dnahcba`bnaheba`anahcba`anaheba`anahdba`anahcba`fnaheba`c`gnahbbanahbba`qnahebanehcba`anahfbanbhcbanahfbanahdba`anbhdba`enahfba`b`fnahbbanahbba`qnahobanahmbahkbb`anahgba`cnahhba`enahcbahcba`pnahabo`bbm`abk`dbg`ebh`b`enahbbahcba`pnahbba`こ`dnahfba`pnahcba`こ`cnahgba`onahcba`さ`cnahfbanphdba`さ`bnah{ba`し`anah|ba`し`bb|`す"
smblogo="`ま`⬅️laoほlaoadほ`aoadaoadはoada`aoadほ`aoadfocdcocdaocdaoedeoedaoed🅾️`aoadeoedbocdaocdaofdcofdaofd♪`aoaddogdaoc`aoc`aogdaog`aogd😐`aoaddogdaoc`aoc`aogdaog`aogd😐`aoaddod`doc`aoc`aoc`aoc`aoc`eoc`aoc`ad⬅️`aoadeod`coc`aoc`aoc`aoc`aoc`aob`boc`aob`bd⬅️`aoade`aoddboc`aoc`aoc`aob`boc`aobdboc`aoa`cd⬅️`aoadf`bocdaoc`aoc`aoc`aob`boc`ada`bdaoc`aob`ad😐`aoaddogdaog`aoc`ada`bdaogdaoc`aocd😐`aoaddog`aog`aoc`ada`bdaogdaoc`aocd😐`aoadeoe`bdaoe`boc`adeof`aoc`aoc`ad⬅️`aoade`aoc`cda`aoc`coc`ade`aoe`aoc`aoc`ad⬅️`aoadf`edc`edb`cdf`fda`cda`cd⬅️`aoadg`cde`cdc`cdg`eda`cda`cd⬅️`aoadほ`aoadほ`aoadfobdcobdeocdcoedcocdcocdgoedcoedeocdeocdj`aoadeoddaoddcoedbofdbocdboedfofdbofdcoedcoedi`aoaddokdaogdaogdaoc`aogdeogdaogdaogdaogdh`aoaddokdaogdaogdaoc`aogdeogdaogdaogdaogdh`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`addoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`adg`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`addoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`adg`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`addoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`adg`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`addoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`adg`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`addoc`aoc`aoc`aoc`aoc`aoc`aoc`ada`cdg`aoaddoc`aoc`aoc`aoc`aoc`aoc`aob`boc`aoc`aoc`addoc`aob`boc`aob`boc`aoc`adaod`cdg`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoa`coc`aoc`aoc`addoc`aoa`coc`aoa`coc`aoc`ada`aoddi`aoaddoc`aoc`aoc`aoc`aoc`aoc`aob`adaoc`aoc`aoc`addoc`aob`adaoc`aob`adaoc`aoc`adb`bocdh`aoaddoc`aoc`aoc`aog`aoc`aocdaoc`aoc`aoc`addoc`aocdaoc`aocdaoc`aoc`aoc`aocdh`aoaddoc`aoc`aoc`aog`aoc`aocdaoc`aoc`aoc`addoc`aocdaoc`aocdaoc`aoc`aocdaoc`adg`aoaddoc`aoc`aoc`aog`aoc`aoc`aoc`aoc`aoc`addoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`adg`aoaddoc`aoc`aoc`aog`aoc`aoc`aoc`aoc`aoc`addoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`adg`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aog`addoc`aoc`aoc`aoc`aog`aog`aocdd`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`aog`addoc`aoc`aoc`aoc`aog`aog`aocdd`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`adaoe`bddoc`aob`boc`aoc`adaoe`bdaoe`boc`adc`aoaddoc`aoc`aoc`aoc`aoc`aoc`aoc`aoc`ada`aoc`cddoc`aoa`coc`aoc`ada`aoc`cda`aoc`coc`adc`aoade`cda`cda`cda`cda`cda`cda`cda`cdb`edf`cda`bdb`cda`cdb`edc`edb`cdc`aoadaoadc`cda`cda`cda`cda`cda`cda`cda`cdc`cdg`cda`adc`cda`cdc`cde`cdc`cdaoada`aoadほ`ala`ほla"

info={--{size,sprites,bgcol}
{1596,256,0},--picnic
{2185,192,0},--antiriad
{848,40,0},--ryu
{622,60,0},--zelda
{522,38,0},--megaman
{455,42,12},--mario
{608,49,0},--pullfrog
{347,60,9},--hotfoot
}
-->8
--functions
--(3 versions)

--1.basic version (74 tokens)
--specify string name and 
--screen x&y coords for top
--left corner of image. tr is
--the transparency color (this
--saves cpu and allows drawing
--over other graphics like a
--sprite, no transparency if
--left blank).

function rle1(s,x0,y,tr)
 local x,mw=x0,x0+ord(s,2)-96
 for i=5,#s,2do
  local col,len=ord(s,i)-96,ord(s,i+1)-96
  if(col!=tr) line(x,y,x+len-1,y,col)
  x+=len if(x>mw) x=x0 y+=1
 end
end

--2.version w/string-to-table
--conversion (104 tokens total)
--uses approximately 40% less
--cpu power. to use, convert
--strings to tables in init()
--using s2t function
--(eg: tblname=s2t(stringname),
--then run rle() function with
--table name as first parameter

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
  if(x>mw) x=x0 y+=1
 end
end


--3.version with pre-conversion
--and horizontal and vertical
--flipping (161 tokens)
--works like pico-8 spr function
--and can flip images on h.or v.
--axis by setting hf and vf
--parameters to any non-nil
--value.

function s2t(s)
 local t={}
 for i=2,#s,2 do
  add(t,ord(s,i-1)*256+ord(s,i)-24672)
 end
 return t
end

function rle3(t,x0,y0,tr,hf,vf)
 local x,y,mw,dy=x0,y0,x0+t[1],1
 if(hf) x=mw
 if(vf) y=y0+t[2] dy=-1
 for i=3,#t do
  local v=t[i]
  local col,len=v\256,v&255
  if hf then
   if(col!=tr) line(x-len+1,y,x,y,col)
   x-=len
   if(x<x0) x=mw y+=dy
  else
   if(col!=tr) line(x,y,x+len-1,y,col)
   x+=len
   if(x>mw) x=x0 y+=dy
  end
 end
end

-->8
--string encoder
--encodes spritesheet image to
--compressed string

--draw,paste or import image to
--spritesheet. if image is not
--full-screen size, position
--in top left corner and enter
--image width and height
--in pixels. then run cart,press
--⬇️ to enter 'encode string'
--mode, and press ❎ to encode
--image string and paste it to
--the clipboard.

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
__label__
ccccccccccccccccccccccccccc11111111111111ccccccccccccc111111111111111111ccccccccc1111111cccc111111111111111111111111111111111111
cccc77777ccc77777cc11ccc77c77717111777117717771111111111111c111cc11ccc1177777ccccc17771177cc771177171117771111171717171771111111
ccc777cc77c77cc777c171c711c7cc17ccc71117111171111111111111ccc11cc111ccc77c7c77cc7ccc71171717cc1711171117111111171717171717111111
ccc77ccc77c77ccc77cc11c777177cc711177cc711117111111111111ccccccccc11ccc777c777cc11cc7c1717171cc711171117711111177717171717111111
ccc777cc77c77cc777cc7c1cc717ccc7c1c7cc171111711111111111cccccccccccc11c77c7c77cc711c7117171717c717171117111111171717171717111111
cccc77777ccc77777ccccc17711777c777c7771177117111111111cccccccccccccc111c77777cccc11c71177117771777177717771111171711771777111111
ccccccccccccccccccccccc11111111111111111ccccc11111ccccccccccccccccccc11cccccccccccc11cccc111111111111111111111111111111111111111
cccc77777cccccc777c7711c77cc7717711777cc11cc77c777c777c777c77ccc77cccccccccccccccc11cccccc11111111111111111111111111111111111111
ccc77ccc77cc7cc7ccc71717ccc717c7c7c7cc111117cccc7cc7c7cc7cc7c7c7ccccccccccccccccc111ccccccc1111111111111111111111111111111111111
ccc77ccc77ccccc77cc717c7cc1717c7c7c77111c11777cc7cc77ccc7cc7c7c7ccccccccccccccccc11ccccccccc111111111111111111111111111111111111
ccc777c777cc7cc7ccc7c7c7cc17c7c7c7c7c11cccccc7cc7cc7c7cc7cc7c7c7c7ccccccccccccccccccccccccccc11111111111111111111111111111111111
cccc77777cccccc777c7c7cc77c77cc777c777ccccc77ccc7cc7c7c777c7c7c777ccccccccccccccccccccccccccccc111111111111111111111111111111111
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11cccc11ccccccccccc1111111111111111111111111111111
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111cc111cccccccccccc111111111111111111111111111111
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11cc11cccccccccccccc11111111111111111111111111111
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11cccccccccccccccc11111111111111111111111111111
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111ccccccccccccccc11111111111111111111111111111
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11ccc1111cccccccccccc111111111111111111111111111111
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11cc111ccc1111ccccccccccc111111111111111111111111111111
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11cccccccc111cc11c1111c111cccccccccc11111111111111111111111111111
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111cc11cccc11cccc111ccccc11cccccccccc1111111111111111111111111111
ccccccccccccfffccccccccccccccccccccccccccccccccccccccccccccccccc11cc111ccccc11111ccc11111111ccccccccc111111111111111111111111111
ccccccccccffff77fccccccccccccccccccccccccccccccccccccccccccccccccc1cc11cccccc1cccc1111111111111111111111111111111111111111111111
cccccccccfff77777fcccccccccccccccccccccccccccccccccccccccccccccccc11111ccccccccc1111111cccc1111111111111111111111111111111111111
cccccccffff777777fccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111ccccccccc11111111111111111111111111111111111
ccccccffff7777777ffcccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111cc11ccccccccc111111111111111111111111111111111
cccccffff777777777fcccccccccccccccccccccccccccccccccccccccccccccccccccc11ccccccccc11111cccccccccc1111111111111111111111111111111
ccccffff7777777777ffcccccccccccccccccccccccccccccccccccccccccccccccccc111cccccccc111c11ccccccccccccc1111111111111111111111111111
ccccffff77777777777fcccccccccccccccccccccccccccccccccccccccccccccccccc11ccccccccc11cccccccccccccccccc111111111111111111111111111
ccccffff77777777777fccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111111
ccccffff77777777777fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111
cccccfff77777777777fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111
ccccccffff777777777fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111
cccccccfffffff77777fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111
ccccccccfffff7777777ffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111
ccccccccfffff777777777fccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111
cccccccffffff7777777777fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11cccc11111111111111111111111111
ccccccfffffff7777777777fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111ccc11111111111111111111111111
77777cffffffff777777777ffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11ccc11111111111111111111111111
777777fffffffffffff7777fccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11c11111111111111111111111111
77777777ffffffff7fff77ffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111111111111111111111111
77777777ffffff7777fffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11c111111111111111111111111111
777777777777777777ffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111c111111111111111111111111111
777777777777777777fffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11ccc11111111111111111111111111
777777777777777777fffcccf77777ffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111111111111111111111
7777777777777777777fffff77777777fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111111111111111111111
7777777777777777777fffff77777777ffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111
777777777777777777ffffff777777777ffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111111111111111111111111
7777777777777777777fffff7777777777ffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111111111111111111111
77777777777777777777fffff77777777777fffffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111111111111111111111
7777777777777777777777fffffff77777777777ffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111111111111111111111
777777777777777777777777ffffff77777777777ffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111111111111111111111
fffff77777777777777777777fffff77777777777fffccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111111111111111111111
ffffff7777777777777777777fffffff777777777fffccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111111111111111111111111111
fffffff777777777777777777fffffffffffffff7fffccccccccccccccccccccccccccccccccccccccccccccccccccccccccc191111111111111111111111111
ffffffff77777777777777777cccccfffcccccccccccccccccccccccccccccccccccccccccccccccccccc9ccccccccccccccc199111111111111111111111111
fffffffff7777777777777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9f9cccccccccccccc9ff911111111111111111111111
ffffffffff77777777777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccff99ccccccccccccc9ff911111111111111111111111
fffffffffff77777777777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc999999999999999999999911111111111111111111111
fffffffffffffffff7777cccccccccccccccccccffffccccccccccccccccccccccccccccccccccccccc999999999999999999999991111111111111111111111
fffffffffffffff7f77777cccccccccccccffff77777ffcccccccccccccccccccccccccccccccccccc9999999999999999999999991111111111111111111111
ffffffffffffffff77777777ccccccccccffff77777777fcccccccccccccccccccccccccccccccccc99999999999999999999999999111111111111111111111
fffffffffffffffff77777777cccccccfffffff777777777cccccccccccccccccccccccccccccccc999999999999999999999999999111111111111111111111
fffffffffffffffffffff7777ffffffffffffffff7777777fccccccccccccccccccccccccccccccc999999999999999999999999999111111111111111111111
ffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff999990099999999999009999999911111111111111111111
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9999990099999999999009999999911111111111111111111
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999999999999999999999999999911111111111111111111
66666666666666666666666666666666666666666666666666666666666666666666666666666699999999999999999999999999999991111111111111111111
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999999999999999999999999999991111111111111111111
d6666666666666666666666666666666666666666666666666666666666666666666666666666699999999999999999999999999999999111111111111111111
df66666666666666666666666666666666666666dd66666666666666666666666666666666666999999999944444444449999999999999991111111111111111
ddff6666666666666666666666666666666666ddddf6666666666666666666666666666666666999999999999999999999999999999999999111111111111111
dddf666666666666666666666666666666666ddddddf666666666666666666666666666666669999999999999999999999999999999999999111111111111111
ddfff6666666666666ddd66666666666666ddddddddff66666666666666666666666666666699999999999999999999999999999999999999911111111111111
ddddfd66666666666ddddf666666666666ddddddddffff66666666666666666666666666669999999999ffffffffffffffffff99999999999911111111111111
dddddddd666666ddddddddf666666666dddddddddddffdd77777777777777777777777777799999999ffffffffffffffffffffff999999999911111111111111
dddddddddddddddddddddddfd66666ddddddddddddddddd6666666666666666666666666699999999ffffffffffffffffffffffff99999999991111111111111
dddddddfdddddddddddddddddddddddddddddddddddddddd77777777777777777777777779999999ffffffffffffffffffffffffff9999999991111111111111
dddddddffdddddddddddddddddddddddddddddddddddddddd7777777777777777777777779999999ffffffffffffffffffffffffff9999999991111111111111
ddddddddddddddddddddddddddddddddddddddddddddddddddd77dd7777777777777777777999999ffffffffffffffffffffffffff9999999911111111111111
dddddddddddddddddddddddddddddddddddddddddddddddddddddddd777777777777777777779999ffffffffffffffffffffffffff9999991111111111111111
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd7777717177777777779999ffffffffffffffffffffffffff9999991111111111111111
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd717771777777777777999ffffffffffffffffffffffffff9999991111111111111111
ddddddddddddddddddddddddddddddddddddddddd9dddddddddddddddddd71717777777377777999fffffffffffffffffffffffff99999911111111111111111
dddddddddddddddddddddddddddddddddddddddd979ddddddddddddddd1dd1711771777377711999fffffffffffffffff5fffffff99999911111111111111111
ddddddddddddddddddddddddddddddddddedddddd9dddd1ddddddddddd1dd111117111773711199993fff3ffffffffff5fffffff999999111111111111111111
ddddddddddddddddddddddddddddddddde7edddddd3dddd1dddd1dddd1d3d131111111173111109993fff3ffffff5555fffffff9993999111111333111133311
ddddddddddddddddddddddddddddddddddeddddddd3d33d11dddd1d111d3313131111111313300999939933f3fff67ddfff3f999993333333313333333333331
dddddddddddddddddddddddddddddddddd3bdddddd333dddd1d3d1dd11113331311313111337700999393333333367dd39933933333333333311333333333333
ddddddddddddddddddddddddddddddddddbdddbddd3dddddd113301d11313331333333138877773333333333333367dd33333333333333333333333333333333
ddddddddddddddddddddddddddddddddbdbdddddd33dddd33010330333313333113333888777777888888888883367dd33333333333333333333333333333333
ddddddddddddddddddddddddddddddddbbbddddbd33ddddd30133b3333311333133333887733337788888998888867dd23333333333333333333333333333333
ddddddddddddddddddddddddbddddddbbdbdbddb33b33333d33bb333333333333338888877333377888893a9888867dd22888333333333333333333333333333
ddddddddddddddddddddddddbddddddbbdbbbbbb33b33bbbd33bb3333333333333888888873333722889999a9888555528838333333333333333333333333333
dddddddddddddddddddddbdddbdddbbbbdbbbbbbbbb33bbbbbbbbbb3333333333888888888888888888999999888888888883333333333333333333333333333
ddddddddaddddddddddddbbddbbdbbbbbbbbbbbbbbb3bbbbbbbbbbb3333333383888888888888888888899992288888888833333333333333333333333333333
ddddddda7addddddddddddbdbbbdbbbbebbbbbbbbbbbbbbbbbbbbbbbb333388888888888888888888888899228888888388333333333333333333333b3333333
ddddddddaddddddddddbbdbbbbbbbbbe7ebbbbbbbbbbbbbbbbbbbbbbbbb3888888888888888888888888888888888883883333333333333333333333b3333333
dddbdddd3ddddddbd333bdbbbbbbbbbbe3bbbbbbbbbbbbbbbbbbbbbbbbb888bb88888888888888888888888888888883833b3333333b3333b3333333b3333333
dddbdddbbbddddbbd3bbbdbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbb88888b8888888b88888888888888b888888b83333b33bb333b3333b3333333bbb3b333
dddbbdbbbddddbdbdbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8b88bbb8888888888888bb8888b8bbb3b3b33bb333b33333b33b333bbbb3333
dddbbddb3bdbdbddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8b88bbb888bbb8bbb888b88888b88bbbbbbbbbb333bbb333b33b33bbbbb3333
bbdbbbdb3bdbb33dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbb88888b8bbbbbbbbbbb3b3bbbbbbb33bb3bbbbb3333
bbbbbbbb3b3bbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbbbbb3bbbb3b333b3333
bbbbbbbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bb3333b3333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bbbb3bbb3bb3333b3333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333b3b3bb3bb3333bb333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33b3b3bb3bb333333333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333b3333333333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bb33333333
bbbb77b777b7b7bbbbb777b7b7bbbbb7bbb777b777b777b7b7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3b3bbb3333bbb33333333
bbb7bbb7b7b7b7bb7bbbb7b7b7bbbbb7bbbbb7b7bbbbb7bbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3bb33333bb33333333
bbb7bbb777b7b7bbbbb777b777bbbbb777bb77b777bb77bb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3bb3b3333333b33333333
bbb7bbb7bbb7b7bb7bb7bbbbb7bbbbb7b7bbb7bbb7bbb7b7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333333333b33333333
bbbb77b7bbbb77bbbbb777bbb7bb7bb777b777b777b777b7b7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333333bb3333333
bbbbbbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333b333bb3333333
bbbb77bb779777b777b777b777bb77bb77b777b77bbbbbbb77b777b777b777b77bbb77bbbbbb77b777b777b777bbbbb77bbbbbb777b7773777373337b7377733
bbb7bbb7b7b777b7b7b7b7b7bbb7bbb7bbb7bbb7b7bbbbb7bbbb7bb7b7bb7bb7b7b7bbbbbbb7bbbb7bbbb7b7bbbb7bbb7bbbbbb7bbb7b337b73733b737373733
bbb7abb7b7b7b7b777b77bb77bb777b777b77bb7b7bbbbb777bb7bb77bbb7bb7b7b7bbbbbbb777bb7bbb7bb77bbbbbbb7bbbbbb777b77737773777b773377333
bbb77ab7b7b7b7b779b7b7b7bbbbb7bbb7b7bbb7b7bbbbbbb7bb7bb7b7bb7bb7b7b7b7bbbbbbb7bb7bb7bbb7bbbb7bbb7bbbbbbbb7bbb7b7b7b737b73737b733
bbbb77b77bb7b7b79bb7b7b777b77bb77bb777b777bbbbb77bbb7bb7b7b777b7b7b777bbbbb77bb777b777b777bbbbb777bb7bb777b777b777b777b7373777b3
b3333333333bbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333b33b3bbbb
b3bb77b7773777b777bbbbb7b7bb77b777b77bbb77bbbbbb77b777b777b777b777b777bb77b7b7b777b777b777bbbbb777b7b7b777bbbbbbbbbbbbbbb3bbbbbb
b3373bb37b3bb7b7bbbbbbb7b7b7bbbb7bb7b7b7bbbbbbb7bbb7b7b7b7bb7bbb7bb7bbb7bbb7b7b7bbb7bbbb7bbb7bb7b7b7b7b7b7bbbbbbbbbbbbbbbbbbbbbb
b3b77733733b7bb77bbbbbb7b7b777bb7bb7b7b7bbbbbbb777b777b77bbb7bbb7bb77bb777b777b77bb77bbb7bbbbbb777b77bb77bbbbbbbbbbbbbbbbbbb3bbb
b3bb37b37337bbb7bbbbbbb7b7bbb7bb7bb7b7b7b7bbbbbbb7b7bbb7b7bb7bbb7bb7bbbbb7b7b7b7bbb7bbbb7bbb7bb7b7b7b7b7b7bbbbbbbbbbbbbbbbbbbbbb
b3377337773777b777bbbbbb77b77bb777b7b7b777bbbbb77bb7bbb7b7b777bb7bb777b77bb7b7b777b777bb7bbbbbb777b7b7b777bbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb

