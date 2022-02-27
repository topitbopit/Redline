
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/banner1.png)

## Notice
**This is in insanely early beta! Only like 12 things actually work (and some are still unfinished)**  

## What is Redline?
Redline is a massive *universal* script designed for lots of customization, ease of use, and many unique features. 

It is designed after and inspired by the many popular hacked clients of Minecraft, such as [Meteor](https://meteorclient.com/), [Aristois](https://aristois.net), and [Impact](https://impactclient.net/).   

>**Note that this is not for Roblox Bedwars, Roblox Skywars, or other similar games.** This is a universal script intended to work across many / all games.

## Script
```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/loader.lua'), 'redline is pretty epic')()
```

## Preview
Classic theme  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/classic.png | width=600)  
Dark theme  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/dark.png | width=600)  
Blue theme  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/blue.png | width=600)  
Cold theme  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/cold.png | width=600)  

## Why use it?  
- **Customizability.** Nearly every module has tons of settings to toy around with.  
- **Optimization.** Every module is extremely optimized. Even on lower end hardware, Redline will still run quick.  
- **Built from scratch.** No code is copy pasted from anywhere, and everything is 100% original.  
- **Security.** Many uncommon checks in local anticheats are bypassed, and nearly every Redline mod is done in a unique, original way. This is definitely safer than other universal scripts.  
>*Note that bypasses are universal and not a game per game basis, so certain anticheats may still detect you. Make sure to test on an alt and use the standard methods if you're not*  

## Q/A  
- **A game I play detects a module, can you bypass it?**  
Open up an issue or DM me (topit#4057) and I'll check it out. Since this is a universal script *(and I'm definitely not just lazy)* I probably won't bypass game specific anticheats.  

- **When will UI configuration be added?**  
There is no ETA, but it will be added in another window meant for UI settings, themes, etc.  

- **Can I whitelist my friends from a certain mod (ex. prevent them from setting off antifling)?**  
Although there is no menu to add friends yet, Redline does have internal support for a friends list and player whitelisting.  

- **Can I use the UI library?**  
Sure, but Redline's UI is lacking a lot of features (like color pickers) most libraries have. It's also heavily tied into the script itself; you'll have to change how a lot of things work.  

- **Can I copy / use some of the code?**  
Yes. However, Redline is under the GPL 3 license. Make sure your project follows that license if you copy/paste anything.  

- **Why won't Redline execute?**  
Make sure your executor is supported. Open up an issue / DM me the error you get.  

- **There's an issue with a module, when will you fix it?**  
If it's a mod in beta like ESP then I'll likely fix it soon. If it's not a beta module, open up an issue or DM me and I'll fix it.  

## Supported executors  
- **Synapse X** - fully tested  
- **Comet** - partially tested
- **Fluxus** - fully tested  

Other exploits will likely work, so if you're unsure still give it a try (and DM me if it works!).  

## Mods (modules?)  
Unfortunately the list of mods - along with their settings and descriptions - changes all the time and I don't want to update it here  

## Planned features
- More mods, such as  
	- Discord rich presence integration  
	- Roblox alt manager integration  
	- Aimbot  
	- Triggerbot  
- Advanced UI Configuration  
	- Customize and share themes with others as well as view them real-time  
- Server browser  
	- View other servers and sort by ping, player count, and more  
- Command bar  
	- Easily enable and disable mods, as well as run simple commands  
- Plugins  
	- Lets you add custom commands, modules, and more  

## Changelog
Current version: 0.4.1  
Dates will follow MM/DD/YYYY  
 

Version 0.4.1 (2/26/2022)  
- Added a loop mode to Zoom   
- Added mouse shake option to Autoclicker  
- Added multiclick to Autoclicker  
- Added noclip module  
- Added ok button to notifications  
- Changed fullbright a bit  
- Fixed an issue with Freecam bypass breaking  
- Hid combat menu (for now) since the only mod on it is unfinished  
- Improved Player Notifs performance  
- Improved anticheat bypass a bit, might take less memory (depends on your exploit)  
- Improved antiwarp a bit  
- Improved notification performance  
- Included display names on Player Notifs  
- Possibly fixed issues with Blink and Fakelag breaking  
- Right clicking sliders now lets you enter a custom value  
 
Version 0.4.0  
- Added a custom mouse cursor, good for games w/o mouse icons  
- Added another ESP mode (Lines)  
- Disabled Triggerbot while its being remade  
- Fixed slide animation not happening when the gui first gets toggled  
- Hopefully improved mem usage since a ton of player handler stuff was remade  
- Improved ESP's stability a ton  
- Players leaving / joining should cause less overhead now  
- Removed a bunch of comments & unused module shit, improving load times  
- Removed Changelog from the script, its now located on the github
- Removed redundant calculations in freecam  
- Replaced notif icons  
- Replaced the logo at the top left  
- Updated Fakelag and Blink to be compatible with both R6 and R15  

Version 0.3.2.1  
- Fixed a bug with how sliders displayed, which affected the colors  
- Updated every theme to be compatible with these changes  

Version 0.3.2  
- Added a cyan theme called Cold  
- Edited how the blue theme looks again  
- Lowered Speed's max value from 300 to 100  
- Removed the Gray theme since it sucks  

Version 0.3.1  
- Added Animspeed module that changes the speed of your animations  
- Added a few tooltips for mods like Autoclicker  
- Edited the blue theme to make it look better  
  
Version 0.3.0  
- Added ESP module  
- Added Fullbright module w/ several modes and optional looping  
- Added a config file, only saves themes for now  
- Added ui theme module w/ several presets, preview hasn't been finished but there will be one  
- Almost finished 2d Box ESP, other modes are unfinished as of now  
- Fixed antifling anchor keeping you anchored after disabling it when it was triggered  
- Fixed labels not having padding  

  

Version 0.2.0  
- Added a Mod list module (under UI)  
- Added a [BETA] tag for mods in beta  
- Added a startup animation + sound  
- Almost finished antiaim  
- Changed the enable color to be the classic Redline red  
- Dropdown options can now be selected with right click  
- Finished Autoclicker  
- Hid all of the unfinished modules, hopefully it won't look weird with everything gone  
- Removed the [Done] tags  
- Slightly improved performance when switching modes while a mod was enabled  

Version 0.1.1  
- Finished Fakelag and Blink  
- Almost finished Triggerbot, team check and spam may have issues  
- Started work on Antiaim  

Version 0.1.0  
- Added Fakelag mod  
- Added Sound option to Player notifs  
- Added another notification sound  
- Added changelog menu, new changes will be documented here  
- Added server browser mod  
- Finished Parkour, Velocity, and Nofall  
- Made mouse unlock when the Redline window is open  
- Marked Jeff and Player notifs as done  
- Removed Logs since player logs aren't that important  
- Renamed Fastfall to Nofall  
