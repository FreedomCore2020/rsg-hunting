local Translations = {
    error = {
        cant_use = 'you can\'t use that outside a hunting zone!',
    },
    success = {
        success_var = 'Example Text',
    },
    primary = {
        enter_hunting_zone = 'you have entered a hunting zone!',
        left_hunting_zone = 'you have left a hunting zone!',
        bait_set = 'bait has been set, hide!',
    },
    menu = {
        menu_var = 'Example Text',
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
