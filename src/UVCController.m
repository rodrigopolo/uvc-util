//
//  UVCController.h
//
//  USB Video Controller (UVC) interface to UVC-compatible video devices.
//
//  Copyright © 2016
//  Dr. Jeffrey Frey, IT-NSS
//  University of Delaware
//
// $Id$
//

//#define DEBUG_WRITE_UVC_HEADER_TO_FILE

#import "UVCController.h"
#include <string.h>

//
// UVC descriptor codes:
//
#define CS_INTERFACE            0x24

#define VC_HEADER               0x01
#define VC_INPUT_TERMINAL       0x02
#define VC_OUTPUT_TERMINAL      0x03
#define VC_SELECTOR_UNIT        0x04
#define VC_PROCESSING_UNIT      0x05
#define VC_EXTENSION_UNIT       0x06

// Video Streaming (VS) interface descriptor subtypes:
#define VS_INPUT_HEADER         0x01
#define VS_OUTPUT_HEADER        0x02
#define VS_FORMAT_UNCOMPRESSED  0x04
#define VS_FRAME_UNCOMPRESSED   0x05
#define VS_FORMAT_MJPEG         0x06
#define VS_FRAME_MJPEG          0x07
#define VS_COLORFORMAT          0x0D
#define VS_FORMAT_FRAME_BASED   0x10
#define VS_FRAME_FRAME_BASED    0x11
#define VS_FORMAT_H264          0x13
#define VS_FRAME_H264           0x14

// On newer versions of Mac OS X, the kIOMasterPortDefault enum has been
// replaced by kIOMainPortDefault.
#if (MAC_OS_X_VERSION_MAX_ALLOWED < 120000) // Before macOS 12 Monterey
  #define kIOMainPortDefault kIOMasterPortDefault
#endif

//
// UVC descriptor data type definitions:
//
typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
} __attribute__((packed)) UVC_Descriptor_Prefix;

typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
  UInt16              bcdUVC;
  UInt16              wTotalLength;
  UInt32              dwClockFrequency;
  UInt8               bInCollection;
  UInt8               baInterfaceNr1;
}  __attribute__((packed)) UVC_VC_Interface_Header_Descriptor;

typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
  UInt8               bTerminalId;
  UInt16              wTerminalType;
  UInt8               bAssocTerminal;
  UInt8               iTerminal;
  UInt16              wObjectiveFocalLengthMin;
  UInt16              wObjectiveFocalLengthMax;
  UInt16              wOcularFocalLength;
  UInt8               bControlSize;
  UInt8               bmControls[];
} __attribute__((packed)) UVC_VC_Terminal_Header_Descriptor;

/*!
  @enum UVC Terminal control enablement bit values
  
  The UVC_VC_Terminal_Header_Descriptor contains a variable-length
  bmControls field that expresses the controls which that unit
  implements.  The field is a bitmap, with bit zero (0) being
  the least-significant bit in the first byte -- which happens to
  correspond to kUVCTerminalControlEnableScanningMode.
*/
enum {
  kUVCTerminalControlEnableScanningMode           = 0,
  kUVCTerminalControlEnableAutoExposureMode       = 1,
  kUVCTerminalControlEnableAutoExposurePriority   = 2,
  kUVCTerminalControlEnableExposureTimeAbsolute   = 3,
  kUVCTerminalControlEnableExposureTimeRelative   = 4,
  kUVCTerminalControlEnableFocusAbsolute          = 5,
  kUVCTerminalControlEnableFocusRelative          = 6,
  kUVCTerminalControlEnableIrisAbsolute           = 7,
  kUVCTerminalControlEnableIrisRelative           = 8,
  kUVCTerminalControlEnableZoomAbsolute           = 9,
  kUVCTerminalControlEnableZoomRelative           = 10,
  kUVCTerminalControlEnablePanTiltAbsolute        = 11,
  kUVCTerminalControlEnablePanTiltRelative        = 12,
  kUVCTerminalControlEnableRollAbsolute           = 13,
  kUVCTerminalControlEnableRollRelative           = 14,
  kUVCTerminalControlEnableFocusAuto              = 17,
  kUVCTerminalControlEnablePrivacy                = 18,
  kUVCTerminalControlEnableFocusSimple            = 19,
  kUVCTerminalControlEnableWindow                 = 20,
  kUVCTerminalControlEnableRegionOfInterest       = 21
};

typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
  UInt8               bUnitId;
  UInt8               bSourceId;
  UInt16              wMaxMultiplier;
  UInt8               bControlSize;
  UInt8               bmControls[];
} __attribute__((packed)) UVC_PU_Header_Descriptor;

/*!
  @enum UVC Processing Unit control enablement bit values
  
  The UVC_PU_Header_Descriptor contains a variable-length
  bmControls field that expresses the controls which that unit
  implements.  The field is a bitmap, with bit zero (0) being
  the least-significant bit in the first byte -- which happens to
  correspond to kUVCProcessingUnitControlEnableBrightness.
*/
enum {
  kUVCProcessingUnitControlEnableBrightness                   = 0,
  kUVCProcessingUnitControlEnableContrast                     = 1,
  kUVCProcessingUnitControlEnableHue                          = 2,
  kUVCProcessingUnitControlEnableSaturation                   = 3,
  kUVCProcessingUnitControlEnableSharpness                    = 4,
  kUVCProcessingUnitControlEnableGamma                        = 5,
  kUVCProcessingUnitControlEnableWhiteBalanceTemperature      = 6,
  kUVCProcessingUnitControlEnableWhiteBalanceComponent        = 7,
  kUVCProcessingUnitControlEnableBacklightCompensation        = 8,
  kUVCProcessingUnitControlEnableGain                         = 9,
  kUVCProcessingUnitControlEnablePowerLineFrequency           = 10,
  kUVCProcessingUnitControlEnableAutoHue                      = 11,
  kUVCProcessingUnitControlEnableAutoWhiteBalanceTemperature  = 12,
  kUVCProcessingUnitControlEnableAutoWhiteBalanceComponent    = 13,
  kUVCProcessingUnitControlEnableDigitalMultiplier            = 14,
  kUVCProcessingUnitControlEnableDigitalMultiplierLimit       = 15,
  kUVCProcessingUnitControlEnableAnalogVideoStandard          = 16,
  kUVCProcessingUnitControlEnableAnalogVideoLockStatus        = 17,
  kUVCProcessingUnitControlEnableAutoContrast                 = 18
};

//
// Video Streaming (VS) descriptor structures:
//
typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
  UInt8               bNumFormats;
  UInt16              wTotalLength;
  UInt8               bEndpointAddress;
  UInt8               bmInfo;
  UInt8               bTerminalLink;
  UInt8               bStillCaptureMethod;
  UInt8               bTriggerSupport;
  UInt8               bTriggerUsage;
  UInt8               bControlSize;
  UInt8               bmaControls[];
} __attribute__((packed)) UVC_VS_Input_Header_Descriptor;

typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
  UInt8               bFormatIndex;
  UInt8               bNumFrameDescriptors;
  UInt8               guidFormat[16];
  UInt8               bBitsPerPixel;
  UInt8               bDefaultFrameIndex;
  UInt8               bAspectRatioX;
  UInt8               bAspectRatioY;
  UInt8               bmInterlaceFlags;
  UInt8               bCopyProtect;
} __attribute__((packed)) UVC_VS_Format_Uncompressed_Descriptor;

typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
  UInt8               bFormatIndex;
  UInt8               bNumFrameDescriptors;
  UInt8               bmFlags;
  UInt8               bDefaultFrameIndex;
  UInt8               bAspectRatioX;
  UInt8               bAspectRatioY;
  UInt8               bmInterlaceFlags;
  UInt8               bCopyProtect;
} __attribute__((packed)) UVC_VS_Format_MJPEG_Descriptor;

typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
  UInt8               bFrameIndex;
  UInt8               bmCapabilities;
  UInt16              wWidth;
  UInt16              wHeight;
  UInt32              dwMinBitRate;
  UInt32              dwMaxBitRate;
  UInt32              dwMaxVideoFrameBufferSize;
  UInt32              dwDefaultFrameInterval;
  UInt8               bFrameIntervalType;
  UInt32              dwFrameInterval[];
} __attribute__((packed)) UVC_VS_Frame_Descriptor;

typedef struct {
  UInt8               bLength;
  UInt8               bDescriptorType;
  UInt8               bDescriptorSubType;
  UInt8               bColorPrimaries;
  UInt8               bTransferCharacteristics;
  UInt8               bMatrixCoefficients;
} __attribute__((packed)) UVC_VS_ColorMatching_Descriptor;

//
// UVC request opcodes:
//
#define UVC_SET_CUR   0x01
#define UVC_GET_CUR   0x81
#define UVC_GET_MIN   0x82
#define UVC_GET_MAX   0x83
#define UVC_GET_RES   0x84
#define UVC_GET_LEN   0x85
#define UVC_GET_INFO  0x86
#define UVC_GET_DEF   0x87

//
// Terminal controls:
//
#define UVC_INPUT_TERMINAL_ID                 0x01

#define CT_SCANNING_MODE_CONTROL                  0x01
#define CT_AE_MODE_CONTROL                        0x02
#define CT_AE_PRIORITY_CONTROL                    0x03
#define CT_EXPOSURE_TIME_ABSOLUTE_CONTROL         0x04
#define CT_EXPOSURE_TIME_RELATIVE_CONTROL         0x05
#define CT_FOCUS_ABSOLUTE_CONTROL                 0x06
#define CT_FOCUS_RELATIVE_CONTROL                 0x07
#define CT_FOCUS_AUTO_CONTROL                     0x08
#define CT_IRIS_ABSOLUTE_CONTROL                  0x09
#define CT_IRIS_RELATIVE_CONTROL                  0x0a
#define CT_ZOOM_ABSOLUTE_CONTROL                  0x0b
#define CT_ZOOM_RELATIVE_CONTROL                  0x0c
#define CT_PANTILT_ABSOLUTE_CONTROL               0x0d
#define CT_PANTILT_RELATIVE_CONTROL               0x0e
#define CT_ROLL_ABSOLUTE_CONTROL                  0x0f
#define CT_ROLL_RELATIVE_CONTROL                  0x10
#define CT_PRIVACY_CONTROL                        0x11
#define CT_FOCUS_SIMPLE_CONTROL                   0x12
#define CT_WINDOW_CONTROL                         0x13
#define CT_REGION_OF_INTEREST_CONTROL             0x14

