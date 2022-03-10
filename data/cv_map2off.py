import sys

FLOOR = 0x0A
LADDERL = 0x07
LADDERR = 0x84
EGG = 0x9C
SEED = 0x97

FLOOROFF = 0x08
LADDERLOFF = 0x10
LADDERROFF = 0x18
EGGOFF = 0x20
SEEDOFF = 0x28


tilemap = {
	0: 0,
	FLOOR: FLOOROFF,
	LADDERL: LADDERLOFF,
	LADDERR: LADDERROFF,
	EGG: EGGOFF,
	SEED: SEEDOFF
}

if len(sys.argv) < 3:
	print("Please specify input and output filenames.")
	quit()

in_file = open(sys.argv[1], "rb")
datain = in_file.read()
in_file.close()

data = bytearray(datain)

for i in range(len(data)):
	data[i] = tilemap[data[i]] 

out_file = open(sys.argv[2], "wb")
out_file.write(data)
out_file.close()
