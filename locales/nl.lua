local Translations = {
    help = {
        ['press_e_to_pickup'] = "[~r~E~w~] Pakken/Plaatsen",
        ['press_e_to_toggle'] = "[~r~G~w~] Aan/Uit schakkelen",
    },
    notify = {
        ['place_a_trap'] = "Je hebt zojuist een bobbytrap geplaatst!!",
        ['walk_in_to_trap'] = "%{username} is zojuist in een bobbytrap van jou gestapt!!",
        ['cant_place_trap'] = "je kan deze boobytrap hier niet plaatsen, zorg voor genoeg ruimte",
        ['disable_trap'] = "Deze boobytrap is nu uitgeschakeld",
        ['enable_trap'] = "Deze boobytrap is nu geactiveerd",
    },
    progressbar = {
        ['place_trap'] = "Boobytrap plaatsen...",
        ['pickup_trap'] = "Boobytrap pakken...",
    },
    mail = {
        sender = "Anoniem",
        subject = "Grote Explosie",
        message = "%{username} is zojuist in een bobbytrap van jou gestapt!!",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})