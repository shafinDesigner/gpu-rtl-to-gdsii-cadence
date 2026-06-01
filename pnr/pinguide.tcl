puts "GIVE THE LAYERH "
gets stdin layerh

puts "GIVE THE LAYERV "
gets stdin layerv

editPin \
-pin [dbGet top.terms.name] \
-layerH $layerh \
-layerV $layerv \
-spreadType SIDE \
-snap TRACK

change_selection [dbGet top.terms.name]

return
