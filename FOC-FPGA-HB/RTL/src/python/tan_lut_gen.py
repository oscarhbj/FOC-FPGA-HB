import numpy as np

file_name= "tan_lut_bin.txt"
f = open(file_name, "w")
bits_ut=16
points=16
scale=float(((2**(bits_ut))-2))/(np.pi/2) 
print("90 degrees is: " , str(2**bits_ut -2))
for i in range(points):
    angle=np.arctan(2**(-i))
    angle_in_range=int(round(angle*scale))
    print(angle_in_range)
    f.write(bin(angle_in_range)[2:].zfill(bits_ut) + "\n")
f.close()
