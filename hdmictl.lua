#!/usr/bin/env lua

xrandr = "xrandr "
homedir = os.getenv("HOME") or "."
mode_filename = homedir .. "/.hdmimode"

function list_monitors()
	local lmp, md, ml, ret
	ret = {}

	lmp = io.popen(xrandr)

	for l in lmp:lines() do
		local name, state = l:match("%s*(%w+)%s(d?i?s?connected)%s*")

		if name ~= nil and state ~=nil and state ~= 'disconnected' then
			table.insert(ret, name)
		end
	end

	ret.count = #ret

	ret.has = table_has_monitor
	return ret
end

function table_has_monitor(self, mon)
	for k,v in ipairs(self) do
		if k == mon then
			return true
		end
	end

	for k,v in pairs(self) do
		if v == mon then
			return true
		end
	end

	return false
end

function run_monitor_config(name, params)
	local command_string = xrandr .. "--output " .. name

	for k,v in pairs(params) do
		if type(k) ~= 'number' then
			command_string = command_string .. " --" .. k .. " " .. v
		end
	end

	for i,v in ipairs(params) do
		command_string = command_string .. " " .. v
	end
	print(command_string)
	os.execute(command_string)
end

function change_mode(modename)
	local params

	params = cfg[modename]

	if params == nil or type(params) ~= 'table' then
		return
	end

	for i,v in ipairs(params.run_order) do
		run_monitor_config(v, params[v])
	end
end

function auto_setup()
	local mt, modes

	mt = list_monitors()
	modes = cfg.default_order

	for i,modename in ipairs(modes) do
		print("testing " .. modename)
		print("count " .. mt.count .. " minimum: " .. cfg[modename].minimum)
		if modename ~= 'default_order' and
			cfg[modename].minimum <= mt.count then
			change_mode(modename)
			set_current_mode(modename)
			return true
		end
	end

	return false
end

function load_cfg(fname) -- TODO: sandbox environment	local chunk, cfg

	chunk = loadfile(fname)
	cfg = chunk()

	return cfg
end

function get_current_mode()
	local mf = io.open(mode_filename)
	local md = mf:read('a')
	mf:close()

	local current_mode = mf:match('%s*current_mode%s*=%s*(%S+)')

	if current_mode == 'nil' then
		current_mode = nil
	end

	return current_mode
end

function set_current_mode(modename)
	local mf = io.open(mode_filename, 'w+')
	mf:write("current_mode = ", modename)
	mf:close()
end

function main()
	local command, config_fname
	command = arg[1]
	config_fname = arg[2]

	if config_fname == nil then
		print("no config file passed, loading default")
		config_fname = homedir .. "/.hdmicfg.lua"
	end

	if command == nil then
		print("no command given")
		return
	end

	cfg = load_cfg(config_fname)

	if command == "auto" then
		auto_setup()
	elseif command == "mode?" then
		print(get_current_mode())
	elseif command == "cycle" then
		mode_cycle()
	else
		change_mode(command)
		set_current_mode(command)
	end
end

main()
