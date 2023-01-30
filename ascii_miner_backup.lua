-- title:  Ascii Miner
-- author: LegoDinoMan, abcq2, Bear Thorne 
-- desc:   Mining in an ASCII world.
-- script: Lua

entities={
  player=129;
}

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
environment={
  floor=145;
    unexplored=161;
  water=193;
  bedrock=209;
    staircase=225;
}

-- Player
inventory={}
depth_tracker={}

directional_keys={
  [0]={ 0,-1};
  [1]={ 0, 1};
  [2]={-1, 0};
  [3]={ 1, 0};
}

-- Helpers
random_number=math.random

-- Map
fog_of_war=100 -- Enabled: 100 Disabled: 0

map_width={
    min=0; -- Default: 0
    max=250; -- Default: 238
}

map_height={
    min=0; -- Default: 0
    max=150; -- Default: 134
}

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
ore_find_enabled=true
deny_enabled=true
block_break_enabled=true
block_place_enabled=true
staircase_enabled=true
footstep_enabled=true

-- Setting Variables
view_distance=1
fog_of_war_enabled=true
visible_ores=true -- TODO: Bit buggy

-- Menu Variables
mode="game"
play_button={x=1*8,y=3*8}
settings_button={x=1*8,y=4*8}
credits_button={x=1*8,y=5*8}
quit_button={x=1*8,y=6*8}
menu_selections={play_button,settings_button,credits_button,quit_button}
selected=1
cursor=menu_selections[selected]

-- Used to add entites to the inventory
function add(initial_value,add_value)
  local sum=initial_value[add_value] or 0 
  initial_value[add_value]=sum+1
end

function random_position()
    -- TODO: Find out why this map size is important
    -- TODO: Can it be smaller/bigger
  return random_number(map_width.min,map_width.max), random_number(map_height.min,map_height.max)
end

function generate_ore_vein(ore_type,min,max,total)
  for num=1,total do
        local x=random_position()
        local y=random_position()
    local x_offset=0
        
        if random_number()<0.5 then 
          x_offset=-1
        else -- random_number()>0.5 
          x_offset=1
        end
  
        for i=1,random_number(min,max) do
            -- -16 Ores are invisible
      -- +16 Ores are visible
      if visible_ores then 
          mset(x,y,ore_type)
      else
          mset(x,y,ore_type-fog_of_war)
            end
            
            if random_number()<0.5 then 
           x=x+x_offset
          else 
                y=y+1
          end
        end
  end
end

function generate_environment(environment_type,min,max,total)
  for num=1,total do
        local x=random_position()
        local y=random_position()
    local x_offset=0
        
        if random_number()<0.5 then 
          x_offset=-1
        else -- random_number()>0.5 
          x_offset=1
        end
  
        for i=1,random_number(min,max) do
      mset(x,y,environment_type)
            if random_number()<0.5 then 
           x=x+x_offset
          else 
                y=y+1
          end
        end
  end
end

function generate_items(item_type,min,max,total)
  for num=1,total do
        local x=random_position()
        local y=random_position()
    local x_offset=0
        
        if random_number()<0.5 then 
          x_offset=-1
        else -- random_number()>0.5 
          x_offset=1
        end
  
        for i=1,random_number(min,max) do
      mset(x,y,item_type)
            if random_number()<0.5 then 
           x=x+x_offset
          else 
                y=y+1
          end
        end
  end
end

-- TODO: Bug causing player to not generate or maybe
-- generate in a bedrock vein / out of bounds
function generate_map()
    -- Fill the entire map with stone
  for x=map_width.min,map_width.max do
    for y=map_height.min,map_height.max do
          -- Subtract fog of war to simulate darkness
            -- For a lil fun set this to ores.diamond
            mset(x,y,ores.stone-fog_of_war)
        end 
  end

    -- Generate the veins of ore
  generate_ore_vein(ores.iron,8,24,20)
  generate_ore_vein(ores.redstone,12,32,30)
  generate_ore_vein(ores.jade,12,32,30)
  generate_ore_vein(ores.gold,4,8,10)
  generate_ore_vein(ores.diamond,2,4,10)
  
  -- Generate the environmental aspects
  generate_environment(environment.bedrock,20,30,50)
  generate_environment(environment.staircase,1,1,150)
  
  -- Generate items
  generate_items(items.necklace,1,1,10)

    -- Add an unmineable border to the world
  for x=map_width.min,map_width.max+1 do
      mset(x,map_height.min,environment.bedrock)
        mset(x,map_height.max+1,environment.bedrock) 
  end
  
  for y=map_height.min,map_height.max+1 do
      mset(map_width.min,y,environment.bedrock)
      mset(map_width.max+1,y,environment.bedrock) 
  end
    
    -- TODO: Why do we set the x/y to a rnd pos?  
    x=random_position()
    y=random_position()
    -- Starting block
  mset(x,y,environment.floor)
    -- Player hasn't moved yet
  player_movement(0,0)
