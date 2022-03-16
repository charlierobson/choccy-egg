import sys

if len(sys.argv) < 3:
	print("Please specify input and output filenames.")
	quit()

in_file = open(sys.argv[1], "rb")
datain = in_file.read()
in_file.close()

data = bytearray(datain)

for i in range(len(data)):
	data[i] = data[i] * 8 

out_file = open(sys.argv[2], "wb")
out_file.write(data)
out_file.close()
