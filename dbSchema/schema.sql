USE "STOREFRONT";
DROP TABLE IF EXISTS "APP_INSTANCE" CASCADE;
CREATE TABLE "APP_INSTANCE" ("UUID" VARCHAR(36) NOT NULL, "CPU_UTILIZATION" INTEGER NOT NULL, "CURRENCY" VARCHAR(255) NOT NULL, "DATE_STARTED" BIGINT NOT NULL, "FIRST_HEARTBEAT" TIMESTAMP(6) NOT NULL, "LAST_API_ACTIVITY" TIMESTAMP(6) NOT NULL, "LAST_HEARTBEAT" TIMESTAMP(6) NOT NULL, "NODE_ID" INTEGER NOT NULL, "REGION" VARCHAR(255) NOT NULL, "STOP_USERS_WHEN_IDLE" BOOLEAN NOT NULL, "URL" VARCHAR(255) NOT NULL);
ALTER TABLE "APP_INSTANCE" ADD PRIMARY KEY ("UUID");
CREATE INDEX "IDX_App_instance_idx_app_instance_last_heartbeat" ON "APP_INSTANCE" ("LAST_HEARTBEAT");
DROP TABLE IF EXISTS "CART_SELECTION" CASCADE;
CREATE TABLE "CART_SELECTION" ("DATE_ADDED" TIMESTAMP(6) NOT NULL, "DATE_MODIFIED" TIMESTAMP(6) NOT NULL, "QUANTITY" INTEGER NOT NULL, "REGION" VARCHAR(255) NOT NULL, "UNIT_PRICE" NUMERIC(8,2) NOT NULL, "CUSTOMER_ID" BIGINT NOT NULL, "PRODUCT_ID" BIGINT NOT NULL);
ALTER TABLE "CART_SELECTION" ADD PRIMARY KEY ("CUSTOMER_ID", "PRODUCT_ID");
CREATE INDEX "IDX_Cart_selection_idx_cart_selection_date_modified" ON "CART_SELECTION" ("DATE_MODIFIED");
DROP TABLE IF EXISTS "CUSTOMER" CASCADE;
DROP SEQUENCE IF EXISTS "Customer_customer$identity_sequence";
CREATE SEQUENCE "Customer_customer$identity_sequence";
CREATE TABLE "CUSTOMER" ("ID" BIGINT GENERATED BY DEFAULT AS IDENTITY("Customer_customer$identity_sequence") NOT NULL, "DATE_ADDED" TIMESTAMP(6) NOT NULL, "DATE_LAST_ACTIVE" TIMESTAMP(6) NOT NULL, "EMAIL_ADDRESS" VARCHAR(255), "REGION" VARCHAR(255) NOT NULL, "WORKLOAD" VARCHAR(255));
ALTER TABLE "CUSTOMER" ADD PRIMARY KEY ("ID");
CREATE INDEX "IDX_Customer_idx_customer_date_last_active" ON "CUSTOMER" ("DATE_LAST_ACTIVE");
DROP TABLE IF EXISTS "PRODUCT" CASCADE;
DROP SEQUENCE IF EXISTS "Product_product$identity_sequence";
CREATE SEQUENCE "Product_product$identity_sequence";
CREATE TABLE "PRODUCT" ("ID" BIGINT GENERATED BY DEFAULT AS IDENTITY("Product_product$identity_sequence") NOT NULL, "DATE_ADDED" TIMESTAMP(6) NOT NULL, "DATE_MODIFIED" TIMESTAMP(6) NOT NULL, "DESCRIPTION" VARCHAR(1000) NOT NULL, "IMAGE_URL" VARCHAR(255), "NAME" VARCHAR(255) NOT NULL, "PURCHASE_COUNT" BIGINT NOT NULL, "RATING" FLOAT, "REVIEW_COUNT" INTEGER NOT NULL, "UNIT_PRICE" NUMERIC(8,2) NOT NULL);
ALTER TABLE "PRODUCT" ADD PRIMARY KEY ("ID");
DROP TABLE IF EXISTS "PRODUCT_CATEGORY" CASCADE;
CREATE TABLE "PRODUCT_CATEGORY" ("PRODUCT_ID" BIGINT NOT NULL, "CATEGORY" VARCHAR(255) NOT NULL);
ALTER TABLE "PRODUCT_CATEGORY" ADD PRIMARY KEY ("PRODUCT_ID", "CATEGORY");
CREATE INDEX "IDX_Product_category_uk_cu9i33d6dbyo4s8jmfepoyn59" ON "PRODUCT_CATEGORY" ("PRODUCT_ID");
CREATE INDEX "IDX_Product_category_uk_an7o8wbrp83d9gh17earbgbyn" ON "PRODUCT_CATEGORY" ("CATEGORY");
ALTER TABLE "PRODUCT_CATEGORY" ADD FOREIGN KEY ("PRODUCT_ID") REFERENCES "STOREFRONT"."PRODUCT" ("ID");
DROP TABLE IF EXISTS "PRODUCT_REVIEW" CASCADE;
DROP SEQUENCE IF EXISTS "Product_review_product_review$identity_sequence";
CREATE SEQUENCE "Product_review_product_review$identity_sequence";
CREATE TABLE "PRODUCT_REVIEW" ("ID" BIGINT GENERATED BY DEFAULT AS IDENTITY("Product_review_product_review$identity_sequence") NOT NULL, "COMMENTS" VARCHAR(255), "DATE_ADDED" TIMESTAMP(6) NOT NULL, "RATING" INTEGER NOT NULL, "REGION" VARCHAR(255) NOT NULL, "TITLE" VARCHAR(255) NOT NULL, "CUSTOMER_ID" BIGINT NOT NULL, "PRODUCT_ID" BIGINT NOT NULL);
ALTER TABLE "PRODUCT_REVIEW" ADD PRIMARY KEY ("ID");
CREATE INDEX "IDX_Product_review_idx_product_review_product" ON "PRODUCT_REVIEW" ("PRODUCT_ID");
CREATE INDEX "IDX_Product_review_idx_product_review_date_added" ON "PRODUCT_REVIEW" ("DATE_ADDED");
ALTER TABLE "PRODUCT_REVIEW" ADD FOREIGN KEY ("CUSTOMER_ID") REFERENCES "STOREFRONT"."CUSTOMER" ("ID");
ALTER TABLE "PRODUCT_REVIEW" ADD FOREIGN KEY ("PRODUCT_ID") REFERENCES "STOREFRONT"."PRODUCT" ("ID");
DROP TABLE IF EXISTS "PURCHASE" CASCADE;
DROP SEQUENCE IF EXISTS "Purchase_purchase$identity_sequence";
CREATE SEQUENCE "Purchase_purchase$identity_sequence";
CREATE TABLE "PURCHASE" ("ID" BIGINT GENERATED BY DEFAULT AS IDENTITY("Purchase_purchase$identity_sequence") NOT NULL, "DATE_PURCHASED" TIMESTAMP(6) NOT NULL, "REGION" VARCHAR(255) NOT NULL, "CUSTOMER_ID" BIGINT NOT NULL);
ALTER TABLE "PURCHASE" ADD PRIMARY KEY ("ID");
CREATE INDEX "IDX_Purchase_idx_purchase_date_purchased" ON "PURCHASE" ("DATE_PURCHASED");
ALTER TABLE "PURCHASE" ADD FOREIGN KEY ("CUSTOMER_ID") REFERENCES "STOREFRONT"."CUSTOMER" ("ID");
DROP TABLE IF EXISTS "PURCHASE_SELECTION" CASCADE;
CREATE TABLE "PURCHASE_SELECTION" ("DATE_ADDED" TIMESTAMP(6) NOT NULL, "DATE_MODIFIED" TIMESTAMP(6) NOT NULL, "QUANTITY" INTEGER NOT NULL, "REGION" VARCHAR(255) NOT NULL, "UNIT_PRICE" NUMERIC(8,2) NOT NULL, "PURCHASE_ID" BIGINT NOT NULL, "PRODUCT_ID" BIGINT NOT NULL);
ALTER TABLE "PURCHASE_SELECTION" ADD PRIMARY KEY ("PURCHASE_ID", "PRODUCT_ID");
CREATE INDEX "IDX_Purchase_selection_idx_product_selection_date_modified" ON "PURCHASE_SELECTION" ("DATE_MODIFIED");
ALTER TABLE "PURCHASE_SELECTION" ADD FOREIGN KEY ("PRODUCT_ID") REFERENCES "STOREFRONT"."PRODUCT" ("ID");
ALTER TABLE "PURCHASE_SELECTION" ADD FOREIGN KEY ("PURCHASE_ID") REFERENCES "STOREFRONT"."PURCHASE" ("ID");
ALTER TABLE "CART_SELECTION" ADD FOREIGN KEY ("CUSTOMER_ID") REFERENCES "STOREFRONT"."CUSTOMER" ("ID");
ALTER TABLE "CART_SELECTION" ADD FOREIGN KEY ("PRODUCT_ID") REFERENCES "STOREFRONT"."PRODUCT" ("ID");
