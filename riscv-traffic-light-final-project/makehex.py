import sys

if len(sys.argv) != 3:
    print("Usage: python makehex.py firmware.bin firmware.hex")
    sys.exit(1)

bin_file = sys.argv[1]
hex_file = sys.argv[2]

with open(bin_file, "rb") as f:
    data = f.read()

# 補到 4 bytes 對齊
while len(data) % 4 != 0:
    data += b'\x00'

with open(hex_file, "w") as f:
    for i in range(0, len(data), 4):
        word = data[i:i+4]
        value = word[0] | (word[1] << 8) | (word[2] << 16) | (word[3] << 24)
        f.write(f"{value:08x}\n")
