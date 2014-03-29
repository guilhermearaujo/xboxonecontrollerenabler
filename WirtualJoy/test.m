//
//  test_client.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <WirtualJoy/WJoyDevice.h>

static const unsigned char hidDescriptorData[] = {
	// initial defaults
	0x05, 0x01,                    // USAGE_PAGE (Generic Desktop)
	0x15, 0x00,                    // LOGICAL_MINIMUM (0)
	0x09, 0x04,                    // USAGE (Joystick)  // joystick = 4, gamepad = 5
	0xa1, 0x01,                    // COLLECTION (Application)
	0x15, 0x81,                    //   LOGICAL_MINIMUM (-127)
	0x25, 0x7f,                    //   LOGICAL_MAXIMUM (127)
	0x75, 0x08,                    //   REPORT_SIZE (8)

	// throttle
//	0x05, 0x02,                    //   USAGE_PAGE (Simulation Controls)
//	0x09, 0xbb,                    //   USAGE (Throttle)
//	0x95, 0x01,                    //   REPORT_COUNT (1)						// 0 byte
//	0x81, 0x02,                    //   INPUT (Data,Var,Abs)

	// rudder
//	0x09, 0xba,                    //     USAGE (Rudder)    
//	0x95, 0x01,                    //     REPORT_COUNT (1)					// 0 byte
//	0x81, 0x02,                    //     INPUT (Data,Var,Abs) 

	// primary axis
	0x05, 0x01,                    //   USAGE_PAGE (Generic Desktop)
	0x09, 0x01,                    //   USAGE (Pointer)
	0xa1, 0x00,                    //   COLLECTION (Physical)
	0x09, 0x30,                    //     USAGE (X)
	0x09, 0x31,                    //     USAGE (Y)
//	0x09, 0x32,                    //     USAGE (Z)
	0x95, 0x02,                    //     REPORT_COUNT (2)					// 2 bytes
	0x81, 0x02,                    //     INPUT (Data,Var,Abs)
	0xc0,                          //   END_COLLECTION

	// secondary axis
	0xa1, 0x00,                    //   COLLECTION (Physical)
	0x09, 0x33,                    //     USAGE (Rx)
	0x09, 0x34,                    //     USAGE (Ry)
//	0x09, 0x35,                    //     USAGE (Rz)
	0x95, 0x02,                    //     REPORT_COUNT (2)					// 2 bytes
	0x81, 0x02,                    //     INPUT (Data,Var,Abs)
	0xc0,                          //   END_COLLECTION
	
	// third axis ?
	
	// d-pad ? X,Y seems best for most compatibility

	// buttons
	// need 28 (1c, 3.5 bytes) if we separate wii remote and classic
	0x05, 0x09,                    //   USAGE_PAGE (Button)
	0x19, 0x01,                    //   USAGE_MINIMUM (Button 1)
	0x29, 0x0B,                    //   USAGE_MAXIMUM (Button 11)
	0x15, 0x00,                    //   LOGICAL_MINIMUM (0)
	0x25, 0x01,                    //   LOGICAL_MAXIMUM (1)
	0x75, 0x01,                    //   REPORT_SIZE (1)
	0x95, 0x0B,                    //   REPORT_COUNT (11)						// 2 bytes
	0x55, 0x00,                    //   UNIT_EXPONENT (0)
	0x65, 0x00,                    //   UNIT (None)
	0x81, 0x02,                    //   INPUT (Data,Var,Abs)

	// hat switch, does anyone care?
//	0x09, 0x39,                    //   USAGE (Hat switch)
//	0x15, 0x00,                    //   LOGICAL_MINIMUM (0)
//	0x25, 0x07,                    //   LOGICAL_MAXIMUM (7)
//	0x35, 0x00,                    //   PHYSICAL_MINIMUM (0)
//	0x46, 0x3b, 0x01,              //   PHYSICAL_MAXIMUM (315)
//	0x65, 0x14,                    //   UNIT (Eng Rot:Angular Pos)
//	0x75, 0x04,                    //   REPORT_SIZE (4)	// 0.5 bytes	// 0
//	0x95, 0x01,                    //   REPORT_COUNT (1)
//	0x81, 0x02,                    //   INPUT (Data,Var,Abs)

	0xc0                           // END_COLLECTION
};

