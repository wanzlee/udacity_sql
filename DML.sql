--1. users table--
INSERT INTO "users" ("username")
SELECT DISTINCT "username" FROM "bad_posts"
UNION
SELECT DISTINCT "username" FROM "bad_comments"
UNION
SELECT DISTINCT regexp_split_to_table(upvotes,',') FROM "bad_posts"
UNION
SELECT DISTINCT regexp_split_to_table(downvotes,',') FROM "bad_posts";

--2. topics table--
INSERT INTO "topics" ("name")
SELECT DISTINCT "topic" FROM "bad_posts";

--3. posts table--
INSERT INTO "posts" ("title", "url", "text_content","topic_id","user_id")
SELECT left("title",100), "url", "text_content", "topics"."id", "users"."id"
FROM "bad_posts"
JOIN "topics"
ON "topics"."name" = "bad_posts"."topic"
JOIN "users"
ON "users"."username" = "bad_posts"."username";

--4. comments table--
INSERT INTO "comments" ("text_content","post_id","user_id")
SELECT "bad_comments"."text_content", "posts"."id", "users"."id"
FROM "bad_comments"
JOIN "posts"
ON "bad_comments"."post_id" = "posts"."id"
JOIN "users"
ON "bad_comments"."username" = "users"."username";

--5. votes table--
INSERT INTO "votes" ("vote","user_id","post_id")
SELECT 1, "users"."id", "t1"."id"
FROM "users"
JOIN (SELECT "id",regexp_split_to_table(upvotes,',') AS "username"
      FROM "bad_posts") AS "t1"
ON "t1"."username" = "users"."username";

INSERT INTO "votes" ("vote","user_id","post_id")
SELECT -1, "users"."id", "t1"."id"
FROM "users"
JOIN (SELECT "id",regexp_split_to_table(downvotes,',') AS "username" 
      FROM "bad_posts") AS "t1"
ON "t1"."username" = "users"."username";
