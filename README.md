# Touchpoint Mobile SDK
The purpose of the Touchpoint mobile SDK is to create an integration between a mobile app and Alida Touchpoint. This integration enables the ability to publish and manage the Touchpoint activities that are displayed in a mobile app without the need to release a new version of the mobile app or make any code changes.

Important concepts regarding Touchpoint can be found [here](https://touchpoint.help.alida.com/redirect.html#9C2DA302D89B4DCD8DE1377F84A07BD1). Some of these concepts are also described briefly below but the link above has a more thorough description.

## Minimum Requirements
- iOS version 10.0

## Sample App
https://github.com/vcilabs/touchpointkit-sample-ios

## Installation using Pods
Include the following in your `Podfile`. To determine the latest tag please see https://github.com/vcilabs/touchpoint-kit-ios/tags.

```pod
pod 'TouchPointKit', :git => 'https://github.com/vcilabs/touchpoint-kit-ios.git', :tag => '1.0.3'
```

Then run `pod install`

## Installation using SPM
Inside the XCode package manager, add the following URL: `https://github.com/vcilabs/touchpoint-kit-ios`. To determine the latest tag please see https://github.com/vcilabs/touchpoint-kit-ios/tags.

## Concepts
A central design goal of the SDK is to require only an upfront effort from the mobile app developer to "Touchpoint enable" various screens in the mobile app, and eliminate any ongoing effort related to switching which particular activity is being shown. The Touchpoint admin is able to switch the Touchpoint activity with no development effort required.

As a result of this decoupling there is never any reference to a particular activity in this SDK. All configuration and distribution for an activity happens by the Touchpoint admin inside the Touchpoint user interface.

* Triggers: a trigger is how a Touchpoint activity gets activated and displayed to the user. There are three different types of triggers that are supported in the SDK.
    * Banner: a Banner is displayed after a user navigates to a particular screen. A UI element is shown at the bottom of the screen with a call to action. Tapping the banner will display the Activity.
    * Pop-up: a Pop-up is displayed after a user navigates to a particular screen (after an optional delay). There is no UI component to a Pop-up, the Touchpoint activity simply displays.
    * Custom Component: a Custom Component is a way to trigger a Touchpoint activity during any arbitrary lifecycle event and is fully under the developer's control. An activity can be triggered after a button tap, after the user visits a screen for the 2nd time, or any other custom logic.
* Screens: a Screen is a page or view in your mobile app, such as the home screen, product list screen, product details screen, settings screen, etc. You can designate any screen in your mobile app as being available to display a Touchpoint activity.
* Components: a component is some UI element on a screen in your mobile app. This could be something like a button, or something more abstract like the number of times a user has visited a particular screen.
* Targeting: it is possible for the Touchpoint admin to target particular Touchpoint activities based on certain User Attributes of the current user of the app. The User Attributes of the current user can be defined in the mobile app and are then used by Touchpoint to perform targeting.

Banner and Pop-up types of triggers are out of the box methods for triggering an activity. This is meant to make integration easier at the cost of flexibility. A Custom Component requires some custom logic to trigger but it provides flexibility as the logic is fully under the control of the app developer.

After a user finishes an activity the activity will be closed and the user will remain on the same screen with no change in state.

### Putting It All Together
As a developer of a mobile app you can designate which Screens and which Screen Components are capable of triggering Touchtpoint activities. You don't need to be concerned about which specific Touchpoint activity is assigned to a particular screen as that is controlled by the Touchpoint admin.

If the desire is to have a Banner or Pop-up activity on a particular screen you will only need to define and provide a screen name. If using a Custom Component you will need to provide both a screen name and a component name. For example:

```swift
let screenComponents = [
        [ "screenName": "Home" ],
        [ "screenName": "Settings", "componentName": "Lightbulb" ],
        [ "screenName": "ProductList" ],
    ]
```

Here we are defining the `Home` screen and `ProductList` screen as being able to display Banner and Pop-up types of triggers. Then on our `Settings` screen we have a button we've named `Lightbulb` that is now able to display a Custom Component trigger. A Screen can support multiple Components.

## Implementation

### Initial Setup

In the AppDelegate class, import the SDK using: `import TouchPointKit`. Then In the `didFinishLaunchingWithOptions` function add the following initialization code.

```swift
// API key and secret are provided by the Touchpoint UI
let apiKey = API_KEY 
let apiSecret = API_SECRET

// The pod is the geographical region hosting your instance of Touchpoint.
// Easiest determined from your URL while logged in, e.g. eu2.alida.com
// Valid values are: na1, na2, eu1, eu2, ap2, ap3
let podName = TouchPointPods.eu2 

// The locale is an optional parameter you can provide
// It will indicate the language your activity is displayed to the user in
// as long as that activity has been distributed with said language.
// If not or no locale is provided, your activity will be displayed in English.
// This same language logic applies to the banner text, should you have
// an activity which is of type Banner
// Valid values are: 'AR', 'ZH', 'EN', 'FR', 'DE', 'ID', 'IT', 'JA', 'KO', 'PL', 'PT', 'RU', 'ES', 'TH', 'TR', 'VI'
let locale = 'EN'

// These are the Screens and Screen Components in your mobile app that you 
// designate as being able to render Touchpoint activities.
let screenComponents = [
        [ "screenName": "Home" ],
        [ "screenName": "Settings", "componentName": "Lightbulb" ],
        [ "screenName": "ProductList" ],
    ]

// The visitor payload describes the current user of the app. The "id"
// is used to help determine if this particular user has already
// seen certain activities and should be a unique identifier.
// "userAttributes" are the targeting parameters. "type" is the data type
// found in the "value". The data type is required as Touchpoint has
// various operators that make sense for certain data types and not 
// others, such as "greater than" or "less than" for numbers.
// Valid values are number, boolean, string and date.
let visitor = [
        "id": "12345",
        "userAttributes": [ // These are used in targeting
            [
                "key": "age", 
                "type": "number",
                "value": "53"
            ],
            [
                "key": "isLoyaltyMember",
                "type": "boolean",
                "value": "true"
            ],
            [
                "key": "city",
                "type": "string",
                "value": "Springfield"
            ],
            [
                "key": "previousVisitDate",
                "type": "date",
                "value": "2022-04-11T21:51:34+0000"
            ]
        ]
    ] as [String : Any]

TouchPointActivity.shared.configure(
    apiKey: apiKey,
    apiSecret: apiSecret,
    podName: podName,
    locale: locale,
    screenComponents: screenComponents,
    visitor: visitor)
 
// The following are optional properties for developer convenience

// Should be "false" in production and is "false" by default.
// Touchpoint generally won't show an activity to the same user twice which
// can make it tricky to test. Setting this to "true" makes it
// possible for a user to be served the same activity more than once.
TouchPointActivity.shared.disableAPIFilter = false

// To disable wkwebview caching, set to "true". "false" by default.
TouchPointActivity.shared.disableCaching = false

// Logs at debug level are silenced by default. To enable debug logs, 
// set this to "true". "false" by default.
TouchPointActivity.shared.enableDebugLogs = true

// Prevents any logs being generated, default is "false".
TouchPointActivity.shared.disableAllLogs = false

// If status bar style is dark, set this property to "false". "true" by
// default.
TouchPointActivity.shared.isStatusBarStyleLight = false

// The height of the banner UI element in pixels. Default is "70".
TouchPointActivity.shared.defaultBannerHeight = 50
```

#### NOTE
Do not leverage visitor attributes to pass personally identifying information (PII) into Touchpoint. To protect visitor privacy, do not pass data into Touchpoint that could be considered as personally identifiable information (PII). PII includes, but is not limited to, information such as social security numbers, personal home addresses, credit card numbers, financial account numbers, street address, etc.

### Triggering Banners and Pop-ups

For Banner and Pop-up triggers you will just need to tell the SDK which screen is currently visible. To do this import the SDK in a `View` or `ViewController` using: `import TouchPointKit`, and set the screen using the below, preferably in the `viewDidLoad` function:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    TouchPointActivity.shared.setScreenName(screenName: SCREEN_NAME)
}
```

Any Banner or Pop-up assigned to the specified screen will be triggered and display automatically.

Since Pop-ups can be configured by the Touchpoint admin to trigger only after a specified amount of time has passed, it is possible for a user to navigate to a screen and quickly navigate away before the Pop-up is shown. The Pop-up will then be displayed on the second screen, which may be undesired. To prevent this it is possible to cancel the Pop-up when the first screen is being dismissed:

```swift
TouchPointActivity.shared.cancelPopupForScreen(screenName: SCREEN_NAME)
```

### Triggering Custom Components
For the Custom Component trigger you can hook into any lifecycle event and invoke the Touchpoint activity directly:

```swift
TouchPointActivity.shared.openActivityForScreenComponent(screenName: SCREEN_NAME, componentName: COMPONENT_NAME, delegate: self)
```

Before calling the `openActivityForScreenComponent` function, it is possible to check if a Touchpoint activity needs to be shown using the following method:

```swift
if TouchPointActivity.shared.shouldShowActivity(screenName: SCREEN_NAME, componentName: COMPONENT_NAME) {
    // Call openActivityForScreenComponent
}
```

This will allow you to manage how you render out your screen, for example by hiding or showing a button based on whether or not a Touchpoint activity is availble.

### Refreshing the Activity List
On each call to `TouchPointActivity.shared.configure` the SDK will reach out to Touchpoint to get the list of valid activities for the current user and cache them. Typically this function is run when the app loads up and is not called again, which could cause the list of activities to become stale. There is a helper function that will refresh this activity list for you:

```kotlin
TouchPointActivity.shared.refreshActivities()
```

This can be called at any time after `TouchPointActivity.shared.configure` and will get a fresh list of activities from Touchpoint.

Note: Typically when a Touchpoint campaign is distributed to an app only one activity in the campaign will be shown per "session", as `TouchPointActivity.shared.configure` is usually called once on app start. Using `TouchPointActivity.shared.refreshActivities` can lead to the next activity in the campaign being displayed within the same user session.

### Callback Events
The Touchpoint SDK offers two different callbacks that can be used to trigger custom logic as the user interacts with the activity.
1. Collapse: when the user closes or collapses the activity. At this point the activity has just been removed from view and the user is back interacting with the app.
2. Complete: when the user finishes the last question in the activity and the activity is considered done. The activity is now considered "complete" for reporting purposes in Touchpoint. The user is still viewing the activity.

To implement these callbacks your class should subclass `TouchPointActivityDelegate` and implement the two functions `onTouchPointActivityCollapse` and `onTouchPointActivityComplete`. Note that `onTouchPointActivityComplete` is optional.

Example:

```swift
class CustomComponentViewController: UIViewController, TouchPointActivityDelegate {
    // ...
    
