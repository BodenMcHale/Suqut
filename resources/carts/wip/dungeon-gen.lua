-- title:   Dungeon Generator
-- author:  LegoDinoMan
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

-- Define constants for the dungeon layout
BLOCK = {
  WALL = 2,
}

NONBLOCK = {
  FLOOR = 0,
  STAIRS = 1
}

-- Define the dungeon layout
dungeon = {}

function init()
  -- Define level statistics
  floorNumber = 0
  finalFloor = 10

  -- Define the player's starting position
  player = {
	x = 2,
	y = 2,
	spr = 256
  }

  -- Generate the first floor
  generateNewFloor()
end

function generate_random_number(min, max)
  return math.random(min, max)
end

-- Define the function to check if the player has reached the final floor
function checkFinalFloor()
  if floorNumber == finalFloor then
    print("YOU DID IT!", 10, 10, 14)
    generateNewFloor()
  end
end

-- TODO: Add desc
function generateStairs()
  -- Define stair settings
  local stairs = {
  	x = 0,
  	y = 0,
  	amount = 0
  }	

  while stairs.amount < 1 do
  	-- Randomize stair position
    stairs.x = generate_random_number(2, width)
    stairs.y = generate_random_number(2, height)

    -- Check if the stairs are in a wall
    if dungeon[stairs.x][stairs.y] ~= BLOCK.WALL then
      -- Check if the player is where the stair will go
      if dungeon[player.y][player.x] ~= NONBLOCK.STAIRS then
        -- Set the tile to stairs 
        dungeon[stairs.x][stairs.y] = NONBLOCK.STAIRS
        stairs.amount = 1
      end
    end
  end
end

-- Generate a randomized floor
function generateNewFloor()
  -- Randomize floor size
  width = generate_random_number(5, 15)
  height = generate_random_number(5, 25)

  -- reset the current floor's layout
  dungeon = {
  	{BLOCK.WALL, BLOCK.WALL, BLOCK.WALL},
  	{BLOCK.WALL, NONBLOCK.FLOOR, BLOCK.WALL},
  	{BLOCK.WALL, BLOCK.WALL, BLOCK.WALL}
  }

  for x = 1, width do
  	dungeon[x] = {}
    for y = 1, height do
      if x == 1 or x == width or y == 1 or y == height then
        dungeon[x][y] = BLOCK.WALL -- Set walls on the perimeter
      else
        dungeon[x][y] = NONBLOCK.FLOOR -- Set walls on the perimeter
      end
    end
  end

  -- Loop until there is a staircase on the floor
  generateStairs()

  -- Increase floor count
  floorNumber = floorNumber + 1

  -- Check if the player has reached the final floor
  checkFinalFloor()
end


-- Define the function to check if the player has reached the stairs
function checkStairs()
  if dungeon[player.y][player.x] == NONBLOCK.STAIRS then
    -- Generate a new floor
    generateNewFloor()
  end
end

-- Define the function to move the player
function movePlayer()
  if btnp(0,6,6) and dungeon[player.y-1][player.x] ~= BLOCK.WALL then
    player.y = player.y - 1
  elseif btnp(1,6,6) and dungeon[player.y+1][player.x] ~= BLOCK.WALL then
    player.y = player.y + 1
  elseif btnp(2,6,6) and dungeon[player.y][player.x-1] ~= BLOCK.WALL then
    player.x = player.x - 1
  elseif btnp(3,6,6) and dungeon[player.y][player.x+1] ~= BLOCK.WALL then
    player.x = player.x + 1
 end

  -- Check if the player has reached the stairs
  checkStairs()
end

-- Define the function to draw the dungeon on the screen
function drawDungeon()
  cls()

  -- TODO: Why is this [y][x] and not [x][y]
  -- Loop through the dungeon tiles and draw them
  for y = 1, #dungeon do
    for x = 1, #dungeon[y] do
      if dungeon[y][x] == NONBLOCK.FLOOR then
        spr(NONBLOCK.FLOOR, x * 8, y * 8)
      elseif dungeon[y][x] == BLOCK.WALL then
        spr(BLOCK.WALL, x * 8, y * 8)
      elseif dungeon[y][x] == NONBLOCK.STAIRS then
        spr(NONBLOCK.STAIRS, x * 8, y * 8)
      end
    end
  end

  -- Draw player
  spr(player.spr, player.x * 8, player.y * 8)

  -- Print current floor
  print(floorNumber, 0, 0, 15)
end

init()
-- Define the main game loop
function TIC()
  movePlayer()

  -- Draw the dungeon and the player
  drawDungeon()
end


-- <TILES>
-- 000:000000000000000000000000000ff000000ff000000000000000000000000000
-- 001:00000000fff00000000fff00000000ff000000ff000fff00fff0000000000000
-- 002:0000000000d00d000dddddd000d00d0000d00d000dddddd000d00d0000000000
-- 003:0000000000e00e000eeeeee000e00e0000e00e000eeeeee000e00e0000000000
-- 016:00000000000ff000000ff0000ffffff00ffffff0000ff000000ff00000000000
-- 017:00000000000ff000000ff000000ff000000ff000000ff000000ff00000000000
-- 018:0000000000000000000000000ffffff00ffffff0000000000000000000000000
-- </TILES>

-- <SPRITES>
-- 000:000000000ffffff00f0000f00f0ff0f00f0ffff00f0000000fffff0000000000
-- 048:0ffff000f0000f00f00000f0f00ff0f00ff00e000000ede00000e84000000400
-- 049:0ffff000f0000f00f00000f0f00ff0f00ff00700000075700000723000000300
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:000000442434003c044e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa9d6dc2cadad45edeeed6
-- </PALETTE>

