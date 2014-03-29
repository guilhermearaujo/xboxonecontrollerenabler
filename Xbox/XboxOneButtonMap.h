//
//  XboxOneButtonMap.h
//  Xbox One Controller Enabler
//
//  Created by Guilherme Araújo on 27/03/14.
//  Copyright (c) 2014 Guilherme Araújo. All rights reserved.
//

//  Xbox One Controller Buttom Map
//  Originally by Brandon Jones
//  Adapted from http://blog.tojicode.com/2014/02/xbox-one-controller-in-chrome-on-osx.html

typedef struct {
  bool sync;
  bool dummy; // Always 0.
  bool menu;  // Not entirely sure what these are
  bool view;  // called on the new controller
  
  bool a;
  bool b;
  bool x;
  bool y;
  
  bool dpad_up;
  bool dpad_down;
  bool dpad_left;
  bool dpad_right;
  
  bool bumper_left;
  bool bumper_right;
  bool stick_left_click;
  bool stick_right_click;
  
  unsigned short trigger_left;
  unsigned short trigger_right;
  
  short stick_left_x;
  short stick_left_y;
  short stick_right_x;
  short stick_right_y;
  
  bool home;
} XboxOneButtonMap;