//
// Processing-unit controls:
//
#define UVC_PROCESSING_UNIT_ID                0x02

#define PU_BACKLIGHT_COMPENSATION_CONTROL         0x01
#define PU_BRIGHTNESS_CONTROL                     0x02
#define PU_CONTRAST_CONTROL                       0x03
#define PU_GAIN_CONTROL                           0x04
#define PU_POWER_LINE_FREQUENCY_CONTROL           0x05
#define PU_HUE_CONTROL                            0x06
#define PU_SATURATION_CONTROL                     0x07
#define PU_SHARPNESS_CONTROL                      0x08
#define PU_GAMMA_CONTROL                          0x09
#define PU_WHITE_BALANCE_TEMPERATURE_CONTROL      0x0a
#define PU_WHITE_BALANCE_TEMPERATURE_AUTO_CONTROL 0x0b
#define PU_WHITE_BALANCE_COMPONENT_CONTROL        0x0c
#define PU_WHITE_BALANCE_COMPONENT_AUTO_CONTROL   0x0d
#define PU_DIGITAL_MULTIPLIER_CONTROL             0x0e
#define PU_DIGITAL_MULTIPLIER_LIMIT_CONTROL       0x0f
#define PU_HUE_AUTO_CONTROL                       0x10
#define PU_ANALOG_VIDEO_STANDARD_CONTROL          0x11
#define PU_ANALOG_LOCK_STATUS_CONTROL             0x12
#define PU_CONTRAST_AUTO_CONTROL                  0x13

/*!
  @enum UVC control capabilities
  
  The UVC standard allows introspection of control's capabilities,
  including:
  
    - supports get (read)
    - supports set (write)
    - get/set disabled due to automatic control by device
    - device may alter the value of the control
    - alteration of control value requires non-trivial amount of time
  
  The UVC standard only encompasses bits 0 - 7.  This API makes use
  of higher-position bits to cache/express other capabilities:
  
    - GET_MIN and GET_MAX supported
    - GET_RES supported
    - GET_DEF supported
    
*/
enum {
  /* Bits 0 - 7 come from the UVC standard: */
  kUVCControlSupportsGet                  = 1 << 0,
  kUVCControlSupportsSet                  = 1 << 1,
  kUVCControlDisabledDueToAutomaticMode   = 1 << 2,
  kUVCControlAutoUpdateControl            = 1 << 3,
  kUVCControlAsynchronousControl          = 1 << 4,
  /* Bits 8 and up are ours: */
  kUVCControlHasRange                     = 1 << 8,
  kUVCControlHasStepSize                  = 1 << 9,
  kUVCControlHasDefaultValue              = 1 << 10
};

/*!
  @typedef UVCControllerPostProcessCallback
  
  A callback function that may alter the value read from a control prior
  to its being returned to the calling program.  This is typically used
  to perform byte-swapping of the (little endian) USB-native value to the
  system endian. 
*/
typedef void (*UVCControllerPostProcessCallback)(void *data, int size);

/*!
  @typedef UVCControllerPreProcessCallback
  
  A callback function that may alter the value to be written to a control.
  This is typically used to perform byte-swapping of the system endian value
  to the (little endian) USB-native value.
*/
typedef void (*UVCControllerPreProcessCallback)(void *data, int size);

/*!
  @typedef uvc_control_t
  
  Each UVC control is defined via one of these data structures.  Since the standard
  declares each control's expected data size and structure, the data structure
  associates the declared selector-id with the type description string and a cached
  "compiled" type representation.
*/
typedef struct {
  int           unitType;
  NSString      *unitTypeStr;
  int           selector;
  const char    *uvcTypeDescription;
  UVCType       *uvcType;
} uvc_control_t;

/*!
  @defined UVC_CONTROL_INIT
  
  Macro that expands a list of UVCControllerControls field values into a struct
  initializer statement.
*/
#define UVC_CONTROL_INIT(U,S,T) { .unitType = (U), .unitTypeStr = @#U, .selector = (S), .uvcTypeDescription = (T), .uvcType = nil }

/*!
  @constant UVCControllerControls
  
  List of all the UVC controls this API supports.  Each control consists of:
  
    - control selector (e.g. CT_SCANNING_MODE_CONTROL, PU_BACKLIGHT_COMPENSATION_CONTROL)
    - UVCType type description string
    - cached UVCType instance
  
  The index of each control in this array is important!!!  It determines the value that
  should be assigned to the control's textual name in the controlMapping dictionary
  (see the controlMapping method).
*/
uvc_control_t     UVCControllerControls[] = {
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_SCANNING_MODE_CONTROL, "{B}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_AE_MODE_CONTROL, "{M1}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_AE_PRIORITY_CONTROL, "{U1}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_EXPOSURE_TIME_ABSOLUTE_CONTROL, "{U4}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_EXPOSURE_TIME_RELATIVE_CONTROL, "{S1}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_FOCUS_ABSOLUTE_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_FOCUS_RELATIVE_CONTROL, "{S1 focus-relative; U1 focus-speed}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_FOCUS_AUTO_CONTROL, "{B}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_IRIS_ABSOLUTE_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_IRIS_RELATIVE_CONTROL, "{S1}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_ZOOM_ABSOLUTE_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_ZOOM_RELATIVE_CONTROL, "{S1 zoom; B digital-zoom; U1 speed}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_PANTILT_ABSOLUTE_CONTROL, "{S4 pan; S4 tilt}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_PANTILT_RELATIVE_CONTROL, "{S1 pan-relative; U1 pan-speed; S1 tilt-relative; U1 tilt-speed}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_ROLL_ABSOLUTE_CONTROL, "{S2}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_ROLL_RELATIVE_CONTROL, "{S1 roll-relative; U1 roll-speed}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_PRIVACY_CONTROL, "{B}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_FOCUS_SIMPLE_CONTROL, "{U1}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_WINDOW_CONTROL, "{U2 window-top; U2 window-left; U2 window-bottom; U2 window-right; U2 num-steps; M2 num-steps-units}"),
                      UVC_CONTROL_INIT(UVC_INPUT_TERMINAL_ID, CT_REGION_OF_INTEREST_CONTROL, "{U2 roi-top; U2 roi-left; U2 roi-bottom; U2 roi-right; M2 auto-controls}"),
                      //
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_BACKLIGHT_COMPENSATION_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_BRIGHTNESS_CONTROL, "{S2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_CONTRAST_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_GAIN_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_POWER_LINE_FREQUENCY_CONTROL, "{U1}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_HUE_CONTROL, "{S2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_SATURATION_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_SHARPNESS_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_GAMMA_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_WHITE_BALANCE_TEMPERATURE_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_WHITE_BALANCE_TEMPERATURE_AUTO_CONTROL, "{B}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_WHITE_BALANCE_COMPONENT_CONTROL, "{U2 blue; U2 red}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_WHITE_BALANCE_COMPONENT_AUTO_CONTROL, "{B}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_DIGITAL_MULTIPLIER_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_DIGITAL_MULTIPLIER_LIMIT_CONTROL, "{U2}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_HUE_AUTO_CONTROL,"{B}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_ANALOG_VIDEO_STANDARD_CONTROL, "{U1}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_ANALOG_LOCK_STATUS_CONTROL, "{U1}"),
                      UVC_CONTROL_INIT(UVC_PROCESSING_UNIT_ID, PU_CONTRAST_AUTO_CONTROL, "{U1}")
                    };

/*!
  @defined UVCInvalidControlIndex
  
  Returned by control-lookup function(s) to indicate a control not implemented by
  this API. 
*/
#define UVCInvalidControlIndex ((NSUInteger)-1)

//
#if 0
#pragma mark -
#endif
//

/*!
  @class UVCControl(UVCControlPrivate)
  @abstract Non-public methods of the UVCControl class.

  UVCControl instances are only ever initialized by the UVCController class, so the
  initializer method(s) can be private.
*/
@interface UVCControl(UVCControlPrivate)

/*!
  @method initControlWithName:parentController:controlIndex:
  
  Initialize a newly-allocated instance of UVCControl.  The controlName is copied;
  the parentController is sent a retain message; and the controlIndex indicates
  this control's position in the UVCControllerControls array.
*/
- (id) initControlWithName:(NSString*)controlName parentController:(UVCController*)parentController controlIndex:(NSUInteger)controlIndex;

@end

//
#if 0
#pragma mark -
#endif
//

/*!
  @class UVCController(UVCControllerPrivate)
  @abstract Non-public methods of the UVCController class.
  
  Class and instance methods of UVCController that should not be accessible
  outside this source file.
*/
@interface UVCController(UVCControllerPrivate)

/*!
  @method controlMapping
  
  Returns a constant NSDictionary which maps control name strings to an index in
  the UVCControllerControls array.
*/
+ (NSDictionary*) controlMapping;
/*!
  @method controlMapping
  
  Convenience method which calls the controlMapping class method.
*/
- (NSDictionary*) controlMapping;

/*!
  @method terminalControlEnableMapping
  
  Returns a constant NSDictionary which maps Terminal unit control name strings to
  the control's enablement bit in the UVC_VC_Terminal_Header_Descriptor.
*/
+ (NSDictionary*) terminalControlEnableMapping;
/*!
  @method terminalControlEnableMapping
  
  Convenience method which calls the terminalControlEnableMapping class method.
*/
- (NSDictionary*) terminalControlEnableMapping;

/*!
  @method processingUnitControlEnableMapping
  
  Returns a constant NSDictionary which maps Processing Unit control name strings to
  the control's enablement bit in the UVC_PU_Header_Descriptor.
*/
+ (NSDictionary*) processingUnitControlEnableMapping;
/*!
  @method processingUnitControlEnableMapping
  
  Convenience method which calls the processingUnitControlEnableMapping class method.
*/
- (NSDictionary*) processingUnitControlEnableMapping;

