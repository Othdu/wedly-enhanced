# Provider Section - API Documentation

**Project**: Wedly - Wedding Services Marketplace
**Section**: Provider (Service Provider Management)
**Version**: 1.0
**Last Updated**: 2025-01-14

---

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Service Management APIs](#service-management-apis)
4. [Booking Management APIs](#booking-management-apis)
5. [Profile Management APIs](#profile-management-apis)
6. [Category APIs](#category-apis)
7. [Image Upload APIs](#image-upload-apis)
8. [Admin Approval Workflow](#admin-approval-workflow)
9. [Data Models](#data-models)
10. [Error Handling](#error-handling)

---

## Overview

The Provider section allows wedding service providers to:
- **Manage Services**: Create, edit, view, and delete their services
- **Handle Bookings**: View and respond to booking requests (approve/reject)
- **Update Profile**: Manage personal and business information
- **Track Performance**: View ratings and reviews (future enhancement)

### Base URL
```
https://api.wedly.com/v1
```

### Authentication
All provider endpoints require authentication via Bearer token in the request header:
```
Authorization: Bearer {access_token}
```

---

## Authentication

### 1. Login
**Endpoint**: `POST /auth/login`
**Description**: Authenticate user and return access token

**Request Body**:
```json
{
  "email": "provider@example.com",
  "password": "password123"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_123",
      "email": "provider@example.com",
      "name": "محمد أحمد",
      "role": "provider",
      "phone": "+201001234567",
      "city": "القاهرة",
      "profile_image_url": "https://cdn.wedly.com/users/123.jpg",
      "gender": "male"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600
  }
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "البريد الإلكتروني أو كلمة المرور غير صحيحة"
  }
}
```

---

## Service Management APIs

### 1. Get Provider Services
**Endpoint**: `GET /providers/{provider_id}/services`
**Description**: Fetch all services belonging to a specific provider

**URL Parameters**:
- `provider_id` (required): Provider's unique ID

**Query Parameters**:
- `status` (optional): Filter by status (`active`, `inactive`, `pending_approval`)
- `category` (optional): Filter by category
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Request Example**:
```
GET /providers/provider_1/services?status=active&page=1&limit=10
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "services": [
      {
        "id": "service_001",
        "name": "تصوير احترافي للأفراح",
        "description": "خدمة تصوير فوتوغرافي وفيديو احترافي",
        "category": "تصوير فوتوغرافي",
        "price": 1500.0,
        "morning_price": 1200.0,
        "evening_price": 1800.0,
        "chair_count": null,
        "image_url": "https://cdn.wedly.com/services/001/main.jpg",
        "image_urls": [
          "https://cdn.wedly.com/services/001/1.jpg",
          "https://cdn.wedly.com/services/001/2.jpg"
        ],
        "latitude": 30.0444,
        "longitude": 31.2357,
        "address": "القاهرة، مصر الجديدة",
        "provider_id": "provider_1",
        "is_active": true,
        "is_pending_approval": false,
        "discount_percentage": 10.0,
        "rating": 4.8,
        "review_count": 24,
        "created_at": "2025-01-10T10:30:00Z",
        "updated_at": "2025-01-14T15:20:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_items": 25,
      "items_per_page": 10
    }
  }
}
```

---

### 2. Get Service by ID
**Endpoint**: `GET /services/{service_id}`
**Description**: Fetch detailed information about a specific service

**URL Parameters**:
- `service_id` (required): Service's unique ID

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "service_001",
    "name": "تصوير احترافي للأفراح",
    "description": "خدمة تصوير فوتوغرافي وفيديو احترافي",
    "category": "تصوير فوتوغرافي",
    "price": 1500.0,
    "morning_price": 1200.0,
    "evening_price": 1800.0,
    "chair_count": null,
    "image_url": "https://cdn.wedly.com/services/001/main.jpg",
    "image_urls": [
      "https://cdn.wedly.com/services/001/1.jpg",
      "https://cdn.wedly.com/services/001/2.jpg"
    ],
    "latitude": 30.0444,
    "longitude": 31.2357,
    "address": "القاهرة، مصر الجديدة",
    "provider_id": "provider_1",
    "is_active": true,
    "is_pending_approval": false,
    "discount_percentage": 10.0,
    "rating": 4.8,
    "review_count": 24,
    "created_at": "2025-01-10T10:30:00Z",
    "updated_at": "2025-01-14T15:20:00Z"
  }
}
```

**Error Response** (404 Not Found):
```json
{
  "success": false,
  "error": {
    "code": "SERVICE_NOT_FOUND",
    "message": "الخدمة غير موجودة"
  }
}
```

---

### 3. Create Service
**Endpoint**: `POST /services`
**Description**: Create a new service (no admin approval required for creation)

**Authorization**: Required (Provider only)

**Request Body**:
```json
{
  "name": "تصوير احترافي للأفراح",
  "description": "خدمة تصوير فوتوغرافي وفيديو احترافي لحفلات الزفاف",
  "category": "تصوير فوتوغرافي",
  "price": 1500.0,
  "morning_price": 1200.0,
  "evening_price": 1800.0,
  "chair_count": null,
  "image_url": "https://cdn.wedly.com/temp/uploaded_image.jpg",
  "image_urls": [
    "https://cdn.wedly.com/temp/image1.jpg",
    "https://cdn.wedly.com/temp/image2.jpg"
  ],
  "latitude": 30.0444,
  "longitude": 31.2357,
  "address": "القاهرة، مصر الجديدة",
  "discount_percentage": 10.0
}
```

**Validation Rules**:
- `name`: Required, 3-100 characters
- `description`: Required, 10-500 characters
- `category`: Required, must be from predefined categories
- `price`: Required, > 0
- `morning_price`: Optional, > 0
- `evening_price`: Optional, > 0
- `chair_count`: Optional, > 0 (only for venue category)
- `image_url`: Required (uploaded via Image Upload API)
- `image_urls`: Optional, max 10 images
- `latitude`, `longitude`: Optional (from Google Maps)
- `address`: Optional
- `discount_percentage`: Optional, 0-100

**Response** (201 Created):
```json
{
  "success": true,
  "message": "تم إضافة الخدمة بنجاح",
  "data": {
    "id": "service_123",
    "name": "تصوير احترافي للأفراح",
    "description": "خدمة تصوير فوتوغرافي وفيديو احترافي لحفلات الزفاف",
    "category": "تصوير فوتوغرافي",
    "price": 1500.0,
    "morning_price": 1200.0,
    "evening_price": 1800.0,
    "chair_count": null,
    "image_url": "https://cdn.wedly.com/services/123/main.jpg",
    "image_urls": [
      "https://cdn.wedly.com/services/123/1.jpg",
      "https://cdn.wedly.com/services/123/2.jpg"
    ],
    "latitude": 30.0444,
    "longitude": 31.2357,
    "address": "القاهرة، مصر الجديدة",
    "provider_id": "provider_1",
    "is_active": true,
    "is_pending_approval": false,
    "discount_percentage": 10.0,
    "rating": null,
    "review_count": 0,
    "created_at": "2025-01-14T16:00:00Z",
    "updated_at": "2025-01-14T16:00:00Z"
  }
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "خطأ في البيانات المدخلة",
    "fields": {
      "name": "اسم الخدمة مطلوب",
      "price": "السعر يجب أن يكون أكبر من صفر"
    }
  }
}
```

---

### 4. Update Service
**Endpoint**: `PUT /services/{service_id}`
**Description**: Update an existing service (**Requires admin approval**)

**⚠️ IMPORTANT**: When a service is updated, `is_pending_approval` is set to `true` and the service enters admin review workflow. The updated data is NOT immediately visible to users until admin approves.

**Authorization**: Required (Provider who owns the service)

**URL Parameters**:
- `service_id` (required): Service's unique ID

**Request Body**:
```json
{
  "price": 1600.0,
  "morning_price": 1300.0,
  "evening_price": 1900.0,
  "chair_count": null,
  "discount_percentage": 15.0
}
```

**Note**: `name`, `category`, `description`, and `image_url` are **read-only** during edits (cannot be changed)

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم إرسال التعديلات للمراجعة من قبل الإدارة",
  "data": {
    "id": "service_123",
    "name": "تصوير احترافي للأفراح",
    "price": 1600.0,
    "morning_price": 1300.0,
    "evening_price": 1900.0,
    "is_pending_approval": true,
    "updated_at": "2025-01-14T16:30:00Z"
  }
}
```

**Error Response** (403 Forbidden):
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "ليس لديك صلاحية لتعديل هذه الخدمة"
  }
}
```

---

### 5. Delete Service
**Endpoint**: `DELETE /services/{service_id}`
**Description**: Delete a service (soft delete)

**Authorization**: Required (Provider who owns the service)

**URL Parameters**:
- `service_id` (required): Service's unique ID

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم حذف الخدمة بنجاح"
}
```

**Error Response** (409 Conflict):
```json
{
  "success": false,
  "error": {
    "code": "SERVICE_HAS_ACTIVE_BOOKINGS",
    "message": "لا يمكن حذف الخدمة لوجود حجوزات نشطة"
  }
}
```

---

### 6. Toggle Service Status
**Endpoint**: `PATCH /services/{service_id}/toggle-status`
**Description**: Activate or deactivate a service

**Authorization**: Required (Provider who owns the service)

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم تحديث حالة الخدمة",
  "data": {
    "id": "service_123",
    "is_active": false
  }
}
```

---

## Booking Management APIs

### 1. Get Provider Bookings
**Endpoint**: `GET /providers/{provider_id}/bookings`
**Description**: Fetch all bookings for a provider's services

**URL Parameters**:
- `provider_id` (required): Provider's unique ID

**Query Parameters**:
- `status` (optional): Filter by status (`pending`, `confirmed`, `cancelled`, `completed`)
- `service_id` (optional): Filter by specific service
- `date_from` (optional): Start date filter (YYYY-MM-DD)
- `date_to` (optional): End date filter (YYYY-MM-DD)
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Request Example**:
```
GET /providers/provider_1/bookings?status=pending&page=1&limit=10
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "bookings": [
      {
        "id": "booking_001",
        "service_id": "service_123",
        "service_name": "تصوير احترافي للأفراح",
        "user_id": "user_456",
        "customer_name": "فاطمة محمد",
        "customer_phone": "+201234567890",
        "customer_email": "fatima@example.com",
        "event_type": "زفاف",
        "event_date": "2025-02-15",
        "event_time": "18:00",
        "time_slot": "evening",
        "guest_count": 200,
        "price": 1800.0,
        "discount_amount": 180.0,
        "final_price": 1620.0,
        "special_requests": "نريد تصوير فيديو سينمائي إضافي",
        "status": "pending",
        "created_at": "2025-01-12T14:30:00Z",
        "updated_at": "2025-01-12T14:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 2,
      "total_items": 15,
      "items_per_page": 10
    },
    "summary": {
      "pending_count": 5,
      "confirmed_count": 8,
      "cancelled_count": 2,
      "completed_count": 0
    }
  }
}
```

---

### 2. Get Booking Details
**Endpoint**: `GET /bookings/{booking_id}`
**Description**: Fetch detailed information about a specific booking

**URL Parameters**:
- `booking_id` (required): Booking's unique ID

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "booking_001",
    "service_id": "service_123",
    "service_name": "تصوير احترافي للأفراح",
    "service_image_url": "https://cdn.wedly.com/services/123/main.jpg",
    "user_id": "user_456",
    "customer_name": "فاطمة محمد",
    "customer_phone": "+201234567890",
    "customer_email": "fatima@example.com",
    "event_type": "زفاف",
    "event_date": "2025-02-15",
    "event_time": "18:00",
    "time_slot": "evening",
    "guest_count": 200,
    "price": 1800.0,
    "discount_amount": 180.0,
    "final_price": 1620.0,
    "special_requests": "نريد تصوير فيديو سينمائي إضافي",
    "status": "pending",
    "created_at": "2025-01-12T14:30:00Z",
    "updated_at": "2025-01-12T14:30:00Z"
  }
}
```

---

### 3. Update Booking Status
**Endpoint**: `PATCH /bookings/{booking_id}/status`
**Description**: Approve or reject a booking request

**Authorization**: Required (Provider who owns the service)

**URL Parameters**:
- `booking_id` (required): Booking's unique ID

**Request Body**:
```json
{
  "status": "confirmed",
  "rejection_reason": null
}
```

**Valid Status Values**:
- `confirmed`: Approve the booking
- `cancelled`: Reject the booking (requires `rejection_reason`)

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم تأكيد الحجز بنجاح",
  "data": {
    "id": "booking_001",
    "status": "confirmed",
    "updated_at": "2025-01-14T17:00:00Z"
  }
}
```

**For Rejection**:
```json
{
  "status": "cancelled",
  "rejection_reason": "الموعد غير متاح في التاريخ المحدد"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم إلغاء الحجز",
  "data": {
    "id": "booking_001",
    "status": "cancelled",
    "rejection_reason": "الموعد غير متاح في التاريخ المحدد",
    "updated_at": "2025-01-14T17:00:00Z"
  }
}
```

---

### 4. Get Bookings Count by Status
**Endpoint**: `GET /providers/{provider_id}/bookings/count`
**Description**: Get count of bookings grouped by status

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "pending": 5,
    "confirmed": 12,
    "cancelled": 3,
    "completed": 8
  }
}
```

