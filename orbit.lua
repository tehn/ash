-- orbit: loop collector
-- 1.0.0 @tehn
-- ...

local rec = {false,false}
local start_time = {0,0}
local loop_len = {0,0}

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

end

function key(n,z)
  local i=n-1
	if n>1 and z==1 and rec[i]==false then
		start_time[i] = util.time()
    softcut.buffer_clear_region_channel(i,0,loop_len[i]+2)
    softcut.level(i,0)
		softcut.position(i, 1)
		softcut.rec_level(i, 1)
		softcut.pre_level(i, 0)
		rec[i] = true
		redraw()
	elseif n>1 and z==1 and rec[i]==true then
		loop_len[i] = util.time() - start_time[i]
    softcut.level(i,1)
		softcut.rec_level(i, 0)
		softcut.pre_level(i, 1)
		softcut.position(i, 1)
		softcut.loop_end(i, loop_len[i] + 1)
		rec[i] = false
		redraw()
	end
end

function redraw()
	screen.clear()
	screen.move(32,48)
	screen.text_center(rec[1] and "play" or "rec")
	screen.move(32,56)
	screen.text_center(util.round(loop_len[1],0.01))
	screen.move(96,48)
	screen.text_center(rec[2] and "play" or "rec")
	screen.move(96,56)
	screen.text_center(util.round(loop_len[2],0.01))
	screen.update()
end


		
