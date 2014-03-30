Xbox One Controller Enabler
===========================

![alt tag](https://raw.github.com/guilhermearaujo/xboxonecontrollerenabler/master/screenshot.png)

What is it?
-----------

Microsoft released in 2013 their new console Xbox One along with its new Controller.
Just like the Xbox 360's controller, it is expected that it will be compatible with computers as well.
A Windows driver is expected to be released in 2014, but nothing was announced with respect to Mac.

This application communicates with the Xbox One Controller and uses a Virtual Joystick to simulate the controller.

Where can I get it?
-------------------

Get your compiled copy [here](https://www.dropbox.com/sh/cx4m6so6vl5j4w7/V91El05FQ_).
Source code is available on [GitHub](https://github.com/guilhermearaujo/xboxonecontrollerenabler).

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

I'd like to contribute!
-----------------------

Well... This is on GitHub, isn't it? [Fork this project](https://github.com/guilhermearaujo/xboxonecontrollerenabler/fork), write some code and [open a pull request](https://github.com/guilhermearaujo/xboxonecontrollerenabler/pulls).
You know what to do!

### Thanks to:

* Kyle Lemons for figuring out how to power the controller (check his [xbox](https://github.com/kylelemons/xbox) project).
* Brandon Jones for nicely laying out the [button mapping](http://blog.tojicode.com/2014/02/xbox-one-controller-in-chrome-on-osx.html) of the controller.
* Lucas Assis for his work on [Windows drivers](https://xboxonegamepad.codeplex.com/) for the controller.
* Alexandr Serkov for providing nice Virtual HID drivers ([WJoy](https://code.google.com/p/wjoy/)).