cupertino_native 0.1.1 copy "cupertino_native: ^0.1.1" to clipboard
Published 4 months ago • verified publisherserverpod.dev
SDKFlutterPlatformiOSmacOS
273
Readme
Changelog
Example
Installing
Versions
Scores
Serverpod Liquid Glass Flutter banner

This package is part of Serverpod's open-source initiative. Serverpod is the ultimate backend for Flutter - all written in Dart, free, and open-source. 👉 Check it out

Liquid Glass for Flutter 
Native Liquid Glass widgets for iOS and macOS in Flutter with pixel‑perfect fidelity.

This plugin hosts real UIKit/AppKit controls inside Flutter using Platform Views and method channels. It matches native look/feel perfectly while still fitting naturally into Flutter code.

Does it work and is it fast? Yes. Is it a vibe-coded Frankenstein's monster patched together with duct tape? Also yes.

This package is a proof of concept for bringing Liquid Glass to Flutter. Contributions are most welcome. What we have here can serve as a great starting point for building a complete, polished library. The vision for this package is to bridge the gap until we have a good, new Cupertino library written entirely in Flutter. To move toward completeness, we can also improve parts that are easy to write in Flutter to match the new Liquid Glass style (e.g., improved CupertinoScaffold, theme, etc.).

Read the release blogpost: 👉 Is it time for Flutter to leave the uncanny valley?

Installation 
Add the dependency in your app’s pubspec.yaml:

flutter pub add cupertino_native
Then run flutter pub get.

Ensure your platform minimums are compatible:

iOS platform :ios, '14.0'
macOS 11.0+
You will also need to install the Xcode 26 beta and use xcode-select to set it as your default.

sudo xcode-select -s /Applications/Xcode-beta.app
What's in the package 
This package ships a handful of native Liquid Glass widgets. Each widget exposes a simple, Flutter‑friendly API and falls back to a reasonable Flutter implementation on non‑Apple platforms.

Slider 
Liquid Glass Slider

double _value = 50;

CNSlider(
  value: _value,
  min: 0,
  max: 100,
  onChanged: (v) => setState(() => _value = v),
)
Switch 
Liquid Glass Switch

bool _on = true;

CNSwitch(
  value: _on,
  onChanged: (v) => setState(() => _on = v),
)
Segmented Control 
Liquid Glass Segmented Control

int _index = 0;

CNSegmentedControl(
  labels: const ['One', 'Two', 'Three'],
  selectedIndex: _index,
  onValueChanged: (i) => setState(() => _index = i),
)
Button 
Liquid Glass Button

CNButton(
  label: 'Press me',
  onPressed: () {},
)

// Icon button variant
CNButton.icon(
  icon: const CNSymbol('heart.fill'),
  onPressed: () {},
)
Icon (SF Symbols) 
Liquid Glass Icon

// Monochrome symbol
const CNIcon(symbol: CNSymbol('star'));

// Multicolor / hierarchical options are also supported
const CNIcon(
  symbol: CNSymbol('paintpalette.fill'),
  mode: CNSymbolRenderingMode.multicolor,
)
Popup Menu Button 
Liquid Glass Popup Menu Button

final items = [
  const CNPopupMenuItem(label: 'New File', icon: CNSymbol('doc', size: 18)),
  const CNPopupMenuItem(label: 'New Folder', icon: CNSymbol('folder', size: 18)),
  const CNPopupMenuDivider(),
  const CNPopupMenuItem(label: 'Rename', icon: CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18)),
];

CNPopupMenuButton(
  buttonLabel: 'Actions',
  items: items,
  onSelected: (index) {
    // Handle selection
  },
)
Tab Bar 
Liquid Glass Tab Bar

int _tabIndex = 0;

// Overlay this at the bottom of your page
CNTabBar(
  items: const [
    CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
    CNTabBarItem(label: 'Profile', icon: CNSymbol('person.crop.circle')),
    CNTabBarItem(label: 'Settings', icon: CNSymbol('gearshape.fill')),
  ],
  currentIndex: _tabIndex,
  onTap: (i) => setState(() => _tabIndex = i),
)
What's left to do? 
So far, this is more of a proof of concept than a full package (although the included components do work). Future improvements include:

Cleaning up the code. Probably by someone who knows a bit about Swift.
Adding more native components.
Reviewing the Flutter APIs to ensure consistency and eliminate redundancies.
Extending the flexibility and styling options of the widgets.
Investigate how to best combine scroll views with the native components.
macOS compiles and runs, but it's untested with Liquid Glass and generally doesn't look great.
How was this done? 
Pretty much vibe-coded with Codex and GPT-5. 😅