#define IMPLEMENTING

using System;
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
        AdColony = 458,
        Liftoff  = 667,
        Google   = 755
    }
    
    public class GoogleUserMessagingPlatform : MonoBehaviour
    {
        private const string AndroidClass = "com.binouze.GoogleUserMessagingPlatform";

        [UsedImplicitly]
        public static  ConsentStatus ConsentStatus { get; private set; } = ConsentStatus.UNKNOWN;

        private static Action<ConsentStatus> OnStatusChanged;
        private static Action                OnFormClosed;
        private static bool                  LogEnabled;
        
        #if UNITY_IOS
        [DllImport( "__Internal")]
        private static extern void _EnableDebugLogging(bool enabled);
        
        [DllImport( "__Internal")]
        private static extern void _SetDebugMode(string debugDevice, bool forceReset);
        
        [DllImport( "__Internal")]
        private static extern void _SetTargetChildren(bool targetChildren);
        
        [DllImport( "__Internal")]
        private static extern void _Initialize();
        
        [DllImport( "__Internal")]
        private static extern void _LoadForm(bool forceShow, bool forceDispatch);
        
        [DllImport( "__Internal")]
        private static extern bool _IsFormAvailable();
        
        [DllImport( "__Internal")]
        private static extern bool _GetCanShowAds();
        
        [DllImport( "__Internal")]
        private static extern bool _GetGDPRRequired();
        
        [DllImport( "__Internal")]
        private static extern bool _GetConsentForVendor(int vendorID);
        
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
        /// Set a callback to listen for consent status change
        /// </summary>
        /// <param name="Listener"></param>
        [UsedImplicitly]
        public static void SetOnStatusChangedListener( Action<ConsentStatus> Listener )
        {
            OnStatusChanged = Listener;
        }

        /// <summary>
        /// Initialize the plugin
        /// </summary>
        [UsedImplicitly]
        public static void Initialize()
        {
            SetInstance();
            
            #if UNITY_EDITOR && !IMPLEMENTING
            // nothing to do on editor
            #elif UNITY_ANDROID
            
            using var cls = new AndroidJavaClass( AndroidClass );
            cls.CallStatic( "Initialize" );
            
            #elif UNITY_IOS
            
            _Initialize();
            
            #endif
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

            #endif

            return false;
        }
        
        /// <summary>
        /// true if user accepted GDPR consent usage necessary to see ads
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

            #endif

            return false;
        }
        
        /// <summary>
        /// returns true if a form is available
        /// </summary>
        /// <returns></returns>
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
        /// <param name="onComplete"></param>
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
        /// <param name="onComplete"></param>
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
        /// he we receive native plugin messages
        /// </summary>
        /// <param name="statusString"></param>
        [UsedImplicitly]
        public void OnFormDissmissedMessage( string statusString )
        {
            Log( $"OnFormDissmissedMessage {statusString}" );
            
            var statusint = String2Int( statusString );
            ConsentStatus = Enum.IsDefined( typeof(ConsentStatus), statusint ) ? (ConsentStatus)statusint : ConsentStatus.UNKNOWN;

            OnStatusChanged?.Invoke( ConsentStatus );
            
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