/*

typedef enum
{
	WiiRemoteOneButton,
	WiiRemoteTwoButton,
	WiiRemoteAButton,
	WiiRemoteBButton,
	WiiRemoteMinusButton,
	WiiRemoteHomeButton,
	WiiRemotePlusButton,
	WiiRemoteUpButton,
	WiiRemoteDownButton,
	WiiRemoteLeftButton,
	WiiRemoteRightButton,
	
	WiiNunchukZButton,
	WiiNunchukCButton,
	
	WiiClassicControllerYButton, // 14th
	WiiClassicControllerXButton,
	WiiClassicControllerAButton,
	WiiClassicControllerBButton,
	WiiClassicControllerMinusButton,
	WiiClassicControllerHomeButton,
	WiiClassicControllerPlusButton,	
	WiiClassicControllerLeftButton,
	WiiClassicControllerRightButton,
	WiiClassicControllerDownButton,
	WiiClassicControllerUpButton,
	
	WiiClassicControllerLButton,
	WiiClassicControllerRButton,
	WiiClassicControllerZLButton,
	WiiClassicControllerZRButton,	// 15 more
	
	WiiNumberOfButtons
} WiiButtonType;

typedef enum
{
	hid_button    = 0,
	hid_XYZ       = WiiNumberOfButtons,
	hid_rXYZ      = WiiNumberOfButtons + 1,
} my_hidElements;

static const size_t         hidStateDataSize = 6;

bool WiijiDevice::update(const void *state, size_t stateSize)
{
    if(stateSize != 3)
        return false;

    const unsigned char *buttonVector = static_cast< const unsigned char* >(state);
    unsigned char target = buttonVector[0];

    switch(target)
    {
        case hid_XYZ:
            m_HIDStateData[0] = buttonVector[1];
            m_HIDStateData[1] = buttonVector[2];
            break;

        case hid_rXYZ:
            m_HIDStateData[2] = buttonVector[1];
            m_HIDStateData[3] = buttonVector[2];
            break;

        case WiiRemoteUpButton:
        case WiiRemoteDownButton:
            m_HIDStateData[0] = buttonVector[1] * ((target == WiiRemoteDownButton)*(127) - (target == WiiRemoteUpButton)*(127));
            break;

        case WiiRemoteRightButton:
        case WiiRemoteLeftButton:
            m_HIDStateData[1] = buttonVector[1] * ((target == WiiRemoteLeftButton)*(127) - (target == WiiRemoteRightButton)*(127));
            break;

        default:
            if(target >= WiiRemoteUpButton)	// compensate for the unused dpad button inputs (we route it to x/y right now)
                target -= 4;
            
            int bitoffset = target % 8;
            int octet     = target / 8 + 4;
            unsigned char action  = 0x0001 << bitoffset;
        
            if (octet >= hidStateDataSize)
                return false;
        
            if(buttonVector[1])
                m_HIDStateData[octet] = m_HIDStateData[octet] | action;
            else
                m_HIDStateData[octet] = m_HIDStateData[octet] & ~action;
            break;
    }

    return m_Device.updateState(m_HIDStateData, sizeof(m_HIDStateData));
}

*/

int main(int argC, char *argV[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    WJoyDevice *device = [[[WJoyDevice alloc] initWithHIDDescriptor:[NSData dataWithBytes:hidDescriptorData length:sizeof(hidDescriptorData)]] autorelease];

    if(device == nil)
        NSLog(@"Error!");
    else
        NSLog(@"Ok!");

    if(![device updateHIDState:nil])
        NSLog(@"error update state!");

    [pool release];
    return 0;
}
