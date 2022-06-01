from solid import *
from solid.utils import * 

default_height=30

x = 100
y = 200
z = 30

divider_spacing_y = 200
divider_spacing_x = 200

corner_radius = 2
corner_radius_segments = 24

wall_thickness = 0.9
floor_thickness = 0.68

labels = True
label_w = 20
label_h = 6

fn = 64

def corners(x1,y1):
    r = corner_radius
    
    return translate([r, r])(circle(r=r, segments=corner_radius_segments)) \
     + translate([r, x1-r])(circle(r=r, segments=corner_radius_segments)) \
    + translate([y1-r, x1-r])(circle(r=r, segments=corner_radius_segments)) \
    + translate([y1-r, r])(circle(r=r, segments=corner_radius_segments)) \

def frame():
    inner_space = linear_extrude(z)(hull()(corners(x-wall_thickness*2, y-wall_thickness*2)))
    hole = translate([wall_thickness, wall_thickness, floor_thickness])(inner_space)
    return linear_extrude(z)(hull()(corners(x,y))) - hole

def label():


    diagonal = sqrt(pow(label_h,2) / 2)
    label_block = translate([wall_thickness-diagonal,(x-label_w)/2,z-diagonal])(
            rotate([0,45,0])(
                cube([label_h,label_w,label_h])
            ))

    cutout = translate([-label_h+0.1,(x-label_w)/2 - 1,z-label_h*2])(
            rotate([0,0,0])(
                cube([label_h,label_w + 2,label_h*2])
            ))
    return label_block-cutout

def create_labels():
    if not labels:
        return union()
    label_objs = union()
    for div_y in range(0, y, divider_spacing_y):
        for div_x in range(0, x - label_w, divider_spacing_x):
            label_objs += translate([div_y,-x/2 + divider_spacing_x/2 + div_x,0])(label())
    return label_objs


def dividers(h):
    dividers = union()
    for  div_y in range(divider_spacing_y, y-divider_spacing_y+1, divider_spacing_y):
        dividers += translate([div_y,wall_thickness,0])(divider_y(h))

    for div_x in range(divider_spacing_x, x-divider_spacing_x+1, divider_spacing_x):
        dividers += translate([wall_thickness,div_x,0])(divider_x(h))
    
    return dividers

def divider_y(h=z):
    l = x-wall_thickness
    return translate([0,-wall_thickness/2,wall_thickness])(cube([wall_thickness,l,h-wall_thickness]))


def divider_x(h=z):
    l = y-wall_thickness
    return translate([-wall_thickness/2,0,wall_thickness])(cube([l, wall_thickness,h-wall_thickness]))


def box():
    return frame() + create_labels() + dividers(z)

obj = box()

scad_render_to_file(obj, 'divider_box_generated.scad')




