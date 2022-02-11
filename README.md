# Touchpoint Mobile SDK
The purpose of the Touchpoint mobile SDK is to create an integration between a mobile app and Touchpoint. This integration enables the ability to publish and manage the Touchpoint activities that are displayed in a mobile app without the need to release a new version of the mobile app or make any code changes.

## Minimum Requirements
- iOS version 10.0

## Sample App
https://github.com/chad-vc/touchpointkit-sample-ios

## Glossary
- Touchpoint activity: an activity created by a user via the Touchpoint dashboard.
- Touchpoint distribution: a distribution defines how an activity is propagated amongst respondents and manages the publishing lifecycle. A distribution can have different types, in this case it would be a mobile distribution. A distribution is linked to a Touchpoint activity.
- Screen name: a unique label given to a specific screen/view/page on a mobile app. Some examples are: Login, Product List, Product Detail, or Settings. A screen can be assigned to a particular Touchpoint distribution so that different activities can be displayed in different screens in your app.
- Visitor: the end user interacting with the mobile app. The app is able to set any arbitrary attributes for the current visitor. Some examples are: email, an internal unique identifier, shoe size, etc. These attributes are sent to Touchpoint and can be exported by Touchpoint admins.
- Banner: a UI component that the SDK can render at any time on any screen without a need for code change to the mobile app. Clicking on a banner opens a Touchpoint activity inside a webview.  A banner is linked to both a Touchpoint distribution and a screen. A banner has three main attributes:
    - Style: what does the banner look like on the mobile app? The style object includes text colour and background colour.
    - Caption: the text that is shown on the banner.
    - Screen name: which screen in the mobile app should show which particular banner.
- Custom components: UI components developed by integrators of the mobile SDK in their own mobile app codebase. Clicking on or otherwise invoking these components will open a Touchpoint activity inside of a webview.
- Tracking Visitors: a mechanism on the SDK used to track the visitors’ interactions with activities rendered by the SDK. The purpose of which is to ensure visitors don’t see the banners and custom components again if they have already completed the activity. The SDK uses device IDs on iOS and Android to track visitors’ activity.

## Methods for Triggering Touchpoint Activities
There are two ways to trigger Touchpoint activities using the mobile SDK: banners and custom components.

### Banners
Banners are designed with minimizing the integrator’s development effort in mind. Once integrated into the app there are no further code changes required; swapping out activities on the various mobile app screens can be controlled without any code change by invoking APIs on Touchpoint.

A banner has the following properties:
1. Screen name: the screen in the mobile app on which the banner should be shown.
1. Caption: the caption text to render inside the banner.
1. Font colour: the colour of the text in the banner.
1. Background colour: the colour used for the banner’s main container.

#### Banners FAQ
- Q: What happens after the user closes the activity?<br/>
A: The user will stay on the same screen of the app without any change in the state of the app.
- Q: What happens if the user closes the activity without completing the activity?<br/>
A: The SDK won’t show the same banner again to the user and it is marked as “Activity Collapsed”, which means the user closed the activity without completing it.
- Q: What happens if the user taps the X to close the banner without opening the activity?<br/>
A: The SDK tracks this event as “Activity Collapsed” and won’t show the same banner again.
- Q: Can the position of the banner be changed?<br/>
A: Not at this time. All banners render on the bottom of the screen.
- Q: How many banners will users see at any time?<br/>
A: As a rule only one banner will be displayed on a screen at any one time. If there are multiple banners published to the same screen (which the SDK distinguishes using the screen name), the user sees only one banner on each visit. The next time they visit the same screen they will see the next banner.

### Custom Components 
Custom components are designed to enable as many different use cases as possible by giving more control to the integrator. Whereas banners have specific look, positioning, and targeting behaviours, custom components allow the integrator to write their own behavioural logic and UI components to handle these functions. This allows the integrator to fully align the look and feel of their app.

Custom components can use any lifecycle event in an app to trigger a Touchpoint activity, such as a button tap, a page load, a timer going off, etc. Any custom logic can run before triggering the activity as well, such as only triggering an activity if a visitor’s attributes match certain criteria.

#### Custom Components FAQ
- Q: How many custom components can be displayed on the same screen at the same time?<br/>
A: Only one custom component per screen. The SDK will open the activity assigned to the screen and since the screen is unique there can’t be more than one custom component on the same screen.
- Q: Can a custom component be persistent in that it will trigger the activity even if the visitor has already seen it?<br/>
A: This scenario is useful for a use case like a “collect feedback” button where you always want the user to be able to respond to the activity. There is an “always_show” property in distributions which forces the SDK to open the distribution regardless of how many times the visitor has completed/closed that activity.

## Integration

### Touchpoint Setup
Some initial setup is required to create various resources in Touchpoint. Currently the Touchpoint API must be used to create these resources.

#### API Key and Secret
The API key and secret are used to uniquely identify your app with Touchpoint. Make note of the api_key and api_secret in the response as those will be used later.

