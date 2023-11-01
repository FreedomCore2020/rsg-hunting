Config = {}

-- settings
Config.SpawnDistanceRadius = 30 -- the distance the animal spawns away from the bait 
Config.HideTime = 10000 -- the amount of time in miliseconds that you have to hide before animal aproaches the bait
Config.AnimalWait = 10000 -- the amount of time in miliseconds that the animal will wait at the bait until freeroam
Config.LegendaryChance = 7

Config.HuntingZones = {
    {
		name       = 'huntingzone1',
		coords     = vector3(-34.51852, 1218.3901, 172.80981),
		radius     = 100.0, 
		showblip   = true,
        blipName   = 'Hunting Zone',
        blipSprite = `blip_mp_deliver_target`,
        blipScale  = 0.2
	},
}

Config.HerbivoreBait = {
	`a_c_armadillo_01`,
	`a_c_badger_01`,
	`a_c_bighornram_01`,
	`a_c_buck_01`,
	`a_c_deer_01`,
	`a_c_elk_01`,
	`a_c_buffalo_01`,
	
}

Config.PotentHerbivoreBait = {
	`a_c_armadillo_01`,
	`a_c_badger_01`,
	`a_c_bighornram_01`,
	`a_c_buck_01`,
	`a_c_deer_01`,
	`a_c_elk_01`,
	`a_c_buffalo_01`,
}

Config.LegendaryHerbivore = {
	-- legendary
	`mp_a_c_beaver_01`,
	`mp_a_c_buffalo_01`,
	`mp_a_c_bighornram_01`,
}

Config.PredatorBait = {
	`a_c_bearblack_01`,
	`a_c_bear_01`,
	`a_c_cougar_01`,
	`a_c_coyote_01`,
	`a_c_fox_01`,
	`a_c_lionmangy_01`,
	`a_c_wolf`,
}

Config.PotentPredatorBait = {
	`a_c_bearblack_01`,
	`a_c_bear_01`,
	`a_c_cougar_01`,
	`a_c_coyote_01`,
	`a_c_fox_01`,
	`a_c_lionmangy_01`,
	`a_c_wolf`,
}

Config.LegendaryPredator = {
	-- legendary
	`mp_a_c_boar_01`,
	`mp_a_c_cougar_01`,
	`mp_a_c_coyote_01`,
	`mp_a_c_panther_01`,
	`mp_a_c_wolf_01`,
	`mp_a_c_alligator_01`,
	`mp_a_c_fox_01`
}
