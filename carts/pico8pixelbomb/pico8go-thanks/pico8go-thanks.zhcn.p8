pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--pico8go thanks
--by randc0degen & icegeek
-- support lowercase only

#include ../../../libs/pico8/i18n.lua
#include ./pico8go-thanks.texts.zhcn.lua

csts={
 -- scene box
 lft=-64,
 rgt=64,
 top=-64,
 btm=64,
 dep=256,
 zmod=64, -- z mod (recurrent)
 frmd=32, -- frame distance
 camd=50, -- camera distance
 fov=0.25,
 vbul=16, -- bullet speed
 frmlp=128, -- frame loop

 -- projection
 cx=64,
 cy=64,
 
 dx={-1,-0.707,0,0.707,1,0.707,0,-0.707},
 dy={0,-0.707,-1,-0.707,0,0.707,1,0.707},
 -- lr/ud  0    1(u) 2(d)
 -- 0      0    3    7
 -- 1(l)   1    2    8
 -- 2(r)   5    4    6
 dirmap={0,3,7,1,2,8,5,4,6},

 t_stg_menu=1,
 t_stg_game=2,

 t_bul=1,
}

glbs={
 -- game state
 stg=csts.t_stg_game,
 spd=3, -- ship speed
 acc=3, -- ship acceleration
 drg=3, -- ship drag
 vmax=6, -- ship max speed
 firert=2, -- fire rate
 zshift=0,
 frm=0, -- frame count 0-127
 -- end game state

 -- game control
 lr=0,
 ud=0,
 btna=false,
 btnb=false,
 -- end game control

 cam={},

 -- game objects
 objs={},
 ship={},
 firecd=0,
 -- end game objects

 -- text
 tx=64,
 ty=1,
 lh=9, -- line height
 -- end text
}

-- math
function proj(x,y,z,s)
 fov=glbs.cam.fov
 cx=glbs.cam.x
 cy=glbs.cam.y
 cz=glbs.cam.z -- camz
 sx=-csts.cx/sin(fov/2)*cos(fov/2)/cz
 zz=1/(z+cz)
 xx=(x-cx)*cz*zz*sx+csts.cx
 yy=(y-cy)*cz*zz*sx+csts.cy
 ss=s*cz*zz*sx
 return xx,yy,ss
end

function clip(x,a,b)
 return x<a and a or x>b and b or x
end

-- clip |<x,y>| to v
function clipv(x,y,v)
 d=sqrt(x*x+y*y)
 if d>v then
  r=v/d
  x*=r
  y*=r
 end
 return x,y
end

function decl(v,d)
 s=sgn(v)
 v=s*max(0,abs(v)-d)
 return v
end

function curve(x,y,z)
 zz=z/csts.dep
 zz=zz*zz
 return x*zz,y*zz
end

-- management

function fire(x,y,vx,vy)
 add(glbs.objs,{typ=csts.t_bul,x=x,y=y,z=0,vx=vx,vy=vy,frame=0})
end

--------
-- inits
--------
function init_game()
 glbs.ship={
  x=0,y=0,z=0,
  vx=0,vy=0,
 }
 glbs.frm=0
 glbs.zshift=0
 glbs.firecd=0
 glbs.cam={x=0,y=0,z=csts.camd,fov=csts.fov}
end






----------
-- updates
----------
function ctrl_glb()
 glbs.lr=btn(⬅️) and 1 or btn(➡️) and 2 or 0
 glbs.ud=btn(⬆️) and 1 or btn(⬇️) and 2 or 0
 glbs.btna=btn(🅾️)
 glbs.btnb=btn(❎)
end

