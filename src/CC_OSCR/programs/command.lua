local w, h = term.getSize()

term.clear()
utils.setDefaultColors()

utils.placeTextAtLocation(
    term.current(),
    "COMMAND LINE TERMINAL",
    "tc",
    false
)

term.setTextColor(colors.gray)
utils.placeTextAtLocation(
    term.current(),
    "Use commands and stuff...",
    "tc",
    false,
    "",
    "",
    0,
    1
)

utils.placeTextAtLocation(
    term.current(),
    string.rep("~", w),
    "tc",
    false,
    "",
    "",
    0,
    2
)

term.setCursorPos(1,4)

