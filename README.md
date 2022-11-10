# GoogleUserMessagingPlatform

Simple implementation of Google AdMob User Messaging Platform to use in Unity projects on iOS and Android

**Google documentation:**
- iOS doc : https://developers.google.com/admob/ump/ios/quick-start
- Android doc: https://developers.google.com/admob/ump/android/quick-start

_Note that on iOS the plugin do not manage the App Tracking Transparency Consent._

## Installation

Choose your favourite method:

- **Plain install**
    - Clone or [download](https://github.com/binouze/GoogleUserMessagingPlatform/archive/refs/heads/master.zip) 
this repository and put it in the `Assets/Plugins` folder of your project.
- **Unity Package Manager (Manual)**:
    - Add the following line to *Packages/manifest.json*:
    - `"com.binouze.googleusermessagingplatform": "https://github.com/binouze/GoogleUserMessagingPlatform.git"`
- **Unity Package Manager (Auto)**
    - in the package manager, click on the + 
    - select `add package from GIT url`
    - paste the following url: `"https://github.com/binouze/GoogleUserMessagingPlatform.git"`


## How to use

```csharp
    private void Start()
    {
        // These settings must be set before Initialisation call
        if( DEBUG )
        {
            // this one is false by default
            GoogleUserMessagingPlatform.SetDebugLogging( true );
            
            // Set here your device ID for testing, 
            // if not set, the device ID to put here will be shown in the console
            #if UNITY_IOS
            GoogleUserMessagingPlatform.SetDebugMode( "XXXXXXXXX", true );
            #elif UNITY_ANDROID
            GoogleUserMessagingPlatform.SetDebugMode( "XXXXXXXXX", true );
            #endif
        }
        
        // Better to have this one set before the Initialisation too
        // so after initialisation it will be called with the current status
        GoogleUserMessagingPlatform.SetOnStatusChangedListener( MajConsentStatus );
        // Initialize GoogleUserMessagingPlatform
        GoogleUserMessagingPlatform.Initialize();
    }
    
    private void MajConsentStatus( ConsentStatus status )
    {
        // Maybe you want to show the form directly after the initialisation if status is REQUIRED
        GoogleUserMessagingPlatform.ShowFormIfRequired();
    }
    
    private void ShowConsentFormBeforeAction()
    {
        // Maybe you want to show the consent form before to make an action
        GoogleUserMessagingPlatform.ShowForm( () => {
            // Do whatever after
        });
        
        // Maybe you want to show the consent form before to make an action only if status is REQUIRED
        GoogleUserMessagingPlatform.ShowFormIfRequired( () => {
            // Do whatever after
        });
    }
    
    
    private void InitFormButton()
    {
        // If you want a button to show the form only if available
        Button.gameObject.SetActive( GoogleUserMessagingPlatform.IsFormAvailable() );
        Button.onClick.AddListener( GoogleUserMessagingPlatform.ShowForm )
    }
    
```