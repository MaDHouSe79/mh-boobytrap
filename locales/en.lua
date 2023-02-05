local Translations = {
    help = {
        ['press_e_to_pickup'] = "[~r~E~w~] Place/Pickup Boobytrap",
        ['press_e_to_toggle'] = "[~r~G~w~] Enable/Disabel Boobytrap",
    },
    notify = {
        ['place_a_trap'] = "You have just placed a bobby trap!!",
        ['walk_in_to_trap'] = "%{username} just stepped into a bobby trap of yours!!",
        ['cant_place_trap'] = "you cannot place this booby trap here, make sure there is enough space",
        ['disable_trap'] = "This boobytrap is now disable",
        ['enable_trap'] = "This boobytrap is now activated",
    },
    progressbar = {
        ['place_trap'] = "Place Boobytrap...",
        ['pickup_trap'] = "Pickup Boobytrap...",
    },
    mail = {
        sender = "Anonymous",
        subject = "Big Explosion",
        message = "%{username} just stepped into a bobby trap of yours!!"
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
