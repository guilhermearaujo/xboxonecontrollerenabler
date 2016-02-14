Xbox One Controller Enabler
===========================

![alt tag](https://raw.github.com/guilhermearaujo/xboxonecontrollerenabler/master/screenshot.png)


Project deprecated
------------------
Use [360Controller](https://github.com/360Controller/360Controller/) instead (it supports Xbox One controllers).

What is it?
-----------

Microsoft released in 2013 their new console Xbox One along with its new Controller.
Just like the Xbox 360's controller, it is expected that it will be compatible with computers as well.
A Windows driver is expected to be released in 2014, but nothing was announced with respect to Mac.

This application communicates with the Xbox One Controller and uses a Virtual Joystick to simulate the controller.

Where can I get it?
-------------------

Get your compiled copy [here](https://github.com/guilhermearaujo/xboxonecontrollerenabler/releases).
Source code is available on [GitHub](https://github.com/guilhermearaujo/xboxonecontrollerenabler).

For OS X 10.10 Yosemite users
------------------

For extended compatibility, you will need to enable kext dev mode. To do so, run the following command on your terminal:  
`sudo nvram boot-args=kext-dev-mode=1`

What's under the hood?
----------------------

The USB communication is done using Apple's IOKit framework. The controller is polled every 5 ms looking for changes in the controller.

This application is built on top of Alexandr Serkov's great VHID and WirtualJoy frameworks, from his [WJoy](https://code.google.com/p/wjoy/ "WJoy Project on Google Code") project. These are responsible for the Virtual HID that the system will see as a controller.

This application doesn't work with this or that game!
-----------------------------------------------------

This is an ongoing project that will eventually be promoted from its current beta stage to a final version.
Feel free to [report issues](https://github.com/guilhermearaujo/xboxonecontrollerenabler/issues). Bugs will be tracked as soon as possible.

As long as I have time to learn more on how to implement the stuff it requires, improvements will be done.
Usability and compatibility are the main goals for now. Additional controllers, automatic connection, bells and whistles will come later.

How to build?
-------------

Update: a [libusb](http://www.libusb.org) installation is no longer needed as the library has been included in the project.

Just open the project in Xcode and run it!

I'd like to contribute!
-----------------------

Well... This is on GitHub, isn't it? [Fork this project](https://github.com/guilhermearaujo/xboxonecontrollerenabler/fork), write some code and [open a pull request](https://github.com/guilhermearaujo/xboxonecontrollerenabler/pulls).
You know what to do!

### Thanks to:

* Kyle Lemons for figuring out how to power the controller (check his [xbox](https://github.com/kylelemons/xbox) project).
* Brandon Jones for nicely laying out the [button mapping](http://blog.tojicode.com/2014/02/xbox-one-controller-in-chrome-on-osx.html) of the controller.
* Lucas Assis for his work on [Windows drivers](https://xboxonegamepad.codeplex.com/) for the controller.
* Alexandr Serkov for providing nice Virtual HID drivers ([WJoy](https://code.google.com/p/wjoy/)).