---

## Profile Management APIs

### 1. Get Provider Profile
**Endpoint**: `GET /providers/{provider_id}`
**Description**: Fetch provider's profile information

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "provider_1",
    "email": "provider@example.com",
    "name": "محمد أحمد",
    "role": "provider",
    "phone": "+201001234567",
    "city": "القاهرة",
    "profile_image_url": "https://cdn.wedly.com/users/provider_1.jpg",
    "gender": "male",
    "created_at": "2024-12-01T10:00:00Z",
    "updated_at": "2025-01-14T12:00:00Z"
  }
}
```

---

### 2. Update Provider Profile
**Endpoint**: `PUT /providers/{provider_id}`
**Description**: Update provider's profile information

**Authorization**: Required (Provider must be authenticated)

**Request Body**:
```json
{
  "name": "محمد أحمد السيد",
  "email": "provider_new@example.com",
  "phone": "+201001234567",
  "city": "الجيزة",
  "profile_image_url": "https://cdn.wedly.com/users/provider_1_new.jpg"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم تحديث الملف الشخصي بنجاح",
  "data": {
    "id": "provider_1",
    "name": "محمد أحمد السيد",
    "email": "provider_new@example.com",
    "phone": "+201001234567",
    "city": "الجيزة",
    "profile_image_url": "https://cdn.wedly.com/users/provider_1_new.jpg",
    "updated_at": "2025-01-14T17:30:00Z"
  }
}
```

---

## Category APIs

### 1. Get All Categories
**Endpoint**: `GET /categories`
**Description**: Fetch list of all service categories

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": "cat_001",
        "name": "تصوير فوتوغرافي",
        "name_en": "Photography",
        "icon": "📷",
        "service_count": 45
      },
      {
        "id": "cat_002",
        "name": "كوش وديكور",
        "name_en": "Decoration",
        "icon": "🎨",
        "service_count": 32
      },
      {
        "id": "cat_003",
        "name": "فرق موسيقية",
        "name_en": "Music Bands",
        "icon": "🎵",
        "service_count": 28
      },
      {
        "id": "cat_004",
        "name": "قاعات أفراح",
        "name_en": "Venues",
        "icon": "🏛️",
        "service_count": 18
      },
      {
        "id": "cat_005",
        "name": "تجميل وميك أب",
        "name_en": "Beauty & Makeup",
        "icon": "💄",
        "service_count": 39
      },
      {
        "id": "cat_006",
        "name": "تنظيم حفلات",
        "name_en": "Event Planning",
        "icon": "🎉",
        "service_count": 22
      },
      {
        "id": "cat_007",
        "name": "كيك وحلويات",
        "name_en": "Cakes & Sweets",
        "icon": "🎂",
        "service_count": 31
      },
      {
        "id": "cat_008",
        "name": "دي جي",
        "name_en": "DJ",
        "icon": "🎧",
        "service_count": 15
      }
    ]
  }
}
```