-- in-game control
function ctrl_game()
 lr=glbs.lr
 ud=glbs.ud
 fre=glbs.btna
 spc=glbs.btnb

 -- dir control
 d=csts.dirmap[lr*3+ud+1]
 if d>0 then
  glbs.ship.vx+=csts.dx[d]*glbs.acc
  glbs.ship.vy+=csts.dy[d]*glbs.acc
  glbs.ship.vx,glbs.ship.vy=clipv(glbs.ship.vx,glbs.ship.vy,glbs.vmax)
 else
  glbs.ship.vx=decl(glbs.ship.vx,glbs.drg)
  glbs.ship.vy=decl(glbs.ship.vy,glbs.drg)
 end
 glbs.ship.x+=glbs.ship.vx
 glbs.ship.y+=glbs.ship.vy
 glbs.ship.x=clip(glbs.ship.x,csts.lft,csts.rgt)
 glbs.ship.y=clip(glbs.ship.y,csts.top,csts.btm)
 glbs.cam.x=glbs.ship.x/3
 glbs.cam.y=glbs.ship.y/3

 -- fire control
 glbs.firecd-=1
 glbs.firecd=max(0,glbs.firecd)
 sp=glbs.ship
 if fre and glbs.firecd<=0 then
  glbs.firecd=glbs.firert
  fire(sp.x,sp.y,sp.vx,sp.vy)
 end

 -- special control
 -- control code here
end

function ctrl()
 ctrl_glb()
 if (glbs.stg==csts.t_stg_game) then
  ctrl_game()
 end
end

function update_game()
 glbs.frm=(glbs.frm+1)%csts.frmlp
 glbs.zshift+=glbs.spd
 if (glbs.zshift>=csts.zmod) glbs.zshift-=csts.zmod
 -- update bullets
 for obj in all(glbs.objs) do
  if (obj.typ==csts.t_bul) then
   obj.z+=csts.vbul
   obj.x+=obj.vx
   obj.y+=obj.vy
   obj.frame=1-obj.frame
   if (obj.z>=csts.dep) del(glbs.objs,obj)
  end
 end
end

function update()
 if (glbs.stg==csts.t_stg_game) then
  update_game()
 end
end








--------
-- draws
--------
function draw_bg_rect_line(w,h,cx,cy,z,c)
 x1,y1,s=proj(cx-w,cy-h,z,1)
 x2,y2=x1+2*w*s,y1+2*h*s
 rect(x1,y1,x2,y2,c)
end

function draw_bg_rect()
 z=glbs.zshift
 st=csts.frmd-z%csts.frmd
 for i=st,csts.dep*0.75,csts.frmd do
  draw_bg_rect_line(csts.lft,csts.top,0,0,i,3)
  fillp()
 end
 pal()
end

-- x,y,spread
function draw_aim(x,y,s)
 spr(3,x-8-s,y-8-s)
 spr(3,x+s,y-8-s,1,1,true)
 spr(3,x-8-s,y+s,1,1,false,true)
 spr(3,x+s,y+s,1,1,true,true)
end

function draw_ship()
 sp=glbs.ship
 md=glbs.frm%2 -- frame mod2
 -- aim hud
 sprd=(abs(sp.vx)+abs(sp.vy))/glbs.vmax*2

 if md==0 and glbs.btna then
--[[
  zz=(glbs.frm%8)/8
  z=zz*zz*csts.dep
  t=z/csts.vbul
  x,y,s=proj(sp.x+t*sp.vx,sp.y+t*sp.vy,z,1)
  draw_aim(x,y,sprd)
]]
  z=256
  t=z/csts.vbul
  x1,y1,_=proj(sp.x,sp.y,sp.z,1)
  x2,y2,_=proj(sp.x+t*sp.vx,sp.y+t*sp.vy,z,1)
  line(x1,y1,x2,y2,11)
 end
 
 x,y,s=proj(sp.x,sp.y,sp.z,1)
 spr(0,x-8,y-4)
 spr(0,x,y-4,1,1,1)
 -- flame
 dx=(x-csts.cx)/64
 dy=(y-csts.cy)/64
 flm=1+md
 spr(flm,x+dx-6,y+dy-1)
 spr(flm,x+dx-1,y+dy-1)
end

function draw_bul()
 for i=#glbs.objs,1,-1 do
  obj=glbs.objs[i]
  if (obj.typ==csts.t_bul) then
   x,y,s=proj(obj.x,obj.y,obj.z,1)
   if s>0.5 then
    spr(16+obj.frame,x-4,y-4)
   else
    spr(18+obj.frame,x-3,y-3)
   end
  end
 end
end

