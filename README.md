# Hexagonal field 1.3.4 (Hexfield)
## By Stanislav Baranov / Spellweaver (spellsweaver@gmail.com)

This application is aimed on creating hexagonal field for a tabletop game, such as D&D, with some extra convenience features.
It is NOT a game by itself and most likely not going to be one. All changes to the environment are made solely by game master/player, not by application itself.

Functionality.
Hexfield allows user to freely observe 2d hexagonal field from any point of view, and rearrange it in several ways: coloring, changing textures, adding static objects such as trees, adding dynamic objects such as people.
In addition, static objects can be turned around (mostly useful for topdown objects such as walls), or dragged to a different tile.
Dynamic objects can not only be moved, but also recolored (in case you need two similar objects to be different), and have their condition ("health" and active effects) set.
A single tile can only contain one static and one dynamic object.
Since version 1.3.0 Hexfield allows save/load of maps.
Since version 1.3.1 Hexfield automatically saves your map on exit.
Since version 1.3.2 Hexfield allows hotkeys, supports all screen sizes and allows window resizing (it's recommended to keep window's height to at least 600).

Controls.
Controls are supposed to be intuitive but this list might be useful if you missed something.

Increase/decrease scale: mouse wheel
Change your point of view: drag hexagonal field with right mouse button
Changing texture/objects/color on the tile: left click the texture/object/color button to enable, left click on the tile
Moving static/dynamic object: click the hand button to enable, then drag an object with left mouse button. If there is another object where you move it, they'll swap.
Deleting object: click on "cross" button or choose "blank" object to enable, then left click on the tile.
Turning static object around: right/left click on "rotate" button before placing object.
Recoloring dynamic object: left click on "brush" button to enable, left click on object to recolor. Transparency has no effect on this coloring, except 100% transparent color is interpreted as white.
Setting dynamic object condition: left click on "heart" button to enable, left click on tile to enter submenu. Set health by left clicking on the health bar, enable/disable effects by left clicking on them. Both health and effects are displayed on the field.
Change color/object/texture selected: right click on the according button, then click on the preferred object/texture to enter submenu, or set the color with r/g/b/alpha sliders. You can scroll through all lists using mouse wheel or arrow keys on keyboars.
Quit the application or go back to field from submenu: "Esc" button on keyboard.
Save/load your map: click on "floppy" button to save or "map" button to load. Then choose the file from list (choosing the "floppy" creates a new one).
Options: button at the top left of the screen allows you to adjust some parameters.
When you create a new file, you're required to enter its name first. To delete a file, click red "Delete" button that's to the bottom right of the dialogue screen.

Hotkeys.
Ctrl + S - opens save panel.
Ctrl + Shift + S - overwrites the last file map was loaded from/saved to. Still asks for confirmation.
Ctrl + N - clears the map, saving it into "autosave.hxm" beforehand
Ctrl + O - opens load panel.
Ctrl + Shift + O - opens the directory containing saved maps in your file browser.
Ctrl + Z - cancels the last change to map.

You can distribute this application freely as long as you give credit to creator.

# States library
Since the last update, this project also contains a completely independant states library for love2d.
You can use and/or modify it freely.
