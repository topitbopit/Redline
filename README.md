<!-- banner -->
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/banner1.png)  

<!-- beta notice -->
## Notice  
**This is in insanely early beta! Only like 14 things actually work**  

<!-- script since nobody cares about the explanation -->
## Loadstring  
```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/loader.lua'))()  
```

<!-- explanation -->
## What is Redline?  
Redline is a massive universal script based on many popular Minecraft hacked clients. It's customizable, easy to use, and packed with features.  

## Why use Redline?  
- **There's tons of options.** Every module has tons of configuration, giving you a completely unique and customizable experience.  
- **It's extremely optimized.** No extra bloat, no super laggy code. Redline is very lightweight and doesn't leave any traces.  
- **It's built from scratch.** Everything you see in Redline was made from the ground up.  
- **It's secure.** Redline bypasses many common detections other scripts don't. (I'm looking at you, IY)  
- **It has too many features.** Most scripts just have aimbot, esp, and flight if you're lucky. Redline has everything.  

<!-- showcases -->
## Screenshots  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/arsenal.png)  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/scp_roleplay_1.png)  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/scp_roleplay_2.png)  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/3008.png)  
## Showcases  
- Haven't made any videos yet, check back later  

## Q/A  
- **A game I play detects a module, can you bypass it?**  
Open up an issue or DM me (topit#4057) and I'll check it out. Since this is a universal script *(and I'm definitely not just lazy)* I won't bypass game specific anticheats.  

- **When's the next update?**  
I don't have a regular update schedule, but I try to shoot for atleast 3 updates a month.  

- **Can I whitelist my friends from a certain mod (ex. prevent them from setting off antifling)?**  
You will be able to later.  

- **Can I copy / use some of the code?**  
Yes, but Redline is under the GPL 3 license. Make sure your project follows that license too if you copy / paste anything.  

- **Why won't Redline execute?**  
Make sure your executor is supported. Open up an issue / DM me the error and I'll fix it fast.  

- **Hey the inertia theme looks like dogshit**  
Don't worry i deleted it  

- **Why do you spend so much time on shitty features**  
No clue  

- **Can I make my own fork / contribute?**  
Yes, but good luck figuring out what my code does cause got damn it sucks  

- **Hi**  
Hi  
  
## Supported executors  
- **Synapse X** - fully tested  
- **Fluxus** - fully tested  
- **WRD executors (Nihon, JJsploit, etc.)** - mostly tested, 1-2 things may not be working  

Other exploits will likely work, so if you're unsure still give it a try (and DM me if it works!)  

## Mods (modules?)  
Unfortunately the list of mods - along with their settings and descriptions - changes all the time and I don't want to update it here  

## Planned features  
- More mods, such as  
	- Discord rich presence  
	- Triggerbot  
- Advanced UI Configuration  
	- Customize themes in real-time and share them with others  
- Server browser  
	- View other servers and sort by ping, player count, and more  
- Command bar  
	- Easily enable and disable mods, as well as run simple commands  
- Plugins  
	- Lets you add custom commands, modules, and more  

## Changelog  
Current version: 0.5.1  
Dates will follow MM/DD/YYYY  

Version 0.5.1 (3/11/2022)  
- Added check for Drawing library  

Version 0.5 (3/10/2022)  
- Added Aimbot module  
- Added Crosshair module, uses Drawing library  
- Added Dash module  
- Added Safe Minimize module, anchors your character when Roblox loses focus  
- Added back combat tab  
- Added new Anti-fling mode (Anchor + Safemin)  
- Added new Noclip mode (Bypass), doesn't do much yet  
- Added new Nofall mode (Glide)  
- Added potential forward support for customasset'ing fonts  
- Added proper icons for textboxes and buttons  
- Added tween option to Click TP  
- Changed Respawn, now it's an actual toggleable module with functionality  
- Changed how menu open animation worked, spamming rshift no longer breaks it  
- Changed how mouse cursor animates  
- Changed sliders, now they can now be interacted anywhere instead of just on the bar  
- Changed sound effects and replaced them with newer ones  
- Changed the speed of some tween animations  
- Fixed notification bug where they wouldn't stack properly  
- Fixed slider input boxes  
- Fixed some stuff in \_G not clearing out  
- Fixed toggle boxes looking jank depending on the theme  
- Optimized nofall a bit more  
- Remade intro to use Drawing library  
- Remade menu dragging logic, way more optimized  
- Remade some themes like Dark, removed others  
- Removed extra RGB loops, most mods use the same one now  
- Removed search temporarily, working on a new system better for features like these  
- Reworked theme system a bit, themes no longer have unused colors and outlines can have gradients  
- Updated how slider text displays to work with a new roblox change  

Version 0.4.1.1 (2/28/2022)  
- Fixed bug where non fluxus and non synapse users couldn't execute. Sorry for any inconvenience  

Version 0.4.1 (2/26/2022)  
- Added a loop mode to Zoom   
- Added mouse shake option to Autoclicker  
- Added multiclick to Autoclicker  
- Added noclip module  
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
