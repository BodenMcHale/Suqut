-- title: abandoned roguelike
-- author: trelemar
-- desc: abandoned
-- script: lua

local middleclass = {
  _VERSION     = 'middleclass v4.1.0',
  _DESCRIPTION = 'OOP for Lua',
  _URL         = 'https://github.com/kikito/middleclass',
}

local function _createIndexWrapper(aClass, f)
  if f == nil then
    return aClass.__instanceDict
  else
    return function(self, name)
      local value = aClass.__instanceDict[name]

      if value ~= nil then
        return value
      elseif type(f) == "function" then
        return (f(self, name))
      else
        return f[name]
      end
    end
  end
end

local function _propagateInstanceMethod(aClass, name, f)
  f = name == "__index" and _createIndexWrapper(aClass, f) or f
  aClass.__instanceDict[name] = f

  for subclass in pairs(aClass.subclasses) do
    if rawget(subclass.__declaredMethods, name) == nil then
      _propagateInstanceMethod(subclass, name, f)
    end
  end
end

local function _declareInstanceMethod(aClass, name, f)
  aClass.__declaredMethods[name] = f

  if f == nil and aClass.super then
    f = aClass.super.__instanceDict[name]
  end

  _propagateInstanceMethod(aClass, name, f)
end

local function _tostring(self) return "class " .. self.name end
local function _call(self, ...) return self:new(...) end

local function _createClass(name, super)
  local dict = {}
  dict.__index = dict

  local aClass = { name = name, super = super, static = {},
                   __instanceDict = dict, __declaredMethods = {},
                   subclasses = setmetatable({}, {__mode='k'})  }

  if super then
    setmetatable(aClass.static, { __index = function(_,k) return rawget(dict,k) or super.static[k] end })
  else
    setmetatable(aClass.static, { __index = function(_,k) return rawget(dict,k) end })
  end

  setmetatable(aClass, { __index = aClass.static, __tostring = _tostring,
                         __call = _call, __newindex = _declareInstanceMethod })

  return aClass
end

local function _includeMixin(aClass, mixin)
  assert(type(mixin) == 'table', "mixin must be a table")

  for name,method in pairs(mixin) do
    if name ~= "included" and name ~= "static" then aClass[name] = method end
  end

  for name,method in pairs(mixin.static or {}) do
    aClass.static[name] = method
  end

  if type(mixin.included)=="function" then mixin:included(aClass) end
  return aClass
end

