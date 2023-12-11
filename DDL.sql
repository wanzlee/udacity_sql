--1. users table--
CREATE TABLE "users" (
	"id" SERIAL PRIMARY KEY,
	"username" VARCHAR(25) UNIQUE NOT NULL CHECK (LENGTH(TRIM("username")) > 0 ),
	"last_logged_in" TIMESTAMP
);

CREATE INDEX "username_search" ON "users" ("username");

--2. topics table--
CREATE TABLE "topics" (
	"id" SERIAL PRIMARY KEY,
	"name" VARCHAR(30) UNIQUE NOT NULL CHECK (LENGTH(TRIM("name")) > 0 ),
	"description" VARCHAR(500)
);

CREATE INDEX "topic_name_search" ON "topics" ("name");

--3. posts table--
CREATE TABLE "posts" (
	"id" SERIAL PRIMARY KEY,
	"title" VARCHAR(100) NOT NULL CHECK (LENGTH(TRIM("title")) > 0 ),
	"url" VARCHAR,
	"text_content" VARCHAR,
	"topic_id" INTEGER NOT NULL REFERENCES "topics" ("id") ON DELETE CASCADE,
	"user_id" INTEGER REFERENCES "users" ("id") ON DELETE SET NULL,
	"created_at" TIMESTAMP
);

ALTER TABLE "posts" ADD CONSTRAINT "not_both" CHECK(
		( ("url") IS NULL AND ("text_content") IS NOT NULL )
	OR
		( ("url") IS NOT NULL AND ("text_content") IS NULL )
);

CREATE INDEX "url_search" ON "posts" ("url");
CREATE INDEX "latest_user_post_search" ON "posts" ("user_id", "created_at");
CREATE INDEX "topic_post_search" ON "posts" ("topic_id", "created_at");

--4. comments table--
CREATE TABLE "comments" (
	"id" SERIAL PRIMARY KEY,
  "text_content" VARCHAR NOT NULL CHECK (LENGTH(TRIM("text_content")) > 0 ),
  "post_id" INTEGER NOT NULL REFERENCES "posts" ("id") ON DELETE CASCADE,
	"user_id" INTEGER REFERENCES "users" ("id") ON DELETE SET NULL,
	"parent_comment_id" INTEGER,
	"created_at" TIMESTAMP
);

CREATE INDEX "parent_comment_search" ON "comments" ("parent_comment_id");
CREATE INDEX "latest_user_comment_search" ON "comments" ("user_id", "created_at");

ALTER TABLE "comments" ADD CONSTRAINT "comment_thread" FOREIGN KEY ("parent_comment_id" ) REFERENCES "comments" ("id") ON DELETE CASCADE;

--5. votes table--
CREATE TABLE "votes" (
	"id" SERIAL PRIMARY KEY,
	"user_id" INTEGER REFERENCES "users" ("id") ON DELETE SET NULL,
	"post_id" INTEGER NOT NULL REFERENCES "posts" ("id") ON DELETE CASCADE,
	"vote" SMALLINT CHECK (("vote" = 1) OR ("vote" = -1))
);

ALTER TABLE "votes" ADD CONSTRAINT "vote_once" UNIQUE("user_id", "post_id");

CREATE INDEX "vote_compute" ON "votes" ("post_id", "vote");
