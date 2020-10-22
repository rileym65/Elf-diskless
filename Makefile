PROJECT = diskless

$(PROJECT).prg: $(PROJECT).asm bios.inc
	rcasm -l -v -x -d1802 $(PROJECT)

clean:
	-rm $(PROJECT).prg


