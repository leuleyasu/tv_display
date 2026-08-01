# HoursSignage DOOH Advertising Network & 3-Shift Business Model

## 1. Executive Summary

**HoursSignage** is a centralized Digital Out-Of-Home (DOOH) advertising and TV display network designed for restaurants, cafes, bars, and lounges across Ethiopia. 

Rather than requiring individual venues to market and manage their own screens, **HoursSignage operates a centralized ad network**. We install our software (`night_track_tv`) for **FREE** on venue televisions, aggregate screen inventory city-wide, and sell high-impact time-slot campaigns to national and regional advertisers.

---

## 2. Core Value Proposition

```
+-----------------------------------------------------------------------------------+
|                            HOURS SIGNAGE NETWORK HUB                              |
|          Centralized Ad Sales, Time-Slot Dayparting & Automated Firebase Sync     |
+-----------------------------------------+-----------------------------------------+
                                          |
                +-------------------------+-------------------------+
                |                                                   |
                v                                                   v
+---------------------------------------+   +---------------------------------------+
|            FOR VENUE OWNERS           |   |            FOR ADVERTISERS            |
| • 0 ETB Upfront / Hardware Cost       |   | • Multi-Venue City-Wide Reach         |
| • Modern Digital Signage & TV Software |   | • 100% Attentive High Dwell-Time Views |
| • FREE Digital QR Menu & Ordering Hub |   | • 3-Shift Time-Targeted Ad Campaigns  |
| • 9,000 ETB Net Monthly Passive Cash   |   |                                       |
+---------------------------------------+   +---------------------------------------+
```

---

## 3. The 3-Shift Dayparting Pricing Engine (ETB)

Advertisers pay dynamic rates based on audience foot traffic, dwell times, and purchasing intent during three distinct daily shifts.

| Time Shift | Operating Hours | Audience Profile & Dwell Time | Value Multiplier | Hourly Rate (ETB) | Monthly Slot Rate (Per Screen) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Shift 1: Breakfast / Morning** | 7:00 AM – 11:00 AM (4 hrs) | Quick coffee, breakfast, lower dwell time | **1.0x (Base)** | **100 ETB / hr** | **3,000 ETB / month** |
| **Shift 2: Lunch / Midday** | 11:00 AM – 4:00 PM (5 hrs) | Business lunches, steady foot traffic | **2.5x (Medium)** | **250 ETB / hr** | **4,000 ETB / month** |
| **Shift 3: Dinner / Evening Peak** | 4:00 PM – 11:00 PM (6 hrs) | High dwell time (1–2 hrs), peak crowds | **5.0x (Premium)** | **500 ETB / hr** | **5,000 ETB / month** |

---

## 4. Single Venue Monthly Financial Model

When all 3 daily time-slot shifts are sold for a single TV display screen:

```
Breakfast Shift Sales (Shift 1):     3,000 ETB / month
Lunch Shift Sales     (Shift 2):     4,000 ETB / month
Dinner Shift Sales    (Shift 3):     5,000 ETB / month
-------------------------------------------------------
TOTAL GROSS REVENUE / SCREEN:       12,000 ETB / month

  ├── Venue Payout (75% Net Profit Share):  9,000 ETB / month (100% Passive Revenue)
  └── HoursSignage Platform Cut (25%):      3,000 ETB / month (Tech & Sales Operating Margin)
```

---

## 5. Network Scaling & Financial Projections (100 Venues)

By scaling the network across **100 venue screens** in key commercial hubs (Bole, Kazanchis, Piassa, 22, Old Airport):

### Monthly Network P&L Summary (100 Screens)

- **Total Network Gross Revenue**: **1,200,000 ETB / month** *(1.2 Million ETB)*
- **Total Venue Payouts (75%)**: **900,000 ETB / month** *(Distributed across 100 partner venues)*
- **HoursSignage Net Platform Income (25%)**: **300,000 ETB / month** *(3.6 Million ETB Annualized Profit)*

---

## 6. Corporate Advertiser Packages

National brands (Telecom, Banking, Beverage, E-Commerce, Delivery Apps, Sports Betting) purchase city-wide network access:

### Package Tier 1: City-Wide Dominance Pass (100 Screens)
- **Coverage**: 100 Screens across all 3 time shifts
- **Ad Frequency**: 15-second ad every 4 minutes (**450,000 ad impressions / month**)
- **Price**: **350,000 ETB / month** *(Includes 20% network bulk discount)*