local DefaultMixin = {
  __tostring   = function(self) return "instance of " .. tostring(self.class) end,

  initialize   = function(self, ...) end,

  isInstanceOf = function(self, aClass)
    return type(aClass) == 'table' and (aClass == self.class or self.class:isSubclassOf(aClass))
  end,

  static = {
    allocate = function(self)
      assert(type(self) == 'table', "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
      return setmetatable({ class = self }, self.__instanceDict)
    end,

    new = function(self, ...)
      assert(type(self) == 'table', "Make sure that you are using 'Class:new' instead of 'Class.new'")
      local instance = self:allocate()
      instance:initialize(...)
      return instance
    end,

    subclass = function(self, name)
      assert(type(self) == 'table', "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'")
      assert(type(name) == "string", "You must provide a name(string) for your class")

      local subclass = _createClass(name, self)

      for methodName, f in pairs(self.__instanceDict) do
        _propagateInstanceMethod(subclass, methodName, f)
      end
      subclass.initialize = function(instance, ...) return self.initialize(instance, ...) end

      self.subclasses[subclass] = true
      self:subclassed(subclass)

      return subclass
    end,

    subclassed = function(self, other) end,

    isSubclassOf = function(self, other)
      return type(other)      == 'table' and
             type(self.super) == 'table' and
             ( self.super == other or self.super:isSubclassOf(other) )
    end,

    include = function(self, ...)
      assert(type(self) == 'table', "Make sure you that you are using 'Class:include' instead of 'Class.include'")
      for _,mixin in ipairs({...}) do _includeMixin(self, mixin) end
      return self
    end
  }
}

function middleclass.class(name, super)
  assert(type(name) == 'string', "A name (string) is needed for the new class")
  return super and super:subclass(name) or _includeMixin(_createClass(name), DefaultMixin)
end

setmetatable(middleclass, { __call = function(_, ...) return middleclass.class(...) end })

---LINE OF SIGHT


--[[
This WIP RogueLike takes a minimal art approach and focuses on gameplay.
Exprimenting with OOP library middleclass by kikito. Also tking a new organized code layout
Code above this is middleclass. Code below is the game. Enjoy!
--]]
local sin,cos,rand,sqrt=math.sin,math.cos,math.random,math.sqrt
local LCONST=.1

function dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
function lerp(a,b,t) return (1-t)*a + t*b end
function col(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function printb(text,x,y,color,bcolor)
  for i = -1,1,2 do
    print(text,x+i,y,bcolor or 0)
    print(text,x,y+i,bcolor or 0)
  end
  print(text,x,y,color or 15)
end

function xp2l(xp)
  return LCONST * sqrt(xp)
end

function l2xp(l)
  return (l/LCONST)^2
end

function addXP(i,xp)
  pmem(i,pmem(i)+xp)
end

function pal(c0,c1)
  if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end
  else poke4(0x3FF0*2+c0,c1)end
end

cdark={
  [3]=1,
  [4]=1,
  [6]=1,
  [7]=3,
  [8]=2,
  [9]=4,
  [10]=3,
  [11]=5,
  [12]=6,
  [13]=8,
  [14]=9,
  [15]=7
}
function darken()
  for i,v in pairs(cdark) do
    pal(i,v)
  end
end

function cellular_gen(sx,sy,w,h,time)
  local tiles={0,17}
  for x=sx,sx+w do
    for y=sy,sy+h do
      if x==sx or x==sx+w or y==sy or y==sy+h then
        mset(x,y,17)
      elseif rand()>.4 then
        mset(x,y,tiles[math.random(1,#tiles)])
      else
        mset(x,y,0)
      end
    end
  end
  local count=0
  while count<time do
    for x=sx,sx+w do
      for y=sy,sy+h do
        local dirs={mget(x-1,y),mget(x+1,y),mget(x,y-1),mget(x,y-1),mget(x-1,y-1),mget(x+1,y+1),mget(x-1,y+1),mget(x+1,y-1)}
        mset(x,y,dirs[math.random(1,#dirs)])
        count=count+1
      end
    end
  end
  for i=1,12 do
    Monster(rand(sx,sx+w),rand(sy,sy+h))
    Item(rand(sx,sx+w),rand(sy,sy+h),rand(1,11))
  end
end
local rock={[17]=9,[18]=true}
local solids={[17]=true,[18]=true,[33]=true,[49]=true}
for i=3,67,16 do solids[i]=true end
solids[35]=false
function solid(x,y) return solids[mget(x,y)] end
local log_t={}                      --(log table) Log displays game interactions

function log(string)
  if #log_t>=3 then table.remove(log_t,#log_t) end
  table.insert(log_t,1,string)
end

function draw_log()
  for i=#log_t,1,-1 do
    print(tostring(log_t[i]),0,128-(i*7))
  end
end

local class = middleclass

local Player=class("Player")

function Player:initialize(x,y)
  self.x=x
  self.y=y
  self.hp=100
  self.hunger=100
  self.spr=1
  self.flip=0
  self.inv={}
  self.lhand={}
end

function Player:update()
  --Handle Input
  local dest_x,dest_y=0,0
  if roll then roll = not roll end --roll, or advance turn. where all the action happens.

  if btnp(0,1,4) then
    roll=true 
    dest_y= -1
  end
  if btnp(1,1,4) then
    roll=true
    dest_y= 1
  end
  if btnp(2,1,4) then
    roll=true
    dest_x=-1
  end
  if btnp(3,1,4) then
    roll=true
    dest_x=1
  end

  for i,v in pairs(monsters) do
    if self.x+dest_x==v.x and self.y+dest_y==v.y then
      dest_x,dest_y=0,0
      self:melee(i,v)
    end
  end

  if solid(self.x+dest_x,self.y+dest_y) then
    if p.lhand.type==2 and rock[mget(self.x+dest_x,self.y+dest_y)] then
      mset(self.x+dest_x,self.y+dest_y,34)
      p:Pickup(-1,Item:new(0,0,10))
    end
  else
    self.x=self.x+dest_x
    self.y=self.y+dest_y
  end

  for i,v in pairs(items) do
    if self.x==v.x and self.y==v.y then
      keys[4]="Pick Up"
      if btnp(4) then
        p:Pickup(i,v)
        keys[4]=""
      end
    end
  end

  if roll then
    self.hunger=self.hunger-.5

    if self.hunger==20 then
      log("You're getting hungry")
    end

    if self.hunger<0 and self.hunger%20==0 then   --Hurt the player after 20 rolls with negative hunger
      log("Your stomach growls")
      self.hp=self.hp-20
    end
  end

  --Draw it
  --spr(self.spr or 1,self.x*8,self.y*8,-1,1,self.flip
end

function Player:melee(mi,m)
  m.hp=m.hp-10
  table.insert(dmg,{n=-10,t=0,x=m.x,y=m.y})
  if m.hp<=0 then
    table.remove(monsters,mi)
    log("You killed the "..m.name)
    addXP(0,50)
  else
    local mhit=5+rand(0,5)
    self.hp=self.hp-mhit
    log("You hit the "..m.name..". HP: "..m.hp)
    addXP(0,10)
  end
end

function Player:Pickup(i,item)
  local stacked=false

  for ii,v in pairs(self.inv) do
    if v.name==item.name and v.stack then
      v.stack=v.stack+1
      stacked=true
    end
  end

  if not stacked then
    table.insert(self.inv,item)
  end

  if i~= -1 then
    table.remove(items,i)
  end
  log("Picked up: "..item.name)
end

Monster=class("Monster") monsters={}        --Define Monster class and monster container

function Monster:initialize(x,y)
  self.name="Zombie"
  self.x=x
  self.y=y
  self.hp=20
  self.spr=2
  table.insert(monsters,self)
end

function Monster.static:updateAll()           --Update method for ALL Monsters
  for i,v in pairs(monsters) do
    v:update()
  end 
end

function Monster:update()
  if roll then
    local d=math.random(-1,1)
    local direction=math.random(0,1)
    if direction==0 then
      if not solid(self.x,self.y+d) then self.y=self.y+d end
    elseif direction==1 then
      if not solid(self.x+d,self.y) then self.x=self.x+d end
    end
  end
  --Draw it
  if lineofsight(p.x,p.y,self.x,self.y) then
    spr(self.spr,(self.x-mx)*8,(self.y-my)*8)
  end
end

Item=class("Item") items={}             --Item class definition and items container

TYPES={
  [0]="Food",
  [1]="Weapon",
  [2]="Tool",
  [3]="Resource",
  [4]="Magic"
}

ITEM_IDS={
  --TYPE 0 (Food)
  [1]={name="Tomato",spr=288,type=0},
  [2]={name="Chicken",spr=289,type=0},
  [3]={name="Cherries",spr=290,type=0},

  --TYPE 1 (Melee Weapons)
  [4]={name="Sword",spr=320,type=1,str=2,spd=2},
  [5]={name="Long Sword",spr=321,type=1,str=4,spd=1},
  [6]={name="Wood Mace",spr=322,type=1,str=1,spd=3},
  [7]={name="Scythe",spr=329,type=1,str=3,spd=5},

  --TYPE 2 (Tools)
  [8]={name="Pick Axe",spr=384,type=2,str=-4,spd=-5},
  [9]={name="Axe",spr=327,type=2},

  [10]={name="Stone",spr=416,type=3,stack=1},

  --Type 4 (RANGED MAGIC)
  [11]={name="Fire Staff",spr=336,type=4}
}


function Item:initialize(x,y,id)
  self.name=ITEM_IDS[id].name
  self.x=x
  self.y=y
  self.spr=ITEM_IDS[id].spr
  self.type=ITEM_IDS[id].type
  if self.type==1 or self.type==2 then
    self.str=ITEM_IDS[id].str
    self.spd=ITEM_IDS[id].spd or 0
  elseif self.type==3 then
    self.stack=1
  end

  table.insert(items,self)
end

function Item.static.updateAll()
  for i,v in pairs(items) do
    v:update()
  end
end

function Item:update()
  if lineofsight(p.x,p.y,self.x,self.y) and not solid(x,y) then
    --spr(self.spr,(self.x-mx)*8,(self.y-my)*8)
    pal()
  else
    darken()
  end
  spr(self.spr,(self.x-mx)*8,(self.y-my)*8)
  pal()
end

function Item:use(i)
  if self.type==0 then
    p.hunger=math.min(p.hunger+25,100)
    table.remove(p.inv,i)
    log("Ate: "..self.name)
  elseif self.type==1 or self.type==2 then
    p.lhand=p.inv[i]
    log(self.name.." equipped")
  elseif self.type==4 then
    InvActive=false
    CastActive=true
  end
end

function showKeys()
  for i=4,7 do
    local k=i-4
    local width=print(keys[i],0,-8)
    spr(252+i,2+(240/4*k),136-8)
    print(keys[i],2+(240/4*k)+10,136-7)
  end
end

function uibox(x,y,w,h)
  rect(x,y,w,h,0)
  rectb(x,y,w,h,15)
  circ(x,y,2.5,15)
  circ(x+w-1,y,2.5,15)
  circ(x,y+h-1,2.5,15)
  circ(x+w-1,y+h-1,2.5,15)
end

local licons={
  ATK=262,
  DEF=263,
  STR=264,
  MGK=265,
  RNG=266
}

function bar(x,y,w,h,v,max)
  rect(x,y,w,h,6)
  rect(x,y,w/max*v,h,11)
end

local menu_list={
  [0]={"Stats",function() StatsActive= not StatsActive end},
  {"Inv",function() InvActive= not InvActive end},
  {"Save",function() StatsActive= not StatsActive end},
  {"Log",function() StatsActive= not StatsActive end},
}

local menu_i=0

function Menu(list)
  local w=48
  local h=(#list+1)*8+5 --Use 0 based arrays
  local x=120-(w/2)
  local y=68-(h/2)

  uibox(x,y,w,h)
  for i,v in pairs(list) do
    local tw=print(v[1],0,-8)
    local ty=(i)*8+y+4
    local tc=15
    local bg=0
    if i==menu_i then tc=0 bg=15 end
    rect(x+4,ty-1,w-8,7,bg)
    print(v[1],x+(w/2)-(tw/2),ty,tc)
  end
  if btnp(0) then menu_i=menu_i-1
  elseif btnp(1) then menu_i=menu_i+1
  end
  if btnp(4) then list[menu_i][2]() MenuActive=not MenuActive end
  menu_i=menu_i%(#list+1)
end

function StatBox(label,xp,x,y)
  local w,h=78,28
  uibox(x-2,y-2,78,28)
  spr(licons[label],x-2,y,0,2)
  print(label,x+16,y)
  print(string.sub(xp2l(xp),1,5).." / 50",x+16,y+8)
  local lvl=math.floor(xp2l(xp))
  local xp2nxt=math.floor(l2xp(lvl+1))
  bar(x+2,y+15,70,8,xp-l2xp(lvl-1),xp2nxt)
  print(xp2nxt,x+4,y+16)
end

function Stats(x,y)
  StatBox("ATK",pmem(0),x,y)
  StatBox("DEF",pmem(1),x+78+6,y)
  StatBox("STR",pmem(2),x,y+28+6)
  StatBox("MGK",pmem(3),x+78+6,y+28+6)
  StatBox("RNG",pmem(4),x+(78+6)/2,y+56+12)
  if btnp(4) then StatsActive=not StatsActive end
end

function Inventory(x,y)
  local bx,by,bw,bh=x-4,y-4,4*16+8,4*16+8
  local lwidth=print("INVENTORY",0,-8)
  print("INVENTORY",bx+(bw/2)-(lwidth/2),by-6,15)
  uibox(bx,by,bw+1,bh)
  if btnp(3) then
    inv_i=math.min(inv_i+1,#p.inv)
  elseif btnp(2) then
    inv_i=math.max(inv_i-1,1)
  end
  local item

  --MAIN INV BOX
  for i,v in pairs(p.inv) do
    local dx=x+((i-1)%4*16)
    local dy=y+((i-1)//4*16)
    spr(v.spr,dx,dy,0,2)
    if v==p.lhand then
      printb("E",dx+10,dy+10,11)
    end
    if v.type==3 then
      printb(v.stack,dx+10,dy+10,15)
    end
    if i==inv_i then
      item=v
      rectb(dx-1,dy-1,19,19,15)
      if btnp(4) then v:use(i) end
    end
    --print(i,dx,dy,15)
  end

  --INFOBOX
  uibox(bx+88,by,bw,bh)
  line(bx+90+4,by+12,bx+90+bw-10,by+12,15)
  if item then
    local dx=bx+88
    local w=print(item.name,0,-8)
    print(item.name,dx+(bw/2)-(w/2),by+4,15)
    print(TYPES[item.type],dx+2,by+16)
    if item.type==1 then
    print("STR: "..item.str,dx+2,by+24)
    print("SPD: "..item.spd,dx+2,by+24+8)
    end
  end
end

function stat(icon,val,x,y)
  spr(icon,x,y)
  print(string.sub(val,1,3),x+10,y+1,15)
end

function uistats(x,y)
  stat(262,xp2l(pmem(0)),x,y)
  stat(263,xp2l(pmem(1)),x,y+8)
  stat(264,xp2l(pmem(2)),x+28,y)
  stat(265,xp2l(pmem(3)),x+28,y+8)
  stat(266,xp2l(pmem(4)),x+(28*2),y)
end

function GUI(x,y)
  --print("HP",x,y)
  --HP
  spr(260,0,0)
  rect(x+10,0,64,6,1)
  rect(x+10,0,64/100*p.hp,6,6)
  --HUNGER
  spr(261,0,8)
  rect(x+10,8,64,6,4)
  rect(x+10,8,64/100*p.hunger,6,9)

  --STATS
  uistats(x+75,y)
  draw_log()
  --print("HUNGER: "..p.hunger,x,8)
  if btnp(7) then InvActive=not InvActive end
  if btnp(6) then MenuActive=not MenuActive end
  if InvActive then
    Inventory(44,36)
  end
  if StatsActive then
    Stats(41,26)
  end
  if MenuActive then
    Menu(menu_list)
  end
end
function drawDMG()
  for i,v in pairs(dmg) do
    v.t=v.t+1
    v.y=v.y-.1
    if v.t>10 then table.remove(dmg,i) end
    printb(v.n,(v.x-mx)*8-4,(v.y-my)*8-4,6,0)
  end
end
function init()
  cellular_gen(0,0,30*7,17*7,200)
  dmg={}
  inv_i=1
  keys={
    [4]="",
    [5]="",
    [6]="",
    [7]="Inv"
  }
  seen={}
  seen[0]={}
  for y=1,136 do table.insert(seen,y,{}) end
  sync()
end

do                            --Early prototype stuff
  p=Player:new(222,127)
  for i=1,#ITEM_IDS do table.insert(p.inv,Item(0,0,i)) end
  Monster:new(29,17)
  Item:new(31,17,1)
  Item:new(33,17,2)
  for xp=0,5 do
    --pmem(xp,rand(50,10000))
  end
  --b=Button(16,16,"DROP",6)

  --invp:add(iButton(32,32,32,2))
end

init()
cls()
  mx=p.x-15
  my=p.y-8
function TIC()
  cls()
  for i,v in pairs(keys) do keys[i]="" end
  mx=lerp(mx,p.x-15,.1)
  my=lerp(my,p.y-8,.1)
  mox=p.x//30
  --cls()
  keys[7]="Inv"
  keys[6]="Menu"
  clip(0,16,240,136-8-16)
  map(0,0,240,136,(mx*-8)-1,(my*-8)-1,-1,1,function(tile,x,y)

    if x>p.x-20 and x<p.x+20 and y>p.y-18 and y<p.y+18 then
    if lineofsight(p.x,p.y,x,y) then 
      pal()
      seen[y][x]=true
    elseif seen[y][x] then
      --for i=1,15 do pal(i,1) end
      darken()
    else
      tile=80
    end 
    end
    return tile
  end
  )

  pal()
  Item:updateAll()
  Monster:updateAll()
  spr(p.spr,(p.x-mx)*8,(p.y-my)*8,12)
  if not InvActive and not StatsActive and not MenuActive then
    p:update()
  end
  clip()
  drawDMG()
  GUI(0,0)
  --draw_log()
  showKeys()
end

function lineofsight(x1,y1,x2,y2)
local deltax = math.abs(x2 - x1) -- // The difference between the x's
local deltay = math.abs(y2 - y1) -- // The difference between the y's
local x = x1; -- // Start x off at the first pixel
local y = y1; -- // Start y off at the first pixel
local xinc1,xinc2,yinc1,yinc2
if (x2 >= x1) then -- // The x-values are increasing
xinc1 = 1;
xinc2 = 1;
else -- // The x-values are decreasing
xinc1 = -1;
xinc2 = -1
end

if (y2 >= y1) then -- // The y-values are increasing
yinc1 = 1;
yinc2 = 1;
else -- // The y-values are decreasing
yinc1 = -1;
yinc2 = -1;
end
if (deltax >= deltay) then -- // There is at least one x-value for every y-value
xinc1 = 0; -- // Don't change the x when numerator >= denominator
yinc2 = 0; -- // Don't change the y for every iteration
den = deltax;
num = deltax / 2;
numadd = deltay;
numpixels = deltax; -- // There are more x-values than y-values
else -- // There is at least one y-value for every x-value
xinc2 = 0; -- // Don't change the x for every iteration
yinc1 = 0; -- // Don't change the y when numerator >= denominator
den = deltay;
num = deltay / 2;
numadd = deltax;
numpixels = deltay; -- // There are more y-values than x-values
end
local onemoreround = 0
local roundnum = 0
while (true) do
roundnum = roundnum + 1 --forces two distance sight
           --  // Draw the current pixel
if onemoreround == 1 and roundnum > 2 then return false end --this stuff is so it penetrates one round and doesnt stop on the first round
if (roundnum ~= 1) and solid(x,y) then onemoreround = 1 end --was return false
if x == x2 and y == y2 then return true end
num = num + numadd; --// Increase the numerator by the top of the fraction
if (num >= den) then -- // Check if numerator >= denominator
num = num - den; -- // Calculate the new numerator value
x = x +xinc1; -- // Change the x as appropriate
y = y+ yinc1; -- // Change the y as appropriate
end
x = x+xinc2; -- // Change the x as appropriate
y = y+yinc2; -- // Change the y as appropriate
end
end 

function checkforlosblock(x,y)
  return solid(x,y)
end