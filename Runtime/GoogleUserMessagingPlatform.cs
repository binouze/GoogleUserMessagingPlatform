//#define IMPLEMENTING

// https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#in-app-details
// https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20Consent%20string%20and%20vendor%20list%20formats%20v2.md
// https://support.google.com/admob/answer/9760862?hl=en&ref_topic=9756841
// vendor id list: https://vendor-list.consensu.org/v3/vendor-list.json
// additional id infos: https://support.google.com/admanager/answer/9681920?hl=en

using System;
using System.Collections.Generic;
using System.Globalization;
using JetBrains.Annotations;
using UnityEngine;

#if UNITY_IOS
using System.Runtime.InteropServices;
#endif

namespace com.binouze
{
    #if UNITY_ANDROID
    public enum ConsentStatus
    {
        NOT_REQUIRED = 1,
        OBTAINED     = 3,
        REQUIRED     = 2,
        UNKNOWN      = 0
    }
    #else
    public enum ConsentStatus
    {
        NOT_REQUIRED = 2,
        OBTAINED     = 3,
        REQUIRED     = 1,
        UNKNOWN      = 0
    }
    #endif

    public enum VendorsIds
    {
        //AdColony = 458,
        Liftoff  = 667,
        Google   = 755
    }
    
    public enum ExternalIds
    {
        UnityAds = 3234,
        AdMost  = 2900,
        AppLovin   = 1301,
        Chartboost = 2898,
        Singular = 1046,
        AdColony = 2710,
    }

    public class GoogleUserMessagingPlatform : MonoBehaviour
    {
        private const string AndroidClass = "com.binouze.GoogleUserMessagingPlatform";

        private static ConsentStatus _consentStatus = ConsentStatus.UNKNOWN;
        
        [UsedImplicitly]
        public static ConsentStatus ConsentStatus
        {
            get => _consentStatus;
            private set
            {
                if ( _consentStatus == value )
                {
                    return;
                }
                
                _consentStatus = value;
                OnStatusChanged?.Invoke( value );
            }
        }

        private static Action<ConsentStatus> OnStatusChanged;
        private static Action                OnFormClosed;
        private static bool                  LogEnabled;

        #if UNITY_IOS
        [DllImport( "__Internal" )]
        private static extern void _EnableDebugLogging( bool enabled );

        [DllImport( "__Internal" )]
        private static extern void _SetDebugMode( string debugDevice, bool forceReset );

        [DllImport( "__Internal" )]
        private static extern void _SetTargetChildren( bool targetChildren );

        [DllImport( "__Internal" )]
        private static extern void _Initialize();

        [DllImport( "__Internal" )]
        private static extern void _LoadForm( bool forceShow, bool forceDispatch );

        [DllImport( "__Internal" )]
        private static extern bool _IsFormAvailable();

        [DllImport( "__Internal" )]
        private static extern bool _GetCanShowAds();

        [DllImport( "__Internal" )]
        private static extern bool _GetCanShowPersonalizedAds();

        [DllImport( "__Internal" )]
        private static extern bool _GetGDPRRequired();

        [DllImport( "__Internal" )]
        private static extern bool _GetConsentForVendor( int vendorID );

        [DllImport( "__Internal" )]
        private static extern bool _GetConsentForExternal( int externalID );

        [DllImport( "__Internal" )]
        private static extern string _GetPurposeConsent();

        [DllImport( "__Internal" )]
        private static extern string _GetVendorConsent();

        [DllImport( "__Internal" )]
        private static extern string _GetAddtlConsent();

        #endif


        private static void Log( string str )
        {
            if( LogEnabled )
                Debug.Log( $"[GoogleUserMessagingPlatform] {str}" );
        }

        /// <summary>
        /// set it to true to enable plugin logs
        /// </summary>
        /// <param name="enabled"></param>
        [UsedImplicitly]
        public static void SetDebugLogging( bool enabled )
        {
            LogEnabled = enabled;

            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            cls.CallStatic( "EnableDebugLogging", enabled );

            #elif UNITY_IOS

            _EnableDebugLogging( enabled );

            #endif
        }

        /// <summary>
        /// Set debug options to be able to test form
        /// </summary>
        /// <param name="device">the debug device to test on</param>
        /// <param name="forceReset">true to force reset the form datas</param>
        [UsedImplicitly]
        public static void SetDebugMode( string device, bool forceReset )
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            cls.CallStatic( "SetDebugMode", device, forceReset  );

            #elif UNITY_IOS

            _SetDebugMode( device, forceReset );

            #endif
        }

        /// <summary>
        /// set it to true to enable plugin logs
        /// </summary>
        /// <param name="targetChildren"></param>
        [UsedImplicitly]
        public static void SetTargetChildren( bool targetChildren )
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            cls.CallStatic( "SetTargetChildren", targetChildren );

            #elif UNITY_IOS

            _SetTargetChildren( targetChildren );