### Package Tier 2: Category Bundle (30 Targeted Screens)
- **Coverage**: 30 Select Venues (e.g., Top 30 Cafes or Lounges)
- **Ad Frequency**: 135,000 impressions / month
- **Price**: **120,000 ETB / month**

### Package Tier 3: Time-Specific Rush Hour Pass (50 Screens)
- **Coverage**: 50 Screens strictly during Lunch (11 AM – 4 PM) or Dinner (4 PM – 10 PM)
- **Ad Frequency**: 112,500 impressions / month
- **Price**: **85,000 ETB / month**

---

## 7. Venue Pitch & Acquisition Playbook

### Why Venue Owners Say YES:
1. **0 ETB Upfront Risk**: Free setup, free Android/Smart TV installation, zero maintenance costs.
2. **Guaranteed Passive Cash**: Venue receives **9,000 ETB every single month** deposited directly via Telebirr or bank transfer.
3. **FREE Digital QR Menu & Ordering Hub**: Replaces expensive printed paper menus. Customers scan the TV screen's QR code (`IdleQrCard` / `ShoutoutMessageQr`) to view the venue's live digital menu, daily food/drink specials, and place instant orders on their phones.
4. **Eliminates Table QR Clutter (Unified LakiPay)**: Replaces 5–10 messy bank/wallet stickers on tables with **One Universal TV QR Code**. Customers can pay with Telebirr, CBE Birr, Awash, Dashen, Abyssinia, etc., seamlessly via LakiPay.
5. **Covers Venue Overheads**: 9,000 ETB monthly payout easily covers their monthly electricity, internet, and TV subscription expenses.
6. **Enhanced Customer Experience**: Digital menus, live sports match center HUD, customer song requests, and DJ shoutout animations keep guests entertained.

---

## 8. Technical Architecture & Real-Time Sync Engine

The network business model is powered by the existing 4-tier HoursSignage tech suite, linked via **Firebase Cloud Firestore Real-Time Data Streams**:

```
+-----------------------------------------------------------------------------------+
|                   ADMIN & VENUE DASHBOARD (nightmusictoughtdasboard)              |
|        Venue Manager updates prices, marks items Out-of-Stock, or edits promos    |
+-----------------------------------------+-----------------------------------------+
                                          | Real-time Firestore Stream
                    +---------------------+---------------------+
                    v                                           v
+---------------------------------------+   +---------------------------------------+
|        TV SIGNAGE (night_track_tv)    |   |     CUSTOMER MENU APP (MUSICINV-2)    |
| • Instant TV Slide & Price Update     |   | • Instant Mobile Menu Price Update    |
| • Zero App Restart Required           |   | • Live Out-of-Stock Badging           |
+---------------------------------------+   +---------------------------------------+
```

1. **Real-Time Price & Product Engine**:
   - Venue managers can update item prices, modify product descriptions, add seasonal specials, or toggle items **"Out of Stock"** instantly from their dashboard.
   - Changes sync in **< 500ms** to both the TV display slides and customer smartphone menus without restarting the TV app or re-printing paper menus.

2. **`night_track_tv` (TV Display Application)**:
   - Listens to real-time settings and ad streams via `TvDisplayCubit` and `settingsStream()`.
   - Displays dynamic venue suggestion cards, price highlights, and campaign ad overlays (`SignageAdOverlay`).

3. **`advertiser` (Advertiser Portal)**:
   - Self-service web portal for brands to upload ad creative, choose time shifts (Breakfast, Lunch, Dinner), select venue clusters, and pay via LakiPay / Telebirr.

4. **`nightmusictoughtdasboard` (Admin & Venue Manager Dashboard)**:
   - Central hub for menu catalog management, real-time price updates, live TV heartbeat monitoring (`updateHeartbeat`), and monthly venue payout reporting.

5. **`MUSICINV-2` & LakiPay Unified Universal Payment QR**:
   - **Solves Table QR Clutter**: Replaces the 5–10 messy individual bank/wallet QR stickers placed on dining tables in Ethiopian venues with **One Single Universal QR Code** displayed on the TV screen (`IdleQrCard` / `ShoutoutMessageQr`).
   - When scanned, customers access the menu and pay instantly via **LakiPay Direct Payment Gateway**, supporting Telebirr, CBE Birr, Awash, Dashen, Abyssinia, and major local banks in a single tap.
