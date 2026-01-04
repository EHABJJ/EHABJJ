# UI Preview - Home Page Design

## Visual Layout Overview

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ╔═══════════════════════════════════════════════════╗ │
│  ║  [⚙️]      🏛️  Jhompay Tracker        [🕒]       ║ │
│  ║                                                   ║ │
│  ║   Glass Effect AppBar (Translucent)              ║ │
│  ║   Colors: #4F5D75 → #6B7A94 (70% opacity)       ║ │
│  ╚═══════════════════════════════════════════════════╝ │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │  PHP ▼              │            JOD ▼          │  │
│  │  12,345.00          │          5,678.00         │  │
│  │                  Balance Section                 │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │                                                  │  │
│  │        ╔═══════════════════════════╗            │  │
│  │        ║      Cash In              ║            │  │
│  │        ╚═══════════════════════════╝            │  │
│  │    (Centered Box - Same color as AppBar)       │  │
│  │                                                  │  │
│  │  ┌───────────────┐   ┌───────────────┐        │  │
│  │  │   Option 1    │   │   Option 2    │        │  │
│  │  └───────────────┘   └───────────────┘        │  │
│  │                                                  │  │
│  │  ┌───────────────┐   ┌───────────────┐        │  │
│  │  │   Option 3    │   │   Option 4    │        │  │
│  │  └───────────────┘   └───────────────┘        │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │                                                  │  │
│  │        ╔═══════════════════════════╗            │  │
│  │        ║     Cash Out              ║            │  │
│  │        ╚═══════════════════════════╝            │  │
│  │    (Centered Box - Same color as AppBar)       │  │
│  │                                                  │  │
│  │  ┌───────────────┐   ┌───────────────┐        │  │
│  │  │   Option 1    │   │   Option 2    │        │  │
│  │  └───────────────┘   └───────────────┘        │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │              Send Payment                        │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Design Elements

### 1. AppBar (Header)
- **Background**: Translucent glass effect with blur
- **Colors**: Gradient from `#4F5D75` to `#6B7A94` with 70% opacity
- **Effect**: BackdropFilter blur (sigmaX: 10, sigmaY: 10)
- **Shadow**: Soft shadow with 0.1 opacity, 15px blur
- **Border Radius**: 20px
- **Icons**: 
  - Left: Settings (⚙️)
  - Center: Company icon (🏛️) + Company Name
  - Right: History (🕒)

### 2. Section Titles (Cash In / Cash Out)
- **Position**: Centered horizontally in the card
- **Background**: Same gradient as AppBar
  - Colors: `#4F5D75` → `#6B7A94` (70% opacity)
- **Padding**: 24px horizontal, 10px vertical
- **Border Radius**: 15px
- **Text Style**:
  - Color: White
  - Font Weight: 600 (Semi-bold)
  - Font Size: 16px
  - Letter Spacing: 0.5

### 3. Color Scheme
| Element | Color | Notes |
|---------|-------|-------|
| AppBar Gradient Start | `#4F5D75` | 70% opacity |
| AppBar Gradient End | `#6B7A94` | 70% opacity |
| Title Boxes | Same as AppBar | Matching design |
| Cash In Buttons | `#4CAF50` | Green |
| Cash Out Buttons | `#E53935` | Red |
| Send Payment | `#1976D2` | Blue |
| Background | `#F5F5F5` | Light gray |

## Key Visual Features

✨ **Glass Morphism Effect**
- The AppBar has a translucent, blurred background
- Creates a modern, elegant "frosted glass" appearance
- The 70% opacity allows subtle transparency

🎯 **Centered Title Design**
- "Cash In" and "Cash Out" labels are in rounded boxes
- Positioned in the center of each card
- Uses the exact same styling as the AppBar for visual consistency

🎨 **Cohesive Color Palette**
- All primary UI elements (AppBar and title boxes) share the same gradient
- Creates a unified, professional look
- Modern color choices suitable for a financial application

📐 **Clean Layout**
- Consistent spacing (16-24px) between elements
- Rounded corners throughout (15-25px border radius)
- Balanced two-column layout for transaction options

## Notes for Testing

To see this design in action, you would need to:

1. Create a complete Flutter project with `pubspec.yaml`
2. Add required dependencies:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     cloud_firestore: ^4.0.0
     intl: ^0.18.0
     google_fonts: ^6.0.0
   ```
3. Create placeholder files for the imported pages:
   - `settings_page.dart`
   - `transaction_history_page.dart`
   - `add_transaction_page.dart`
4. Set up Firebase configuration
5. Run the app with `flutter run`

The glass effect is most visible when there's content behind the AppBar, and the translucent nature of the design becomes apparent during scrolling or animations.