---

## Image Upload APIs

### 1. Upload Service Image
**Endpoint**: `POST /upload/service-image`
**Description**: Upload an image for a service

**Authorization**: Required (Provider only)

**Request**: Multipart form data
```
Content-Type: multipart/form-data

image: [binary file data]
service_id: "service_123" (optional, for existing service)
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم رفع الصورة بنجاح",
  "data": {
    "url": "https://cdn.wedly.com/services/123/image_001.jpg",
    "thumbnail_url": "https://cdn.wedly.com/services/123/thumb_image_001.jpg",
    "size": 245678,
    "format": "jpg"
  }
}
```

**Validation**:
- Max file size: 5MB
- Allowed formats: JPG, JPEG, PNG, WEBP
- Image dimensions: Min 800x600, Max 4000x4000

---

### 2. Upload Profile Picture
**Endpoint**: `POST /upload/profile-picture`
**Description**: Upload profile picture for provider

**Authorization**: Required (Provider only)

**Request**: Multipart form data
```
Content-Type: multipart/form-data

image: [binary file data]
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم رفع الصورة الشخصية بنجاح",
  "data": {
    "url": "https://cdn.wedly.com/users/provider_1.jpg",
    "thumbnail_url": "https://cdn.wedly.com/users/thumb_provider_1.jpg"
  }
}
```

