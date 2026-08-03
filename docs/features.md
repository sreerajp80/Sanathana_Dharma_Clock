# Sanathana Dharma Clock - Features & Capabilities

## App Description

**Sanathana Dharma Clock** is a fully offline, zero-network Flutter application for Android that calculates and displays time according to traditional Sanātana Dharma (Vedic) astronomy (**Ghaṭikā : Vināḍī : Prāṇa**), anchored to local sunrise and displayed side-by-side with standard civil time. Operating under the classical *ahorātra* model, each day begins at local sunrise and ends at the subsequent local sunrise. The day is divided into 60 elastic Ghaṭikā units that dynamically scale with the actual seasonal daylight and night duration of the user's precise geographical location.

Built entirely on on-device mathematical engines (NOAA solar position algorithms and Jean Meeus lunar position calculations), the application provides a complete Vedic timekeeping and astronomical suite. Its capabilities include an interactive 3-hand custom analog clock dial (`DharmaDialPainter`) with active Muhūrta outer ring, 60 Ghaṭikā inner ticks, daytime arc overlays, color-coded arc legend, and hand style/thickness legend; a real-time digital readout with elapsed sunrise time and screen-reader accessibility support (`Semantics`); a comprehensive Panchang with dual regional calendar views (Kerala Kollavarsham & North Indian Vikram Samvat), moonrise/moonset timings, and 5 Panchang limbs (Vāra, Tithi with ending times, Nakshatra with ending times, Yoga with ending times, Karaṇa with ending times); 30 daily named Muhūrtas and daytime Kālas (Abhijit Muhūrta, Rāhu Kālam, Yamagaṇḍa, Gulika Kālam) with live focus auto-scrolling (`Scrollable.ensureVisible`); 24 planetary Horās (12 day, 12 night) with active Horā card and live countdown timers; a year-round solar Almanac calculating major solar milestones (equinoxes, solstices, Ayana transitions) and monthly daylight tables; flexible offline location management (Live GPS & custom saved locations with safe fallback handling); a dedicated Permissions & Privacy dashboard with direct system App Settings launcher; full bilingual support (English & Malayalam); detailed educational guides; dynamic configuration loading (`app_config.json`); build flavor support (Dev & Prod); a state-preserving 5-tab navigation shell (`StatefulShellRoute` via `go_router`); crash-resilient error handling; a complete automated test suite of 184 unit and widget tests; and a Vedic Material 3 theme featuring Vermillion (*Sindūr*) accents on Sandalwood (*Chandan*) surfaces.

---

## Features & Capabilities

### 1. Vedic Timekeeping Engine
- **Sunrise-Anchored Day (*Ahorātra*)**: Day boundary begins at local sunrise rather than midnight, strictly adhering to classical Vedic astronomy.
- **Elastic Proportional Time Units**:
  - **1 Day (*Ahorātra*)** = 30 Muhūrta = 60 Ghaṭikā = 3,600 Vināḍī = 21,600 Prāṇa
  - **1 Muhūrta** = 2 Ghaṭikā (~48 civil minutes)
  - **1 Ghaṭikā** = 60 Vināḍī (~24 civil minutes)
  - **1 Vināḍī** = 6 Prāṇa (~24 civil seconds)
  - **1 Prāṇa** = ~4 civil seconds
- **Reversible Time Mapping**: Exact, bidirectional mathematical conversion between civil time (`DateTime`) and Ghaṭikā:Vināḍī:Prāṇa readings.
- **Real-Time Dynamic Engine**: Ticking clock updates readings once per second with smooth precision using Riverpod state management (`flutter_riverpod`).

---

### 2. Dual Analog Dial & Digital Clock Screen (`ClockScreen`)
- **Custom 3-Hand Analog Dial (`DharmaDialPainter`)**:
  - Outer ring displaying 30 Muhūrta marks with active Muhūrta highlighted, named (e.g., *Brahma Muhūrta*), and numbered (e.g., 1/30).
  - Main inner dial featuring 60 Ghaṭikā tick marks.
  - Three distinct hands matching classical styles: Ghaṭikā hand (thick dark vermillion), Vināḍī hand (medium vermillion), and Prāṇa hand (thin vermillion).
  - Arc overlays on the dial face illustrating active daytime windows (Abhijit Muhūrta, Rāhu Kālam, Yamagaṇḍa, Gulika Kālam).
  - Color-coded Arc Legend (`_ArcLegend`) and Hand Style/Thickness Legend (`_Legend`) rendered below the dial.
