// enclosure for air-monitor-thc-v1
module plate (length, width, thickness)
{
    // width is also the diameter of the rounding
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


$fn=36;

box (80+4, 35+4, 20+2, 2);