/*!
  @method controlIndexForString:
  
  Looks-up the controlString in the controlMapping NSDictionary.  If found, returns
  the control's index in the UVCControllerControls array.
  
  If the control is not found, returns UVCInvalidControlIndex.
*/
+ (NSUInteger) controlIndexForString:(NSString*)controlString;
/*!
  @method controlIndexForString:
  
  Convenience method which calls the controlIndexForString: class method.
*/
- (NSUInteger) controlIndexForString:(NSString*)controlString;

/*!
  @method controlIsNotAvailable:
  
  If the findControllerInterfaceForServiceObject: method was able to pull control
  enablement data from the device descriptors, then this method will check the
  enablement bitmask to determine whether or not the device claims the control
  is implemented.
  
  If no enablement data was found, this method always returns NO; the controlWithName:
  method will then always at least TRY to instantiate the control (and maybe fail).
*/
- (BOOL) controlIsNotAvailable:(NSString*)controlString;

/*!
  @method initWithLocationId:vendorId:productId:ioServiceObject:
  
  Designated initializer for this class.  Expects the locationId, vendorId, and
  productId to already have been read from the ioServiceObject's property list.
  
  Caches a copy of the device's textual name.
  
  Calls the findControllerInterfaceForServiceObject: method to fill-in the USB
  interface callback list, etc.
  
  Returns nil if any aspect of initialization fails.
*/
- (id) initWithLocationId:(UInt32)locationId vendorId:(UInt16)vendorId productId:(UInt16)productId ioServiceObject:(io_service_t)ioServiceObject;

/*!
  @method findControllerInterfaceForServiceObject:
  
  Given the ioServiceObject, locate the correct UVC-compliant device interface object
  which this class can control.
  
  Also determines the appropriate interface index for use in control request parameter
  blocks.
  
  If successful, the interface's descriptor list is walked in an attempt to find
  control enablement bitmasks; if found, they are retained as NSData instances which
  are later consulted to determine which controls are enabled/disabled.

  Returns YES if all operations are successful.
  
  This method consumes one reference to ioServiceObject; the caller should retain
  the object before calling this method if it needs to keep ioServiceObject valid
  afterwards.
*/
- (BOOL) findControllerInterfaceForServiceObject:(io_service_t)ioServiceObject;

/*!
  @method sendControlRequest:
  
  Lowest-level mechanism for delivering USB requests to the receiver's device.
  Returns YES if the request is successful.
  
  In order to send the request, the interface must be open.  If the receiver has
  not been explicitly opened (via setIsInterfaceOpen:) then this method will
  open the interface, deliver the request, and then close the interface.
*/
- (BOOL) sendControlRequest:(IOUSBDevRequest)controlRequest;

/*!
  @method setData:withLength:forSelector:atUnitId:
  
  Constructs an IOUSBDevRequest parameter block around the given arguments with the UVC_SET_CUR
  opcode and calls sendControlRequest: to write the length bytes of data at value to the
  device.
  
  Returns YES if successful.
*/
- (BOOL) setData:(void*)value withLength:(int)length forSelector:(int)selector atUnitId:(int)unitId;

/*!
  @method getData:ofType:withLength:fromSelector:atUnitId:
  
  Constructs an IOUSBDevRequest parameter block around the given arguments with the given
  opcode (type) and calls sendControlRequest: to read length bytes of data into value from
  the device.
  
  Returns YES if successful.
*/
- (BOOL) getData:(void*)value ofType:(int)type withLength:(int)length fromSelector:(int)selector atUnitId:(int)unitId;

/*!
  @method getLowValue:highValue:stepSize:defaultValue:updateCapabilitiesBitmask:forControl:
  
  For the given control (by controlId, index in the UVCControllerControls array) attempt to read
  the minimum, maximum, resolution, and default values.  So long as the control uses a 1-, 2-, or
  4-byte data size, the values are set (for any parameter that is not NULL).
  
  The capabilities bitmask is updated to indicate if the range, resolution (step size), or
  default values were available.
*/
- (void) getLowValue:(UVCValue**)lowValue highValue:(UVCValue**)highValue stepSize:(UVCValue**)stepSize defaultValue:(UVCValue**)defaultValue updateCapabilitiesBitmask:(uvc_capabilities_t*)capabilities forControl:(NSUInteger)controlId;


- (BOOL) getValue:(UVCValue*)value forControl:(NSUInteger)controlId;
- (BOOL) setValue:(UVCValue*)value forControl:(NSUInteger)controlId;

@end

@implementation UVCController(UVCControllerPrivate)

  + (NSDictionary*) controlMapping
  {
    static NSDictionary *sharedControlMapping = nil;

    if ( ! sharedControlMapping ) {
      sharedControlMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithInt:0], UVCTerminalControlScanningMode,
                                  [NSNumber numberWithInt:1], UVCTerminalControlAutoExposureMode,
                                  [NSNumber numberWithInt:2], UVCTerminalControlAutoExposurePriority,
                                  [NSNumber numberWithInt:3], UVCTerminalControlExposureTimeAbsolute,
                                  [NSNumber numberWithInt:4], UVCTerminalControlExposureTimeRelative,
                                  [NSNumber numberWithInt:5], UVCTerminalControlFocusAbsolute,
                                  [NSNumber numberWithInt:6], UVCTerminalControlFocusRelative,
                                  [NSNumber numberWithInt:7], UVCTerminalControlAutoFocus,
                                  [NSNumber numberWithInt:8], UVCTerminalControlIrisAbsolute,
                                  [NSNumber numberWithInt:9], UVCTerminalControlIrisRelative,
                                  [NSNumber numberWithInt:10], UVCTerminalControlZoomAbsolute,
                                  [NSNumber numberWithInt:11], UVCTerminalControlZoomRelative,
                                  [NSNumber numberWithInt:12], UVCTerminalControlPanTiltAbsolute,
                                  [NSNumber numberWithInt:13], UVCTerminalControlPanTiltRelative,
                                  [NSNumber numberWithInt:14], UVCTerminalControlRollAbsolute,
                                  [NSNumber numberWithInt:15], UVCTerminalControlRollRelative,
                                  [NSNumber numberWithInt:16], UVCTerminalControlPrivacy,
                                  [NSNumber numberWithInt:17], UVCTerminalControlFocusSimple,
                                  [NSNumber numberWithInt:18], UVCTerminalControlWindow,
                                  [NSNumber numberWithInt:19], UVCTerminalControlRegionOfInterest,

                                  [NSNumber numberWithInt:20], UVCProcessingUnitControlBacklightCompensation,
                                  [NSNumber numberWithInt:21], UVCProcessingUnitControlBrightness,
                                  [NSNumber numberWithInt:22], UVCProcessingUnitControlContrast,
                                  [NSNumber numberWithInt:23], UVCProcessingUnitControlGain,
                                  [NSNumber numberWithInt:24], UVCProcessingUnitControlPowerLineFrequency,
                                  [NSNumber numberWithInt:25], UVCProcessingUnitControlHue,
                                  [NSNumber numberWithInt:26], UVCProcessingUnitControlSaturation,
                                  [NSNumber numberWithInt:27], UVCProcessingUnitControlSharpness,
                                  [NSNumber numberWithInt:28], UVCProcessingUnitControlGamma,
                                  [NSNumber numberWithInt:29], UVCProcessingUnitControlWhiteBalanceTemperature,
                                  [NSNumber numberWithInt:30], UVCProcessingUnitControlAutoWhiteBalanceTemperature,
                                  [NSNumber numberWithInt:31], UVCProcessingUnitControlWhiteBalanceComponent,
                                  [NSNumber numberWithInt:32], UVCProcessingUnitControlAutoWhiteBalanceComponent,
                                  [NSNumber numberWithInt:33], UVCProcessingUnitControlDigitalMultiplier,
                                  [NSNumber numberWithInt:34], UVCProcessingUnitControlDigitalMultiplierLimit,
                                  [NSNumber numberWithInt:35], UVCProcessingUnitControlAutoHue,
                                  [NSNumber numberWithInt:36], UVCProcessingUnitControlAnalogVideoStandard,
                                  [NSNumber numberWithInt:37], UVCProcessingUnitControlAnalogLockStatus,
                                  [NSNumber numberWithInt:38], UVCProcessingUnitControlAutoContrast,
                                  nil
                                ];
    }
    return sharedControlMapping;
  }
  - (NSDictionary*) controlMapping
  {
    return [[self class] controlMapping];
  }

//

  + (NSDictionary*) terminalControlEnableMapping
  {
    static NSDictionary *sharedTerminalControlEnableMapping = nil;

    if ( ! sharedTerminalControlEnableMapping ) {
      sharedTerminalControlEnableMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableScanningMode], UVCTerminalControlScanningMode,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableAutoExposureMode], UVCTerminalControlAutoExposureMode,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableAutoExposurePriority], UVCTerminalControlAutoExposurePriority,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableExposureTimeAbsolute], UVCTerminalControlExposureTimeAbsolute,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableExposureTimeRelative], UVCTerminalControlExposureTimeRelative,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableFocusAbsolute], UVCTerminalControlFocusAbsolute,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableFocusRelative], UVCTerminalControlFocusRelative,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableIrisAbsolute], UVCTerminalControlIrisAbsolute,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableIrisRelative], UVCTerminalControlIrisRelative,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableZoomAbsolute], UVCTerminalControlZoomAbsolute,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableZoomRelative], UVCTerminalControlZoomRelative,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnablePanTiltAbsolute], UVCTerminalControlPanTiltAbsolute,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnablePanTiltRelative], UVCTerminalControlPanTiltRelative,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableRollAbsolute], UVCTerminalControlRollAbsolute,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableRollRelative], UVCTerminalControlRollRelative,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableFocusAuto], UVCTerminalControlAutoFocus,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnablePrivacy], UVCTerminalControlPrivacy,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableFocusSimple], UVCTerminalControlFocusSimple,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableWindow], UVCTerminalControlWindow,
                                              [NSNumber numberWithInt:kUVCTerminalControlEnableRegionOfInterest], UVCTerminalControlRegionOfInterest,
                                              nil
                                            ];
    }
    return sharedTerminalControlEnableMapping;
  }
  - (NSDictionary*) terminalControlEnableMapping
  {
    return [[self class] terminalControlEnableMapping];
  }

