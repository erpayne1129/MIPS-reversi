.text
getIndexLocation: #Take an x,y coordinate and translate it into a single-array index location
mulu $t0, $a0, 8
add $t0, $t0, $a1
move $a0, $t0