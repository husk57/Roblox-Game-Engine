
import math
rBitDepth = 8
gBitDepth = 8
bBitDepth = 8
file = open("output.txt", "w")
file.write("{")
count = 0
precision = 1000
for r in range(rBitDepth+1):
    for g in range(gBitDepth+1):
        for b in range(bBitDepth+1):
            file.write("\n")
            count = count + 1
            rRatio = math.floor(r/rBitDepth * precision)/precision
            gRatio = math.floor(g/gBitDepth * precision)/precision
            bRatio = math.floor(b/bBitDepth * precision)/precision
            rStr = "{:.3f}"
            rStr = rStr.format(rRatio)
            gStr = "{:.3f}"
            gStr = gStr.format(gRatio)
            bStr = "{:.3f}"
            bStr = bStr.format(bRatio)
            file.write('["'+rStr+"a"+gStr+"a"+bStr+'"] = Color3.new(' + str(r/rBitDepth) + "," + str(g/gBitDepth) + "," + str(b/bBitDepth) + "),")
file.write("}")
file.close()
print(count)