//

  + (NSDictionary*) processingUnitControlEnableMapping
  {
    static NSDictionary *sharedProcessingUnitControlEnableMapping = nil;

    if ( ! sharedProcessingUnitControlEnableMapping ) {
      sharedProcessingUnitControlEnableMapping = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableBrightness], UVCProcessingUnitControlBrightness,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableContrast], UVCProcessingUnitControlContrast,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableHue], UVCProcessingUnitControlHue,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableSaturation], UVCProcessingUnitControlSaturation,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableSharpness], UVCProcessingUnitControlSharpness,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableGamma], UVCProcessingUnitControlGamma,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableWhiteBalanceTemperature], UVCProcessingUnitControlWhiteBalanceTemperature,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableWhiteBalanceComponent], UVCProcessingUnitControlWhiteBalanceComponent,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableBacklightCompensation], UVCProcessingUnitControlBacklightCompensation,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableGain], UVCProcessingUnitControlGain,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnablePowerLineFrequency], UVCProcessingUnitControlPowerLineFrequency,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableAutoHue], UVCProcessingUnitControlAutoHue,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableAutoWhiteBalanceTemperature], UVCProcessingUnitControlAutoWhiteBalanceTemperature,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableAutoWhiteBalanceComponent], UVCProcessingUnitControlAutoWhiteBalanceComponent,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableDigitalMultiplier], UVCProcessingUnitControlDigitalMultiplier,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableDigitalMultiplierLimit], UVCProcessingUnitControlDigitalMultiplierLimit,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableAnalogVideoStandard], UVCProcessingUnitControlAnalogVideoStandard,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableAnalogVideoLockStatus], UVCProcessingUnitControlAnalogLockStatus,
                                                    [NSNumber numberWithInt:kUVCProcessingUnitControlEnableAutoContrast], UVCProcessingUnitControlAutoContrast,
                                                    nil
                                                  ];
    }
    return sharedProcessingUnitControlEnableMapping;
  }
  - (NSDictionary*) processingUnitControlEnableMapping
  {
    return [[self class] processingUnitControlEnableMapping];
  }

//

  + (NSUInteger) controlIndexForString:(NSString*)controlString
  {
    NSDictionary    *controlMapping = [self controlMapping];
    NSUInteger      index = UVCInvalidControlIndex;

    if ( controlMapping ) {
      NSNumber      *indexObj = [controlMapping objectForKey:controlString];

      if ( indexObj ) index = [indexObj unsignedIntegerValue];
    }
    return index;
  }
  - (NSUInteger) controlIndexForString:(NSString*)controlString
  {
    return [[self class] controlIndexForString:controlString];
  }

//

  - (BOOL) controlIsNotAvailable:(NSString*)controlString
  {
    NSUInteger      controlIndex = [self controlIndexForString:controlString];

    if ( controlIndex != UVCInvalidControlIndex ) {
      switch ( UVCControllerControls[controlIndex].unitType ) {

        case UVC_INPUT_TERMINAL_ID: {
          // If we weren't able to get control enablement from the interface
          // descriptor, don't prevent the code from TRYING to access the
          // control and failing:
          if ( ! _terminalControlsAvailable ) return NO;
          // Get the bit index for the given control:
          NSNumber      *bitIndexObj = [[self terminalControlEnableMapping] objectForKey:controlString];

          if ( bitIndexObj ) {
            // Check the enablement bitvector:
            NSUInteger  bitIndex = [bitIndexObj unsignedIntegerValue], byteIndex;
            UInt8       byte;

            byteIndex = bitIndex / 8;
            bitIndex = bitIndex % 8;
            if ( byteIndex < [_terminalControlsAvailable length] ) {
              [_terminalControlsAvailable getBytes:&byte range:NSMakeRange(byteIndex, 1)];
            } else {
              return YES;
            }
            if ( (byte & (1 << bitIndex)) != 0 ) return NO;
          }
          break;
        }

        case UVC_PROCESSING_UNIT_ID: {
          // If we weren't able to get control enablement from the interface
          // descriptor, don't prevent the code from TRYING to access the
          // control and failing:
          if ( ! _processingUnitControlsAvailable ) return NO;
          // Get the bit index for the given control:
          NSNumber      *bitIndexObj = [[self processingUnitControlEnableMapping] objectForKey:controlString];

          if ( bitIndexObj ) {
            // Check the enablement bitvector:
            NSUInteger  bitIndex = [bitIndexObj unsignedIntegerValue], byteIndex;
            UInt8       byte;

            byteIndex = bitIndex / 8;
            bitIndex = bitIndex % 8;
            if ( byteIndex < [_processingUnitControlsAvailable length] ) {
              [_processingUnitControlsAvailable getBytes:&byte range:NSMakeRange(byteIndex, 1)];
            } else {
              return YES;
            }
            if ( (byte & (1 << bitIndex)) != 0 ) return NO;
          }
          break;
        }

      }
    }
    return YES;
  }

//

  - (id) initWithLocationId:(UInt32)locationId
    vendorId:(UInt16)vendorId
    productId:(UInt16)productId
    ioServiceObject:(io_service_t)ioServiceObject
  {
    if ( (self = [self init]) ) {
      io_name_t     nameBuffer;

      _locationId = locationId;
      _vendorId = vendorId;
      _productId = productId;

      if ( IORegistryEntryGetName(ioServiceObject, nameBuffer) == KERN_SUCCESS ) {
        _deviceName = [[NSString stringWithUTF8String:nameBuffer] retain];
      }
      _unitIds = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                        [NSNumber numberWithInt:UVC_INPUT_TERMINAL_ID], @"UVC_INPUT_TERMINAL_ID",
                        [NSNumber numberWithInt:UVC_PROCESSING_UNIT_ID], @"UVC_PROCESSING_UNIT_ID",
                        nil
                    ];
      if ( [self findControllerInterfaceForServiceObject:ioServiceObject] ) {
        _controls = [[NSMutableDictionary alloc] init];
      } else {
        [self release];
        self = nil;
      }
    }
    return self;
  }

//

  - (BOOL) findControllerInterfaceForServiceObject:(io_service_t)ioServiceObject
  {
    IOUSBDeviceInterface        **deviceInterface = NULL;
    IOCFPlugInInterface         **plugInInterface = NULL;
    SInt32                      score;
    kern_return_t               krc = IOCreatePlugInInterfaceForService(ioServiceObject, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);

    if ( (krc != kIOReturnSuccess) || ! plugInInterface ) return NO;

    IOReturn                    hrc = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID*)&deviceInterface);

    IODestroyPlugInInterface(plugInInterface);
    if ( (hrc != 0) || ! deviceInterface ) return NO;

    //
    // Find any video control interfaces to this device:
    //
    io_iterator_t               interfaceIter;
    IOUSBFindInterfaceRequest   interfaceRequest = {
                                    .bInterfaceClass = kUSBVideoInterfaceClass,
                                    .bInterfaceSubClass = kUSBVideoControlSubClass,
                                    .bInterfaceProtocol = kIOUSBFindInterfaceDontCare,
                                    .bAlternateSetting = kIOUSBFindInterfaceDontCare
                                  };

    hrc = (*deviceInterface)->CreateInterfaceIterator(deviceInterface, &interfaceRequest, &interfaceIter);
    (*deviceInterface)->Release(deviceInterface);

    if( (hrc != 0) || ! interfaceIter ) return NO;

    io_service_t                usbInterface = IOIteratorNext(interfaceIter);

    IOObjectRelease(interfaceIter);
    if ( ! usbInterface ) return NO;

    // Create an intermediate plug-in to use to grab an interface to the device:
    krc = IOCreatePlugInInterfaceForService(usbInterface, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
    IOObjectRelease(usbInterface);
    if ( (krc != kIOReturnSuccess) || ! plugInInterface ) return NO;

    // Now create the device interface for the interface:
    hrc = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID), (LPVOID *)&_controllerInterface);
    IODestroyPlugInInterface(plugInInterface);
    if ( (hrc != 0) || ! _controllerInterface ) return NO;

    hrc = (*_controllerInterface)->GetInterfaceNumber(_controllerInterface, &_videoInterfaceIndex);

    //
    // Check with the interface for the UVC config descriptors:
    //
    IOUSBDescriptorHeader       *interfaceDescriptor = NULL;
    if ( (interfaceDescriptor = (*_controllerInterface)->FindNextAssociatedDescriptor(_controllerInterface, NULL, CS_INTERFACE)) ) {
      //
      // UVC leads the descriptor with a VC Interface Header that provides
      // the version of UVC implemented and a list of the available streaming
      // interfaces (by number).  More importantly, it provides the full byte
      // length of the descriptor, which aids in walking the Unit/Terminal
      // descriptors that follow it.
      //
      UVC_Descriptor_Prefix     *descriptorPrefix = (UVC_Descriptor_Prefix*)interfaceDescriptor;

      switch ( descriptorPrefix->bDescriptorSubType ) {

        case VC_HEADER: {
          UVC_VC_Interface_Header_Descriptor    *vcHeader = (UVC_VC_Interface_Header_Descriptor*)interfaceDescriptor;
          void                                  *basePtr = (void*)vcHeader;
          void                                  *endPtr = basePtr + vcHeader->wTotalLength;
          
#ifdef DEBUG_WRITE_UVC_HEADER_TO_FILE
          // Dump the header to a file for debugging:
          char                                  headerFName[64];
          
          snprintf(headerFName, sizeof(headerFName), "uvc-header-%hhu.bin", vcHeader->baInterfaceNr1);
          
          FILE                                  *headerFPtr = fopen(headerFName, "w");
          
          if ( headerFPtr ) {
            fwrite(basePtr, vcHeader->wTotalLength, 1, headerFPtr);
            fclose(headerFPtr);
          }
#endif
          
          // Grab the version of the UVC standard this device implements:
          _uvcVersion = NSSwapLittleShortToHost(vcHeader->bcdUVC);

          //
          // basePtr and endPtr are setup to allow us to easily walk the embedded
          // Unit/Terminal descriptors
          //
          basePtr += vcHeader->bLength;
          while ( basePtr < endPtr ) {
            descriptorPrefix = (UVC_Descriptor_Prefix*)basePtr;
            if ( descriptorPrefix->bDescriptorType == CS_INTERFACE ) {
              switch ( descriptorPrefix->bDescriptorSubType ) {

                case VC_INPUT_TERMINAL: {
                  UVC_VC_Terminal_Header_Descriptor   *terminalHeader = (UVC_VC_Terminal_Header_Descriptor*)basePtr;

                  if ( terminalHeader->bControlSize > 0 ) {
                    _terminalControlsAvailable = [[NSData alloc] initWithBytes:&terminalHeader->bmControls[0] length:terminalHeader->bControlSize];
                  }
                  break;
                }

                case VC_PROCESSING_UNIT: {
                  UVC_PU_Header_Descriptor            *puHeader = (UVC_PU_Header_Descriptor*)basePtr;

                  if ( puHeader->bControlSize > 0 ) {
                    [_unitIds setObject:[NSNumber numberWithInt:puHeader->bUnitId] forKey:@"UVC_PROCESSING_UNIT_ID"];
                    _processingUnitControlsAvailable = [[NSData alloc] initWithBytes:&puHeader->bmControls[0] length:puHeader->bControlSize];
                  }
                  break;
                }

              }
            }
            basePtr += descriptorPrefix->bLength;

          }
          break;
        }
      }
    }

    return YES;
  }

