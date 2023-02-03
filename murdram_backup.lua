  -- title:  Murdram
  -- author: LegoDinoMan, JupiterSky
  -- desc:   Arrows to move, top button to swap modes, left button to change block, right button to use tool.
  -- script: lua


  -- Developer variables
  version="1.0.0"
  updateDate="02-02-2023"
  releaseDate="02-02-2023"
  debug=false

  local llr = 0

  -- TODO: Add a credits
  local menu = {}
  menu.state = "MAIN"
  menu.subSt = "NONE"
  menu.subSel = 0
  menu.select = 0

  local cam = {}
  cam.x = 0
  cam.y = 0
  local updates = 0
  local renders = 0
  local transparentTick = {}
  transparentTick.shadow = 0
  transparentTick.heldBlock = 0

  local inv = {}
  inv.hotbar = {1, 2, 3, 4, 5, 6, 7, 17, 34}
  inv.hotbar.sel = 1

  local plyr = {}

  plyr.x = 96
  plyr.y = 24
  plyr.z = 100
  plyr.vx = 0
  plyr.vy = 0
  plyr.vz = 0
  local onGround = false
  local facing = 0
  local playerState = 0

  local render_distance = 7

  bl = {1, 2, 3, 4, 5, 6, 7, 17, 33, 34}

  local placex = 0
  local placey = 0
  local placeID = 1

  local camx = 0
  local camy = 0

  world = {}

  -- Minimum height of the world
  local wminwidth = 0
  -- Minimum width of the world
  local wminheight = 0
  -- Minimum depth of the world
  local wmindepth = -100

  -- Maximum width of the world
  local wwidth = 30
  -- Maximum height of the world
  local wheight = 17
  -- Maximum depth of the world
  local wdepth = 120

  local ttemp = {}
  ttemp.type = 0
  ttemp.state = 0



  for i = 0, wwidth do
   world[i] = {}
   for k = 0, wheight do
    world[i][k] = {}
    for j = 0, wdepth do
      world[i][k][j] = ttemp
        end
      end
   end





  function updatePlayer()


  if btn(0) then
    plyr.vy = plyr.vy - .3
    facing = 0
  end

  if btn(1) then
    plyr.vy = plyr.vy + .3
    facing = 2
  end

  if btn(2) then
    plyr.vx = plyr.vx - .3
    facing = 3
  end

  if btn(3) then
    plyr.vx = plyr.vx + .3
    facing = 1
  end

  if btnp(4) and onGround then
    plyr.vz = plyr.vz + 0.3
    end

  if btnp(7) then
   playerState = playerState + 1
   if playerState > 2 then
     playerState = 0
      end
    end


  if facing == 0 then
   placex = 0
    placey = -1
  elseif facing == 1 then
   placex = 1
    placey = 0
  elseif facing == 2 then
   placex = 0
    placey = 1
  elseif facing == 3 then
   placex = -1
    placey = 0
  end


  if btnp(5) and playerState == 1 and inv.hotbar[inv.hotbar.sel] ~= nil then
   local tfd = wget(plyr.x//8+placex, plyr.y//8+placey, plyr.z-1)
   local tfu = wget(plyr.x//8+placex, plyr.y//8+placey, plyr.z)
    if tfd.type == 0 then
    createTile(plyr.x//8+placex, plyr.y//8+placey, plyr.z-1, inv.hotbar[inv.hotbar.sel], 0)
      sfx(1, "E-3")
   elseif tfu.type == 0 then
    createTile(plyr.x//8+placex, plyr.y//8+placey, plyr.z, inv.hotbar[inv.hotbar.sel], 0)
      sfx(1, "E-3")
   end
  elseif btnp(5) and playerState == 2 then
   local tfd = wget(plyr.x//8+placex, plyr.y//8+placey, plyr.z-1)
   local tfu = wget(plyr.x//8+placex, plyr.y//8+placey, plyr.z)
    if tfu.type ~= 0 then
    createTile(plyr.x//8+placex, plyr.y//8+placey, plyr.z, 0, 0)
      sfx(2, "E-3")
   elseif tfd.type ~= 0 then
    createTile(plyr.x//8+placex, plyr.y//8+placey, plyr.z-1, 0, 0)
      sfx(2, "E-3")
   end
  end


  if not onGround then
   plyr.vz = plyr.vz - 0.03
  end

  plyr.vx = plyr.vx * .7
  plyr.vy = plyr.vy * .7
  plyr.vz = plyr.vz * .98

  plyr.x = plyr.x + plyr.vx
  plyr.y = plyr.y + plyr.vy
  plyr.z = plyr.z + plyr.vz


  end






  function drawPlayer()
    local tTick = transparentTick
  if playerState == 0 then
   spr(256 + facing, plyr.x - 4, plyr.y - 4, 1)
  elseif playerState == 1 then
    if inv.hotbar[inv.hotbar.sel] ~= nil then
      
      --rect((plyr.x//8+placex)*8, (plyr.y//8+placey)*8, 8, 8, 11)
      --spr(497, (plyr.x//8+placex)*8, (plyr.y//8+placey)*8, 0)
      
      if tTick.heldBlock >= 15 then
        spr(inv.hotbar[inv.hotbar.sel], (plyr.x//8+placex)*8, (plyr.y//8+placey)*8)
        line(((plyr.x//8+placex)*8), ((plyr.y//8+placey)*8)-1, ((plyr.x//8+placex)*8)+7, ((plyr.y//8+placey)*8)-1, 15)
        line(((plyr.x//8+placex)*8), ((plyr.y//8+placey)*8)+8, ((plyr.x//8+placex)*8)+7, ((plyr.y//8+placey)*8)+8, 0)
        line(((plyr.x//8+placex)*8)-1, ((plyr.y//8+placey)*8), ((plyr.x//8+placex)*8)-1, ((plyr.y//8+placey)*8)+7,15)
        line(((plyr.x//8+placex)*8)+8, ((plyr.y//8+placey)*8), ((plyr.x//8+placex)*8)+8, ((plyr.y//8+placey)*8)+7, 0)
        --line((plyr.x-4+placex*8)+8, (plyr.y-4+placey*8), (plyr.x-4+placex*8)+8, (plyr.y-4+placey*8)+7, 0)
      end
     
      local offsetX, offsetY = 0, 0
      
      if facing == 0 then
        offsetX = 2
        offsety = -4
      elseif facing == 1 then
        offsetX = 3
        offsety = 3
      elseif facing == 2 then
        offsetX = -3
        offsety = 3
      elseif facing == 3 then
        offsetX = -4
        offsety = 3
      end
        
      
      
      line((plyr.x+offsetX), (plyr.y+offsetY), ((plyr.x//8+placex)*8)+8, ((plyr.y//8+placey)*8)+8, 0)
      line((plyr.x+offsetX), (plyr.y+offsetY), ((plyr.x//8+placex)*8)+8, ((plyr.y//8+placey)*8)-1, 0)
      line((plyr.x+offsetX), (plyr.y+offsetY), ((plyr.x//8+placex)*8)-1, ((plyr.y//8+placey)*8)+8, 0)
      line((plyr.x+offsetX), (plyr.y+offsetY), ((plyr.x//8+placex)*8)-1, ((plyr.y//8+placey)*8)-1, 0)
      
    end
    
   spr(256 + facing + 8, plyr.x - 4, plyr.y - 4, 1)
    
  elseif playerState == 2 then
   
    --rect((plyr.x//8+placex)*8, (plyr.y//8+placey)*8, 8, 8, 6)
    spr(496, (plyr.x//8+placex)*8, (plyr.y//8+placey)*8, 0)
    
   spr(256 + facing + 8, plyr.x - 4, plyr.y - 4, 1)
    
   end

  end






  function updateCollisions()


  for j = plyr.z//1-2, plyr.z//1+1 do

   for i = 0, wwidth do
     
      for k = 0, wheight do
     
        
       local t = wget(i, k, j)
        
        
        if t.type ~= 0 then
        
        
        local above = wget(i, k, plyr.z+1)
        
        
        if i*8 < plyr.x+16 and i*8 > plyr.x-16 and k*8 < plyr.y+16 and k*8 > plyr.y-16 and j >= plyr.z//1-1 then
          
          local box1 = {}
          local box2 = {}
          
          box1.x = i*8+4
          box1.y = k*8+4
          
          box2.x = plyr.x
          box2.y = plyr.y
          
          box1.width = 8
          box2.width = 4
          
          local hw1 = box1.width*0.5
          local hw2 = box2.width*0.5
          local invjmpx = false
          local invjmpy = false
          local xjump = 0
          local yjump = 0
          local colx = false
          local coly = false
          
          if box2.x >= box1.x and box2.y > box1.y - (hw1 + hw2) and box2.y < box1.y + (hw1 + hw2) then
          
          local length = box2.x - box1.x
          local gap = length - hw1 - hw2
          if gap < 0 then
           xjump = gap
           invjmpx = true
            colx = true
          end
          
          elseif box2.x < box1.x and box2.y > box1.y - (hw1 + hw2) and box2.y < box1.y + (hw1 + hw2) then
          
          local length = box1.x - box2.x
          local gap = length - hw1 - hw2
          
          if gap < 0 then
            xjump = gap
            invjmpx = false
            colx = true
          end
          
          end
          
          
          
          
          if box2.y >= box1.y and box2.x > box1.x - (hw1 + hw2) and box2.x < box1.x + (hw1 + hw2) then
          
          local length = box2.y - box1.y
          local gap = length - hw1 - hw2
          
          if gap < 0 then
            yjump = gap
            invjmpy = true
            coly = true
          end
          
          elseif box2.y < box1.y and box2.x > box1.x - (hw1 + hw2) and box2.x < box1.x + (hw1 + hw2) then
          
          local length = box1.y - box2.y
          local gap = length - hw1 - hw2
          
          if gap < 0 then
            yjump = gap
            invjmpy = false
            coly = true
          end
          
          end
          
          
          
          if j == plyr.z//1 and above.type ~= 0 then
          
          if yjump > xjump and coly then
            if invjmpy then
              plyr.y = box2.y - yjump
            elseif not invjmpy then
              plyr.y = box2.y + yjump
            end
          elseif xjump > yjump and colx then
            if invjmpx then
              plyr.x = box2.x - xjump
            elseif not invjmpx then
              plyr.x = box2.x + xjump
            end
          end
          
          
          else
          
          if j == plyr.z//1 and above.type == 0 and t.type ~= 34 then
            
            if colx or coly then
              
              plyr.z = plyr.z + 1
              
            end
          
          end
            
          if j < plyr.z//1+1 then
           if colx or coly then
             onGround = true
              plyr.z = j + 1
              plyr.vz = 0
            end
          end
          end
          
          
          end
          end
          
          
          updates = updates + 1
          
        end
      end
    end
  end






  function updateWorld()


  for j = 0, 12 do

   for i = 0, wwidth do
     
      for k = 0, wheight do
        
       local t = world[i][k][j]
        
       if t == nil then
          
          createTile(i, k, j, 0, 0)
          
        elseif t.type == 0 then
          
          --no 'thang
          
        end
      end
    end
  end


  end






  function scanTiles()
    local tTick = transparentTick
    
    local toDraw = {}
    
    for q = plyr.z//1-50, plyr.z//1 do
      toDraw[q] = {}
    end
    
    
    for j = wminwidth,  wwidth do
      for i = wminheight, wheight do
        
        for q = plyr.z//1, plyr.z//1-50, -1 do
          
          
          t = world[j][i][q]
          
          if t.type ~= 0 then
            local tile = {}
            tile.type = t.type
            tile.x = j
            tile.y = i
            
            tile.n = false
            tile.s = false
            tile.w = false
            tile.e = false
            tile.u = false
            if wget(j, i-1, q).type == 0 then tile.n = true end
            if wget(j, i+1, q).type == 0 then tile.s = true end
            if wget(j-1, i, q).type == 0 then tile.w = true end
            if wget(j+1, i, q).type == 0 then tile.e = true end
            if wget(j, i, q+1).type == 0 then tile.u = true end
            table.insert(toDraw[q], tile)
            --renders = renders + 1
            break
          end
          
        end
        
      end
    end
    
    
    
    for j = wmindepth, #toDraw, 1 do
      if toDraw[j] ~= nil then
        for q = 0, #toDraw[j] do
          local t = toDraw[j][q]
          if t ~= nil then
            if t.n or t.s or t.w or t.e or t.u then
              spr(t.type, t.x*8, t.y*8, 0)
              if t.n then line(t.x*8+2, t.y*8+1, t.x*8+5, t.y*8+1, 15) renders = renders + 1 end
              if t.s then line(t.x*8+2, t.y*8+6, t.x*8+5, t.y*8+6, 0) renders = renders + 1 end
              if t.w then line(t.x*8+1, t.y*8+2, t.x*8+1, t.y*8+5, 15) renders = renders + 1 end
              if t.e then line(t.x*8+6, t.y*8+2, t.x*8+6, t.y*8+5, 0) renders = renders + 1 end
              if not t.u then
                spr(83+tTick.shadow, t.x*8, t.y*8, 1) renders = renders + 1
              end
              renders = renders + 1
            end
          end
        end
      end
    end
    
    
    
  end






  function drawTiles()
    
    
    
  end






  function drawWorld()
    
    scanTiles()
    
  end






  function drawInventory()
    
    
    
    if menu.subSt == "INVENTORY" then
      
      menuBox(30, 68, 48, 112, 4, 9, 1, 9, 1)
      print("Hotbar", 13, 17)
      
      
      if btnp(0) then menu.select = menu.select - 1 sfx(3, "3-F") end
      if btnp(1) then menu.select = menu.select + 1 sfx(3, "3-F") end
      if btnp(2) then menu.select = menu.select - 6 sfx(3, "3-F") end
      if btnp(3) then menu.select = menu.select + 6 sfx(3, "3-F") end
      inv.hotbar.sel = menu.select + 1
      
      local slots = 11
      
      if menu.select < 0 then menu.select = slots+(menu.select+1)
      elseif menu.select > slots then menu.select = (menu.select-1-slots)
      end
      
      
      local currentSlot = 0
          
      for j = 0, 1, 1 do
        if currentSlot > slots then
          break
        end
        
        for q = 0, 5, 1 do
          if menu.select == currentSlot then
            menuBox(22+j*16, 33+q*16, 12, 12, 4, 1, 9, 1, 9)
          else
            menuBox(22+j*16, 33+q*16, 12, 12, 4, 9, 1, 9, 1)
          end
          if inv.hotbar[currentSlot+1] ~= nil then
            rect((22-5)+j*16, (33-5)+q*16, 10, 10, 0)
            spr(inv.hotbar[currentSlot+1], (22-4)+j*16, (33-4)+q*16)
          end
          currentSlot = currentSlot + 1
        end
      end
      
    end
    
    
    
  end






  function updateInventory()
    
    
    
  end






  function wget(q, j, k)
    
    local t = {}
    
    if  q >= wminwidth and j >= wminheight and q <= wwidth and j <= wheight and k <= wdepth then
      t = world[q][j][k]
    end
    
    if t == nil or t == {} then
      t = {}
      t.type = 0
      t.state = 0
    end
    
    return t
    
  end






  function createTile(x, y, z, type, state)

  local t = {}

  t.type = type
  t.state = state

  world[x][y][z] = t

  end






  function menuBox(x, y, width, height, col1, col2, col3, col4, col5)
    rect(x-width/2, y-height/2, width, height, col1)
    line(x-width/2-1, y-height/2-1, x+width/2, y-height/2-1, col2)
    line(x-width/2-1, y+height/2, x+width/2, y+height/2, col3)
    line(x-width/2-1, y-height/2, x-width/2-1, y+height/2-1, col4)
    line(x+width/2, y-height/2, x+width/2, y+height/2-1, col5)
  end






  function rnd(min, max, d)
  return math.random(min*d, max*d) / d
  end






  function _INIT()
    for q = 0, 30 do
      for j = 0, 17 do
        for k = wmindepth, wdepth do
          
          local oreRND = rnd(0, 500, 1)
          
          if k == 51 and oreRND < 1 then
            createTile(q, j, k, 0, 0) -- change to leaves someday
          elseif k > 50 then
            createTile(q, j, k, 0, 0)
          elseif k == 50 then
            createTile(q, j, k, 1, 0)
          else
            
            if oreRND <= 40 and k < 0 then
              createTile(q, j, k, 6, 0)
            elseif oreRND <= 10 and k < 5 then
              createTile(q, j, k, 6, 0)
            elseif oreRND <= 5 and k < 30 then
              createTile(q, j, k, 6, 0)
              
            elseif oreRND <= 15 and k < 40 then
              createTile(q, j, k, 4, 0)
            elseif oreRND <= 20 and k < 7 then
              createTile(q, j, k, 4, 0)
              
            elseif oreRND <= 50 and k < 47 then
              createTile(q, j, k, 5, 0)
              
            else
              createTile(q, j, k, 3, 0)
              
            end
          end
        end
      end
    end
  end

  _INIT()



  -- Print a message to the console
  trace("\n\n----------------------------------\nAuthor: LegoDinoMan\nTitle: Murdram \nVersion: "..version.."\nUpdated: "..updateDate.."\nReleased: "..releaseDate.."\nLostRabbitDigital.itch.io/murdram\n----------------------------------\n")

  function TIC()
    
    if menu.state == "MAIN" then
      cls(0)
      
      menuBox(120, 68, 64, 98, 4, 9, 1, 9, 1)
      print("- Murdram -", 91, 24, 15)
      
      
      if btnp(0) then menu.select = menu.select - 1 end
      if btnp(1) then menu.select = menu.select + 1 end
      
      if menu.select < 0 then menu.select = 0
      elseif menu.select > 0 then menu.select = 0
      end
      
      
      if menu.select == 0 then
        menuBox(120, 44, 48, 11, 4, 9, 1, 9, 1)
        menuBox(120, 64, 48, 11, 1, 1, 9, 1, 9)
        menuBox(120, 84, 48, 11, 1, 1, 9, 1, 9)
        menuBox(120, 104, 48, 11, 1, 1, 9, 1, 9)
        if btnp(4) then
          menu.state = "PLAY"
        end
      elseif menu.select == 1 then
        menuBox(120, 44, 48, 11, 4, 9, 1, 9, 1)
        menuBox(120, 64, 48, 11, 1, 9, 1, 9, 1)
        menuBox(120, 84, 48, 11, 4, 9, 1, 9, 1)
        menuBox(120, 104, 48, 11, 4, 9, 1, 9, 1)
      elseif menu.select == 2 then
        menuBox(120, 44, 48, 11, 4, 9, 1, 9, 1)
        menuBox(120, 64, 48, 11, 4, 9, 1, 9, 1)
        menuBox(120, 84, 48, 11, 1, 9, 1, 9, 1)
        menuBox(120, 104, 48, 11, 4, 9, 1, 9, 1)
      elseif menu.select == 3 then
        menuBox(120, 44, 48, 11, 4, 9, 1, 9, 1)
        menuBox(120, 64, 48, 11, 4, 9, 1, 9, 1)
        menuBox(120, 84, 48, 11, 4, 9, 1, 9, 1)
        menuBox(120, 104, 48, 11, 1, 9, 1, 9, 1)
      end
      
      print("Play", 109, 41, 15)
      print("Options", 101, 61, 4)
      print("Credits", 101, 81, 4)
      print("Tutorial", 99, 101, 4)
      
      
    elseif menu.state == "PLAY" then
      
      
      local tTick = transparentTick
      
      if tTick.heldBlock ~= 29 then
        tTick.heldBlock = tTick.heldBlock + 1
      else
        tTick.heldBlock = 0
      end
      
      if tTick.shadow ~= 3 then
        tTick.shadow = tTick.shadow + 1
      else
        tTick.shadow = 0
      end
      
      if btnp(6) and menu.subSt == "NONE" then
        menu.subSt = "INVENTORY"
      elseif btnp(6) and menu.subSt == "INVENTORY" then
        menu.subSt = "NONE"
      end
      
      if placeID > #bl then
       placeID = 1
        end
      
      if plyr.z > wdepth then
        plyr.z = 0
        end
      
      
      updates = 0
      renders = 0
      onGround = false
      
      
      -- Updates --
      if menu.subSt == "NONE" then
        updateCollisions()
        --updateWorld()
        updatePlayer()
      end
      
      -- Drawing --
      cls(0)
      drawWorld()
      drawPlayer()
      if menu.subSt == "INVENTORY" then
        drawInventory()
      end
      
      
      local og = 0
      if onGroud then
       og = 1
      end
      
      if menu.subSt == "NONE" then
        
        
        for j = wdepth, wmindepth, -1 do
         local t = wget(plyr.x//8, plyr.y//8, j)
          print(t.type, 230, (62-j*8)+plyr.z*8)
        end
        line(227, 64, 237, 64, 15)
        print(">", 224, 62, 15)
        print("Layer: " .. plyr.z .. "\nOn Ground: " .. og .. "\nRenders: " .. renders .. "\nUpdates: " .. updates, 0, 0, 15)
        
        --[[
        for q = 0, 240 do
          for j = 0, 136 do
            
            if math.random(1, 1200) == 1 then
              pix(q,j,13)
            end
            
          end
        end]]
        
        
      end
      
    end
  end