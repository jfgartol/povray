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

#macro Pencil(Color, Rotate, Translate)
 union {
   cylinder {0, y*30, 0.5
      pigment { Color }
   }

   cylinder {y*30, y*32, 0.5
      pigment { Tan }
   }
   finish {
      crand 0.05
      ambient 0.3
      diffuse 0.7
   }   
   rotate Rotate
   translate Translate
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
   pigment { White }
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
      <0  , 0, 0>
      <8.5, 0, 0>
      <0  , 0, -11>
   }
   triangle {
      <0  , 0, -11>
      <8.5, 0, -11>
      <8.5, 0,   0>
   }

   scale <4.0, 1.0, 4.0>
   rotate -30.0*y
   translate <-20, -17.9999, -40>

   finish {
      crand 0.04
      ambient 0.15
      diffuse 0.5
   }
   pigment { color rgb <0.5, 0.5, 0.3> }
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
       pigment {rgbf <0.8, 1, 0.95, 0.9>}
       finish {F_Glass3}
       }
     interior {ior 1.5}
     }
}


/*The Picture itself*/
#local FrameCorners = array[4]{
     <-1, -1, 0>,
     <41, -1, 0>,
     <41, 31, 0>,
     <-1, 31, 0>    
}

#declare Picture =
union {
      box { 0, <40, 30, 1>
      finish {
         ambient 0.05
         diffuse 0.9
      }
      pigment {
      	#if (clock<2)
      	    Gray50
      	#else
      	    image_map { png concat("desk",str(clock-1,0,0),".png") once interpolate 2 }
             scale <60, 45, 1>
      	#end
      }
   }

   /* The picture frame */
   union {
   	#for (i,0,3)
   		cylinder {FrameCorners[i],FrameCorners[(i<3?i+1:0)],1}
   		sphere {FrameCorners[i], 1}		
   	#end
      texture { This_Brass }
   }

   scale 1.5
   rotate <10, -35, 0>
   translate <-65, -15, -25>
}

#declare Pencil_Holder =
union {
   intersection {
      object { Cylinder_Y scale <5.0, 1.0, 5.0> }
      object { Cylinder_Y scale <4.8, 1.0, 4.8> inverse }
      plane { y, 0.0 inverse }
      plane { y, 15.0 rotate -45*x }
      texture { This_Brass }
   }
   Pencil(Red, -2*z, <1, 0, 1>)
   Pencil(Green, 2*z, <-1, 3, 0>)
   Pencil(Blue, <-2, 0, 3>, <0, -2, -1>) 
   rotate 45*y
   translate <70, -18, -20>
}

#local LampA=
intersection {
   sphere { <-30.0, 35.0, -13.0>, 10.0 }
   sphere { <-30.0, 35.0, -13.0>, 9.95 inverse }
   plane { y, 35.0 inverse }
   plane { x, -30.0 }
}

#declare Lamp =
union {
   cylinder {
      -y*18, y*40, 3
      texture { This_Brass }
   }
   cylinder { -y*2, y*2, 25
//    intersection {
//       object { Cylinder_Y scale <25.0, 1.0, 25.0> }
//       plane { y, 2.0 }
//       plane { y, -2.0 inverse }

      translate <0.0, -16.0, -5.0>
      texture { This_Brass
         normal { bumps 0.1 }
      }
   }

   intersection {
      cylinder{-x*30, x*30, 10 }
      cylinder{-x*31, x*31, 9.95 }
      plane { y, 0 inverse }
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
      object{LampA}
      object{LampA scale<-1,1,1>}
      texture { This_Brass }
   }
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

   translate <0, 43, -10>
   rotate 35*y
   translate <50, 0, 30>
}
camera {
   location <0.0, 40.0, -150.0>
   angle 65
   right x*image_width/image_height // keep proportions with any aspect ratio
   look_at 0.0
}

light_source { <20.0, 100.0, -200.0> rgb 1 }

object { Back_Wall }
object { Ceiling }
object { Desk_Top }
object { Blotter }
object { Paperweight }
object { Lamp }
object { Lamp_Light_Source }
object { Picture }
object { Pencil_Holder }