    func onTouchPointActivityComplete() {
        let activityCompleteAlert: UIAlertView = UIAlertView(title: "Thanks for completing the activity!", message: "We really appreciate your feedback",
                             delegate: self, cancelButtonTitle: "OK")
        activityCompleteAlert.show()
    }
    
    func onTouchPointActivityCollapse() {
        curSelectedButton?.isEnabled = false
    }

    // ...    
}
```

## React Native Integration for iOS

In your React Native project will be a folder named `ios`. In this folder will be the iOS native part of your app. To install this SDK into your app use one of the methods described above, either via [Podfile](#installation-using-pods) or [SPM](#installation-using-spm)

In the `AppDelegate.m` file import the SDK by adding an import line at the top of the file: `@import TouchPointKit;` and add the following code snippet in `AppDelegate.m`'s `didFinishLaunchingWithOptions` function.

Please see the [Initial Setup](#initial-setup) section above for a description of how to use the various parameters in the snippet below and what their usage is.

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //...

    NSString *apiKey = @"API_KEY";
    NSString *apiSecret = @"API_SECRET";

    // Possible values: TouchPointPodsNA1, TouchPointPodsNA2, TouchPointPodsEU1,
    // TouchPointPodsEU2, TouchPointPodsAP2, TouchPointPodsAP3
    TouchPointPods pod = TouchPointPodsEU2;

    NSString *locale = @"EN"

    // Example user attributes used for targeting, see the integration details
    // above for more details.
    NSArray *userAttributes = @[
        @{ @"key": @"age", @"type": @"number", @"value": @"53" },
        @{ @"key": @"isLoyaltyMember", @"type": @"boolean", @"value": @"true" },
        @{ @"key": @"city", @"type": @"string", @"value": @"Springfield" },
        @{ @"key": @"previousVisitDate", @"type": @"date", @"value": @"2022-04-11T21:51:34+0000" },
    ];
    NSDictionary *visitor = [[NSDictionary alloc] initWithObjectsAndKeys:@"12345", @"id", userAttributes, @"userAttributes", nil];

    // Example screens and components
    NSArray *screenComponents = @[
        @{ @"screenName": @"Banner Screen" },
        @{ @"screenName": @"Popup Screen" },
        @{ @"screenName": @"Custom Component Screen", @"componentName": @"Button 1" },
        @{ @"screenName": @"Custom Component Screen", @"componentName": @"Button 2" },
        @{ @"screenName": @"Custom Component Screen", @"componentName": @"Button 3" },
    ];

    [[TouchPointActivity shared] configureWithApiKey: apiKey apiSecret: apiSecret podName: pod locale: locale screenComponents: screenComponents visitor: visitor];

    // Optional configuration elements, see integration details above for more details
    [TouchPointActivity shared].disableAPIFilter = false;
    [TouchPointActivity shared].disableCaching = false;
    [TouchPointActivity shared].enableDebugLogs = true;
    [TouchPointActivity shared].disableAllLogs = false;
    [TouchPointActivity shared].isStatusBarStyleLight = false;
    [TouchPointActivity shared].defaultBannerHeight = 50;
    
    //...
}
```

