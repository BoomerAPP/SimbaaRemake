# SIMBAA Fresh v15

- Fixed public storefront settings reader to use the actual `store_settings(key, value)` JSONB schema; no request for non-existent `id` or flat settings columns.
- Added editable WhatsApp community group and channel settings, prefilled with the two links supplied by the owner. Homepage community notice and footer links are updated after settings load.
- Added distinct WhatsApp consultation templates for homepage, help, about, catalog, promotions, floating contact, and category-aware product requests. Product messages include WhatsApp bold headings, emoji, separators, configuration, product details, and confirmation checklist.
- Added automatic editable configuration suggestions when creating a product, based on its selected category.
- Added `show_on_home` control and public homepage selection for active Best Seller / selected products.
- Improved admin product cards with larger horizontal imagery, clearer prices, and visible edit/activate/deactivate/delete actions.
- Improved promotion admin list to display all records with active, scheduled, expired, and inactive states; newest entries load first.
- Added read-only SQL diagnostics for promotion visibility, homepage flags, banner links, settings, review schema, and Storage bucket.
- Improved product detail hierarchy and portfolio typography.
- Clarified banner behavior: the three existing slots are updated in place; CTA target links control whether a banner opens services, promo, or information pages. Updating a banner does not delete products or other banner slots.
- Public promotions remain on the dedicated Promo page and are not added to the homepage.
- Fixed username password-grant request to send the publishable API key only in the `apikey` header and verify the returned Auth UID matches the Owner UID.

## Database
No new v15 schema migration is required. v15 uses columns confirmed in the user's schema. Continue to use the already prepared v14 migration only if it has not yet been applied; do not run the incompatible v12 settings migration.
