import numpy as np

file_name= "sin_lut_harmonic_bin.txt"
f = open(file_name, "w")
bits_lut=16
sin_multippel=2**bits_lut
points=(2**8)
string_inp=input("third_harmonic y/n?")
string_inp=string_inp.upper()
for i in range(int(points*2/3)+10):
	angle=2*i*np.pi/(4*points)
	value=0
	if string_inp=='Y':
		sin_value=1.154*np.sin(angle)
		harmonic_value=0.15 * np.sin(3*angle)
		value=sin_multippel*(sin_value+harmonic_value)
	elif string_inp=='T':
		sinus_verdi=np.sin(angle)/(np.sin(angle)+np.sin((np.pi/3)-angle))
		if sinus_verdi>=1:
			sinus_verdi=1		
		value=(sin_multippel-1)*(sinus_verdi)
	else:
		sinus_verdi=np.sin(angle)
		value=sin_multippel*(sinus_verdi)
	number=bin(int(round(value)))
	print(number)
	f.write(number[2:].zfill(bits_lut) + "\n")
f.close()
