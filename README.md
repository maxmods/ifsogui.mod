ifsogui.mod
===========

Marcus Trisdale's Ifso Max2D GUI module and form designer. 

Only a few changes were made to the module in v1.18, the form editor is much improved and examples now include a MaxGUI demo.

Depends on Maxmods/koriolis.zipstream because the internal zipstream wasn't 64-bit compatible. 

Extract ifsogui.mod to your BlitzMax/mod folder and build with bmk.

License
=======

This version uses the zlib license since the original had no license, just a copyright notice.

Notes
=====

The Skin2 folder can be incbin'd using incbinSkin.bmx (both found in the module folder). 

If you wonder what Skin3 does it's used by the editor toolbar. The editor currently can't incbin skins (crashes). 

There are random crashes at init when loading media from zip files, but incbin works fine.

The editor doesn't support multicolumn listboxes.

See the examples folder to get started, each gadget is well documented.

