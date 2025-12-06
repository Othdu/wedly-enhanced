# Banners API Specification

This document describes the API endpoints required for the promotional banners feature in the Wedly app.

## Overview

Banners are promotional images displayed in a carousel on the home screen. Admin users can create, update, and delete banners. Each banner can optionally have a link that opens when the user taps on it.

## Features

- **Autoplay Carousel**: Banners auto-rotate every 4 seconds
- **Optional Links**: Admin can add external links to banners (e.g., promo pages, special offers)
- **Display Order**: Banners are sorted by the `order` field (lower numbers appear first)
- **Active/Inactive**: Admin can activate/deactivate banners without deleting them
- **No Banners = Hidden Section**: If no active banners exist, the carousel section disappears completely

---

## API Endpoints

### 1. Get All Active Banners (Public)

**Endpoint**: `GET /api/banners`

**Description**: Returns all active banners, sorted by the `order` field.

**Authentication**: Not required (public endpoint)

**Query Parameters**: None

**Response Format**:
```json
{
  "success": true,
  "data": [
    {
      "id": "banner_1",
      "image_url": "https://cdn.wedly.com/banners/winter-sale.jpg",
      "link": "https://wedly.com/winter-packages",
      "title": "Winter Wedding Packages",
      "title_ar": "عروض حفلات الشتاء",
      "order": 1,
      "is_active": true
    },
    {
      "id": "banner_2",
      "image_url": "https://cdn.wedly.com/banners/photography-discount.jpg",
      "link": "https://wedly.com/photography-special",
      "title": "40% Off Photography",
      "title_ar": "خصم 40% على التصوير",
      "order": 2,
      "is_active": true
    },
    {
      "id": "banner_3",
      "image_url": "https://cdn.wedly.com/banners/wedding-dresses.jpg",
      "link": null,
      "title": "New Wedding Dress Collection",
      "title_ar": "أحدث تصاميم فساتين الزفاف",
      "order": 3,
      "is_active": true
    }
  ]
}
```

**Error Response**:
```json
{
  "success": false,
  "message": "Failed to load banners",
  "message_ar": "فشل تحميل العروض"
}
```

---

### 2. Get Banner by ID (Public)

**Endpoint**: `GET /api/banners/:id`

**Description**: Returns a single banner by ID.

**Authentication**: Not required (public endpoint)

**URL Parameters**:
- `id` (string, required): Banner ID

**Response Format**:
```json
{
  "success": true,
  "data": {
    "id": "banner_1",
    "image_url": "https://cdn.wedly.com/banners/winter-sale.jpg",
    "link": "https://wedly.com/winter-packages",
    "title": "Winter Wedding Packages",
    "title_ar": "عروض حفلات الشتاء",
    "order": 1,
    "is_active": true
  }
}
```

**Error Response** (Banner not found):
```json
{
  "success": false,
  "message": "Banner not found",
  "message_ar": "العرض غير موجود"
}
```

---

### 3. Create Banner (Admin Only)

**Endpoint**: `POST /api/admin/banners`

**Description**: Creates a new banner.

**Authentication**: Required (Admin role only)

**Headers**:
```
Authorization: Bearer <admin_token>
Content-Type: multipart/form-data
```

**Request Body**:
```json
{
  "image": "<file>",
  "link": "https://wedly.com/promo",
  "title": "Summer Sale",
  "title_ar": "عروض الصيف",
  "order": 1,
  "is_active": true
}
```

**Field Descriptions**:
- `image` (file, required): Banner image file (JPG, PNG, WebP)
  - Recommended size: 1200x400 pixels
  - Max file size: 2MB
- `link` (string, optional): External URL to open when banner is tapped
- `title` (string, optional): English title overlay on banner
- `title_ar` (string, optional): Arabic title overlay on banner
- `order` (integer, required): Display order (lower = shown first)
- `is_active` (boolean, required): Whether banner is active

**Response Format**:
```json
{
  "success": true,
  "message": "Banner created successfully",
  "message_ar": "تم إنشاء العرض بنجاح",
  "data": {
    "id": "banner_new",
    "image_url": "https://cdn.wedly.com/banners/summer-sale.jpg",
    "link": "https://wedly.com/promo",
    "title": "Summer Sale",
    "title_ar": "عروض الصيف",
    "order": 1,
    "is_active": true
  }
}
```

