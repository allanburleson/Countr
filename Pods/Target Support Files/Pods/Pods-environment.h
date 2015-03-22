
// To check if a library is compiled with CocoaPods you
// can use the `COCOAPODS` macro definition which is
// defined in the xcconfigs so it is available in
// headers also when they are imported in the client
// project.


// GoogleAnalytics-iOS-SDK
#define COCOAPODS_POD_AVAILABLE_GoogleAnalytics_iOS_SDK
#define COCOAPODS_VERSION_MAJOR_GoogleAnalytics_iOS_SDK 3
#define COCOAPODS_VERSION_MINOR_GoogleAnalytics_iOS_SDK 10
#define COCOAPODS_VERSION_PATCH_GoogleAnalytics_iOS_SDK 0

// GoogleAnalytics-iOS-SDK/Core
#define COCOAPODS_POD_AVAILABLE_GoogleAnalytics_iOS_SDK_Core
#define COCOAPODS_VERSION_MAJOR_GoogleAnalytics_iOS_SDK_Core 3
#define COCOAPODS_VERSION_MINOR_GoogleAnalytics_iOS_SDK_Core 10
#define COCOAPODS_VERSION_PATCH_GoogleAnalytics_iOS_SDK_Core 0

// NSDate+Helper
#define COCOAPODS_POD_AVAILABLE_NSDate_Helper
#define COCOAPODS_VERSION_MAJOR_NSDate_Helper 1
#define COCOAPODS_VERSION_MINOR_NSDate_Helper 0
#define COCOAPODS_VERSION_PATCH_NSDate_Helper 0

// Debug build configuration
#ifdef DEBUG

  // Reveal-iOS-SDK
  #define COCOAPODS_POD_AVAILABLE_Reveal_iOS_SDK
  #define COCOAPODS_VERSION_MAJOR_Reveal_iOS_SDK 1
  #define COCOAPODS_VERSION_MINOR_Reveal_iOS_SDK 5
  #define COCOAPODS_VERSION_PATCH_Reveal_iOS_SDK 1

#endif
