/*
 * Enclosure for air-monitor-thc-v1
 * 
 */
myversion = "TH Enclosure v0.11";
/*
 *
 */

module plate (length, width, thickness)
{
/*
 * Rounded plate
 *
 * Width is also the diameter of the roundess
 *     
 */    
    // 
    hull ()
    {
        translate ([thickness/2, thickness/2, 0]) sphere (thickness/2);
        translate ([length - thickness/2, thickness/2, 0]) sphere (thickness/2);
        translate ([length - thickness/2, width - thickness/2, 0]) sphere (thickness/2);
        translate ([thickness/2, width - thickness/2, 0]) sphere (thickness/2);
    }
    
}

module box (length, width, hight, thickness, overhang=0)
/* Empty box without lid
 *
 * Inner length = @length - 2x @thickness
 * Inner width = @width - 2x @thickness
 */
{
translate ([0, 0, thickness/2])
    plate (length, width, thickness);
    translate ([thickness/2, 0, 0])
        rotate (-90, [0,1,0])
            plate (hight+overhang, width, thickness);
    translate ([length - thickness/2, 0, 0])
        rotate (-90, [0,1,0])
            plate (hight, width, thickness);
    translate ([0, thickness/2,  0])
        rotate (90, [1,0,0])
            plate (length, hight+overhang, thickness);
    translate ([0, width - thickness/2,  0])
        rotate (90, [1,0,0])
            plate (length, hight+overhang, thickness);


}


module round_airholes (number, width, thickness)
/*
 * @thickness determines also width of each airhole
 *
 */
/*
 * NOT USED
 */
{
    // cylinder should be higher than thickness of the material
    translate ([-thickness/2, 0, 0 ])
    rotate (90, [0,1,0])
    hull ()
    {
        translate ([0, width/2-thickness, 0]) cylinder (thickness*1.2, thickness/2);
        translate ([0, -1*width/2-thickness, 0]) cylinder (thickness*1.2, thickness/2); 
    }
    
    // not completed ... 
}

module airholes (size, thickness)
/*
 * airholes should be substracted from the material
 * @size of the square shape
 * @thickness of the material
 */

{
    diagonal = sqrt (2*size*size);

    difference()
    {

        rotate (45, [0,0,1])
            for (i = [-5:2:5])
            {
                translate ([0,i*0.08*diagonal,0])
                    cube([diagonal, 0.08*diagonal, thickness], true);
            }   
         difference()
         {
            cube([2*size, 2*size, thickness*2], true);
            cube([size, size, thickness*3], true);
     
         }
     }        
}

module cable_hole (width, hight, thickness)
/*
 * Hole for the power supply cable
 * @width is the complete width of the opening
 * @hight is the hight of the square part
 */
{
    translate ([0,0,-thickness])
        linear_extrude(thickness*2)
            polygon (points = [[-width/2,-hight/2], [width/2,-hight/2], [width/2,hight/2], [-width/2,hight/2]]);
}


// Global parameters
$fn=36;
mylength = 80+4;
mywidth = 35+4;
myhight = 20+2+2+5;
mythickness = 2;
myoverhang = mythickness*2;
mychamber_length = 27; // Internal size of chamber
airholes_size = min(mywidth, myhight)*0.8;
mycable_hole_width = 12;
mycable_hole_height = 8;
mycable_hole_position_z = 1;
myinternal_elevation_hight = 9;
myinternal_elevation_width = 3;
mydevider_hight = myinternal_elevation_hight + 15; // elevation + hight of the circuit pillar element

// Create box
module create_box(){

    // Create outer shell
    box (mylength, mywidth, myhight, mythickness, myoverhang);

    // Deviders
    translate ([mychamber_length + mythickness/2 + mythickness, 0, 0])
        rotate (-90, [0,1,0])
            plate (mydevider_hight, mywidth, 2);

    translate ([mylength - mychamber_length - (mythickness/2 + mythickness), 0, 0])
        rotate (-90, [0,1,0])
            plate (mydevider_hight, mywidth, 2);


    // Internal elevators
    translate([mythickness, mythickness, mythickness])
        cube([myinternal_elevation_width, mywidth-2*mythickness, myinternal_elevation_hight]);

    translate([mychamber_length-0.5*mythickness, mythickness, mythickness])
        cube([myinternal_elevation_width, mywidth-2*mythickness, myinternal_elevation_hight]);


    translate([mylength-mychamber_length-mythickness, mythickness, mythickness])
        cube([myinternal_elevation_width, mywidth-2*mythickness, myinternal_elevation_hight]);

    translate([mylength-2.5*mythickness, mythickness, mythickness])
        cube([myinternal_elevation_width, mywidth-2*mythickness, myinternal_elevation_hight]);


}

module create_holes(){

    translate ([(mychamber_length)/2+mythickness, mythickness/2,  mycable_hole_position_z+mythickness+myinternal_elevation_hight])
       rotate (90, [1,0,0])
            cable_hole (mycable_hole_width, mycable_hole_height, mythickness*2);    

    /*translate ([(mychamber_length)/2+mythickness, mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size, mythickness*2);
    */
    
    translate ([(mychamber_length)/2+mythickness, mywidth-mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size, mythickness*2);

    translate ([mylength-(mychamber_length)/2-mythickness, mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size, mythickness*2);
    
    translate ([mylength-(mychamber_length)/2-mythickness, mywidth-mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size, mythickness*2);

    translate ([mylength/2, mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size*0.7, mythickness*2);
    
    translate ([mylength/2, mywidth-mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size*0.7, mythickness*2);



    // Front and back holes
    translate ([mythickness/2, mywidth/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [0,1,0])
            airholes (airholes_size, mythickness*2+2*myinternal_elevation_width);
    translate ([mylength-mythickness/2, mywidth/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [0,1,0])
            airholes (airholes_size, mythickness*2+2*myinternal_elevation_width);
}

module create_notch (length, width, hight, thickness)
{
    thickness_addition = 0.1;
    //width_reduction = -0.2;
    translate ([thickness/2-thickness_addition, thickness/2-thickness_addition, hight+thickness/2])
        plate (length, width-thickness+2*thickness_addition, thickness+2*thickness_addition);

}

module engrave_version(x_start_position=0, y_start_position=0)
{
    fontsize = 2;
    depth = 1;
    translate ([2*mythickness+x_start_position, 2*mythickness+y_start_position, 1])
        rotate (180, [1,0,0])
            linear_extrude(depth)
            text(myversion, size = fontsize, halign="left", valign="top");
}

///////////////////////////////////////////
module complete_box()
{
    difference()
    {
        difference ()
        {
            difference()
            {
                create_box();
                create_holes();
            }
        create_notch(mylength, mywidth, myhight, mythickness);    
        }
        engrave_version(0,0);
    }
}
module complete_lid()
{
    difference()
    {
        translate ([mythickness/2, mythickness/2, mythickness/2])
            plate (mylength-mythickness/2, mywidth-mythickness, mythickness);
        engrave_version();
    }
}

///////////////////////////////////////////
complete_box();
translate ([-mylength-10,0,0])
complete_lid();