Now create two files inside your iOS project name `TouchPointKitBridge.h` and `TouchPointKitBridge.m`. Add the following code to these files:

```objc
//  TouchPointKitBridge.h
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
@import TouchPointKit;

NS_ASSUME_NONNULL_BEGIN

@interface TouchPointKitBridge : RCTEventEmitter <RCTBridgeModule, TouchPointActivityDelegate>

@end

NS_ASSUME_NONNULL_END
```

```objc
//  TouchPointKitBridge.m
#import "TouchPointKitBridge.h"

@implementation TouchPointKitBridge
{
  bool hasListeners;
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(configure:(NSString *)apiKey apiSecret:(NSString *)apiSecret pod:(int)pod locale: (NSString *)locale screens:(NSArray *)screens visitor:(NSDictionary *)visitor ) {
  [[TouchPointActivity shared] configureWithApiKey:apiKey apiSecret:apiSecret podName:pod locale:locale screenComponents:screens visitor:visitor];
}

RCT_EXPORT_METHOD(refreshActivities) {
  [[TouchPointActivity shared] refreshActivities];
}

RCT_EXPORT_METHOD(setVisitor:(NSDictionary<NSString *, id> *)visitor)
{
  [TouchPointActivity shared].visitor = visitor;
}

RCT_EXPORT_METHOD(enableDebugLogs:(BOOL)enable)
{
  [TouchPointActivity shared].enableDebugLogs = enable;
}

RCT_EXPORT_METHOD(disableAllLogs:(BOOL)disable)
{
  [TouchPointActivity shared].disableAllLogs = disable;
}

RCT_EXPORT_METHOD(disableAPIFilter:(BOOL)disableAPIFilter)
{
  [TouchPointActivity shared].disableAPIFilter = disableAPIFilter;
}

RCT_EXPORT_METHOD(disableCaching:(BOOL)caching)
{
  [TouchPointActivity shared].disableCaching = caching;
}

RCT_EXPORT_METHOD(isStatusBarStyleLight:(BOOL)isStatusBarStyleLight)
{
  [TouchPointActivity shared].isStatusBarStyleLight = isStatusBarStyleLight;
}

RCT_EXPORT_METHOD(defaultBannerHeight:(CGFloat)defaultBannerHeight)
{
  [TouchPointActivity shared].defaultBannerHeight = defaultBannerHeight;
}


RCT_EXPORT_METHOD(setScreen:(NSString *)screenName)
{
  [[TouchPointActivity shared] setScreenNameWithScreenName:screenName delegate: self];
}

RCT_EXPORT_METHOD(openActivity:(NSString *)screenName componentName:(NSString *)componentName)
{
  if ([[TouchPointActivity shared] shouldShowActivityWithScreenName: screenName componentName: componentName]) {
    [[TouchPointActivity shared] openActivityForScreenComponentWithScreenName: screenName componentName:componentName delegate: self];
  }
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(shouldShowActivity:(NSString *)screenName) {
  BOOL val = [[TouchPointActivity shared] shouldShowActivityWithScreenName: screenName componentName: NULL];
    return [NSNumber numberWithBool:val];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(shouldShowActivity:(NSString *)screenName componentName:(NSString *)componentName)  {
  BOOL val = [[TouchPointActivity shared] shouldShowActivityWithScreenName: screenName componentName: componentName];
    return [NSNumber numberWithBool:val];
}

RCT_EXPORT_METHOD(openActivityForUrl:(NSString *)url alwaysShow:(BOOL)alwaysShow)
{
  [[TouchPointActivity shared] openActivityForUrlWithDistUrl:url useBannerStyling:false delegate:self alwaysShow:alwaysShow];
}

RCT_EXPORT_METHOD(clearCache)
{
  NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
  NSDictionary * dict = [userDefaults dictionaryRepresentation];
  for (id key in dict) {
      [userDefaults removeObjectForKey:key];
  }
  [userDefaults synchronize];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (void) onTouchPointActivityComplete {
  if (hasListeners) {
    [self sendEventWithName:@"onTouchPointActivityComplete" body:@"TouchPointActivityCompleted"];
  }
}

- (void) onTouchPointActivityCollapse {
  if (hasListeners) {
    [self sendEventWithName:@"onTouchPointActivityCollapse" body:@"TouchPointActivityCollapsed"];
  }
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"onTouchPointActivityComplete", @"onTouchPointActivityCollapse"];
}

@end
```

From your App.js call `TouchPointKitBridge` methods using `NativeModules`.

```javascript
import {
  NativeModules,
  NativeEventEmitter,
} from 'react-native';

// Register for event listening from SDK (activity complete event)
const { TouchPointKitBridge } = NativeModules;
const eventEmitter = new NativeEventEmitter(TouchPointKitBridge);
eventEmitter.addListener(
  'onTouchPointActivityComplete',
  onTouchPointActivityComplete,
);

eventEmitter.addListener(
  'onTouchPointActivityCollapse',
  onTouchPointActivityCollapse,
);

const onTouchPointActivityComplete = (event) => {
  console.log('onTouchPointActivityComplete called');
  console.log(event);
};

const onTouchPointActivityCollapse = (event) => {
  console.log('onTouchPointActivityCollapse called');
  console.log(event);
};

// To trigger a Pop-up or Banner
NativeModules.TouchPointKitBridge.setScreen('SCREEN_NAME');

// To trigger a custom component
NativeModules.TouchPointKitBridge.openActivity('SCREEN_NAME', 'COMPONENT_NAME');
```
