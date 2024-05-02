pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
 -- crate a table for
 -- particles
 bits={}
 del_bits={}
 particles={}
 stars={}
 starcols={6,7,10,15}
 
	for i=0,80 do
		newstar()
	end
 
 cols={"red","green","blue","yellow"}
 blink=3
 
 
 cyuan={}
 add(cyuan,{0,1,1,1,1,1,0,0})
 add(cyuan,{0,0,0,0,0,0,0,0})
 add(cyuan,{1,1,1,1,1,1,1,0})
 add(cyuan,{0,0,1,0,1,0,0,0})
 add(cyuan,{0,0,1,0,1,0,0,0})
 add(cyuan,{0,1,0,0,1,0,1,0})
 add(cyuan,{1,0,0,0,1,1,1,0})
 add(cyuan,{0,0,0,0,0,0,0,0})
 cyuans={}
 cyuans.x=9
 cyuans.y=128
 cyuans.sx=0
 cyuans.sy=1.2
 cyuans.ey=45
 
 cxiao={}
 add(cxiao,{1,1,1,1,1,1,1,0})
 add(cxiao,{1,0,0,1,0,0,1,0})
 add(cxiao,{0,1,0,1,0,1,0,0})
 add(cxiao,{0,1,1,1,1,1,0,0})
 add(cxiao,{0,1,0,0,0,1,0,0})
 add(cxiao,{0,1,0,0,0,1,0,0})
 add(cxiao,{1,1,0,0,1,1,0,0})
 add(cxiao,{0,0,0,0,0,0,0,0})
	cxiaos={}
 cxiaos.x=28
 cxiaos.y=140
 cxiaos.sx=0
 cxiaos.sy=1.2
 cxiaos.ey=57
 
 cjie={}
 add(cjie,{0,0,1,0,0,1,0,0})
 add(cjie,{1,1,1,1,1,1,1,0})
 add(cjie,{0,0,1,0,0,1,0,0})
 add(cjie,{0,1,1,1,1,1,1,0})
 add(cjie,{0,0,0,1,0,0,1,0})
 add(cjie,{0,0,0,1,0,0,1,0})
 add(cjie,{0,0,0,1,0,0,0,0})
 add(cjie,{0,0,0,0,0,0,0,0})
	cjies={}
 cjies.x=48
 cjies.y=130
 cjies.sx=0
 cjies.sy=1.2
 cjies.ey=47
 
 ckuai={}
 add(ckuai,{0,1,0,0,1,0,0,0})
 add(ckuai,{0,1,0,1,1,1,1,0})
 add(ckuai,{1,1,0,0,1,0,1,0})
 add(ckuai,{1,1,1,1,1,1,1,0})
 add(ckuai,{0,1,0,0,1,0,0,0})
 add(ckuai,{0,1,0,1,0,1,0,0})
 add(ckuai,{0,1,1,0,0,0,1,0})
 add(ckuai,{0,0,0,0,0,0,0,0})
	ckuais={}
 ckuais.x=70
 ckuais.y=125
 ckuais.sx=0
 ckuais.sy=1.2
 ckuais.ey=42
 
 cle={}
 add(cle,{0,0,1,1,1,1,0,0})
 add(cle,{0,1,0,0,0,0,0,0})
 add(cle,{0,1,0,1,0,0,0,0})
 add(cle,{1,1,1,1,1,1,1,0})
 add(cle,{0,0,0,1,0,0,0,0})
 add(cle,{0,1,0,1,0,1,0,0})
 add(cle,{1,0,1,1,0,0,1,0})
 add(cle,{0,0,0,0,0,0,0,0})
	cles={}
 cles.x=93
 cles.y=128
 cles.sx=0
 cles.sy=1.2
 cles.ey=45
 
 counter=0
end

function _update()
	
 if rnd()<0.2 then
		newbit()
		sfx(1)
	end
	
	update_particles()
	counter+=1
	if counter%9==0 then
		rndx=flr((0.5-rnd())*2)
	end
	if counter%11==0 then
		rndy=flr((0.5-rnd())*2)
	end
end

function _draw()
 cls()
 draw_bg()
 draw_stars()
 draw_bits()
 draw_particles()
 