//

  - (BOOL) sendControlRequest:(IOUSBDevRequest)controlRequest
  {
    //
    // Open the interface. This will cause the pipes associated with the endpoints in
    // the interface descriptor to be instantiated.  Then send a control request.
    //
    IOReturn          rc = 0;
    
    if ( ! [self isInterfaceOpen] ) {
      [self setIsInterfaceOpen:YES];
      if ( ! [self isInterfaceOpen] ) return NO;
    }
    rc = (*_controllerInterface)->ControlRequest(_controllerInterface, 0, &controlRequest);
    return ( rc == kIOReturnSuccess );
  }

//

  - (BOOL) setData:(void*)value
    withLength:(int)length
    forSelector:(int)selector
    atUnitId:(int)unitId
  {
    IOUSBDevRequest controlRequest = {
                        .bmRequestType = USBmakebmRequestType(kUSBOut, kUSBClass, kUSBInterface),
                        .bRequest = UVC_SET_CUR,
                        .wValue = (selector << 8),
                        .wIndex = (unitId << 8) | _videoInterfaceIndex,
                        .wLength = length,
                        .wLenDone = 0,
                        .pData = value
                      };
    return [self sendControlRequest:controlRequest];
  }

//

  - (BOOL) getData:(void*)value
    ofType:(int)type
    withLength:(int)length
    fromSelector:(int)selector
    atUnitId:(int)unitId
  {
    IOUSBDevRequest controlRequest = {
                        .bmRequestType = USBmakebmRequestType(kUSBIn, kUSBClass, kUSBInterface),
                        .bRequest = type,
                        .wValue = (selector << 8),
                        .wIndex = (unitId << 8) | _videoInterfaceIndex,
                        .wLength = length,
                        .wLenDone = 0,
                        .pData = value
                      };
    return [self sendControlRequest:controlRequest];
  }

//

  - (BOOL) capabilities:(NSUInteger*)capabilities
    forControl:(NSUInteger)controlId
  {
    uvc_control_t           *control = &UVCControllerControls[controlId];
    uint8_t                 scratch;

    if ( [self getData:&scratch ofType:UVC_GET_INFO withLength:1 fromSelector:control->selector atUnitId:[[_unitIds objectForKey:control->unitTypeStr] intValue]] ) {
      *capabilities = scratch;
      return YES;
    }
    return NO;
  }

//

  - (void) getLowValue:(UVCValue**)lowValue
    highValue:(UVCValue**)highValue
    stepSize:(UVCValue**)stepSize
    defaultValue:(UVCValue**)defaultValue
    updateCapabilitiesBitmask:(uvc_capabilities_t*)capabilities
    forControl:(NSUInteger)controlId
  {
    uvc_control_t   *control = &UVCControllerControls[controlId];
    int             unitId = [[_unitIds objectForKey:control->unitTypeStr] intValue];
    
    if ( *lowValue && *highValue ) {
      if ( [self getData:[*lowValue valuePtr] ofType:UVC_GET_MIN withLength:(int)[*lowValue byteSize] fromSelector:control->selector atUnitId:unitId] &&
           [self getData:[*highValue valuePtr] ofType:UVC_GET_MAX withLength:(int)[*highValue byteSize] fromSelector:control->selector atUnitId:unitId]
      ) {
        *capabilities |= kUVCControlHasRange;
        [(*lowValue = [*lowValue retain]) byteSwapUSBToHostEndian];
        [(*highValue = [*highValue retain]) byteSwapUSBToHostEndian];
      } else {
        *lowValue = nil;
        *highValue = nil;
      }
    }
    if ( *stepSize ) {
      if ( [self getData:[*stepSize valuePtr] ofType:UVC_GET_RES withLength:(int)[*stepSize byteSize] fromSelector:control->selector atUnitId:unitId]) {
        *capabilities |= kUVCControlHasStepSize;
        [(*stepSize = [*stepSize retain]) byteSwapUSBToHostEndian];
      } else {
        *stepSize = nil;
      }
    }
    if ( *defaultValue ) {
      if ( [self getData:[*defaultValue valuePtr] ofType:UVC_GET_DEF withLength:(int)[*defaultValue byteSize] fromSelector:control->selector atUnitId:unitId]) {
        *capabilities |= kUVCControlHasDefaultValue;
        [(*defaultValue = [*defaultValue retain]) byteSwapUSBToHostEndian];
      } else {
        *defaultValue = nil;
      }
    }
  }

//

  - (BOOL) getValue:(UVCValue*)value
    forControl:(NSUInteger)controlId
  {
    uvc_control_t   *control = &UVCControllerControls[controlId];
     
    if ( [self getData:[value valuePtr] ofType:UVC_GET_CUR withLength:(int)[value byteSize] fromSelector:control->selector atUnitId:[[_unitIds objectForKey:control->unitTypeStr] intValue]] ) {
      [value byteSwapUSBToHostEndian];
      return YES;
    }
    return NO;
  }

//

  - (BOOL) setValue:(UVCValue*)value
    forControl:(NSUInteger)controlId
  {
    uvc_control_t   *control = &UVCControllerControls[controlId];
    BOOL            rc = NO;
    
    [value byteSwapHostToUSBEndian];
    rc = [self setData:[value valuePtr] withLength:(int)[value byteSize] forSelector:control->selector atUnitId:[[_unitIds objectForKey:control->unitTypeStr] intValue]];
    [value byteSwapUSBToHostEndian];
    return rc;
  }

@end

//
#if 0
#pragma mark -
#endif
//

@implementation UVCController

  + (NSArray*) controlStrings
  {
    static NSArray    *sharedControlStrings = nil;

    if ( ! sharedControlStrings ) {
      NSDictionary    *controlMapping = [self controlMapping];

      if ( controlMapping ) sharedControlStrings = [controlMapping allKeys];
    }
    return sharedControlStrings;
  }
  - (NSArray*) controlStrings
  {
    return [[self class] controlStrings];
  }

//

  + (NSArray*) uvcControllers
  {
    NSMutableArray          *newControllers = nil;

    // Find a USB Device with the given locationId:
    CFMutableDictionaryRef  matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    io_iterator_t           deviceIter;

    if ( IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &deviceIter) == KERN_SUCCESS ) {
      io_service_t          device;

      while ( (device = IOIteratorNext(deviceIter)) ) {
        UVCController       *newController = [UVCController uvcControllerWithService:device];

        IOObjectRelease(device);
        if ( newController ) {
          if ( ! newControllers ) newControllers = [[NSMutableArray alloc] init];
          [newControllers addObject:newController];
        }
        IOObjectRelease(device);
      }
      IOObjectRelease(deviceIter);
    }
    if ( newControllers ) {
      NSArray             *outArray = [newControllers copy];

      [newControllers release];
      return [outArray autorelease];
    }
    return nil;
  }

//

  + (id) uvcControllerWithService:(io_service_t)ioService
  {
    CFNumberRef             vendorIdObj = IORegistryEntrySearchCFProperty(ioService, kIOUSBPlane, CFSTR(kUSBVendorID), kCFAllocatorDefault, 0);
    CFNumberRef             productIdObj = IORegistryEntrySearchCFProperty(ioService, kIOUSBPlane, CFSTR(kUSBProductID), kCFAllocatorDefault, 0);
    CFNumberRef             locationIdObj = IORegistryEntrySearchCFProperty(ioService, kIOUSBPlane, CFSTR(kUSBDevicePropertyLocationID), kCFAllocatorDefault, 0);
    UInt16                  vendorId = -1, productId = -1;
    UInt32                  locationId = -1;

    if ( vendorIdObj ) {
      CFNumberGetValue(vendorIdObj, kCFNumberSInt16Type, &vendorId);
      CFRelease(vendorIdObj);
    }
    if ( productIdObj ) {
      CFNumberGetValue(productIdObj, kCFNumberSInt16Type, &productId);
      CFRelease(productIdObj);
    }
    if ( locationIdObj ) {
      CFNumberGetValue(locationIdObj, kCFNumberSInt32Type, &locationId);
      CFRelease(locationIdObj);
    }
    // We assume that the caller doesn't want to lose ioService in the course of finding the
    // controller interface, so increase the refcount on it:
    IOObjectRetain(ioService);
    return [[[UVCController alloc] initWithLocationId:locationId vendorId:vendorId productId:productId ioServiceObject:ioService] autorelease];
  }

