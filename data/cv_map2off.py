import sys

FLOOR = 0x0A
LADDERC = 0x03
LADDERLF = 0x92
LADDERRF = 0x93
LADDERL = 0x85
LADDERR = 0x05
EGG = 0x9C
SEED = 0x97

FLOOROFF = 0x08
LADDERCOFF = 0x10
LADDERLFOFF = 0x18
LADDERRFOFF = 0x20
LADDERLOFF = 0x28
LADDERROFF = 0x30
EGGOFF = 0x38
SEEDOFF = 0x40


tilemap = {
	0: 0,
	FLOOR: FLOOROFF,
	LADDERC: LADDERCOFF,
	LADDERL: LADDERLOFF,
	LADDERR: LADDERROFF,
	LADDERLF: LADDERLFOFF,
	LADDERRF: LADDERRFOFF,
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
