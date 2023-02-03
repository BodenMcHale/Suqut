-- title:  Placement Test
-- author: LegoDinoMan, derpguy125
-- desc:   An example of placing blocks with ASCII visuals
-- script: Lua

-- Controls: Place=A, Break=B, Inventory=X, Interact=Y, Movement=Arrows

-- Developer
version="1.0.0"
updateDate="02-02-2023"
releaseDate="02-02-2023"

-- World
max_x=30
max_y=17

-- Player
player={sprite=256,x=8,y=10}
controls={up=0,down=1,left=2,right=3,a=4,b=5,x=6,y=7}
placement={x=0,y=0} -- Used to determine placement of blocks
camera={x=-7,y=2}
direction=0 -- Direction the player faces
selected_block=0 -- Currently selected block from inventory
inventory_mode=false -- If the inventory is active or not
inventory={}
depth_tracker={}

-- Hud
cursor_y_min=8 -- Minimum Y pos for cursor
cursor_y_max=126 -- Maximum Y pos for cursor
cursor_y=126 -- Y pos of cursor in inventory

-- Used to add entites to the inventory
function add(initial_value,add_value)
  local temp_value=initial_value[add_value] or 0 
  initial_value[add_value]=temp_value+1
end

-- Used to subtract entites to the inventory
function subtract(initial_value,subtract_value)
  local temp_value=initial_value[subtract_value] or 0 
  initial_value[subtract_value]=temp_value-1
end

function player_movement()
  -- Move up
  if btnp(controls.up,6,6) and inventory_mode==false and direction==1 and (mget(player.x,player.y-1)==1 or mget(player.x,player.y-1)==16) then 
    player.y=player.y-1
    camera.y=camera.y-1
    direction=1
    sfx(0)
  elseif btnp(controls.up,6,6) and inventory_mode==false then
    direction=1
    sfx(0)
  end
  
  -- Move down
  if btnp(controls.down,6,6) and inventory_mode==false and direction==0 and (mget(player.x,player.y+1)==1 or mget(player.x,player.y+1)==16) then
    player.y=player.y+1
    camera.y=camera.y+1
    direction=0
    sfx(0)
  elseif btnp(controls.down,6,6) and inventory_mode==false then
    direction=0
    sfx(0)
  end
  
  -- Move left
  if btnp(controls.left,6,6) and inventory_mode==false and direction==2 and (mget(player.x-1,player.y)==1 or mget(player.x-1,player.y)==16) then
    player.x=player.x-1
    camera.x=camera.x-1
    direction=2
    sfx(0)
  elseif btnp(controls.left,6,6) and inventory_mode==false then
    direction=2
      sfx(0)
  end
  
  -- Move right
  if btnp(controls.right,6,6) and inventory_mode==false and direction==3 and (mget(player.x+1,player.y)==1 or mget(player.x+1,player.y)==16) then
    player.x=player.x+1
    camera.x=camera.x+1
    direction=3
    sfx(0)
  elseif btnp(controls.right,6,6) and inventory_mode==false then
    direction=3
    sfx(0)
  end
end

-- Mining and placing blocks
function player_block_manager()
  local new_x=player.x+placement.x
  local new_y=player.y+placement.y
  local target_entity=mget(new_x,new_y)

    if selected_block>16 then
        selected_block=2
    elseif selected_block<2 then
        selected_block=16
    end

    -- Place blocks
    if btnp(controls.a) then
      if inventory[selected_block]~=nil and inventory[selected_block]>0 then            
            if mget(new_x,new_y)==1 then
              -- Remove the block from the inventory
                subtract(inventory,selected_block)
              mset(new_x,new_y,0+selected_block)
                sfx(1)
            -- If it isn't floor, staircase, or black
            elseif mget(new_x,new_y)~=1 and mget(new_x,new_y)~=19 and mget(new_x,new_y)~=0 then
                subtract(inventory,selected_block)
                -- Add the block that you replaced to the inventory
                -- Add the mined blocks to the inventory
              if target_entity>1 and target_entity<19 then
                -- Open doors are converted back into closed
              -- doors when added to the inventory
                if target_entity==17 or target_entity==18 then
                  add(inventory,16)
              else
                add(inventory,target_entity)
              end
                end
                mset(new_x,new_y,0+selected_block)
                sfx(1)
            else
                sfx(3)
            end
        else
            sfx(3)
        end
    end
  
    -- Destroy blocks
    -- Can't mine staircases or unexplored
    if btnp(controls.b) and (target_entity~=19 and target_entity~=0) then
        mset(new_x,new_y,1)
        sfx(1)
        -- Add the mined blocks to the inventory
      if target_entity>1 and target_entity<19 then
        -- Open doors are converted back into closed
      -- doors when added to the inventory
        if target_entity==17 or target_entity==18 then
          add(inventory,16)
      else
        add(inventory,target_entity)
      end
      elseif target_entity==19 then -- Add staircases to the depth tracker 
        add(depth_tracker,target_entity)
        else
            sfx(3)
        end
    elseif btnp(controls.b) and (target_entity==19 or target_entity==0) then
        sfx(3)
    end
end