            #endif
        }

        /// <summary>
        /// returns the IABTCF_PurposeConsents tcf string
        /// </summary>
        [UsedImplicitly]
        public static string GetPurposeConsent()
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return "";
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<string>( "GetPurposeConsent" );

            #elif UNITY_IOS

            return _GetPurposeConsent();

            #else
            
            return "";
            
            #endif
        }

        /// <summary>
        /// returns the IABTCF_VendorConsents tcf string
        /// </summary>
        [UsedImplicitly]
        public static string GetVendorConsent()
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return "";
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<string>( "GetVendorConsent" );

            #elif UNITY_IOS

            return _GetVendorConsent();

            #else
            
            return "";
            
            #endif
        }

        /// <summary>
        /// returns the IABTCF_AddtlConsent tcf string
        /// </summary>
        [UsedImplicitly]
        public static string GetAddtlConsent()
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return "";
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<string>( "GetAddtlConsent" );

            #elif UNITY_IOS

            return _GetAddtlConsent();

            #else
            
            return "";
            
            #endif
        }

        /// <summary>
        /// know if user accepted to share content with the vendor
        /// https://vendor-list.consensu.org/v3/vendor-list.json
        /// </summary>
        [UsedImplicitly]
        public static bool GetConsentForVendor( VendorsIds vendorID )
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return false;
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<bool>( "GetConsentForVendor", (int)vendorID );

            #elif UNITY_IOS

            return _GetConsentForVendor( (int)vendorID );

            #endif
        }
        /// <summary>
        /// know if user accepted to share content with the vendor
        /// https://vendor-list.consensu.org/v3/vendor-list.json
        /// </summary>
        [UsedImplicitly]
        public static bool GetConsentForVendor( int vendorID )
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return false;
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<bool>( "GetConsentForVendor", vendorID );

            #elif UNITY_IOS

            return _GetConsentForVendor( vendorID );

            #else
            
            return false;
            
            #endif
        }
        
        /// <summary>
        /// know if user accepted to share content with the vendor (google additianal id)
        /// https://support.google.com/admanager/answer/9681920?hl=en
        /// </summary>
        [UsedImplicitly]
        public static bool GetConsentForAdditional( ExternalIds vendorID )
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return false;
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<bool>( "GetConsentForAdditional", (int)vendorID );

            #elif UNITY_IOS

            return _GetConsentForExternal( (int)vendorID );

            #else
            
            return false;
            
            #endif
        }
        /// <summary>
        /// know if user accepted to share content with the vendor (google additianal id)
        /// https://support.google.com/admanager/answer/9681920?hl=en
        /// </summary>
        [UsedImplicitly]
        public static bool GetConsentForAdditional( int vendorID )
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return false;
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<bool>( "GetConsentForAdditional", vendorID );

            #elif UNITY_IOS

            return _GetConsentForExternal( vendorID );

            #else
            
            return false;
            
            #endif
        }
        
        /// <summary>
        /// Set a callback to listen for consent status change
        /// </summary>
        /// <param name="Listener"></param>
        [UsedImplicitly]
        public static void SetOnStatusChangedListener( Action<ConsentStatus> Listener )
        {
            OnStatusChanged = Listener;
        }

        private static bool                  IsInitializing;
        private static Action<ConsentStatus> OnInitialisationComplete;
        /// <summary>
        /// Initialize the plugin 
        /// </summary>
        /// <param name="OnComplete">optionnal callback to know when the initialisation is complete and the ConsentStatus after initialisation</param>
        [UsedImplicitly]
        public static void Initialize( Action<ConsentStatus> OnComplete = null )
        {
            Log( "Initialize" );

            IsInitializing           = true;
            OnInitialisationComplete = OnComplete;
            SetInstance();
            
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            InitComplete(ConsentStatus.UNKNOWN);
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            cls.CallStatic( "Initialize" );

            #elif UNITY_IOS

            _Initialize();

            #endif
        }

        private static void InitComplete(ConsentStatus status)
        {
            IsInitializing = false;
            OnInitialisationComplete?.Invoke(status);
            OnInitialisationComplete = null;
            ConsentStatus = status;
        }

        /// <summary>
        /// true if user accepted GDPR consent usage necessary to see ads
        /// </summary>
        [UsedImplicitly]
        public static bool CanShowAds()
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return false;
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<bool>( "GetCanShowAds" );

            #elif UNITY_IOS

            return _GetCanShowAds();

            #else
            
            return false;
            
            #endif
        }
        
        

        /// <summary>
        /// true if user accepted GDPR consent usage necessary to see personnalized ads
        /// </summary>
        [UsedImplicitly]
        public static bool CanShowPersonalizedAds()
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return false;
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<bool>( "GetCanShowPresonalizedAds" );

            #elif UNITY_IOS

            return _GetCanShowPersonalizedAds();

            #else
            
            return false;
            
            #endif
        }

        /// <summary>
        /// returns true if user accepted all vendors ids and external id from the lists + all necessary items to show personalized ads<br/>
        /// if consent form is not required, returns true.
        /// </summary>
        [UsedImplicitly]
        public static bool UserConsentedAll(List<int> vendorIds, List<int> externalIds)
        {
            #if !UNITY_EDITOR && (UNITY_ANDROID || UNITY_IOS)
            
            if( !IsGDPRRequired() )
                return true;

            // form not shown yet
            if( IsFormRequired() )
                return false;

            // check vendors consent
            foreach( var id in vendorIds )
            {
                if( !GetConsentForVendor( id ) )
                    return false;
            }
            
            // check external consent
            foreach( var id in externalIds )
            {
                if( !GetConsentForAdditional( id ) )
                    return false;
            }

            #endif

            // everythings seems good
            return true;
        }
        
        /// <summary>
        /// true if GDPR applies to the current user
        /// </summary>
        [UsedImplicitly]
        public static bool IsGDPRRequired()
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            return false;
            #elif UNITY_ANDROID

            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<bool>( "GetGDPRRequired" );

            #elif UNITY_IOS

            return _GetGDPRRequired();

            #else
            
            return false;
            
            #endif
        }
        
        /// <summary>
        /// returns true if a form is available
        /// </summary>
        [UsedImplicitly]
        public static bool IsFormAvailable()
        {
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            #elif UNITY_ANDROID
            
            using var cls = new AndroidJavaClass( AndroidClass );
            return cls.CallStatic<bool>( "IsFormAvailable" );
            
            #elif UNITY_IOS
            
            return _IsFormAvailable();
            
            #endif

            return false;
        }

        /// <summary>
        /// Show the form if the form is available
        /// Optionally call a callback when the user close the form (or if the form is not oppenned)
        /// </summary>
        [UsedImplicitly]
        public static void ShowForm()
        {
            ShowForm( null );
        }
        /// <summary>
        /// Show the form if the form is available
        /// Optionally call a callback when the user close the form (or if the form is not oppenned)
        /// </summary>
        [UsedImplicitly]
        public static void ShowForm( Action onComplete )
        {
            Log( "ShowForm" );
            
            OnFormClosed = onComplete;
            
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            #elif UNITY_ANDROID
            
            using var cls = new AndroidJavaClass( AndroidClass );
            cls.CallStatic( "LoadForm", true, false );
            
            #elif UNITY_IOS
            
            _LoadForm( true, false );
            
            #endif
        }
        
        /// <summary>
        /// return true if the form must be shown for the user
        /// </summary>
        [UsedImplicitly]
        public static bool IsFormRequired()
        {
            Log( $"IsFormRequired {ConsentStatus}" );
            return ConsentStatus == ConsentStatus.REQUIRED;
        }

        /// <summary>
        /// Show the form if the form is available and the status is ConsentStatus.REQUIRED
        /// Optionally call a callback when the user close the form (or if the form is not oppenned)
        /// </summary>
        [UsedImplicitly]
        public static void ShowFormIfRequired()
        {
            ShowFormIfRequired( null );
        }
        /// <summary>
        /// Show the form if the form is available and the status is ConsentStatus.REQUIRED
        /// call a callback with true as result if the form has been shown, false if form not shown
        /// </summary>
        [UsedImplicitly]
        public static void ShowFormIfRequired( Action<bool> onComplete )
        {
            Log( $"ShowFormIfRequired<bool> {ConsentStatus}" );

            if( ConsentStatus == ConsentStatus.REQUIRED )
                ShowForm( () => onComplete?.Invoke( true ) );
            else
                onComplete?.Invoke(false);
        }

        /// <summary>
        /// here we receive the native plugin messages
        /// </summary>
        /// <param name="statusString"></param>
        [UsedImplicitly]
        public void OnFormDissmissedMessage( string statusString )
        {
            Log( $"OnFormDissmissedMessage {statusString}" );
            
            var statusint = String2Int( statusString );
            var newConsentStatus = Enum.IsDefined( typeof(ConsentStatus), statusint ) ? (ConsentStatus)statusint : ConsentStatus.UNKNOWN;

            if (IsInitializing)
            {
                InitComplete(newConsentStatus);
                return;
            }

            ConsentStatus = newConsentStatus;
            
            OnFormClosed?.Invoke();
            OnFormClosed = null;
        }

        /// <summary>
        /// just keep a reference - not used
        /// </summary>
        private static GoogleUserMessagingPlatform _instance;
        /// <summary>
        /// Create the unity asset to be able to receive messages from native plugin
        /// </summary>
        private static void SetInstance()
        {
            if( _instance != null )
                return;
            
            _instance = (GoogleUserMessagingPlatform)FindObjectOfType( typeof(GoogleUserMessagingPlatform) );
            if( _instance == null ) 
            {
                const string goName = "GoogleUserMessagingPlatform";

                var go = GameObject.Find( goName );
                if( go == null ) 
                {
                    go = new GameObject {name = goName};
                    DontDestroyOnLoad( go );
                }
                
                _instance = go.AddComponent<GoogleUserMessagingPlatform>();
            }
        }
        
        
        
        /// <summary>
        /// get back an int from the string message
        /// </summary>
        private static int String2Int( string str, int defaut = 0 )
        {
            try
            {
                return Convert.ToInt32( Convert.ToDecimal( str, CultureInfo.InvariantCulture ), CultureInfo.InvariantCulture );
            }
            catch( Exception )
            {
                return defaut;
            }
        }
    }
}