//

  + (id) uvcControllerWithLocationId:(UInt32)locationId
  {
    UVCController           *newController = nil;

    // Find a USB Device with the given locationId:
    CFMutableDictionaryRef  matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    CFMutableDictionaryRef  propertiesDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    CFNumberRef             usbLocationIdObj = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &locationId);

    CFDictionarySetValue(propertiesDict, CFSTR(kUSBDevicePropertyLocationID), usbLocationIdObj);
    CFRelease(usbLocationIdObj);
    CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertiesDict);
    CFRelease(propertiesDict);

    io_service_t            device = IOServiceGetMatchingService(kIOMainPortDefault, matchingDict);

    if ( device ) {
      CFNumberRef           vendorIdObj = IORegistryEntrySearchCFProperty(device, kIOUSBPlane, CFSTR(kUSBVendorID), kCFAllocatorDefault, 0);
      CFNumberRef           productIdObj = IORegistryEntrySearchCFProperty(device, kIOUSBPlane, CFSTR(kUSBProductID), kCFAllocatorDefault, 0);
      UInt16                vendorId = -1, productId = -1;

      if ( vendorIdObj ) {
        CFNumberGetValue(vendorIdObj, kCFNumberSInt16Type, &vendorId);
        CFRelease(vendorIdObj);
      }
      if ( productIdObj ) {
        CFNumberGetValue(productIdObj, kCFNumberSInt16Type, &productId);
        CFRelease(productIdObj);
      }

      // Our reference to the "device" object will be dropped in the course of finding the controller interface:
      newController = [[[UVCController alloc] initWithLocationId:locationId vendorId:vendorId productId:productId ioServiceObject:device] autorelease];
    }
    return newController;
  }

//

  + (id) uvcControllerWithVendorId:(UInt16)vendorId
    productId:(UInt16)productId
  {
    UVCController           *newController = nil;

    // Find a USB Device with the given vendor and product ids:
    CFMutableDictionaryRef  matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    CFMutableDictionaryRef  propertiesDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                                &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    CFNumberRef             vendorIdObj = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt16Type, &vendorId);
    CFNumberRef             productIdObj = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt16Type, &productId);

    CFDictionarySetValue(propertiesDict, CFSTR(kUSBVendorID), vendorIdObj);
    CFRelease(vendorIdObj);
    CFDictionarySetValue(propertiesDict, CFSTR(kUSBProductID), productIdObj);
    CFRelease(productIdObj);
    CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertiesDict);
    CFRelease(propertiesDict);

    io_service_t            device = IOServiceGetMatchingService(kIOMainPortDefault, matchingDict);

    if ( device ) {
      CFNumberRef           locationIdObj = IORegistryEntrySearchCFProperty(device, kIOUSBPlane, CFSTR(kUSBDevicePropertyLocationID), kCFAllocatorDefault, 0);
      UInt32                locationId = -1;

      if ( locationIdObj ) {
        CFNumberGetValue(locationIdObj, kCFNumberSInt32Type, &locationId);
        CFRelease(locationIdObj);
      }

      // Our reference to the "device" object will be dropped in the course of finding the controller interface:
      newController = [[[UVCController alloc] initWithLocationId:locationId vendorId:vendorId productId:productId ioServiceObject:device] autorelease];
    }
    return newController;
  }

//

  - (void) dealloc
  {
    if ( _terminalControlsAvailable ) [_terminalControlsAvailable release];
    if ( _processingUnitControlsAvailable ) [_processingUnitControlsAvailable release];
    if ( _controls ) [_controls release];
    if ( _unitIds ) [_unitIds release];
    if ( _controllerInterface ) {
      [self setIsInterfaceOpen:NO];
      (*_controllerInterface)->Release(_controllerInterface);
    }
    if ( _deviceName ) [_deviceName release];
    [super dealloc];
  }

//

  - (NSString*) description
  {
    return [NSString stringWithFormat:@"UVCController@%p { \"%@\"; vendor-id=0x%04x; product-id=0x%04x; location-id=0x%08x; uvc-version: 0x%04x interface-index: %d%s }",
                        self,
                        _deviceName,
                        _vendorId, _productId,
                        _locationId,
                        _uvcVersion,
                        _videoInterfaceIndex,
                        (_isInterfaceOpen ? " ; is-open" : "")
                      ];
  }

//

  - (NSString*) deviceName
  {
    return _deviceName;
  }

//

  - (UInt32) locationId
  {
    return _locationId;
  }

//

  - (UInt16) vendorId
  {
    return _vendorId;
  }

//

  - (UInt16) productId
  {
    return _productId;
  }

//

  - (UInt16) uvcVersion
  {
    return _uvcVersion;
  }

//

  - (BOOL) isInterfaceOpen
  {
    return _isInterfaceOpen;
  }
  - (void) setIsInterfaceOpen:(BOOL)isInterfaceOpen
  {
    if ( isInterfaceOpen != _isInterfaceOpen ) {
      IOReturn          rc;

      if ( isInterfaceOpen ) {
        rc = (*_controllerInterface)->USBInterfaceOpen(_controllerInterface);
        if ( rc == kIOReturnSuccess ) {
          _shouldNotCloseInterface = _isInterfaceOpen = YES;
        }
        else if ( rc == kIOReturnExclusiveAccess) {
          _isInterfaceOpen = YES;
          _shouldNotCloseInterface = NO;
        }
      } else if ( ! _shouldNotCloseInterface ) {
        rc = (*_controllerInterface)->USBInterfaceClose(_controllerInterface);
        if ( rc == kIOReturnSuccess ) _shouldNotCloseInterface = _isInterfaceOpen = NO;
      }
    }
  }

//

  - (UVCControl*) controlWithName:(NSString*)controlName
  {
    UVCControl      *theControl = [_controls objectForKey:controlName];

    if ( ! theControl ) {
      if ( ! [self controlIsNotAvailable:controlName] ) {
        NSUInteger    controlIndex = [self controlIndexForString:controlName];

        if ( controlIndex != UVCInvalidControlIndex ) {
          theControl = [[UVCControl alloc] initControlWithName:controlName parentController:self controlIndex:controlIndex];

          if ( theControl ) {
            [_controls setObject:theControl forKey:controlName];
          } else {
            [_controls setObject:[NSNull null] forKey:controlName];
          }
          [theControl release];
        }
      } else {
        [_controls setObject:[NSNull null] forKey:controlName];
      }
    }
    if ( [theControl isMemberOfClass:[NSNull class]] ) return nil;
    return theControl;
  }

