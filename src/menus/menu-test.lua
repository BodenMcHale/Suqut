-- title:  game manager demo
-- author: RayTro
-- desc:   Game manager with a simple pong game as demo
-- script: lua


function em_init()
    merge = function (t1, t2)
        for k, v in pairs(t2) do
            if (type(v) == "table") and (type(t1[k] or false) == "table") then
                merge(t1[k], t2[k])
            else
                t1[k] = v
            end
        end
        return t1
    end
    _G["em"] = {
        sprites = {},
        entities = {},
        const = {
            UP = 1,
            DOWN = 2,
            LEFT = 4,
            RIGHT = 8,
        },

        newSprite = function (id, index, colorkey, scale, flip, rotate, w, h)
            em.sprites[id] = {index=index, colorkey=colorkey, scale=scale, flip=flip, rotate=rotate, w=w,h=h}
            return em.sprites[id]
        end,
        getSprite = function(id)
            return em.sprites[id]
        end,
        hasSprite = function (id)
            return type(em.sprites[id] == "table")
        end,
        removeSprite = function(id)
            em.sprites[id] = nil
        end,
        newEntity = function (id, spr_id, x, y, func_move, add_attr)
            em.entities[id] = {spr_id=spr_id, x=x, y=y, move=func_move}
            if (type(add_attr) == "table") then merge(em.entities[id], add_attr) end
            return em.entities[id]
        end,
        getEntity = function (id)
            return em.entities[id]
        end,
        hasEntity = function (id)
            return type(em.entities[id]) == "table"
        end,
        removeEntity = function (id)
            em.entities[id] = nil
        end,
        checkColision = function(e1, e2)
            box1 = em.getBox(e1)
            box2 = em.getBox(e2)
            w = (box1.w+box2.w)/2
            h = (box1.h+box2.h)/2
            dx = box1.cx-box2.cx
            dy = box1.cy-box2.cy

            colision = math.abs(dx) <= w and math.abs(dy) <= h
            side = 0
            
            if colision then
                wy = w * dy
                hx = h * dx
                if wy > hx then
                    if wy > -hx then 
                        side = em.const.UP
                    else
                        side = em.const.LEFT
                    end
                else
                    if wy > -hx then 
                        side = em.const.RIGHT
                    else
                        side = em.const.DOWN
                    end
                end
            end
            
            return {colision=colision, side=side}
        end,
        getBox = function(e)
            if type(e) ~= "table" then
                e = em.getEntity(e)
            end
            s = em.getSprite(e.spr_id)
            width = s.w*8*s.scale
            height = s.h*8*s.scale
            return {x1=e.x, y1=e.y, x2=e.x+width, y2=e.y+height, w=width, h=height, cx=e.x+width/2, cy=e.y+height/2}
        end,
        nextMove = function()
            for id, e in pairs(em.entities) do
                if type(e.move) == "function" then
                    e.move(em.entities[id])
                end
            end
        end,
        draw = function(e)
            if type(e) ~= "table" then
                if type(e) == "nil" then
                    for id, e in pairs(em.entities) do
                        em.draw(e)
                    end
                    return
                else
                    e = em.getEntity(e)
                end
            end
            s = em.sprites[e.spr_id]
            spr(s.index, e.x, e.y, s.colorkey, s.scale, s.flip, s.rotate, s.w, s.h)
        end
        -- debug functions, remove them if you distribute
        ,debug = {
            drawBox = function(box)
                if type(box) ~= "table" then
                    if type(box) == "nil" then
                        for id, e in pairs(em.entities) do
                            em.debug.drawBox(e)
                        end
                        return
                    else
                        box = em.getBox(em.getEntity(box))
                    end
                else
                    if(type(box.spr_id) ~= "nil") then
                        box = em.getBox(box)
                    end
                end
                line(box.x1,box.y1,box.x2,box.y1,6)
                line(box.x2,box.y1,box.x2,box.y2,6)
                line(box.x2,box.y2,box.x1,box.y2,6)
                line(box.x1,box.y2,box.x1,box.y1,6)
            end
        }
    }
end

