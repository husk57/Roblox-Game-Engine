
import math
rBitDepth = 8
gBitDepth = 8
bBitDepth = 8
file = open("output.txt", "w")
file.write("{")
precision = 1000
for r in range(rBitDepth+1):
    for g in range(gBitDepth+1):
        for b in range(bBitDepth+1):
            file.write("\n")
            rRatio = round(r/rBitDepth * precision)/precision
            gRatio = round(g/gBitDepth * precision)/precision
            bRatio = round(b/bBitDepth * precision)/precision
            rRatio = round(rRatio * 255)
            gRatio = round(gRatio * 255)
            bRatio = round(bRatio * 255)
            idxAddress = (rRatio << 16) | (gRatio << 8) | bRatio
            file.write('['+str(idxAddress)+'] = Color3.new(' + str(r/rBitDepth) + "," + str(g/gBitDepth) + "," + str(b/bBitDepth) + "),")
file.write("}")
file.close()

r=255
g=168
b=74
bitData = (r << 16) | (g << 8) | b
print(bitData)
extractedR = (bitData >> 16) & 0xFF
extractedG = (bitData >> 8) & 0xFF
extractedB = bitData & 0xFF
print(extractedR, extractedG, extractedB)