remove # EtherWorld - App Store Metadata

## Short Description (30 words max)
Read and discover articles from EtherWorld. Search, filter by tags, save offline, and get notifications of new posts.

## Full Description (4000 characters)
EtherWorld is a beautifully designed news reader for the EtherWorld publication. Stay informed with a fast, intuitive app that brings you the latest articles right to your device.

**Key Features:**

• **Fast & Responsive** – Articles load instantly with intelligent caching. Read even when offline.

• **Smart Discovery** – Search articles by title, content, tags, or author. Filter by tags to find exactly what interests you.

• **Save for Later** – Bookmark articles and read them anytime, offline or online.

• **Get Notified** – Opt-in notifications alert you when new articles are published.

• **Dark Mode** – Easy on the eyes with full dark mode support.

• **Privacy First** – All your data stays on your device. We don't track you.


**How It Works:**
1. Browse the home feed to see the latest articles
2. Use Discover to search and filter by tags or author
3. Tap an article to read the full story with rich formatting
4. Bookmark articles you want to read later
5. Enable notifications in Settings to stay updated

**Privacy & Security:**
- All article caching happens locally on your device
- Bookmarks and preferences stored only on your device
- No tracking, no analytics by default (optional, opt-in only)
- No personal data sent to third parties
- Full privacy policy available in-app

EtherWorld is the fastest way to read quality journalism. Download now and never miss an article.

## Keywords (max 100 chars total, comma-separated)
news, articles, reader, ethereum, crypto, blockchain, tech

## Support URL
https://etherworld.co/support

## Privacy Policy URL
https://etherworld.co/privacy

## Screenshots Plan

### iPhone Portrait (1242 x 2208 px, required for all devices)

**Screenshot 1: Home Feed**
- Title: "Latest Articles"
- Description: "Browse the latest EtherWorld articles. Pull to refresh and infinite scroll through all posts."
- Key element: List of articles with images, titles, authors

**Screenshot 2: Discover & Search**
- Title: "Search Everything"
- Description: "Search articles by title, content, tags, and author. Filter by tags to discover what interests you."
- Key element: Search bar, tag chips, filtered results

**Screenshot 3: Article Detail**
- Title: "Read with Rich Formatting"
- Description: "Full-featured HTML rendering with images, links, and beautiful typography. Bookmark to read offline."
- Key element: Article with hero image, title, author info, content, bookmark button

**Screenshot 4: Saved Articles**
- Title: "Read Offline Anytime"
- Description: "Save articles and read them offline. Your bookmarks sync across sessions."
- Key element: List of saved articles

**Screenshot 5: Settings & Privacy**
- Title: "Control Your Experience"
- Description: "Toggle notifications, dark mode, and analytics. Review our privacy policy and clear cache."
- Key element: Settings toggles, privacy policy link, dark mode enabled

## App Capabilities Checklist

### Required Entitlements
- [x] Push Notifications (UNUserNotificationCenter)
- [x] Background Modes
  - [x] Background Fetch (BGAppRefreshTask)
  - [x] Remote Notifications

### Frameworks Used
- [x] SwiftUI (main UI framework)
- [x] WebKit (HTML rendering)
- [x] Combine (reactive data binding)
- [x] BackgroundTasks (background refresh)
- [x] UserNotifications (local notifications)
- [x] URLSession (networking with caching)

### Privacy Disclosures
- **Data Collected:**
  - Bookmarked article IDs (local storage only)
  - Notification preferences (local storage)
  - Dark mode preference (local storage)
  - Reading history via cache (local storage)

- **Data NOT Collected:**
  - Location data
  - Health & fitness data
  - Financial data
  - Sensitive information
  - Advertising identifiers
  - Browsing history beyond session

- **Third-Party Services:**
  - Ghost CMS API (for article content only)
  - No trackers, analytics, or ads

### Bundle Settings
- **Bundle ID:** (to be set in Xcode: IOS_App or com.etherworld.newsreader)
- **Minimum OS:** iOS 15.0
- **Supported Devices:** iPhone, iPad
- **Orientations:** Portrait (iPhone), All (iPad)
- **App Icons:** Required (all sizes via Assets)
- **Launch Screen:** Storyboard or SwiftUI
- **Version:** 1.0.0
- **Build:** 1

### Info.plist Keys Required
```xml
<key>NSBonjourServices</key>
<array>
  <string>_http._tcp</string>
  <string>_https._tcp</string>
</array>

<key>UIApplicationSceneManifest</key>
<dict>
  <key>UISceneConfigurations</key>
  <dict>
    <key>UIWindowSceneSessionRoleApplication</key>
    <array>
      <dict>
        <key>UISceneConfigurationName</key>
        <string>Default Configuration</string>
        <key>UISceneDelegateClassName</key>
        <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
      </dict>
    </array>
  </dict>
</dict>

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
  <string>com.etherworld.newsreader.background-fetch</string>
</array>

<key>UNUserNotificationCenterDelegate</key>
<true/>
```

### Testing Checklist Before Submission
- [x] Test on iPhone 14/15 and iPad
- [x] Verify all screens render correctly in light and dark mode
- [x] Test offline mode: kill network and verify cached articles display
- [x] Notifications: enable and verify test alert appears
- [x] Background refresh: trigger manually and verify timing
- [x] Search and tag filtering: verify results are accurate
- [x] Bookmarks: save and verify persistence
- [x] Deep links: tap notification and verify article opens
- [x] Accessibility: VoiceOver navigation and labels
- [x] Dynamic Type: test with largest/smallest font sizes
- [x] Privacy Policy: verify link works and content is accurate
- [x] Crash-free: run through all flows without errors

### Metadata Summary
| Field | Value |
|-------|-------|
| App Name | EtherWorld |
| Bundle ID | com.etherworld.newsreader (set in Xcode) |
| Version | 1.0.0 |
| Min OS | iOS 15.0 |
| Category | News |
| Content Rating | 4+ |
| Keywords | news, articles, reader, ethereum, crypto, blockchain, tech |
| Support | https://etherworld.co/support |
| Privacy | https://etherworld.co/privacy |
