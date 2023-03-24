vlt: clean
	verilator --binary tb.sv -I../../src --assert 
	./obj_dir/Vtb +verilator+error+limit+10

rvra: clean
	vlib work
	vlog +incdir+../../src tb.sv -dbg
	vsim -access+rwc -dbg tb -c -do "run -all;exit" | tee rvra.log

clean:
	rm -fr work *.log obj* *.cfg data*
