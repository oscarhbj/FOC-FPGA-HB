import numpy as np

file_name= "sin_lut_bin.txt"
f = open(file_name, "w")
bits_lut=15
sin_multippel=2**bits_lut #could be -1 if the calculations had a overflow. due to no overflow, imma nope that -1
points=(2**8)
for i in range(points):
	angle=i*np.pi/(2*points)
	value=sin_multippel*np.sin(angle)
	number=bin(int(round(value)))
	f.write(bin(int(round(sin_multippel*np.sin(i*np.pi/(2*points)))))[2:].zfill(bits_lut) + "\n")
f.close()