--	drawc(cyuan,cyuans.x,cyuans.y,14,3)
--	drawc(cyuan,cyuans.x-1,cyuans.y-1,7,3)
--	if cyuans.y>cyuans.ey then
--	 cyuans.y-=flr(cyuans.sy)
--	end
--	
--	drawc(cxiao,cxiaos.x,cxiaos.y,14,3)
--	drawc(cxiao,cxiaos.x-1,cxiaos.y-1,7,3)
--	if cxiaos.y>cxiaos.ey then
--	 cxiaos.y-=flr(cxiaos.sy)
--	end
--	
--	drawc(cjie,cjies.x,cjies.y,14,3)
--	drawc(cjie,cjies.x-1,cjies.y-1,7,3)
--	if cjies.y>cjies.ey then
--		cjies.y-=flr(cjies.sy)
--	end
--	
--	drawc(ckuai,ckuais.x,ckuais.y,14,3)
--	drawc(ckuai,ckuais.x-1,ckuais.y-1,9,3)
--	if ckuais.y>ckuais.ey then
--		ckuais.y-=flr(ckuais.sy)
--	end
--	
--	drawc(cle,cles.x,cles.y,14,3)
--	drawc(cle,cles.x-1,cles.y-1,10,3)
--	if cles.y>cles.ey then
--		cles.y-=flr(cles.sy)
--	end
end









-->8
--update

function c_yuan(col)
	
end

function newstar()
	local s={}
	s.x=flr(rnd(128))
	s.y=flr(rnd(128))
	s.flash=rndflashlife()
	s.col=rndstarcol()
 add(stars,s)
end

function rndstarcol()
	return starcols[flr(rnd(4)+1)]
end

function rndflashlife()
	return 10+flr(rnd(20))
end

function newbit()
	local b={}
	b.x=flr(rnd(128))
	b.y=127
	b.xa=-1+rnd(2)
	b.ya=-2-rnd()
	b.age=240+(0.5-rnd(1))*180
	b.col=cols[flr(rnd(4))+1]
	b.pure=flr(rnd(2))
	add(bits,b)
end

function boom(_x,_y,_c,_p)
	local n=80+flr((0.5-rnd()))
 for i=0,n do
 	spawn_particles(_x,_y,_c,_p)
 end
 sfx(0)
 blink=3
end

function spawn_particles(_x,_y,_c,_p)
	local p={}
	local angle=rnd()
	local speed=rnd(2)*0.6
	p.x=_x
	p.y=_y
	p.col=_c
	p.pure=_p
	p.sx=sin(angle)*speed
	p.sy=cos(angle)*speed
	p.age=flr(rnd(25))
	add(particles,p)
end

function update_particles()
	for p in all(particles) do
		if p.age>50
			or p.y>128
			or p.y<0
			or p.x>128
			or p.y<0 then
			del(particles,p)
		else
			--move
			p.x+=p.sx
			p.y+=p.sy
			p.age+=1
			p.sy+=0.025
		end
	end
end


-->8
--draw

function draw_bg()
	sspr(0,0,128,32,0,0,128,32)
	sspr(0,32,128,32,0,32,128,32)
 
 if blink>0 then
 	pal(5,6)
 	blink-=1
 end
	
	sspr(0,64,128,32,0,64,128,32)
	sspr(0,96,128,32,0,96,128,32)
	pal()
end

function draw_stars()
	for s in all(stars) do
		pset(s.x,s.y,s.col)
		s.flash-=1
		if s.flash<0 then
			s.flash=rndflashlife()
			s.col=rndstarcol()
		end
	end
end

function draw_bits()
	for b in all(bits) do
		local c1=8
		local c2=9
		local c3=10
		if b.type==1 then
			c1=12
			c2=14
			c3=10
		end
 	circfill(b.x,b.y,1,c1)
 	pset(b.x,b.y+1,c2)
 	pset(b.x,b.y+flr(rnd(2))+2,c3)
 	b.age-=3
 	b.x+=b.xa*0.2
 	b.y+=b.ya*2
 	b.ya+=.037
 	if b.y<=48-rnd(48) then
 		del(bits,b)
 		boom(b.x,b.y,b.col,b.pure)
 	end
 end
end

function draw_particles() 
	local col=8
 local col1=8
 local col2=9
 local col3=10
 local col4=7
 
 for p in all(particles) do
 	if p.col=="red" then
 		if p.pure==0 then
 			col1=8
 			col2=8
 			col3=14
 			col4=6
 		else
 			col1=8
 			col2=14
 			col3=7
 			col4=6
 		end
 	elseif p.col=="green" then
 		if p.pure==0 then
 			col1=11
 			col2=11
 			col3=11
 			col4=6
 		else
 		 col1=11
 		 col2=14
 		 col3=8
 		 col4=6
 		end
 	elseif p.col=="blue" then
 		if p.pure==0 then
 			col1=12
 			col2=12
 			col3=12
 			col4=6
 		else
 			col1=12
 			col2=13
 			col3=8
 			col4=6
 		end
 	else
 		if p.pure==0 then
 			col1=10
 			col2=10
 			col3=10
 			col4=8
 		else
 			col1=8
 			col2=9
 			col3=10
 			col4=7
 		end
 	end
 
  if p.age > 60 then col=col1
  elseif p.age > 40 then col=col2
  elseif p.age > 20 then col=col3  
  else col=col4 end
 
  line(p.x,p.y,p.x+p.sx,p.y+p.sy,col)

 end
