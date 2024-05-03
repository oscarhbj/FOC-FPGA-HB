#XDC masterfile for Trenz Te0720-04-61C33MAS + TE0703-06 extention card.

#CLOCK

#create_clock -period 10.000 -name gclk -waveform {0.000 5.000} [get_ports clk_main]
#create_clock -period 10.000 -name gclk -waveform {0.000 5.000} [get_pins design_1_i/top_fpga_trenz_0/clk_main]

#PINS TOTAL: 150
#PINS IN USE: 140+1

#MOTORS MAPPED: 12
#ADC AMOUNT: 5
#ANGULAR ENCODERS: 12
#HW RESET BTN: YES
#REDUCED ADC INTERFACE: YES
#ONLY CRITICAL ADC: NO
#ENGATE: YES



# ---------------------------------------------------------
# J1
# ---------------------------------------------------------
# A: 28

#A1 MIO10-SCL
#A2 MIO11-SDA
#A3 GND
#set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33 } [get_ports {en_gate[7]}];  # "A4"
#set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS33 } [get_ports {CHI[7]}];  # "A5"
#set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports {CHB[7]}];  # "A6"
#set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVCMOS33 } [get_ports {CHA[7]}];  # "A7"

#PWM MOTOR 3
#set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor3[0]}];  # "A8"
#set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor3[1]}];  # "A9"
#set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor3[2]}];  # "A10"
#set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor3[3]}];  # "A11"
#set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor3[4]}];  # "A12"
#set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor3[5]}];  # "A13"

#PWM MOTOR 2
#set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor2[0]}];  # "A14"
#set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor2[1]}];  # "A15"
#set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor2[2]}];  # "A16"
#set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor2[3]}];  # "A17"
#set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor2[4]}];  # "A18"
#set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor2[5]}];  # "A19"

#PWM MOTOR 1
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor1[0]}];  # "A20"
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor1[1]}];  # "A21"
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor1[2]}];  # "A22"
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor1[3]}];  # "A23"
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor1[4]}];  # "A24"
set_property -dict {PACKAGE_PIN P21 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor1[5]}];  # "A25"

#PWM MOTOR 0
set_property -dict {PACKAGE_PIN L21 IOSTANDARD LVCMOS33} [get_ports {pwm_motor0[0]}]
set_property -dict {PACKAGE_PIN L22 IOSTANDARD LVCMOS33} [get_ports {pwm_motor0[1]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {pwm_motor0[2]}]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports {pwm_motor0[3]}]
set_property -dict {PACKAGE_PIN R20 IOSTANDARD LVCMOS33} [get_ports {pwm_motor0[4]}]
set_property -dict {PACKAGE_PIN R21 IOSTANDARD LVCMOS33} [get_ports {pwm_motor0[5]}]
#A32 GND

# ----------------------------------------------------------
# B: 28

#B1 VCCIOA
#B2 GND
#set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports {en_gate[6]}];  # "B3"
#set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33 } [get_ports {CHI[6]}];  # "B4"
#set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports {CHB[6]}];  # "B5"
#set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports {CHA[6]}];  # "B6"

#set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS33 } [get_ports {en_gate[5]}];  # "B7"
#set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33 } [get_ports {CHI[5]}];  # "B8"
#set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33 } [get_ports {CHB[5]}];  # "B9"
#set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS33 } [get_ports {CHA[5]}];  # "B10"

#set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports {en_gate[4]}];  # "B11"
#set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33 } [get_ports {CHI[4]}];  # "B12"
#set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33 } [get_ports {CHB[4]}];  # "B13"
#set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS33 } [get_ports {CHA[4]}];  # "B14"

#set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33 } [get_ports {en_gate[3]}];  # "B15"
#set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS33 } [get_ports {CHI[3]}];  # "B16"
#set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports {CHB[3]}];  # "B17"
#set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS33 } [get_ports {CHA[3]}];  # "B18"