function draw_txt()
 x=glbs.tx
 y=glbs.ty
 _t("t0",x,y,7);y=y+glbs.lh
 _t("t1",x,y,14);y=y+glbs.lh
 _t("t2",x,y,14);y=y+glbs.lh
 _t("t3",x,y,14);y=y+glbs.lh
 _t("t4",x,y,14);y=y+glbs.lh
 _t("t5",x,y,14);y=y+glbs.lh
 _t("t6",x,y,14);y=y+glbs.lh
end

function draw_game()
 draw_bg_rect()
 draw_bul()
 draw_ship()
 draw_txt()
end

function draw()
 if (glbs.stg==csts.t_stg_game) then
  draw_game()
 end
end

-- system
function _init()
 -- init code here
 init_game()
end

function _update()
 ctrl()
 update()
 -- update code here
end

function _draw()
 cls()
 draw()
 pal()
 --?glbs.frm
 --?stat(1)*100
end
__gfx__
00008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00075000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007500500080000009a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007501c0089800008aaa80000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007665500080000009a90000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
866622150000000000080000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
055525150000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000089800000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0888888000089998008a800000098800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
899aa998008aa980089a980000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
899aa998089aa800008a800008890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880899980000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000089800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000003333333333333333333333333333333333333333333333333333333333333333333333333333333333333333300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000003333333333333333333333333333333333333333333333333333333333333333330000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000003333333333333333333333333333333333333333333333333333000000030000000000000300000000000
00000000003000000000000000003000000003000003000000000000000000000000000000000000000000000000003000000030000000000000300000000000
00000000003000000000000000003000000003000003000000000000000000000000000000000000000000000000003000000030000000000000300000000000
00000000003000000000000000003000000003000003000000000000000000000000000000000000000000000000003000000030000000000000300000000000
00000000003000000000000000003000000003000003003333333333333333333333333333333333333333333300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003000000000000000000000000000000000000000000300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003000000000000000000000000000000000000000000300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003333333333333333333333333333333333333300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000083000008003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000753000005703000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000753055005703000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
000000000030000000000000007531cc105703000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000766555566703000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000866628155182666800003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000055589855898555b00888888003000000000000000000000000000000000000300300003000000030000000000000300000000000
000000000030000000000000000181551810030bbb9aa99803000000000000000000000000000000000000300300003000000030000000000000300000000000
000000000030000000000000000030000000030089bbb98888880000000000000000000000000000000000300300003000000030000000000000300000000000
000000000030000000000000000030000000030008888bbbaa998000000000000000000000000000000000300300003000000030000000000000300000000000
000000000030000000000000000030000000030000030899bbb98a80000000000000000000000000000000300300003000000030000000000000300000000000
000000000030000000000000000030000000030000030088888bbba8a80000000000000000000000000000300300003000000030000000000000300000000000
000000000030000000000000000030000000030000030030030089bbb98000000000000000000000000000300300003000000030000000000000300000000000
000000000030000000000000000030000000030000030030030008a8abb000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003000000000000000000000000000000000000300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003003333333333333333333333333333333333333300300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003000000000000000000000000000000000000000000300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003000000000000000000000000000000000000000000300003000000030000000000000300000000000
00000000003000000000000000003000000003000003003333333333333333333333333333333333333333333300003000000030000000000000300000000000
00000000003000000000000000003000000003000003000000000000000000000000000000000000000000000000003000000030000000000000300000000000
00000000003000000000000000003000000003000003000000000000000000000000000000000000000000000000003000000030000000000000300000000000
00000000003000000000000000003000000003000003000000000000000000000000000000000000000000000000003000000030000000000000300000000000
00000000003000000000000000003000000003000003000000000000000000000000000000000000000000000000003000000030000000000000300000000000
00000000003000000000000000003000000003000003333333333333333333333333333333333333333333333333333000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003000000000000000000000000000000000000000000000000000000000000000030000000000000300000000000
00000000003000000000000000003000000003333333333333333333333333333333333333333333333333333333333333333330000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000
00000000003000000000000000003333333333333333333333333333333333333333333333333333333333333333333333333333333333333333300000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

