from os.path import basename

app = defines["app"]
app_name = basename(app)

files = [app]
symlinks = {"Applications": "/Applications"}

format = "UDZO"
background = "builtin-arrow"
window_rect = ((160, 170), (640, 280))
icon_size = 112
text_size = 14
icon_locations = {app_name: (155, 116), "Applications": (485, 116)}