- **Digital Readout**:
  - Large digital display showing current `Ghaṭikā : Vināḍī : Prāṇa`.
  - Active Muhūrta number and name.
  - Synchronized civil time (`HH:mm:ss`) alongside today's local sunrise (`HH:mm`).
  - "Since sunrise" elapsed time readout (`Xh Ym Zs`).
- **Location Anchor Header**: Displays location source (Live GPS with latitude/longitude coordinates, Saved Location with place label, or explainable fallback status such as fetching, GPS disabled, permission denied, or midnight fallback).
- **Location Permission Banner**: Inline banner (`LocationPermissionBanner`) alerting users when location access is needed.
- **Screen Reader Accessibility**: Built-in localized `Semantics` label describing the full clock reading for assistive screen readers.

---

### 3. Comprehensive Panchang (`PanchangScreen`)
- **Dual Tabbed Regional Calendar Styles**:
  - **Kerala Style (Kollavarsham)**: Displays Kollavarsham year, Kollavarsham Solar Month (*Solar Masa*), Njaattuvela (solar nakshatra position), Malayalam weekday names, and regional nomenclature.
  - **North Indian Style (Vikram Samvat)**: Displays Vikram Samvat year, Amānta Lunar Month, traditional Paksha terms, and Sanskrit/Devanagari names in English and Malayalam.
- **The Five Limbs of Panchang (*Pancha-Anga*)**:
  - **Vāra (Weekday)**: Vedic weekday starting at sunrise with traditional description.
  - **Tithi (Lunar Day)**: Current lunar day, Paksha (Shukla/Krishna), meaning, and exact ending timestamp in civil time.
  - **Nakshatra (Lunar Mansion)**: Active star mansion out of 27 mansions with ending timestamp.
  - **Yoga**: Active yoga out of 27 combined sun-moon periods with ending timestamp.
  - **Karaṇa (Half Tithi)**: Active half-tithi with ending timestamp.
- **Moon Phase & Timing Card**: Calculates and displays local Moonrise and Moonset times with date indicators for cross-midnight events.
- **Astronomical Cycles**:
  - **Ṛtu (Season)**: Identifies 6 traditional Ṛtus (Vasanta, Grīṣma, Varṣā, Śarat, Hemanta, Śiśira).
  - **Ayana (Solstitial Movement)**: Tracks Uttarāyaṇa (northward course) and Dakṣiṇāyana (southward course).

---

### 4. Daily Muhūrtas & Kālas (`MuhurtaScreen`)
- **30 Named Daily Muhūrtas**: Complete listing of all 30 daily Muhūrtas (15 daytime, 15 nighttime) with 1-based index, name, exact start/end civil times, and special Brahma Muhūrta / auspicious indicators.
- **Special Daytime Windows (Kālas)**:
  - **Abhijit Muhūrta**: Midday auspicious window calculation.
  - **Inauspicious Kālas**: Precise calculation of Rāhu Kālam, Yamagaṇḍa, and Gulika Kālam derived from dividing daytime into 8 equal parts.
- **Live Focus & Auto-Scroll**: Highlights the active window in real time with a "Now" chip and automatically scrolls (`Scrollable.ensureVisible`) to the active Muhūrta/Kāla on screen open.
- **Polar / Edge Case Handling**: Friendly empty state notification when daytime windows cannot be computed (e.g., polar days).

---

### 5. Planetary Horā Tab (`HoraScreen`)
- **24 Planetary Hours**: Divides the day into 12 Daytime Horās (sunrise to sunset) and 12 Nighttime Horās (sunset to next sunrise).
- **Planetary Rulers (Horā Lords)**: Classical planetary sequence assigned starting from the weekday lord at sunrise (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn) followed by the repeating 7-planet cycle.
- **Active Horā Card**: Prominently highlights the active horā lord, day/night category, start–end civil times, and live countdown timer (`Xh Ym remaining`).
- **Split List & Auto-Scroll**: Separate lists for Day and Night Horās with minute-precision active row highlighting and auto-scrolling on screen open.

---

### 6. Year-Round Solar Almanac (`AlmanacScreen`)
- **On-Device Annual Calculation**: Generates full annual solar data completely offline for any selected calendar year using bisection scanning algorithms (`AlmanacCalculator`).
- **Key Solar Milestones**: Computes exact local date and time for 6 major solar events:
  - March Equinox
  - June Solstice
  - September Equinox
  - December Solstice
  - Start of Uttarāyaṇa
  - Start of Dakṣiṇāyana
