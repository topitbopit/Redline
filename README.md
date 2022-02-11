![](https://cdn.discordapp.com/attachments/917914099759849482/940857063733612584/banner.png)

## Notice
**This is in insanely early beta! Only like 5 things actually work (and even so are still unfinished)**  
Scroll down to the modules section to see what's working

## What is Redline?
Redline is a massive universal script intended for customization, ease of use, and security. 

It is designed after and inspired by the many popular hacked clients of Minecraft, such as [Meteor](https://meteorclient.com/), [Entropy](https://entropy.club), [Impact](https://impactclient.net/), and more.   

>**Note that this is not for Roblox Bedwars, Roblox Skywars, or other similar games.** This is a universal script intended to work across many / all games.

>**Note that Redline is still in beta.** Many features are not working yet.

## Script
```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/loader.lua'), 'redline is pretty epic')()
```

## Preview
![](https://cdn.discordapp.com/attachments/917914099759849482/940853797624905728/sample.png)

## Why use it?
- **Customizability.** Nearly every module has tons of settings to toy around with.
- **Features.** Redline has tons of unique features that have never been seen, such as Discord Rich Presence.
- **Speed.** Redline is designed to be super fast and easy to use.  No annoying menus to navigate, no textboxes to type in, and no clutter on your screen.
- **Optimization.** Every module is extremely optimized. Even on lower end hardware, Redline will still run quick. 
- **Security.** Many uncommon checks in local anticheats are bypassed, and nearly every Redline module is handled in a unique, hard-to-detect way. This is definitely safer than other universal scripts.  
>*Note that bypasses are universal and not a game per game basis, so certain anticheats may still detect you. Make sure to use an alt!*

## Q/A
**This mod is detected in this game**   
Open up an issue or DM me (jeffismyname#4316) and I'll check it out.  
Note that game specific, serverside anticheats are most likely not gonna be bypassed. (ex. Jailbreak or Phantom forces)  
**When will UI configuration be added?**    
There is no ETA, but it will be added eventually in another window.   
**Can I whitelist my friends from a certain mod (ex. prevent them from being locked onto with aimbot)?**  
Although there is no menu to add friends yet, Redline does have internal support for a friends list and player whitelisting. It will be added soon.    
**Can I use the ui library?**   
Sure, but Redline's UI was made specifically for Redline. Most stuff that you want is probably not gonna be there. Also, read the question below.   
If you want a similar library that might have more features, check out [Herrtt's aimhot library](https://github.com/Herrtt/AimHot-v8/blob/master/UiLib.lua)  
**Can I copy / use some of the code?**   
Yes. However, Redline is under the GPL 3 license. Make sure your project follows that license if you copy/paste anything.    
If you want to instead just remake what I did but use the same methods (ex. flight, speed), then go ahead     
**What does X module do**    
Open up an issue or DM me if a module description isn't clear   
**Why won't Redline execute?**  
Make sure your executor is supported. Open up an issue / DM me the error you get.   

## Supported executors  
- Synapse X, fully tested   
- Comet, fully tested  
- Fluxus, fully tested  
Others may work and will be tested soon.   
  

## Modules   
  
### Combat
**Aimbot**  [PLANNED]    
*Classic FPS mouse aimbot. Has locking and prediction*  
**Anti-aim**   
*Spins you around to prevent others from headshotting you*  
**Hitboxes**  [PLANNED]    
*Hitbox expander*  
**Stare**  [PLANNED]     
*Constantly looks at someone when you get in range of them. Useful for swordfighting games*  
**TPbot**  [PLANNED]    
*Teleports you around someone when you get in range of them. Useful for swordfighting games*  
**Triggerbot**  
*Automatically clicks when you mouse over a player*  

### Player  
**Anti-AFK**    
*Prevents you from being disconnected for idling*  
**Anti-fling**  
*Prevents you from being flung by other players*  
**Anti-warp**   
*Prevents you from being teleported (as in a position change, not across places / games)*  
**Autoclicker**   
*Clicks for you. Has tons of modes, like jitter and double click*  
**Fancy chat**  [PLANNED]    
*Makes your chat fancy*  
**Flashback**   
*Teleports you back to where you were before you died*  
**Pathfinder** [PLANNED]   
*Automatically pathfinds to a point you choose. Kinda like baritone but without all of the extra features*  
**Radar** [PLANNED]    
*Radar that displays where other players are*  
**Respawn**    
*Force resets you. Can fix some glitches with reanimations*  
**Waypoints** 
*Lets you save positions and teleport back to them later*


### Movement  
**Air jump**     
*Lets you jump in the air*   
**Blink**   
*Pseudo lagswitch. Doesn't actually choke packets*   
**Click TP**     
*Standard click TP*  
**Flight**     
*Standard fly with tons of options*  
**Float**    
*Low gravity or no gravity*  
**High jump** [PLANNED]     
*Lets you jump higher*  
**Ice** [PLANNED]    
*Makes you walk like you're on ice*  
**Jesus** [PLANNED]     
*Lets you walk over dangerous parts*  
**Jetpack** [PLANNED]     
*Like flight, but you're affected by gravity and can accelerate by pressing space*  
**Noclip** [PLANNED]   
*Standard noclip*   
**Nofall**  
*Makes you quickly fall or bounce before you hit the ground. Useful for bypassing fall damage mechanics in games like Natural Disaster Survival*  
**Noslowdown** [PLANNED]    
*Prevents you from being slowed down; your walkspeed can't go under 16 and you can't be anchored*  
**Parkour**    
*Automatically jumps when you reach the end of a block*  
**Phase** [PLANNED]    
*Teleports you insanely fast around a central position. Useful for games like Prison Life to avoid arrests*  
**Safewalk** [PLANNED]    
*Prevents you from walking off of a part*  
**Speedhack**      
*Classic speedhack. Has plenty of modes*  
**Spider** [PLANNED]   
*Lets you climb up parts like a spider*  
**Step** [PLANNED]    
*Teleports you up when you walk into a part*  
**Velocity**     
*Limits or disables your velocity*  
  
### Render  
**Better UI** [PLANNED]     
*Improves Roblox UIs like the chat and inventory*   
**Breadcrumbs** [PLANNED]    
*Leaves a trail behind you*   
**Camera tweaks** [PLANNED]   
*Modify lots of camera attributes like camnoclip, max zoom. etc)   
**Crosshair** [PLANNED]  
*Drawing crosshair configuration*   
**ESP** [PLANNED]   
*Standard ESP with tons of configuration*   
**Freecam**   
*Flight but you control your camera*  
**Fullbright**  [PLANNED]   
*Disables lighting. Has several presets that may work for different games*  
**Nametags**  [PLANNED]    
*Detailed nametags above every player*  
**Zoom**  
*Like Optifine zoom*  
  
### UI  
**Command bar**   [PLANNED]  
*Command bar that lets you quickly toggle modules with a textbox. Also has mods that aren't in the main gui like .tooldupe*  
**Jeff**   
*I forgor what this does* :skull:  
**Player alerts**  
*Notifies you when a player joins or leaves*   
**Mod list**     
*Shows what mods are currently enabled*   
   
### Server   
**Private server**   [PLANNED]   
*Server hops to the smallest server*   
**Rejoin**  
*Rejoins the current server*  
**Serverhop**  [PLANNED]   
*Server hops to a random server*  
**Server browser** [PLANNED]   
*Lets you view existing servers and join them*   


### Integrations  
**Discord Rich Prescence**  [PLANNED]   
*Show everyone else how cool you are for using Redline*  
**Roblox Alt Manager**  [PLANNED]    
*Lets you manage and use your alts. Requires the Roblox Alt Manager program.*  
    
