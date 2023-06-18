-- Display the intro story in a Star Wars format
function intro_story()
  local text = [[
  Ahmed was an experienced spelunker, having 
  explored countless caves in Arabia over 
  the years. One day, while exploring a new 
  area,  he stumbled upon a small cave 
  entrance that  he had never seen before. 
  He couldn't resist  the temptation to 
  explore it, so he carefully made 
  his way inside.

  As he ventured deeper into the cave, 
  Ahmed began to feel a sense of unease. 
  The walls seemed to be closing in on him, 
  and the air was getting thicker. 
  Suddenly, he heard a loud cracking noise, 
  and before he knew it, the ground beneath 
  him gave way, sending him tumbling 
  into a deep pit.

  When he came to, Ahmed realized that he 
  had fallen into a deep crevice and was 
  now trapped. He tried to climb out, 
  but the walls were too steep and slick 
  with moisture. The only way out was 
  to keep moving forward.

  With no other choice, Ahmed began to 
  explore the cave system in search of 
  a way out. The cave was dark and 
  winding, and he had to be careful not 
  to get lost or injured. He crawled 
  through tight spaces, squeezed through 
  narrow passages, and climbed over 
  jagged rocks, all the while keeping 
  his wits about him.

  Days turned into weeks, and Ahmed's 
  food and water supplies were 
  dwindling. He knew he had to find a 
  way out soon, or he would perish in 
  the depths of the cave. 
  ]]
  local t = time() / 80
  local q = t > 800 or cls() 
  local scroll_speed = 1
  local text_color = 4

  print(text, 0, 150 - t * scroll_speed, text_color)
end

function TIC()
  cls()

  -- Play the intro storyload
  intro_story()
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

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