function gm_init(default_state)
    em_init()
    _G["gm"] = {
        currentState = default_state,
        menus = {},
        states = {},
        newMenu = function(name, config, items, back, func_onChange, func_submit)
            if type(func_onChange) ~= "function" then func_onChange = function() end end
            if type(func_submit) ~= "function" then func_submit = function() end end
            gm.menus[name] = {
                config=config,
                items=items,
                selected=1,
                change = func_onChange,
                submit = func_submit,
                back = back
            }
            number = 0
            x = config.location.x
            y = config.location.y
            max = 0
            for key,item in pairs(items) do
                max = max + 1
                gm.menus[name].items[key].x = x
                gm.menus[name].items[key].y = y
                if config.location.mode == "v" then
                    y = y + 10
                end
            end
            gm.menus[name].max = max
        end,
        menu = function (name)
            if type(gm.menus[name]) == "nil" then
                trace("Unknown menu : '"..name.."'",6)
                exit()
            else
                m = gm.menus[name]
                for key,item in pairs(m.items) do
                    indent = 0
                    if key == m.selected then
                        if m.config.type == "color" then
                            color = m.config.selection
                        elseif m.config.type == "sprite" then
                            s = em.getSprite(m.config.selection)
                            if not em.hasEntity("gm_menu_"..m.config.selection) then
                                em.newEntity("gm_menu_"..m.config.selection, m.config.selection, m.items[m.selected].x,m.items[m.selected].y)
                            end
                            e = em.getEntity("gm_menu_"..m.config.selection)
                            box = em.getBox(e)
                            e.y = m.items[m.selected].y - 1
                            e.x = m.items[m.selected].x - box.w-1
                            em.draw(e)
                        elseif m.config.type == "indent" then
                            indent = m.config.selection
                        end
                    else
                        color = m.config.color
                    end
                    print(item.label, item.x + indent, item.y, color)
                end
                oldSelect = m.selected
                if (btnp(0) or btnp(2)) and m.selected > 1 then m.selected = m.selected-1 end
                if (btnp(1) or btnp(3)) and m.selected < m.max then m.selected = m.selected+1 end
                if oldSelect ~= m.selected then m.change() end
                if btnp(4) then 
                    m.submit()
                    if m.config.type == "sprite" then
                        em.removeEntity("gm_menu_"..m.config.selection)
                    end
                    act = m.items[m.selected].action
                    if type(act) == "function" then
                        act()
                    else
                        gm.currentState = act
                    end
                end
                if btnp(5) then
                    if type(m.back) == "function" then
                        m.back()
                    elseif type(m.back) ~= "nil" then
                        gm.currentState = m.back
                    end
                    if m.config.type == "sprite" then
                        em.removeEntity("gm_menu_"..m.config.selection)
                    end
                end
            end
        end,
        resetMenu = function(name)
            gm.menus[name].selected = 1
        end,
        newState = function(state_name, func)
            gm.states[state_name] = func
        end,
        run = function ()
            if type(gm.states[gm.currentState]) == "nil" then
                trace("Unknown game state : '"..gm.currentState.."'",6)
                exit()
            else
                gm.states[gm.currentState]()
            end
        end
    } 
end

-- movements functions

function player_move(e)
    -- we define the buttons
    up = 0
    down = 1
    left = 2
    right = 3
    if e.p==2 then
        -- and if this is the second player, we adds 8 for checking the P2's gamepad
        up = up + 8
        down = down + 8
        left = left + 8
        right = right + 8
    end
    -- the movement of the bars need some accelerations
    if btn(up) then e.vy = e.vy-1
    elseif btn(down) then e.vy = e.vy+1
    else
        -- and if the player is not moving, the bar isn't stopped immediately
        if math.abs(e.vy) < 1 then
            e.vy = 0
        end
        if e.vy > 0 then
            e.vy = e.vy-1
        elseif e.vy < 0 then
            e.vy = e.vy+1
        end
    end
    player_colision(e)
end

function com_move(e)
    -- here's the AI : basically we move the bar until we are on the same Y position than the ball.
    decision = 0
    ballbox = em.getBox("ball")
    box = em.getBox(e)
    if ballbox.cy > box.cy then decision = 2
    elseif ballbox.cy < box.cy then decision = 1
    end
    if decision == 1 then e.vy = e.vy-1
    elseif decision == 2 then e.vy = e.vy+1
    else
        if math.abs(e.vy) < 1 then
            e.vy = 0
        end
        if e.vy > 0 then
            e.vy = e.vy-1
        elseif e.vy < 0 then
            e.vy = e.vy+1
        end
    end
    player_colision(e)
end

