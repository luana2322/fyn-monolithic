--
-- PostgreSQL database dump
--

\restrict fUWe3q3JBeAs0SkuqITOn9M0d8BUN6sKdcMZkcR4SeN8BFb6SNMIwXab35d0esz

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
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO postgres;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO postgres;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: activity_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.activity_type AS ENUM (
    'coffee',
    'breakfast',
    'brunch',
    'lunch',
    'dinner',
    'drinks',
    'sports',
    'gym',
    'hiking',
    'cycling',
    'running',
    'swimming',
    'movie',
    'concert',
    'theater',
    'museum',
    'exhibition',
    'study',
    'tutoring',
    'workshop',
    'seminar',
    'conference',
    'gaming',
    'board_games',
    'esports',
    'travel',
    'road_trip',
    'camping',
    'networking',
    'meetup',
    'coworking',
    'volunteer',
    'charity',
    'party',
    'celebration',
    'other'
);


ALTER TYPE public.activity_type OWNER TO postgres;

--
-- Name: connection_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.connection_status AS ENUM (
    'pending',
    'accepted',
    'rejected',
    'blocked',
    'expired'
);


ALTER TYPE public.connection_status OWNER TO postgres;

--
-- Name: connection_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.connection_type AS ENUM (
    'friend',
    'romantic',
    'activity_partner',
    'study_partner',
    'tutor',
    'mentor',
    'mentee',
    'colleague',
    'business',
    'roommate',
    'acquaintance',
    'service_provider'
);


ALTER TYPE public.connection_type OWNER TO postgres;

--
-- Name: event_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.event_status AS ENUM (
    'draft',
    'open',
    'waiting_list',
    'full',
    'ongoing',
    'completed',
    'cancelled',
    'expired'
);


ALTER TYPE public.event_status OWNER TO postgres;

--
-- Name: event_visibility; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.event_visibility AS ENUM (
    'public',
    'friends_only',
    'group_only',
    'invite_only'
);


ALTER TYPE public.event_visibility OWNER TO postgres;

--
-- Name: group_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.group_type AS ENUM (
    'sport',
    'study',
    'hangout',
    'gaming',
    'travel',
    'hobby',
    'professional',
    'support',
    'community',
    'other'
);


ALTER TYPE public.group_type OWNER TO postgres;

--
-- Name: group_visibility; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.group_visibility AS ENUM (
    'public',
    'private',
    'event_based',
    'invite_only'
);


ALTER TYPE public.group_visibility OWNER TO postgres;

--
-- Name: member_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.member_role AS ENUM (
    'owner',
    'admin',
    'moderator',
    'member',
    'pending'
);


ALTER TYPE public.member_role OWNER TO postgres;

--
-- Name: participant_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.participant_status AS ENUM (
    'pending',
    'approved',
    'rejected',
    'waitlisted',
    'cancelled',
    'attended',
    'no_show'
);


ALTER TYPE public.participant_status OWNER TO postgres;

--
-- Name: recurrence_frequency; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.recurrence_frequency AS ENUM (
    'daily',
    'weekly',
    'biweekly',
    'monthly',
    'custom'
);


ALTER TYPE public.recurrence_frequency OWNER TO postgres;

--
-- Name: report_reason; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.report_reason AS ENUM (
    'inappropriate_content',
    'harassment',
    'spam',
    'fake_profile',
    'scam',
    'violence',
    'hate_speech',
    'impersonation',
    'underage',
    'other'
);


ALTER TYPE public.report_reason OWNER TO postgres;

--
-- Name: report_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.report_status AS ENUM (
    'pending',
    'reviewing',
    'resolved',
    'dismissed',
    'escalated'
);


ALTER TYPE public.report_status OWNER TO postgres;

--
-- Name: review_context; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.review_context AS ENUM (
    'event',
    'connection',
    'group',
    'service'
);


ALTER TYPE public.review_context OWNER TO postgres;

--
-- Name: verification_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.verification_type AS ENUM (
    'phone',
    'email',
    'government_id',
    'social',
    'photo'
);


ALTER TYPE public.verification_type OWNER TO postgres;

--
-- Name: calculate_distance_km(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_distance_km(lat1 numeric, lng1 numeric, lat2 numeric, lng2 numeric) RETURNS numeric
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN ST_DistanceSphere(
        ST_SetSRID(ST_MakePoint(lng1, lat1), 4326),
        ST_SetSRID(ST_MakePoint(lng2, lat2), 4326)
    ) / 1000.0;
END;
$$;


ALTER FUNCTION public.calculate_distance_km(lat1 numeric, lng1 numeric, lat2 numeric, lng2 numeric) OWNER TO postgres;

--
-- Name: update_event_participant_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_event_participant_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE events
    SET 
        current_participants = (
            SELECT COUNT(*)
            FROM event_participants
            WHERE event_id = COALESCE(NEW.event_id, OLD.event_id) AND status = 'approved'
        ),
        waitlist_count = (
            SELECT COUNT(*)
            FROM event_participants
            WHERE event_id = COALESCE(NEW.event_id, OLD.event_id) AND status = 'waitlisted'
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.event_id, OLD.event_id);
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION public.update_event_participant_count() OWNER TO postgres;

--
-- Name: update_user_reputation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_user_reputation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_profiles_extended
    SET 
        reputation_score = (
            SELECT COALESCE(AVG(rating), 5.0)
            FROM reviews
            WHERE reviewed_user_id = NEW.reviewed_user_id AND NOT is_hidden
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM reviews
            WHERE reviewed_user_id = NEW.reviewed_user_id AND NOT is_hidden
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = NEW.reviewed_user_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_user_reputation() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_suggestions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ai_suggestions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    suggestion_type character varying(50),
    target_id uuid,
    content text,
    confidence_score numeric(5,2),
    is_shown boolean DEFAULT false,
    is_used boolean DEFAULT false,
    user_feedback character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone
);


ALTER TABLE public.ai_suggestions OWNER TO postgres;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    action character varying(255) NOT NULL,
    actor_id character varying(255),
    payload jsonb,
    resource character varying(255) NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    room_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    content text,
    message_type character varying(20) DEFAULT 'text'::character varying,
    media_urls text[],
    media_thumbnails text[],
    location_lat numeric(10,8),
    location_lng numeric(11,8),
    location_name character varying(200),
    reply_to_id uuid,
    thread_id uuid,
    reactions jsonb,
    is_edited boolean DEFAULT false,
    edited_at timestamp without time zone,
    is_deleted boolean DEFAULT false,
    deleted_at timestamp without time zone,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: chat_room_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_room_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    room_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role character varying(20) DEFAULT 'member'::character varying,
    is_muted boolean DEFAULT false,
    muted_until timestamp without time zone,
    notifications_enabled boolean DEFAULT true,
    last_read_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_read_message_id uuid,
    unread_count integer DEFAULT 0,
    joined_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chat_room_members OWNER TO postgres;

--
-- Name: chat_rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_rooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    room_type character varying(20) NOT NULL,
    name character varying(100),
    description text,
    avatar_url character varying(500),
    event_id uuid,
    group_id uuid,
    is_active boolean DEFAULT true,
    is_muted_all boolean DEFAULT false,
    slow_mode_seconds integer,
    message_count integer DEFAULT 0,
    member_count integer DEFAULT 0,
    created_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chat_rooms OWNER TO postgres;

--
-- Name: connection_type_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.connection_type_metadata (
    connection_type public.connection_type NOT NULL,
    requires_mutual_consent boolean DEFAULT true,
    supports_group boolean DEFAULT false,
    is_business_related boolean DEFAULT false,
    max_pending_days integer DEFAULT 30,
    allows_intro_message boolean DEFAULT true,
    display_name_en character varying(50),
    display_name_vi character varying(50)
);


ALTER TABLE public.connection_type_metadata OWNER TO postgres;

--
-- Name: connections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.connections (
    match_score double precision,
    receiver_follows_requester boolean,
    requester_follows_receiver boolean,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    expires_at timestamp(6) without time zone,
    requested_at timestamp(6) without time zone,
    responded_at timestamp(6) without time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    receiver_id uuid NOT NULL,
    requester_id uuid NOT NULL,
    connection_type character varying(255) NOT NULL,
    intro_message character varying(255),
    match_source character varying(255),
    response_message character varying(255),
    status character varying(255),
    matched_interests text[],
    date_created_at timestamp(6) with time zone,
    date_description text,
    date_latitude double precision,
    date_location_address text,
    date_location_name character varying(255),
    date_longitude double precision,
    date_scheduled_at timestamp(6) with time zone,
    date_status character varying(20),
    feedback_status character varying(20),
    CONSTRAINT connections_connection_type_check CHECK (((connection_type)::text = ANY ((ARRAY['FRIEND'::character varying, 'ROMANTIC'::character varying, 'ACTIVITY_PARTNER'::character varying, 'STUDY_PARTNER'::character varying, 'TUTOR'::character varying, 'MENTOR'::character varying, 'MENTEE'::character varying, 'COLLEAGUE'::character varying, 'BUSINESS'::character varying, 'ROOMMATE'::character varying, 'ACQUAINTANCE'::character varying, 'SERVICE_PROVIDER'::character varying])::text[]))),
    CONSTRAINT connections_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'ACCEPTED'::character varying, 'REJECTED'::character varying, 'BLOCKED'::character varying, 'EXPIRED'::character varying, 'CANCELLED'::character varying, 'COMPLETED'::character varying, 'NO_SHOW'::character varying])::text[])))
);


