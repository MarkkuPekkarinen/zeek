zeek_add_plugin(
    Zeek HTTP
    SOURCES HTTP.cc Plugin.cc
    BIFS events.bif functions.bif)
