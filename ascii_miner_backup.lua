-- title:  Ascii Miner
-- author: LegoDinoMan, abcq2, Bear Thorne 
-- desc:   Mining in an ASCII world.
-- script: Lua



items={
  necklace=241;
}

ores={
  diamond=177;
  gold=178;
  redstone=179;
  iron=180;
  jade=181;
  stone=182;
}

-- These are unmineable/interactable
env={
  floor=145;
	unexplored=161;
  water=193;
  bedrock=209;
	staircase=225;
}

-- Player
p=129

inv={} -- Inventory
depth_tracker={}

dir_keys={
  [0]={ 0,-1};
  [1]={ 0, 1};
  [2]={-1, 0};
  [3]={ 1, 0};
}

-- Helpers
ran_num=math.random

-- Map
fow=100 -- Enabled: 100 Disabled: 0

-- Audio
sounds={
  ore=0;
  bedrock=1;
  stone=2;
  staircase=3;
	footstep=4;
	selection=5;
}

-- Audio booleans
ore_find_enbl=true -- Ore find enabled
entry_deny_enbl=true
block_break_enbl=true
block_place_enbl=true
staircase_enbl=true
footstep_enbl=true

-- Setting Variables
vw_d=1 -- View distance
fow_enbl=true -- Fog of war
visible_ores=true -- TODO: Bit buggy

-- Used to add entites to the inv
function add(initial_value,add_value)
  local sum=initial_value[add_value] or 0 
  initial_value[add_value]=sum+1
end

function ran_pos()
		-- TODO: Find out why this map size is important
		-- TODO: Can it be smaller/bigger
  return ran_num(0,1238), ran_num(0,1134)
end

function gen_ore(ore_type,min,max,total)
  for num=1,total do
				local x=ran_pos()
				local y=ran_pos()
    local x_offset=0
				
				if ran_num()<0.5 then 
	  			x_offset=-1
				else -- ran_num()>0.5 
	  			x_offset=1
				end
	
				for i=1,ran_num(min,max) do
						-- -16 Ores are invisible
      -- +16 Ores are visible
      if visible_ores then 
      		mset(x,y,ore_type)
      else
      		mset(x,y,ore_type-fow)
						end
						
						if ran_num()<0.5 then 
		   		 x=x+x_offset
	  			else 
								y=y+1
	  			end
				end
  end
end

function gen_env(env_type,min,max,total)
  for num=1,total do
				local x=ran_pos()
				local y=ran_pos()
    local x_offset=0
				
				if ran_num()<0.5 then 
	  			x_offset=-1
				else -- ran_num()>0.5 
	  			x_offset=1
				end
	
				for i=1,ran_num(min,max) do
      mset(x,y,env_type)
						if ran_num()<0.5 then 
		   		 x=x+x_offset
	  			else 
								y=y+1
	  			end
				end
  end
end

function gen_items(item_type,min,max,total)
  for num=1,total do
				local x=ran_pos()
				local y=ran_pos()
    local x_offset=0
				
				if ran_num()<0.5 then 
	  			x_offset=-1
				else -- ran_num()>0.5 
	  			x_offset=1
				end
	
				for i=1,ran_num(min,max) do
      mset(x,y,item_type)
						if ran_num()<0.5 then 
		   		 x=x+x_offset
	  			else 
								y=y+1
	  			end
				end
  end
end