ALTER TABLE public.connections OWNER TO postgres;

--
-- Name: content_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.content_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reporter_id uuid,
    content_type character varying(50) NOT NULL,
    content_id uuid NOT NULL,
    reason public.report_reason NOT NULL,
    description text,
    status public.report_status DEFAULT 'pending'::public.report_status,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    resolved_at timestamp without time zone
);


ALTER TABLE public.content_reports OWNER TO postgres;

--
-- Name: conversation_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversation_members (
    is_admin boolean NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    conversation_id uuid NOT NULL,
    id uuid NOT NULL,
    member_id uuid NOT NULL,
    role character varying(255) DEFAULT 'MEMBER'::character varying,
    joined_at timestamp with time zone DEFAULT now(),
    left_at timestamp with time zone
);


ALTER TABLE public.conversation_members OWNER TO postgres;

--
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    title character varying(255),
    type character varying(255) NOT NULL,
    meet_match_id uuid,
    meetup_id uuid,
    is_archived boolean DEFAULT false,
    CONSTRAINT conversations_type_check CHECK (((type)::text = ANY ((ARRAY['DIRECT'::character varying, 'GROUP'::character varying, 'GROUP_MEETUP'::character varying, 'FRIENDS_GROUP'::character varying])::text[])))
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- Name: date_feedback; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.date_feedback (
    id uuid NOT NULL,
    did_meet boolean NOT NULL,
    feedback_text text,
    no_show_reason character varying(50),
    rating character varying(20),
    submitted_at timestamp(6) with time zone NOT NULL,
    connection_id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.date_feedback OWNER TO postgres;

--
-- Name: date_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.date_plans (
    id uuid NOT NULL,
    connection_type character varying(255) NOT NULL,
    created_at timestamp(6) with time zone,
    description text,
    duration_minutes integer,
    is_public boolean,
    latitude double precision,
    longitude double precision,
    max_proposals integer,
    place_address text,
    place_name character varying(255),
    place_type character varying(255) NOT NULL,
    proposal_count integer,
    scheduled_at timestamp(6) with time zone NOT NULL,
    status character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    updated_at timestamp(6) with time zone,
    owner_id uuid NOT NULL,
    partner_id uuid,
    CONSTRAINT date_plans_connection_type_check CHECK (((connection_type)::text = ANY ((ARRAY['DATING'::character varying, 'FRIENDSHIP'::character varying, 'HOBBIES'::character varying, 'GROUPS'::character varying, 'COMMUNITY'::character varying])::text[]))),
    CONSTRAINT date_plans_place_type_check CHECK (((place_type)::text = ANY ((ARRAY['RESTAURANT'::character varying, 'CAFE'::character varying, 'BAR'::character varying, 'PARK'::character varying, 'CINEMA'::character varying, 'BILLIARD'::character varying, 'BADMINTON'::character varying, 'GYM'::character varying, 'MUSEUM'::character varying, 'OTHER'::character varying])::text[]))),
    CONSTRAINT date_plans_status_check CHECK (((status)::text = ANY ((ARRAY['OPEN'::character varying, 'PROPOSAL_PENDING'::character varying, 'ACCEPTED'::character varying, 'REJECTED'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying, 'EXPIRED'::character varying, 'NO_SHOW'::character varying])::text[])))
);


ALTER TABLE public.date_plans OWNER TO postgres;

--
-- Name: date_proposals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.date_proposals (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone,
    message text,
    proposed_time timestamp(6) with time zone,
    status character varying(255) NOT NULL,
    updated_at timestamp(6) with time zone,
    date_id uuid NOT NULL,
    proposer_id uuid NOT NULL,
    CONSTRAINT date_proposals_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'ACCEPTED'::character varying, 'REJECTED'::character varying, 'COUNTER_PROPOSED'::character varying, 'WITHDRAWN'::character varying])::text[])))
);


ALTER TABLE public.date_proposals OWNER TO postgres;

--
-- Name: emergency_contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.emergency_contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(20),
    email character varying(255),
    relationship character varying(50),
    is_primary boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.emergency_contacts OWNER TO postgres;

--
-- Name: event_invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    occurrence_id uuid,
    invited_user_id uuid NOT NULL,
    invited_by uuid NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    message text,
    invited_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    responded_at timestamp without time zone
);


ALTER TABLE public.event_invitations OWNER TO postgres;

--
-- Name: event_occurrences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_occurrences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    occurrence_number integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    status public.event_status DEFAULT 'open'::public.event_status,
    max_participants integer,
    current_participants integer DEFAULT 0,
    waitlist_count integer DEFAULT 0,
    override_fields jsonb,
    chat_room_id uuid,
    is_cancelled boolean DEFAULT false,
    cancelled_at timestamp without time zone,
    cancellation_reason text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.event_occurrences OWNER TO postgres;