---

## Admin Approval Workflow

### Overview
When a provider edits a service, the changes require admin approval before being visible to users.

### Workflow Steps

1. **Provider Submits Edit**
   - Provider updates service via `PUT /services/{service_id}`
   - `is_pending_approval` is set to `true`
   - Original service data remains visible to users
   - Provider sees "under review" badge on their service

2. **Admin Reviews Changes**
   - Admin receives notification of pending changes
   - Admin reviews the updated service data
   - Admin can approve or reject

3. **Admin Approval**
   - Admin approves: `is_pending_approval` set to `false`, changes go live
   - Admin rejects: `is_pending_approval` set to `false`, changes reverted

### Admin Approval Endpoints (Backend Internal)

#### Approve Service Edit
**Endpoint**: `POST /admin/services/{service_id}/approve`
**Authorization**: Required (Admin only)

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم الموافقة على التعديلات",
  "data": {
    "service_id": "service_123",
    "is_pending_approval": false,
    "approved_at": "2025-01-15T10:00:00Z"
  }
}
```

#### Reject Service Edit
**Endpoint**: `POST /admin/services/{service_id}/reject`
**Authorization**: Required (Admin only)

**Request Body**:
```json
{
  "rejection_reason": "الأسعار المدخلة غير معقولة"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "تم رفض التعديلات",
  "data": {
    "service_id": "service_123",
    "is_pending_approval": false,
    "rejection_reason": "الأسعار المدخلة غير معقولة",
    "rejected_at": "2025-01-15T10:00:00Z"
  }
}
```

---

## Data Models

### ServiceModel
```typescript
{
  id: string;                    // Unique service ID
  name: string;                  // Service name (Arabic)
  description: string;           // Service description
  category: string;              // Category name
  price: number;                 // Default price
  morning_price?: number;        // Morning time slot price (optional)
  evening_price?: number;        // Evening time slot price (optional)
  chair_count?: number;          // Number of chairs (for venues)
  image_url: string;             // Main service image
  image_urls?: string[];         // Additional images (max 10)
  latitude?: number;             // Service location latitude
  longitude?: number;            // Service location longitude
  address?: string;              // Human-readable address
  provider_id: string;           // Owner provider ID
  is_active: boolean;            // Service availability status
  is_pending_approval: boolean;  // Admin approval status
  discount_percentage?: number;  // Discount (0-100)
  rating?: number;               // Average rating (0-5)
  review_count?: number;         // Number of reviews
  created_at: string;            // ISO 8601 timestamp
  updated_at: string;            // ISO 8601 timestamp
}
```

### BookingModel
```typescript
{
  id: string;                    // Unique booking ID
  service_id: string;            // Service being booked
  service_name: string;          // Service name
  service_image_url: string;     // Service image
  user_id: string;               // Customer user ID
  customer_name: string;         // Customer name
  customer_phone: string;        // Customer phone
  customer_email: string;        // Customer email
  event_type: string;            // Event type (زفاف، خطوبة، etc.)
  event_date: string;            // Event date (YYYY-MM-DD)
  event_time: string;            // Event time (HH:MM)
  time_slot?: string;            // Time slot (morning/evening)
  guest_count?: number;          // Number of guests
  price: number;                 // Original price
  discount_amount: number;       // Discount applied
  final_price: number;           // Final price after discount
  special_requests?: string;     // Special requests from customer
  status: string;                // pending, confirmed, cancelled, completed
  rejection_reason?: string;     // Reason for cancellation
  created_at: string;            // ISO 8601 timestamp
  updated_at: string;            // ISO 8601 timestamp
}
```

### UserModel (Provider)
```typescript
{
  id: string;                    // Unique user ID
  email: string;                 // Email address
  name: string;                  // Full name
  role: string;                  // "provider"
  phone?: string;                // Phone number
  city?: string;                 // City name
  profile_image_url?: string;    // Profile picture URL
  gender?: string;               // "male" or "female"
  created_at: string;            // ISO 8601 timestamp
  updated_at: string;            // ISO 8601 timestamp
}
```

---

## Error Handling

### HTTP Status Codes
- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource conflict (e.g., service has active bookings)
- `422 Unprocessable Entity`: Validation error
- `500 Internal Server Error`: Server error

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "رسالة الخطأ بالعربية",
    "fields": {
      "field_name": "خطأ في الحقل"
    }
  }
}
```

