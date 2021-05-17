PROJECT = diskless

$(PROJECT).prg: $(PROJECT).asm bios.inc
	rcasm -l -v -x -d1802 $(PROJECT) 2>&1 | tee diskless.lst

mchip: $(PROJECT).asm bios.inc
	rcasm -l -v -x -d1802 -DMCHIP $(PROJECT) 2>&1 | tee diskless.lst

clean:
	-rm $(PROJECT).prg