end

function drawc(_c,_x,_y,_col,_s)
	for i=1,8 do
		for j=1,8 do
			if _c[i][j]==1 then
			 local lt={}
			 lt.x=_x+(j-1)*_s
			 lt.y=_y+(i-1)*_s
			 local rb={}
			 rb.x=lt.x+_s-1
			 rb.y=lt.y+_s-1
				rectfill(lt.x,lt.y,rb.x,rb.y,_col)
			end
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
10001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
01110111011101110111011101110111011101110111011101110111011101110111011101110111011101110111011101110111011101110111011101110111
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
11011101110111011101110111011101110111011101110111011101110111011101110111011101110111011101110111011101110111011101110111011101
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d1
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d
d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111d111
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d
d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d
d1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1dd
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d151d1d1d1d1d1d1d1d1d1d1d
ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1ddd1d551
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55551
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5555511111
5ddddddddddd5555ddddd555ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd55555ddddd55555111111dd53
15555dd555551111555551115555dd55dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5551ddd155555111111ddd111111
111115511111111111111111111155115dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5555511116dddddddddddd51111111111
11111111555111111111111111111111155555ddddddddddddddddddddddddddddddddddddddddddddddddddddd555511113ddd33dddd5111111111111111555
11111111111115555511dd511111111111111155ddddddddddd5dddddddddd5dddddddddddddddddddddd5555551111113ddd313311111111111111111111111
111111111111111111111dd111111111111111111555dddddd545dddddddd545dddddddddddddddddd555511111111111ddd1111111111111111111111111111
1111111111111111111133dd51111111111111111111555dd56445d5555554445dddddd5dddddd55553311111113dddddd511111111111111111111111111111
111111111111111111111111dd5511111111111111111115d56444544444444465dd5551555555511111115ddddd551111111111111111111111151111511111
111111111111111115111111115dd55d5dd511111111111156444444444444446f55131111111111555555111111111111111111111111551151151111111111
1111111011111111155d11111111111111111555dd531111664e444442244444461133111133dd55111111111111111551111111115555111111151110101111
011111101110001155151111111111111111151111533111644e444444444444461111155dd311111111111111111156d5551111155111110111010011551111
1111011111100011511d1111111111111111111511111111f444445424422254447113d1151111d5dd5111111111111dd11111111d1111110dd6110001665111
101d100000111115115d1111111111111111101111115511f44444554224222544f11511111511d51111111111111115111111111d1155111555000011665110
105650101001115551110111111115111111155515115511d44444422242252244f1d65111156d611111d1111115111d11011111151555111115100011111111
015651155551511515111111111113351111576615111d51d6444424444222444f11dd651157dd61111111111111511111111111151555111111100011111111
11051006fdfd515115110111111110001111576d15111dd11df44424224444444d11d15777750d6111111111111111111111111105566d51111110001111111d
11111116767d1151500110100115155111111555151115d11df4444244444444d111d00d66d01d611111010111111515551555551556dd111111100010111151
10111116767d511111111010015667d011111011151111d5115f444242222444d116100066000061111111111111555555555555551511111ddd110011115111
1111111dddd551151511111101576760111105111511115d1115f4555552224d611d0000dd00006111d111111111111111111111115111111d66110010101111
10111111111111555d556dd1015767601111011115111115d310d0010001001551150005dd10005d1d5111111111110111111111111111111555010011115111
55111111111d1151111555d1015d5dd11156651115111111d11d65500000015d6561000ddd500017dd111ddd1111115111111111111111111115100010115155
1551110115555555555111110111111011d7751555111111155ff4455552244f711101ddddd50057d111166611155ddd55100000011111111111100011115566
111510115111111111101111d111111111155155d551111111dff4444444444ef616dddddddddd67d1111dd51115d7ff65011111011ddd111111110001105577
111511551111111115d111116011111111111111111d111111ff442222244444e711ddddddd6d666d11111111115d7ff651110110116661111111100111055ff
101101111111111155511111611111111111111111155111157f442222222244df116ddddddddd66511111111115d766651111111115d5111111110001115566
111511111111111511d11111d1111115ddddddddd51155111dff444224244244efdd1111111115d51111111111155dddd5111111011111111111111111111110
5d15101111100015555155115111111d111111111d1111d516f444422442224444d51ddddddd6776111111111515115115111101155555551555111111111511
67551010000000011111115d1dd115115511111111d1111557f4444225222244446ddddddddd677611111111111511555505dd01511111111111111111111111
6d5d110055510001111111115115511ddd111111111511115ff444424454424444d6d116dddd6777515dd1111115111115167615111111111111111111111111
d5551011fff500011111111115111156665111111111d1116f4444442544444444d5001dd6dd6767615d111115dd5555151d7111111111111111111111111111
33dd110164f500111111111111111555555101111111111dff4444442445444444510000056d66777d11111155111111550d6151111111111111111111111101
115d55116d65011100000010011155115155000010011115ff444442225524444410000001d6dd677511111d5111111110d11111555555555555151111111111
11115d11ddd5100511152111111155555155111101111156fe4444222222222444000000001dd6677711115111111111011511555ff67d515dd55511111155d5
11111155d5511101105665011111551111111010111111dff444422222222224440000000005dd6777111511111111111011511557f67d55567d55111111d56d
1111111551d50011115dd5111111511515511011100155fff444222222222224440000000011dd6677d11111110011111111111557767d515f7555111111516d
1111111111551155d5d66511111151566665011515111dff4444224222222224421000000000dd666775111111111111111111555dd5d51556f5551111101155
001111111111115d335ddd511111511dd5610dd6d7d116f44444224222422222221000000011ddd66777111115551111111115d5555555155d65550111111111
0001111011111111131155151111511555510ddfd7511664444444422444222225000000001dddd6677611115666501111115d51111155155115111111111111
000111111111111111115515115dd111111105555d111d6444442222444422222215511115dddddd66761151166f51155511d511111111115111111111111111
000011000111111111111111111dd1111111010011111df44444224444442222211dddddddddddddd67711115667111d6dd5d111111111115511111111111111
0000000000011111111111111111555111111111111115f442242244444422222115dddd66dddddd666601111555111dddd5d111111111111111511111111111
0000000000000001111111111111151111111155155d50dd5222555244222252211515dddddddddddd6d1d515551510115511111111111111511500000000000
fffffffffffffff77777677677777776666f77777766676d52225552222222511100015ddddddddd6676776767777ff7677767777777777767777777ffffffff
eee4444444eeeee4444444444fe44ee444444444d46d442e22222222222222111100001155d11ddd5dd154d4ddddd44444444ee4e44ed4ddd44d4edeeee44444
eee444444eeeee44e444444f44eef44ee4994e444f44442222111122222221110000000151111d15550544444fee4494eeeee994e44ee44e444eeeeeee444499
4444444444444444444444444444444e444444444e4444420000002424422010000000001010151100124444444444444444444444444444444ee44444444444
4444444444444ee44444444444e4444444444444444444445110005224440000011110000010111112244444444444444444444444444444444444444444444e
222255555222225222225552222222222222552222222225511000d2444e00001111111110001111115522222222222255522222225522222222222222222225
22555555555555555555555555555555555555555555555555555052424411555555555551000115555552255555552555555225555555555555555555555555
11111111111111111111111111111111111111111111111101111055244e50011111111110001101111111111111111111111111111111111111111111111111
221111111221111111111121222211121222111111111111221110052224d0151111111110000001111122211111112211122221111111221111211111111111
222222222222222222222222222222222222222222222222222551015244e5101155111100000011222222222222222222222222222222222222222222222222
2225552222222255552222222255552222222222225222222225511055224f225555100000000011522222255555522222222222555552222222255555222222
00000000000000000000000000000000000000000000001000000010155244e45055000000000000000000000000000100001000000000100000000000010000
000000010001000000010011000000000011011000000010111110100154424eed4ed01000000000010011000000000110011000000000100001000000010001
000000111111000000011115100000000111111000000011111111100055544444eedd0011000000011115100000000511111000000000111111000000011111
00000015111500000002222210000000015112200000002111111150000555544242420511000000022115100000000511121000000000121211000000151222
0000001511250000000222221000000001512220000000221111115000000555542d222115000000022115100000000511221000000000121221000000151222
00000015111500000005222210000000005122500000005211111150000000055552002115000000052115100000000511251000000000121225000000151222
00000015111500000005222510000000005121500000005511121150000000000005111115000000051115000000000511151000000000151211000000151122
00000015111500000005222510000000005521500000005111121150000000000005111115000000051515000000000511151000000000151111000000151122
__sfx__
00010000316203162031620316203162031620316203162031620316201b6201b6201b6201b6201b6201b6201b6201b6201b6201b6201b6200a6200a6200a6200a6200a6200a6200a6200a6200a6200a6200a620
00030000260112601127011270112701127011270112701126011260112601126011250112401124011240112301123011220112201121011200111f0111f0111e0111d0111c0111b0111b0111a0111901118011
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002d15023150000002d1502d150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
