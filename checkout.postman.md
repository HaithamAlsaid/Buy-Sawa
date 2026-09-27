# Checkout API — Postman Guide & Payload Reference

> **Endpoint**: `POST /api/v1/orders/checkout`  
> **Authentication**: Bearer Token (`auth:sanctum`)  
> **Content-Type**: `application/json`  
> **Accept**: `application/json`  
> **Default Market & Currency**: United Arab Emirates (UAE) — `AED`  
> **Active Providers**: N-Genius (`ngenius`), Tabby (`tabby`), Tamara (`tamara`), Customer Wallet (`wallet`)

---

## 📑 Table of Contents
1. [Field Reference](#1--complete-field-reference)
2. [Address Object Fields](#shipping_address--billing_address-object-fields)
3. [Postman Environment Setup](#2--postman-environment-setup)
4. [Request Scenarios](#3--request-body-examples-by-scenario)
   - [Scenario 1: Existing Address ID (Credit Card via N-Genius)](#scenario-1-existing-address-id-credit-card-via-n-genius)
   - [Scenario 2: Buy Now Pay Later via Tabby](#scenario-2-buy-now-pay-later-via-tabby)
   - [Scenario 3: Buy Now Pay Later via Tamara](#scenario-3-buy-now-pay-later-via-tamara)
   - [Scenario 4: 100% Wallet Balance Payment](#scenario-4-100-wallet-payment-payment_method-wallet)
   - [Scenario 5: Split Payment (Wallet Contribution + N-Genius Card Gateway)](#scenario-5-split-payment-wallet-contribution--n-genius-card-gateway)
   - [Scenario 6: Inline New Shipping Address (`save_address: true`)](#scenario-6-inline-new-shipping-address-saved-to-address-book)
   - [Scenario 7: One-Time Guest / Hotel Address (`save_address: false`)](#scenario-7-one-time-address-save_address-false)
   - [Scenario 8: Distinct Shipping and Billing Addresses](#scenario-8-distinct-shipping-and-billing-addresses)
   - [Scenario 9: Flat Address Payload (Simplified Mobile Format)](#scenario-9-flat-address-payload-simplified-mobile-format)
   - [Scenario 10: Monthly Subscription Plan Checkout](#scenario-10-monthly-subscription-plan-checkout)
   - [Scenario 11: Promotional Coupon & Idempotency Key](#scenario-11-promotional-coupon--idempotency-key)
   - [Scenario 12: Specific Shipping Carrier & Method Selection](#scenario-12-specific-shipping-carrier--method-selection)
5. [Response Structure Examples](#4--response-structure-examples)

---

## 1. 📋 Complete Field Reference

| Field | Type | Requirement | Description | Example |
|:---|:---|:---|:---|:---|
| `shipping_address_id` | `integer` | Required **without** `shipping_address` | ID of a previously saved user address. | `8` |
| `shipping_address` | `object` | Required **without** `shipping_address_id` | Complete inline shipping address details. | *See object breakdown below* |
| `billing_address_id` | `integer` | Optional | ID of an existing billing address. If omitted and `billing_address` is omitted, defaults to shipping address. | `8` |
| `billing_address` | `object` | Optional | Complete inline billing address details. | *See object breakdown below* |
| `payment_method` | `string` | **Required** | Payment method type: `card`, `wallet`, `bnpl`. | `"card"` |
| `provider` | `string` | Optional | Active payment gateway provider: `ngenius`, `tabby`, `tamara`, `wallet`. | `"ngenius"` |
| `phone` | `string` | Optional | Customer contact phone. Automatically saved to order metadata & cloned address. | `"0501234567"` |
| `customer_note` | `string` | Optional (max: 1000) | Delivery instructions or special notes from the customer. | `"Please deliver after 2 PM."` |
| `coupon_code` | `string` | Optional (max: 64) | Applied promotional discount code. | `"DUBAI2026"` |
| `idempotency_key` | `string` | Optional (max: 255) | Unique client UUID to guarantee request idempotency. | `"9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d"` |
| `use_wallet` | `boolean` | Optional | Set `true` to partially pay from the customer's wallet balance. | `true` |
| `wallet_amount` | `number` | Optional | Specific amount to debit from the wallet balance in AED. | `250.00` |
| `monthly_subscription_id` | `integer`| Optional | Active monthly subscription plan ID covering eligible product entitlements. | `1` |
| `return_url` | `string` | Optional | Redirection URL after online card/payment processing. | `"https://app.buysawa.ae/checkout/callback"` |
| `callback_url` | `string` | Optional | Webhook callback URL for payment confirmation. | `"https://app.buysawa.ae/api/v1/payments/ngenius/webhook"` |
| `shipping_carrier_code` | `string` | Optional | Preferred courier code: `aramex`, `dhl`, `internal`, `standard`. | `"aramex"` |
| `shipping_method_id` | `string\|int`| Optional | Specific shipping service rate/method ID. | `1` |
| `shipping_rate` | `number` | Optional | Manual shipping override amount (if allowed by business policy). | `25.00` |

---

### `shipping_address` & `billing_address` Object Fields

| Sub-field | Type | Requirement | Description | Example |
|:---|:---|:---|:---|:---|
| `address_line_1` | `string\|array` | **Required** | Street address, building name, and landmark. Single string or `{"en": "...", "ar": "..."}`. | `"Downtown Dubai, Boulevard Plaza Tower 1"` |
| `address_line_2` | `string\|array` | Optional | Floor, apartment, suite number. | `"Apt 1402, Floor 14"` |
| `city` | `string\|array` | **Required** | City or emirate name. | `"Dubai"` |
| `state` | `string\|array` | Optional | Emirate or province. | `"Dubai"` |
| `postal_code` | `string` | Optional | Postal code (or `00000` for UAE). | `"00000"` |
| `country` | `string\|array` | Optional (default: `"AE"`) | Country ISO code or name (`"AE"` or `"United Arab Emirates"`). | `"AE"` |
| `phone` | `string\|array` | Optional | Contact phone for this specific location. | `"0501234567"` |
| `phone_code` | `string` | Optional | Country dialing code (used if submitting `phone_number`). | `"+971"` |
| `phone_number` | `string` | Optional | Phone number without dialing code. | `"501234567"` |
| `label` | `string\|array` | Optional | Friendly label for the address. | `"Home"` or `"Office"` |
| `instructions` | `string\|array` | Optional | Delivery or building access instructions. | `"Leave with concierge at reception"` |
| `latitude` | `numeric` | Optional | GPS latitude coordinate. | `25.1972` |
| `longitude` | `numeric` | Optional | GPS longitude coordinate. | `55.2744` |
| `save_address` | `boolean` | Optional (default: `true`)| When `true`, automatically attaches address to customer profile. | `true` |
| `is_default` | `boolean` | Optional | Mark this address as customer's default address. | `true` |

---

## 2. ⚡ Postman Environment Setup

```json
{
  "baseUrl": "http://localhost:8000",
  "apiUrl": "{{baseUrl}}/api/v1",
  "token": "YOUR_SANCTUM_BEARER_TOKEN",
  "shippingAddressId": 8,
  "subscriptionId": 1
}
```

---

## 3. 📦 Request Body Examples by Scenario

### Scenario 1: Existing Address ID (Credit Card via N-Genius)
Initiates an order payment intent with N-Genius Gateway in AED using a saved shipping address. The response includes `payment_action.redirection_url` pointing to the secure N-Genius hosted payment portal.

```json
{
  "shipping_address_id": 8,
  "billing_address_id": 8,
  "payment_method": "card",
  "provider": "ngenius",
  "phone": "0501234567",
  "return_url": "https://app.buysawa.ae/checkout/success",
  "callback_url": "https://app.buysawa.ae/api/v1/payments/ngenius/webhook",
  "customer_note": "Handle with care"
}
```

---

### Scenario 2: Buy Now Pay Later via Tabby
Submits an installment order through Tabby BNPL in UAE (AED). Response includes the Tabby checkout flow redirect URL.

```json
{
  "shipping_address_id": 8,
  "billing_address_id": 8,
  "payment_method": "bnpl",
  "provider": "tabby",
  "phone": "0501234567",
  "return_url": "https://app.buysawa.ae/checkout/success",
  "customer_note": "Tabby 4-month installments"
}
```

---

### Scenario 3: Buy Now Pay Later via Tamara
Submits an order through Tamara BNPL in UAE (AED). Response includes the Tamara checkout session redirect URL.

```json
{
  "shipping_address_id": 8,
  "billing_address_id": 8,
  "payment_method": "bnpl",
  "provider": "tamara",
  "phone": "0501234567",
  "return_url": "https://app.buysawa.ae/checkout/success",
  "customer_note": "Pay in 3 with Tamara"
}
```

---

### Scenario 4: 100% Wallet Payment (`payment_method: "wallet"`)
Full payment debited from customer wallet balance in AED. Order is instantly marked `PROCESSING` and `PAID`.

```json
{
  "shipping_address_id": 8,
  "payment_method": "wallet",
  "provider": "wallet",
  "phone": "0501234567",
  "customer_note": "Paid in full via BuySawa Wallet"
}
```

---

### Scenario 5: Split Payment (Wallet Contribution + N-Genius Card Gateway)
Deducts an exact AED amount from the customer's wallet balance and charges the remaining balance to N-Genius credit card.

```json
{
  "shipping_address_id": 8,
  "payment_method": "card",
  "provider": "ngenius",
  "use_wallet": true,
  "wallet_amount": 250.00,
  "phone": "0501234567",
  "return_url": "https://app.buysawa.ae/checkout/success"
}
```

---

### Scenario 6: Inline New Shipping Address (Saved to Address Book)
No existing address needed. Address is created, saved to user's address book, and billing defaults to shipping.

```json
{
  "shipping_address": {
    "address_line_1": "Sheikh Zayed Road, Al Manara",
    "address_line_2": "Villa 14, Street 12B",
    "city": "Dubai",
    "state": "Dubai",
    "postal_code": "00000",
    "country": "AE",
    "phone": "0501234567",
    "label": "Home",
    "instructions": "Ring doorbell at main gate",
    "save_address": true,
    "is_default": true
  },
  "payment_method": "card",
  "provider": "ngenius",
  "phone": "0501234567"
}
```

---

### Scenario 7: One-Time Address (`save_address: false`)
Uses the address for this order snapshot only, without adding it to the user's permanent address book (e.g. hotel, vacation residence).

```json
{
  "shipping_address": {
    "address_line_1": "Room 502, W Hotel Yas Island",
    "city": "Abu Dhabi",
    "state": "Abu Dhabi",
    "postal_code": "00000",
    "country": "AE",
    "phone": "0529988776",
    "save_address": false
  },
  "payment_method": "card",
  "provider": "ngenius",
  "phone": "0529988776"
}
```

---

### Scenario 8: Distinct Shipping and Billing Addresses
Customer ships to one UAE location but bills to a separate corporate or personal entity.

```json
{
  "shipping_address": {
    "address_line_1": "Dubai Silicon Oasis, Techno Hub 2",
    "city": "Dubai",
    "state": "Dubai",
    "country": "AE",
    "phone": "0501234567",
    "label": "Office Warehouse"
  },
  "billing_address": {
    "address_line_1": "DIFC, Gate Precinct Building 4, Level 5",
    "city": "Dubai",
    "state": "Dubai",
    "country": "AE",
    "phone": "041234567",
    "label": "Corporate HQ"
  },
  "payment_method": "card",
  "provider": "ngenius"
}
```

---

### Scenario 9: Flat Address Payload (Simplified Mobile Format)
Flat root-level fields are automatically packed and normalized into `shipping_address`.

```json
{
  "address_line_1": "Jumeirah Beach Residence, Sadaf 4",
  "address_line_2": "Apartment 1802",
  "city": "Dubai",
  "state": "Dubai",
  "postal_code": "00000",
  "country": "AE",
  "payment_method": "card",
  "provider": "ngenius",
  "phone": "0501234567",
  "customer_note": "Call when at reception"
}
```

---

### Scenario 10: Monthly Subscription Plan Checkout
Consumes an active monthly plan subscription. Plan covers product entitlements; customer only pays remaining shipping/taxes via N-Genius.

```json
{
  "shipping_address_id": 8,
  "monthly_subscription_id": 1,
  "payment_method": "card",
  "provider": "ngenius",
  "phone": "0501234567",
  "customer_note": "Monthly Subscription Plan order"
}
```

---

### Scenario 11: Promotional Coupon & Idempotency Key
Applies a discount coupon and protects against duplicate submissions with an idempotency key.

```json
{
  "shipping_address_id": 8,
  "coupon_code": "DUBAI2026",
  "idempotency_key": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "payment_method": "card",
  "provider": "ngenius",
  "phone": "0501234567"
}
```

---

### Scenario 12: Specific Shipping Carrier & Method Selection
Explicitly select shipping carrier (e.g. Aramex, DHL) and delivery service rate.

```json
{
  "shipping_address_id": 8,
  "shipping_carrier_code": "aramex",
  "shipping_method_id": "standard",
  "payment_method": "card",
  "provider": "ngenius",
  "phone": "0501234567"
}
```

---

## 4. 📤 Response Structure Examples

### A. 201 Created (Card Payment with N-Genius Redirection)
```json
{
  "status": "success",
  "message": "Order placed successfully.",
  "data": {
    "id": 42,
    "order_number": "ORD-20260925-0042",
    "status": {
      "value": 2,
      "name": "PENDING",
      "label": "Pending",
      "badge_class": "badge-warning",
      "is_terminal": false
    },
    "payment_status": {
      "value": 1,
      "name": "PENDING",
      "label": "Pending",
      "badge_class": "badge-warning"
    },
    "fulfillment_status": {
      "value": 1,
      "name": "UNFULFILLED",
      "label": "Unfulfilled",
      "badge_class": "badge-secondary"
    },
    "currency": "AED",
    "financials": {
      "subtotal": 300.0,
      "formatted_subtotal": "300.00 AED",
      "discount_total": 0.0,
      "formatted_discount_total": "0.00 AED",
      "shipping_total": 25.0,
      "formatted_shipping_total": "25.00 AED",
      "tax_total": 0.0,
      "formatted_tax_total": "0.00 AED",
      "grand_total": 325.0,
      "formatted_grand_total": "325.00 AED"
    },
    "coupon_code": null,
    "customer_note": "Please deliver after 2 PM",
    "items_count": 2,
    "is_cancellable": true,
    "is_paid": false,
    "payment_action": {
      "status": "requires_action",
      "provider": "ngenius",
      "reference": "0191837a-9774-7221-a7b5-6f913d8091ab",
      "redirection_url": "https://portal.sandbox.ngenius-payments.com/payment/ref-12345"
    },
    "shipping_address": {
      "id": 85,
      "address_line_1": "Downtown Dubai, Boulevard Plaza Tower 1",
      "city": "Dubai",
      "state": "Dubai",
      "postal_code": "00000",
      "country": "AE",
      "phone": "0501234567"
    },
    "billing_address": {
      "id": 85,
      "address_line_1": "Downtown Dubai, Boulevard Plaza Tower 1",
      "city": "Dubai",
      "state": "Dubai",
      "country": "AE"
    },
    "placed_at": "2026-09-25T18:20:00.000000Z"
  }
}
```

---

### B. 422 Validation Error (Missing Address)
When neither `shipping_address_id` nor `shipping_address` is provided:

```json
{
  "status": "error",
  "message": "Please provide an existing shipping_address_id or new shipping_address details.",
  "errors": {
    "shipping_address_id": [
      "Please provide an existing shipping_address_id or new shipping_address details."
    ],
    "shipping_address": [
      "Please provide a new shipping_address or an existing shipping_address_id."
    ]
  }
}
```

---

### C. 422 Validation Error (Missing Required Inline Address Fields)
When `shipping_address` is provided without `address_line_1` or `city`:

```json
{
  "status": "error",
  "message": "The street address (address_line_1) is required for the shipping address.",
  "errors": {
    "shipping_address.address_line_1": [
      "The street address (address_line_1) is required for the shipping address."
    ]
  }
}
```