```bash
curl --location --request POST 'https://api-touchpoint.<pod>.visioncritical.com/dashboard/dashboard.Builder/MobileSDKCreate' \
--header 'x-application-id: <application_id>' \
--header 'Authorization: Bearer <jwt>' \
--header 'Content-Type: application/json' \
--data-raw '{
   "name":"<name>",
   "device_type":"<device_type>",
   "is_active":true
}'
```

Where:
- `pod`: the “pod” that the Touchpoint instance belongs to. This can be determined from the URL bar when you are logged into Touchpoint, such as https://app.eu2.visioncritical.com/touchpoint. Can be one of: `na1`, `na2`, `eu1`, `eu2`, `ap2`.
- `application_id`: this can be obtained by looking at the network traffic when logging in to Alida. Look for an API request like https://eu2.visioncritical.com/c/uishellcontext/appcontext?applicationId=<application_id>, the application ID is in the query string.
- `jwt`: this can be obtained by looking at the network traffic when logging in to Alida. Look for an API request like https://cc.eu2.visioncritical.com/session/validate and inspect the response. The token property in the response is the JWT.
- `name`: an arbitrary name to give this resource, just used for convenience so they can be easily differentiated.
- `device_type`: either `DEVICE_ANDROID` or `DEVICE_IOS`.

#### Distribution
This will create a mobile distribution that can be used by the mobile SDK. Make a note of the ID that is returned in the response, this will be used in subsequent requests.

```bash
curl --location --request POST 'https://api-touchpoint.<pod>.visioncritical.com/dashboard/dashboard.Builder/DistCreate' \
--header 'x-application-id: <application_id>' \
--header 'Authorization: Bearer <jwt>' \
--header 'Content-Type: application/json' \
--data-raw '{
   "activity_id":<activity_id>,
   "dist_name":"<name>",
   "dist_type":"DIST_MOBILE"
}'
```

Where:
- `pod`: the “pod” that the Touchpoint instance belongs to. This can be determined from the URL bar when you are logged into Touchpoint, such as https://app.eu2.visioncritical.com/touchpoint. Can be one of: `na1`, `na2`, `eu1`, `eu2`, `ap2`.
- `application_id`: this can be obtained by looking at the network traffic when logging in to Alida. Look for an API request like https://eu2.visioncritical.com/c/uishellcontext/appcontext?applicationId=<application_id>, the application ID is in the query string.
- `jwt`: this can be obtained by looking at the network traffic when logging in to Alida. Look for an API request like https://cc.eu2.visioncritical.com/session/validate and inspect the response. The token property in the response is the JWT.
- `name`: an arbitrary name to give this resource, just used for convenience so they can be easily differentiated.
- `activity_id`: the ID of the activity to be displayed. This can be obtained by navigating on the web to the report page for that activity. The location bar in the browser will have a number which is the activity ID. For example: https://app.eu2.visioncritical.com/touchpoint/activities/1902/report, in this case 1902.

#### Banners
A banner ties a distribution to a screen name. A screen name is required for both banner and custom component methods.

```bash
curl --location --request POST 'https://api-touchpoint.<pod>.visioncritical.com/dashboard/dashboard.Builder/MobileSDKBannerCreate' \
--header 'x-application-id: <application_id>' \
--header 'Authorization: Bearer <jwt>' \
--header 'Content-Type: application/json' \
--data-raw '{
   "api_key": "<api_key>",
   "caption_text": "<caption_text>",
   "dist_id": "<distribution_id>",
   "screen_name": "<screen_name>",
   "style": {
       "backgroundColor": "<bg_color>",
       "textColor": "<text_color>"
   },
   "use_banner_styling": <styling>
}'
```

Where:
- `pod`: the “pod” that the Touchpoint instance belongs to. This can be determined from the URL bar when you are logged into Touchpoint, such as https://app.eu2.visioncritical.com/touchpoint. Can be one of: `na1`, `na2`, `eu1`, `eu2`, `ap2`.
- `application_id`: this can be obtained by looking at the network traffic when logging in to Alida. Look for an API request like https://eu2.visioncritical.com/c/uishellcontext/appcontext?applicationId=<application_id>, the application ID is in the query string.
- `jwt`: this can be obtained by looking at the network traffic when logging in to Alida. Look for an API request like https://cc.eu2.visioncritical.com/session/validate and inspect the response. The token property in the response is the JWT.
- `api_key`: this is found in the response from the request made in the API Key and Secret section above.
- `caption_text`: the text that will appear in the banner, used only in the banner method.
- `distribution_id`: the ID found in the response from the request made in the Distribution section above.
- `screen_name`: the name of the screen this banner should appear on.
- `bg_color`: the hex value of the background colour, such as #00ff00. Used only in the banner method.
- `text_color`: the value of the text colour, such as #00ff00. Used only in the banner method.
- `styling`: a boolean value that specifies whether or not to use the specified style. Either true or false.

## Installation using Pods
Include the following in your `Podfile`:

