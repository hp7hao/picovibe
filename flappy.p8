pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	--tweak
	gravity=2
	flap_amt=9
	
	--init vars
	p1={}
	p1.x=20
	p1.y=20
	flap=0
	
	score=0
	
	col=false
	
	state="game"
	
	init_pipes()
end

function _update()
	if state=="game" then
		update_game()
	elseif state=="gameover" then
		update_gameover()
	end
end

function update_game()
	p1.y=p1.y+gravity
	
	if btnp(❎) then
		flap=flap_amt
	end
	
	if flap>0 then
		flap=flap-1
	end
	
	p1.y=p1.y-flap
	
	if p1.y>=120 then
		p1.y=120
	elseif p1.y<=0 then
		p1.y=0
	end
	
	update_pipes()
	update_score()
	collide()
	if col then
		state="gameover"
	end
end

function update_gameover()
	if btn(❎) then
		state="game"
		_init()
	end
end

function _draw()
	if state=="game" then
		draw_game()
	elseif state=="gameover" then
		print("gameover",50,50)
	end
end

function draw_game()
	cls()
	map()
 draw_pipes()
 
 spr(1,p1.x,p1.y)
 
 print("score: "..score)
 print(col)
end


-->8
--pipes--

function init_pipes()
 gap=30
	p1bx=70
	p1by=rndby()
	
	p2bx=p1bx+72
	p2by=rndby()
end

function update_pipes()
 p1bx-=1
 if p1bx<-16 then
 	p1bx=128
 	p1by=rndby()
 end
 
 p2bx-=1
 if p2bx<-16 then
 	p2bx=128
 	p2by=rndby()
 end
end

function draw_pipes()
 spr(8,p1bx,p1by,2,16)
 spr(8,p1bx,p1by-128-gap,2,16)
 
 spr(8,p2bx,p2by,2,16)
 spr(8,p2bx,p2by-128-gap,2,16)
end

function rndby()
	return 8+gap+rnd(128-2*(8+gap))
end
-->8
--score/collide--
function update_score()
 if p1bx==p1.x-8 then
 	score+=1
 end
 
 if p2bx==p1.x-8 then
 	score+=1
 end
end

function collide()
	if p1.x>p1bx-4 
		and p1.x<p1bx+12 then
		if p1.y>p1by-6 
			or p1.y<p1by-gap-2 then
			col=true
		else
			col=false
		end
	elseif p1.x>p2bx-4
		and p1.x<p2bx+12 then
		if p1.y>p2by-6 
			or p1.y<p2by-gap-2 then
			col=true
		else
			col=false
		end
	else
		col=false
	end
end
__gfx__
00000000000880000000000000000000000000000000000000000000000000000111111111111110000000000000000000000000000000000000000000000000
0000000000889900000000000000000000000000000000000000000000000000133333bbbbb3b331000000000000000000000000000000000000000000000000
007007000009099a0000000000000000000000000000000000000000000000001333333bbbbb3331000000000000000000000000000000000000000000000000
0007700099fff990000000000000000000000000000000000000000000000000133333bbbbb3b331000000000000000000000000000000000000000000000000
0007700009fff9000000000000000000000000000000000000000000000000001333333bbbbb3331000000000000000000000000000000000000000000000000
00700700009ff900000000000000000000000000000000000000000000000000133333bbbbb3b331000000000000000000000000000000000000000000000000
00000000000ff0000000000000000000000000000000000000000000000000001333333bbbbb3331000000000000000000000000000000000000000000000000
000000000000f0000000000000000000000000000000000000000000000000000111111111111110000000000000000000000000000000000000000000000000
cccccccccccccccc000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
cccccccccccccccc000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
cccccccccccccccc000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
ccccccccccc77ccc000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
cccccccccc7777cc000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
ccccccccc777777c000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
cccccccc77777777000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
cccccccccccccccc000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc13333bbb3331cc000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000cc1333bbb3b331cc000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000111111111111110000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000133333bbbbb3b331000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001333333bbbbb3331000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000133333bbbbb3b331000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001333333bbbbb3331000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000133333bbbbb3b331000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001333333bbbbb3331000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000111111111111110000000000000000000000000000000000000000000000000
__map__
1010101010101010101010111010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101110101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010111010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010111010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101110101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010111010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101110101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101110101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101110101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
