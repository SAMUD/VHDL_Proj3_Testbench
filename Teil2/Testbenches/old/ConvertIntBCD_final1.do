######################################
# Do File by Samuel Daurat [178190]  #
# 05.12.17							 #
######################################

#This file is used to test Converting INT to BCD.
#Files used:	CovertIntBcd.vhd / Decoder.vhd 

# -- Restart Simulation
restart -force -nolist -nowave -nobreak -nolog
onerror {resume}

#--log all waves including the not shown ones
log -r /*

# Add the waves needed to be displayed
# Two ways can be used to add signals
# either each signal by its name and path
# or use add wave /*
add wave /*


#--------------------FORCE SIGNALS HERE ---------
# Syntax: force signalname value1 time1, value2 time2,…
# e.g.
# force signal_x 0 0ns, 1 10ns, 0 30ns, Z 100ns
# use s, us, ms, ns, ps, fs as timescale
# To override the signal of a driver use –freeze
# default timescale is ps
#‘-r’ is used for repetition

#------------------RUN SIMULATION HERE---------------

#pepare clk signal
force main/clk 1 0, 0 1ps -repeat 2ps


#increase Count value
force main/Countvalue 0 0, 1 10ps, 2 20ps, 3 30ps, 4 40ps, 5 50ps, 6 60ps, 7 70ps, 8 80ps , 9 90ps, 10 100ps, 11 110ps, 12 120ps, 599 130ps, 600 140ps, 5999 150ps


#and now run the simulation for 1,5ns
run 150 ps
