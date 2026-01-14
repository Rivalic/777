//
//  DeviceIDRotator.h
//  Device ID Rotator Dylib Header
//

#ifndef DeviceIDRotator_h
#define DeviceIDRotator_h

#ifdef __cplusplus
extern "C" {
#endif

// Rotate to a new device ID
void rotateDeviceID(void);

// Get current device ID (returns C string, caller must free if needed)
const char* getCurrentDeviceID(void);

#ifdef __cplusplus
}
#endif

#endif /* DeviceIDRotator_h */