**Error Responses**:

Missing image:
```json
{
  "success": false,
  "message": "Image is required",
  "message_ar": "الصورة مطلوبة"
}
```

Invalid image format:
```json
{
  "success": false,
  "message": "Invalid image format. Only JPG, PNG, WebP allowed",
  "message_ar": "صيغة الصورة غير صحيحة. فقط JPG و PNG و WebP مسموح بها"
}
```

Image too large:
```json
{
  "success": false,
  "message": "Image size exceeds 2MB limit",
  "message_ar": "حجم الصورة يتجاوز 2 ميجابايت"
}
```

Unauthorized:
```json
{
  "success": false,
  "message": "Unauthorized. Admin access required",
  "message_ar": "غير مصرح. يتطلب صلاحيات المشرف"
}
```

---

### 4. Update Banner (Admin Only)

**Endpoint**: `PUT /api/admin/banners/:id`

**Description**: Updates an existing banner.

**Authentication**: Required (Admin role only)

**Headers**:
```
Authorization: Bearer <admin_token>
Content-Type: multipart/form-data
```

**URL Parameters**:
- `id` (string, required): Banner ID to update

**Request Body** (all fields optional):
```json
{
  "image": "<file>",
  "link": "https://wedly.com/new-promo",
  "title": "Updated Title",
  "title_ar": "العنوان المحدث",
  "order": 2,
  "is_active": false
}
```

**Response Format**:
```json
{
  "success": true,
  "message": "Banner updated successfully",
  "message_ar": "تم تحديث العرض بنجاح",
  "data": {
    "id": "banner_1",
    "image_url": "https://cdn.wedly.com/banners/updated-banner.jpg",
    "link": "https://wedly.com/new-promo",
    "title": "Updated Title",
    "title_ar": "العنوان المحدث",
    "order": 2,
    "is_active": false
  }
}
```

**Error Response** (Banner not found):
```json
{
  "success": false,
  "message": "Banner not found",
  "message_ar": "العرض غير موجود"
}
```

---

### 5. Delete Banner (Admin Only)

**Endpoint**: `DELETE /api/admin/banners/:id`

**Description**: Permanently deletes a banner.

**Authentication**: Required (Admin role only)

**Headers**:
```
Authorization: Bearer <admin_token>
```

**URL Parameters**:
- `id` (string, required): Banner ID to delete

**Response Format**:
```json
{
  "success": true,
  "message": "Banner deleted successfully",
  "message_ar": "تم حذف العرض بنجاح"
}
```

**Error Response** (Banner not found):
```json
{
  "success": false,
  "message": "Banner not found",
  "message_ar": "العرض غير موجود"
}
```

---

## Database Schema

### Banners Table

```sql
CREATE TABLE banners (
  id VARCHAR(255) PRIMARY KEY,
  image_url VARCHAR(500) NOT NULL,
  link VARCHAR(500) NULL,
  title VARCHAR(255) NULL,
  title_ar VARCHAR(255) NULL,
  order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_order (order),
  INDEX idx_is_active (is_active)
);
```

**Field Constraints**:
- `id`: Unique identifier
- `image_url`: Public URL to uploaded banner image (required)
- `link`: Optional external URL
- `title`: Optional English title
- `title_ar`: Optional Arabic title (recommended for RTL display)
- `order`: Integer for sorting (lower = shown first)
- `is_active`: Boolean to enable/disable banner without deletion

---

## Image Upload Guidelines

### Recommended Image Specifications:
- **Dimensions**: 1200x400 pixels (3:1 aspect ratio)
- **Format**: JPG, PNG, or WebP
- **Max File Size**: 2MB
- **Quality**: 80-90% compression for optimal loading speed
- **Content Safe Area**: Keep important text/logos in center 80% to avoid being cut off on small screens

### Upload Process:
1. Admin uploads image via dashboard
2. Backend validates file type and size
3. Image is uploaded to CDN (e.g., AWS S3, Cloudinary)
4. CDN returns public URL
5. URL is stored in `image_url` field

---

## Frontend Implementation (Current State)

### Mock Data
The app currently uses 4 mock banners in `lib/data/repositories/banner_repository.dart`:

```dart
BannerModel(
  id: '1',
  imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=1200&h=400&fit=crop',
  link: 'https://wedly.com/winter-wedding-packages',
  titleAr: 'عروض حفلات الشتاء',
  title: 'Winter Wedding Packages',
  order: 1,
  isActive: true,
),
// ... 3 more banners
```

### Network Delay Simulation
Mock repository simulates 600ms network delay:
```dart
static const _networkDelay = Duration(milliseconds: 600);
```

### Integration Checklist

When integrating with real API:

- [ ] Replace `BannerRepository` mock implementation with Dio HTTP client
- [ ] Add `ApiClient` integration for banners endpoints
- [ ] Update `getBanners()` to call `GET /api/banners`
- [ ] Implement error handling for network failures
- [ ] Add retry logic for failed requests
- [ ] Update image URLs to use CDN links
- [ ] Test banner carousel with 0, 1, 3, and 10+ banners
- [ ] Test link opening with both HTTP and HTTPS URLs
- [ ] Test banners with and without titles
- [ ] Verify autoplay works correctly
- [ ] Test on slow network connections

---

## Admin Dashboard Requirements

The admin dashboard should provide:

1. **Banner List View**:
   - Show all banners (active and inactive)
   - Display thumbnail, title, order, and status
   - Sortable by order
   - Filter by active/inactive

2. **Create Banner Form**:
   - Image upload with preview
   - Link input (optional)
   - Title inputs (English and Arabic)
   - Order number input
   - Active/Inactive toggle
   - Save button

3. **Edit Banner Form**:
   - Same as create, but pre-populated
   - Option to replace image
   - Option to remove link

4. **Delete Confirmation**:
   - Confirm before permanent deletion
   - Option to deactivate instead of delete

5. **Drag-and-Drop Reordering**:
   - Allow admin to reorder banners visually
   - Auto-update `order` field

---

## User Experience

### Banner Carousel Behavior:

- **Autoplay**: Automatically rotates every 4 seconds
- **Manual Swipe**: User can swipe left/right to navigate
- **Indicators**: Dots below carousel show current position
- **Link Handling**:
  - If banner has link → Tap opens link in external browser
  - If banner has no link → Tap does nothing (no visual feedback)
- **No Banners**: Carousel section is completely hidden

### Visual Design:

- **Height**: 200px (phones), 250px (tablets)
- **Margin**: 8px horizontal spacing between slides
- **Border Radius**: 16px rounded corners
- **Title Overlay**: Semi-transparent gradient at bottom with white text
- **Indicators**: Gold active dot, gray inactive dots

---

## Testing Scenarios

### API Testing:

1. **Get Banners**:
   - Request with 0 banners → Empty array
   - Request with multiple banners → Sorted by order
   - Request with only inactive banners → Empty array

2. **Create Banner**:
   - Upload valid image → Success
   - Upload without image → Error
   - Upload oversized image → Error
   - Create with link → Link saved correctly
   - Create without link → Link is null

3. **Update Banner**:
   - Update order → Order changes
   - Update to inactive → Banner disappears from public API
   - Update link to null → Link removed
   - Update with new image → Old image replaced

4. **Delete Banner**:
   - Delete existing banner → Success
   - Delete non-existent banner → 404 error

### Frontend Testing:

1. **Carousel Display**:
   - 0 banners → Section hidden
   - 1 banner → No autoplay, no indicators
   - 2+ banners → Autoplay enabled, indicators shown

2. **Link Opening**:
   - Tap banner with link → External browser opens
   - Tap banner without link → Nothing happens

3. **Performance**:
   - Large images load smoothly
   - Autoplay doesn't lag
   - Smooth swipe animations

---

## Notes for Backend Team

1. **Image CDN**: Use a CDN for serving banner images to ensure fast loading globally
2. **Image Optimization**: Automatically compress and optimize uploaded images
3. **Caching**: Implement CDN-level caching with appropriate cache headers
4. **Rate Limiting**: Not needed for public GET endpoint, but apply to admin endpoints
5. **Validation**: Strictly validate image dimensions and file types
6. **Order Uniqueness**: Allow duplicate order numbers (backend should sort deterministically)
7. **Soft Delete**: Consider soft delete instead of permanent deletion for admin rollback

---

## Contact

For questions about this API specification, contact the frontend team.

**Last Updated**: 2025-12-06
**Version**: 1.0
