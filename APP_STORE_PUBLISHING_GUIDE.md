# App Store Publishing Guide for QuickQuote

## Prerequisites

Before you begin, ensure you have:
1. ✅ An active Apple Developer account ($99/year)
2. ✅ Xcode installed (latest version recommended)
3. ✅ Your app built successfully (already completed ✓)
4. ✅ App Store Connect account access

---

## Step-by-Step Publishing Process

### Step 1: Configure App in App Store Connect

1. **Log in to App Store Connect**
   - Go to [https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Sign in with your Apple Developer account

2. **Create a New App**
   - Click "My Apps" → "+" button → "New App"
   - Fill in the required information:
     - **Platform**: iOS
     - **Name**: QuickQuote (or your preferred name)
     - **Primary Language**: English (or your preferred language)
     - **Bundle ID**: Select your bundle identifier (e.g., `com.quickquotetn.app`)
     - **SKU**: A unique identifier (e.g., `quickquote-001`)
     - **User Access**: Full Access (or as needed)

3. **Complete App Information**
   - **App Information**:
     - Category: Select appropriate categories (e.g., Lifestyle, Productivity)
     - Privacy Policy URL: Required (if your app collects user data)
   - **Pricing and Availability**: Set your price (Free or Paid)
   - **App Privacy**: Complete privacy questionnaire

---

### Step 2: Configure Xcode Project Settings

1. **Open the Project in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **Important**: Open `.xcworkspace`, NOT `.xcodeproj`

2. **Select the Runner Target**
   - In the Project Navigator, click on "Runner" project (blue icon)
   - Select the "Runner" target (under TARGETS)
   - Go to the "Signing & Capabilities" tab

3. **Configure Signing**
   - **Team**: Select your Apple Developer Team
   - **Bundle Identifier**: Ensure it matches your App Store Connect app
     - Current: Check `ios/Runner.xcodeproj/project.pbxproj` or Xcode
     - Should match: `com.quickquotetn.app` (or your chosen identifier)
   - **Automatically manage signing**: ✅ Check this box
   - Xcode will automatically create/select provisioning profiles

4. **Set Build Configuration**
   - Go to "Product" → "Scheme" → "Edit Scheme"
   - Select "Run" → "Build Configuration" → **Release**
   - Select "Archive" → "Build Configuration" → **Release**

5. **Verify Version and Build Number**
   - In the "General" tab, check:
     - **Version**: Should match `pubspec.yaml` (currently `1.0.0`)
     - **Build**: Should match `pubspec.yaml` (currently `1`)
   - These are set in `pubspec.yaml`:
     ```yaml
     version: 1.0.0+1
     ```
     Format: `version+buildNumber`

---

### Step 3: Archive the App

1. **Select Generic iOS Device**
   - In Xcode's toolbar, select "Any iOS Device" or "Generic iOS Device"
   - ⚠️ Do NOT select a simulator

2. **Create Archive**
   - Go to **Product** → **Archive**
   - Wait for the build to complete (may take several minutes)
   - The Organizer window will open automatically when done

3. **Verify Archive**
   - In the Organizer, you should see your archive
   - Check the date, version, and build number

---

### Step 4: Validate and Upload to App Store Connect

1. **Distribute App**
   - In the Organizer, select your archive
   - Click **"Distribute App"**

2. **Choose Distribution Method**
   - Select **"App Store Connect"**
   - Click **"Next"**

3. **Select Distribution Options**
   - Choose **"Upload"** (recommended for first submission)
   - Click **"Next"**

4. **Select Distribution Options (Advanced)**
   - ✅ **"Upload your app's symbols"** (recommended for crash reports)
   - ✅ **"Manage Version and Build Number"** (if needed)
   - Click **"Next"**

5. **Automatically Manage Signing**
   - Select **"Automatically manage signing"**
   - Xcode will handle certificates and provisioning profiles
   - Click **"Next"**

6. **Review and Upload**
   - Review the summary
   - Click **"Upload"**
   - Wait for the upload to complete (may take 10-30 minutes)

7. **Validation**
   - Xcode will validate your app before uploading
   - If there are errors, fix them and try again
   - Common issues:
     - Missing icons or launch screens
     - Invalid bundle identifier
     - Missing required app icons

---

### Step 5: Complete App Store Listing

1. **Go to App Store Connect**
   - Navigate to your app in App Store Connect
   - Go to the **"App Store"** tab

2. **Prepare for Submission**
   - Click **"+ Version or Platform"** → **"iOS"**
   - Enter the version number (e.g., `1.0.0`)

3. **Required Information**

   **App Information:**
   - **Screenshots**: Required for all device sizes
     - iPhone 6.7" (iPhone 14 Pro Max, etc.)
     - iPhone 6.5" (iPhone 11 Pro Max, etc.)
     - iPhone 5.5" (iPhone 8 Plus, etc.)
     - iPad Pro (12.9") - if supporting iPad
   - **App Preview** (optional but recommended)
   - **Description**: App description (up to 4,000 characters)
   - **Keywords**: Search keywords (up to 100 characters)
   - **Support URL**: Your website or support page
   - **Marketing URL** (optional)
   - **Promotional Text** (optional, up to 170 characters)

   **App Review Information:**
   - **Contact Information**: Your contact details
   - **Demo Account** (if your app requires login)
   - **Notes**: Any additional information for reviewers

   **Version Information:**
   - **What's New in This Version**: Release notes
   - **Copyright**: Your copyright information
   - **Trade Representative Contact Information** (if applicable)

4. **App Privacy**
   - Complete the privacy questionnaire
   - Answer questions about data collection
   - Add Privacy Policy URL if required

5. **Build Selection**
   - After upload completes (may take 15-30 minutes), select your build
   - Go to **"Build"** section
   - Click **"+ Build"** and select the uploaded build

6. **Age Rating**
   - Complete the age rating questionnaire
   - App will be rated automatically based on your answers

7. **Pricing and Availability**
   - Set price (if not already set)
   - Select countries/regions for availability

---

### Step 6: Submit for Review

1. **Review All Information**
   - Double-check all screenshots, descriptions, and metadata
   - Ensure all required fields are completed
   - Verify build is selected

2. **Export Compliance**
   - Answer export compliance questions
   - Usually: "No" for encryption questions (unless using custom encryption)

3. **Advertising Identifier**
   - Answer if your app uses the Advertising Identifier (IDFA)
   - Check your app's dependencies

4. **Content Rights**
   - Confirm you have rights to all content

5. **Submit for Review**
   - Click **"Submit for Review"** button
   - Confirm submission

---

### Step 7: Monitor Review Status

1. **Check Status in App Store Connect**
   - Status will show: "Waiting for Review" → "In Review" → "Pending Developer Release" or "Ready for Sale"

2. **Review Times**
   - Typically 24-48 hours for review
   - Can take up to 7 days during busy periods

3. **If Rejected**
   - Review rejection reasons
   - Fix issues and resubmit
   - You can reply to reviewers with clarifications

4. **If Approved**
   - App will be automatically released (if set to auto-release)
   - Or manually release from App Store Connect

---

## Important Notes

### Bundle Identifier
- Current bundle identifier needs to be verified
- Check in Xcode: Runner target → General → Bundle Identifier
- Must match App Store Connect app

### App Icons
- Ensure all required icon sizes are present
- Check `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Required sizes:
  - 1024x1024 (App Store)
  - 180x180 (iPhone)
  - 120x120 (iPhone)
  - 152x152 (iPad)
  - 76x76 (iPad)

### Launch Screen
- Verify launch screen is configured
- Check `ios/Runner/Assets.xcassets/LaunchImage.imageset/`

### Version Management
- Update version in `pubspec.yaml` for each release
- Format: `version: X.Y.Z+buildNumber`
- Example: `version: 1.0.1+2` (version 1.0.1, build 2)

### Testing Before Submission
- Test on physical devices
- Test all features thoroughly
- Check for crashes and performance issues

---

## Troubleshooting

### Common Issues

1. **"No accounts with App Store Connect access"**
   - Ensure you're signed in with correct Apple ID in Xcode
   - Xcode → Preferences → Accounts → Add your Apple ID

2. **"Bundle identifier is not available"**
   - Bundle ID must be unique
   - Change in Xcode or App Store Connect

3. **"Missing compliance"**
   - Answer export compliance questions
   - Usually select "No" for encryption (unless using custom encryption)

4. **"Invalid bundle"**
   - Ensure all required icons are present
   - Check Info.plist configuration

5. **Upload fails**
   - Check internet connection
   - Verify signing certificates are valid
   - Try cleaning build folder: Product → Clean Build Folder

---

## Quick Checklist

Before submitting:
- [ ] App builds successfully in Release mode
- [ ] All app icons are present and correct sizes
- [ ] Launch screen is configured
- [ ] Bundle identifier matches App Store Connect
- [ ] Version and build numbers are correct
- [ ] App tested on physical devices
- [ ] Screenshots prepared for all required sizes
- [ ] App description and metadata completed
- [ ] Privacy policy URL added (if required)
- [ ] Age rating completed
- [ ] Export compliance answered

---

## Additional Resources

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)

---

Good luck with your App Store submission! 🚀

