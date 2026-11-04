// This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or send a
// letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

// Persistence Of Vision raytracer sample file.
// File by Tom Price, modified by Dan Farmer
//
//                         !! NOTE !!
// Designed to be run as a 3-frame animation, which will generate the
// self-including image_maps in the picture frame.  See DESK.INI.
// Specifies .PNG format for the image_maps, so you may need to do
// some editing if your standard output format is different than that.
//
// -w320 -h240 +kfi1 +kff4 +ki1.0 +kf4.0 +fn
// -w800 -h600 +a0.3 +kfi1 +kff4 +ki1.0 +kf4.0 +fn

#version 3.6;

global_settings {
  assumed_gamma 2.2
}

#include "shapes.inc"
#include "colors.inc"
#include "textures.inc"
#include "woods.inc"
#include "glass.inc"
#include "metals.inc"

#declare This_Brass = texture { T_Brass_4B }

// The pencils are the same object with different color, rotation and translation
// converted to macro with these 3 parameters
#macro Pencil(COLOR, Rot, Trans)
 union {
   cylinder {0, y*30, 0.5
      pigment { COLOR }
      finish {
         crand 0.05
         ambient 0.3
         diffuse 0.7
      }  
   }
   cylinder {y*30, y*32, 0.5
      pigment { Tan }
      finish {
         crand 0.05
         ambient 0.3
         diffuse 0.7
      }
   }
   rotate Rot
   translate Trans
}
#end


#declare Back_Wall =
plane { z, 200.0
      hollow on
      finish {
      crand 0.05
      ambient 0.3
      diffuse 0.7
   }
   pigment { LightGray }
}

#declare Ceiling =
plane { y,  500.0
   hollow on
   finish {
      ambient 0.3
      diffuse 0.7
   }
   pigment { rgb 1 }
}


#declare Desk_Top =
box { <-125, -2, -100> <125, 2, 100>
   translate -20.0*y                     // top surface at -18*y
   texture {
      // T_Wood30
      pigment { P_WoodGrain6A color_map { M_Wood6A }}
      #if (clock=4)
          finish { reflection 0.2 }
      #end
      rotate y*90
      translate z*30
      rotate z*5
      scale 5
   }
}

#declare Blotter =
union {
   triangle {
      <0  , 0,  0>
      <8.5, 0,  0>
      <0  , 0, -11>
   }
   triangle {
      <0.0, 0, -11>
      <8.5, 0, -11>
      <8.5, 0,  0>
   }

   scale <4, 1, 4>
   rotate -30.0*y
   translate <-20.0, -17.9999, -40.0>

   finish {
      crand 0.04
      ambient 0.15
      diffuse 0.5
   }
   pigment { color rgb<0.5, 0.5, 0.3> }
}

#declare Paperweight=
intersection {
   sphere { <0, -5, 0>, 10 }
   disc { 0, -y, 10.1 }
   translate <0.0, -17.9998, -35.0>
   //texture { T_Green_Glass }
   // converted to material 26Sep2008 (jh)
   material {
     texture {
       pigment {color rgbf <0.8, 1, 0.95, 0.9>}
       finish {F_Glass3}
       }
     interior {ior 1.5}
     }
}


/*The Picture itself*/
#declare Picture =
union {
      box { 0, <40.0, 30.0, 0.1>
      finish {
         ambient 0.05
         diffuse 0.9
      }
      pigment {
      	// changed switch to if
         #if (clock>1)
             image_map { png concat("desk",str(clock-1,0,0),".png") once interpolate 2.0 }
             scale <60.0, 45.0, 1>
         #else
             Gray50         
         #end
      }
   }

   /* The picture frame */
   union {
		#local verts=array[4]{<-1, -1, 0>, <-1, 31, 0>, <41, 31, 0>, <41, -1, 0>}
		#for (i,0,3)
			 sphere { verts[i], 1.0 }
			 cylinder {verts[i],verts[(i<3?i+1:0)],1}
		#end
      texture { This_Brass }
   }

   scale 1.5
   rotate <10.0, -35.0, 0.0>
   translate <-65.0, -15.0, -25.0>
}

#declare Pencil_Holder =
union {
   // rounded base
	torus{4,1
		translate y*1
		texture { This_Brass }
	}
   intersection {
	   cylinder{y*1, y*40, 5}
	   cylinder{y*2, y*41, 4.8 inverse}
      plane { y, 15.0 rotate -45*x }
      texture { This_Brass }
   }
   Pencil(Red,   -2*z     ,< 1,  0,  1>)
   Pencil(Green, 2.0*z    ,<-1,  3,  0>)
   Pencil(Blue, <-2, 0, 3>,< 0, -2, -1>)
   rotate 45*y
   translate <70, -18, -20>
}

#declare Lamp =
union {
   cylinder { -y*18, y*40, 3 }
   union{
   	torus{23,2 translate<0, -16,-5>} // rounded base top
   	cylinder {<0, -18, -5><0, -16, -5>, 25}
      cylinder {<0, -18, -5><0, -14, -5>, 23}
      texture { This_Brass
         normal { bumps 0.1 }
      }
   }
	
	cylinder{
		x*30,-x*30,10
		clipped_by{
         plane { y, 0.0 inverse }
		}
		translate <0.0, 35.0, -13.0>
      finish {
         Shiny
         crand 0.05
         ambient 0.5
         diffuse 0.5
         reflection 0.3
         brilliance 4.0
      }
      pigment { DarkGreen }
	}

   union {
      sphere { <-30.0, 35.0, -13.0>, 10.0
         clipped_by{
            plane { y, 35.0 inverse }
            plane { x, -30.0 }
         }
      }
      sphere { <30.0, 35.0, -13.0>, 10.0 
			clipped_by{
            plane { y, 35.0 inverse }
            plane { x, 30.0 inverse }
         }
      }
      
   }
   texture { This_Brass }
   
   rotate 35*y
   translate <50.0, 0.0, 30.0>
}

/*The fluorescent tube inside the lamp*/
#declare Lamp_Light_Source =
light_source { <0, 0, 0> color rgb 1

    looks_like {
       cylinder { -x*25, x*25, 2
          pigment { rgb 1 filter 0 }
          finish { ambient 1 diffuse 0 }
      }
   }

   translate <0.0, 42.0, -10.0>
   rotate 35*y
   translate <50.0, 0.0, 30.0>
}
camera {
   location <0.0, 40.0, -150.0>
   angle 65 
   right x*image_width/image_height // keep propotions with any aspect ratio
   look_at 0
}

light_source { <20.0, 100.0, -200.0> color rgb 1 }

object { Back_Wall }
object { Ceiling }
object { Desk_Top }
object { Blotter }
object { Paperweight }
object { Lamp }
object { Lamp_Light_Source }
object { Picture }
object { Pencil_Holder }
// 282