-- TODO: Bug causing p to not gen or maybe
-- gen in a bedrock vein / out of bounds
function gen_map()
		-- Fill the entire map with stone
  for x=0,1238 do
    for y=0,1134 do
	  			-- Subtract fog of war to simulate darkness
						-- For a lil fun set this to ores.diamond
						mset(x,y,ores.stone-fow)
				end 
  end

		-- gen the veins of ore
 	gen_ore(ores.iron,8,24,20)
  gen_ore(ores.redstone,12,32,30)
  gen_ore(ores.jade,12,32,30)
  gen_ore(ores.gold,4,8,10)
  gen_ore(ores.diamond,2,4,10)
  
  -- gen the enval aspects
  gen_env(env.bedrock,20,30,50)
  gen_env(env.staircase,1,1,150)
  
  -- gen items
  gen_items(items.necklace,1,1,10)

		-- Add an unmineable border to the world
  for x=0,1238+1 do
	 		mset(x,0,env.bedrock)
				mset(x,1134+1,env.bedrock) 
  end
  
  for y=0,1134+1 do
	 		mset(0,y,env.bedrock)
	 		mset(1238+1,y,env.bedrock) 
  end
		
		-- TODO: Why do we set the x/y to a rnd pos?  
		x=ran_pos()
		y=ran_pos()
		-- Starting block
  mset(x,y,env.floor)
		-- TODO: Why do we pass 0,0?
		--  p hasn't moved yet
  p_mv(0,0)
end

function p_mv (dir_x,dir_y)
  local n_x=x+dir_x
  local n_y=y+dir_y
  local tgt_ent=mget(n_x,n_y)
  
  if tgt_ent==env.bedrock or tgt_ent==0 then
    mv_spd=16
    if entry_deny_enbl then
    		sfx(sounds.bedrock)
    end
    return
  elseif tgt_ent==env.floor then
    mv_spd=8
    if footstep_enbl then
    		sfx(sounds.footstep)
    end
  else
  		-- Add the mined blocks to the inv
    if tgt_ent~=env.staircase then
    		add(inv,tgt_ent)
    else -- Add staircases to the depth tracker 
    		add(depth_tracker,tgt_ent)
				end
				
    if tgt_ent==ores.stone then
	  			mv_spd=16
						if block_break_enbl then
								sfx(sounds.stone)
 					end   
    elseif tgt_ent==env.staircase then
 	  		if staircase_enbl then
      		sfx(sounds.staircase)
	  			end
						return gen_map() -- Simulate going down deeper
    elseif tgt_ent==items.necklace then
	  			mv_spd=60
      if staircase_enbl then
      		sfx(sounds.staircase)
      end
    else
 	  		mv_spd=12
						if ore_find_enbl then
								sfx(sounds.ore)
						end
    end
  end
  
  -- Set old pos to floor ent
  mset(x,y,env.floor)
  -- Update p pos to n poss
  x=n_x 
  y=n_y
  
  -- Look around the p
  for x=x-vw_d,x+vw_d do
				for y=y-vw_d,y+vw_d do
	  			local tgt_ent=mget(x,y)
						-- Remv fog of war from blocks surrounding p
						if tgt_ent<fow then
								mset(x,y,tgt_ent+fow); 
	  			end
				end
  end
		
	-- Render player
  mset(x,y,p)
end

function init()
  if fow_enbl then
  		fow=100
  else
  		fow=0
  end
  
	-- Initial map generation
	gen_map()
end

init()

function TIC()
	local dir_x
	local dir_y
	local hud_y=128

	for i,dir in pairs(dir_keys) do
		if btn(i) then
			dir_x=dir[1]
			dir_y=dir[2]
		end
	end

	if mv_spd > 0 then 
		mv_spd=mv_spd-1;
	elseif dir_x then
	  p_mv(dir_x,dir_y)
	end

	-- Render the background
	for background_x=0,30 do
	  for background_y=0,17 do
	  	spr(env.unexplored,(background_x*8)-(x%8),(background_y*8)-(y%8))
		end
	end

	map(x-15,y-8,30,17,0,0,0)

	-- Render the inventory
	for blocks,count in pairs(inv) do
	  spr(blocks,2,hud_y)
		print(count,12,hud_y+2,15)
		hud_y=hud_y-10
	end

	-- Render the depth_tracker
	for depth_lvl,count in pairs(depth_tracker) do
	  spr(depth_lvl,2,0)
		print(count,12,2,15)
  end
end