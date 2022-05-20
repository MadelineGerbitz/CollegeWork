from PIL import Image
import random
a = 0
b = int(input("Saves? "))
c = str(input("File Number? "))
e = str(input("Iteration Number? "))
img = Image.open("in"+c+".jpg")
img.save("out"+c+""+e+".jpg", "JPEG", quality=100, optimize=True, progressive=False)
while a < b:
    d = random.randint(0,50)
    img = Image.open("out"+c+""+e+".jpg")
    img.save("out"+c+""+e+".jpg", "JPEG", quality=d, optimize=True, progressive=True)
    a = a + 1
    print(a)
