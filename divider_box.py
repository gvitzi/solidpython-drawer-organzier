from solid import *
from solid.utils import * 
import sys

default_height=30

x = 200
y = 200
z = 30

divider_spacing_y = 100
divider_spacing_x = 50

corner_radius = 1
corner_radius_segments = 24

wall_thickness = 0.9
floor_thickness = 0.68

add_labels = True
label_w = 20
label_h = 6

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
    if not add_labels:
        return union()
    label_objs = union()
    for div_y in range(0, y-divider_spacing_y+1, divider_spacing_y):
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
    # we add 0.1 to the height and lower the divider -0.1 into the floor
    # This is to prevent the divider from disconnecting from the floor after the print is ready
    return translate([0,-wall_thickness/2,wall_thickness-0.1])(cube([wall_thickness,l,h+0.1-wall_thickness]))


def divider_x(h=z):
    l = y-wall_thickness
    return translate([-wall_thickness/2,0,wall_thickness])(cube([l, wall_thickness,h-wall_thickness]))


def box():
    return frame() + create_labels() + dividers(z)

def parse_arguments():
    import argparse
    parser = argparse.ArgumentParser(description='Generate SCAD file for a drawer organizer divider box')
    parser.add_argument('-o','--output', type=str, help='A filename for the output .scad e.g. --output ./box_100x100.scad', default='box_generated.scad')
    parser.add_argument('-',dest='print_to_stdout', action='store_true', help='print output to stdout')
    parser.add_argument('-s','--size', required=True ,type=str, help='The size of the frame in x,y milimeters. format {x}x{y}x{z} e.g: 100x100 or 150x200x50')
    parser.add_argument('-l','--layout', required=True, type=str, help='The cells layout. format {x_cells}x{y_cells} e.g: 1x2 or 4x4')
    parser.add_argument('--no-labels', action='store_true', help='If given will add a panel for label for each cell in the layout')
    parser.add_argument('--label-size', type=str, help='The size of the label. format {w}x{h} e.g 20x8 default 20x6', default="20x6")
    parser.add_argument('--corner-radius', type=int, help='Corner radius in milimeters', default=1)
    parser.add_argument('--smooth', type=int, help='The number of segments for the corner radius. e.g --smooth 128', default=64)

    args = parser.parse_args()
    
    global x,y,z,divider_spacing_x,divider_spacing_y, add_labels,label_w,label_h,corner_radius, corner_radius_segments
    size_sections = args.size.split('x')
    if len(size_sections) == 3:
        x,y,z = size_sections
    elif len(size_sections) == 2:
        x,y = size_sections
    else:
        print("wrong format for size")
        sys.exit(2)

    x = int(x)
    y = int(y)
    z = int(z)
    x_cells,y_cells = args.layout.split('x')

    divider_spacing_x = int(x / int(x_cells))
    divider_spacing_y = int(y / int(y_cells))
    add_labels = not args.no_labels
    label_w,label_h = args.label_size.split('x')
    label_w = int(label_w)
    label_h = int(label_h)
    corner_radius = args.corner_radius
    corner_radius_segments = args.smooth

    return args, x_cells, y_cells

def log(line):
    if not args.print_to_stdout:
        print(line)

if __name__ == '__main__':
    args, x_cells, y_cells = parse_arguments()
    obj = box()
    if args.print_to_stdout:
        scad_text = scad_render(obj)
        print(scad_text)
    else:
        log(f'size: {x}x{y}x{z}')
        log(f'layout: {x_cells}x{y_cells}\tcell: {divider_spacing_x}x{divider_spacing_y}')
        log('labels: {}'.format(f'{label_w}x{label_h}' if add_labels else 'No Labels'))
        scad_render_to_file(obj, args.output)

