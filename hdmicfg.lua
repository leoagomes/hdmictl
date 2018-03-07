return {
	default_order = {
		"multi-s2",
		"solo"
	},
	["solo"] = {
		minimum = 1,
		main = "LVDS1",
		run_order = {"LVDS1", "HDMI1"},
		["HDMI1"] = {
			"--auto",
			"--off",
		},
		["LVDS1"] = {
			"--auto",
		}
	},
	["multi-s2"] = {
		minimum = 2,
		main = "LVDS1",
		run_order = {"LVDS1", "HDMI1"},
		["HDMI1"] = {
			"--auto",
			["left-of"] = "LVDS1",
		},
		["LVDS1"] = {
			pos = "1920x500",
		},
	}
}