-- How the player selects which block to place
function player_inventory()
    local hud_y=127

    -- Enter inventory mode
    if btnp(controls.x) then
        if inventory_mode then
            inventory_mode=false
        else
            inventory_mode=true
        end
    end 

    if inventory_mode then
        -- Select previous block
        if btnp(controls.up) then
            selected_block=selected_block-1
        end
        -- Select next block
        if btnp(controls.down) then
            selected_block=selected_block+1
        end
    end

    -- Render the inventory
    for blocks,count in pairs(inventory) do
        -- Add more background as the number expands
        -- to improve readability of numbers
        if count==0 then
            -- Render nothing
        elseif count<=10 then
            spr(blocks,2,hud_y)
            rect(10,hud_y,8,8,0)
            print(count,12,hud_y+2,15)
            hud_y=hud_y-10
        elseif count>10 and count<=100 then
            spr(blocks,2,hud_y)
            rect(10,hud_y,8,8,0)
            rect(18,hud_y,8,8,0)
            print(count,12,hud_y+2,15)
            hud_y=hud_y-10
        elseif count>100 and count<1000 then -- Item cap is 999
            spr(blocks,2,hud_y)
            rect(10,hud_y,8,8,0)
            rect(18,hud_y,8,8,0)
            rect(26,hud_y,8,8,0)
            print(count,12,hud_y+2,15)
            hud_y=hud_y-10
        end
    end
    
    -- Old inventory
    rect(230,0,240,10,0)
    spr(selected_block,231,1,0)
end

-- How the player interacts with entities
function player_interaction()
  -- Interact up
  -- Close doors
  if btnp(controls.y,6,6) and inventory_mode==false and direction==1 and mget(player.x,player.y-1)==16 then 
    mset(player.x,player.y-1,18)
    direction=1
    sfx(2)
  -- Open doors
  elseif btnp(controls.y,6,6) and inventory_mode==false and direction==1 and (mget(player.x,player.y-1)==17 or mget(player.x,player.y-1)==18) then
    mset(player.x,player.y-1,16)
      direction=1
      sfx(2)
  -- Staircases
  elseif btnp(controls.y,6,6) and inventory_mode==false and direction==1 and mget(player.x,player.y-1)==19 then
      -- TODO: Add code to move up a layer like generate_map()
      direction=1
      sfx(3)
  end
  
  -- Interact down
  if btnp(controls.y,6,6) and inventory_mode==false and direction==0 and mget(player.x,player.y+1)==16 then
      mset(player.x,player.y+1,18)
      direction=0
      sfx(2)
  elseif btnp(controls.y,6,6) and inventory_mode==false and direction==0 and (mget(player.x,player.y+1)==17 or mget(player.x,player.y+1)==18) then
    mset(player.x,player.y+1,16)
      direction=0
      sfx(2)
  -- Staircases
  elseif btnp(controls.y,6,6) and inventory_mode==false and direction==1 and mget(player.x,player.y-1)==19 then
      direction=1
      sfx(3)
  end
  
  -- Interact left
  if btnp(controls.y,6,6) and inventory_mode==false and direction==2 and mget(player.x-1,player.y)==16 then
    mset(player.x-1,player.y,17)
      direction=2
      sfx(2)
  elseif btnp(controls.y,6,6) and inventory_mode==false and direction==2 and (mget(player.x-1,player.y)==17 or mget(player.x-1,player.y)==18) then
    mset(player.x-1,player.y,16)
      direction=2
      sfx(2)
  -- Staircases
  elseif btnp(controls.y,6,6) and inventory_mode==false and direction==1 and mget(player.x,player.y-1)==19 then
      direction=1
      sfx(3)
  end
  
  -- Interact right
  if btnp(controls.y,6,6) and inventory_mode==false and direction==3 and mget(player.x+1,player.y)==16 then
    mset(player.x+1,player.y,17)
      direction=3
      sfx(2)
  elseif btnp(controls.y,6,6) and inventory_mode==false and direction==3 and (mget(player.x+1,player.y)==17 or mget(player.x+1,player.y)==18) then
    mset(player.x+1,player.y,16)
      direction=3
      sfx(2)
  -- Staircases
  elseif btnp(controls.y,6,6) and inventory_mode==false and direction==1 and mget(player.x,player.y-1)==19 then
      direction=1
      sfx(3)
  end
end

function check_player_direction()
  if direction==0 then
      placement.x=0
      placement.y=1
  end
  
 if direction==1 then
    placement.x=0
      placement.y=-1
  end
    
  if direction==2 then
    placement.x=-1
      placement.y=0
  end
  
 if direction==3 then
    placement.x=1
      placement.y=0
  end
end


-- Print a message to the console
trace("\n\n----------------------------------\nAuthor: LegoDinoMan\nTitle: Murdram \nVersion: "..version.."\nUpdated: "..updateDate.."\nReleased: "..releaseDate.."\nLostRabbitDigital.itch.io/murdram\n----------------------------------\n")


function TIC()
  check_player_direction()
  player_block_manager()
  player_movement()
  player_interaction()
  
    map(player.x-15,player.y-8,max_x,max_y)

    player_inventory()
    
    -- TODO:Get rid of this block of code
    local hud_y=128
    -- Render the depth_tracker
    for depth_levels,count in pairs(depth_tracker) do
      spr(depth_levels,2,0)
        if count<=10 then
            rect(10,hud_y,8,8,14)
        elseif count>10 and count<=100 then
            rect(10,hud_y,8,8,14)
            rect(18,hud_y,8,8,14)
        elseif count>100 and count<1000 then -- Depth cap is 999
            rect(10,hud_y,8,8,14)
            rect(18,hud_y,8,8,14)
            rect(26,hud_y,8,8,14)
        end
        print(count,12,2,15)
    end

    spr(player.sprite+direction,15*8,8*8,0)
end