//

  - (void) displayFormatInformation
  {
    //
    // This method scans for Video Streaming interfaces and displays format information
    //
    printf("\n========================================\n");
    printf("Video Streaming Format Information\n");
    printf("========================================\n\n");

    // We need to re-find the device to enumerate its streaming interfaces
    // Create a matching dictionary for UVC devices
    CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    if ( !matchingDict ) {
      printf("Error: Unable to create matching dictionary\n");
      return;
    }

    // Find all USB devices
    io_iterator_t deviceIter;
    kern_return_t krc = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &deviceIter);
    if ( krc != KERN_SUCCESS ) {
      printf("Error: Unable to enumerate USB devices\n");
      return;
    }

    // Search for our device by location ID
    io_service_t deviceService = 0;
    io_service_t candidateDevice;
    while ( (candidateDevice = IOIteratorNext(deviceIter)) ) {
      CFNumberRef locationRef = (CFNumberRef)IORegistryEntryCreateCFProperty(candidateDevice, CFSTR(kUSBDevicePropertyLocationID), kCFAllocatorDefault, 0);
      if ( locationRef ) {
        UInt32 candidateLocation;
        CFNumberGetValue(locationRef, kCFNumberSInt32Type, &candidateLocation);
        CFRelease(locationRef);

        if ( candidateLocation == _locationId ) {
          deviceService = candidateDevice;
          break;
        }
      }
      IOObjectRelease(candidateDevice);
    }
    IOObjectRelease(deviceIter);

    if ( !deviceService ) {
      printf("Error: Device not found\n");
      return;
    }

    // Get device interface
    IOCFPlugInInterface **plugInInterface = NULL;
    SInt32 score;
    krc = IOCreatePlugInInterfaceForService(deviceService, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
    IOObjectRelease(deviceService);

    if ( (krc != kIOReturnSuccess) || !plugInInterface ) {
      printf("Error: Unable to create plugin interface\n");
      return;
    }

    IOUSBDeviceInterface **deviceInterface = NULL;
    IOReturn hrc = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID*)&deviceInterface);
    IODestroyPlugInInterface(plugInInterface);

    if ( (hrc != 0) || !deviceInterface ) {
      printf("Error: Unable to query device interface\n");
      return;
    }

    // Find Video Streaming interfaces
    io_iterator_t interfaceIter;
    IOUSBFindInterfaceRequest interfaceRequest = {
      .bInterfaceClass = kUSBVideoInterfaceClass,
      .bInterfaceSubClass = kUSBVideoStreamingSubClass,
      .bInterfaceProtocol = kIOUSBFindInterfaceDontCare,
      .bAlternateSetting = kIOUSBFindInterfaceDontCare
    };

    hrc = (*deviceInterface)->CreateInterfaceIterator(deviceInterface, &interfaceRequest, &interfaceIter);
    (*deviceInterface)->Release(deviceInterface);

    if ( (hrc != 0) || !interfaceIter ) {
      printf("Error: Unable to find video streaming interfaces\n");
      return;
    }

    io_service_t usbInterface;
    int interfaceIndex = 0;

    while ( (usbInterface = IOIteratorNext(interfaceIter)) ) {
      IOUSBInterfaceInterface220 **streamInterface = NULL;
      IOCFPlugInInterface **plugInInterface = NULL;
      SInt32 score;
      kern_return_t krc;

      // Create plugin for this interface
      krc = IOCreatePlugInInterfaceForService(usbInterface, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
      IOObjectRelease(usbInterface);

      if ( (krc != kIOReturnSuccess) || !plugInInterface ) continue;

      hrc = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID), (LPVOID *)&streamInterface);
      IODestroyPlugInInterface(plugInInterface);

      if ( (hrc != 0) || !streamInterface ) continue;

      // Get the interface descriptor
      IOUSBDescriptorHeader *interfaceDescriptor = NULL;
      interfaceDescriptor = (*streamInterface)->FindNextAssociatedDescriptor(streamInterface, NULL, CS_INTERFACE);

      if ( interfaceDescriptor ) {
        UVC_Descriptor_Prefix *descriptorPrefix = (UVC_Descriptor_Prefix*)interfaceDescriptor;

        if ( descriptorPrefix->bDescriptorSubType == VS_INPUT_HEADER ) {
          UVC_VS_Input_Header_Descriptor *vsHeader = (UVC_VS_Input_Header_Descriptor*)interfaceDescriptor;
          void *basePtr = (void*)vsHeader;
          void *endPtr = basePtr + NSSwapLittleShortToHost(vsHeader->wTotalLength);

          // Parse format and frame descriptors
          basePtr += vsHeader->bLength;
          const char *currentFormatName = NULL;
          int currentBitsPerPixel = 0;
          BOOL firstFormat = YES;

          // Color space tracking
          const char *colorSpace = NULL;
          const char *transferChar = NULL;
          const char *videoRange = NULL;

          // Track printed entries to avoid duplicates
          NSMutableSet *printedEntries = [[NSMutableSet alloc] init];

          while ( basePtr < endPtr ) {
            descriptorPrefix = (UVC_Descriptor_Prefix*)basePtr;

            if ( descriptorPrefix->bDescriptorType == CS_INTERFACE ) {
              switch ( descriptorPrefix->bDescriptorSubType ) {

                case VS_COLORFORMAT: {
                  UVC_VS_ColorMatching_Descriptor *colorDesc = (UVC_VS_ColorMatching_Descriptor*)basePtr;

                  // Color Primaries (defines the color space)
                  switch (colorDesc->bColorPrimaries) {
                    case 0: colorSpace = "Unspecified"; break;
                    case 1: colorSpace = "BT.709"; break;
                    case 2: colorSpace = "BT.470-2M"; break;
                    case 3: colorSpace = "BT.470-2BG"; break;
                    case 4: colorSpace = "SMPTE 170M (BT.601)"; break;
                    case 5: colorSpace = "SMPTE 240M"; break;
                    default: colorSpace = "Unknown"; break;
                  }

                  // Transfer Characteristics
                  switch (colorDesc->bTransferCharacteristics) {
                    case 0: transferChar = "Unspecified"; break;
                    case 1: transferChar = "BT.709"; break;
                    case 2: transferChar = "BT.470-2M"; break;
                    case 3: transferChar = "BT.470-2BG"; break;
                    case 4: transferChar = "BT.601"; break;
                    case 5: transferChar = "SMPTE 240M"; break;
                    case 6: transferChar = "Linear"; break;
                    case 7: transferChar = "sRGB"; break;
                    default: transferChar = "Unknown"; break;
                  }

                  // Matrix Coefficients (also affects color space, and implies range)
                  switch (colorDesc->bMatrixCoefficients) {
                    case 0: videoRange = "Unspecified"; break;
                    case 1: videoRange = "BT.709"; break;
                    case 2: videoRange = "FCC"; break;
                    case 3: videoRange = "BT.470-2BG"; break;
                    case 4: videoRange = "BT.601"; break;
                    case 5: videoRange = "SMPTE 240M"; break;
                    default: videoRange = "Unknown"; break;
                  }

                  break;
                }

                case VS_FORMAT_UNCOMPRESSED: {
                  UVC_VS_Format_Uncompressed_Descriptor *formatDesc = (UVC_VS_Format_Uncompressed_Descriptor*)basePtr;

                  // Identify format by GUID and determine bit depth
                  int bitDepth = 8; // Default to 8-bit
                  if (memcmp(formatDesc->guidFormat, (UInt8[]){0x59, 0x55, 0x59, 0x32, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}, 16) == 0) {
                    currentFormatName = "YUY2";
                    bitDepth = 8;
                  } else if (memcmp(formatDesc->guidFormat, (UInt8[]){0x4e, 0x56, 0x31, 0x32, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}, 16) == 0) {
                    currentFormatName = "NV12";
                    bitDepth = 8;
                  } else if (memcmp(formatDesc->guidFormat, (UInt8[]){0x50, 0x30, 0x31, 0x30, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}, 16) == 0) {
                    currentFormatName = "P010";
                    bitDepth = 10;
                  } else if (memcmp(formatDesc->guidFormat, (UInt8[]){0x50, 0x32, 0x31, 0x30, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}, 16) == 0) {
                    currentFormatName = "P210";
                    bitDepth = 10;
                  } else if (memcmp(formatDesc->guidFormat, (UInt8[]){0x49, 0x34, 0x32, 0x30, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}, 16) == 0) {
                    currentFormatName = "I420";
                    bitDepth = 8;
                  } else if (memcmp(formatDesc->guidFormat, (UInt8[]){0x55, 0x59, 0x56, 0x59, 0x00, 0x00, 0x10, 0x00, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}, 16) == 0) {
                    currentFormatName = "UYVY";
                    bitDepth = 8;
                  } else {
                    // Try to extract FourCC from GUID
                    static char fourcc[5];
                    fourcc[0] = formatDesc->guidFormat[0];
                    fourcc[1] = formatDesc->guidFormat[1];
                    fourcc[2] = formatDesc->guidFormat[2];
                    fourcc[3] = formatDesc->guidFormat[3];
                    fourcc[4] = '\0';
                    currentFormatName = fourcc;
                    bitDepth = 8; // Unknown, assume 8-bit
                  }

                  currentBitsPerPixel = bitDepth; // Store actual bit depth, not bpp

                  if (firstFormat) {
                    printf("\n%-10s %-12s %-8s %-10s %s\n", "Format", "Resolution", "FPS", "Bit Depth", "Subsampling");
                    printf("---------- ------------ -------- ---------- ------------------------------------------------\n");
                    firstFormat = NO;
                  }
                  break;
                }

                case VS_FORMAT_MJPEG: {
                  UVC_VS_Format_MJPEG_Descriptor *formatDesc = (UVC_VS_Format_MJPEG_Descriptor*)basePtr;
                  currentFormatName = "MJPEG";
                  currentBitsPerPixel = 8; // MJPEG typically 8-bit

                  if (firstFormat) {
                    printf("\n%-10s %-12s %-8s %-10s %s\n", "Format", "Resolution", "FPS", "Bit Depth", "Subsampling");
                    printf("---------- ------------ -------- ---------- ------------------------------------------------\n");
                    firstFormat = NO;
                  }
                  break;
                }

                case VS_FRAME_UNCOMPRESSED:
                case VS_FRAME_MJPEG: {
                  UVC_VS_Frame_Descriptor *frameDesc = (UVC_VS_Frame_Descriptor*)basePtr;

                  char resolution[16];
                  snprintf(resolution, sizeof(resolution), "%dx%d",
                           NSSwapLittleShortToHost(frameDesc->wWidth),
                           NSSwapLittleShortToHost(frameDesc->wHeight));

                  // Collect frame rates
                  char fpsStr[128] = "";
                  UInt8 intervalType = frameDesc->bFrameIntervalType;
                  if ( intervalType == 0 ) {
                    // Continuous frame intervals
                    if ( descriptorPrefix->bLength >= 38 ) {
                      UInt32 minInterval = NSSwapLittleLongToHost(frameDesc->dwFrameInterval[0]);
                      UInt32 maxInterval = NSSwapLittleLongToHost(frameDesc->dwFrameInterval[1]);
                      snprintf(fpsStr, sizeof(fpsStr), "%.0f-%.0f",
                               10000000.0 / maxInterval, 10000000.0 / minInterval);
                    }
                  } else {
                    // Discrete frame intervals - show only key rates
                    int fpsCount = 0;
                    for (int i = 0; i < intervalType && i < 3; i++) {
                      UInt32 interval = NSSwapLittleLongToHost(frameDesc->dwFrameInterval[i]);
                      char temp[16];
                      snprintf(temp, sizeof(temp), "%s%.0f", (i > 0 ? "," : ""), 10000000.0 / interval);
                      strncat(fpsStr, temp, sizeof(fpsStr) - strlen(fpsStr) - 1);
                      fpsCount++;
                    }
                    if (intervalType > 3) {
                      strncat(fpsStr, ",+", sizeof(fpsStr) - strlen(fpsStr) - 1);
                    }
                  }

                  // Build bit depth and subsampling strings
                  char bitDepthStr[16] = "";
                  char subsamplingStr[64] = "";

                  if (currentBitsPerPixel > 0) {
                    snprintf(bitDepthStr, sizeof(bitDepthStr), "%d-bit", currentBitsPerPixel);
                  }

                  // Determine subsampling based on format name
                  if (strcmp(currentFormatName, "YUY2") == 0 || strcmp(currentFormatName, "UYVY") == 0) {
                    snprintf(subsamplingStr, sizeof(subsamplingStr), "4:2:2");
                  } else if (strcmp(currentFormatName, "NV12") == 0 || strcmp(currentFormatName, "I420") == 0 || strcmp(currentFormatName, "P010") == 0) {
                    snprintf(subsamplingStr, sizeof(subsamplingStr), "4:2:0");
                  } else if (strcmp(currentFormatName, "MJPEG") == 0) {
                    snprintf(subsamplingStr, sizeof(subsamplingStr), "4:2:0 (compressed)");
                  }

                  // Create unique key for deduplication
                  NSString *entryKey = [NSString stringWithFormat:@"%s|%s|%s|%s",
                                        currentFormatName, resolution, fpsStr, bitDepthStr];

                  // Only print if we haven't seen this exact entry before
                  if (![printedEntries containsObject:entryKey]) {
                    [printedEntries addObject:entryKey];
                    printf("%-10s %-12s %-8s %-10s %s\n", currentFormatName, resolution, fpsStr, bitDepthStr, subsamplingStr);
                  }
                  break;
                }
              }
            }

            basePtr += descriptorPrefix->bLength;
          }

          // Display color space information if available
          if (colorSpace || transferChar || videoRange) {
            printf("---------- ------------ -------- ---------- ------------------------------------------------\n");
            printf("\nColor Space Information:\n");
            if (colorSpace) printf("  Color Primaries: %s\n", colorSpace);
            if (transferChar) printf("  Transfer: %s\n", transferChar);
            if (videoRange) printf("  Matrix/Range: %s\n", videoRange);
          }

          // Clean up
          [printedEntries release];
        }
      }

      (*streamInterface)->Release(streamInterface);
    }

    IOObjectRelease(interfaceIter);
    printf("---------- ------------ -------- ---------- ------------------------------------------------\n");
    printf("\nNotes:\n");
    printf("  - Bit Depth: Bits per color channel (8-bit SDR, 10-bit HDR)\n");
    printf("  - Subsampling: 4:2:2 (half chroma), 4:2:0 (quarter chroma)\n");
    printf("  - Color Space: BT.709 (HD), BT.601 (SD), affects color reproduction\n");
    printf("  - Video Range: Full (0-255) or Limited (16-235) - UVC doesn't always specify\n");
    printf("  - FPS: Shows up to first 3 rates (+ indicates more available)\n");
    printf("========================================\n\n");
  }