```pod
pod 'TouchPointKit', :git => 'https://github.com/vcilabs/touchpoint-kit-ios.git', :tag => '0.1.8'
```

And run `pod install`

## Installation using SPM
Inside the XCode package manager, add the following URL: `https://github.com/vcilabs/touchpoint-kit-ios`.

## Implementation
In the AppDelegate class, import the SDK using: `import TouchPointKit`. Then In the `didFinishLaunchingWithOptions` function add the following initialization code.

```swift
//SWIFT
let apiKey = API_KEY
let apiSecret = API_SECRET
let podName = TouchPointPods.eu2 // na1, na2, eu1, eu2, ap2
let screenNames = ["Screen1", "Screen2"]
let visitor = ["id": "12345", "email": "ios_visitor@example.com", "favorite_food": "oranges"]

TouchPointActivity.shared.configure(apiKey: apiKey,
                                    apiSecret: apiSecret,
                                    podName: podName,
                                    screenNames: screenNames,
                                    visitor: visitor)
 
// Note: the following are optional properties for developer convenience

// For testing you can set this property to false so that the API will not filter data based on visitor id and uuid
TouchPointActivity.shared.shouldApplyAPIFilter = false

// To disable wkwebview caching, set to true
TouchPointActivity.shared.disableCaching = true

// To change banner height, you can set this property
TouchPointActivity.shared.defaultBannerHeight = 50

// To enable debug logs, set this property to true
TouchPointActivity.shared.enableDebugLogs = true

// If status bar style is dark, set this property to false
TouchPointActivity.shared.isStatusBarStyleLight = false
```

```objc
// Objective-C
NSString *apiKey = API_KEY;
NSString *apiSecret = API_SECRET;
TouchPointPods pod = TouchPointPods.eu2; // na1, na2, eu1, eu2, ap2
NSArray *screens = [[NSArray alloc] initWithObjects:@"Demo 1", @"Demo 2"];
NSDictionary *visitorDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"id",@"12345",@"email",@"ios_visitor@example.com", nil];

[[TouchPointActivity shared] configureWithApiKey: apiKey apiSecret: apiSecret podName: pod screenNames: screens visitor: visitorDict];

// Note: the following are optional properties for developer convenience

// For testing you can set this property to false so that the API will not filter data based on visitor id and uuid
[TouchPointActivity shared].shouldApplyAPIFilter = false;

// To disable wkwebview caching, set o true
[TouchPointActivity shared].disableCaching = true;

// To change banner height, you can set this property
[TouchPointActivity shared].defaultBannerHeight = 50;

// To enable debug logs, set this property to true
[TouchPointActivity shared].enableDebugLogs = true;

// If status bar style is dark, set this property to false
[TouchPointActivity shared].isStatusBarStyleLight = false;
```

Where:
- The values for `API_KEY`, and `API_SECRET` will come from the API calls made above.
- `pod_name`: the “pod” that the Touchpoint instance belongs to. This can be determined from the URL bar when you are logged into Touchpoint, such as https://app.eu2.visioncritical.com/touchpoint. Can be one of: `na1`, `na2`, `eu1`, `eu2`, `ap2`.

For a banner workflow you will just need to tell the SDK which screen is currently visible. To do this import the SDK in a `View` or `ViewController` using: `import TouchPointKit`, and set the screen using:

```swift
//SWIFT
TouchPointActivity.shared.setScreenName(screenName: SCREEN_NAME)
```

```objc
// Objective-C
[[TouchPointActivity shared] setScreenNameWithScreenName:SCREEN_NAME];
```

This will look for any banner for the specified screen (`SCREEN_NAME`) and display the banner automatically.

If the custom component method is preferred open a Touchpoint activity directly by invoking the following method:

```swift
//SWIFT
TouchPointActivity.shared.openActivityForScreen(screenName: SCREEN_NAME, delegate: self)
```

```objc
// Objective-C
[[TouchPointActivity shared] openActivityForScreenWithScreenName: SCREEN_NAME delegate: self];
```

`TouchPointActivityCompletionDelegate` is required to receive a callback when the Touchpoint activity has completed. Otherwise pass `nil` to the delegate. The following is the `TouchPointActivityCompletionDelegate` delegate method.

```swift
//SWIFT
public func didActivityCompleted() {
    // Calls when TouchPoint activity is completed.
}
```

```objc
// Objective-C
- (void)didActivityCompleted {
    // Calls when TouchPoint activity is completed.
}
```

Before calling the `openActivityForScreen` function, it is possible to check if a Touchpoint activity needs to be shown using the following method:

```swift
//SWIFT
if TouchPointActivity.shared.shouldShowActivity(screenName: SCREEN_NAME) {
    // Call openActivity function of TouchPointActivity
}
```

```objc
// Objective-C
if ([[TouchPointActivity shared] shouldShowActivityWithScreenName: SCREEN_NAME]) {
    // Call openActivityWithScreenName function of TouchPointActivity
}
```