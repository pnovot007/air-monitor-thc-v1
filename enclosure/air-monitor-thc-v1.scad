// enclosure for air-monitor-thc-v1
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
            polygon (points = [[-width/2,-hight/2], [width/2,-hight/2], [width/2,hight/2], [0,hight], [-width/2,hight/2]]);
}


// Global parameters
$fn=36;
mylength = 80+4;
mywidth = 35+4;
myhight = 20+2+2+5;
myoverhang = 4;
mydevider_reduction = 4;
mythickness = 2;
mychamber_length = 27;
airholes_size = min(mywidth, myhight)*0.8;
mycable_hole_width = 12;
mycable_hole_height = 8;
mycable_hole_position_z = 17;

// Create box
module create_box(){
    // Create outer shell
    box (mylength, mywidth, myhight, mythickness, myoverhang);
    // Deviders
    translate ([mychamber_length + mythickness/2 + mythickness, 0, 0])
        rotate (-90, [0,1,0])
            plate (myhight - mydevider_reduction, mywidth, 2);
    translate ([mylength - mychamber_length - (mythickness/2 + mythickness), 0, 0])
        rotate (-90, [0,1,0])
            plate (myhight- mydevider_reduction, mywidth, 2);
}

module create_holes(){
    translate ([(mychamber_length)/2+mythickness, mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size, mythickness*2);
    translate ([(mychamber_length)/2+mythickness, mywidth-mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size, mythickness*2);

    /*translate ([mylength-(mychamber_length)/2-mythickness, mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size, mythickness*2);*/
    translate ([mylength-(mychamber_length)/2-mythickness, mythickness/2,  mycable_hole_position_z+mythickness])
       rotate (90, [1,0,0])
            cable_hole (mycable_hole_width, mycable_hole_height, mythickness*2);    
    
    translate ([mylength-(mychamber_length)/2-mythickness, mywidth-mythickness/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [1,0,0])
            airholes (airholes_size, mythickness*2);

    translate ([mythickness/2, mywidth/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [0,1,0])
            airholes (airholes_size, mythickness*2);
    translate ([mylength-mythickness/2, mywidth/2, airholes_size/2+(myhight-airholes_size)/2])
        rotate (90, [0,1,0])
            airholes (airholes_size, mythickness*2);


}


//#create_holes();
difference()
{
    create_box();
    create_holes();
}