--
-- Name: event_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_participants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    occurrence_id uuid,
    user_id uuid NOT NULL,
    status public.participant_status DEFAULT 'pending'::public.participant_status,
    intro_message text,
    requested_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    responded_at timestamp without time zone,
    responded_by uuid,
    response_message text,
    proposed_alternative_time timestamp without time zone,
    alternative_message text,
    waitlist_position integer,
    promoted_from_waitlist_at timestamp without time zone,
    checked_in_at timestamp without time zone,
    checked_out_at timestamp without time zone,
    check_in_location_lat numeric(10,8),
    check_in_location_lng numeric(11,8),
    recurring_signup_type character varying(20)
);


ALTER TABLE public.event_participants OWNER TO postgres;

--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    age_max integer,
    age_min integer,
    allow_waitlist boolean,
    auto_approve_verified boolean,
    current_participants integer,
    duration_minutes integer,
    is_online boolean,
    is_recurring boolean,
    join_deadline_hours integer,
    location_lat double precision,
    location_lng double precision,
    max_participants integer NOT NULL,
    min_participants integer,
    min_reputation_score double precision,
    requires_approval boolean,
    waitlist_count integer,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    end_time timestamp(6) without time zone,
    start_time timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    created_by uuid NOT NULL,
    id uuid NOT NULL,
    activity_type character varying(255) NOT NULL,
    cover_image_url character varying(255),
    description text,
    gender_preference character varying(255),
    location_address text,
    location_name character varying(255),
    location_place_id character varying(255),
    online_meeting_url character varying(255),
    recurrence_rule character varying(255),
    slug character varying(255),
    status character varying(255),
    timezone character varying(255),
    title character varying(255) NOT NULL,
    visibility character varying(255),
    required_verifications text[],
    CONSTRAINT events_activity_type_check CHECK (((activity_type)::text = ANY ((ARRAY['COFFEE'::character varying, 'BREAKFAST'::character varying, 'BRUNCH'::character varying, 'LUNCH'::character varying, 'DINNER'::character varying, 'DRINKS'::character varying, 'SPORTS'::character varying, 'GYM'::character varying, 'HIKING'::character varying, 'CYCLING'::character varying, 'RUNNING'::character varying, 'SWIMMING'::character varying, 'MOVIE'::character varying, 'CONCERT'::character varying, 'THEATER'::character varying, 'MUSEUM'::character varying, 'EXHIBITION'::character varying, 'STUDY'::character varying, 'TUTORING'::character varying, 'WORKSHOP'::character varying, 'SEMINAR'::character varying, 'CONFERENCE'::character varying, 'GAMING'::character varying, 'BOARD_GAMES'::character varying, 'ESPORTS'::character varying, 'TRAVEL'::character varying, 'ROAD_TRIP'::character varying, 'CAMPING'::character varying, 'NETWORKING'::character varying, 'MEETUP'::character varying, 'COWORKING'::character varying, 'VOLUNTEER'::character varying, 'CHARITY'::character varying, 'PARTY'::character varying, 'CELEBRATION'::character varying, 'OTHER'::character varying])::text[]))),
    CONSTRAINT events_status_check CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'OPEN'::character varying, 'WAITING_LIST'::character varying, 'FULL'::character varying, 'ONGOING'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying, 'EXPIRED'::character varying])::text[]))),
    CONSTRAINT events_visibility_check CHECK (((visibility)::text = ANY ((ARRAY['PUBLIC'::character varying, 'FRIENDS_ONLY'::character varying, 'GROUP_ONLY'::character varying, 'INVITE_ONLY'::character varying])::text[])))
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: file_storage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.file_storage (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    size_bytes bigint NOT NULL,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    bucket character varying(255) NOT NULL,
    content_type character varying(255),
    file_name character varying(255) NOT NULL,
    media_type character varying(255) NOT NULL,
    object_key character varying(255) NOT NULL,
    CONSTRAINT file_storage_media_type_check CHECK (((media_type)::text = ANY ((ARRAY['IMAGE'::character varying, 'VIDEO'::character varying, 'AUDIO'::character varying, 'FILE'::character varying])::text[])))
);


ALTER TABLE public.file_storage OWNER TO postgres;

--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO postgres;

--
-- Name: group_join_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_join_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    message text,
    requested_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    responded_at timestamp without time zone,
    responded_by uuid,
    response_message text
);


ALTER TABLE public.group_join_requests OWNER TO postgres;

--
-- Name: group_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role public.member_role DEFAULT 'member'::public.member_role,
    joined_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    invited_by uuid,
    approved_by uuid,
    notifications_enabled boolean DEFAULT true,
    is_muted boolean DEFAULT false,
    nickname character varying(50),
    last_active_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    messages_count integer DEFAULT 0,
    events_attended integer DEFAULT 0
);


ALTER TABLE public.group_members OWNER TO postgres;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100),
    description text,
    cover_image_url character varying(500),
    icon_url character varying(200),
    group_type public.group_type NOT NULL,
    visibility public.group_visibility DEFAULT 'public'::public.group_visibility,
    location_lat numeric(10,8),
    location_lng numeric(11,8),
    location_name character varying(200),
    rules text[],
    welcome_message text,
    max_members integer DEFAULT 1000,
    requires_approval boolean DEFAULT false,
    min_age integer DEFAULT 18,
    allowed_genders character varying(20)[],
    min_reputation_score numeric(3,2),
    min_events_attended integer DEFAULT 0,
    member_count integer DEFAULT 0,
    active_member_count integer DEFAULT 0,
    total_events integer DEFAULT 0,
    chat_enabled boolean DEFAULT true,
    chat_room_id uuid,
    tags text[],
    is_featured boolean DEFAULT false,
    is_verified boolean DEFAULT false,
    created_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: hashtags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hashtags (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    usage_count bigint NOT NULL,
    version bigint NOT NULL,
    id uuid NOT NULL,
    tag character varying(255) NOT NULL
);


ALTER TABLE public.hashtags OWNER TO postgres;

--
-- Name: match_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match_scores (
    activity_score double precision,
    interest_score double precision,
    location_score double precision,
    total_score double precision,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    user_id_1 uuid NOT NULL,
    user_id_2 uuid NOT NULL,
    common_interests text[]
);


ALTER TABLE public.match_scores OWNER TO postgres;

--
-- Name: meetup_attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meetup_attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    meetup_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying(255) DEFAULT 'PENDING'::character varying NOT NULL,
    confirmed_at timestamp with time zone,
    feedback text,
    rating real,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.meetup_attendance OWNER TO postgres;

--
-- Name: meetup_confirmations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meetup_confirmations (
    id uuid NOT NULL,
    confirmed_at timestamp(6) with time zone,
    notes text,
    result character varying(20) NOT NULL,
    meetup_match_id uuid NOT NULL,
    user_id uuid NOT NULL,
    comment text,
    rating double precision,
    CONSTRAINT meetup_confirmations_result_check CHECK (((result)::text = ANY ((ARRAY['SUCCESS'::character varying, 'NO_SHOW'::character varying])::text[])))
);


ALTER TABLE public.meetup_confirmations OWNER TO postgres;