function ball_move(e)
    -- we manage the colision between the two players
    ball_colision(e, "player1")
    ball_colision(e, "player2")
    -- then we manage the bounce on top and bottom of the screen
    box = em.getBox(e)
    if box.y1 <= 1 or box.y2 >= 136 then
        e.vy= -e.vy
    end
    -- then we update the ball position (it's a simple vector addition)
    e.x = e.x+e.vx
    e.y = e.y+e.vy
    -- and if we are on left or right of the screen, the opposite player won
    if e.x < 0 then
        game_score("player2")
    elseif e.x > 240 then
        game_score("player1")
    end
end

-- colision functions

function player_colision(e)
    -- the maximum speed of the bars is 3px/tick
    if e.vy > 3 then
        e.vy = 3
    elseif e.vy < -3 then
        e.vy = -3
    end

    -- we use the em's colision function between the player and the ball
    col = em.checkColision(e, "ball")

    -- in function of the side, we stop the bar so the ball is not locked inside the player
    -- also, if the player is on top or bottom of the screen, he'll be stopped too
    e.y= e.y+e.vy
    box = em.getBox(e)
    if box.y1 <= 1 or box.y2 >= 136 or (e.vy > 0 and col.side == em.const.DOWN) or (e.vy < 0 and col.side == em.const.UP) then
        e.y= e.y-e.vy
        e.vy = 0
    end
end

function ball_colision(e, target)
    col = em.checkColision(e, target)
    -- we manage the colision of the ball in function of the side
    if col.colision then
        if col.side >= 8 then --right
            e.vx = math.abs(e.vx) + 0.1
            col.side = col.side - 8
        end
        if col.side >= 4 then --left
            e.vx = -math.abs(e.vx) - 0.1
            col.side = col.side - 4
        end
        if col.side >= 2 then --down
            e.vy = -math.abs(e.vy) - 0.1
            col.side = col.side - 2
        end
        if col.side >= 1 then --up
            e.vy = math.abs(e.vy) + 0.1
        end
        -- the ball will take the speed of the player he just touched
        -- but the ball's vertical speed cannot go faster than 4px/tick
        e.vy = e.vy + em.getEntity(target).vy
        if e.vy > 4 then
            e.vy = 4
        elseif e.vy < -4 then
            e.vy = -4
        end
    end
end

-- game functions

function game_score(e)
    -- updating scores and placing players in their base position
    gm.currentState = "prepare"
    em.getEntity(e).score = em.getEntity(e).score + 1
    p1 = em.getEntity("player1")
    p1.y = 59
    p1.vy = 0
    p2 = em.getEntity("player2")
    p2.y = 59
    p2.vy = 0
end

function game_title()
    -- we display a giant "PONG" and two menus (it's a trick, see init for more details)
    print("PONG", 5,5,15,false,5)
    gm.menu("title_spr")
    gm.menu("title")
    if waitTime ~= 0 then waitTime = 0 end
end

function game_prepare1P()
    -- the player 2 is an AI, so we change his move function
    em.getEntity("player2").move = com_move
    game_prepare()
end

function game_prepare2P()
    -- the player 2 is an human, so we change his move function
    em.getEntity("player2").move = player_move
    game_prepare()
end

function game_prepare()
    -- we prepare the game, and display the scores
    if em.hasEntity("ball") then em.removeEntity("ball") end
    line(0,0,240,0,15)
    line(0,135,240,135,15)
    em.draw()
    print(em.getEntity("player1").score,20,3,15,false,3)
    print(em.getEntity("player2").score,204,3,15,false,3)
    game_start()
end

function game_start()
    -- we wait 3 seconds before starting the game
    if(waitTime >= 180) then
        waitTime = 0
        math.randomseed(time())
        gm.currentState = "game"
        p1 = em.getEntity("player1")
        p2 = em.getEntity("player2")
        dir = p1.score>p2.score and 1 or 0
        if dir == 0 then dir = -1 end
        em.newEntity("ball", "ball", 120, 63.5, ball_move, {vx=dir,vy=math.random()*2-1})
    else
        -- while waiting, we display a countdown 
        -- and when the player want to quit he just have to press B
        waitTime = waitTime + 1
        print(math.ceil((180-waitTime)/60), 112,67,14,false,3)
        print("B : Titlescreen", 75, 90,15)
        if btn(5) then gm.currentState = "title" end
    end
end

function play()
    -- main function of the game, we display the arena 
    -- (two lines at the top and bottom of the screen)
    line(0,0,240,0,15)
    line(0,135,240,135,15)
    -- the entity manager have a function to manage the movement of every entities
    em.nextMove()
    -- he also have a function to draw all entities on the screen.
    em.draw()
end

-- init

function init()
    cls()
    gm_init("title")

    -- menu definition
    -- Menu items has an 'action' parameter, that can be a function, or a string.
    -- When the parameter is a string, the selection of this item will switch the game state.
    gm.newMenu("title", {type="color", color=15, selection=14,location={mode="v",x=10,y=50}}, {
        {label="1P Game", action="prepare1P"},
        {label="2P Game", action="prepare2P"},
        {label="Quit", action=exit}
    })
    -- this second menu is a trick to display two visual effects : 
    -- the text is colored by the first menu and this second menu display a sprite
    gm.newMenu("title_spr", {type="sprite", color=15, selection="ball",location={mode="v",x=10,y=50}}, {
        {label="", action="prepare1P"},
        {label="", action="prepare2P"},
        {label="", action=exit}
    })

    -- game states definition
    -- every state has a function that the game manager will run.
    gm.newState("title", game_title)
    gm.newState("prepare1P", game_prepare1P)
    gm.newState("prepare2P", game_prepare2P)
    gm.newState("prepare", game_prepare)
    gm.newState("game", play)

    -- sprites definition
    em.newSprite("bar", 1, 0, 1, 0, 0, 1, 3)
    em.newSprite("ball", 2, 0, 1,0,0,1,1)

    -- entities definition
    -- entities can have a function for movement, and additional custom parameters.
    em.newEntity("player1", "bar", 5,59, player_move, {p=1,vy=0, score=0})
    em.newEntity("player2", "bar", 230,59,player_move, {p=2,vy=0, score=0})
end

init()

function TIC()
    cls()
    -- the game manager automatically switches between states when needed.
    -- this function manage everything you have defined in it.
    gm.run()
end
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
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

