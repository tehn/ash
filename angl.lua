-- angl: arc grains
-- @tehn, engine: glut @artfwo
--
-- load files via param menu
--
-- K3 to switch modes:
-- -- SPEED
--  K2 then touch arc to
--    set speed to zero
-- -- PITCH
--  K2 sets fine control

engine.name = 'Glut'

tau = math.pi * 2
VOICES = 4
positions = {-1,-1,-1,-1}
modes = {"speed", "pitch"}
mode = 1
hold = false

REFRESH_RATE = 0.03


key = function(n,z)
  if n==2 then hold = z==1 and true or false
  elseif n==3 and z==1 then mode = mode==1 and 2 or 1 end
  redraw()
end

a = arc.connect()

a.delta = function(n,d)
  if mode==1 then
    if hold == true then
      params:set(n.."speed",0) 
    else
      params:delta(n.."speed",d/10)
    end
  else
    if hold == true then
      params:delta(n.."pitch",d/20) 
    else
      params:delta(n.."pitch",d/2)
    end
  end
end

arc_redraw = function()
  a:all(0)
  if mode == 1 then
    for v=1,VOICES do
      a:segment(v,positions[v]*tau,tau*positions[v]+0.2,15)
    end
  else
    for v=1,VOICES do
      local pitch = params:get(v.."pitch") / 10
      if pitch > 0 then
        a:segment(v,0.5,0.5+pitch,15)
      else
        a:segment(v,pitch-0.5,-0.5,15)
      end

    end
  end
  a:refresh()
end

re = metro.init()
re.time = REFRESH_RATE
re.event = function()
  arc_redraw()
end
re:start()




function init()
  -- polls
  for v = 1, VOICES do
    local phase_poll = poll.set('phase_' .. v, function(pos) positions[v] = pos end)
    phase_poll.time = REFRESH_RATE
    phase_poll:start()
  end

  local sep = ": "

  params:add_taper("reverb_mix", "*"..sep.."mix", 0, 100, 50, 0, "%")
  params:set_action("reverb_mix", function(value) engine.reverb_mix(value / 100) end)

  params:add_taper("reverb_room", "*"..sep.."room", 0, 100, 50, 0, "%")
  params:set_action("reverb_room", function(value) engine.reverb_room(value / 100) end)

  params:add_taper("reverb_damp", "*"..sep.."damp", 0, 100, 50, 0, "%")
  params:set_action("reverb_damp", function(value) engine.reverb_damp(value / 100) end)

  for v = 1, VOICES do
    params:add_separator()

    params:add_file(v.."sample", v..sep.."sample")
    params:set_action(v.."sample", function(file) engine.read(v, file) end)

    params:add_option(v.."play", v..sep.."play", {"off","on"}, 2)
    params:set_action(v.."play", function(x) engine.gate(v, x-1) end)

    params:add_taper(v.."volume", v..sep.."volume", -60, 20, 0, 0, "dB")
    params:set_action(v.."volume", function(value) engine.volume(v, math.pow(10, value / 20)) end)

    params:add_taper(v.."speed", v..sep.."speed", -200, 200, 100, 0, "%")
    params:set_action(v.."speed", function(value) engine.speed(v, value / 100) end)

    params:add_taper(v.."jitter", v..sep.."jitter", 0, 500, 0, 5, "ms")
    params:set_action(v.."jitter", function(value) engine.jitter(v, value / 1000) end)

    params:add_taper(v.."size", v..sep.."size", 1, 500, 100, 5, "ms")
    params:set_action(v.."size", function(value) engine.size(v, value / 1000) end)

    params:add_taper(v.."density", v..sep.."density", 0, 512, 20, 6, "hz")
    params:set_action(v.."density", function(value) engine.density(v, value) end)

    params:add_taper(v.."pitch", v..sep.."pitch", -24, 24, 0, 0, "st")
    params:set_action(v.."pitch", function(value) engine.pitch(v, math.pow(0.5, -value / 12)) end)

    params:add_taper(v.."spread", v..sep.."spread", 0, 100, 0, 0, "%")
    params:set_action(v.."spread", function(value) engine.spread(v, value / 100) end)

    params:add_taper(v.."fade", v..sep.."att / dec", 1, 9000, 1000, 3, "ms")
    params:set_action(v.."fade", function(value) engine.envscale(v, value / 1000) end)
  end

  params:bang()
end


function redraw()
  screen.clear()
  screen.move(64,40)
  screen.level(hold==true and 4 or 15)
  screen.font_face(10)
  screen.font_size(20)
  screen.text_center(modes[mode])
  screen.update()
end
