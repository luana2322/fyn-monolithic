--
-- PostgreSQL database dump
--

\restrict Z370XYJ6EW2UohNVkfwMcNxUyMDXAaMK6a2FgKw0p2tm7hpGPXAE13oWuwBI8yN

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    actor_id character varying(255),
    action character varying(255) NOT NULL,
    resource character varying(255) NOT NULL,
    payload jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: conversation_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversation_members (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    conversation_id uuid NOT NULL,
    member_id uuid NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.conversation_members OWNER TO postgres;

--
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    type character varying(255) NOT NULL,
    title character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- Name: file_storage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.file_storage (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    object_key character varying(255) NOT NULL,
    bucket character varying(255) NOT NULL,
    file_name character varying(255) NOT NULL,
    content_type character varying(255),
    size_bytes bigint NOT NULL,
    media_type character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.file_storage OWNER TO postgres;

--
-- Name: hashtags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hashtags (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tag character varying(255) NOT NULL,
    usage_count bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.hashtags OWNER TO postgres;

--
-- Name: message_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_media (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message_id uuid NOT NULL,
    object_key character varying(255) NOT NULL,
    media_type character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.message_media OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    conversation_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    content character varying(2048),
    status character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL,
    reaction character varying(10)
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    recipient_id uuid NOT NULL,
    type character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'UNREAD'::character varying NOT NULL,
    reference_id uuid,
    message character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: post_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_comments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    post_id uuid NOT NULL,
    author_id uuid NOT NULL,
    parent_comment_id uuid,
    content character varying(1024) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.post_comments OWNER TO postgres;

--
-- Name: post_hashtags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_hashtags (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    post_id uuid NOT NULL,
    hashtag_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.post_hashtags OWNER TO postgres;

--
-- Name: post_likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_likes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.post_likes OWNER TO postgres;

--
-- Name: post_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_media (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    post_id uuid NOT NULL,
    object_key character varying(255) NOT NULL,
    media_type character varying(255) NOT NULL,
    description character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.post_media OWNER TO postgres;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    author_id uuid NOT NULL,
    content character varying(2048),
    visibility character varying(255) NOT NULL,
    comment_count bigint DEFAULT 0 NOT NULL,
    like_count bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: user_followers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_followers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    follower_id uuid NOT NULL,
    muted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_followers OWNER TO postgres;

--
-- Name: user_login_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_login_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    ip_address character varying(255),
    user_agent character varying(255),
    success boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_login_history OWNER TO postgres;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    bio character varying(512),
    website character varying(255),
    location character varying(255),
    avatar_object_key character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_settings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    is_private boolean DEFAULT false NOT NULL,
    allow_messages boolean DEFAULT true NOT NULL,
    push_notifications boolean DEFAULT true NOT NULL,
    email_notifications boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_settings OWNER TO postgres;

--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    refresh_token character varying(512) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    ip_address character varying(255),
    user_agent character varying(255),
    revoked boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_tokens OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(255),
    username character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255),
    status character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, actor_id, action, resource, payload, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: conversation_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversation_members (id, conversation_id, member_id, is_admin, created_at, updated_at, deleted_at, version) FROM stdin;
eadb2384-372c-4869-b23a-513f865711e3	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3	f	2025-11-25 20:30:52.883714+00	2025-11-25 20:30:52.883714+00	\N	0
54189577-d8d2-4d20-9b6f-4dc0f3c46b67	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74	f	2025-11-25 20:30:52.884086+00	2025-11-25 20:30:52.884086+00	\N	0
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversations (id, type, title, created_at, updated_at, deleted_at, version) FROM stdin;
7defe4be-4f68-4331-aae1-d46bd214a9f3	DIRECT	\N	2025-11-25 20:30:52.881666+00	2025-11-25 20:30:52.881666+00	\N	0
\.


--
-- Data for Name: file_storage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.file_storage (id, object_key, bucket, file_name, content_type, size_bytes, media_type, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: hashtags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hashtags (id, tag, usage_count, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: message_media; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_media (id, message_id, object_key, media_type, created_at, updated_at, deleted_at, version) FROM stdin;
1c12711c-5cf1-4631-aee7-4a903f8b6ee4	bcbb3fd5-4a9d-4532-b54e-5c144b90887c	message-bcbb3fd5-4a9d-4532-b54e-5c144b90887c	FILE	2025-11-25 21:10:49.228484+00	2025-11-25 21:10:49.228484+00	\N	0
8cc4dda4-582a-40c1-9b56-788974625ad9	cb23ad9f-92cb-4393-b862-85fd0aac25f4	message-cb23ad9f-92cb-4393-b862-85fd0aac25f4	FILE	2025-11-25 21:11:42.537402+00	2025-11-25 21:11:42.537402+00	\N	0
98b1b80e-6cf0-4e32-a8f5-9b5a810d396a	863c7221-9975-45f2-bd67-babb89445766	message-863c7221-9975-45f2-bd67-babb89445766	FILE	2025-11-25 21:12:07.664016+00	2025-11-25 21:12:07.664016+00	\N	0
1dca00f9-f393-4568-80ac-63a79c0674ac	7e1a1bb2-c33e-4946-83b7-3680ffd77077	d8ed2e05-366a-4871-84b4-0d08864d6de3-scaled_IMG_1615.jpg	IMAGE	2025-11-25 21:24:29.952463+00	2025-11-25 21:24:29.952463+00	\N	0
20dc52c0-e4b7-494e-9b6d-47100975c3b0	13c051a2-c265-4b71-83ea-0073b476aebe	947d522a-a4f2-4824-b6fb-6f8e9ae736fc-scaled_REAL.png	IMAGE	2025-11-25 21:33:59.306501+00	2025-11-25 21:33:59.306501+00	\N	0
d246f819-ef13-447c-b6c4-d104de100d3a	006f5e0b-3e5a-44f2-bb1c-aef169069b2e	a9b03a3f-bd8d-4fef-b350-9db036689731-scaled_hme.jpg	IMAGE	2025-11-25 21:34:45.790777+00	2025-11-25 21:34:45.790777+00	\N	0
adc14a84-04a4-45d3-be7e-f8bde18f9cdc	c162e324-b6f7-44fb-ab5b-3695889cdfc0	83e10b23-7e57-447a-9f6c-c1382fece45e-scaled_462224309_546515287751812_8297374275899012310_n.jpg	IMAGE	2025-11-26 15:04:36.532578+00	2025-11-26 15:04:36.532578+00	\N	0
093dc5b2-f9f6-4b35-9fd4-a16b6161d3be	a7e25c3a-a11b-4004-8ea7-d711bdd943ef	e963ebe3-0bfa-49c1-88f7-c03f33cf5700-scaled_ChatGPT Image Apr 1, 2025, 09_29_20 PM.png	IMAGE	2025-11-26 15:12:10.000625+00	2025-11-26 15:12:10.000625+00	\N	0
74c7af32-2ade-4772-8b24-c3389ae976ce	52153dab-187f-4907-a9a2-1dead1a28ddd	0f5c0d14-1fd7-4a65-af82-392b5a692a56-scaled_GBpaqHEWkAAyk1J.jpg	IMAGE	2025-11-26 15:18:22.190793+00	2025-11-26 15:18:22.190793+00	\N	0
c0559ac0-488d-4062-9578-970e8de7ab75	8a506543-83ed-41de-a0a7-0a7c0bfc491f	68c079f1-6fff-4991-97cd-34d68ff2999f-scaled_IMG_1615.jpg	IMAGE	2025-11-26 15:25:39.512091+00	2025-11-26 15:25:39.512091+00	\N	0
a94f7206-6602-4a22-aee3-ea7337ad0065	c3301f33-ccb9-4ea4-b206-666c4a096a05	faf9efd0-556e-424c-98a7-2c5424556a9f-scaled_407110248_1486201505281829_3986978336564209646_n.jpg	IMAGE	2025-11-26 15:34:43.572332+00	2025-11-26 15:34:43.572332+00	\N	0
83f82ef7-a800-4038-91b6-0a14bfd97f87	e32ae869-5961-49d9-8a0e-7acfe4231f98	cf53db7b-d38c-4b89-a4ce-6cdb0cade2e1-scaled_Screenshot 2025-04-01 220716.png	IMAGE	2025-11-26 16:33:18.766988+00	2025-11-26 16:33:18.766988+00	\N	0
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, conversation_id, sender_id, content, status, created_at, updated_at, deleted_at, version, reaction) FROM stdin;
c210e028-27e2-4a0f-aa7a-d8704959f31b	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74	hallo	SENT	2025-11-25 20:30:57.369592+00	2025-11-25 20:30:57.369592+00	\N	0	\N
c640487a-fc2b-498b-aea0-6c2efd838da4	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3	ok bro	SENT	2025-11-25 20:31:20.594283+00	2025-11-25 20:31:20.594283+00	\N	0	\N
71ffa6d5-d2ea-44c3-ad9a-0196a9a4d81a	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74	ok	SENT	2025-11-25 20:31:28.416513+00	2025-11-25 20:31:28.416513+00	\N	0	\N
4936efbf-4389-470a-bf7b-56c1d302afe5	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3	hallo2	SENT	2025-11-25 20:55:36.288163+00	2025-11-25 20:55:36.288163+00	\N	0	\N
bcbb3fd5-4a9d-4532-b54e-5c144b90887c	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3		SENT	2025-11-25 21:10:49.148543+00	2025-11-25 21:10:49.148543+00	\N	0	\N
8b219a66-5c89-4b6f-b49a-399eb3c0088d	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3		SENT	2025-11-25 21:10:55.93252+00	2025-11-25 21:10:55.93252+00	\N	0	≡ƒÿé
cb23ad9f-92cb-4393-b862-85fd0aac25f4	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3		SENT	2025-11-25 21:11:42.485391+00	2025-11-25 21:11:42.485391+00	\N	0	\N
863c7221-9975-45f2-bd67-babb89445766	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3		SENT	2025-11-25 21:12:07.566298+00	2025-11-25 21:12:07.566298+00	\N	0	\N
7e1a1bb2-c33e-4946-83b7-3680ffd77077	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74		SENT	2025-11-25 21:24:29.901269+00	2025-11-25 21:24:29.901269+00	\N	0	\N
13c051a2-c265-4b71-83ea-0073b476aebe	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3		SENT	2025-11-25 21:33:59.18784+00	2025-11-25 21:33:59.18784+00	\N	0	\N
006f5e0b-3e5a-44f2-bb1c-aef169069b2e	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3		SENT	2025-11-25 21:34:45.689156+00	2025-11-25 21:34:45.689156+00	\N	0	\N
c162e324-b6f7-44fb-ab5b-3695889cdfc0	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74		SENT	2025-11-26 15:04:36.481509+00	2025-11-26 15:04:36.481509+00	\N	0	\N
a7e25c3a-a11b-4004-8ea7-d711bdd943ef	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3		SENT	2025-11-26 15:12:09.93321+00	2025-11-26 15:12:09.93321+00	\N	0	\N
52153dab-187f-4907-a9a2-1dead1a28ddd	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74		SENT	2025-11-26 15:18:22.152243+00	2025-11-26 15:18:22.152243+00	\N	0	\N
8a506543-83ed-41de-a0a7-0a7c0bfc491f	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74		SENT	2025-11-26 15:25:39.473677+00	2025-11-26 15:25:39.473677+00	\N	0	\N
0bfde597-ed1c-4244-a368-61697c64ae23	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74	a	SENT	2025-11-26 15:30:14.314893+00	2025-11-26 15:30:14.314893+00	\N	0	\N
c3301f33-ccb9-4ea4-b206-666c4a096a05	7defe4be-4f68-4331-aae1-d46bd214a9f3	8006e69c-c9cf-4594-b6d4-f80fba31bd74		SENT	2025-11-26 15:34:43.528887+00	2025-11-26 15:34:43.528887+00	\N	0	\N
e32ae869-5961-49d9-8a0e-7acfe4231f98	7defe4be-4f68-4331-aae1-d46bd214a9f3	9dc80086-f464-4bfa-b54e-8d4af2e873c3		SENT	2025-11-26 16:33:18.659217+00	2025-11-26 16:33:18.659217+00	\N	0	\N
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, recipient_id, type, status, reference_id, message, created_at, updated_at, deleted_at, version) FROM stdin;
efaa4920-05d8-40ee-aa66-a265b727132d	8006e69c-c9cf-4594-b6d4-f80fba31bd74	MESSAGE	READ	7defe4be-4f68-4331-aae1-d46bd214a9f3	Bß║ín c├│ tin nhß║»n mß╗¢i	2025-11-26 16:33:18.775189+00	2025-11-26 16:33:30.996398+00	\N	1
f8be253a-0e93-4e1d-b55e-38ef432792c2	8006e69c-c9cf-4594-b6d4-f80fba31bd74	LIKE	READ	e0971989-403c-4f2e-a7fc-8b2409251f74	loi_lon ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:30:39.387769+00	2025-11-26 16:33:34.746829+00	\N	1
c2d854e6-4a9e-4cee-9ae1-a2e0da03bafa	8006e69c-c9cf-4594-b6d4-f80fba31bd74	LIKE	READ	19df2cf5-c0cf-4953-932d-7566944d3a8e	loi_lon ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:17:12.054398+00	2025-11-26 16:33:35.338525+00	\N	1
165952db-37e5-4f1d-8454-4e8ddc5fd2cb	8006e69c-c9cf-4594-b6d4-f80fba31bd74	LIKE	UNREAD	e0971989-403c-4f2e-a7fc-8b2409251f74	loi_lon ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:49:39.242747+00	2025-11-26 16:49:39.242747+00	\N	0
fba67c51-f960-4187-9c1e-cb70a3ad8300	8006e69c-c9cf-4594-b6d4-f80fba31bd74	LIKE	UNREAD	e0971989-403c-4f2e-a7fc-8b2409251f74	loi_lon ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:49:57.089138+00	2025-11-26 16:49:57.089138+00	\N	0
ed562859-b472-413e-9681-a67f9be228f6	8006e69c-c9cf-4594-b6d4-f80fba31bd74	LIKE	UNREAD	31cc2707-f42a-41d6-b1b1-d71bf53df271	loi_lon ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:50:04.243042+00	2025-11-26 16:50:04.243042+00	\N	0
a23e1a90-2b15-4d8b-9a59-f930641774f7	9dc80086-f464-4bfa-b54e-8d4af2e873c3	LIKE	READ	2a556636-962b-4bf1-ba39-8ee08fd645c6	luan ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:50:33.18233+00	2025-11-26 16:51:24.488292+00	\N	1
ad51d59a-1f24-4b87-9bbf-9a0e173f49ec	9dc80086-f464-4bfa-b54e-8d4af2e873c3	LIKE	UNREAD	458da6cb-4814-4902-9b94-957a7656fda2	luan ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:51:32.637716+00	2025-11-26 16:51:32.637716+00	\N	0
101a1596-4aa1-4ced-8b90-148695b91f16	9dc80086-f464-4bfa-b54e-8d4af2e873c3	LIKE	UNREAD	383948dd-ea7a-4c36-a790-f09fbe04e830	luan ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:52:55.541774+00	2025-11-26 16:52:55.541774+00	\N	0
3dcb2685-818d-4676-8a43-4176563670cd	9dc80086-f464-4bfa-b54e-8d4af2e873c3	LIKE	UNREAD	383948dd-ea7a-4c36-a790-f09fbe04e830	luan ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 16:57:18.471045+00	2025-11-26 16:57:18.471045+00	\N	0
4c134a7f-b016-4060-b7ec-4103d0ceaacd	9dc80086-f464-4bfa-b54e-8d4af2e873c3	LIKE	UNREAD	780424ae-8f8f-4fa3-b029-f8cc1809128f	luan ─æ├ú th├¡ch b├ái viß║┐t cß╗ºa bß║ín	2025-11-26 20:08:31.109083+00	2025-11-26 20:08:31.109083+00	\N	0
\.


--
-- Data for Name: post_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_comments (id, post_id, author_id, parent_comment_id, content, created_at, updated_at, deleted_at, version) FROM stdin;
dac31ac4-b099-4221-8e69-0037171451f8	e0971989-403c-4f2e-a7fc-8b2409251f74	9dc80086-f464-4bfa-b54e-8d4af2e873c3	\N	hay qua from loi lon	2025-11-25 17:24:50.700537+00	2025-11-25 17:24:50.700537+00	\N	0
af81a94e-4e37-4e5a-bc54-5d4ee42aa35b	e0971989-403c-4f2e-a7fc-8b2409251f74	8006e69c-c9cf-4594-b6d4-f80fba31bd74	\N	├ósasasasa	2025-11-25 20:12:47.549934+00	2025-11-25 20:12:47.549934+00	\N	0
4133b003-a4fa-43fe-942e-a3d9ab58e11e	458da6cb-4814-4902-9b94-957a7656fda2	8006e69c-c9cf-4594-b6d4-f80fba31bd74	\N	dssdsdsdsds	2025-11-26 16:00:49.096575+00	2025-11-26 16:00:49.096575+00	\N	0
64c5e9fb-4c6d-46aa-a4d1-c60505e69303	383948dd-ea7a-4c36-a790-f09fbe04e830	8006e69c-c9cf-4594-b6d4-f80fba31bd74	\N	vai l\n loi lon	2025-11-26 16:53:15.070794+00	2025-11-26 16:53:15.070794+00	\N	0
60fd8457-decc-4df9-b590-63df429df2a5	383948dd-ea7a-4c36-a790-f09fbe04e830	8006e69c-c9cf-4594-b6d4-f80fba31bd74	\N	dsdsdsdsd	2025-11-26 16:57:14.38326+00	2025-11-26 16:57:14.38326+00	\N	0
\.


--
-- Data for Name: post_hashtags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_hashtags (id, post_id, hashtag_id, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: post_likes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_likes (id, post_id, user_id, created_at, updated_at, deleted_at, version) FROM stdin;
b3b5b083-150a-4cb7-a0f5-7b1d33594d13	458da6cb-4814-4902-9b94-957a7656fda2	9dc80086-f464-4bfa-b54e-8d4af2e873c3	2025-11-25 20:32:21.695272+00	2025-11-25 20:32:21.695272+00	\N	0
230f8cc1-442c-4a21-b5a6-9dabd6ae4ada	31cc2707-f42a-41d6-b1b1-d71bf53df271	8006e69c-c9cf-4594-b6d4-f80fba31bd74	2025-11-26 13:30:29.676858+00	2025-11-26 13:30:29.676858+00	\N	0
aad4f8cd-44e9-46b3-9b16-b7a588c97c43	95cbd50e-b4d9-4ade-94f7-33c00aa89ba3	8006e69c-c9cf-4594-b6d4-f80fba31bd74	2025-11-26 13:30:36.273643+00	2025-11-26 13:30:36.273643+00	\N	0
20e68ed1-fec4-4829-90cb-36045ff74303	19df2cf5-c0cf-4953-932d-7566944d3a8e	8006e69c-c9cf-4594-b6d4-f80fba31bd74	2025-11-26 15:25:25.10395+00	2025-11-26 15:25:25.10395+00	\N	0
0ed4f320-e9d5-40c5-91a2-f933f2a490fa	95cbd50e-b4d9-4ade-94f7-33c00aa89ba3	9dc80086-f464-4bfa-b54e-8d4af2e873c3	2025-11-26 16:00:36.122563+00	2025-11-26 16:00:36.122563+00	\N	0
cdb3b44e-4343-4a61-a6cd-013f83ed79db	19df2cf5-c0cf-4953-932d-7566944d3a8e	9dc80086-f464-4bfa-b54e-8d4af2e873c3	2025-11-26 16:17:12.050133+00	2025-11-26 16:17:12.050133+00	\N	0
74d0a687-b906-4649-bb4f-38c3473f0a06	e0971989-403c-4f2e-a7fc-8b2409251f74	9dc80086-f464-4bfa-b54e-8d4af2e873c3	2025-11-26 16:49:57.087722+00	2025-11-26 16:49:57.087722+00	\N	0
f5fbf62c-ab7a-4515-86ef-a952328fcad8	31cc2707-f42a-41d6-b1b1-d71bf53df271	9dc80086-f464-4bfa-b54e-8d4af2e873c3	2025-11-26 16:50:04.242714+00	2025-11-26 16:50:04.242714+00	\N	0
29e47265-992d-49f4-a515-5a08a3921991	458da6cb-4814-4902-9b94-957a7656fda2	8006e69c-c9cf-4594-b6d4-f80fba31bd74	2025-11-26 16:51:32.637352+00	2025-11-26 16:51:32.637352+00	\N	0
58589ac7-c2be-4cf4-b8d6-faf926a5227b	383948dd-ea7a-4c36-a790-f09fbe04e830	8006e69c-c9cf-4594-b6d4-f80fba31bd74	2025-11-26 16:57:18.470507+00	2025-11-26 16:57:18.470507+00	\N	0
5a7339ca-d4ac-4ef9-b599-cf97064e4822	780424ae-8f8f-4fa3-b029-f8cc1809128f	8006e69c-c9cf-4594-b6d4-f80fba31bd74	2025-11-26 20:08:31.107124+00	2025-11-26 20:08:31.107124+00	\N	0
\.


--
-- Data for Name: post_media; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_media (id, post_id, object_key, media_type, description, created_at, updated_at, deleted_at, version) FROM stdin;
2b1467d9-3fc8-483b-b747-33165dc222ca	e0971989-403c-4f2e-a7fc-8b2409251f74	cb2a6f79-6a28-4c67-b61c-2802d027a84b-khit.gif	IMAGE	\N	2025-11-25 16:47:24.117713+00	2025-11-25 16:47:24.117713+00	\N	0
dff6e17b-0a81-4c54-99b0-16080fef6c35	31cc2707-f42a-41d6-b1b1-d71bf53df271	b1bc8a74-668f-4923-8ad2-c5278239d1e5-IMG_1615.jpg	IMAGE	\N	2025-11-25 16:50:15.224889+00	2025-11-25 16:50:15.224889+00	\N	0
2939db9a-1bc8-41d2-bcfb-2a118d30e483	458da6cb-4814-4902-9b94-957a7656fda2	38d8d49c-c9a8-4615-a597-8232c6d915fa-images.png	IMAGE	\N	2025-11-25 20:13:36.072547+00	2025-11-25 20:13:36.072547+00	\N	0
91314da6-558e-45e3-87e3-abb590862979	95cbd50e-b4d9-4ade-94f7-33c00aa89ba3	38f04a28-ff65-434c-a884-e88d2f589418-ditmem.mp4	VIDEO	\N	2025-11-25 21:10:06.928416+00	2025-11-25 21:10:06.928416+00	\N	0
5b95b4a0-807c-4710-970e-6ad02b5836b0	2a556636-962b-4bf1-ba39-8ee08fd645c6	6efa2684-8e89-43c5-9b16-28bfe41a4783-Screenshot 2025-04-01 220716.png	IMAGE	\N	2025-11-25 21:36:31.736107+00	2025-11-25 21:36:31.736107+00	\N	0
951f5098-6786-4678-a14b-0a97e1e7699e	19df2cf5-c0cf-4953-932d-7566944d3a8e	6ef0ee60-ec21-400b-af38-9208eb10cd4f-409777106_372961378732019_6999831694106274015_n.jpg	IMAGE	\N	2025-11-26 15:19:45.620017+00	2025-11-26 15:19:45.620017+00	\N	0
b8023de5-acb8-4fd8-95e9-afdb3f0a118f	383948dd-ea7a-4c36-a790-f09fbe04e830	7da65667-3692-4557-9160-a5234eaa4f63-character_10.png	IMAGE	\N	2025-11-26 16:52:44.719403+00	2025-11-26 16:52:44.719403+00	\N	0
35cc50b8-f33e-4eb8-8d08-4e46509fec60	780424ae-8f8f-4fa3-b029-f8cc1809128f	e3f380d6-e8b8-48ff-bacf-9f87857b0443-01c40998066c70767e146a44fc5a62f9.mp4	VIDEO	\N	2025-11-26 20:05:36.779831+00	2025-11-26 20:05:36.779831+00	\N	0
8cb5f72d-26e0-4769-a06e-ac5f0cc936d2	780424ae-8f8f-4fa3-b029-f8cc1809128f	ebcd8256-625c-4f4e-aeb3-15e2fa06ffbc-661b62a178009dd049627053ef5c891c.mp4	VIDEO	\N	2025-11-26 20:05:36.852999+00	2025-11-26 20:05:36.852999+00	\N	0
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (id, author_id, content, visibility, comment_count, like_count, created_at, updated_at, deleted_at, version) FROM stdin;
95cbd50e-b4d9-4ade-94f7-33c00aa89ba3	8006e69c-c9cf-4594-b6d4-f80fba31bd74	vide hay	PUBLIC	0	2	2025-11-25 21:10:06.598342+00	2025-11-26 16:00:36.128057+00	\N	2
19df2cf5-c0cf-4953-932d-7566944d3a8e	8006e69c-c9cf-4594-b6d4-f80fba31bd74	con b├▓	PUBLIC	0	2	2025-11-26 15:19:45.555739+00	2025-11-26 16:17:12.055726+00	\N	2
e0971989-403c-4f2e-a7fc-8b2409251f74	8006e69c-c9cf-4594-b6d4-f80fba31bd74	khß╗ë\nhahahah	PUBLIC	2	1	2025-11-25 16:47:23.806998+00	2025-11-26 16:49:57.090273+00	\N	17
31cc2707-f42a-41d6-b1b1-d71bf53df271	8006e69c-c9cf-4594-b6d4-f80fba31bd74	abybara	PUBLIC	0	2	2025-11-25 16:50:15.145469+00	2025-11-26 16:50:04.243539+00	\N	8
458da6cb-4814-4902-9b94-957a7656fda2	9dc80086-f464-4bfa-b54e-8d4af2e873c3	metamarrk	PUBLIC	1	2	2025-11-25 20:13:35.996544+00	2025-11-26 16:51:32.638104+00	\N	7
2a556636-962b-4bf1-ba39-8ee08fd645c6	9dc80086-f464-4bfa-b54e-8d4af2e873c3	zomnie	PUBLIC	0	0	2025-11-25 21:36:31.635495+00	2025-11-26 16:57:05.847106+00	\N	4
383948dd-ea7a-4c36-a790-f09fbe04e830	9dc80086-f464-4bfa-b54e-8d4af2e873c3	loi lon	PUBLIC	2	1	2025-11-26 16:52:44.632537+00	2025-11-26 16:57:18.47153+00	\N	5
780424ae-8f8f-4fa3-b029-f8cc1809128f	9dc80086-f464-4bfa-b54e-8d4af2e873c3	rap	PUBLIC	0	1	2025-11-26 20:05:36.12458+00	2025-11-26 20:08:31.111427+00	\N	1
\.


--
-- Data for Name: user_followers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_followers (id, user_id, follower_id, muted, created_at, updated_at, deleted_at, version) FROM stdin;
055c15dd-4686-4db3-9ec3-5c0dfc3231f7	9dc80086-f464-4bfa-b54e-8d4af2e873c3	8006e69c-c9cf-4594-b6d4-f80fba31bd74	f	2025-11-25 20:21:06.915464+00	2025-11-25 20:21:06.915464+00	\N	0
\.


--
-- Data for Name: user_login_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_login_history (id, user_id, ip_address, user_agent, success, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles (id, user_id, bio, website, location, avatar_object_key, created_at, updated_at, deleted_at, version) FROM stdin;
382199be-597e-4705-9d47-1227f286f3b7	8006e69c-c9cf-4594-b6d4-f80fba31bd74	\N	\N	\N	f9f90715-5b47-44df-8dd0-a10d54799e16-scaled_IMG_1615.jpg	2025-11-25 16:46:58.114797+00	2025-11-25 20:09:18.226652+00	\N	2
302f2f98-2402-4417-86c0-f497eccf7aca	9dc80086-f464-4bfa-b54e-8d4af2e873c3	\N	\N	\N	311f6248-58aa-4510-964d-ffe8dca9da86-scaled_REAL.png	2025-11-25 17:24:33.658378+00	2025-11-25 20:14:13.728354+00	\N	1
\.


--
-- Data for Name: user_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_settings (id, user_id, is_private, allow_messages, push_notifications, email_notifications, created_at, updated_at, deleted_at, version) FROM stdin;
088d1e81-1754-42a7-b6f2-cce0c86b0005	8006e69c-c9cf-4594-b6d4-f80fba31bd74	f	t	t	t	2025-11-25 16:46:58.118195+00	2025-11-25 16:46:58.118195+00	\N	0
1996d689-4363-416c-94a3-521870a15c40	9dc80086-f464-4bfa-b54e-8d4af2e873c3	f	t	t	t	2025-11-25 17:24:33.659073+00	2025-11-25 17:24:33.659073+00	\N	0
\.


--
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tokens (id, user_id, refresh_token, expires_at, ip_address, user_agent, revoked, created_at, updated_at, deleted_at, version) FROM stdin;
5f9d317b-45a1-44e9-be0b-5680f3355c9f	8006e69c-c9cf-4594-b6d4-f80fba31bd74	9650ab11-9e67-4123-bc91-c195a486f0ae	2025-12-02 16:46:58.160503+00	\N	\N	f	2025-11-25 16:46:58.165569+00	2025-11-25 16:46:58.165569+00	\N	0
a9de644b-8224-4d92-8d7b-f7e6906bfc36	9dc80086-f464-4bfa-b54e-8d4af2e873c3	98021c9d-d66c-43c9-a88c-c49cdfeafc6e	2025-12-02 17:24:33.663394+00	\N	\N	f	2025-11-25 17:24:33.664937+00	2025-11-25 17:24:33.664937+00	\N	0
d42bcfa3-c668-4c5d-9b4e-a0598bce324f	8006e69c-c9cf-4594-b6d4-f80fba31bd74	158ca3cc-b44a-45c9-9bd4-3420ffec1d3b	2025-12-03 16:49:21.257472+00	\N	\N	f	2025-11-26 16:49:21.26934+00	2025-11-26 16:49:21.26934+00	\N	0
83f8156b-b372-485b-b6c1-2bf559075039	9dc80086-f464-4bfa-b54e-8d4af2e873c3	4a890dcb-402d-4af8-b334-0025202bb562	2025-12-03 20:04:59.4898+00	\N	\N	f	2025-11-26 20:04:59.510724+00	2025-11-26 20:04:59.510724+00	\N	0
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, phone, username, password_hash, full_name, status, created_at, updated_at, deleted_at, version) FROM stdin;
8006e69c-c9cf-4594-b6d4-f80fba31bd74	luan@gmail.com	+84982323232	luan	$2a$10$ojsmJRdrR..ppZGPbvD5yerTv2xVdzTba5OUfPR1xiCKcSyKLcm3K	luan	ACTIVE	2025-11-25 16:46:58.084774+00	2025-11-25 16:46:58.084774+00	\N	0
9dc80086-f464-4bfa-b54e-8d4af2e873c3	alo@gmail.com	+84363636363636	loi_lon	$2a$10$q2bU5Qmhozql0IXjnj9Z2e77/6QZ9CfBqYbRsLUptBdcx847eHDtK	LOI LON	ACTIVE	2025-11-25 17:24:33.65677+00	2025-11-25 17:24:33.65677+00	\N	0
\.


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: conversation_members conversation_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT conversation_members_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: file_storage file_storage_object_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_storage
    ADD CONSTRAINT file_storage_object_key_key UNIQUE (object_key);


--
-- Name: file_storage file_storage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_storage
    ADD CONSTRAINT file_storage_pkey PRIMARY KEY (id);


--
-- Name: hashtags hashtags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hashtags
    ADD CONSTRAINT hashtags_pkey PRIMARY KEY (id);


--
-- Name: hashtags hashtags_tag_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hashtags
    ADD CONSTRAINT hashtags_tag_key UNIQUE (tag);


--
-- Name: message_media message_media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_media
    ADD CONSTRAINT message_media_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: post_comments post_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_pkey PRIMARY KEY (id);


--
-- Name: post_hashtags post_hashtags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_hashtags
    ADD CONSTRAINT post_hashtags_pkey PRIMARY KEY (id);


--
-- Name: post_likes post_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_pkey PRIMARY KEY (id);


--
-- Name: post_media post_media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_media
    ADD CONSTRAINT post_media_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: user_followers uq_follower; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_followers
    ADD CONSTRAINT uq_follower UNIQUE (user_id, follower_id);


--
-- Name: conversation_members uq_member; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT uq_member UNIQUE (conversation_id, member_id);


--
-- Name: post_hashtags uq_post_hashtag; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_hashtags
    ADD CONSTRAINT uq_post_hashtag UNIQUE (post_id, hashtag_id);


--
-- Name: post_likes uq_post_like; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT uq_post_like UNIQUE (post_id, user_id);


--
-- Name: user_followers user_followers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_followers
    ADD CONSTRAINT user_followers_pkey PRIMARY KEY (id);


--
-- Name: user_login_history user_login_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login_history
    ADD CONSTRAINT user_login_history_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_key UNIQUE (user_id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);


--
-- Name: user_settings user_settings_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_user_id_key UNIQUE (user_id);


--
-- Name: user_tokens user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);


--
-- Name: user_tokens user_tokens_refresh_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_refresh_token_key UNIQUE (refresh_token);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: conversation_members conversation_members_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT conversation_members_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: conversation_members conversation_members_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT conversation_members_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: message_media message_media_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_media
    ADD CONSTRAINT message_media_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id) ON DELETE CASCADE;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: post_comments post_comments_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: post_comments post_comments_parent_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.post_comments(id) ON DELETE CASCADE;


--
-- Name: post_comments post_comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_hashtags post_hashtags_hashtag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_hashtags
    ADD CONSTRAINT post_hashtags_hashtag_id_fkey FOREIGN KEY (hashtag_id) REFERENCES public.hashtags(id) ON DELETE CASCADE;


--
-- Name: post_hashtags post_hashtags_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_hashtags
    ADD CONSTRAINT post_hashtags_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_likes post_likes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: post_likes post_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: post_media post_media_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_media
    ADD CONSTRAINT post_media_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: posts posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_followers user_followers_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_followers
    ADD CONSTRAINT user_followers_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_followers user_followers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_followers
    ADD CONSTRAINT user_followers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_login_history user_login_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login_history
    ADD CONSTRAINT user_login_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_settings user_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_tokens user_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Z370XYJ6EW2UohNVkfwMcNxUyMDXAaMK6a2FgKw0p2tm7hpGPXAE13oWuwBI8yN

