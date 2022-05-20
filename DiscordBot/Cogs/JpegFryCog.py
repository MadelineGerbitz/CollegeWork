import discord
from discord.ext import commands

import random
import urllib.request
from PIL import Image

opener = urllib.request.build_opener()
opener.addheaders=[('User-Agent', 'Mozilla/5.0')]
urllib.request.install_opener(opener)

class FryCog(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    @commands.Cog.listener()
    async def on_ready(self):
        print("Fry cog loaded!")

    @commands.command()
    async def Fry(self, ctx):
        """Fries an attached image"""
        url = ctx.message.attachments[0].url
        type = url[-3:]
        urllib.request.urlretrieve(url, "fry.{}".format(type))
        await ctx.send("Order up!")
        if(type == "png"):
            img = Image.open("fry.png")
            if(img.mode == "RGBA"):
                print("here " + img.mode)
                img = img.convert("RGB")
                img.save("fried.jpg", "JPEG", quality=random.randint(0,5), optimize=True, progressive=True)
            img.save("fried.jpg", "JPEG", quality=random.randint(0,5), optimize=True, progressive=True)
            await ctx.send(file=discord.File("fried.jpg"))
        elif(type == "jpg"):
            img = Image.open("fry.jpg")
            img.save("fried.jpg", "JPEG", quality=random.randint(0,5), optimize=True, progressive=True)
            await ctx.send(file=discord.File("fried.jpg"))
        else:
            await ctx.send("Sorry, but your order was just too shitty...")


def setup(bot):
    bot.add_cog(FryCog(bot))
