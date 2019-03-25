-- orbit: loop collector
-- 1.0.0 @tehn
-- ...

local cs = require 'controlspec'

local state = {"stop","stop"}
local start_time = {0,0}
local loop_len = {0,0}
local edit = "rate"

function init()
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_ext_cut(1)
  for i=1,2 do
    softcut.level(i,0)
    softcut.level_slew_time(1,0.1)
    softcut.level_input_cut(1, i, 1.0)
    softcut.level_input_cut(2, i, 1.0)
    softcut.pan(1, 0.5)
    softcut.play(i, 1)
    softcut.rate(i, 1)
    softcut.rate_slew_time(1,0.1)
    softcut.loop_start(i, 1)
    softcut.loop_end(i, 91)
    softcut.loop(i, 1)
    softcut.fade_time(i, 0.1)
    softcut.rec(i, 1)
    softcut.rec_level(i, 0)
    softcut.pre_level(i, 1)
    softcut.position(i, 1)
    softcut.buffer(i,i)
    softcut.enable(i, 1)
    softcut.filter_dry(i, 0.125);
    softcut.filter_fc(i, 1200);
    softcut.filter_lp(i, 0);
    softcut.filter_bp(i, 1.0);
    softcut.filter_rq(i, 2.0);
  end

  params:add{type = "control", id = "1level", name = "1.level",
    controlspec = cs.new(0, 1, "lin", 0, 1, ""),
    action = function(x) softcut.level(1,x) end}
  params:add{type = "control", id = "2level", name = "2.level",
    controlspec = cs.new(0, 1, "lin", 0, 1, ""),
    action = function(x) softcut.level(2,x) end}
  params:add{type = "control", id = "1rate", name = "1.rate",
    controlspec = cs.new(-4, 4, "lin", 0, 1, ""),
    action = function(x) softcut.rate(1,x) end}
  params:add{type = "control", id = "2rate", name = "2.rate",
    controlspec = cs.new(-4, 4, "lin", 0, 1, ""),
    action = function(x) softcut.rate(2,x) end}
end

local function start(i)
  start_time[i] = util.time()
  --softcut.buffer_clear_region_channel(i,0,loop_len[i]+2)
  --softcut.buffer_clear_channel(i)
  softcut.level(i,0)
  params:set(i.."rate",1)
  softcut.loop_end(i, 91)
  softcut.position(i, 1)
  softcut.rec_level(i, 1)
  softcut.pre_level(i, 0)
  state[i] = "rec"
end

local function stop(i)
  loop_len[i] = util.time() - start_time[i]
  softcut.level(i,1)
  softcut.rec_level(i, 0)
  softcut.pre_level(i, 1)
  softcut.position(i, 1)
  softcut.loop_end(i, loop_len[i] + 1)
  state[i] = "play"
end

local function clear(i)
  softcut.level(i,0)
  softcut.buffer_clear_channel(i)
  state[i] = "stop"
end

function key(n,z)
  local i=n-1
  if n==1 then alt = z
  elseif n>1 and z==1 and state[i]~="rec" then
    start(i)
    redraw()
  elseif n>1 and z==1 and state[i]=="rec" then
    if alt==1 then
      clear(i)
    else
      stop(i)
      redraw()
    end
  end
end

function enc(n,delta)
  local i=n-1
  if n==1 then
    if delta < 0 then edit = "level"
    else edit = "rate" end
  else
    params:delta(i..edit,delta*(edit=="rate" and 0.1 or 2))
  end
  redraw()
end


function redraw()
	screen.clear()
  screen.level(edit=="level" and 15 or 2)
  screen.move(10,30)
  screen.text("level")
  screen.move(80,30)
  screen.text_right(params:string("1level"))
	screen.move(110,30)
  screen.text_right(params:string("2level"))

  screen.level(edit=="rate" and 15 or 2)
  screen.move(10,40)
  screen.text("rate")
  screen.move(80,40)
  screen.text_right(params:string("1rate"))
	screen.move(110,40)
  screen.text_right(params:string("2rate"))

  screen.level(15)
  screen.move(10,50)
  screen.text("state")
	screen.move(80,50)
	screen.text_right(state[1])
	screen.move(110,50)
	screen.text_right(state[2])

  screen.level(2)
  screen.move(10,60)
  screen.text("len")
	screen.move(80,60)
	screen.text_right(util.round(loop_len[1],0.01))
	screen.move(110,60)
	screen.text_right(util.round(loop_len[2],0.01))
	screen.update()
end

