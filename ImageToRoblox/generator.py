from PIL import Image
from numpy import asarray

image = Image.open("example.png")
numpydata = asarray(image)
file = open("output.txt", "w")

count = 0
file.write("{\n")
for x in numpydata:
    file.write("{\n")
    for y in x:
        file.write("{\n")
        file.write(str(y[0]) + ", " + str(y[1]) + ", " +  str(y[2]))
        count += 1
        file.write("\n},")
    file.write("\n},")
file.write("}")
file.close()
