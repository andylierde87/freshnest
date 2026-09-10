# PantryPulse — App Store Connect metadata

> Note: the marketing domain is still `frshnest.xyz` (not renamed — a domain
> change would need a new domain purchase/DNS setup). The site content itself
> now says "PantryPulse" throughout; only the URL keeps the old name.

## Name (30 chars max)
PantryPulse
(if this exact word is already taken, use "PantryPulse: Food Tracker" — 25 chars)

## Subtitle (30 chars max)
Track produce freshness

## Promotional Text (170 chars max, editable anytime without review)
Know what to eat first. PantryPulse tracks your fruits and vegetables, estimates freshness on-device, and never sends a photo or byte of data anywhere.

## Description
PantryPulse is an offline-first assistant for the fruits and vegetables in your kitchen. No account, no cloud, no subscriptions — everything runs on your device.

WHAT IT DOES
• Kitchen — every batch you own, filterable by fridge, counter, freezer, or what needs eating first
• Scan — point the camera at an item; an on-device model suggests what it is, then a local visual-condition estimate follows
• Storage Advisor — pick a few items and see ethylene compatibility warnings, like keeping bananas away from avocados
• Rescue — simple recipe suggestions built around whatever is closest to being wasted
• Insights — use rate, most-wasted items, and discard reasons, so patterns become visible over time
• Shopping List — add what you're running low on, and turn purchases straight into new kitchen batches

HOW FRESHNESS SCORING WORKS
Every item gets a 0–100 score, recalculated from purchase date, storage location, ripeness, and any photo scan:
90–100 Very Fresh · 75–89 Fresh · 55–74 Use Soon · 30–54 Eat Today · 0–29 Check Carefully

PantryPulse is a visual-condition estimator, not a food-safety diagnostic tool. It will say "check carefully," never "safe to eat" — always check smell, texture, and the inside of the food yourself.

PRIVATE BY DESIGN
• No account or sign-in required
• No backend, no analytics, no advertising
• Works fully in Airplane Mode — the food database, freshness model, and recipes all ship inside the app
• Scan photos are analyzed on-device and never uploaded; you can turn off photo storage entirely in Settings
• Delete everything at any time from Settings

Built for iPhone and iPad, with an adaptive layout, full Dynamic Type and VoiceOver support, and Light/Dark Mode.

## Keywords (100 chars max, comma-separated, no spaces after commas)
produce,fridge,freshness,fruit,vegetable,food waste,pantry,kitchen,grocery,expiration,storage

## What's New in This Version (for first release)
Welcome to PantryPulse — track produce freshness, scan items for a visual condition estimate, and get storage and rescue-recipe suggestions, all fully offline.

## Category
Primary: Food & Drink
Secondary: Lifestyle (optional)

## Age Rating Questionnaire
Answer "None" / "No" to every content question (violence, gambling, mature content, etc.) — PantryPulse has no user-generated content, no web access, and no objectionable material. Expected result: Age 4+.

## Copyright
© 2026 PantryPulse
(replace with your legal name/entity if you'd like something else)

## Pricing
Free. Available in all App Store territories except: United States (US), China mainland (CN), Hong Kong (HK), Singapore (SG). Developer account is Belgium-based.

## App Review Information
- Contact email: andylierde87@icloud.com
- Sign-in required: No
- Demo account: Not applicable — PantryPulse has no accounts, sign-in, or server backend of any kind.

### Notes for the reviewer (paste into the "Notes" field — ~3,750 characters)

OVERVIEW
PantryPulse tracks how fresh the fruits/vegetables in a kitchen are. No account, no backend, no network requests — everything below works in Airplane Mode. A local database of ~60 produce items (shelf life, ripening, storage tips) ships inside the app.

GETTING TEST DATA IN
Home/Kitchen start empty (no demo account exists to log into). To populate them: Home tab > "Add Food" (or + on Kitchen) > search an item (e.g. "Banana") > set quantity/storage/ripeness > confirm. Repeat 2-3 times — Home, Kitchen, Rescue, and Insights then populate with real content.

HOW TO TEST EACH TAB
- Home: "Needs attention" summary + "Eat First" list, ranked by a 0-100 freshness score recalculated from purchase date, storage, and ripeness (no network involved).
- Kitchen: Full inventory with filters (Fruits/Vegetables/Fridge/Counter/Freezer/Eat First) and sorting. Tap a card for Food Details.
- Food Details: Freshness score, storage tips, ethylene notes. Actions: "Ate One" (decrements quantity), "Discard" (asks a reason), "Move Storage", "Check Freshness" (opens Scan for this item).
- Scan: "Take Photo" or "Choose from Library" on any produce. Runs Apple's on-device Vision framework to suggest what it is, then a local, deterministic image heuristic estimates visible condition (browning, dark spots, etc). Nothing is ever uploaded. If Camera is restricted in your test environment, use "Choose from Library" with any fruit/vegetable photo — same flow either way.
- Rescue: Once an item's score drops below ~55, this tab suggests simple recipes from what's already in the kitchen (recipes are bundled locally).
- Insights: Use rate, most-used/most-wasted item, discard reasons — computed from "Ate One"/"Discard" actions. Empty until at least one such action is taken.
- Storage Advisor: Home > "Check Storage". Select 2+ items to see ethylene-compatibility warnings.
- Shopping List: From Settings or the Kitchen toolbar. Add an item, mark purchased, optionally convert straight into a new Kitchen batch.
- Settings: "Store Scan Photos" toggle (keep or discard scan images after analysis), local Freshness Reminders/Daily Summary (permission requested only when enabled, never at launch), and "Delete All Data" (immediate local wipe, with confirmation).

PERMISSIONS
- Camera/Photo Library: only for Scan, described above. Declining does not block any other feature.
- Notifications: only requested if reminders are turned on in Settings; the app is fully usable with them off.

DISCLAIMER BY DESIGN
PantryPulse never claims to diagnose food safety. It only ever says things like "Looks fresh," "Use soon," or "Check carefully" — never "safe/unsafe to eat." This is stated on the Scan result screen and in the Privacy Policy.

## URLs
- Marketing URL: https://frshnest.xyz
- Support URL: https://frshnest.xyz/support
- Privacy Policy URL: https://frshnest.xyz/privacy

## Export Compliance
Uses encryption: No (standard HTTPS/OS-provided encryption only, no proprietary cryptography) — answer "No" to "Does your app use encryption?" unless you've added something beyond what's listed here.
