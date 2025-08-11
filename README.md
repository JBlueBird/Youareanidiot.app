# Youareanidiot.exe for MacOS

***What is this?***

Youareanidiot.exe for MacOS is a prank app that mimics the classic *You Are An Idiot*.exe from Windows—but on Mac.  
It opens tons of windows playing the iconic video and keeps throwing up alerts that say “You are an idiot!” so you can annoy your friends (or yourself).


***Features***

- Opens multiple prank windows automatically  
- Plays the classic `youare.mp4` video in each window  
- Windows bounce and move around the screen  
- You can’t close the windows — they just pop up an alert instead  
- Random alerts saying “You are an idiot!” pop up on random windows every 5-15 seconds  
- Press **spacebar** to toggle window movement on/off  
- Minimal window style with no title bar  

***Credits***

*MacOS Port* 
- JBlueBird — for MacOS port programming  
  [https://github.com/JBlueBird](https://github.com/JBlueBird)  
- YouTube — for the original `youare.mp4` video  

*Original Creators / Inspiration*
- Jonty Lovell — created the original *youareanidiot*  
  [https://youareanidiot.cc/](https://youareanidiot.cc/)  
- Andrew Regner — created the original domain  
  [https://youareanidiot.org](https://youareanidiot.org)  
- ComputerVirusWatch — made variants of the `.exe` in 2013  
- "Cheap Radio Thrills" CD — music source  

***How to run it***

1. Clone or download this repo  
2. Open the project in Xcode  
3. Make sure `youare.mp4` is included in the app bundle  
4. Build and run on your Mac  
5. Watch the madness unfold  

***How it works (quick tech rundown)***

- SwiftUI app using AVKit for video playback  
- Manages multiple NSWindows that each play the prank video  
- Windows move and bounce around inside the screen bounds  
- Timer triggers random “You are an idiot!” alerts on random windows  
- Closing a window triggers an alert and stops it from closing  
- Press spacebar to toggle window movement  

---

***License***

© Birdie Works 2025. All rights reserved.  
Mit Licensed, do what you want.

> **Disclaimer**
>
>This is a harmless prank app for fun and nostalgia.  
>Use responsibly — don’t ruin anyone’s day!  