end

function player_movement (direction_x,direction_y)
  local new_x=x+direction_x
  local new_y=y+direction_y
  local target_entity=mget(new_x,new_y)
  
  if target_entity==environment.bedrock or target_entity==0 then
    move_speed=16
    if deny_enabled then
        sfx(sounds.bedrock)
    end
    return
  elseif target_entity==environment.floor then
    move_speed=8
    if footstep_enabled then
        sfx(sounds.footstep)
    end
  else
      -- Add the mined blocks to the inventory
    if target_entity~=environment.staircase then
        add(inventory,target_entity)
    else -- Add staircases to the depth tracker 
        add(depth_tracker,target_entity)
        end
        
    if target_entity==ores.stone then
          move_speed=16
            if block_break_enabled then
                sfx(sounds.stone)
          end   
    elseif target_entity==environment.staircase then
        if staircase_enabled then
          sfx(sounds.staircase)
          end
            return generate_map() -- Simulate going down deeper
    elseif target_entity==items.necklace then
          move_speed=60
      if staircase_enabled then
          sfx(sounds.staircase)
      end
    else
        move_speed=12
            if ore_find_enabled then
                sfx(sounds.ore)
            end
    end
  end
  
  -- Set old position to floor entity
  mset(x,y,environment.floor)
  -- Update player position to new positions
  x=new_x 
  y=new_y
  
  -- TODO: Understand this code
  -- Look around the player
  for x=x-view_distance,x+view_distance do
        for y=y-view_distance,y+view_distance do
          local target_entity=mget(x,y)
            -- Remove fog of war from blocks surrounding player
            if target_entity<fog_of_war then
                mset(x,y,target_entity+fog_of_war); 
          end
        end
  end
    
    -- Render player
  mset(x,y,entities.player)
end

function init()
  if fog_of_war_enabled then
      fog_of_war=100
  else
      fog_of_war=0
  end
  
  if mode=="game" then
      -- Initial map generation
      generate_map()
  end
end

init()

function TIC()
    if mode=="menu" then
        cls()
       --map(0,0,30,17)
  
        -- Title of the game
        print("ASCII Miner",1*8,1*8,14)
        -- Menu text
        print("Play",2*8,3*8,15)
        print("Settings",2*8,4*8,15)
        print("Credits",2*8,5*8,15)
        print("Quit",2*8,6*8,15)
        -- Interaction prompt
        print("Press 'A'",2*8,8*8,14)
        
        -- Menu controls
        if btnp(0) and selected>2 then
            selected=selected-1
        end
                
        -- Draw the selection outline
        rectb(cursor.x-2,cursor.y-1,4,4,14)
        
    elseif mode=="settings" then
    
    elseif mode=="credits" then

    elseif mode=="game" then
        local direction_x
      local direction_y
      local hud_y=128
    
      for i,dir in pairs(directional_keys) do
            if btn(i) then
              direction_x=dir[1]
              direction_y=dir[2]
            end
      end
      
      if move_speed > 0 then 
          move_speed=move_speed-1;
      elseif direction_x then
        player_movement(direction_x,direction_y)
      end
      
        -- Render the background
      for background_x=0,30 do
        for background_y=0,17 do
              spr(environment.unexplored,(background_x*8)-(x%8),(background_y*8)-(y%8))
            end
      end
      
      map(x-15,y-8,30,17,0,0,0)
      
      -- Render the inventory
      for blocks,count in pairs(inventory) do
        spr(blocks,2,hud_y)
            print(count,12,hud_y+2,15)
            hud_y=hud_y-10
      end
      
      -- Render the depth_tracker
      for depth_levels,count in pairs(depth_tracker) do
        spr(depth_levels,2,0)
            print(count,12,2,15)
      end
    elseif mode=="game_over" then
    
    end
end