#set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports {en_gate[2]}];  # "B19"
#set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33 } [get_ports {CHI[2]}];  # "B20"
#set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports {CHB[2]}];  # "B21"
#set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {CHA[2]}];  # "B22"

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {en_gate[1]}];  # "B23"
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports {CHI[1]}];  # "B24"
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports {CHB[1]}];  # "B25"
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports {CHA[1]}];  # "B26"

set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {en_gate[0]}];
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {CHI[0]}];
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVCMOS33} [get_ports {CHB[0]}];
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVCMOS33} [get_ports {CHA[0]}];

#B31 GND
#B32 VCCIOB

# ----------------------------------------------------------
# C: 28

##C1 GND
#set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports {en_gate[11]}];  # "C2"
#set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33 } [get_ports {CHI[11]}];  # "C3"
#set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33 } [get_ports {CHB[11]}];  # "C4"
#set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33 } [get_ports {CHA[11]}];  # "C5"


#set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33 } [get_ports {en_gate[10]}];  # "C6"
#set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33 } [get_ports {CHI[10]}];  # "C7"
#set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports {CHB[10]}];  # "C8"
#set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33 } [get_ports {CHA[10]}];  # "C9"


##ADC4 (2+.66 motors)
#set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST } 	[get_ports {CS[4]}];  # "C10"
#set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST } 	[get_ports {MOSI[4]}];  # "C11"
#set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33 PULLUP true } 		[get_ports {MISO[4]}];  # "C12"
#set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST } 	[get_ports {SPI_clk[4]}];  # "C13"


##ADC3 (2+.66 motors)
#set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST} 	[get_ports {CS[3]}];  # "C14"
#set_property -dict {PACKAGE_PIN A22 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST} 	[get_ports {MOSI[3]}];  # "C15"
#set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33 PULLUP true } 		[get_ports {MISO[3]}];  # "C16"
#set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST } 	[get_ports {SPI_clk[3]}];  # "C17"


##3x ADC = 8 motors
##ADC2 (2+.66 motors)
#set_property -dict {PACKAGE_PIN J22 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST } 	[get_ports {CS[2]}];  # "C18"
#set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST } 	[get_ports {MOSI[2]}];  # "C19"
#set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33 PULLUP true } 		[get_ports {MISO[2]}];  # "C20"
#set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST } 	[get_ports {SPI_clk[2]}];  # "C21"


##ADC1 (2+.66 motors)
#set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST} 	[get_ports {CS[1]}];
#set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST} 	[get_ports {MOSI[1]}];
#set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33 PULLUP true} 		[get_ports {MISO[1]}];
#set_property -dict {PACKAGE_PIN K21 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST} 	[get_ports {SPI_clk[1]}];


#ADC0 (2+.66 motors)
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST} 	[get_ports {CS[0]}];
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST} 	[get_ports {MOSI[0]}];
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33 PULLUP true} 		[get_ports {MISO[0]}];
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33 DRIVE 16 SLEW FAST} 	[get_ports {SPI_clk[0]}];
#C30 GND

#C31 3.3V
#C32 M3.3VOUT


#
# ---------------------------------------------------------
# J2
# ---------------------------------------------------------

# A:22

#A1 5VIN
#A2 5VIN
#A3 GND
#set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS33 } [get_ports {J2_A4}];  # "A4"
#set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33 } [get_ports {J2_A5}];  # "A5"
#set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33 } [get_ports {J2_A6}];  # "A6"
#set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33 } [get_ports {J2_A7}];  # "A7"


#set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor9[0]}];  # "A8"
#set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor9[1]}];  # "A9"
#set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor9[2]}];  # "A10"
#set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor9[3]}];  # "A11"
#set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor9[4]}];  # "A12"
#set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor9[5]}];  # "A13"