--
-- Name: meetup_matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meetup_matches (
    id uuid NOT NULL,
    conversation_id uuid,
    created_at timestamp(6) with time zone,
    message text,
    responded_at timestamp(6) with time zone,
    status character varying(255) NOT NULL,
    meetup_id uuid NOT NULL,
    user_id uuid NOT NULL,
    CONSTRAINT meetup_matches_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'ACCEPTED'::character varying, 'REJECTED'::character varying, 'CANCELLED'::character varying, 'CONFIRMED'::character varying])::text[])))
);


ALTER TABLE public.meetup_matches OWNER TO postgres;

--
-- Name: meetup_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meetup_participants (
    meetup_id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.meetup_participants OWNER TO postgres;

--
-- Name: meetups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meetups (
    id uuid NOT NULL,
    category character varying(100) NOT NULL,
    created_at timestamp(6) with time zone,
    description text,
    duration_minutes integer,
    latitude double precision,
    location character varying(255),
    longitude double precision,
    max_participants integer,
    scheduled_at timestamp(6) with time zone NOT NULL,
    status character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    updated_at timestamp(6) with time zone,
    organizer_id uuid NOT NULL,
    confirmation_sent_at timestamp(6) with time zone,
    confirmation_status character varying(255),
    expires_at timestamp(6) with time zone,
    meet_type character varying(255) NOT NULL,
    organizer_confirmed boolean,
    participant_confirmed boolean,
    CONSTRAINT meetups_confirmation_status_check CHECK (((confirmation_status)::text = ANY ((ARRAY['NONE'::character varying, 'PENDING'::character varying, 'CONFIRMED'::character varying, 'DISPUTED'::character varying, 'NO_SHOW'::character varying])::text[]))),
    CONSTRAINT meetups_meet_type_check CHECK (((meet_type)::text = ANY ((ARRAY['ONE_TO_ONE'::character varying, 'GROUP'::character varying])::text[]))),
    CONSTRAINT meetups_status_check CHECK (((status)::text = ANY ((ARRAY['OPEN'::character varying, 'MATCHED'::character varying, 'WAITING_CONFIRMATION'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying, 'EXPIRED'::character varying])::text[])))
);


ALTER TABLE public.meetups OWNER TO postgres;

--
-- Name: message_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_media (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    message_id uuid NOT NULL,
    media_type character varying(255) NOT NULL,
    object_key character varying(255) NOT NULL,
    CONSTRAINT message_media_media_type_check CHECK (((media_type)::text = ANY ((ARRAY['IMAGE'::character varying, 'VIDEO'::character varying, 'AUDIO'::character varying, 'FILE'::character varying])::text[])))
);


ALTER TABLE public.message_media OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    reaction character varying(10),
    conversation_id uuid NOT NULL,
    id uuid NOT NULL,
    sender_id uuid NOT NULL,
    content character varying(2048),
    status character varying(255) NOT NULL,
    CONSTRAINT messages_status_check CHECK (((status)::text = ANY ((ARRAY['SENT'::character varying, 'DELIVERED'::character varying, 'READ'::character varying])::text[])))
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: moderation_actions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moderation_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    target_user_id uuid,
    action_type character varying(50) NOT NULL,
    action_reason text,
    duration_hours integer,
    expires_at timestamp without time zone,
    performed_by uuid,
    related_report_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.moderation_actions OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    recipient_id uuid NOT NULL,
    reference_id uuid,
    message character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    CONSTRAINT notifications_status_check CHECK (((status)::text = ANY ((ARRAY['UNREAD'::character varying, 'READ'::character varying])::text[]))),
    CONSTRAINT notifications_type_check CHECK (((type)::text = ANY ((ARRAY['FOLLOW'::character varying, 'LIKE'::character varying, 'COMMENT'::character varying, 'MESSAGE'::character varying, 'SYSTEM'::character varying])::text[])))
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: pending_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pending_reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reviewer_id uuid NOT NULL,
    reviewed_user_id uuid NOT NULL,
    context_type public.review_context NOT NULL,
    context_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone,
    reminder_sent_at timestamp without time zone
);


ALTER TABLE public.pending_reviews OWNER TO postgres;

--
-- Name: post_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_comments (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    author_id uuid NOT NULL,
    id uuid NOT NULL,
    parent_comment_id uuid,
    post_id uuid NOT NULL,
    content character varying(1024) NOT NULL
);


ALTER TABLE public.post_comments OWNER TO postgres;

--
-- Name: post_hashtags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_hashtags (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    hashtag_id uuid NOT NULL,
    id uuid NOT NULL,
    post_id uuid NOT NULL
);


ALTER TABLE public.post_hashtags OWNER TO postgres;

