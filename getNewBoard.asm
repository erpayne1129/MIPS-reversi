#Ethan Payne 
#CS3340.0U1 Project: Reversi
		.data
#cleanBoard	.byte	' ':64	#creates an empty board of 64 characters
newBoard	.byte	' ':64	#creates an empty board of 64 characters (to be used and modified)
		.text
GETNEWBOARD:
	# I'm not sure if creating a new board is something
	# we can/need to worry about, I'm kind of confused in that sense


 	# I think all we need is the data initialization
	
	
	#lb $t0, cleanBoard

	#jr $ra			#return to caller address
