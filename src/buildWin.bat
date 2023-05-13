mkdir build

wsl bash luacc.sh

set gamename=Suqut

tic80.exe --fs . --cli --cmd="load game.lua & export win build/%gamename%-%1.exe alone=1 & exit"

copy "game.lua" "build\%gamename%-%1.lua"