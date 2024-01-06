# TuxTaskManager
Task Manager for Linux. TuxTaskManger's backend is written in Rust which is blazingly fast™ 🚀.

#### The app isn't available for download yet and it's still in the very early phases of development, but it's coming along nicely. Should have a version 1.0 out soon.

## About
Linux has Gnome System Monitor, but I personally prefer the design of Windows Task Manager.  

Here are the existing Windows like Task Managers for Linux:  
- SysMonTask [https://github.com/KrispyCamel4u/SysMonTask](https://github.com/KrispyCamel4u/SysMonTask)
	- hasn't been maintained in 3 years
	- multiple stats are broken
	- doesn't show my GPU usage
	- written is the sluggish language that is Python
- Mission Center [https://gitlab.com/mission-center-devs/mission-center](https://gitlab.com/mission-center-devs/mission-center)
	- doesn't show my GPU usage
	- the graph gets squished ugly when I make the window small
- WSysMon [https://github.com/SlyFabi/WSysMon](https://github.com/SlyFabi/WSysMon)
	- hasn't been maintained in 2 years
	- Only NVIDIA GPUs using the proprietary driver are detected
	- I couldn't figure out how compile it successfully. This is just me being a noob at C++

I just want a task manager that works, is easy to install, and is similiar to the Windows layout. Hence I am creating my own.


#### Preview of the current phase in development:
![screenshot](https://github.com/vExcess/TuxTaskManager/blob/master/preview.png?raw=true)
