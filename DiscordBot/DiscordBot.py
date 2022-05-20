import discord  #Import the discord api tools.
from discord.ext import commands
import os

bot = commands.Bot(command_prefix='!')

@bot.event
async def on_ready():
    print("Logged in as")
    print(bot.user.name)
    print(bot.user.id)
    print("------------------")

@bot.event
async def on_message(message):
    if(message.author.name != bot.user.name):
        print("User " + message.author.display_name + "(" + message.author.name + ") said: " + message.content)
        print("Channel: " + message.channel.name + " Server: " + message.guild.name)
        await bot.process_commands(message)
    else:
        return

for filename in os.listdir("./Cogs"):
    if filename.endswith(".py"):
        bot.load_extension(f'Cogs.{filename[:-3]}')

bot.run('')