#set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor8[0]}];  # "A14"
#set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor8[1]}];  # "A15"
#set_property -dict {PACKAGE_PIN V9 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor8[2]}];  # "A16"
#set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor8[3]}];  # "A17"
#set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor8[4]}];  # "A18"
#set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor8[5]}];  # "A19"


#set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor7[0]}];  # "A20"
#set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor7[1]}];  # "A21"
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor7[2]}];  # "A22"
#set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor7[3]}];  # "A23"
#set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor7[4]}];  # "A24"
#set_property -dict {PACKAGE_PIN AA22 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor7[5]}];  # "A25"

#A26 X8 (U5-47)
#A27 X11 (U5-50)
#A28 X14 (U5-55)
#A29 X15 (U5-56)
#A30 X16 (U5-59)

#A31 X17 (U5-60)
#A32 GND

# ----------------------------------------------------------
# B:22

#B1 VCCIOD
#B2 GND
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports rst]


#set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports {J2_B4}];  # "B4"
#set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports {J2_B5}];  # "B5"
#set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS33 } [get_ports {J2_B6}];  # "B6"



#set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor6[0]}];  # "B7"
#set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor6[1]}];  # "B8"
#set_property -dict {PACKAGE_PIN W8 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor6[2]}];  # "B9"
#set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor6[3]}];  # "B10"
#set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor6[4]}];  # "B11"
#set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor6[5]}];  # "B12"

#set_property -dict {PACKAGE_PIN Y5 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor5[0]}];  # "B13"
#set_property -dict {PACKAGE_PIN Y6 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor5[1]}];  # "B14"
#set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor5[2]}];  # "B15"
#set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor5[3]}];  # "B16"
#set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor5[4]}];  # "B17"
#set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor5[5]}];  # "B18"

#set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor4[0]}];  # "B19"
#set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor4[1]}];  # "B20"
#set_property -dict {PACKAGE_PIN W21 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor4[2]}];  # "B21"
#set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor4[3]}];  # "B22"
#set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor4[4]}];  # "B23"
#set_property -dict {PACKAGE_PIN AA21 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor4[5]}];  # "B24"


# B25 X4 (U5-42)
# B26 X5 (U5-43)
# B27 X9 (U5-48)
# B28 X10 (U5-49)
# B29 X12 (U5-52)
# B30 X13 (U5-54)

#B31 GND
#B32 VCCIOC

# ----------------------------------------------------------
# C: 22

#C1 GND
#set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS33 } [get_ports {J2_C2}];  # "C2"
#set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS33 } [get_ports {J2_C3}];  # "C3"

#set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVCMOS33 } [get_ports {en_gate[9]}];  # "C4"
#set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33 } [get_ports {CHI[9]}];  # "C5"
#set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS33 } [get_ports {CHB[9]}];  # "C6"
#set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS33 } [get_ports {CHA[9]}];  # "C7"

#set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33 } [get_ports {en_gate[8]}];  # "C8"
#set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33 } [get_ports {CHI[8]}];  # "C9"
#set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS33 } [get_ports {CHB[8]}];  # "C10"
#set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33 } [get_ports {CHA[8]}];  # "C11"


#set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor11[0]}];  # "C12"
#set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor11[1]}];  # "C13"
#set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor11[2]}];  # "C14"
#set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor11[3]}];  # "C15"
#set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor11[4]}];  # "C16"
#set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor11[5]}];  # "C17"

#set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor10[0]}];  # "C18"
#set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor10[1]}];  # "C19"
#set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor10[2]}];  # "C20"
#set_property -dict {PACKAGE_PIN AA17 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor10[3]}];  # "C21"
#set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor10[4]}];  # "C22"
#set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports {pwm_motor10[5]}];  # "C23"


#C24 X0 (U5-39)
#C25 X1 (U5-38)
#C26 X2 (U5-40)
#C27 X3 (U5-41)
#C28 X6 (U5-44)
#C29 X7 (U5-45)
#C30 GND

#C31 3.3V
#C32 M3.3VOUT