@end

//
#if 0
#pragma mark -
#endif
//

@implementation UVCControl(UVCControlPrivate)

  - (id) initControlWithName:(NSString*)controlName
    parentController:(UVCController*)parentController
    controlIndex:(NSUInteger)controlIndex
  {
    if ( (self = [super init]) ) {
      if ( ! [parentController capabilities:&_capabilities forControl:controlIndex] ) {
        [self release];
        self = nil;
      } else {
        _parentController = [parentController retain];
        _controlName = [controlName copy];
        _controlIndex = controlIndex;
        
        uvc_control_t   *controlInfo = &UVCControllerControls[controlIndex];
        
        if ( controlInfo->uvcType == nil ) {
          if ( (controlInfo->uvcType = [UVCType uvcTypeWithCString:controlInfo->uvcTypeDescription]) == nil ) {
            fprintf(stderr, "FATAL ERROR:  unable to instantiate UVCType for description %s !!!\n", controlInfo->uvcTypeDescription);
            exit(EFAULT);
          }
          controlInfo->uvcType = [controlInfo->uvcType retain];
        }
        
        _currentValue = [[UVCValue uvcValueWithType:controlInfo->uvcType] retain];

        _minimum = [UVCValue uvcValueWithType:controlInfo->uvcType];
        _maximum = [UVCValue uvcValueWithType:controlInfo->uvcType];
        _stepSize = [UVCValue uvcValueWithType:controlInfo->uvcType];
        _defaultValue = [UVCValue uvcValueWithType:controlInfo->uvcType];

        [_parentController getLowValue:&_minimum highValue:&_maximum stepSize:&_stepSize defaultValue:&_defaultValue updateCapabilitiesBitmask:&_capabilities forControl:controlIndex];
      }
    }
    return self;
  }

@end

//

@implementation UVCControl : NSObject

  - (void) dealloc
  {
    if ( _controlName ) [_controlName release];
    if ( _parentController ) [_parentController release];
    if ( _currentValue ) [_currentValue release];
    if ( _minimum ) [_minimum release];
    if ( _maximum ) [_maximum release];
    if ( _stepSize ) [_stepSize release];
    if ( _defaultValue ) [_defaultValue release];
    [super dealloc];
  }

//

  - (NSString*) description
  {
    NSMutableString *outString = [[NSMutableString alloc] initWithFormat:@"UVCControl[%@]@%p { capabilities: %012x, byte-size: %lu",
                        _controlName, self,
                        (unsigned int)_capabilities,
                        (unsigned long)[_currentValue byteSize]
                      ];

    if ( [self hasRange] ) {
      [outString appendFormat:@"; range: [%@,%@]", _minimum, _maximum];
    }
    if ( [self hasStepSize] ) {
      [outString appendFormat:@"; step-size: %@", _stepSize];
    }
    if ( [self hasDefaultValue] ) {
      [outString appendFormat:@"; default-value: %@", _defaultValue];
    }
    [outString appendString:@" }"];

    NSString      *returnString = [outString copy];

    [outString release];
    return returnString;
  }

//

  - (BOOL) supportsGetValue
  {
    return ((_capabilities & kUVCControlSupportsGet) != 0);
  }
  - (BOOL) supportsSetValue
  {
    return ((_capabilities & kUVCControlSupportsSet) != 0);
  }
  - (BOOL) hasRange
  {
    return ((_capabilities & kUVCControlHasRange) != 0 );
  }
  - (BOOL) hasStepSize
  {
    return ((_capabilities & kUVCControlHasStepSize) != 0 );
  }
  - (BOOL) hasDefaultValue
  {
    return ((_capabilities & kUVCControlHasDefaultValue) != 0 );
  }

//

  - (NSString*) controlName
  {
    return _controlName;
  }

//

  - (UVCValue*) currentValue
  {
    if ( [self readIntoCurrentValue] ) return _currentValue;
    return nil;
  }
  - (UVCValue*) minimum { return _minimum; }
  - (UVCValue*) maximum { return _maximum; }
  - (UVCValue*) stepSize { return _stepSize; }
  - (UVCValue*) defaultValue { return _defaultValue; }

//

  - (BOOL) resetToDefaultValue
  {
    if ( [self hasDefaultValue] ) return [_parentController setValue:_defaultValue forControl:_controlIndex];
    return NO;
  }
  
//

  - (BOOL) setCurrentValueFromCString:(const char*)cString
    flags:(UVCTypeScanFlags)flags
  {
    return [_currentValue scanCString:cString flags:flags minimum:_minimum maximum:_maximum stepSize:_stepSize defaultValue:_defaultValue];
  }

//

  - (BOOL) readIntoCurrentValue
  {
    return [_parentController getValue:_currentValue forControl:_controlIndex];
  }
  
//

  - (BOOL) writeFromCurrentValue
  {
    return [_parentController setValue:_currentValue forControl:_controlIndex];
  }

//

  - (NSString*) summaryString
  {
    NSMutableString     *asString = [[NSMutableString alloc] initWithFormat:@"%@ {\n  type-description: {\n%@  },",
                                            _controlName, [[_currentValue valueType] typeSummaryString]];
    if ( [self hasRange] ) {
      [asString appendFormat:@"\n  minimum: %@", [_minimum stringValue]];
      [asString appendFormat:@"\n  maximum: %@", [_maximum stringValue]];
    }
    if ( [self hasStepSize] ) {
      [asString appendFormat:@"\n  step-size: %@", [_stepSize stringValue]];
    }
    if ( [self hasDefaultValue] ) {
      [asString appendFormat:@"\n  default-value: %@", [_defaultValue stringValue]];
    }
    
    UVCValue    *curValue = [self currentValue];
    if ( curValue ) [asString appendFormat:@"\n  current-value: %@", [curValue stringValue]]; 
    
    [asString appendString:@"\n}"];
    
    NSString      *outString = [[asString copy] autorelease];
    [asString release];
    
    return outString;
  }

@end

//

NSString *UVCTerminalControlScanningMode = @"scanning-mode";
NSString *UVCTerminalControlAutoExposureMode = @"auto-exposure-mode";
NSString *UVCTerminalControlAutoExposurePriority = @"auto-exposure-priority";
NSString *UVCTerminalControlExposureTimeAbsolute = @"exposure-time-abs";
NSString *UVCTerminalControlExposureTimeRelative = @"exposure-time-rel";
NSString *UVCTerminalControlFocusAbsolute = @"focus-abs";
NSString *UVCTerminalControlFocusRelative = @"focus-rel";
NSString *UVCTerminalControlAutoFocus = @"auto-focus";
NSString *UVCTerminalControlIrisAbsolute = @"iris-abs";
NSString *UVCTerminalControlIrisRelative = @"iris-rel";
NSString *UVCTerminalControlZoomAbsolute = @"zoom-abs";
NSString *UVCTerminalControlZoomRelative = @"zoom-rel";
NSString *UVCTerminalControlPanTiltAbsolute = @"pan-tilt-abs";
NSString *UVCTerminalControlPanTiltRelative = @"pan-tilt-rel";
NSString *UVCTerminalControlRollAbsolute = @"roll-abs";
NSString *UVCTerminalControlRollRelative = @"roll-rel";
NSString *UVCTerminalControlPrivacy = @"privacy";
NSString *UVCTerminalControlFocusSimple = @"focus-simple";
NSString *UVCTerminalControlWindow = @"window";
NSString *UVCTerminalControlRegionOfInterest = @"region-of-interest";

//

NSString *UVCProcessingUnitControlBacklightCompensation = @"backlight-compensation";
NSString *UVCProcessingUnitControlBrightness = @"brightness";
NSString *UVCProcessingUnitControlContrast = @"contrast";
NSString *UVCProcessingUnitControlGain = @"gain";
NSString *UVCProcessingUnitControlPowerLineFrequency = @"power-line-frequency";
NSString *UVCProcessingUnitControlHue = @"hue";
NSString *UVCProcessingUnitControlSaturation = @"saturation";
NSString *UVCProcessingUnitControlSharpness = @"sharpness";
NSString *UVCProcessingUnitControlGamma = @"gamma";
NSString *UVCProcessingUnitControlWhiteBalanceTemperature = @"white-balance-temp";
NSString *UVCProcessingUnitControlAutoWhiteBalanceTemperature = @"auto-white-balance-temp";
NSString *UVCProcessingUnitControlWhiteBalanceComponent = @"white-balance-component";
NSString *UVCProcessingUnitControlAutoWhiteBalanceComponent = @"auto-white-balance-component";
NSString *UVCProcessingUnitControlDigitalMultiplier = @"digital-multiplier";
NSString *UVCProcessingUnitControlDigitalMultiplierLimit = @"digital-multiplier-limit";
NSString *UVCProcessingUnitControlAutoHue = @"auto-hue";
NSString *UVCProcessingUnitControlAnalogVideoStandard = @"analog-video-standard";
NSString *UVCProcessingUnitControlAnalogLockStatus = @"analog-lock-status";
NSString *UVCProcessingUnitControlAutoContrast = @"auto-contrast";