### Common Error Codes
- `VALIDATION_ERROR`: Invalid input data
- `UNAUTHORIZED`: Not authenticated
- `FORBIDDEN`: Insufficient permissions
- `NOT_FOUND`: Resource not found
- `DUPLICATE_ENTRY`: Resource already exists
- `SERVICE_HAS_ACTIVE_BOOKINGS`: Cannot delete service with active bookings
- `INVALID_CREDENTIALS`: Wrong email/password
- `SERVICE_NOT_FOUND`: Service doesn't exist
- `BOOKING_NOT_FOUND`: Booking doesn't exist

---

## Testing & Development

### Mock Data
For testing purposes, the app currently uses mock data with network delays:
- Login: Always succeeds with any credentials
- Services: Returns 6 hardcoded services
- Bookings: Returns 7 hardcoded bookings

### Development Environment
```
Base URL: https://dev-api.wedly.com/v1
```

### Production Environment
```
Base URL: https://api.wedly.com/v1
```

---

## Rate Limiting
- **Requests per minute**: 60
- **Burst**: 100

**Rate Limit Headers**:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1642077600
```

---

## Webhooks (Future Enhancement)
Providers can register webhook URLs to receive real-time notifications:
- New booking received
- Booking cancelled by user
- Service approved by admin
- Service rejected by admin

---

## Notes for Backend Team

### Priority 1 (Must Have)
1. ✅ Service CRUD operations with provider filtering
2. ✅ Booking management with status updates
3. ✅ Profile update with phone & city fields
4. ✅ Admin approval workflow for service edits
5. ✅ Image upload endpoints

### Priority 2 (Should Have)
6. Category management API
7. Booking date/time validation (prevent double booking)
8. Search and filtering for services and bookings
9. Pagination for all list endpoints

### Priority 3 (Nice to Have)
10. Analytics endpoints (revenue, popular services)
11. Review and rating system
12. Notification system (push/email/SMS)
13. Bulk operations for services
14. Export bookings to CSV/PDF

### Security Considerations
- Implement JWT token authentication
- Validate provider ownership for all service/booking operations
- Sanitize all user inputs to prevent XSS/SQL injection
- Implement CORS properly
- Use HTTPS only
- Rate limit API endpoints

### Database Indexes
Recommended indexes for performance:
```sql
CREATE INDEX idx_services_provider_id ON services(provider_id);
CREATE INDEX idx_services_category ON services(category);
CREATE INDEX idx_services_is_active ON services(is_active);
CREATE INDEX idx_bookings_service_id ON bookings(service_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_event_date ON bookings(event_date);
```

---

## Contact & Support
For questions about this API documentation:
- **Frontend Team**: [frontend@wedly.com]
- **Backend Team**: [backend@wedly.com]
- **Project Manager**: [pm@wedly.com]

---

**END OF DOCUMENT**
