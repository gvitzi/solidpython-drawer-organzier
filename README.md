# Modular Drawer Organizer Boxes

This script allows to generate OpenSCAD .scad files for a completely modular small items boxes / drawer organizer boxes

Available on Cults3d:
https://cults3d.com/en/3d-model/tool/modular-drawer-organizer-boxes-openscad

## Install Solid Python

```
pip install solidpython
```

Then run the script using these examples:

## Examples

Box of 100x100x50 mm (WxLxH) with 2 columns and 3 rows
```
python .\divider_box.py --size 100x100x50 -l 2x3
```


Box of 200x105 mm (WxL) height 30mm without inner dividers, with no labels and rounded corners
```
python .\divider_box.py --size 200x105 -l 1x1 --no-labels --corner-radius 5
```

Box of 150x150 mm with larger labels
```
python .\divider_box.py --size 150x150 -l 2x1 --label-size 50x10
```