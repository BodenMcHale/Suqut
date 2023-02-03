-- title:  MINE
-- author: abcq2
-- desc:   No goal. Just dig.
-- script: lua

rnd = math.random

visible = 48

tile = {
 stone = 80;
	iron = 81;
	coal = 82;
	redstone = 83;
	gold = 84;
	diamond = 85;
	floor = 86;
	player = 87;
	brick = 88;
	stairs = 89;
	yendor = 90;
}

function randpos()
 return rnd(M8), rnd(1,134)
end

function inc (t,k)
 local v = t[k] or 0
	t[k] = v+1
end

function vein (tile, min, max, count)
 for n = 1,count do
	 local h = 1
		if rnd() < 1/2 then h = -1; end
	 local x,y = randpos()
		for t = 1,rnd(min,max) do
 		mset(x,y,tile - visible)
		 if rnd() < 1/2 then x = x+h;
			else y = y+1; end
		end
	end
end

function mapgen()
	for x = 1,238 do
	 for y = 1,134 do
		 mset(x,y,tile.stone - visible);
	end end
	vein(tile.iron, 8, 24, 20)
	vein(tile.redstone, 12, 32, 30)
 vein(tile.coal, 12, 32, 30)
 vein(tile.gold, 4, 8, 10)
 vein(tile.brick, 20, 30, 50)
 vein(tile.diamond, 2, 4, 10)
	vein(tile.stairs, 1, 1, 5)
	vein(tile.yendor, 0, 1, 5)
	for x = 0,239 do
	 mset(x,  0,tile.brick - visible);
	 mset(x,135,tile.brick - visible); end
	for y = 0,135 do
	 mset(0,  y,tile.brick - visible);
	 mset(239,y,tile.brick - visible); end
 x,y = randpos()
	mset(x,y,tile.floor)
	move(0,0)
 mv = 60
end

snd = {
 clink = 0;
	brick = 1;
	rock  = 2;
	note  = 3;
	advance = 4;
	--rock = 2, step  = 3;
}

bag={}

function move (dx,dy)
 local nx = x+dx
	local ny = y+dy
	local t = mget(nx,ny)
	if t == tile.brick
	or t == 0 then
	 mv = 16
	 sfx(snd.brick)
		return
	elseif t == tile.floor then
		mv = 8
	else
		inc(bag,t)
	 if t == tile.stone then
   -- note()
			sfx(snd.rock)
			mv = 16
		elseif t == tile.stairs then
 		sfx(snd.advance)
	 	return mapgen()
		elseif t == tile.yendor then
 		sfx(snd.advance)
		 mv = 60
	 else -- shiny
 	 sfx(snd.clink)
			mv = 12
		end
	end
	mset(x,y,tile.floor)
 x=nx; y=ny
	for x = x-1,x+1 do
	 for y = y-1,y+1 do
		 local t = mget(x,y)
			if t < visible then
			 mset(x,y,t+visible); end
		end
	end
	mset(x,y,tile.player)
end

mapgen()

keys = {
 [0] = { 0,-1};
	[1] = { 0, 1};
	[2] = {-1, 0};
	[3] = { 1, 0};
}

function TIC()
	local dx,dy
 for i,d in pairs(keys) do
	 if btn(i) then
		 dx = d[1]
			dy = d[2]
		end
	end

 if mv > 0 then mv = mv-1;
	elseif dx
	--and btnp(4)
	then
	 move(dx,dy)
	end
	
 for bx = 0,30 do
	 for by = 0,30 do
		 spr(16, (bx*8)-(x%8), (by*8)-(y%8))
		end
	end
	map(x-15, y-8, 30,17, 0,0,0)
	local hy = 0
	for tile,count in pairs(bag) do
	 spr(tile, 0, hy)
		print(count,10, hy+2, 0)
		print(count, 9, hy+1,15)
		hy = hy+8
	end
end
