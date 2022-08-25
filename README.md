![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/thread_text_beta.jpg)  

<!-- beta notice -->
## Notice  
**This is in insanely early beta! Only like 14 things actually work.**  
**Want to join the discord?**
Probably not but [here it is anyway](https://discord.gg/TyKZFQtDvw)

## Loadstring  
```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/loader.lua'))()  
```
## What is Redline?  
Redline is a massive universal script based on many popular Minecraft hacked clients. It's customizable, easy to use, and packed with features.  

## Why use Redline?  
- **There's tons of options.** Every module has tons of configuration, giving you a completely unique and customizable experience.  
- **It's extremely optimized.** Each module has been designed to be super quick.  
- **It's built from scratch.** Everything you see in Redline was made from the ground up.  
- **It's secure.** Redline bypasses many (un?)common detections other scripts might not.  
- **It has too many features.** Most scripts just have aimbot, esp, and flight if you're lucky. Redline has everything.  

## Screenshots  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/features.jpg)  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/gamedemo1.jpg)  
![](https://raw.githubusercontent.com/topitbopit/Redline/main/assets/gamedemo2.jpg)  

## Q/A  
- **How do I use Redline?**
When you execute it, press RightShift to open up the UI. Right click the menus to open up a list of modules under that category.  

- **Can I whitelist my friends from a certain mod (ex. not lock onto them with aimbot)?**  
This is a planned feature for the rewrite.  

- **Why won't Redline execute?**  
Make sure you pressed RightShift and there aren't any errors in console.  

- **Can I make my own fork / contribute?**  
Yes, but I'd wait for the rewrite as it is way more cleaner and in a more module-like format.  

- **Hi**  
Hi  
  
## Supported executors  
- All of them  


## Changelog  
Current version: 0.6.5  
Dates will follow MM/DD/YYYY   

Version 0.6.5 (8/25/2022)   
- Added Distance check to ESP   
- Changed a few default settings for ESP    
- Changed a few tooltips   
- Changed how files save, you might need to redownload your theme!   
- Fixed a bug with the ESP font, which only affected certain exploits   
- Hopefully fixed a bug with a nil theme   
- Hopefully fixed character manager Humanoid bug    
- Hopefully fixed queueing not disabling properly   
- Improved some older code a bit   
  
Version 0.6.4.1 (8/4/2022)   
- Increased Flight's speed cap from 250 to 350  
- Increased Speed's cap from 100 to 300  

Version 0.6.4 (7/26/2022)  
 - ! Sorry about the lack of updates  
 - Added Antiplayer mod  
 - Changed a few tooltips  
 - Changed the name and description of the respawn mod  
 - Fixed aimbot smoothness when the method is set to Mouse being inverted  
 - Removed glide module since it was useless  
 - Trying to execute redline when its already loaded now sends a notification instead of printing  

Version 0.6.3.1 (5/14/2022)  
- Fixed non-synapse exploits not being able to use Redline  (oops)  


Version 0.6.3 (5/14/2022)  
- ! Sorry about no updates, been working on some other stuff!
- Added more ESP settings
- Added option to move crosshair over target under Aimbot
- Added visual indicator to autoclicker
- Changed a bunch of tooltips to be more accurate
- Improved ESP a ton, now it's way more stable and doesn't memleak :troll:
- Improved Velocity a bit
- Remade some internal shit, most modules should be 0.00001% faster now (this also improves stability)
- Rewrote some parts of aimbot

Version 0.6.2 (3/25/2022)
 - Fixed queue_on_teleport not being triggered if a certain file was missing (i.e. queueing works now)

Version 0.6.1 (3/21/2022)  
 - ESP: Fixed not working on executors other than synapse. Thanks to TemporalTech for letting me know  
 - High jump: Now works on every jump, rather than just the first jump  
  
Version 0.6.0 (3/20/2022)  
- Added AutoHop mod  
- Added AutoReconnect mod  
- Added Glide mod  
- Added High Jump mod  
- Added Hitboxes mod  
- Added Keystrokes mod  
- Added NoTrip mod   
- Added Private Server mod  
- Added Serverhop mod   
- Added Sprint mod  
- Added Unfocused GPU mod   
- Added popups for games with custom char systems, like PF and bad business  
- Added support for the modlist mods to display a slider's value  
- Fixed Vehicle fly kicking you out of seats when enabled (Thanks Artemlist!)  
- Fixed redline watermark (top left) not showing up  
- Fixed teleport queueing not working, changed to a filesystem method  
- Improved input handler  
- Improved mod dragging  
- Improved mod placement on non 1920x1080 monitors  
- Made beta text change color based off of the theme (Thanks Artemlist!)  
- Remade a bunch of tooltips to be less retarded and more useful  
- Remade and renamed a bunch of themes  
- Removed a bunch of useless comments that bloated the file   
- Removed bundled ESP library, may improve mem usage  
- Removed redundant usage of getconnections  
  
*Mod specific changes *
  
- Air jump: fixed bug letting you jump while typing  
- Dash: Added a debounce option (Thanks Artemlist!)  
- Dash: Fixed bug where you would move less when your camera faced up or down  
- ESP: Completely remade with 4 modes, tracers, nametags, and more  
- Flashback: Now can flashback if you enable it while already dead  
- Flight: Fixed bug where camera-based would work funky  
- Flight: Remade a bunch of flight logic, way more optimized  
- Freecam: Made camera subject change p/ frame, meaning the camera focus won't change  
- Freecam: Remade a bunch of flight logic, way more optimized  
- Fullbright: Fixed connection spoofing thing not working  
- Fullbright: Hopefully improved loop mode  
- Fullbright: Switched to GetService instead of indexing game.Lighting  
- Nofall: Added new deceleration method  
- Nofall: Removed glide mode in favor of the new mod  
- Respawn: Now works if you were already dead  
- Zoom: Added key to toggle zoom without needing to toggle the mod self (Thanks Artemlist!)  
- Zoom: Fixed bug where looped mode wouldn't loop  
- Zoom: Fixed zoom not resetting to the game's normal FOV properly  


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