- **Monthly Solar Breakdown**: Expandable month-by-month tables listing daily sunrise time, sunset time, and total daylight length for every day of the year (with current day highlight and auto-expanded current month).
- **Multi-Year Selector**: Navigation controls to switch seamlessly between previous, current, and future years.

---

### 7. Offline Location & GPS Management (`LocationSettingsScreen`, `PermissionsScreen`)
- **On-Device Astronomical Engines**: NOAA solar position algorithms, Jean Meeus lunar position calculations, and custom sunrise/sunset/moonrise calculators computed locally without network requests.
- **Dual Location Modes**:
  - **Saved Location**: Persisted latitude, longitude, and custom place label via `shared_preferences`.
  - **Live GPS Mode**: Fetches real-time position using device GPS via native `geolocator_android` plugin without umbrella dependencies or web calls.
- **Location & Permission Controls**:
  - One-tap "Save Current Location" with custom naming dialog.
  - Edit saved place labels or clear stored location.
  - Dedicated **Permissions Dashboard (`PermissionsScreen`)** listing location access status, system permission check, direct launcher button to system App Settings (`openAppSettings`), and explicit "Internet Disabled / No Network Access" confirmation.
- **Safe Fallbacks & Edge Cases**:
  - No location / permission denied -> Falls back to Saved Location; if none, falls back to a midnight-anchored day (06:00 virtual sunrise).
  - Polar regions (continuous daylight or polar night) -> Fallback using a fixed 86,400-second day span.
  - Pre-sunrise time -> Smoothly anchors to previous day's sunrise.

---

### 8. Internationalization & Dual-Language Support
- **Full Bilingual Interface**: Complete localized strings for **English** and **Malayalam (മലയാളം)** across all titles, readouts, Panchang limbs, Muhūrtas, Horās, Help articles, settings, dialogs, and semantic accessibility labels.
- **Language Mode Options**: Switch seamlessly between System Default, English, and Malayalam (`AppLanguageMode`).

---

### 9. Educational Help Center (`HelpScreen`, `HelpTopicScreen`)
- **Interactive Unit Explanations**: Detailed educational articles covering all 5 time units: Ghaṭikā, Vināḍī, Prāṇa, Muhūrta, and Horā.
- **Educational Context**: Explains classical timekeeping concepts, civil time equivalents, parent ratios, approximate unit lengths, and planetary horā assignment rules.

---

### 10. Data-Driven About & Settings (`SettingsScreen`, `AboutScreen`)
- **Card-Based Settings Navigation**: Intuitive section cards (`NavCard`) for Language, Location, Permissions, Help, and About.
- **Data-Driven About Screen**: Loads metadata dynamically from `assets/config/app_config.json` via `ConfigService` (App name, version, build number, author, license, AI used, IDE used, and localized fields).
- **Build Flavor Support**: Environment-aware configuration via `AppFlavorConfig` supporting `dev` and `prod` flavors with flavor-specific app titles ("Sanathana Dharma Clock Dev" vs "Sanathana Dharma Clock") and verbose logging control.

---

### 11. Security, Privacy & Design Aesthetics
- **100% Offline & Private**: Zero internet permissions declared (`android.permission.INTERNET` absent). Location data remains strictly on device and is never logged, stored off-device, or transmitted. Cloud backup disabled (`android:allowBackup="false"`).
- **Vedic Material 3 Theme (`AppTheme`)**: Custom palette featuring Vermillion (*Sindūr*) primary accents on Sandalwood (*Chandan*) background surfaces, styled with rounded card layouts and Material 3 design standards.

---

### 12. Architectural Infrastructure & Automated Test Suite
- **State-Preserving 5-Tab Navigation**: `StatefulShellRoute` using `go_router` maintains individual tab stack state and scroll position across Clock, Muhurta, Hora, Panchang, and Almanac screens.
- **Modular Riverpod Providers**: Decoupled service, repository, state, and UI logic via `flutter_riverpod` providers for predictable reactivity and easy testing.
- **Direct Native Android Integration**: Uses `geolocator_android` directly to eliminate transitive network dependencies.
- **Crash-Resilient Error Handling**: Global error handlers catch platform and framework exceptions without crashing the app.
- **Comprehensive Automated Test Suite**: 184 passing automated unit and widget tests covering model conversions, repositories, astronomical calculators (solar, lunar, panchang, muhurta, hora, almanac, moonrise/set), Riverpod state providers, widgets, and full UI screens.