--
-- Name: post_likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_likes (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.post_likes OWNER TO postgres;

--
-- Name: post_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_media (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    post_id uuid NOT NULL,
    description character varying(255),
    media_type character varying(255) NOT NULL,
    object_key character varying(255) NOT NULL,
    order_index integer,
    CONSTRAINT post_media_media_type_check CHECK (((media_type)::text = ANY ((ARRAY['IMAGE'::character varying, 'VIDEO'::character varying, 'AUDIO'::character varying, 'FILE'::character varying])::text[])))
);


ALTER TABLE public.post_media OWNER TO postgres;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    comment_count bigint NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    like_count bigint NOT NULL,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    author_id uuid NOT NULL,
    id uuid NOT NULL,
    content character varying(2048),
    visibility character varying(255) NOT NULL,
    location public.geometry(Point,4326),
    place_code character varying(50),
    place_name character varying(255),
    CONSTRAINT posts_visibility_check CHECK (((visibility)::text = ANY ((ARRAY['PUBLIC'::character varying, 'FOLLOWERS'::character varying, 'PRIVATE'::character varying])::text[])))
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: review_responses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.review_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    review_id uuid NOT NULL,
    response_text text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.review_responses OWNER TO postgres;

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reviewer_id uuid NOT NULL,
    reviewed_user_id uuid NOT NULL,
    context_type public.review_context NOT NULL,
    context_id uuid,
    rating integer NOT NULL,
    punctuality_rating integer,
    communication_rating integer,
    friendliness_rating integer,
    respectfulness_rating integer,
    feedback text,
    tags character varying(50)[],
    photo_urls text[],
    is_public boolean DEFAULT true,
    is_anonymous boolean DEFAULT false,
    is_flagged boolean DEFAULT false,
    is_hidden boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: safety_checkins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.safety_checkins (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    event_id uuid,
    location_lat numeric(10,8),
    location_lng numeric(11,8),
    location_accuracy numeric(10,2),
    checkin_type character varying(20),
    is_sos boolean DEFAULT false,
    sos_message text,
    emergency_contacts_notified boolean DEFAULT false,
    notified_at timestamp without time zone,
    responded_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.safety_checkins OWNER TO postgres;

--
-- Name: stories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stories (
    id uuid NOT NULL,
    background_color character varying(20),
    created_at timestamp(6) without time zone,
    expires_at timestamp(6) without time zone NOT NULL,
    media_type character varying(255) NOT NULL,
    media_url character varying(500) NOT NULL,
    text_content character varying(500),
    view_count integer,
    user_id uuid NOT NULL,
    CONSTRAINT stories_media_type_check CHECK (((media_type)::text = ANY ((ARRAY['IMAGE'::character varying, 'VIDEO'::character varying])::text[])))
);


ALTER TABLE public.stories OWNER TO postgres;

--
-- Name: story_views; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.story_views (
    id uuid NOT NULL,
    viewed_at timestamp(6) without time zone,
    story_id uuid NOT NULL,
    viewer_id uuid NOT NULL
);


ALTER TABLE public.story_views OWNER TO postgres;

--
-- Name: swipe_actions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.swipe_actions (
    is_mutual boolean,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    actor_id uuid NOT NULL,
    id uuid NOT NULL,
    target_id uuid NOT NULL,
    action_type character varying(255) NOT NULL,
    CONSTRAINT swipe_actions_action_type_check CHECK (((action_type)::text = ANY ((ARRAY['LIKE'::character varying, 'DISLIKE'::character varying, 'SUPERLIKE'::character varying])::text[])))
);


ALTER TABLE public.swipe_actions OWNER TO postgres;

--
-- Name: user_activity_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_activity_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    action_type character varying(50) NOT NULL,
    target_type character varying(50),
    target_id uuid,
    metadata jsonb,
    session_id character varying(100),
    device_type character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_activity_logs OWNER TO postgres;

--
-- Name: user_blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_blocks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    blocker_id uuid NOT NULL,
    blocked_id uuid NOT NULL,
    reason text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_blocks OWNER TO postgres;

--
-- Name: user_followers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_followers (
    muted boolean NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    follower_id uuid NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.user_followers OWNER TO postgres;

--
-- Name: user_login_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_login_history (
    success boolean NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    ip_address character varying(255),
    user_agent character varying(255)
);


ALTER TABLE public.user_login_history OWNER TO postgres;

--
-- Name: user_photos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    photo_url character varying(500) NOT NULL,
    thumbnail_url character varying(500),
    display_order integer DEFAULT 0,
    is_primary boolean DEFAULT false,
    is_verified boolean DEFAULT false,
    caption text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_photos OWNER TO postgres;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    bio character varying(512),
    avatar_object_key character varying(255),
    location character varying(255),
    website character varying(255),
    reputation_score double precision,
    date_of_birth date,
    education_level character varying(255),
    gender character varying(255),
    total_meets_cancelled integer,
    total_meets_completed integer,
    total_no_shows integer,
    CONSTRAINT user_profiles_education_level_check CHECK (((education_level)::text = ANY ((ARRAY['HIGH_SCHOOL'::character varying, 'COLLEGE'::character varying, 'UNIVERSITY'::character varying, 'GRADUATE'::character varying, 'POSTGRADUATE'::character varying, 'OTHER'::character varying])::text[]))),
    CONSTRAINT user_profiles_gender_check CHECK (((gender)::text = ANY ((ARRAY['MALE'::character varying, 'FEMALE'::character varying, 'OTHER'::character varying, 'PREFER_NOT_TO_SAY'::character varying])::text[])))
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- Name: user_profiles_extended; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles_extended (
    date_of_birth date,
    is_online boolean,
    is_verified boolean,
    location_approximate boolean,
    location_lat double precision,
    location_lng double precision,
    max_distance_km integer,
    preferred_age_max integer,
    preferred_age_min integer,
    profile_completeness integer,
    reputation_score double precision,
    total_reviews integer,
    verification_level integer,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    last_active_at timestamp(6) without time zone,
    updated_at timestamp(6) with time zone,
    verified_at timestamp(6) without time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    company character varying(255),
    diet character varying(255),
    drinking character varying(255),
    education character varying(255),
    education_level character varying(255),
    exercise_frequency character varying(255),
    gender character varying(255),
    gender_identity character varying(255),
    location_city character varying(255),
    location_country character varying(255),
    location_district character varying(255),
    occupation character varying(255),
    personality_type character varying(255),
    pronouns character varying(255),
    relationship_status character varying(255),
    smoking character varying(255),
    timezone character varying(255),
    available_days character varying[],
    available_time_slots jsonb,
    interests text[],
    languages character varying[],
    looking_for text[],
    pets character varying[],
    preferred_genders character varying[]
);


ALTER TABLE public.user_profiles_extended OWNER TO postgres;

--
-- Name: user_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reporter_id uuid,
    reported_user_id uuid NOT NULL,
    reason public.report_reason NOT NULL,
    description text,
    evidence_urls text[],
    context_type character varying(50),
    context_id uuid,
    status public.report_status DEFAULT 'pending'::public.report_status,
    priority integer DEFAULT 0,
    assigned_to uuid,
    reviewed_at timestamp without time zone,
    reviewed_by uuid,
    resolution_notes text,
    action_taken character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    resolved_at timestamp without time zone
);


ALTER TABLE public.user_reports OWNER TO postgres;

--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_settings (
    allow_messages boolean NOT NULL,
    email_notifications boolean NOT NULL,
    is_private boolean NOT NULL,
    push_notifications boolean NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.user_settings OWNER TO postgres;

--
-- Name: user_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_stats (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    total_connections integer DEFAULT 0,
    friends_count integer DEFAULT 0,
    romantic_connections integer DEFAULT 0,
    activity_partners integer DEFAULT 0,
    events_created integer DEFAULT 0,
    events_joined integer DEFAULT 0,
    events_completed integer DEFAULT 0,
    events_cancelled integer DEFAULT 0,
    events_no_show integer DEFAULT 0,
    groups_joined integer DEFAULT 0,
    groups_created integer DEFAULT 0,
    reviews_given integer DEFAULT 0,
    reviews_received integer DEFAULT 0,
    average_rating numeric(3,2),
    reports_received integer DEFAULT 0,
    blocks_received integer DEFAULT 0,
    warnings_received integer DEFAULT 0,
    profile_views integer DEFAULT 0,
    messages_sent integer DEFAULT 0,
    match_rate numeric(5,2),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_stats OWNER TO postgres;

--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_tokens (
    revoked boolean NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    expires_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    refresh_token character varying(512) NOT NULL,
    ip_address character varying(255),
    user_agent character varying(255)
);


ALTER TABLE public.user_tokens OWNER TO postgres;

--
-- Name: user_verifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    verification_type public.verification_type NOT NULL,
    verification_data jsonb,
    verified_at timestamp without time zone,
    expires_at timestamp without time zone,
    is_valid boolean DEFAULT true,
    verified_by character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_verifications OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    full_name character varying(255),
    otp character varying(255),
    password_hash character varying(255) NOT NULL,
    phone character varying(255),
    status character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    no_show_count integer,
    latitude double precision,
    longitude double precision,
    CONSTRAINT users_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING_VERIFICATION'::character varying, 'ACTIVE'::character varying, 'SUSPENDED'::character varying, 'DEACTIVATED'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: ai_suggestions ai_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_suggestions
    ADD CONSTRAINT ai_suggestions_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: chat_room_members chat_room_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_room_members
    ADD CONSTRAINT chat_room_members_pkey PRIMARY KEY (id);


--
-- Name: chat_room_members chat_room_members_room_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_room_members
    ADD CONSTRAINT chat_room_members_room_id_user_id_key UNIQUE (room_id, user_id);


--
-- Name: chat_rooms chat_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_rooms
    ADD CONSTRAINT chat_rooms_pkey PRIMARY KEY (id);


--
-- Name: connection_type_metadata connection_type_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connection_type_metadata
    ADD CONSTRAINT connection_type_metadata_pkey PRIMARY KEY (connection_type);


--
-- Name: connections connections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT connections_pkey PRIMARY KEY (id);


--
-- Name: content_reports content_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.content_reports
    ADD CONSTRAINT content_reports_pkey PRIMARY KEY (id);


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
-- Name: date_feedback date_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_feedback
    ADD CONSTRAINT date_feedback_pkey PRIMARY KEY (id);


--
-- Name: date_plans date_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_plans
    ADD CONSTRAINT date_plans_pkey PRIMARY KEY (id);


--
-- Name: date_proposals date_proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_proposals
    ADD CONSTRAINT date_proposals_pkey PRIMARY KEY (id);


--
-- Name: emergency_contacts emergency_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.emergency_contacts
    ADD CONSTRAINT emergency_contacts_pkey PRIMARY KEY (id);


--
-- Name: event_invitations event_invitations_event_id_occurrence_id_invited_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_invitations
    ADD CONSTRAINT event_invitations_event_id_occurrence_id_invited_user_id_key UNIQUE (event_id, occurrence_id, invited_user_id);


--
-- Name: event_invitations event_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_invitations
    ADD CONSTRAINT event_invitations_pkey PRIMARY KEY (id);


--
-- Name: event_occurrences event_occurrences_event_id_occurrence_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_occurrences
    ADD CONSTRAINT event_occurrences_event_id_occurrence_number_key UNIQUE (event_id, occurrence_number);


--
-- Name: event_occurrences event_occurrences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_occurrences
    ADD CONSTRAINT event_occurrences_pkey PRIMARY KEY (id);


--
-- Name: event_participants event_participants_event_id_occurrence_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_event_id_occurrence_id_user_id_key UNIQUE (event_id, occurrence_id, user_id);


--
-- Name: event_participants event_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


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
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: group_join_requests group_join_requests_group_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_join_requests
    ADD CONSTRAINT group_join_requests_group_id_user_id_key UNIQUE (group_id, user_id);


--
-- Name: group_join_requests group_join_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_join_requests
    ADD CONSTRAINT group_join_requests_pkey PRIMARY KEY (id);


--
-- Name: group_members group_members_group_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_group_id_user_id_key UNIQUE (group_id, user_id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: groups groups_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_slug_key UNIQUE (slug);


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
-- Name: match_scores match_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_scores
    ADD CONSTRAINT match_scores_pkey PRIMARY KEY (id);


--
-- Name: meetup_attendance meetup_attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_attendance
    ADD CONSTRAINT meetup_attendance_pkey PRIMARY KEY (id);


--
-- Name: meetup_confirmations meetup_confirmations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_confirmations
    ADD CONSTRAINT meetup_confirmations_pkey PRIMARY KEY (id);


--
-- Name: meetup_matches meetup_matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_matches
    ADD CONSTRAINT meetup_matches_pkey PRIMARY KEY (id);


--
-- Name: meetups meetups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetups
    ADD CONSTRAINT meetups_pkey PRIMARY KEY (id);


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
-- Name: moderation_actions moderation_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: pending_reviews pending_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_reviews
    ADD CONSTRAINT pending_reviews_pkey PRIMARY KEY (id);


--
-- Name: pending_reviews pending_reviews_reviewer_id_reviewed_user_id_context_type_c_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pending_reviews
    ADD CONSTRAINT pending_reviews_reviewer_id_reviewed_user_id_context_type_c_key UNIQUE (reviewer_id, reviewed_user_id, context_type, context_id);


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
-- Name: review_responses review_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review_responses
    ADD CONSTRAINT review_responses_pkey PRIMARY KEY (id);


--
-- Name: review_responses review_responses_review_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review_responses
    ADD CONSTRAINT review_responses_review_id_key UNIQUE (review_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_reviewer_id_reviewed_user_id_context_type_context_i_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_reviewer_id_reviewed_user_id_context_type_context_i_key UNIQUE (reviewer_id, reviewed_user_id, context_type, context_id);


--
-- Name: safety_checkins safety_checkins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.safety_checkins
    ADD CONSTRAINT safety_checkins_pkey PRIMARY KEY (id);


--
-- Name: stories stories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stories
    ADD CONSTRAINT stories_pkey PRIMARY KEY (id);


--
-- Name: story_views story_views_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.story_views
    ADD CONSTRAINT story_views_pkey PRIMARY KEY (id);


--
-- Name: swipe_actions swipe_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.swipe_actions
    ADD CONSTRAINT swipe_actions_pkey PRIMARY KEY (id);


--
-- Name: date_feedback uk6whv2rnx9l1gw9w6im9k8fqr0; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_feedback
    ADD CONSTRAINT uk6whv2rnx9l1gw9w6im9k8fqr0 UNIQUE (connection_id, user_id);


--
-- Name: date_proposals uk76uydjdv96f23on974ugaj2cw; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_proposals
    ADD CONSTRAINT uk76uydjdv96f23on974ugaj2cw UNIQUE (date_id, proposer_id);


--
-- Name: meetup_matches ukgh5gg3p4u5itdlkq0tewpv2ow; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_matches
    ADD CONSTRAINT ukgh5gg3p4u5itdlkq0tewpv2ow UNIQUE (meetup_id, user_id);


--
-- Name: meetup_attendance ukhkikaabelr49fa0p3j0csvkkd; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_attendance
    ADD CONSTRAINT ukhkikaabelr49fa0p3j0csvkkd UNIQUE (meetup_id, user_id);


--
-- Name: meetup_confirmations uktb6hnmc0do4tr5i46mikaog3m; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_confirmations
    ADD CONSTRAINT uktb6hnmc0do4tr5i46mikaog3m UNIQUE (meetup_match_id, user_id);


--
-- Name: meetup_attendance uq_meetup_attendance; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_attendance
    ADD CONSTRAINT uq_meetup_attendance UNIQUE (meetup_id, user_id);


--
-- Name: user_activity_logs user_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_activity_logs
    ADD CONSTRAINT user_activity_logs_pkey PRIMARY KEY (id);


--
-- Name: user_blocks user_blocks_blocker_id_blocked_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT user_blocks_blocker_id_blocked_id_key UNIQUE (blocker_id, blocked_id);


--
-- Name: user_blocks user_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT user_blocks_pkey PRIMARY KEY (id);


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
-- Name: user_photos user_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_photos
    ADD CONSTRAINT user_photos_pkey PRIMARY KEY (id);


--
-- Name: user_profiles_extended user_profiles_extended_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles_extended
    ADD CONSTRAINT user_profiles_extended_pkey PRIMARY KEY (id);


--
-- Name: user_profiles_extended user_profiles_extended_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles_extended
    ADD CONSTRAINT user_profiles_extended_user_id_key UNIQUE (user_id);


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
-- Name: user_reports user_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_reports
    ADD CONSTRAINT user_reports_pkey PRIMARY KEY (id);


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
-- Name: user_stats user_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT user_stats_pkey PRIMARY KEY (id);


--
-- Name: user_stats user_stats_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT user_stats_user_id_key UNIQUE (user_id);


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
-- Name: user_verifications user_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_verifications
    ADD CONSTRAINT user_verifications_pkey PRIMARY KEY (id);


--
-- Name: user_verifications user_verifications_user_id_verification_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_verifications
    ADD CONSTRAINT user_verifications_user_id_verification_type_key UNIQUE (user_id, verification_type);


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
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: idx_chat_messages_room; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_messages_room ON public.chat_messages USING btree (room_id, created_at DESC);


--
-- Name: idx_conversations_meetup_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_conversations_meetup_id ON public.conversations USING btree (meetup_id);


--
-- Name: idx_date_plans_is_public; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_date_plans_is_public ON public.date_plans USING btree (is_public);


--
-- Name: idx_date_plans_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_date_plans_owner ON public.date_plans USING btree (owner_id);


--
-- Name: idx_date_plans_scheduled_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_date_plans_scheduled_at ON public.date_plans USING btree (scheduled_at);


--
-- Name: idx_date_plans_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_date_plans_status ON public.date_plans USING btree (status);


--
-- Name: idx_date_proposals_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_date_proposals_date ON public.date_proposals USING btree (date_id);


--
-- Name: idx_date_proposals_proposer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_date_proposals_proposer ON public.date_proposals USING btree (proposer_id);


--
-- Name: idx_date_proposals_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_date_proposals_status ON public.date_proposals USING btree (status);


--
-- Name: idx_group_members_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_members_group ON public.group_members USING btree (group_id, role);


--
-- Name: idx_group_members_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_members_user ON public.group_members USING btree (user_id, role);


--
-- Name: idx_meetup_attendance_meetup_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meetup_attendance_meetup_id ON public.meetup_attendance USING btree (meetup_id);


--
-- Name: idx_meetup_attendance_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meetup_attendance_status ON public.meetup_attendance USING btree (status);


--
-- Name: idx_meetup_attendance_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meetup_attendance_user_id ON public.meetup_attendance USING btree (user_id);


--
-- Name: idx_meetup_participants_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meetup_participants_user ON public.meetup_participants USING btree (user_id);


--
-- Name: idx_meetups_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meetups_category ON public.meetups USING btree (category);


--
-- Name: idx_meetups_organizer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meetups_organizer ON public.meetups USING btree (organizer_id);


--
-- Name: idx_meetups_scheduled_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meetups_scheduled_at ON public.meetups USING btree (scheduled_at);


--
-- Name: idx_meetups_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_meetups_status ON public.meetups USING btree (status);


--
-- Name: idx_participants_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_participants_user ON public.event_participants USING btree (user_id, status);


--
-- Name: event_participants trg_update_event_participants; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_event_participants AFTER INSERT OR DELETE OR UPDATE ON public.event_participants FOR EACH ROW EXECUTE FUNCTION public.update_event_participant_count();


--
-- Name: reviews trg_update_reputation; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_reputation AFTER INSERT OR UPDATE ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.update_user_reputation();


--
-- Name: chat_messages chat_messages_reply_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_reply_to_id_fkey FOREIGN KEY (reply_to_id) REFERENCES public.chat_messages(id) ON DELETE SET NULL;


--
-- Name: chat_messages chat_messages_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.chat_rooms(id) ON DELETE CASCADE;


--
-- Name: chat_room_members chat_room_members_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_room_members
    ADD CONSTRAINT chat_room_members_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.chat_rooms(id) ON DELETE CASCADE;


--
-- Name: chat_rooms chat_rooms_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_rooms
    ADD CONSTRAINT chat_rooms_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_meetup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_meetup_id_fkey FOREIGN KEY (meetup_id) REFERENCES public.meetups(id);


--
-- Name: event_invitations event_invitations_occurrence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_invitations
    ADD CONSTRAINT event_invitations_occurrence_id_fkey FOREIGN KEY (occurrence_id) REFERENCES public.event_occurrences(id) ON DELETE CASCADE;


--
-- Name: event_participants event_participants_occurrence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_occurrence_id_fkey FOREIGN KEY (occurrence_id) REFERENCES public.event_occurrences(id) ON DELETE CASCADE;


--
-- Name: date_feedback fk146fxgvmv8yyp7c71mgc86c2v; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_feedback
    ADD CONSTRAINT fk146fxgvmv8yyp7c71mgc86c2v FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: post_media fk1urcum9dtf0vgul7k405f4r2d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_media
    ADD CONSTRAINT fk1urcum9dtf0vgul7k405f4r2d FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: post_comments fk21q7y8a124im4g0l4aaxn4ol1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT fk21q7y8a124im4g0l4aaxn4ol1 FOREIGN KEY (parent_comment_id) REFERENCES public.post_comments(id);


--
-- Name: meetup_confirmations fk2byeer5agddu83bij66e3204h; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_confirmations
    ADD CONSTRAINT fk2byeer5agddu83bij66e3204h FOREIGN KEY (meetup_match_id) REFERENCES public.meetup_matches(id);


--
-- Name: story_views fk2y4acyhro3w5xrmku47osiry9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.story_views
    ADD CONSTRAINT fk2y4acyhro3w5xrmku47osiry9 FOREIGN KEY (viewer_id) REFERENCES public.users(id);


--
-- Name: date_plans fk3l8n9mvo9y4416kye4lfl7ame; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_plans
    ADD CONSTRAINT fk3l8n9mvo9y4416kye4lfl7ame FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: swipe_actions fk3vssajpmbeq5vbxsaioir4f29; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.swipe_actions
    ADD CONSTRAINT fk3vssajpmbeq5vbxsaioir4f29 FOREIGN KEY (target_id) REFERENCES public.users(id);


--
-- Name: messages fk4ui4nnwntodh6wjvck53dbk9m; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT fk4ui4nnwntodh6wjvck53dbk9m FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: user_tokens fk61iiu6gfevpvo2v3yl76sar7r; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT fk61iiu6gfevpvo2v3yl76sar7r FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: posts fk6xvn0811tkyo3nfjk2xvqx6ns; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk6xvn0811tkyo3nfjk2xvqx6ns FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: user_settings fk8v82nj88rmai0nyck19f873dw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT fk8v82nj88rmai0nyck19f873dw FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: conversation_members fk91j0v3mph9xj4mbx7flwdesbk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT fk91j0v3mph9xj4mbx7flwdesbk FOREIGN KEY (member_id) REFERENCES public.users(id);


--
-- Name: message_media fk9dofr3ed1b29u3g5rkf4bgypi; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_media
    ADD CONSTRAINT fk9dofr3ed1b29u3g5rkf4bgypi FOREIGN KEY (message_id) REFERENCES public.messages(id);


--
-- Name: post_comments fk9uedrlupih4x9c9qk1ntwdpie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT fk9uedrlupih4x9c9qk1ntwdpie FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: post_likes fka5wxsgl4doibhbed9gm7ikie2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT fka5wxsgl4doibhbed9gm7ikie2 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: post_comments fkaawaqxjs3br8dw5v90w7uu514; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT fkaawaqxjs3br8dw5v90w7uu514 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: date_proposals fkaubkanrrl5tn4jqqxaanb0iw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_proposals
    ADD CONSTRAINT fkaubkanrrl5tn4jqqxaanb0iw FOREIGN KEY (date_id) REFERENCES public.date_plans(id);


--
-- Name: post_hashtags fkb8j4xx456a7584d8blc604pqg; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_hashtags
    ADD CONSTRAINT fkb8j4xx456a7584d8blc604pqg FOREIGN KEY (hashtag_id) REFERENCES public.hashtags(id);


--
-- Name: date_feedback fkbmfuq6o0n8wugbsm6gcqg4mq0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_feedback
    ADD CONSTRAINT fkbmfuq6o0n8wugbsm6gcqg4mq0 FOREIGN KEY (connection_id) REFERENCES public.connections(id);


--
-- Name: swipe_actions fkg1fpyfrlugt3ocs6km9lbjo8p; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.swipe_actions
    ADD CONSTRAINT fkg1fpyfrlugt3ocs6km9lbjo8p FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: match_scores fkimdttbhs2shefo103atkloing; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_scores
    ADD CONSTRAINT fkimdttbhs2shefo103atkloing FOREIGN KEY (user_id_1) REFERENCES public.users(id);


--
-- Name: user_profiles fkjcad5nfve11khsnpwj1mv8frj; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT fkjcad5nfve11khsnpwj1mv8frj FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: meetup_confirmations fkjqk1p1vyu8hqmjobmr63nu5mk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_confirmations
    ADD CONSTRAINT fkjqk1p1vyu8hqmjobmr63nu5mk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: post_likes fkkgau5n0nlewg6o9lr4yibqgxj; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT fkkgau5n0nlewg6o9lr4yibqgxj FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: connections fklutg9g52xi3p7i1kmfigig563; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT fklutg9g52xi3p7i1kmfigig563 FOREIGN KEY (receiver_id) REFERENCES public.users(id);


--
-- Name: meetups fkm376eeljwfai2hlpdih7ysmes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetups
    ADD CONSTRAINT fkm376eeljwfai2hlpdih7ysmes FOREIGN KEY (organizer_id) REFERENCES public.users(id);


--
-- Name: events fkmpv90a1lsx9lcxsj7xjcvvsxg; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT fkmpv90a1lsx9lcxsj7xjcvvsxg FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: connections fkmrwaqamem13p6gynbehk2c26d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connections
    ADD CONSTRAINT fkmrwaqamem13p6gynbehk2c26d FOREIGN KEY (requester_id) REFERENCES public.users(id);


--
-- Name: meetup_matches fkn09ehbc5vejow69wk1jq03nlt; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_matches
    ADD CONSTRAINT fkn09ehbc5vejow69wk1jq03nlt FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: story_views fknpayqngtq4lo8dgqqpo01vcrv; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.story_views
    ADD CONSTRAINT fknpayqngtq4lo8dgqqpo01vcrv FOREIGN KEY (story_id) REFERENCES public.stories(id);


--
-- Name: conversation_members fknxfbup81m9td8l03se3rg2icf; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT fknxfbup81m9td8l03se3rg2icf FOREIGN KEY (conversation_id) REFERENCES public.conversations(id);


--
-- Name: user_profiles_extended fkomjwovbef1e8rs1b5uh8kjtxy; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles_extended
    ADD CONSTRAINT fkomjwovbef1e8rs1b5uh8kjtxy FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: match_scores fkomu0xp0wcr6g3b2l20yi21qef; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_scores
    ADD CONSTRAINT fkomu0xp0wcr6g3b2l20yi21qef FOREIGN KEY (user_id_2) REFERENCES public.users(id);


--
-- Name: meetup_participants fkooa6dp747686bmd5bhtdhyq2a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_participants
    ADD CONSTRAINT fkooa6dp747686bmd5bhtdhyq2a FOREIGN KEY (meetup_id) REFERENCES public.meetups(id);


--
-- Name: user_followers fkox7c2m7d9qhhpu45d83luq19q; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_followers
    ADD CONSTRAINT fkox7c2m7d9qhhpu45d83luq19q FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: meetup_participants fkp72gnmqfmnw630a6cycblw5q1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_participants
    ADD CONSTRAINT fkp72gnmqfmnw630a6cycblw5q1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notifications fkqqnsjxlwleyjbxlmm213jaj3f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fkqqnsjxlwleyjbxlmm213jaj3f FOREIGN KEY (recipient_id) REFERENCES public.users(id);


--
-- Name: date_plans fkqwgkxi6y088pv4ch2qjn61nut; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_plans
    ADD CONSTRAINT fkqwgkxi6y088pv4ch2qjn61nut FOREIGN KEY (partner_id) REFERENCES public.users(id);


--
-- Name: post_hashtags fkrrlq793bvaswhomm900i71ac5; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_hashtags
    ADD CONSTRAINT fkrrlq793bvaswhomm900i71ac5 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: user_followers fksauvjgnbgys3gbeharkga2omh; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_followers
    ADD CONSTRAINT fksauvjgnbgys3gbeharkga2omh FOREIGN KEY (follower_id) REFERENCES public.users(id);


--
-- Name: date_proposals fksbq7u5957ll2op5dcn2yrkjl4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.date_proposals
    ADD CONSTRAINT fksbq7u5957ll2op5dcn2yrkjl4 FOREIGN KEY (proposer_id) REFERENCES public.users(id);


--
-- Name: conversations fksdtd03157lbb4o4h2mxobuhd4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT fksdtd03157lbb4o4h2mxobuhd4 FOREIGN KEY (meet_match_id) REFERENCES public.meetup_matches(id);


--
-- Name: stories fkshv2ytgbsn9w9mpu43mc6ln6j; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stories
    ADD CONSTRAINT fkshv2ytgbsn9w9mpu43mc6ln6j FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: messages fkt492th6wsovh1nush5yl5jj8e; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT fkt492th6wsovh1nush5yl5jj8e FOREIGN KEY (conversation_id) REFERENCES public.conversations(id);


--
-- Name: user_login_history fkthvsfa8x1rhm6fbi1ysbsnsac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_login_history
    ADD CONSTRAINT fkthvsfa8x1rhm6fbi1ysbsnsac FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: meetup_matches fktid3liii4g5jgjb02k9c9kcoc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_matches
    ADD CONSTRAINT fktid3liii4g5jgjb02k9c9kcoc FOREIGN KEY (meetup_id) REFERENCES public.meetups(id);


--
-- Name: group_join_requests group_join_requests_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_join_requests
    ADD CONSTRAINT group_join_requests_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_members group_members_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: meetup_attendance meetup_attendance_meetup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_attendance
    ADD CONSTRAINT meetup_attendance_meetup_id_fkey FOREIGN KEY (meetup_id) REFERENCES public.meetups(id) ON DELETE CASCADE;


--
-- Name: meetup_attendance meetup_attendance_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetup_attendance
    ADD CONSTRAINT meetup_attendance_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: moderation_actions moderation_actions_related_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_related_report_id_fkey FOREIGN KEY (related_report_id) REFERENCES public.user_reports(id);


--
-- Name: review_responses review_responses_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review_responses
    ADD CONSTRAINT review_responses_review_id_fkey FOREIGN KEY (review_id) REFERENCES public.reviews(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict fUWe3q3JBeAs0SkuqITOn9M0d8BUN6sKdcMZkcR4SeN8BFb6SNMIwXab35d0esz

