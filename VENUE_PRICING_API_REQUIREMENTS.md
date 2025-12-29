# Venue Pricing API Requirements

## Overview
This document outlines the required API changes to support proper venue pricing in the Wedly app. The Flutter app has been updated to **NEVER calculate prices locally** - all prices must come from the backend API.

## Critical Changes Made to Flutter App

### ✅ Removed All Price Calculations
- **Removed**: `pricePerPerson × capacity` calculations
- **Removed**: Evening multiplier (1.25x)
- **Removed**: Hardcoded decoration prices (5000, 3000, 2000 EGP)
- **Removed**: Hardcoded tax/service charges (100 EGP, 5%)

### ✅ Updated Models
- Added `morningPrice` (optional) to `VenueModel`
- Added `eveningPrice` (optional) to `VenueModel`
- Removed `serviceCharge` from `CartItemModel`

### ✅ Price Display Logic
- If `morningPrice` is provided by API → Display it
- If `morningPrice` is null → Show "السعر غير متاح" (Price not available)
- If `eveningPrice` is provided by API → Display it
- If `eveningPrice` is null → Show "السعر غير متاح" (Price not available)

---

## Required Backend API Changes

### 1. Venue Details API Response

**Current Response (from your screenshot):**
```json
{
  "success": true,
  "data": {
    "venues": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "image_url": "string",
        "city": "string",
        "min_capacity": 0,
        "max_capacity": 0,
        "min_price": 0,
        "max_price": 0,
        "rating": 0,
        "review_count": 0
      }
    ]
  }
}
```

**Required Response (add these fields):**
```json
{
  "success": true,
  "data": {
    "venues": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "image_url": "string",
        "city": "string",
        "capacity": 500,
        "min_capacity": 0,
        "max_capacity": 0,
        "min_price": 0,
        "max_price": 0,
        "morning_price": 5000000,     // ← ADD THIS: Pre-calculated morning slot price
        "evening_price": 6250000,     // ← ADD THIS: Pre-calculated evening slot price
        "price_per_person": 10000,    // ← ADD THIS: Fallback for legacy support
        "rating": 0,
        "review_count": 0,
        "address": "string",
        "latitude": 30.0444,
        "longitude": 31.2357,
        "provider_id": "string",
        "is_active": true
      }
    ]
  }
}
```

### 2. New Fields Explained

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `morning_price` | number | **YES** | **Pre-calculated** total price for morning slot (صباحي). Include ALL costs: base price, time slot fees, venue fees, etc. |
| `evening_price` | number | **YES** | **Pre-calculated** total price for evening slot (مسائي). Include ALL costs: base price, time slot fees, venue fees, etc. |
| `capacity` | number | YES | Single capacity value (used for display) |
| `price_per_person` | number | NO | Fallback only (not used for calculations) |
| `address` | string | NO | Venue address |
| `latitude` | number | NO | For map display |
| `longitude` | number | NO | For map display |
| `provider_id` | string | YES | Provider who owns the venue |

---

## Important Rules for Backend Team

### 🚫 What the Flutter App Does NOT Do:
1. ❌ Does NOT multiply price by capacity
2. ❌ Does NOT apply time slot multipliers (like 1.25x for evening)
3. ❌ Does NOT calculate decoration costs
4. ❌ Does NOT add service charges/tax

### ✅ What the Backend MUST Do:
1. ✅ **Calculate `morning_price`** including:
   - Base venue cost
   - Morning time slot fees
   - Any venue-specific charges
   - Everything the user will pay for morning booking

2. ✅ **Calculate `evening_price`** including:
   - Base venue cost
   - Evening time slot fees (if different from morning)
   - Any venue-specific charges
   - Everything the user will pay for evening booking

3. ✅ Prices should be **final, total prices** ready to display
4. ✅ If price cannot be calculated, omit the field (don't send null or 0)

---

## Example Calculation (Backend Side)

```javascript
// Example backend logic for calculating venue prices
const calculateVenuePrices = (venue) => {
  const basePrice = venue.capacity * venue.pricePerPerson;

  return {
    morning_price: basePrice,                    // Base price for morning
    evening_price: basePrice * 1.25,            // 25% premium for evening
    // OR use fixed prices from database:
    // morning_price: venue.morning_slot_price,
    // evening_price: venue.evening_slot_price,
  };
};
```

---

## TODO: Decoration Packages

**Status**: Not yet implemented in Flutter app (placeholders exist)

**Future Requirement**: Backend should also provide decoration packages with prices:

```json
{
  "decoration_packages": [
    {
      "id": "dec1",
      "name": "ديكور1",
      "name_en": "Decoration Package 1",
      "price": 5000,
      "description": "Premium decoration package"
    },
    {
      "id": "dec2",
      "name": "ديكور2",
      "price": 3000
    },
    {
      "id": "dec3",
      "name": "ديكورة",
      "price": 2000
    },
    {
      "id": "none",
      "name": "خالي",
      "name_en": "No decoration",
      "price": 0
    }
  ]
}
```

---

## Testing Checklist

### ✅ Backend Team Should Test:
- [ ] Venue details API returns `morning_price` and `evening_price`
- [ ] Prices are pre-calculated (not just base price)
- [ ] Prices include all fees/charges
- [ ] Response includes `capacity`, `address`, `latitude`, `longitude`
- [ ] Response includes `provider_id`

### ✅ Flutter Team Should Verify:
- [ ] Morning price displays correctly from API
- [ ] Evening price displays correctly from API
- [ ] "السعر غير متاح" shows when API doesn't provide prices
- [ ] No local calculations are performed
- [ ] Cart stores the exact price from API

---

## Current State vs Required State

| Feature | Current State | Required State |
|---------|--------------|----------------|
| Morning Price | ❌ Not in API | ✅ `morning_price` field |
| Evening Price | ❌ Not in API | ✅ `evening_price` field |
| Price Calculation | ❌ Done in Flutter | ✅ Done in Backend |
| Decoration Prices | ❌ Hardcoded in Flutter | ⏳ TODO: From API |
| Service Charge (Tax) | ✅ Removed | ✅ N/A (no tax) |

---

## Code References

### Flutter Files Updated:
1. `lib/data/models/venue_model.dart` - Added `morningPrice` and `eveningPrice` fields
2. `lib/presentation/screens/user/venue_details_screen.dart:240,318` - Shows API prices or "السعر غير متاح"
3. `lib/presentation/screens/user/venue_booking_screen.dart:43-60` - Uses API prices, fallback to 0
4. `lib/data/models/cart_item_model.dart` - Removed `serviceCharge` field

### TODO Comments in Code:
- Search for `TODO: Backend` in the codebase to find all places requiring API integration
- Main files: `venue_details_screen.dart`, `venue_booking_screen.dart`

---

## Questions?

Contact the Flutter team if you need clarification on:
- Expected price values
- Field naming conventions
- Additional fields needed
- Testing scenarios

---

**Last Updated**: 2025-12-20
**Flutter App Version**: Ready for API integration
**Status**: ⏳ Waiting for backend API updates
