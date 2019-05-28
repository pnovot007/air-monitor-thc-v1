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

module box (length, width, hight, thickness)
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
            plate (hight, width, thickness);
    translate ([length - thickness/2, 0, 0])
        rotate (-90, [0,1,0])
            plate (hight, width, thickness);
    translate ([0, thickness/2,  0])
        rotate (90, [1,0,0])
            plate (length, hight, thickness);
    translate ([0, width - thickness/2,  0])
        rotate (90, [1,0,0])
            plate (length, hight, thickness);


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



// Global parameters
$fn=36;
mylength = 80+4;
mywidth = 35+4;
myhight = 20+2;
mythickness = 2;
airholes_size = min(mywidth, myhight)*0.8;

// Create box
box (mylength, mywidth, myhight, mythickness);
// Deviders
translate ([27 + mythickness/2 + mythickness, 0, 0])
    rotate (-90, [0,1,0])
        plate (myhight, mywidth, 2);
translate ([mylength - 27 - (mythickness/2 + mythickness), 0, 0])
    rotate (-90, [0,1,0])
        plate (myhight, mywidth, 2);


rotate (90, [1,0,0])
translate ([airholes_size/2, mythickness/2, airholes_size/2])
airholes (airholes_size, mythickness);


