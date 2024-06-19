use <./MX_DES_Standard.scad>
use <./MX_DES_Thumb.scad>

// TODO - update homerow dot

// Update key parameter indexes below
// Sets are mirrored (e.g 6 keyIDs will print 12 keys)
sets = [
    ["R1",    [0, 0, 0, 0, 0, 0]],
    ["R2",    [1, 1, 1, 1, 1, 1]],
    //["R3",    [2, 2, 2, 2, 2, 2]],
    //["Thumb", [7, 6, 3, 7, 6, 3]],
];

// Variables
includeHomeDots = true; // true to include two keys on home row with home dots
xSpacing = 20; // Define x spacing
ySpacing = 20;
gen_support = 1; // * Disable support generation */

$radious = 0.75;

module mjf_supports(size, gen_support, sprue_trim) {
  extra_side = 3.5;
  extra_heigt = 0.1;
  $fn = 16;

  if (gen_support > 0) {
	color("red") {
		translate([0,0,$radious]) {
			// connect sprues
			if (sprue_trim != true) {
				translate([0, -size/2 + $radious - 0.45, -$radious * 3])
					rotate([90,0,0])
					cylinder(h=size + extra_side,r=$radious);
			}
			translate([$radious, -size/2 + $radious - 0.45, -$radious * 3])
				rotate([180,90,0])
				cylinder(h=size + extra_side,r=$radious);
			translate([0, -size/2 + $radious - 0.45, -$radious + extra_heigt])
				rotate([0,180,0])
				cylinder(h=$radious * 2 + extra_heigt,r=$radious);
		}
	}
  }
  children();
}

module genside(idx, name, layout, sprue_trim) {
	for ( idy = [ 0 : 1 : len(layout) - 1]) {
		if (name == "Thumb") {
			translate([xSpacing * idy, ySpacing * idx])
				mjf_supports(size=17.16, gen_support=gen_support, sprue_trim)
			rotate([0,0,180])
				thumb_keycap(
					keyID  = layout[idy], 
					cutLen = 0, //Don't change. for chopped caps
					Stem   = true, //turn on shell and stems
					Dish   = true, //turn on dish cut
					Stab   = 0, 
					visualizeDish = false, // turn on debug visual of Dish 
					crossSection  = false, // center cut to check internal
					homeDot = false, //turn on homedots
					Legends = false
					);
		} else {
			dots = ( includeHomeDots != true ? false :
				( name != "R2" ? false :
					( idy == 1 ? true : false)
				)
			);
			translate([xSpacing * idy, ySpacing * idx])
				mjf_supports(size=17.16, gen_support=gen_support, sprue_trim)
				keycap(
				keyID  = layout[idy], 
				cutLen = 0, //Don't change. for chopped caps
				Stem   = true, //turn on shell and stems
				Dish   = true, //turn on dish cut
				Stab   = 0, 
				visualizeDish = false, // turn on debug visual of Dish 
				crossSection  = false, // center cut to check internal
				homeDot = dots, //turn on homedots
				Legends = false
				);
		}
	}
}

for ( idx = [ 0 : 1 : len(sets) - 1]) {
	setName = sets[idx][0];
	layout = sets[idx][1];
	echo ("Rendering Set: ", setName, " ", layout);
	sprue_trim = ( idx != 0 ? false :
		( len(sets) > 1 ? true : false)
	);
	translate([ xSpacing, 0, 0])genside(idx, setName, layout, sprue_trim);
	mirror([(len(layout) - 1) * xSpacing, 0, 0])genside(idx, setName, layout, sprue_trim);
}
