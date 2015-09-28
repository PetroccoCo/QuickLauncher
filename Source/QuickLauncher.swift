import UIKit

/// Delegate that will be called when a shortcut is
/// activated from the home screen in a backgrounded state.
public protocol QuickLaunchDelegate :class {
    
    /**
    The provided shortcut was used to launch the app.
    It's up to the delegate to take action on the shortcut.
    
    - parameter shortcut: The UIApplicationShortcutItem used to launch the app.
    */
    func shortcutInvoked(shortcut :NSObject)
}

/// A wrapper class round iOS 9 3D Touch shortcuts.
/// The objective of this class is to minimize the need to check
/// for iOS 9 compatability and allow for a quick and easy way
/// to get and set shortcut actions.
public class QuickLauncher :NSObject {
    static let sharedInsatance = QuickLauncher()
    private var quickLaunchAction :NSObject?
    weak var delegate :QuickLaunchDelegate?
    
    // MARK: Setup
    
    private override init() {
        super.init()
        NSNotificationCenter.defaultCenter()
        .addObserver(
            self,
            selector: "applicationDidBecomeActive",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    internal func applicationDidBecomeActive() {
        if #available(iOS 9.0, *) {
            if let quickLaunchAction = quickLaunchAction as? UIApplicationShortcutItem {
                delegate?.shortcutInvoked(quickLaunchAction)
            }
        }
    }
    
    /**
    Sets the delegate for QuickLauncher and will call it's shortcutInvoked
    method if a shortcut has been activated. It is recommended to use this in
    viewWillAppear or viewDidAppear if using on a UIViewController.
    
    - parameter delegate: The delegate for QuickLauncher
    */
    public func setDelegateAsReady(delegate :QuickLaunchDelegate) {
        self.delegate = delegate
        if let quickLaunchAction = quickLaunchAction {
            delegate.shortcutInvoked(quickLaunchAction)
        }
    }
    
    /**
    Save a shortcut from the launch options of the AppDelegate if it exists.
    If no shortcut exists, calling the getAndClearShortcut() will return nil.
    
    - parameter options: launch options from the AppDelegate
    */
    public func setupShortcutFromLaunchOptions(options :[NSObject : AnyObject]?) {
        if #available(iOS 9.0, *) {
            if let
                options = options,
                action = options[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem
            {
                quickLaunchAction = action
            }
        }
    }
    
    // MARK: Getters
    
    /**
    Get the shortcut that launched the app if it exists. If 
    no shortcut launched the app, this method will return nil.
    This function will clear the shortcut so it cannot be triggered again.
    
    - returns: The UIApplicatinoShortcutItem used to launch the application, or nil.
    */
    @available(iOS 9.0, *)
    public func getAndClearShortcut() -> UIApplicationShortcutItem? {
        let quickLaunch = quickLaunchAction as? UIApplicationShortcutItem
        quickLaunchAction = nil
        return quickLaunch
    }
    
    
    // MARK: Setters
    
    /**
    Set the shortcut that launched the app.
    - parameter shortcut: Shortcut that launched the application.
    */
    public func setShortCut(shortcut :NSObject) {
        if #available(iOS 9.0, *) {
            if let shortcut = shortcut as? UIApplicationShortcutItem {
                quickLaunchAction = shortcut
            }
        }
    }
    
    /**
    Clear the shortcut, if it exists.
    */
    public func clearShortcut() {
        quickLaunchAction = nil
    }
    
    /**
    Add a dynamic shortcut to the application. Currently only 4 shortcuts can
    be displayed at any given time. If more exist, the most recent 4
    will be displayed.
    */
    @available(iOS 9.0, *)
    public func addDynamicShortcut(shortcut :UIApplicationShortcutItem) {
        if UIApplication.sharedApplication().shortcutItems == nil {
            UIApplication.sharedApplication().shortcutItems = [UIApplicationShortcutItem]()
        }
        
        UIApplication.sharedApplication().shortcutItems!.append(shortcut)
    }
    
    /**
    Wrapper around creating a shortcut that doesn't require any iOS 9 checks.
    This will create a UIApplicationShortcutItem and addit to the UIApplication.
    
    - parameter type:     The shortcut type.
    - parameter title:    The title to display when 3D Touching on the home screen.
    - parameter subTitle: The subtitle that will display under the main title on the home screen.
    - parameter iconName: The name of the icon to use. If none is provided, no icon will be added to the shortcut.
    - parameter userData: Any data that should be included with the shortcut.
    */
    public func addDynamicShortcut(type :String, title :String, subTitle :String? = nil, iconName :String? = nil, userData :[NSObject : AnyObject]? = nil) {
        if #available(iOS 9.0, *) {
            
            var icon :UIApplicationShortcutIcon?
            if let iconName = iconName {
                icon = UIApplicationShortcutIcon(templateImageName: iconName)
            }
            
            let shortcut = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: subTitle, icon: icon, userInfo: userData)
            addDynamicShortcut(shortcut)
        }
    }
    
    /**
    This function will clear all dynamic shortcuts that have been added to the application.
    */
    public func resetDynamicShortcuts() {
        if #available(iOS 9.0, *) {
            UIApplication.sharedApplication().shortcutItems = [UIApplicationShortcutItem]()
        }
    }
    
}