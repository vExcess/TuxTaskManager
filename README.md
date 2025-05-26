# TuxTaskManager
Task Manager for Linux.

#### The app isn't available for download yet and it's still in the very early phases of development, but it's coming along nicely. Should have a version 1.0 out soon.

## About
Linux has Gnome System Monitor, but I personally prefer the design of Windows Task Manager.  

Here are the existing Windows-like task managers for Linux:  
- SysMonTask [https://github.com/KrispyCamel4u/SysMonTask](https://github.com/KrispyCamel4u/SysMonTask)
	- hasn't been updated in 4 years
	- multiple stats are broken
	- doesn't show my GPU usage
	- written in the language with the speed of a paraplegic tortoise crawling across a row of punchcards (Python)
- Mission Center [https://gitlab.com/mission-center-devs/mission-center](https://gitlab.com/mission-center-devs/mission-center)
	- didn't show my GPU usage (EDIT: now it does)
	- the graph gets squished ugly when I make the window small
	- I hate `border-radius: 200px` on everything
- WSysMon [https://github.com/SlyFabi/WSysMon](https://github.com/SlyFabi/WSysMon)
	- hasn't been updated in 3 years
	- Only NVIDIA GPUs using the proprietary driver are detected
	- I couldn't figure out how compile it successfully (I have C++ skill issue)

When I started this project, none of the above suited my needs. Now I suppose Mission Center is adequate, but I'm still creating my own app simply because I want to nitpick about stylistic GUI choices. I like my apps to be make out of rectangles, not circles.

#### Why not just fork an existing project?
I don't know cringe languages such as Python (SysMonTask), C (Mission Center), and C++ (WSysMon). I only know cool languages like Zig and Dart.

## OS Support
[✔] Debian + derivatives (Ubuntu, Mint, etc.)  
[?] Arch + derivatives  
[?] Fedora + derivatives  
[X] non-Linux operating systems

## TODO
- Support Nvidia and Intel cards
    - I need someone else to do this because I only have AMD cards.
- Literally everything else

## Build Locally
Compiling TuxTaskManager requires Dart. Install these other dependencies as well:  
`sudo apt-get install build-essential libsdl2-dev libcairo2-dev libpango1.0-dev libpng-dev libjpeg-dev libgif-dev`  
util-linux is for lscpu, procps is for sysctl  
`sudo apt install util-linux procps pkexec dmidecode`  
Then run:  
`dart compile exe src/main.dart -o dist/tuxtaskmanager`

## TuxTaskManager running on Linux Mint:
![screenshot](https://github.com/vExcess/TuxTaskManager/blob/master/preview.png?raw=true)
