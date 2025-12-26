--
-- PostgreSQL database dump
--

\restrict REcnVKfCWWdWNqbC01ef8sE6ywAY9ikR5icxANdg2LA0uGpxiCJj5vG87pYcCPP

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
-- Name: admin_action_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_action_logs (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    action_type character varying(255) NOT NULL,
    note character varying(1024),
    target_id uuid NOT NULL,
    admin_id uuid NOT NULL,
    CONSTRAINT admin_action_logs_action_type_check CHECK (((action_type)::text = ANY ((ARRAY['HIDE_POST'::character varying, 'DELETE_POST'::character varying, 'RESTORE_POST'::character varying, 'MARK_REPORT_VALID'::character varying, 'MARK_REPORT_INVALID'::character varying])::text[])))
);


ALTER TABLE public.admin_action_logs OWNER TO postgres;

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
-- Name: post_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_reports (
    id uuid NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    deleted_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,
    version bigint NOT NULL,
    description character varying(1024),
    moderation_comment character varying(1024),
    reason character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    post_id uuid NOT NULL,
    reporter_id uuid NOT NULL,
    CONSTRAINT post_reports_reason_check CHECK (((reason)::text = ANY ((ARRAY['SPAM'::character varying, 'INAPPROPRIATE'::character varying, 'HATE_SPEECH'::character varying, 'SCAM'::character varying, 'OTHER'::character varying])::text[]))),
    CONSTRAINT post_reports_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'VALID'::character varying, 'INVALID'::character varying])::text[])))
);


ALTER TABLE public.post_reports OWNER TO postgres;

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
    status character varying(255) DEFAULT 'ACTIVE'::character varying NOT NULL,
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
    role character varying(255) DEFAULT 'USER'::character varying NOT NULL,
    CONSTRAINT users_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING_VERIFICATION'::character varying, 'ACTIVE'::character varying, 'SUSPENDED'::character varying, 'DEACTIVATED'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: admin_action_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_action_logs (id, created_at, deleted_at, updated_at, version, action_type, note, target_id, admin_id) FROM stdin;
\.


--
-- Data for Name: ai_suggestions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ai_suggestions (id, user_id, suggestion_type, target_id, content, confidence_score, is_shown, is_used, user_feedback, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (created_at, deleted_at, updated_at, version, id, action, actor_id, payload, resource) FROM stdin;
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, room_id, sender_id, content, message_type, media_urls, media_thumbnails, location_lat, location_lng, location_name, reply_to_id, thread_id, reactions, is_edited, edited_at, is_deleted, deleted_at, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: chat_room_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_room_members (id, room_id, user_id, role, is_muted, muted_until, notifications_enabled, last_read_at, last_read_message_id, unread_count, joined_at) FROM stdin;
\.


--
-- Data for Name: chat_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_rooms (id, room_type, name, description, avatar_url, event_id, group_id, is_active, is_muted_all, slow_mode_seconds, message_count, member_count, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: connection_type_metadata; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.connection_type_metadata (connection_type, requires_mutual_consent, supports_group, is_business_related, max_pending_days, allows_intro_message, display_name_en, display_name_vi) FROM stdin;
friend	t	f	f	30	t	Friend	Bạn bè
romantic	t	f	f	7	t	Romantic Interest	Hẹn hò
activity_partner	t	t	f	14	t	Activity Partner	Bạn hoạt động
study_partner	t	t	f	14	t	Study Partner	Bạn học
tutor	f	f	f	30	t	Tutor	Gia sư
mentor	t	f	t	30	t	Mentor	Người hướng dẫn
mentee	t	f	t	30	t	Mentee	Học viên
colleague	t	f	t	30	t	Colleague	Đồng nghiệp
business	t	f	t	30	t	Business Contact	Đối tác kinh doanh
roommate	t	t	f	14	t	Roommate	Bạn cùng phòng
acquaintance	t	f	f	7	f	Acquaintance	Quen biết
service_provider	f	f	t	30	t	Service Provider	Nhà cung cấp
\.


--
-- Data for Name: connections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.connections (match_score, receiver_follows_requester, requester_follows_receiver, created_at, deleted_at, expires_at, requested_at, responded_at, updated_at, version, id, receiver_id, requester_id, connection_type, intro_message, match_source, response_message, status, matched_interests, date_created_at, date_description, date_latitude, date_location_address, date_location_name, date_longitude, date_scheduled_at, date_status, feedback_status) FROM stdin;
\N	f	t	2025-12-18 12:29:36.331915+00	\N	\N	2025-12-18 12:29:36.331038	\N	2025-12-20 06:40:06.353805+00	1	f018ed8a-ea12-475d-aed6-13b29e4a848d	c986c222-633d-4b87-b1c6-af938fb558e7	1abd3aa6-3068-469f-9c45-a38ad7076fdf	FRIEND	\N	SWIPE	\N	CANCELLED	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\N	f	t	2025-12-20 06:45:13.30059+00	\N	\N	2025-12-20 06:45:13.300224	\N	2025-12-20 08:27:07.755805+00	2	a03dccea-ab15-40a6-bd0e-7996a8d156da	c986c222-633d-4b87-b1c6-af938fb558e7	05479f65-5810-4a18-8454-3f9eb850157e	FRIEND	\N	SWIPE	\N	CANCELLED	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\N	f	t	2025-12-13 11:30:39.492486+00	\N	\N	2025-12-13 11:30:39.488827	\N	2025-12-20 08:36:50.664721+00	2	a16fc649-e353-4007-83ec-9c60d3df58ed	2fbff3dd-1da7-472e-9273-c495a1c0b870	c986c222-633d-4b87-b1c6-af938fb558e7	FRIEND	\N	SWIPE	\N	CANCELLED	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\N	f	t	2025-12-18 10:08:58.802815+00	\N	\N	2025-12-18 10:08:58.801705	\N	2025-12-20 08:36:52.33873+00	1	af178ce5-d930-4730-9678-a8df8514189b	3f6ef7ed-8e2f-409a-877e-056971006476	c986c222-633d-4b87-b1c6-af938fb558e7	FRIEND	\N	SWIPE	\N	CANCELLED	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: content_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.content_reports (id, reporter_id, content_type, content_id, reason, description, status, created_at, resolved_at) FROM stdin;
\.


--
-- Data for Name: conversation_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversation_members (is_admin, created_at, deleted_at, updated_at, version, conversation_id, id, member_id, role, joined_at, left_at) FROM stdin;
f	2025-12-13 09:06:42.248059+00	\N	2025-12-13 09:06:42.248059+00	0	29991d3c-2697-4c50-8918-bf97c7a4e463	9e8e2968-8477-473c-b711-ec17f98699d6	c986c222-633d-4b87-b1c6-af938fb558e7	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-13 09:06:42.253592+00	\N	2025-12-13 09:06:42.253592+00	0	29991d3c-2697-4c50-8918-bf97c7a4e463	95ffca36-fd10-4c72-b3fb-587718a61d04	2fbff3dd-1da7-472e-9273-c495a1c0b870	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-15 09:33:29.032382+00	\N	2025-12-15 09:33:29.032382+00	0	3e04052d-6eb5-48c9-8278-ad235b7aac57	8e823534-46cf-4016-a590-ab3e7573ac98	2fbff3dd-1da7-472e-9273-c495a1c0b870	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-15 09:33:29.03284+00	\N	2025-12-15 09:33:29.03284+00	0	3e04052d-6eb5-48c9-8278-ad235b7aac57	af37c72a-c354-4a3a-acde-37822ebe4ddd	1abd3aa6-3068-469f-9c45-a38ad7076fdf	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-22 07:55:09.957178+00	\N	2025-12-22 07:55:09.957178+00	0	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	75068229-3e96-453e-b706-53500939bf93	c986c222-633d-4b87-b1c6-af938fb558e7	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-22 07:55:09.958043+00	\N	2025-12-22 07:55:09.958043+00	0	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	322f1b5c-da0f-4ec1-8b1e-a2a686c6de9a	1abd3aa6-3068-469f-9c45-a38ad7076fdf	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-22 09:28:57.83039+00	\N	2025-12-22 09:28:57.83039+00	0	bfaac5ca-ec5c-49b3-bec5-67112cf1226b	a4525051-4785-44d0-b5c0-1056e0866bba	2fbff3dd-1da7-472e-9273-c495a1c0b870	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-22 09:28:57.831963+00	\N	2025-12-22 09:28:57.831963+00	0	bfaac5ca-ec5c-49b3-bec5-67112cf1226b	fdbcceb8-011e-452b-8797-397d35b4fbf0	c986c222-633d-4b87-b1c6-af938fb558e7	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-22 09:32:10.999223+00	\N	2025-12-22 09:32:10.999223+00	0	aa1aee4a-d432-4187-a9c7-37765fa9068e	8dd2ff79-efe7-410b-8149-09009b6b1593	1abd3aa6-3068-469f-9c45-a38ad7076fdf	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-22 09:32:10.999643+00	\N	2025-12-22 09:32:10.999643+00	0	aa1aee4a-d432-4187-a9c7-37765fa9068e	8d31643d-a9bd-4fbf-a2e8-5c6fe6256844	2fbff3dd-1da7-472e-9273-c495a1c0b870	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-22 10:29:22.692979+00	\N	2025-12-22 10:29:22.692979+00	0	610f5c93-e91f-40ca-ad84-2e9d36b996f8	42234ca4-37e0-4603-90da-749f2e6638fa	2fbff3dd-1da7-472e-9273-c495a1c0b870	MEMBER	2025-12-24 08:23:10.695918+00	\N
f	2025-12-22 10:29:22.69369+00	\N	2025-12-22 10:29:22.69369+00	0	610f5c93-e91f-40ca-ad84-2e9d36b996f8	19123ac1-2ef4-4de7-a917-5b8ca4bf7706	1abd3aa6-3068-469f-9c45-a38ad7076fdf	MEMBER	2025-12-24 08:23:10.695918+00	\N
t	2025-12-24 09:17:07.596561+00	\N	2025-12-24 09:17:07.596561+00	0	d5558371-366e-4422-817b-b88050f23296	c5cc4228-c030-4244-8a91-9ac191647a35	c986c222-633d-4b87-b1c6-af938fb558e7	ORGANIZER	2025-12-24 09:17:07.586983+00	\N
f	2025-12-24 09:17:07.737709+00	\N	2025-12-24 09:17:07.737709+00	0	d5558371-366e-4422-817b-b88050f23296	4f8b9040-5164-4219-8e06-be26df6627b9	1abd3aa6-3068-469f-9c45-a38ad7076fdf	MEMBER	2025-12-24 09:17:07.734352+00	\N
f	2025-12-24 09:17:09.943178+00	\N	2025-12-24 09:17:09.943178+00	0	d5558371-366e-4422-817b-b88050f23296	dc173f22-4c89-42fe-851c-8a996e490d14	2fbff3dd-1da7-472e-9273-c495a1c0b870	MEMBER	2025-12-24 09:17:09.936539+00	\N
f	2025-12-25 14:43:36.959777+00	\N	2025-12-25 14:43:36.959777+00	0	7e9bf206-9168-48fb-8f34-f23ab2e47cb9	1e5a5087-febc-48e7-b202-33b210a80923	1abd3aa6-3068-469f-9c45-a38ad7076fdf	MEMBER	\N	\N
f	2025-12-25 14:43:36.960162+00	\N	2025-12-25 14:43:36.960162+00	0	7e9bf206-9168-48fb-8f34-f23ab2e47cb9	a667e6d8-bfa5-47fa-be21-3e6fc6e14ff3	2fbff3dd-1da7-472e-9273-c495a1c0b870	MEMBER	\N	\N
f	2025-12-25 16:21:43.035953+00	\N	2025-12-25 16:21:43.035953+00	0	1e780ce2-fd92-4858-a1d9-7c83201ede10	f5e93bdd-f907-4240-a971-3e5a4205b1fd	05479f65-5810-4a18-8454-3f9eb850157e	MEMBER	\N	\N
f	2025-12-25 16:21:43.036523+00	\N	2025-12-25 16:21:43.036523+00	0	1e780ce2-fd92-4858-a1d9-7c83201ede10	c59eba3c-b215-4442-b57a-0755be73d2ed	1abd3aa6-3068-469f-9c45-a38ad7076fdf	MEMBER	\N	\N
f	2025-12-25 17:00:51.384755+00	\N	2025-12-25 17:00:51.384755+00	0	d2afecd1-58c3-4467-a7eb-8e91e839c72d	dddd350f-d1f6-4d0a-bbe1-3be51369de4c	9ef82fed-3a9c-4087-ab31-c47682ed420e	MEMBER	\N	\N
f	2025-12-25 17:00:51.385406+00	\N	2025-12-25 17:00:51.385406+00	0	d2afecd1-58c3-4467-a7eb-8e91e839c72d	6264901e-6414-4c0f-99d8-0e7eebae8cda	c986c222-633d-4b87-b1c6-af938fb558e7	MEMBER	\N	\N
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversations (created_at, deleted_at, updated_at, version, id, title, type, meet_match_id, meetup_id, is_archived) FROM stdin;
2025-12-13 09:06:42.243366+00	\N	2025-12-13 09:06:42.243366+00	0	29991d3c-2697-4c50-8918-bf97c7a4e463	\N	DIRECT	\N	\N	f
2025-12-15 09:33:29.030255+00	\N	2025-12-15 09:33:29.030255+00	0	3e04052d-6eb5-48c9-8278-ad235b7aac57	\N	DIRECT	\N	\N	f
2025-12-22 07:55:09.942727+00	\N	2025-12-22 07:55:09.942727+00	0	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	Chat: s	DIRECT	5e39a261-a2d8-4c20-8433-919e6d38e704	\N	f
2025-12-22 09:28:57.80732+00	\N	2025-12-22 09:28:57.80732+00	0	bfaac5ca-ec5c-49b3-bec5-67112cf1226b	Chat: play game	DIRECT	e8d7f359-13fe-435b-b319-0ad2e4cc5ea3	\N	f
2025-12-22 09:32:10.998693+00	\N	2025-12-22 09:32:10.998693+00	0	aa1aee4a-d432-4187-a9c7-37765fa9068e	Chat: newest	DIRECT	6bf7e117-b731-42ec-b42e-caf0f258246d	\N	f
2025-12-22 10:29:22.691539+00	\N	2025-12-22 10:29:22.691539+00	0	610f5c93-e91f-40ca-ad84-2e9d36b996f8	Chat: play game	DIRECT	e8566e19-3f5a-4dc1-bf31-60468cbb39a8	\N	f
2025-12-24 09:17:07.58035+00	\N	2025-12-24 09:17:07.58035+00	0	d5558371-366e-4422-817b-b88050f23296	play somthing for 5 people	GROUP_MEETUP	\N	f08d181d-d538-4b24-8f8d-f51cc94b2dd2	f
2025-12-25 14:43:36.95861+00	\N	2025-12-25 14:43:36.95861+00	0	7e9bf206-9168-48fb-8f34-f23ab2e47cb9	Chat: a	DIRECT	f224d5d9-1b8b-458d-b27d-123dc0ad2b3c	\N	f
2025-12-25 16:21:43.034448+00	\N	2025-12-25 16:21:43.034448+00	0	1e780ce2-fd92-4858-a1d9-7c83201ede10	\N	DIRECT	\N	\N	f
2025-12-25 17:00:51.382602+00	\N	2025-12-25 17:00:51.382602+00	0	d2afecd1-58c3-4467-a7eb-8e91e839c72d	\N	DIRECT	\N	\N	f
\.


--
-- Data for Name: date_feedback; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.date_feedback (id, did_meet, feedback_text, no_show_reason, rating, submitted_at, connection_id, user_id) FROM stdin;
\.


--
-- Data for Name: date_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.date_plans (id, connection_type, created_at, description, duration_minutes, is_public, latitude, longitude, max_proposals, place_address, place_name, place_type, proposal_count, scheduled_at, status, title, updated_at, owner_id, partner_id) FROM stdin;
\.


--
-- Data for Name: date_proposals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.date_proposals (id, created_at, message, proposed_time, status, updated_at, date_id, proposer_id) FROM stdin;
\.


--
-- Data for Name: emergency_contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.emergency_contacts (id, user_id, name, phone, email, relationship, is_primary, created_at) FROM stdin;
\.


--
-- Data for Name: event_invitations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_invitations (id, event_id, occurrence_id, invited_user_id, invited_by, status, message, invited_at, responded_at) FROM stdin;
\.


--
-- Data for Name: event_occurrences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_occurrences (id, event_id, occurrence_number, start_time, end_time, status, max_participants, current_participants, waitlist_count, override_fields, chat_room_id, is_cancelled, cancelled_at, cancellation_reason, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: event_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_participants (id, event_id, occurrence_id, user_id, status, intro_message, requested_at, responded_at, responded_by, response_message, proposed_alternative_time, alternative_message, waitlist_position, promoted_from_waitlist_at, checked_in_at, checked_out_at, check_in_location_lat, check_in_location_lng, recurring_signup_type) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (age_max, age_min, allow_waitlist, auto_approve_verified, current_participants, duration_minutes, is_online, is_recurring, join_deadline_hours, location_lat, location_lng, max_participants, min_participants, min_reputation_score, requires_approval, waitlist_count, created_at, deleted_at, end_time, start_time, updated_at, version, created_by, id, activity_type, cover_image_url, description, gender_preference, location_address, location_name, location_place_id, online_meeting_url, recurrence_rule, slug, status, timezone, title, visibility, required_verifications) FROM stdin;
\.


--
-- Data for Name: file_storage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.file_storage (created_at, deleted_at, size_bytes, updated_at, version, id, bucket, content_type, file_name, media_type, object_key) FROM stdin;
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	init	SQL	V1__init.sql	-1715361318	postgres	2025-12-13 08:43:52.327715	3809	t
2	2	add date and meetup tables	SQL	V2__add_date_and_meetup_tables.sql	751091182	postgres	2025-12-18 13:46:40.871398	1266	t
\.


--
-- Data for Name: group_join_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_join_requests (id, group_id, user_id, status, message, requested_at, responded_at, responded_by, response_message) FROM stdin;
\.


--
-- Data for Name: group_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_members (id, group_id, user_id, role, joined_at, invited_by, approved_by, notifications_enabled, is_muted, nickname, last_active_at, messages_count, events_attended) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, name, slug, description, cover_image_url, icon_url, group_type, visibility, location_lat, location_lng, location_name, rules, welcome_message, max_members, requires_approval, min_age, allowed_genders, min_reputation_score, min_events_attended, member_count, active_member_count, total_events, chat_enabled, chat_room_id, tags, is_featured, is_verified, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: hashtags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hashtags (created_at, deleted_at, updated_at, usage_count, version, id, tag) FROM stdin;
\.


--
-- Data for Name: match_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.match_scores (activity_score, interest_score, location_score, total_score, created_at, deleted_at, updated_at, version, id, user_id_1, user_id_2, common_interests) FROM stdin;
\.


--
-- Data for Name: meetup_attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meetup_attendance (id, meetup_id, user_id, status, confirmed_at, feedback, rating, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: meetup_confirmations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meetup_confirmations (id, confirmed_at, notes, result, meetup_match_id, user_id, comment, rating) FROM stdin;
\.


--
-- Data for Name: meetup_matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meetup_matches (id, conversation_id, created_at, message, responded_at, status, meetup_id, user_id) FROM stdin;
5e39a261-a2d8-4c20-8433-919e6d38e704	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	2025-12-22 06:47:09.417574+00	halo	2025-12-22 07:55:09.91905+00	ACCEPTED	1b879f3f-c9cd-4e26-a8d2-31fdf336267e	1abd3aa6-3068-469f-9c45-a38ad7076fdf
e8d7f359-13fe-435b-b319-0ad2e4cc5ea3	bfaac5ca-ec5c-49b3-bec5-67112cf1226b	2025-12-22 09:04:07.020678+00	ssss	\N	PENDING	13131f8a-6814-4340-bdf2-9af61dc4b52d	c986c222-633d-4b87-b1c6-af938fb558e7
6bf7e117-b731-42ec-b42e-caf0f258246d	aa1aee4a-d432-4187-a9c7-37765fa9068e	2025-12-22 09:32:03.585273+00	need to play	2025-12-22 09:32:10.993957+00	ACCEPTED	d353d6f5-9b0b-4c22-9817-bcad01cd7e1e	2fbff3dd-1da7-472e-9273-c495a1c0b870
e8566e19-3f5a-4dc1-bf31-60468cbb39a8	610f5c93-e91f-40ca-ad84-2e9d36b996f8	2025-12-22 09:04:13.220467+00	eeeeee	\N	PENDING	13131f8a-6814-4340-bdf2-9af61dc4b52d	1abd3aa6-3068-469f-9c45-a38ad7076fdf
f7680f17-1fd9-452b-826f-66912208f3e2	d5558371-366e-4422-817b-b88050f23296	2025-12-24 08:56:52.585851+00	people2	2025-12-24 09:17:07.511888+00	ACCEPTED	f08d181d-d538-4b24-8f8d-f51cc94b2dd2	1abd3aa6-3068-469f-9c45-a38ad7076fdf
96e53810-00b2-4dc3-bd2b-64f50d97485f	d5558371-366e-4422-817b-b88050f23296	2025-12-24 08:56:25.588127+00	1 people	2025-12-24 09:17:09.901616+00	ACCEPTED	f08d181d-d538-4b24-8f8d-f51cc94b2dd2	2fbff3dd-1da7-472e-9273-c495a1c0b870
6c88d667-e579-459e-9be1-b8c8b3b883b7	\N	2025-12-24 10:08:15.212792+00	h	\N	PENDING	13131f8a-6814-4340-bdf2-9af61dc4b52d	05479f65-5810-4a18-8454-3f9eb850157e
f224d5d9-1b8b-458d-b27d-123dc0ad2b3c	7e9bf206-9168-48fb-8f34-f23ab2e47cb9	2025-12-22 08:13:22.386451+00	helo im rich	2025-12-25 15:24:23.134852+00	ACCEPTED	362eddaf-cc35-4744-869f-22203d1d8e86	2fbff3dd-1da7-472e-9273-c495a1c0b870
1ea30c4c-a270-42c1-9542-28d912fe4f9c	\N	2025-12-22 06:47:19.207736+00	sss	2025-12-25 15:24:23.281488+00	REJECTED	362eddaf-cc35-4744-869f-22203d1d8e86	c986c222-633d-4b87-b1c6-af938fb558e7
\.


--
-- Data for Name: meetup_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meetup_participants (meetup_id, user_id) FROM stdin;
1b879f3f-c9cd-4e26-a8d2-31fdf336267e	1abd3aa6-3068-469f-9c45-a38ad7076fdf
d353d6f5-9b0b-4c22-9817-bcad01cd7e1e	2fbff3dd-1da7-472e-9273-c495a1c0b870
f08d181d-d538-4b24-8f8d-f51cc94b2dd2	1abd3aa6-3068-469f-9c45-a38ad7076fdf
f08d181d-d538-4b24-8f8d-f51cc94b2dd2	2fbff3dd-1da7-472e-9273-c495a1c0b870
362eddaf-cc35-4744-869f-22203d1d8e86	2fbff3dd-1da7-472e-9273-c495a1c0b870
\.


--
-- Data for Name: meetups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meetups (id, category, created_at, description, duration_minutes, latitude, location, longitude, max_participants, scheduled_at, status, title, updated_at, organizer_id, confirmation_sent_at, confirmation_status, expires_at, meet_type, organizer_confirmed, participant_confirmed) FROM stdin;
187ce8e1-2937-4c22-99da-0b3ed524ac41	Music	2025-12-21 14:05:31.149566+00	ssss	120	21.0285	ss	105.8542	1	2025-12-22 21:05:00+00	CANCELLED	sdss	2025-12-22 06:35:08.393813+00	c986c222-633d-4b87-b1c6-af938fb558e7	\N	NONE	\N	ONE_TO_ONE	f	f
a4d7d32b-6e23-4758-b5e7-3fe04ddabf65	Gaming	2025-12-21 13:57:12.749733+00	zzz	120	21.0285	zzz	105.8542	1	2025-12-22 20:57:00+00	CANCELLED	zz	2025-12-22 06:40:02.361612+00	c986c222-633d-4b87-b1c6-af938fb558e7	\N	NONE	\N	ONE_TO_ONE	f	f
f27c9c72-3553-47c7-8bba-967330ca3d9f	Gaming	2025-12-21 13:47:02.54994+00	ddd	120	21.0285	dddd	105.8542	1	2025-12-22 20:47:00+00	CANCELLED	ddd	2025-12-22 06:43:33.856565+00	c986c222-633d-4b87-b1c6-af938fb558e7	\N	NONE	\N	ONE_TO_ONE	f	f
585f4ad3-aebc-4395-be06-d40fc600b9fc	Music	2025-12-21 13:42:53.79558+00	ssss	120	21.0285	sssss	105.8542	1	2025-12-22 20:42:00+00	CANCELLED	sss	2025-12-22 06:43:39.299897+00	c986c222-633d-4b87-b1c6-af938fb558e7	\N	NONE	\N	ONE_TO_ONE	f	f
ffaf6173-a672-4172-846f-37ef113efdf3	Music	2025-12-21 13:37:18.218845+00	s	120	21.0285	sss	105.8542	1	2025-12-22 20:37:00+00	CANCELLED	s	2025-12-22 06:43:43.291422+00	c986c222-633d-4b87-b1c6-af938fb558e7	\N	NONE	\N	ONE_TO_ONE	f	f
0d63f262-f2e1-488f-9e5b-9a820927fed8	Music	2025-12-21 13:37:51.740728+00	s	120	21.0285	sss	105.8542	1	2025-12-22 20:37:00+00	CANCELLED	s	2025-12-22 06:43:47.895059+00	c986c222-633d-4b87-b1c6-af938fb558e7	\N	NONE	\N	ONE_TO_ONE	f	f
354df7f7-bd20-4335-b86a-088ea09bb222	Art	2025-12-21 16:41:56.195432+00	\N	120	15.977901252662685	Selected Location	108.26030641088593	1	2025-12-23 23:41:00+00	CANCELLED	dđ	2025-12-22 06:46:38.776474+00	1abd3aa6-3068-469f-9c45-a38ad7076fdf	\N	NONE	\N	ONE_TO_ONE	f	f
1b879f3f-c9cd-4e26-a8d2-31fdf336267e	Music	2025-12-21 13:37:41.517411+00	s	120	21.0285	sss	105.8542	1	2025-12-22 20:37:00+00	MATCHED	s	2025-12-22 07:55:10.05321+00	c986c222-633d-4b87-b1c6-af938fb558e7	\N	NONE	\N	ONE_TO_ONE	f	f
13131f8a-6814-4340-bdf2-9af61dc4b52d	Gaming	2025-12-22 09:03:41.828767+00	play game	120	15.977719050682621	Selected Location	108.25807183922221	1	2025-12-25 16:03:00+00	OPEN	play game	2025-12-22 09:03:41.82881+00	2fbff3dd-1da7-472e-9273-c495a1c0b870	\N	NONE	\N	ONE_TO_ONE	f	f
d353d6f5-9b0b-4c22-9817-bcad01cd7e1e	Gaming	2025-12-22 09:31:37.62263+00	sssssssssssssssssssssssssssssss	120	15.978038151901677	Selected Location	108.26203360295864	5	2025-12-22 16:33:00+00	OPEN	newest	2025-12-22 09:31:37.622719+00	1abd3aa6-3068-469f-9c45-a38ad7076fdf	\N	NONE	\N	GROUP	f	f
f08d181d-d538-4b24-8f8d-f51cc94b2dd2	Art	2025-12-24 08:55:59.159351+00	play somthing for 5 people	120	15.97802220536254	Selected Location	108.2616045367161	5	2025-12-25 15:55:00+00	OPEN	play somthing for 5 people	2025-12-24 08:55:59.159448+00	c986c222-633d-4b87-b1c6-af938fb558e7	\N	NONE	\N	GROUP	f	f
362eddaf-cc35-4744-869f-22203d1d8e86	Music	2025-12-21 13:47:58.698719+00	a	120	21.0285	aaaa	105.8542	1	2025-12-30 20:47:00+00	MATCHED	a	2025-12-25 15:24:23.314176+00	1abd3aa6-3068-469f-9c45-a38ad7076fdf	\N	NONE	\N	ONE_TO_ONE	f	f
\.


--
-- Data for Name: message_media; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_media (created_at, deleted_at, updated_at, version, id, message_id, media_type, object_key) FROM stdin;
2025-12-15 09:33:35.402362+00	\N	2025-12-15 09:33:35.402362+00	0	63d85380-9e91-44a5-b264-3e7921ee353e	df0d4c75-293a-4bc9-96ab-d66a3251d19f	IMAGE	a8a2cc44-8a7a-4531-8f78-c0135354a147-scaled_character_12.png
2025-12-22 09:32:39.771748+00	\N	2025-12-22 09:32:39.771748+00	0	47d1c9fb-7201-46b5-90b0-c85d7bd163cd	e7365a6f-76c1-47f5-b7a3-989381ac6d13	IMAGE	4c9b2c3c-db2f-4e89-8574-793ffb84a828-scaled_420198238_122125069352055338_176253627461992973_n.jpg
2025-12-24 08:00:53.040674+00	\N	2025-12-24 08:00:53.040674+00	0	7f4c7da8-ff53-4386-ba1d-c2a213480718	c1f068c5-b6ee-4e42-989c-38d8dfc9b219	IMAGE	0a5a1900-d928-447e-9c0f-8faf944c6119-scaled_IMG_1615.jpg
2025-12-24 09:18:09.420888+00	\N	2025-12-24 09:18:09.420888+00	0	3bc88e8c-1663-4cbb-914b-9ea9700bd120	1348183f-5b69-4d9a-97a6-7d041fa0792b	IMAGE	823ea792-8984-4995-b6d4-99e1e52f4642-scaled_420198238_122125069352055338_176253627461992973_n.jpg
2025-12-24 09:18:24.009153+00	\N	2025-12-24 09:18:24.009153+00	0	05a628e8-c3b0-47be-a028-b4468fa0819d	3b4af64b-baaa-4728-876a-987d2c9d962e	IMAGE	07c2cbc0-88c4-4f82-bae3-544cdcf0a8b8-scaled_IMG_1615.jpg
2025-12-25 14:39:54.261907+00	\N	2025-12-25 14:39:54.261907+00	0	8556f61a-5f41-4bc6-bd15-1274d30c0d5b	82ea93c2-2c82-4e6c-b153-b95120fae18c	IMAGE	ab1c4f82-433b-40fd-9074-3f8d7de3f861-scaled_1000039456.jpg
2025-12-25 14:40:00.453277+00	\N	2025-12-25 14:40:00.453277+00	0	57f71af5-bc3e-43f5-8369-a1b863eacb5a	44a67496-5d78-423d-9dff-4c0abe2d7208	IMAGE	c5a64e44-d579-4cf4-ba90-f565c635f14a-scaled_1000039449.jpg
2025-12-25 15:22:18.726339+00	\N	2025-12-25 15:22:18.726339+00	0	4a88b343-c502-4863-a98f-372ce897926c	33707e2a-6036-4b7b-81de-1cc1b3359bc7	IMAGE	e850534c-1e33-43e6-91ea-933a3ae463e8-scaled_1000039459.jpg
2025-12-25 16:21:37.742302+00	\N	2025-12-25 16:21:37.742302+00	0	4c7b242d-51f8-44d7-8375-2738ed18c7b2	5bcf12f5-9914-4a51-b9f3-4ce2d51bccc9	IMAGE	3186dd5c-af3d-4b5f-9268-f8c9a465842a-scaled_1000039452.jpg
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (created_at, deleted_at, updated_at, version, reaction, conversation_id, id, sender_id, content, status) FROM stdin;
2025-12-13 09:06:48.235415+00	\N	2025-12-13 09:06:48.235415+00	0	\N	29991d3c-2697-4c50-8918-bf97c7a4e463	38aa3ef5-2122-4713-8070-c21e1841011c	c986c222-633d-4b87-b1c6-af938fb558e7	halo	SENT
2025-12-15 06:30:47.114286+00	\N	2025-12-15 06:30:47.114286+00	0	\N	29991d3c-2697-4c50-8918-bf97c7a4e463	a6c95506-855b-43a9-95af-a3c7ccf99959	2fbff3dd-1da7-472e-9273-c495a1c0b870	halo	SENT
2025-12-15 09:33:35.272819+00	\N	2025-12-15 09:33:35.272819+00	0	\N	3e04052d-6eb5-48c9-8278-ad235b7aac57	df0d4c75-293a-4bc9-96ab-d66a3251d19f	1abd3aa6-3068-469f-9c45-a38ad7076fdf		SENT
2025-12-22 08:10:57.147897+00	\N	2025-12-22 08:10:57.147897+00	0	\N	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	3920006e-ab49-4eb4-bb9d-cb1aef3e787e	c986c222-633d-4b87-b1c6-af938fb558e7	hello	SENT
2025-12-22 09:32:34.755202+00	\N	2025-12-22 09:32:34.755202+00	0	\N	aa1aee4a-d432-4187-a9c7-37765fa9068e	a9a555e7-59ab-4823-b693-912504ff4f26	1abd3aa6-3068-469f-9c45-a38ad7076fdf	good bro	SENT
2025-12-22 09:32:39.537283+00	\N	2025-12-22 09:32:39.537283+00	0	\N	aa1aee4a-d432-4187-a9c7-37765fa9068e	e7365a6f-76c1-47f5-b7a3-989381ac6d13	1abd3aa6-3068-469f-9c45-a38ad7076fdf		SENT
2025-12-22 10:33:11.897809+00	\N	2025-12-22 10:33:11.897809+00	0	\N	610f5c93-e91f-40ca-ad84-2e9d36b996f8	46436844-ac1e-4ade-9734-bc9e62b3f4b2	2fbff3dd-1da7-472e-9273-c495a1c0b870	dd	SENT
2025-12-24 08:00:52.147713+00	\N	2025-12-24 08:00:52.147713+00	0	\N	29991d3c-2697-4c50-8918-bf97c7a4e463	c1f068c5-b6ee-4e42-989c-38d8dfc9b219	c986c222-633d-4b87-b1c6-af938fb558e7		SENT
2025-12-24 09:17:07.600578+00	\N	2025-12-24 09:17:07.600578+00	0	\N	d5558371-366e-4422-817b-b88050f23296	92969b73-5e40-4acf-8c22-d5801c0cb883	c986c222-633d-4b87-b1c6-af938fb558e7	👋 Group chat has been created for this meetup	SENT
2025-12-24 09:17:07.738838+00	\N	2025-12-24 09:17:07.738838+00	0	\N	d5558371-366e-4422-817b-b88050f23296	d6249c1f-7d05-4061-9c9d-22a9e35e8e19	1abd3aa6-3068-469f-9c45-a38ad7076fdf	👋 qqq has joined the group	SENT
2025-12-24 09:17:09.94394+00	\N	2025-12-24 09:17:09.94394+00	0	\N	d5558371-366e-4422-817b-b88050f23296	650f25e3-0689-40c1-8dbf-3102e0218671	2fbff3dd-1da7-472e-9273-c495a1c0b870	👋 ss has joined the group	SENT
2025-12-24 09:18:08.662078+00	\N	2025-12-24 09:18:08.662078+00	0	\N	d5558371-366e-4422-817b-b88050f23296	1348183f-5b69-4d9a-97a6-7d041fa0792b	2fbff3dd-1da7-472e-9273-c495a1c0b870		SENT
2025-12-24 09:18:23.905504+00	\N	2025-12-24 09:18:23.905504+00	0	\N	d5558371-366e-4422-817b-b88050f23296	3b4af64b-baaa-4728-876a-987d2c9d962e	c986c222-633d-4b87-b1c6-af938fb558e7		SENT
2025-12-25 14:39:49.894703+00	\N	2025-12-25 14:39:49.894703+00	0	\N	d5558371-366e-4422-817b-b88050f23296	310b4396-d13c-4930-9781-a77074bee784	1abd3aa6-3068-469f-9c45-a38ad7076fdf	halo	SENT
2025-12-25 14:39:54.204018+00	\N	2025-12-25 14:39:54.204018+00	0	\N	d5558371-366e-4422-817b-b88050f23296	82ea93c2-2c82-4e6c-b153-b95120fae18c	1abd3aa6-3068-469f-9c45-a38ad7076fdf		SENT
2025-12-25 14:40:00.341559+00	\N	2025-12-25 14:40:00.341559+00	0	\N	d5558371-366e-4422-817b-b88050f23296	44a67496-5d78-423d-9dff-4c0abe2d7208	1abd3aa6-3068-469f-9c45-a38ad7076fdf		SENT
2025-12-25 15:22:18.658676+00	\N	2025-12-25 15:22:18.658676+00	0	\N	7e9bf206-9168-48fb-8f34-f23ab2e47cb9	33707e2a-6036-4b7b-81de-1cc1b3359bc7	1abd3aa6-3068-469f-9c45-a38ad7076fdf		SENT
2025-12-25 16:21:31.515476+00	\N	2025-12-25 16:21:31.515476+00	0	\N	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	dfbace92-4e7a-42a4-96a7-07e8c8657ac0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	halo	SENT
2025-12-25 16:21:37.662831+00	\N	2025-12-25 16:21:37.662831+00	0	\N	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	5bcf12f5-9914-4a51-b9f3-4ce2d51bccc9	1abd3aa6-3068-469f-9c45-a38ad7076fdf		SENT
2025-12-25 16:21:46.629685+00	\N	2025-12-25 16:21:46.629685+00	0	\N	1e780ce2-fd92-4858-a1d9-7c83201ede10	9865c8f5-1fcb-498e-8e3c-f32f5ae6e59a	1abd3aa6-3068-469f-9c45-a38ad7076fdf	halo	SENT
2025-12-25 16:21:53.43941+00	\N	2025-12-25 16:21:53.43941+00	0	\N	d5558371-366e-4422-817b-b88050f23296	6b73c4dd-d545-4340-9473-806ea75fa689	1abd3aa6-3068-469f-9c45-a38ad7076fdf	fun	SENT
2025-12-25 17:00:56.758145+00	\N	2025-12-25 17:00:56.758145+00	0	\N	d2afecd1-58c3-4467-a7eb-8e91e839c72d	640dc08a-2aba-4ab2-827d-1c0ce84a0a28	c986c222-633d-4b87-b1c6-af938fb558e7	hello cậu	SENT
2025-12-25 17:12:45.479854+00	\N	2025-12-25 17:12:45.479854+00	0	\N	29991d3c-2697-4c50-8918-bf97c7a4e463	4d16e61f-1214-4d9b-8c7f-215a7b824070	c986c222-633d-4b87-b1c6-af938fb558e7	alo	SENT
\.


--
-- Data for Name: moderation_actions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.moderation_actions (id, target_user_id, action_type, action_reason, duration_hours, expires_at, performed_by, related_report_id, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (created_at, deleted_at, updated_at, version, id, recipient_id, reference_id, message, status, type) FROM stdin;
2025-12-13 09:05:46.409403+00	\N	2025-12-13 09:06:30.739667+00	1	09afd4b7-cf51-4253-bc3c-1138ec9015c1	c986c222-633d-4b87-b1c6-af938fb558e7	2fbff3dd-1da7-472e-9273-c495a1c0b870	sss đã bắt đầu theo dõi bạn	READ	FOLLOW
2025-12-13 09:06:48.2457+00	\N	2025-12-13 09:06:48.2457+00	0	87ecdf2f-3c02-406e-a365-cff6ed93610e	2fbff3dd-1da7-472e-9273-c495a1c0b870	29991d3c-2697-4c50-8918-bf97c7a4e463	halo	UNREAD	MESSAGE
2025-12-15 09:32:26.634435+00	\N	2025-12-15 09:32:26.634435+00	0	c0346edc-d5f2-486d-9a3c-eb58974faa94	2fbff3dd-1da7-472e-9273-c495a1c0b870	1abd3aa6-3068-469f-9c45-a38ad7076fdf	qqq đã bắt đầu theo dõi bạn	UNREAD	FOLLOW
2025-12-13 09:06:37.293474+00	\N	2025-12-15 09:32:34.523245+00	1	60f0ba8f-5453-4373-8659-9ff629233727	2fbff3dd-1da7-472e-9273-c495a1c0b870	c986c222-633d-4b87-b1c6-af938fb558e7	luan đã bắt đầu theo dõi bạn	READ	FOLLOW
2025-12-15 09:33:35.41271+00	\N	2025-12-15 09:33:35.41271+00	0	a8f737fc-410b-4d76-a32f-e2461220bcd6	2fbff3dd-1da7-472e-9273-c495a1c0b870	3e04052d-6eb5-48c9-8278-ad235b7aac57	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-15 09:32:44.752809+00	\N	2025-12-17 05:56:54.405958+00	1	db150d12-2323-4bb8-9189-8c8246e7ee8e	1abd3aa6-3068-469f-9c45-a38ad7076fdf	2fbff3dd-1da7-472e-9273-c495a1c0b870	sss đã bắt đầu theo dõi bạn	READ	FOLLOW
2025-12-16 06:37:28.204907+00	\N	2025-12-17 08:22:45.221+00	1	ea2569d7-2621-4197-8983-1daa642f09ad	c986c222-633d-4b87-b1c6-af938fb558e7	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	qqq đã thích bài viết của bạn	READ	LIKE
2025-12-16 06:37:26.163091+00	\N	2025-12-17 08:22:46.452051+00	1	06b04ad4-4bc5-4c4d-a0dc-9558cb7974be	c986c222-633d-4b87-b1c6-af938fb558e7	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	qqq đã thích bài viết của bạn	READ	LIKE
2025-12-15 06:44:14.114934+00	\N	2025-12-17 08:22:47.055391+00	1	27d42d98-5ea2-41ca-a579-06d03a1632e1	c986c222-633d-4b87-b1c6-af938fb558e7	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	sss đã thích bài viết của bạn	READ	LIKE
2025-12-15 06:30:47.167226+00	\N	2025-12-17 08:22:47.25462+00	1	831007f9-1fe4-4d5d-8d6d-d6a1780767e7	c986c222-633d-4b87-b1c6-af938fb558e7	29991d3c-2697-4c50-8918-bf97c7a4e463	halo	READ	MESSAGE
2025-12-17 08:22:35.173169+00	\N	2025-12-17 08:22:57.536446+00	1	7d1b3b40-fe0d-4387-8ccd-3d1df6a74f0c	c986c222-633d-4b87-b1c6-af938fb558e7	1abd3aa6-3068-469f-9c45-a38ad7076fdf	qqq đã bắt đầu theo dõi bạn	READ	FOLLOW
2025-12-17 09:19:34.117912+00	\N	2025-12-17 09:19:34.117912+00	0	ccbfb70f-9cda-4dbf-b214-2937dc4c944d	c986c222-633d-4b87-b1c6-af938fb558e7	3f6ef7ed-8e2f-409a-877e-056971006476	rrr đã bắt đầu theo dõi bạn	UNREAD	FOLLOW
2025-12-18 08:11:59.294554+00	\N	2025-12-18 08:11:59.294554+00	0	1a17d8d9-621a-49c1-96b9-486f7b7172b4	c986c222-633d-4b87-b1c6-af938fb558e7	d8ea3c88-e11a-4e96-a194-ace0a16931cb	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-18 08:13:01.277899+00	\N	2025-12-18 08:13:01.277899+00	0	b6e71be0-bbd5-4623-acc3-db87ee84c232	c986c222-633d-4b87-b1c6-af938fb558e7	523f2954-30c1-471e-89b0-7fd638788ac3	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-18 13:18:17.715553+00	\N	2025-12-18 13:18:17.715553+00	0	67dcc9a5-fba1-418d-aa43-84e75ee5d7e4	c986c222-633d-4b87-b1c6-af938fb558e7	1abd3aa6-3068-469f-9c45-a38ad7076fdf	qqq đã bắt đầu theo dõi bạn	UNREAD	FOLLOW
2025-12-19 05:47:09.079653+00	\N	2025-12-19 05:47:09.079653+00	0	bd137a6d-f0ee-43ea-ab6a-1d837da9d659	c986c222-633d-4b87-b1c6-af938fb558e7	9b963a1c-c133-4df0-aadf-e6bea2c1e50d	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 05:47:10.872111+00	\N	2025-12-19 05:47:10.872111+00	0	bcdc299c-7aad-4a9b-9134-95fd20fbc8e4	c986c222-633d-4b87-b1c6-af938fb558e7	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:02:31.793935+00	\N	2025-12-19 07:02:31.793935+00	0	3503da7b-1323-4d86-aec2-2dc1b1cca426	2fbff3dd-1da7-472e-9273-c495a1c0b870	5c4b1abe-29ca-421e-a95f-6def93804ee5	luan đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:02:35.481731+00	\N	2025-12-19 07:02:35.481731+00	0	ca980ce8-f8bd-4726-a061-920a84bfb58a	2fbff3dd-1da7-472e-9273-c495a1c0b870	b2023a96-a193-42ac-9de2-fe4be55d04e3	luan đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:25:27.422164+00	\N	2025-12-19 07:25:27.422164+00	0	2d8fdfd7-35be-4c2e-8429-c77501e59a55	2fbff3dd-1da7-472e-9273-c495a1c0b870	b2023a96-a193-42ac-9de2-fe4be55d04e3	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:25:29.544275+00	\N	2025-12-19 07:25:29.544275+00	0	e14f4964-9c5d-44b0-b146-48975a7f7fa6	2fbff3dd-1da7-472e-9273-c495a1c0b870	d0ee6ccb-46f1-44ce-8ae0-76934935ba51	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:25:31.510949+00	\N	2025-12-19 07:25:31.510949+00	0	f3d70cdd-8805-425e-8418-14870d61187d	2fbff3dd-1da7-472e-9273-c495a1c0b870	2140c3e5-87fb-4af8-b550-4947527f85c4	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:26:25.234903+00	\N	2025-12-19 07:26:25.234903+00	0	d969ad81-9da2-4e75-9e9e-8291501d730f	2fbff3dd-1da7-472e-9273-c495a1c0b870	c92262a6-94dc-4a2a-9236-444a0b09020f	eee đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:26:26.609575+00	\N	2025-12-19 07:26:26.609575+00	0	35f5bfa3-1e2f-4eed-a9c0-cef95cd462ef	2fbff3dd-1da7-472e-9273-c495a1c0b870	b6940166-e3ce-4374-8aaa-255442a58979	eee đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:26:27.240444+00	\N	2025-12-19 07:26:27.240444+00	0	a5723ac6-5b19-488a-af36-7dd1c423132d	2fbff3dd-1da7-472e-9273-c495a1c0b870	6fbfa0f0-9ddf-4ddb-95ff-ad53393934c5	eee đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:26:28.858178+00	\N	2025-12-19 07:26:28.858178+00	0	0bad79fd-a738-4118-89c7-4d7788c7466e	2fbff3dd-1da7-472e-9273-c495a1c0b870	a694c093-5d90-463e-ab71-79d8b6f79061	eee đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:26:30.152525+00	\N	2025-12-19 07:26:30.152525+00	0	ff11ea4c-348b-4355-8854-e79885bf5d41	2fbff3dd-1da7-472e-9273-c495a1c0b870	54db354f-8588-49b2-90aa-fbcbb6dd542c	eee đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:25:28.132497+00	\N	2025-12-19 07:27:58.836225+00	1	0378058c-d9e9-49fb-8d62-295d8f1e4ddb	2fbff3dd-1da7-472e-9273-c495a1c0b870	5c4b1abe-29ca-421e-a95f-6def93804ee5	qqq đã thích bài viết của bạn	READ	LIKE
2025-12-19 07:47:45.634747+00	\N	2025-12-19 07:47:45.634747+00	0	e32e20c3-4df2-41db-8e65-8490d172d67b	3f6ef7ed-8e2f-409a-877e-056971006476	05479f65-5810-4a18-8454-3f9eb850157e	eee đã bắt đầu theo dõi bạn	UNREAD	FOLLOW
2025-12-19 07:47:57.330502+00	\N	2025-12-19 07:47:57.330502+00	0	a77d6bc0-9892-4f1b-92d7-7993318aeaa8	c986c222-633d-4b87-b1c6-af938fb558e7	05479f65-5810-4a18-8454-3f9eb850157e	eee đã bắt đầu theo dõi bạn	UNREAD	FOLLOW
2025-12-19 07:49:48.950585+00	\N	2025-12-19 07:49:48.950585+00	0	b63efe56-160d-4394-adfb-4232b3845625	05479f65-5810-4a18-8454-3f9eb850157e	1ddd5e47-9259-4ee3-8e44-119af7d5ab46	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:49:51.941779+00	\N	2025-12-19 07:49:51.941779+00	0	596d3523-2e26-40f0-b47b-c8cbc007de60	05479f65-5810-4a18-8454-3f9eb850157e	616a3d42-4670-4ed9-9b3b-88fde8f1fe21	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:49:54.619761+00	\N	2025-12-19 07:49:54.619761+00	0	34ba5243-7350-48c6-8dd3-19c5e51ca6d9	2fbff3dd-1da7-472e-9273-c495a1c0b870	b6940166-e3ce-4374-8aaa-255442a58979	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:50:18.540549+00	\N	2025-12-19 07:50:18.540549+00	0	ccc97140-ce85-4293-b6cb-d0a711c21d54	2fbff3dd-1da7-472e-9273-c495a1c0b870	b2023a96-a193-42ac-9de2-fe4be55d04e3	eee đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:51:03.681487+00	\N	2025-12-19 07:51:03.681487+00	0	74b8b107-aad2-465c-a6ab-a1d9c40729c2	2fbff3dd-1da7-472e-9273-c495a1c0b870	c92262a6-94dc-4a2a-9236-444a0b09020f	rrr đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 07:52:16.340036+00	\N	2025-12-19 07:52:16.340036+00	0	3edadf5e-433b-4ea9-adb5-6e0e805794c7	05479f65-5810-4a18-8454-3f9eb850157e	c986c222-633d-4b87-b1c6-af938fb558e7	luan đã bắt đầu theo dõi bạn	UNREAD	FOLLOW
2025-12-19 07:28:06.539434+00	\N	2025-12-19 07:52:25.50838+00	1	6f11a893-d55e-4e26-bd1f-83b67e41f44d	05479f65-5810-4a18-8454-3f9eb850157e	2fbff3dd-1da7-472e-9273-c495a1c0b870	sss đã bắt đầu theo dõi bạn	READ	FOLLOW
2025-12-20 06:31:31.518578+00	\N	2025-12-20 06:31:31.518578+00	0	7dd3dc38-1257-4c8d-bfa5-1b4eadc5eec9	05479f65-5810-4a18-8454-3f9eb850157e	3305ec0b-5aee-440e-af28-dc46c3c2fc27	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-20 06:31:40.276491+00	\N	2025-12-20 06:31:40.276491+00	0	db031257-12c0-4d65-9b52-057c65a86d34	2fbff3dd-1da7-472e-9273-c495a1c0b870	c92262a6-94dc-4a2a-9236-444a0b09020f	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-20 07:06:43.064138+00	\N	2025-12-20 07:06:43.064138+00	0	262af80a-5c15-42c1-b9b7-60e4dc90f7b1	05479f65-5810-4a18-8454-3f9eb850157e	3305ec0b-5aee-440e-af28-dc46c3c2fc27	sss đã thích bài viết của bạn	UNREAD	LIKE
2025-12-20 09:10:56.442428+00	\N	2025-12-20 09:10:56.442428+00	0	83b5282d-03f4-4857-8765-0c16004ec209	05479f65-5810-4a18-8454-3f9eb850157e	1abd3aa6-3068-469f-9c45-a38ad7076fdf	qqq đã bắt đầu theo dõi bạn	UNREAD	FOLLOW
2025-12-20 09:11:52.535194+00	\N	2025-12-20 09:11:52.535194+00	0	a65f83b1-933a-4d12-9460-3dbadbd93c57	2fbff3dd-1da7-472e-9273-c495a1c0b870	051ab58e-69ba-4143-b327-542caf8b0265	eee đã thích bài viết của bạn	UNREAD	LIKE
2025-12-19 05:48:28.734983+00	\N	2025-12-25 16:21:11.76412+00	1	722f25c7-fe84-42e1-b772-840573d54e91	1abd3aa6-3068-469f-9c45-a38ad7076fdf	488d9dea-8553-4e49-bf2b-106c5e143613	luan đã thích bài viết của bạn	READ	LIKE
2025-12-19 07:50:55.979877+00	\N	2025-12-25 16:21:11.94805+00	1	3a9ae35e-4899-409e-9676-c84a0dc69833	1abd3aa6-3068-469f-9c45-a38ad7076fdf	3f6ef7ed-8e2f-409a-877e-056971006476	rrr đã bắt đầu theo dõi bạn	READ	FOLLOW
2025-12-19 07:50:58.6246+00	\N	2025-12-25 16:21:12.140169+00	1	0e62ea5f-032c-429f-9963-be056f8a16d0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b20e0159-de08-4174-8a71-83ebb743c360	rrr đã thích bài viết của bạn	READ	LIKE
2025-12-19 07:50:59.597895+00	\N	2025-12-25 16:21:12.353906+00	1	7ca565f6-e23d-4976-9c58-c75ede604401	1abd3aa6-3068-469f-9c45-a38ad7076fdf	06d35722-3bfd-409e-84ef-116aac88c4c3	rrr đã thích bài viết của bạn	READ	LIKE
2025-12-20 08:27:03.235377+00	\N	2025-12-25 16:21:12.870652+00	1	f17ba254-e99f-43b7-9340-2559a10333c4	1abd3aa6-3068-469f-9c45-a38ad7076fdf	05479f65-5810-4a18-8454-3f9eb850157e	eee đã bắt đầu theo dõi bạn	READ	FOLLOW
2025-12-20 14:57:12.13851+00	\N	2025-12-25 16:21:13.08894+00	1	b335a04c-f5c1-4b37-b025-5cbfba503d34	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b20e0159-de08-4174-8a71-83ebb743c360	luan đã thích bài viết của bạn	READ	LIKE
2025-12-22 09:32:34.76426+00	\N	2025-12-22 09:32:34.76426+00	0	2a72245f-e54c-4489-8460-d4f5ebe409bf	2fbff3dd-1da7-472e-9273-c495a1c0b870	aa1aee4a-d432-4187-a9c7-37765fa9068e	good bro	UNREAD	MESSAGE
2025-12-22 09:32:39.772726+00	\N	2025-12-22 09:32:39.772726+00	0	1ea3bdd6-0baf-4934-9448-feba31d14247	2fbff3dd-1da7-472e-9273-c495a1c0b870	aa1aee4a-d432-4187-a9c7-37765fa9068e	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-22 08:10:57.168927+00	\N	2025-12-22 09:33:44.884156+00	1	d0a5c87f-7c02-49d8-a032-45b82479168d	1abd3aa6-3068-469f-9c45-a38ad7076fdf	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	hello	READ	MESSAGE
2025-12-22 10:14:11.730758+00	\N	2025-12-22 10:14:11.730758+00	0	e9cee316-0fc4-4f8a-905d-df7fb26b863f	1abd3aa6-3068-469f-9c45-a38ad7076fdf	23a749de-d376-438d-8bfa-7cd162db2cd0	luan đã thích bài viết của bạn	UNREAD	LIKE
2025-12-22 10:28:56.019183+00	\N	2025-12-22 10:28:56.019183+00	0	2f72a43a-381b-4b55-9b19-16b410468dcb	c986c222-633d-4b87-b1c6-af938fb558e7	d8ea3c88-e11a-4e96-a194-ace0a16931cb	sss đã thích bài viết của bạn	UNREAD	LIKE
2025-12-22 10:30:58.72933+00	\N	2025-12-22 10:30:58.72933+00	0	4f695915-1e7b-497f-9ad6-76c97e8117d9	05479f65-5810-4a18-8454-3f9eb850157e	616a3d42-4670-4ed9-9b3b-88fde8f1fe21	sss đã thích bài viết của bạn	UNREAD	LIKE
2025-12-22 10:33:11.911105+00	\N	2025-12-22 10:33:11.911105+00	0	1c4689d5-f468-40a5-8d36-0e03fb39d5ba	1abd3aa6-3068-469f-9c45-a38ad7076fdf	610f5c93-e91f-40ca-ad84-2e9d36b996f8	dd	UNREAD	MESSAGE
2025-12-22 17:07:36.366851+00	\N	2025-12-22 17:07:36.366851+00	0	e9fd29af-df83-4db9-8627-97971695755f	2fbff3dd-1da7-472e-9273-c495a1c0b870	051ab58e-69ba-4143-b327-542caf8b0265	qqq đã thích bài viết của bạn	UNREAD	LIKE
2025-12-24 08:00:53.073687+00	\N	2025-12-24 08:00:53.073687+00	0	4f1a3d0f-b606-4188-a976-0d90c1496cda	2fbff3dd-1da7-472e-9273-c495a1c0b870	29991d3c-2697-4c50-8918-bf97c7a4e463	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-24 09:18:09.428335+00	\N	2025-12-24 09:18:09.428335+00	0	2938dd56-91b5-4442-b7e0-15a441f6531c	c986c222-633d-4b87-b1c6-af938fb558e7	d5558371-366e-4422-817b-b88050f23296	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-24 09:18:09.503096+00	\N	2025-12-24 09:18:09.503096+00	0	d5351e20-09b1-46b4-8d5e-6b374abf7240	1abd3aa6-3068-469f-9c45-a38ad7076fdf	d5558371-366e-4422-817b-b88050f23296	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-24 09:18:24.010788+00	\N	2025-12-24 09:18:24.010788+00	0	25697f48-0225-4093-848e-ce31ea55c108	1abd3aa6-3068-469f-9c45-a38ad7076fdf	d5558371-366e-4422-817b-b88050f23296	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-24 09:18:24.012937+00	\N	2025-12-24 09:18:24.012937+00	0	4b7c9eff-30cc-4114-af54-265dc81bd01d	2fbff3dd-1da7-472e-9273-c495a1c0b870	d5558371-366e-4422-817b-b88050f23296	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-25 08:39:46.269777+00	\N	2025-12-25 08:39:46.269777+00	0	b7c89d81-8a5e-45e9-b234-2663e6591475	05479f65-5810-4a18-8454-3f9eb850157e	616a3d42-4670-4ed9-9b3b-88fde8f1fe21	luan đã thích bài viết của bạn	UNREAD	LIKE
2025-12-25 14:00:52.777781+00	\N	2025-12-25 14:00:52.777781+00	0	23fa5d73-3587-4fca-af38-e390ca1aea78	05479f65-5810-4a18-8454-3f9eb850157e	3305ec0b-5aee-440e-af28-dc46c3c2fc27	luan đã thích bài viết của bạn	UNREAD	LIKE
2025-12-25 14:39:49.90294+00	\N	2025-12-25 14:39:49.90294+00	0	8dbe49bb-23ac-47fe-94b3-54002847bf70	2fbff3dd-1da7-472e-9273-c495a1c0b870	d5558371-366e-4422-817b-b88050f23296	halo	UNREAD	MESSAGE
2025-12-25 14:39:49.905737+00	\N	2025-12-25 14:39:49.905737+00	0	751148e0-41b0-4a87-8c89-4c7c4e317f2d	c986c222-633d-4b87-b1c6-af938fb558e7	d5558371-366e-4422-817b-b88050f23296	halo	UNREAD	MESSAGE
2025-12-25 14:39:54.262702+00	\N	2025-12-25 14:39:54.262702+00	0	31e279ab-8062-4510-ad36-6701437f7697	2fbff3dd-1da7-472e-9273-c495a1c0b870	d5558371-366e-4422-817b-b88050f23296	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-25 14:39:54.263233+00	\N	2025-12-25 14:39:54.263233+00	0	f4f3fb02-9b79-4803-90cc-1c9f8f53a92a	c986c222-633d-4b87-b1c6-af938fb558e7	d5558371-366e-4422-817b-b88050f23296	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-25 14:40:00.453644+00	\N	2025-12-25 14:40:00.453644+00	0	0701b290-8340-4f7e-966e-1811849cc32d	c986c222-633d-4b87-b1c6-af938fb558e7	d5558371-366e-4422-817b-b88050f23296	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-25 14:40:00.454152+00	\N	2025-12-25 14:40:00.454152+00	0	0876c45f-f3ae-4c4e-99e6-680bf61afbff	2fbff3dd-1da7-472e-9273-c495a1c0b870	d5558371-366e-4422-817b-b88050f23296	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-25 15:22:18.727605+00	\N	2025-12-25 15:22:18.727605+00	0	a6e008df-4141-40ab-bd11-1ccfd7902686	2fbff3dd-1da7-472e-9273-c495a1c0b870	7e9bf206-9168-48fb-8f34-f23ab2e47cb9	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-17 08:23:03.166486+00	\N	2025-12-25 16:21:10.940001+00	1	3575743b-cac0-4629-996f-1e8b7bcd6074	1abd3aa6-3068-469f-9c45-a38ad7076fdf	c986c222-633d-4b87-b1c6-af938fb558e7	luan đã bắt đầu theo dõi bạn	READ	FOLLOW
2025-12-19 05:47:16.609486+00	\N	2025-12-25 16:21:11.559349+00	1	a283789c-69b8-4fb9-a634-5b2739fb905d	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	luan đã thích bài viết của bạn	READ	LIKE
2025-12-25 16:21:31.519427+00	\N	2025-12-25 16:21:31.519427+00	0	86d21711-b019-44cf-a43b-7492f7b989ec	c986c222-633d-4b87-b1c6-af938fb558e7	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	halo	UNREAD	MESSAGE
2025-12-25 16:21:37.742927+00	\N	2025-12-25 16:21:37.742927+00	0	c33d1463-43d8-439a-b5e9-eceb5d6ad3cc	c986c222-633d-4b87-b1c6-af938fb558e7	ad3b14f0-0d6b-4bf1-ab40-e7848a15e513	Bạn có tin nhắn mới	UNREAD	MESSAGE
2025-12-25 16:21:46.630262+00	\N	2025-12-25 16:21:46.630262+00	0	dddfcfd3-8bef-4ed3-b206-dc7011e0aa06	05479f65-5810-4a18-8454-3f9eb850157e	1e780ce2-fd92-4858-a1d9-7c83201ede10	halo	UNREAD	MESSAGE
2025-12-25 16:21:53.440179+00	\N	2025-12-25 16:21:53.440179+00	0	3e81b1dc-ab8a-475b-9337-3f93fad27cb6	2fbff3dd-1da7-472e-9273-c495a1c0b870	d5558371-366e-4422-817b-b88050f23296	fun	UNREAD	MESSAGE
2025-12-25 16:21:53.440663+00	\N	2025-12-25 16:21:53.440663+00	0	26881acd-e714-40be-afa5-d7bc18778151	c986c222-633d-4b87-b1c6-af938fb558e7	d5558371-366e-4422-817b-b88050f23296	fun	UNREAD	MESSAGE
2025-12-25 17:00:40.872097+00	\N	2025-12-25 17:00:40.872097+00	0	26f07ec9-e727-4f4e-84df-f0dee3b44b81	9ef82fed-3a9c-4087-ab31-c47682ed420e	c986c222-633d-4b87-b1c6-af938fb558e7	luan đã bắt đầu theo dõi bạn	UNREAD	FOLLOW
2025-12-25 17:00:56.761286+00	\N	2025-12-25 17:00:56.761286+00	0	c1a103b9-86b9-4b49-9713-40b9128c65b0	9ef82fed-3a9c-4087-ab31-c47682ed420e	d2afecd1-58c3-4467-a7eb-8e91e839c72d	hello cậu	UNREAD	MESSAGE
2025-12-25 17:12:45.489534+00	\N	2025-12-25 17:12:45.489534+00	0	680df991-2f37-4c47-b3b5-64e006215735	2fbff3dd-1da7-472e-9273-c495a1c0b870	29991d3c-2697-4c50-8918-bf97c7a4e463	alo	UNREAD	MESSAGE
\.


--
-- Data for Name: pending_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pending_reviews (id, reviewer_id, reviewed_user_id, context_type, context_id, created_at, expires_at, reminder_sent_at) FROM stdin;
\.


--
-- Data for Name: post_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_comments (created_at, deleted_at, updated_at, version, author_id, id, parent_comment_id, post_id, content) FROM stdin;
2025-12-17 05:56:19.001357+00	\N	2025-12-17 05:56:19.001357+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	2e407e64-eb59-4de4-8320-688902b84453	\N	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	fun
2025-12-19 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7eef884e-4d2f-4439-8548-977ef9809018	\N	a1434472-6a39-42d1-8322-2242b0faec4c	Mình cũng nghĩ vậy
2025-12-19 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	73688e1e-3f9f-450e-a1aa-9ae1c98ac38a	\N	0315b928-6309-4fdd-9d96-4227695fb0ec	Mình cũng nghĩ vậy
2025-12-19 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	612a7914-de3d-429a-9cee-8a5cdc01c08c	\N	c319c256-93cb-48dd-83c2-05428f75fa76	Đồng cảm quá bạn ơi!
2025-12-19 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cd3edbe3-e538-47d8-989f-5463b3f29252	\N	e900c3eb-5d9e-4b0c-8869-6bc21f08c517	Hay quá á!
2025-12-19 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0140632c-bd78-4595-a8ff-da4f03007297	\N	af1518c6-25eb-4d4d-be15-047336e3b091	Mình cũng nghĩ vậy
2025-12-19 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a0168226-9f3b-4202-a09b-83186ec72a4b	\N	ed0e7b6c-058a-48bf-a2c1-3f9af8b12528	Hay quá á!
2025-12-18 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8b1f1aaa-f03e-4592-b6f7-ac5d442db69e	\N	baf47fd0-3863-46ba-8875-9963aab9bbcf	Hay quá á!
2025-12-18 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	4f8cbe7b-de10-46fa-8668-74efda9fa77f	\N	a2003227-c9ee-46e8-800f-ec2a24a90f99	Hay quá á!
2025-12-18 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a45c6674-543f-4238-af8e-78653b293138	\N	f86fd3f1-45e2-4998-b465-c10f5483f2e8	Mình cũng nghĩ vậy
2025-12-18 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	528c6209-d1fc-4fd2-b7fc-56493e7dbf4d	\N	477ea1c4-d0db-46eb-a83d-1887c3066c76	Mình cũng nghĩ vậy
2025-12-18 06:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	762af3a1-4033-41c5-b1b8-a5abdf7d41f7	\N	f86fd3f1-45e2-4998-b465-c10f5483f2e8	Đồng cảm quá bạn ơi!
2025-12-18 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	86849608-6b52-49d8-ba55-826a0b9bb2c4	\N	af1518c6-25eb-4d4d-be15-047336e3b091	Hay quá á!
2025-12-18 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	55aa3578-11be-4b8a-85ea-bb12361a2ee2	\N	a7bf8fc4-211b-4c93-91a5-2a927127e019	Hay quá á!
2025-12-18 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d6ec30b9-fb1a-4848-9a96-804c3bff6d43	\N	8bf2bf65-128f-4015-ad4d-54fd6105dcb8	Hay quá á!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	1480908d-07f1-4d08-a339-3bf5e53d23ae	\N	e900c3eb-5d9e-4b0c-8869-6bc21f08c517	Mình cũng nghĩ vậy
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5fc1df4c-5785-4db6-a56f-0cef77c87003	\N	1c53e1ce-c1dd-4d64-afba-b76249b0c44a	Đồng cảm quá bạn ơi!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c0022945-1adb-434a-9edb-76486e61ab0a	\N	018e4a26-93c8-4ac7-99b6-ffef04f067ce	Đồng cảm quá bạn ơi!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a36642a7-bbd8-4c3b-b8d9-7f82c901e604	\N	ad3b3dc5-a715-47ed-b3e6-7c7691c90292	Hay quá á!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	666d6423-f66c-43ed-9322-a9c5a2d49a38	\N	5abc8d96-0dce-46eb-9d46-1ff4f7020e00	Hay quá á!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	24b0c935-2aea-4a89-8ac3-a6ef2f81bd32	\N	f86fd3f1-45e2-4998-b465-c10f5483f2e8	Hay quá á!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a6c4fa35-606e-45c0-b7c7-05cd78336b23	\N	6f05fb7c-7f24-4fb3-8763-312ea2b52779	Mình cũng nghĩ vậy
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	9f972530-daba-4b15-8e29-ec21ebe87449	\N	477ea1c4-d0db-46eb-a83d-1887c3066c76	Đồng cảm quá bạn ơi!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5aad51c6-ca6f-460e-ab2a-96e10f34c97a	\N	a2003227-c9ee-46e8-800f-ec2a24a90f99	Mình cũng nghĩ vậy
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7a55a37d-b30c-4d9a-8cf8-75d8a12ba140	\N	0f9777a8-e365-4193-939b-8faf60ea7070	Đồng cảm quá bạn ơi!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	fdd85e39-372e-4b76-92d4-e5e8a41b9370	\N	1c53e1ce-c1dd-4d64-afba-b76249b0c44a	Hay quá á!
2025-12-17 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5e4da196-fe69-4f27-a683-5c88efd78310	\N	0dc13a3e-bf85-4410-9679-daa0e3f1db35	Đồng cảm quá bạn ơi!
2025-12-16 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0aa09163-47c3-4607-906c-24a77f1206b3	\N	fd3c0334-e400-4620-861a-1a98921c2efa	Mình cũng nghĩ vậy
2025-12-16 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c0ea6db8-702d-49d2-aaf3-989544449e90	\N	ccaa812c-5688-4086-a76f-4d29eba4aa9f	Hay quá á!
2025-12-16 05:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a2138155-8e22-4e7d-9782-a6f33644d7a5	\N	b1461a46-ad73-49e6-88aa-044ab10017e7	Đồng cảm quá bạn ơi!
2025-12-16 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8b54a702-f713-45ab-b9ba-c7b8515e9683	\N	4fd72897-13fc-4a19-9cdf-642de4b8bdc9	Mình cũng nghĩ vậy
2025-12-16 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	18946768-1514-474f-8469-a905587e7bb4	\N	a5869473-14de-4b81-bf19-c5fcbef3f988	Hay quá á!
2025-12-16 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a69a65de-9943-4128-bc0d-56f9ebdc16fa	\N	c01425b1-ca97-4d65-b2b2-25ea7366b6e9	Mình cũng nghĩ vậy
2025-12-16 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	26ac1298-24e9-4dd7-b9e7-305cec55937b	\N	f91cf04e-f6ec-4184-b2b4-a265ec5cb667	Hay quá á!
2025-12-15 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5fe18e58-c27e-4342-8cc6-0498818b6fed	\N	523f2954-30c1-471e-89b0-7fd638788ac3	Hay quá á!
2025-12-15 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f8cdd856-2ed9-4c20-abb7-771a55a2ebbe	\N	e1293ed0-26c7-40c1-979b-4431bb2d8161	Hay quá á!
2025-12-15 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e0a4cf89-dd33-4a00-bb3c-791902c2ecf5	\N	329f165e-054a-4190-9b74-d0cb07700e11	Đồng cảm quá bạn ơi!
2025-12-15 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cd95df5e-d601-4d37-93f2-20a07983df5a	\N	2e09c782-f52c-42ae-abc9-7c437db06c63	Đồng cảm quá bạn ơi!
2025-12-15 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5fa16317-8844-4c7e-94f9-2fb290402159	\N	f5449411-3ee3-47a9-aa52-7c63aae2de5c	Mình cũng nghĩ vậy
2025-12-15 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	355e30ee-2f08-4377-b73d-9596a96fc7f8	\N	2c11a22a-de1c-41e5-b3f5-5ec90d484f82	Hay quá á!
2025-12-15 04:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	91dae717-8f74-4cf2-8a4e-501805db4d52	\N	0dc13a3e-bf85-4410-9679-daa0e3f1db35	Hay quá á!
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	12ef033f-af9e-4b57-a308-41651369c36d	\N	578c949a-4092-4f8f-8a23-953ef093f6f4	Đồng cảm quá bạn ơi!
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5fadfbb6-8856-415b-a0ef-b85eae1e6e75	\N	7f83c5f7-a1f5-4704-bfb8-b098e7ca8df0	Mình cũng nghĩ vậy
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	123b856b-aadf-4420-ae81-b59d2c6ae048	\N	3b2a05d2-c06d-4580-97d9-01b3b340af85	Mình cũng nghĩ vậy
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	475f76d3-a285-404d-aa26-8c56e8f070a4	\N	018e4a26-93c8-4ac7-99b6-ffef04f067ce	Hay quá á!
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e60fb581-42cd-4903-b187-634c85608716	\N	3b2a05d2-c06d-4580-97d9-01b3b340af85	Hay quá á!
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5b2e7798-db28-4343-8bf6-296dd6764029	\N	5ad7114b-d2c8-4ea8-986f-b1ad961f4bf2	Hay quá á!
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e593d479-e978-4bf2-a1d5-101a8e37494b	\N	edfd111b-0ce6-47b2-acf4-13272b45a550	Đồng cảm quá bạn ơi!
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f7a7590d-4efd-482e-87d1-7091593709ca	\N	caf7a7bc-0d09-4668-b59b-7efb63a7ea00	Đồng cảm quá bạn ơi!
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ce81f737-0cff-4f56-8a11-5c976e367ca7	\N	8f178140-5846-4df0-8786-129675be0fff	Mình cũng nghĩ vậy
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	1e8946a8-6721-4a37-918c-bbc13a31bbf1	\N	4fd72897-13fc-4a19-9cdf-642de4b8bdc9	Hay quá á!
2025-12-14 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	886274fd-bdea-4347-9d1a-908b522f5b23	\N	315cbe78-ff19-4a10-9df6-4c324e55a308	Hay quá á!
2025-12-13 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0d7a9be9-ca93-4661-bd7d-66242b2f603f	\N	0ccfeb06-e0d7-4161-b5cb-b497b4b28f0f	Hay quá á!
2025-12-13 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	00397d5c-7790-45a0-902a-cb2657eca5fe	\N	5abc8d96-0dce-46eb-9d46-1ff4f7020e00	Đồng cảm quá bạn ơi!
2025-12-13 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	3104b2fd-c2ba-41f0-8e07-069c996ca2d4	\N	baf47fd0-3863-46ba-8875-9963aab9bbcf	Đồng cảm quá bạn ơi!
2025-12-13 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	416e8b72-107a-4ec7-9c60-c2a339b51cb5	\N	3e82a004-3c12-4e8b-b0d5-58b34c6e0da4	Hay quá á!
2025-12-13 03:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	21d8b707-3431-4cbc-834a-9786c83f7a18	\N	2c11a22a-de1c-41e5-b3f5-5ec90d484f82	Đồng cảm quá bạn ơi!
2025-12-12 02:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	68ea3227-d57b-45da-b47c-94bd4a3b0d52	\N	ea7dc302-8294-4b76-9edc-808eb27201ee	Hay quá á!
2025-12-12 02:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ecfc9d4a-47b6-4beb-a06b-ad21a800ea5f	\N	0ccfeb06-e0d7-4161-b5cb-b497b4b28f0f	Đồng cảm quá bạn ơi!
2025-12-12 02:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c203090f-5c05-4e5d-9e95-c2a47fe1fbcc	\N	59c1da2e-0d70-49a4-a4d3-a1d518717b20	Hay quá á!
2025-12-12 02:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	fb923899-9b7d-49aa-aea2-37add6b36f79	\N	d190b3bc-6b6d-48bf-ac30-8b84d9fb842c	Đồng cảm quá bạn ơi!
2025-12-12 02:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8fb7d789-e40d-4947-bf19-d6edddfa7cd5	\N	018ce88a-19ec-4e0d-a35c-9f9abbe7d423	Đồng cảm quá bạn ơi!
2025-12-12 02:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5ed8577e-bdad-47e9-9e25-778a0c243ef4	\N	fd3c0334-e400-4620-861a-1a98921c2efa	Hay quá á!
2025-12-12 02:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b28abe94-170d-4f40-ba99-fe922593a15b	\N	1abd00ce-2cd5-4197-b058-5bbabdd79ab2	Hay quá á!
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	49861396-74e9-44d1-a46f-b7a04ece6fed	\N	cd27b1ac-1595-4431-8136-7a6817babe28	Mình cũng nghĩ vậy
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d2f1fab3-7f4a-4679-ae3d-5fb10cc341a1	\N	fb3956bd-ff46-469d-91a6-617dad6e2145	Hay quá á!
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	753914c2-be2f-4a25-97f0-7fca89232d4c	\N	5f515192-7964-4845-ae91-82e9c74a65ef	Mình cũng nghĩ vậy
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ca93e8b2-2b4d-428c-bfd2-cd32c8a27752	\N	90d59886-4e90-4632-827b-069337f887d6	Hay quá á!
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	31c15bb8-51e8-41f1-8b4f-eb927630f93c	\N	80a80c68-5b98-4043-a0e8-ae6c11bf7961	Đồng cảm quá bạn ơi!
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cad7f8d8-c74d-4bf1-982a-9d6f8cfd64d6	\N	f5449411-3ee3-47a9-aa52-7c63aae2de5c	Hay quá á!
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	74302912-9157-4e97-aa13-05256811c970	\N	e0d80e6e-72dc-403f-ae90-5a71399b50e9	Hay quá á!
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	22965110-744e-45d6-a9c8-59aff3a6dce7	\N	6e1d1c2d-1ed6-432c-8104-a7b8b6c476b6	Mình cũng nghĩ vậy
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	2b5abf09-283f-45bd-a5a9-00252a6a1807	\N	e8c9b48f-bb4e-4885-92bd-7ec972be3865	Hay quá á!
2025-12-11 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e31b29a7-3eb8-4e83-810b-021903b8c4d0	\N	c319c256-93cb-48dd-83c2-05428f75fa76	Mình cũng nghĩ vậy
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	78fcaf54-4beb-4005-be70-59d5f8ae7343	\N	fd3c0334-e400-4620-861a-1a98921c2efa	Đồng cảm quá bạn ơi!
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	2c4f9179-7a7c-4ab1-817c-7a7e36d89441	\N	a2003227-c9ee-46e8-800f-ec2a24a90f99	Đồng cảm quá bạn ơi!
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	14b8f877-c8d0-4860-b7a2-0a2ebc5eadb8	\N	ca2771b6-e743-4fb2-9585-49815ea1f159	Mình cũng nghĩ vậy
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f6ab082c-3b95-4d36-af25-2a4200b27ec0	\N	5ad7114b-d2c8-4ea8-986f-b1ad961f4bf2	Mình cũng nghĩ vậy
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a7ff06a3-ca16-4680-90e1-bc380f8201c2	\N	7f83c5f7-a1f5-4704-bfb8-b098e7ca8df0	Đồng cảm quá bạn ơi!
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a5cd45ea-f99f-4868-bb6d-5f969a9593fa	\N	cdd0d903-6588-4227-a33c-e8a99769f675	Hay quá á!
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	6b1b40e5-e0e4-418b-b32c-bc62b47296ca	\N	3dd06b24-a7c0-49f6-a16e-d1e6a34739be	Đồng cảm quá bạn ơi!
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b45d1f7b-0efa-42fb-8593-9b328a5078d7	\N	729c5095-4965-4b06-8a3e-74f892f58d64	Hay quá á!
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e21f5730-3953-4315-8393-63c3e3ecaaec	\N	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	Hay quá á!
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	85837dc9-5063-42c9-8e6d-660cc1ba445f	\N	7f83c5f7-a1f5-4704-bfb8-b098e7ca8df0	Hay quá á!
2025-12-10 01:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	01ed49a6-de73-4826-a8c8-1e41d4616a56	\N	8bf2bf65-128f-4015-ad4d-54fd6105dcb8	Mình cũng nghĩ vậy
2025-12-09 00:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cc7dcf04-1234-40a4-9143-1498a77bc39c	\N	e8c9b48f-bb4e-4885-92bd-7ec972be3865	Mình cũng nghĩ vậy
2025-12-09 00:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	4f3c0a4f-d13b-4722-be6e-45fbe07fc7bd	\N	fcd6215b-2abe-427d-9025-bf0c21aec724	Hay quá á!
2025-12-09 00:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	07269be4-2f24-443a-afa9-2c266cb11ac6	\N	e1293ed0-26c7-40c1-979b-4431bb2d8161	Mình cũng nghĩ vậy
2025-12-09 00:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	79aac33b-d0a8-46ff-a2c5-355dae1757ef	\N	488d9dea-8553-4e49-bf2b-106c5e143613	Đồng cảm quá bạn ơi!
2025-12-08 00:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	4fe71c98-1023-4715-a65f-adbf3a6ee5f0	\N	59c1da2e-0d70-49a4-a4d3-a1d518717b20	Mình cũng nghĩ vậy
2025-12-08 00:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	03a88282-6d36-415b-b576-8397a0bdc214	\N	5ad7114b-d2c8-4ea8-986f-b1ad961f4bf2	Đồng cảm quá bạn ơi!
2025-12-07 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8c53bd2f-ba8b-4136-9f75-365586b89af6	\N	9db9f670-0a6e-4fa0-9a6d-2737fb28303f	Hay quá á!
2025-12-07 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7bfb5945-0c25-4fb8-a411-bba01f2aa1c4	\N	c30d8234-dd2d-45bd-83ad-0b18fd840343	Đồng cảm quá bạn ơi!
2025-12-07 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b7566f56-79f8-4d8c-9b0b-d6aba056ec2a	\N	5e37c692-bfa3-42df-8a0e-17c891ff9376	Hay quá á!
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	afc47710-9b4a-4811-92c4-53817559905a	\N	ea7dc302-8294-4b76-9edc-808eb27201ee	Mình cũng nghĩ vậy
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ad054bd6-ba3b-47b0-a1c9-14c59927a27f	\N	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	Mình cũng nghĩ vậy
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	9be214a6-db8d-42e1-a7f9-14f10a1c2f82	\N	edfd111b-0ce6-47b2-acf4-13272b45a550	Hay quá á!
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e09c8118-b94e-495f-9f2d-63531dfb3971	\N	ad3b3dc5-a715-47ed-b3e6-7c7691c90292	Đồng cảm quá bạn ơi!
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f61f20a6-407a-416c-aa15-e9926247c203	\N	3e82a004-3c12-4e8b-b0d5-58b34c6e0da4	Mình cũng nghĩ vậy
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	fec56389-6335-4127-a2fe-a6fa2ca5bf07	\N	3ea2b20c-4071-4a2c-a69a-e6583f32297a	Mình cũng nghĩ vậy
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	2210e74e-7840-4d7c-8ee1-b4ebf39ecd7c	\N	69eb4c1b-29b0-45ec-9737-38814966ce06	Đồng cảm quá bạn ơi!
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	eb9661f5-22cf-4e65-8e0d-6b37a0ac66da	\N	0f9777a8-e365-4193-939b-8faf60ea7070	Mình cũng nghĩ vậy
2025-12-06 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e80fc6d5-13e1-4c36-be29-06e9e9044a4f	\N	436d5545-896f-4b2c-a457-b5d867c31aff	Đồng cảm quá bạn ơi!
2025-12-05 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b5eea6f7-5dfe-4e00-a4cd-f8baeaf3aaf6	\N	6e1d1c2d-1ed6-432c-8104-a7b8b6c476b6	Đồng cảm quá bạn ơi!
2025-12-05 23:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5c1d9295-c74f-445a-979b-fcb4a9e53d8b	\N	729c5095-4965-4b06-8a3e-74f892f58d64	Đồng cảm quá bạn ơi!
2025-12-05 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a8e8aea2-d61d-4daf-a1dc-770fd8e500f2	\N	477ea1c4-d0db-46eb-a83d-1887c3066c76	Hay quá á!
2025-12-05 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a6c4dd62-c5b0-4f2a-a9d2-461f4292e339	\N	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	Đồng cảm quá bạn ơi!
2025-12-05 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	840057aa-191b-467e-8951-6df25a554ece	\N	488d9dea-8553-4e49-bf2b-106c5e143613	Hay quá á!
2025-12-05 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b6224e25-f729-49dd-93ef-33cae7b7c7f5	\N	a7eda267-2926-4574-b931-9087cc71040d	Mình cũng nghĩ vậy
2025-12-05 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	040144f2-c774-40c2-8a5d-ac93d85fd918	\N	6f05fb7c-7f24-4fb3-8763-312ea2b52779	Hay quá á!
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a0b171bb-a6dc-4e94-9794-87014748a926	\N	90d59886-4e90-4632-827b-069337f887d6	Mình cũng nghĩ vậy
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e4129bfa-efff-4231-92ba-a5ee4d1de84b	\N	b4a3a72d-9a2e-4cc7-9805-e0d7b8460086	Đồng cảm quá bạn ơi!
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5d03b46a-1033-4f69-bcae-38ed4326262c	\N	1c53e1ce-c1dd-4d64-afba-b76249b0c44a	Mình cũng nghĩ vậy
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	39629746-7212-48bc-b443-e213ba631004	\N	c01425b1-ca97-4d65-b2b2-25ea7366b6e9	Hay quá á!
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d3033ea6-652d-467e-b383-c0ef46a9e830	\N	d3f183f2-5e0f-407a-b29e-ac189105796f	Mình cũng nghĩ vậy
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8748da4b-10f3-4cab-a605-0c1d63020562	\N	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	Mình cũng nghĩ vậy
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	500050c2-852c-4787-9086-743dd5506b1f	\N	e0d80e6e-72dc-403f-ae90-5a71399b50e9	Mình cũng nghĩ vậy
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a2463e46-6acd-4019-9a64-a2553c20e6bb	\N	f83553c0-8ed8-4cb7-a0eb-1209bd258a17	Đồng cảm quá bạn ơi!
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e82de31f-a4d5-4bb3-94c8-2c2db671d74e	\N	a694c11b-ad03-4a7a-bb82-7ac1f30addb0	Mình cũng nghĩ vậy
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	db512152-092a-41eb-a614-67c3f85d4b49	\N	fb3956bd-ff46-469d-91a6-617dad6e2145	Mình cũng nghĩ vậy
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	48119d8a-9732-4f6c-a1ee-7a8cb350fbf1	\N	e0d80e6e-72dc-403f-ae90-5a71399b50e9	Đồng cảm quá bạn ơi!
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7c677361-f6c1-45ac-a106-5dc5fc21d7a4	\N	e9c7308d-897d-4380-bb1e-59484215e180	Hay quá á!
2025-12-04 22:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	64456aa1-f502-4c20-8b9c-ff23671f06b5	\N	d190b3bc-6b6d-48bf-ac30-8b84d9fb842c	Mình cũng nghĩ vậy
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	16348bd8-30dd-47ee-9987-f61738c23b76	\N	018e4a26-93c8-4ac7-99b6-ffef04f067ce	Mình cũng nghĩ vậy
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	af9d0b1d-a69f-4e71-885b-12aebd600fb4	\N	3f734767-2437-4edb-adca-f957ac247374	Mình cũng nghĩ vậy
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	6b67c50d-9173-4541-b98e-152e5ad1acb6	\N	63b42a9d-4df4-464b-a66f-a83e36899a2c	Hay quá á!
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	327cfac1-dd49-4fe3-b3ab-d33f93d14a54	\N	8842eecd-91df-4fc0-8b85-e0f1e032d145	Mình cũng nghĩ vậy
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	30601f69-be60-41a3-9959-13e0674cff4f	\N	ad3b3dc5-a715-47ed-b3e6-7c7691c90292	Mình cũng nghĩ vậy
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	388bc677-1983-482f-a82a-3f27d76a7104	\N	3dd06b24-a7c0-49f6-a16e-d1e6a34739be	Hay quá á!
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0579533c-bf33-41ea-a2e1-2125435ee113	\N	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	Hay quá á!
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d2c99598-4e34-4f51-9e43-96a791eed8c4	\N	b95c500b-e7d5-4307-9319-55e304e2ca2d	Đồng cảm quá bạn ơi!
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7fda0abb-5a01-4b74-9b3e-30992e971a3e	\N	0dc13a3e-bf85-4410-9679-daa0e3f1db35	Mình cũng nghĩ vậy
2025-12-03 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	6388b78b-9c4e-4e72-9429-797176dd1ad0	\N	83cade0f-bcf7-4225-b1a3-90d686fc2a3f	Hay quá á!
2025-12-02 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	54391b2c-eded-4162-95e1-8640f8deea38	\N	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	Hay quá á!
2025-12-02 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	456a8508-cc4a-4c87-8a7e-04181aae09d4	\N	ea7dc302-8294-4b76-9edc-808eb27201ee	Đồng cảm quá bạn ơi!
2025-12-02 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e58a3283-1146-4991-8053-b13af1458855	\N	8c0f6e42-050d-4a87-82b6-4d407f9be2da	Đồng cảm quá bạn ơi!
2025-12-02 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	01d46ba4-e367-4aa9-a9fe-287893c92bfc	\N	c30d8234-dd2d-45bd-83ad-0b18fd840343	Mình cũng nghĩ vậy
2025-12-02 21:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7b921a72-f0b4-4cd5-ae0c-0077b9309a95	\N	9b963a1c-c133-4df0-aadf-e6bea2c1e50d	Hay quá á!
2025-12-02 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	06e64011-0bfc-43cd-a05b-334619f134bf	\N	488d9dea-8553-4e49-bf2b-106c5e143613	Mình cũng nghĩ vậy
2025-12-02 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	73be9a9d-8ddd-4ca0-93fc-8fb5f3470f19	\N	329f165e-054a-4190-9b74-d0cb07700e11	Mình cũng nghĩ vậy
2025-12-01 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	488fcb92-3a69-4e30-a8c3-ecbd91b749c0	\N	f366ce18-ef44-47cf-97a5-310852627315	Mình cũng nghĩ vậy
2025-12-01 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d92d2a02-99fa-45f1-8b4a-234632dcf25d	\N	38c4f435-0383-4aea-ae64-3b6fcd2ca8a4	Đồng cảm quá bạn ơi!
2025-12-01 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e8197b9e-4e93-4ef4-9862-bd84f20b051b	\N	cdd0d903-6588-4227-a33c-e8a99769f675	Mình cũng nghĩ vậy
2025-12-01 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7a0fb732-548f-47e2-9aa5-d272e4fcabee	\N	08d8aad9-3f6f-474a-b207-676809f9d0a4	Đồng cảm quá bạn ơi!
2025-12-01 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	91862289-ea23-4a7c-9118-82dd74802533	\N	af5511d8-6187-4402-850c-9a567ff84ee2	Hay quá á!
2025-12-01 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	84032570-db80-4315-9512-e63414dba701	\N	3e82a004-3c12-4e8b-b0d5-58b34c6e0da4	Đồng cảm quá bạn ơi!
2025-12-01 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b7ddb301-425b-4c6e-a450-97daca5dab6b	\N	73f505b7-771c-4543-8aa8-48ecc6c646f3	Mình cũng nghĩ vậy
2025-12-01 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a0bf82ea-70a1-445e-907f-44f89f5c67dc	\N	380cbbe2-5e4e-4fbf-8834-0426188b4486	Đồng cảm quá bạn ơi!
2025-11-30 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	3259e48b-6ebb-4696-a883-de65f0e7d75b	\N	b95c500b-e7d5-4307-9319-55e304e2ca2d	Mình cũng nghĩ vậy
2025-11-30 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	11cb4851-7211-4adb-a01b-b36e7c63c868	\N	5f515192-7964-4845-ae91-82e9c74a65ef	Hay quá á!
2025-11-30 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c58e8271-3201-43ae-ace5-9bd5a61d9a3a	\N	3b67bced-d152-49d5-a170-189200f33385	Mình cũng nghĩ vậy
2025-11-30 20:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0ae51b58-f741-423b-ba26-f06785e3dc98	\N	fb3956bd-ff46-469d-91a6-617dad6e2145	Đồng cảm quá bạn ơi!
2025-11-30 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f7d21a02-021b-4a4b-9f7b-a25b5d111468	\N	d84199b9-1574-41d2-8d92-896eafbb2324	Đồng cảm quá bạn ơi!
2025-11-30 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d122b0ac-17a3-454f-938a-b88b066a9bdd	\N	b4a3a72d-9a2e-4cc7-9805-e0d7b8460086	Hay quá á!
2025-11-30 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5d009cf2-cd62-431e-aa6c-7c0fe7c66867	\N	d1191140-d45f-436b-8365-d25be77222d6	Mình cũng nghĩ vậy
2025-11-30 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	912d6413-41d8-479d-b4af-c8543d750d77	\N	0315b928-6309-4fdd-9d96-4227695fb0ec	Hay quá á!
2025-11-30 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e5707d8f-4154-4e34-b3e2-6c65122a6d1b	\N	5abc8d96-0dce-46eb-9d46-1ff4f7020e00	Mình cũng nghĩ vậy
2025-11-30 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	bdafc0bb-1d1f-46e4-8d35-1d32f896a052	\N	5e37c692-bfa3-42df-8a0e-17c891ff9376	Đồng cảm quá bạn ơi!
2025-11-30 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f0759b46-5947-4b09-989d-1037db4c4d4b	\N	b1461a46-ad73-49e6-88aa-044ab10017e7	Hay quá á!
2025-11-30 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	31fb3209-e5b5-4d59-9a4b-85c638ac79ca	\N	cd27b1ac-1595-4431-8136-7a6817babe28	Đồng cảm quá bạn ơi!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8c8cc168-0be8-4d16-a49e-0ebde39d5ccd	\N	380cbbe2-5e4e-4fbf-8834-0426188b4486	Hay quá á!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	4fe406d9-0060-45fa-a3c7-6edd0d7b251b	\N	af1518c6-25eb-4d4d-be15-047336e3b091	Đồng cảm quá bạn ơi!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	4f006a0d-d643-4e62-9770-86cfec5238b2	\N	ccaa812c-5688-4086-a76f-4d29eba4aa9f	Đồng cảm quá bạn ơi!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	70b37430-5292-4200-abdb-ff60b7d5c476	\N	1ab81feb-545f-46f8-8eb8-7f580f331ca7	Hay quá á!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a5c1f315-6a1c-41de-ad40-d6738b37a9d9	\N	c319c256-93cb-48dd-83c2-05428f75fa76	Hay quá á!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	36d1dde4-e561-4465-a241-bf3cbeb2f53f	\N	53af5af3-44dc-4e98-94f3-7dc2a602c2d2	Hay quá á!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	3561fb67-21b7-42a5-8ef8-8567158806d1	\N	d190b3bc-6b6d-48bf-ac30-8b84d9fb842c	Hay quá á!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5b610939-e387-4c60-ae77-a344eca1c05a	\N	6e1d1c2d-1ed6-432c-8104-a7b8b6c476b6	Hay quá á!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	74f05d69-a3af-42bb-b92f-13db1dd704d8	\N	018ce88a-19ec-4e0d-a35c-9f9abbe7d423	Hay quá á!
2025-11-29 19:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	633c6777-0cd7-462e-a153-c1e31c755078	\N	23cce978-fc18-4d3c-92a4-d82717f7c9ac	Mình cũng nghĩ vậy
2025-11-28 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7c421de0-e6d3-4511-92b7-9119e993b89e	\N	f79a722d-a6db-48cb-836b-091ec96026fb	Hay quá á!
2025-11-28 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d0f269fc-56fd-49f1-81a7-921eadc13ec9	\N	83cade0f-bcf7-4225-b1a3-90d686fc2a3f	Mình cũng nghĩ vậy
2025-11-28 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	6b6f6f8a-931e-44a4-a634-8224f200e089	\N	a7bf8fc4-211b-4c93-91a5-2a927127e019	Đồng cảm quá bạn ơi!
2025-11-28 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5249c1be-c8c6-4b31-97cc-3f9e99fc1afa	\N	03729fff-4ed4-4ec8-a45d-0aa62843df4f	Đồng cảm quá bạn ơi!
2025-11-28 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	003593bf-fe40-45c5-8ee7-ab0e010b9ba3	\N	329f165e-054a-4190-9b74-d0cb07700e11	Hay quá á!
2025-11-28 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	1e7896ca-3e6a-4bc2-91fc-e226a1dfd11a	\N	28a23ecf-7e87-4517-817f-71005f2181bc	Hay quá á!
2025-11-28 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	6cbb3274-1803-4cc6-9497-8b6df41622aa	\N	d84199b9-1574-41d2-8d92-896eafbb2324	Mình cũng nghĩ vậy
2025-11-28 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b0898b84-ad46-4676-893e-d9da1de92e4d	\N	03729fff-4ed4-4ec8-a45d-0aa62843df4f	Mình cũng nghĩ vậy
2025-11-27 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7c621ca5-a9d5-489e-86b5-6181e7dcc07d	\N	8842eecd-91df-4fc0-8b85-e0f1e032d145	Đồng cảm quá bạn ơi!
2025-11-27 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cfa50e03-8699-41a3-b95b-f289a0dd1059	\N	b4a3a72d-9a2e-4cc7-9805-e0d7b8460086	Mình cũng nghĩ vậy
2025-11-27 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0da50109-10b5-446d-8e6f-703eaf8ceb9a	\N	edfd111b-0ce6-47b2-acf4-13272b45a550	Mình cũng nghĩ vậy
2025-11-27 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	dcef00a2-0299-42e3-9014-382c8ad33e5d	\N	a0576d7a-2356-41d3-8040-2418a8518e49	Hay quá á!
2025-11-27 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	21550567-33fc-4845-b644-5a9767e1479e	\N	ca2771b6-e743-4fb2-9585-49815ea1f159	Hay quá á!
2025-11-27 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	52f4ec3b-d3ef-46a3-9f5f-a4ddc344f566	\N	a694c11b-ad03-4a7a-bb82-7ac1f30addb0	Hay quá á!
2025-11-27 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8d001566-12ed-402e-bd09-917cabaf1ba4	\N	80a80c68-5b98-4043-a0e8-ae6c11bf7961	Mình cũng nghĩ vậy
2025-11-27 18:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	64f9d866-4339-4c34-ba63-7332ce67a528	\N	f5449411-3ee3-47a9-aa52-7c63aae2de5c	Đồng cảm quá bạn ơi!
2025-11-27 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5a7176e7-8d2b-4acc-b0d6-f55b68e37609	\N	6f05fb7c-7f24-4fb3-8763-312ea2b52779	Đồng cảm quá bạn ơi!
2025-11-27 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	37554d7d-552e-42dc-8904-78d0f29e63cb	\N	63b42a9d-4df4-464b-a66f-a83e36899a2c	Đồng cảm quá bạn ơi!
2025-11-27 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	395efdfc-1f42-4881-a7bb-291eb52539bb	\N	8f178140-5846-4df0-8786-129675be0fff	Hay quá á!
2025-11-27 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cde5ff67-eee0-4a0b-922f-114c08849c43	\N	03729fff-4ed4-4ec8-a45d-0aa62843df4f	Hay quá á!
2025-11-26 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	04a512fe-5373-44f0-b021-0290be6ea554	\N	8c0f6e42-050d-4a87-82b6-4d407f9be2da	Mình cũng nghĩ vậy
2025-11-26 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	2df43a79-08f8-41fc-9d7c-5da553de6b39	\N	af5511d8-6187-4402-850c-9a567ff84ee2	Mình cũng nghĩ vậy
2025-11-26 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	1075b0c7-4568-4e6d-a70b-d6cabc20ae14	\N	cdd0d903-6588-4227-a33c-e8a99769f675	Đồng cảm quá bạn ơi!
2025-11-26 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	af03643f-083f-44c6-9cce-55a79b98bcb0	\N	3a488bda-31da-4c0e-a48d-9df821f81f4c	Hay quá á!
2025-11-26 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	baa4d7ec-d520-42b6-885a-bc6e51203a06	\N	018ce88a-19ec-4e0d-a35c-9f9abbe7d423	Mình cũng nghĩ vậy
2025-11-26 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d0fb0719-9e25-436c-b0b1-4c7a397b4a25	\N	3f734767-2437-4edb-adca-f957ac247374	Đồng cảm quá bạn ơi!
2025-11-26 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	65d549fc-6b14-44a1-9799-f7256d2aa8ac	\N	6fabb14b-cfc7-4afd-98e0-c741db54a528	Mình cũng nghĩ vậy
2025-11-25 17:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ae2c1f84-69f4-4ec2-99ff-e9227bf9b620	\N	f91cf04e-f6ec-4184-b2b4-a265ec5cb667	Mình cũng nghĩ vậy
2025-11-25 16:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	583e97fd-a990-43bd-94c1-cd3c8e3cb8c9	\N	d8ea3c88-e11a-4e96-a194-ace0a16931cb	Đồng cảm quá bạn ơi!
2025-11-25 16:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8b482081-bc8b-47f7-93f0-6b0e731c6617	\N	60808489-351b-4443-a95d-1fee8f8d9ba3	Mình cũng nghĩ vậy
2025-11-25 16:49:23.030502+00	\N	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b1d360f0-171e-4ad5-a7ef-7b46e322f0fc	\N	a5869473-14de-4b81-bf19-c5fcbef3f988	Đồng cảm quá bạn ơi!
2025-12-19 06:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a4d3e5de-24aa-44af-acc5-e8b3cc2d0398	\N	a7eda267-2926-4574-b931-9087cc71040d	Đồng cảm quá bạn ơi!
2025-12-19 06:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	45b4b098-09e1-4489-9650-ff28bc740c1c	\N	729c5095-4965-4b06-8a3e-74f892f58d64	Đồng cảm quá bạn ơi!
2025-12-19 06:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f661d433-146e-4ee7-bc39-e1004e59242b	\N	d8ea3c88-e11a-4e96-a194-ace0a16931cb	Đồng cảm quá bạn ơi!
2025-12-19 06:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	10f2f119-b506-4d75-a733-7760b0d7e4cb	\N	cd27b1ac-1595-4431-8136-7a6817babe28	Đồng cảm quá bạn ơi!
2025-12-19 06:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	be2132be-58fe-4ee7-b5a2-09b4c259b438	\N	f68cf51b-5606-4200-b110-9ddd34a13251	Đồng cảm quá bạn ơi!
2025-12-19 06:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9018048d-eb28-46e6-bde9-31e059122c8b	\N	1781164d-aae4-4f0a-9d83-5d14a70f6990	Đồng cảm quá bạn ơi!
2025-12-19 06:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2da13cd2-9b8b-408c-a3d9-addea71bc692	\N	23bd823f-8c3f-4607-8605-59ff67874886	Đồng cảm quá bạn ơi!
2025-12-18 06:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e0595779-76e3-4103-9628-b4f05c4ad5d1	\N	83cade0f-bcf7-4225-b1a3-90d686fc2a3f	Đồng cảm quá bạn ơi!
2025-12-18 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e47e4ca2-8fa4-44f5-aae7-0120881973cd	\N	b93534d9-4a9f-4e31-a52e-6f1c98012d8c	Đồng cảm quá bạn ơi!
2025-12-18 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b7232851-e2ec-4ce1-92e7-bbfad74137b9	\N	0315b928-6309-4fdd-9d96-4227695fb0ec	Đồng cảm quá bạn ơi!
2025-12-17 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	92ef9ffe-8b15-4391-9c3f-f7ab08ee6682	\N	375de7b9-098b-4f15-9bbf-4b5b014f675a	Đồng cảm quá bạn ơi!
2025-12-17 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b82ba088-bc08-4656-a9ce-7023b53fcc6b	\N	58746496-23d4-4ae4-a1d1-1a3de2ef4609	Đồng cảm quá bạn ơi!
2025-12-17 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c4a283a0-b981-4753-9125-39f1548df61b	\N	e554f9a2-fcb9-4c85-a52a-6ea2955117b3	Đồng cảm quá bạn ơi!
2025-12-17 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b282a33e-7992-4078-9a6c-5ab820c419a6	\N	578c949a-4092-4f8f-8a23-953ef093f6f4	Đồng cảm quá bạn ơi!
2025-12-16 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	398f0a4f-e74f-47ac-89c5-8c3b2f40396c	\N	915a00b7-48a4-4ff8-959b-f20c42ae157f	Đồng cảm quá bạn ơi!
2025-12-16 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a5dfcc89-855f-462d-8627-e07910e60303	\N	bddd6d02-c07e-47cc-bcb3-dfe90830fbee	Đồng cảm quá bạn ơi!
2025-12-16 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	78465350-e600-4fa1-8292-afb5c0d38a43	\N	5f515192-7964-4845-ae91-82e9c74a65ef	Đồng cảm quá bạn ơi!
2025-12-16 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ca8f82c6-2abe-46e4-9af3-e13cb51c90b6	\N	af5511d8-6187-4402-850c-9a567ff84ee2	Đồng cảm quá bạn ơi!
2025-12-16 05:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f161948e-590b-43c8-80fb-07d0dbcf062e	\N	e9c7308d-897d-4380-bb1e-59484215e180	Đồng cảm quá bạn ơi!
2025-12-16 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1892a680-0c8d-4cc6-9550-1d9e499d3081	\N	7d444e40-3b9d-4b89-94fb-a53ba62467c2	Đồng cảm quá bạn ơi!
2025-12-16 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	737fee82-ca3c-4935-b0ea-60442c0d7e0b	\N	2e09c782-f52c-42ae-abc9-7c437db06c63	Đồng cảm quá bạn ơi!
2025-12-16 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a5110ad6-4003-4884-a083-5dd2394fd636	\N	23faaa79-5567-4c1b-98ea-11d42b9a5624	Đồng cảm quá bạn ơi!
2025-12-16 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5a6f938f-89d3-4c66-9ce5-c00ca7f93feb	\N	c01425b1-ca97-4d65-b2b2-25ea7366b6e9	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e5d3a542-61a8-4fdd-9843-7801b57381b6	\N	fb3956bd-ff46-469d-91a6-617dad6e2145	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	45ae38d7-3ab1-4cdf-9ba5-adcca3902882	\N	2632f577-b312-4a72-884d-1d94bef08c6c	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	db1a08be-6c9d-427f-9744-f1fb94d80112	\N	e3771fcb-31d8-41dd-8cf7-a065c5ee4430	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	06001f57-35c5-495c-8666-099c079c21bd	\N	d2dc024f-8dd7-4305-b34d-f022a92e8eea	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	37d8cd31-5a5f-46d9-84d5-c7f63c2eb385	\N	c319c256-93cb-48dd-83c2-05428f75fa76	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8e25f7af-0334-4661-83c2-9aeccd333bf6	\N	2c11a22a-de1c-41e5-b3f5-5ec90d484f82	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3ed1b59e-c460-4ab5-a139-adde4de9c40b	\N	ed0e7b6c-058a-48bf-a2c1-3f9af8b12528	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3ede6dae-5a53-435e-9077-b5033a895930	\N	54128841-d796-4af0-adb3-2e8ac9b9fd8a	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	93efa6c0-a85b-452c-a002-84b0d5a49e0b	\N	d1191140-d45f-436b-8365-d25be77222d6	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	99da0a00-2d01-4d2f-8748-54733d05686c	\N	80a80c68-5b98-4043-a0e8-ae6c11bf7961	Đồng cảm quá bạn ơi!
2025-12-15 04:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	96a33b23-3024-4de2-812b-add51bb986f7	\N	73f505b7-771c-4543-8aa8-48ecc6c646f3	Đồng cảm quá bạn ơi!
2025-12-14 03:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	883c47e7-697b-44e5-b26e-dc995690fd1f	\N	f818e29e-2264-47e5-85a7-c5e8a4db8f21	Đồng cảm quá bạn ơi!
2025-12-14 03:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	55401fc0-7b0a-441c-bb8f-8e1cc8aaa3b2	\N	97921494-ee29-4269-8eb2-6fc8f5d487b5	Đồng cảm quá bạn ơi!
2025-12-14 03:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6a4ba046-5bb2-43eb-a47e-d8130961048e	\N	345389ee-235c-4907-8384-d81e42c42ae8	Đồng cảm quá bạn ơi!
2025-12-13 03:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ce70e21a-9d56-4194-8940-7f3232e5d136	\N	6f05fb7c-7f24-4fb3-8763-312ea2b52779	Đồng cảm quá bạn ơi!
2025-12-13 02:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	952492dd-8eb9-4522-8945-1060ab20e5ca	\N	59c1da2e-0d70-49a4-a4d3-a1d518717b20	Đồng cảm quá bạn ơi!
2025-12-13 02:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	06fa2de8-dd55-46a3-8f1c-b5273dd8af21	\N	a43c9cb1-dabb-43d4-9fa7-f5f378a50f4c	Đồng cảm quá bạn ơi!
2025-12-12 02:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ec5e9ba0-22d8-4d92-acf5-5d1940a89544	\N	5e37c692-bfa3-42df-8a0e-17c891ff9376	Đồng cảm quá bạn ơi!
2025-12-12 02:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	85c09331-7da8-4be9-92a8-f4ace429025d	\N	306fe046-1b25-40e6-8a27-bec37bd32614	Đồng cảm quá bạn ơi!
2025-12-12 02:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9c79f9a5-74ad-45b0-a8e4-3c9b0a084172	\N	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	Đồng cảm quá bạn ơi!
2025-12-11 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	35727199-6e1d-44f1-a3e3-9619240ea0b0	\N	3bec3a67-58f3-4a67-a300-5c12de77481c	Đồng cảm quá bạn ơi!
2025-12-11 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3a71f2e4-4ebf-43a1-aa70-80f3373e6c8e	\N	e67b6f1e-a2ef-4128-9778-cceb03f71a8e	Đồng cảm quá bạn ơi!
2025-12-11 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f76b79e5-4b12-4b20-9cea-88979648d2e1	\N	69eb4c1b-29b0-45ec-9737-38814966ce06	Đồng cảm quá bạn ơi!
2025-12-11 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f539eb18-c375-4dfd-b8f9-995d3047cbed	\N	f91cf04e-f6ec-4184-b2b4-a265ec5cb667	Đồng cảm quá bạn ơi!
2025-12-10 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a05bf38d-7faf-4cee-8591-7b403273510d	\N	4fd72897-13fc-4a19-9cdf-642de4b8bdc9	Đồng cảm quá bạn ơi!
2025-12-10 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	313bc2f2-72d9-4399-bb7b-c1c52ce97e74	\N	eaabd4e5-b6c1-4678-9cea-58d7190a7f3e	Đồng cảm quá bạn ơi!
2025-12-10 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3a9db6d0-3dd6-40e0-9a3f-dcbc8346efe7	\N	f366ce18-ef44-47cf-97a5-310852627315	Đồng cảm quá bạn ơi!
2025-12-10 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	df479c34-ddf9-45c9-9b64-4e794d166958	\N	60aa584b-e2de-4997-87ff-3675276a53e7	Đồng cảm quá bạn ơi!
2025-12-10 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0e587090-de72-4dd8-a6d5-724527a4d6be	\N	5ad7114b-d2c8-4ea8-986f-b1ad961f4bf2	Đồng cảm quá bạn ơi!
2025-12-10 01:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7d6c6876-08f3-43e2-b91e-3ec27da0d69e	\N	c30d8234-dd2d-45bd-83ad-0b18fd840343	Đồng cảm quá bạn ơi!
2025-12-09 00:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	40073ec4-0af4-4b57-9677-d7c8c1340c36	\N	b1461a46-ad73-49e6-88aa-044ab10017e7	Đồng cảm quá bạn ơi!
2025-12-09 00:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	237cc157-ddde-480c-ba8c-83ec551dbb48	\N	ae3a3f5b-3f4f-4375-956f-0a31ffeb4dff	Đồng cảm quá bạn ơi!
2025-12-09 00:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6e9a571a-86e8-4ce2-bc96-404cd3a3b2aa	\N	04578903-cbcd-4227-8344-8af8af430449	Đồng cảm quá bạn ơi!
2025-12-09 00:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f8778982-e546-401f-925e-68294598ecb5	\N	63b42a9d-4df4-464b-a66f-a83e36899a2c	Đồng cảm quá bạn ơi!
2025-12-09 00:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	647cc9dd-21bd-4d82-adfd-656d07ad8894	\N	0f9777a8-e365-4193-939b-8faf60ea7070	Đồng cảm quá bạn ơi!
2025-12-08 00:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1482eed5-f08b-4de3-a794-45d7662c40d7	\N	018e4a26-93c8-4ac7-99b6-ffef04f067ce	Đồng cảm quá bạn ơi!
2025-12-07 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8736a565-a426-4a9f-a7c3-3e89ecffb0b7	\N	ca2771b6-e743-4fb2-9585-49815ea1f159	Đồng cảm quá bạn ơi!
2025-12-07 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c0a2615a-7a0f-4b46-8f38-b2785742f641	\N	8842eecd-91df-4fc0-8b85-e0f1e032d145	Đồng cảm quá bạn ơi!
2025-12-06 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	372f12b8-69fd-40f9-9310-6ce0785503aa	\N	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	Đồng cảm quá bạn ơi!
2025-12-06 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	53644636-2274-4ead-ae65-2ab51cabf3ab	\N	cdd0d903-6588-4227-a33c-e8a99769f675	Đồng cảm quá bạn ơi!
2025-12-06 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	83693f03-4d93-475f-a397-032bbd34b04a	\N	380cbbe2-5e4e-4fbf-8834-0426188b4486	Đồng cảm quá bạn ơi!
2025-12-06 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	216789d7-4979-4659-9688-4f976873acfd	\N	59dc22d9-fe1e-4618-8a36-2f768143b988	Đồng cảm quá bạn ơi!
2025-12-06 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	35b55b87-0f16-42df-9ca8-018e890d5d95	\N	cc59412e-089a-4bc5-a644-e50c0e3a76c6	Đồng cảm quá bạn ơi!
2025-12-06 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	71cb5517-f612-4d34-9e8b-284f5bca4058	\N	53af5af3-44dc-4e98-94f3-7dc2a602c2d2	Đồng cảm quá bạn ơi!
2025-12-06 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ac35e78f-efc7-437d-8099-c7c270ab9118	\N	cede95bf-7606-4d9d-8bed-8509e027b61d	Đồng cảm quá bạn ơi!
2025-12-05 23:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e4e0e0a5-e991-4020-b402-0c9096e6617b	\N	bf252fc0-bead-41f2-80ae-4e2ac5d24545	Đồng cảm quá bạn ơi!
2025-12-05 22:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8f202a5d-1638-406b-9271-78914733bad8	\N	cec1d8b9-819c-436a-b62f-ffcc52a112d9	Đồng cảm quá bạn ơi!
2025-12-05 22:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4111a9c1-772f-414e-914e-44ba4bdd9cc3	\N	3e82a004-3c12-4e8b-b0d5-58b34c6e0da4	Đồng cảm quá bạn ơi!
2025-12-04 22:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	80707c51-04dd-47dd-a4b9-1cc6e04227cf	\N	e7752d99-8f2a-4da4-ad91-d71fd545bc46	Đồng cảm quá bạn ơi!
2025-12-04 22:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	14384c3c-a3a7-4607-824d-65ba9cd9af40	\N	28a23ecf-7e87-4517-817f-71005f2181bc	Đồng cảm quá bạn ơi!
2025-12-04 22:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f2935d46-5fcb-466c-be7e-d72e26aedb41	\N	ccc4a84e-e519-4526-aa4e-f41f4482c019	Đồng cảm quá bạn ơi!
2025-12-04 22:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	255861a5-b49e-42ff-8c06-4d1da28a286e	\N	66662d1b-794a-4641-8886-3e91bb3158aa	Đồng cảm quá bạn ơi!
2025-12-04 22:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4d3a69b7-96c7-447c-bd9c-6fbc2041f6ed	\N	b20e0159-de08-4174-8a71-83ebb743c360	Đồng cảm quá bạn ơi!
2025-12-04 22:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	33822c26-b345-43ce-9526-fe7df9f85a35	\N	3ea2b20c-4071-4a2c-a69a-e6583f32297a	Đồng cảm quá bạn ơi!
2025-12-03 21:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d8976e90-c6f7-4055-b74a-37960c88b407	\N	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	Đồng cảm quá bạn ơi!
2025-12-03 21:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e5e60534-09ea-469c-a963-c95dfc9131ab	\N	8a0db927-d52e-446d-8bc8-c1e16024c283	Đồng cảm quá bạn ơi!
2025-12-03 21:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	def776ab-aa61-4ae2-a838-7ae3d4c2666a	\N	0ccfeb06-e0d7-4161-b5cb-b497b4b28f0f	Đồng cảm quá bạn ơi!
2025-12-03 21:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	34cd0b9c-3432-48a7-84cd-9fece3b22ccd	\N	7cc09085-8f78-4e38-967b-8d13070957e2	Đồng cảm quá bạn ơi!
2025-12-03 21:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	907e10ad-66b3-46b3-ab91-b6dd452ca0d8	\N	4a1ad6a0-5702-42e7-a756-9801595e1b2c	Đồng cảm quá bạn ơi!
2025-12-03 21:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b6a26cff-b519-415f-b813-a08769a6abb5	\N	b95c500b-e7d5-4307-9319-55e304e2ca2d	Đồng cảm quá bạn ơi!
2025-12-03 21:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1fd89213-c57d-432b-a3c4-3281cdab7b03	\N	6e1d1c2d-1ed6-432c-8104-a7b8b6c476b6	Đồng cảm quá bạn ơi!
2025-12-03 21:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	21a7bb5f-c690-4cef-ae7c-202812bec9da	\N	f79a722d-a6db-48cb-836b-091ec96026fb	Đồng cảm quá bạn ơi!
2025-12-02 20:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	13b6904a-ca40-44fe-8c7e-603c05da3a65	\N	e900c3eb-5d9e-4b0c-8869-6bc21f08c517	Đồng cảm quá bạn ơi!
2025-12-01 20:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	882e06c8-ec35-4e86-8563-499335856b7f	\N	74c0890a-7d32-4666-9001-8616fe63af61	Đồng cảm quá bạn ơi!
2025-12-01 20:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d6ad6929-d0c9-48dc-aa7e-773daf93e216	\N	7fbb2bbf-5ca1-4e14-bd0b-c166a67e8232	Đồng cảm quá bạn ơi!
2025-12-01 20:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	303d0f3e-7082-4f81-90bd-8686dcd7cec5	\N	6fabb14b-cfc7-4afd-98e0-c741db54a528	Đồng cảm quá bạn ơi!
2025-12-01 20:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7284c6e9-62d1-42c9-bf5a-77cf8d24b9bd	\N	614a72a8-1a61-4f22-bbce-35c735e856ca	Đồng cảm quá bạn ơi!
2025-11-30 20:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3a81f1ce-2edc-414f-8dd9-1c4be70229bf	\N	9b963a1c-c133-4df0-aadf-e6bea2c1e50d	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fd0776cb-c5b2-4dc3-987d-71db25d0b904	\N	6f577918-32ff-4dc8-a835-235b2d55c345	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9bc07372-08ea-4eec-9834-a2456174f1fd	\N	af1518c6-25eb-4d4d-be15-047336e3b091	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6458a6a4-b239-4960-8bf3-f63514543646	\N	71458d31-4161-4835-9b98-c70f1787d4a6	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	345f3713-b76d-41e6-af4d-36b5dcf0af9c	\N	8a7f2fae-66cd-4800-8d42-2e6860739654	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	295d9ea4-af85-4799-8875-6e583c336406	\N	caf7a7bc-0d09-4668-b59b-7efb63a7ea00	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	65c826a6-40d1-412a-8d38-43531bbf75c3	\N	37dc1845-04bb-44bc-b32a-db37f0c25717	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b28532ff-04d3-4875-9bdf-941f22995184	\N	53f9fb19-510d-4510-a76f-6f3b4448e541	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	61df4294-f8b2-48fa-848f-c62ca72afd23	\N	3f734767-2437-4edb-adca-f957ac247374	Đồng cảm quá bạn ơi!
2025-11-30 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fff2d2e8-8832-4b24-86d0-96c35bdd3f5f	\N	03729fff-4ed4-4ec8-a45d-0aa62843df4f	Đồng cảm quá bạn ơi!
2025-11-29 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	60da6872-3b48-4c86-a43f-9eb9b25ae29f	\N	fcd6215b-2abe-427d-9025-bf0c21aec724	Đồng cảm quá bạn ơi!
2025-11-29 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7c4f9512-c189-4d8e-a5f2-de11bca8a3eb	\N	baf47fd0-3863-46ba-8875-9963aab9bbcf	Đồng cảm quá bạn ơi!
2025-11-29 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ac35a379-3535-4f01-9600-9a441bfee0c8	\N	951c8ef2-0982-4991-9ed1-fa5d3710bd2c	Đồng cảm quá bạn ơi!
2025-11-29 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	038153c1-6baf-4d60-a4fd-15090c7b7eca	\N	2306c799-2354-4b39-b0e1-f50ca86fa9a7	Đồng cảm quá bạn ơi!
2025-11-29 19:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ee142c18-f3f3-425a-867c-27cf8ce59a80	\N	08d8aad9-3f6f-474a-b207-676809f9d0a4	Đồng cảm quá bạn ơi!
2025-11-28 18:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7730754c-77bc-48cb-a101-8a578c1ad6eb	\N	fd3c0334-e400-4620-861a-1a98921c2efa	Đồng cảm quá bạn ơi!
2025-11-27 18:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	eaed60b3-80be-42de-9656-d9f0e8d4af45	\N	3b2a05d2-c06d-4580-97d9-01b3b340af85	Đồng cảm quá bạn ơi!
2025-11-27 18:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d1e8c483-a9bb-40e7-a397-090245640efd	\N	97dcb5e5-2f77-4296-8adf-d17c166a56e1	Đồng cảm quá bạn ơi!
2025-11-27 18:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	832e393c-83ad-421b-9ecc-86b81c9f63b3	\N	98336c18-41fb-4f39-b0e0-39b0e8afe8f2	Đồng cảm quá bạn ơi!
2025-11-27 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5aae4713-0ae4-4e88-8841-2ebc4c0d7bdf	\N	488d9dea-8553-4e49-bf2b-106c5e143613	Đồng cảm quá bạn ơi!
2025-11-27 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fe7a0c2b-12bf-42bd-97d6-a0812d670c34	\N	d190b3bc-6b6d-48bf-ac30-8b84d9fb842c	Đồng cảm quá bạn ơi!
2025-11-26 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	047504d0-79c8-4cf3-be63-03cdf02985a6	\N	ccaa812c-5688-4086-a76f-4d29eba4aa9f	Đồng cảm quá bạn ơi!
2025-11-26 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0c4ba7a5-4272-494c-b738-ee59de726e41	\N	1c53e1ce-c1dd-4d64-afba-b76249b0c44a	Đồng cảm quá bạn ơi!
2025-11-26 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6930b20d-5f01-4c26-9504-ee295221cd83	\N	ad3b3dc5-a715-47ed-b3e6-7c7691c90292	Đồng cảm quá bạn ơi!
2025-11-26 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	14c24ff5-7c31-4879-9148-4344fdf4659c	\N	3687dfc8-f059-43e0-9088-2a42a0333d0f	Đồng cảm quá bạn ơi!
2025-11-25 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ac90a722-d544-444d-ac31-6e6b3bd0fa0f	\N	a7bf8fc4-211b-4c93-91a5-2a927127e019	Đồng cảm quá bạn ơi!
2025-11-25 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	892c156a-5627-4de2-81a7-cdd03f17d449	\N	cd2eca79-ad56-4e4c-8679-bfe92b7d91b1	Đồng cảm quá bạn ơi!
2025-11-25 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7624d677-3ef9-4f12-82df-b037de34f4fa	\N	1ab81feb-545f-46f8-8eb8-7f580f331ca7	Đồng cảm quá bạn ơi!
2025-11-25 17:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8fb30e7b-b533-47e9-862e-ab13f77f9724	\N	8bf2bf65-128f-4015-ad4d-54fd6105dcb8	Đồng cảm quá bạn ơi!
2025-11-25 16:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	818e464c-a003-4c55-aa06-b7072537d792	\N	097e8be6-2de8-42ae-bfcf-2951d96bddb6	Đồng cảm quá bạn ơi!
2025-11-25 16:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c70c71de-c782-4273-be1c-87dfb7196437	\N	2b4d404f-af98-4b6e-97e2-487f9b84047d	Đồng cảm quá bạn ơi!
2025-11-25 16:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0d6dd715-0fc2-453f-b104-a0246c01ab86	\N	38c4f435-0383-4aea-ae64-3b6fcd2ca8a4	Đồng cảm quá bạn ơi!
2025-11-25 16:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	142604e2-4ac5-490f-999a-8ac52aa3a208	\N	523f2954-30c1-471e-89b0-7fd638788ac3	Đồng cảm quá bạn ơi!
2025-11-25 16:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b9f70d09-1afe-418a-b043-7a99e029b888	\N	b81c3242-04a1-49eb-b283-892421cd45c6	Đồng cảm quá bạn ơi!
2025-11-24 16:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	76ed0f84-cc0e-4e8f-a390-ddd597e88817	\N	a9b54525-7574-43c3-84de-60dbf19aa9ac	Đồng cảm quá bạn ơi!
2025-11-23 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	273f9fe2-f6b3-40a8-a083-890ee3f91dc0	\N	8dbc4147-7063-400c-99a0-97aadef49864	Đồng cảm quá bạn ơi!
2025-11-23 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7734ef03-895f-4d43-81ba-12203e6549a2	\N	018ce88a-19ec-4e0d-a35c-9f9abbe7d423	Đồng cảm quá bạn ơi!
2025-11-23 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	395ae3c7-aca2-4629-b5ee-9ad49b4dc50d	\N	765b545b-ab9d-4dba-b26b-e9ebc393aede	Đồng cảm quá bạn ơi!
2025-11-23 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9e66361b-1eae-4fc9-b572-3e232715327a	\N	92db18d0-2fa3-44c1-a5e7-b7a0b1a15cfb	Đồng cảm quá bạn ơi!
2025-11-23 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4724cb8b-5418-422c-9b93-c0b3dd6775d0	\N	009e8f8d-1862-4387-9fa0-d35c009a03e6	Đồng cảm quá bạn ơi!
2025-11-23 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0b5bb8c5-12d7-47ab-a112-bb4b9f1554f8	\N	3a488bda-31da-4c0e-a48d-9df821f81f4c	Đồng cảm quá bạn ơi!
2025-11-22 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	53b9e004-b7ae-41b3-a3f7-4faf6ae6f0b4	\N	e8c9b48f-bb4e-4885-92bd-7ec972be3865	Đồng cảm quá bạn ơi!
2025-11-22 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b443c1d7-30f6-4aac-9a71-e30c9f615cb7	\N	de3c6d3c-9551-4483-8b6d-a89a9673e6e2	Đồng cảm quá bạn ơi!
2025-11-22 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	759ecaa3-3a89-4dc7-9bcc-dedc6a3a1aa1	\N	dbbcd2d5-b9d7-48b6-88ca-af09db4cdaa6	Đồng cảm quá bạn ơi!
2025-11-22 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	bce5db2b-2862-41ab-a4cc-7b2ffb075c10	\N	329f165e-054a-4190-9b74-d0cb07700e11	Đồng cảm quá bạn ơi!
2025-11-22 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	62c15fdc-ae8b-4576-9906-36301b619e0a	\N	420e5094-6aa0-42cd-8386-912f01d41dd5	Đồng cảm quá bạn ơi!
2025-11-22 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4f8daba4-cfa7-4e2d-9d33-68f28ea453ae	\N	d3f183f2-5e0f-407a-b29e-ac189105796f	Đồng cảm quá bạn ơi!
2025-11-22 15:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0dc6c167-f6fe-424c-9ee4-7f2a69ebf083	\N	884b6db5-5247-43e9-ac9a-9b522216c650	Đồng cảm quá bạn ơi!
2025-11-22 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8ad7c059-58f1-48fd-9408-88a369516316	\N	a2003227-c9ee-46e8-800f-ec2a24a90f99	Đồng cảm quá bạn ơi!
2025-11-22 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cfa0047b-8dee-496c-907f-5d43f2f25806	\N	436d5545-896f-4b2c-a457-b5d867c31aff	Đồng cảm quá bạn ơi!
2025-11-21 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	90821bc6-096b-41e0-bc7b-5a38e9f03562	\N	a0576d7a-2356-41d3-8040-2418a8518e49	Đồng cảm quá bạn ơi!
2025-11-21 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5c0d18a4-859b-47db-bad3-1b06e68c6a81	\N	edfd111b-0ce6-47b2-acf4-13272b45a550	Đồng cảm quá bạn ơi!
2025-11-21 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	57bf3824-2ad1-4fff-93e7-9f585a007786	\N	d84199b9-1574-41d2-8d92-896eafbb2324	Đồng cảm quá bạn ơi!
2025-11-21 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b19ef092-58c0-45c0-bf1d-c6bdb9852c3c	\N	90bbc811-f855-41f0-98e3-79eacde99da0	Đồng cảm quá bạn ơi!
2025-11-21 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9ec1580e-433e-408f-8c25-7a8860f79eee	\N	ec1b4911-d5ff-43af-a7a6-0ffd301ab427	Đồng cảm quá bạn ơi!
2025-11-21 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c6d627fe-6737-45ea-83ad-5974bae165fb	\N	de1aa8cc-6863-47a1-8132-150d762852c6	Đồng cảm quá bạn ơi!
2025-11-20 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	03333511-59dc-4727-9d55-9c2e841edbec	\N	f9a96ec1-29a2-4d72-b98a-139470db22a3	Đồng cảm quá bạn ơi!
2025-11-20 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	bd863dbd-0c73-4fa0-927e-e3c367f40b83	\N	7acaa218-dbd5-4517-b814-ff1f97bdf6f1	Đồng cảm quá bạn ơi!
2025-11-20 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f5931862-7093-4ff6-9410-933c37fe13b0	\N	f86fd3f1-45e2-4998-b465-c10f5483f2e8	Đồng cảm quá bạn ơi!
2025-11-20 14:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	af974a09-9140-433d-a66f-5b1bc879de31	\N	315cbe78-ff19-4a10-9df6-4c324e55a308	Đồng cảm quá bạn ơi!
2025-11-20 13:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c5c61396-9a3c-4fee-b54b-80d5d33cd81e	\N	8c0f6e42-050d-4a87-82b6-4d407f9be2da	Đồng cảm quá bạn ơi!
2025-11-19 13:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	dda2c972-4146-4471-bbdb-2db1feb468f3	\N	c34ec469-f699-4cbc-9241-8e0992688aad	Đồng cảm quá bạn ơi!
2025-11-19 13:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0211a852-7dd4-4dfb-a991-b613624a0f89	\N	ea7dc302-8294-4b76-9edc-808eb27201ee	Đồng cảm quá bạn ơi!
2025-11-19 13:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6ef49ed8-853b-40da-ac1e-4be627d1a624	\N	9a01cba2-9740-4bdc-b3a2-c97fa387145f	Đồng cảm quá bạn ơi!
2025-11-18 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	92e77f43-8bc5-4ca1-8a87-ea4323390ff7	\N	213387bc-4d29-4caf-a532-93b850d29b34	Đồng cảm quá bạn ơi!
2025-11-18 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9f35afc3-f28e-4020-ab53-35339fb4282b	\N	abb693cf-33ff-44c9-a64d-440ae1904bb6	Đồng cảm quá bạn ơi!
2025-11-18 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	450d96c7-af00-4a12-881c-fd54802c8510	\N	311ce3af-5f0a-4011-9e7f-dd2ad8f01fa7	Đồng cảm quá bạn ơi!
2025-11-18 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	afe44519-ec88-4330-b7f6-12ce3d15ae9d	\N	9db9f670-0a6e-4fa0-9a6d-2737fb28303f	Đồng cảm quá bạn ơi!
2025-11-18 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b530309d-d132-44f2-adbb-b833a1192430	\N	7f83c5f7-a1f5-4704-bfb8-b098e7ca8df0	Đồng cảm quá bạn ơi!
2025-11-18 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c3e90e9f-f86a-492c-902b-8d8548a9ab0d	\N	12b0b6f0-9820-4732-aba6-331411b6a4a9	Đồng cảm quá bạn ơi!
2025-11-18 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e0a6c663-ab44-4e26-84cb-2cf76fd9902d	\N	01fbe6b4-42ea-4f13-aedc-b41b66b63f36	Đồng cảm quá bạn ơi!
2025-11-17 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5aca239c-7db7-44bc-941c-52a8d1076f48	\N	a694c11b-ad03-4a7a-bb82-7ac1f30addb0	Đồng cảm quá bạn ơi!
2025-11-17 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	acd0ff65-58f2-4328-b9b8-7a59efa831e5	\N	9a4131b4-2029-469c-b261-72971a4cbbbb	Đồng cảm quá bạn ơi!
2025-11-17 12:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ecb72f73-b289-4f43-8ee8-a076f61c2d9d	\N	256dfa3b-6b08-4076-b027-717b4748f1f3	Đồng cảm quá bạn ơi!
2025-11-17 11:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b1bff97c-6cc9-4e04-bf2e-ad6b3e6276f1	\N	f778f110-1a0a-471d-9de1-33f3f6f30475	Đồng cảm quá bạn ơi!
2025-11-16 11:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	65f85d2b-8d08-457f-b6d8-337f8f61fa81	\N	31bcf1b7-1479-4d25-a6cb-9cb2cb0ba460	Đồng cảm quá bạn ơi!
2025-11-16 11:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1e8b24c4-4d08-4844-855f-a3978f81bdc4	\N	ab97709f-d2e6-4967-ab09-3e24512c52a5	Đồng cảm quá bạn ơi!
2025-11-16 11:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	21400dc2-a4e0-4db7-955a-ad9e0da091d2	\N	c158497f-c68c-425c-bb99-8e6814363bc8	Đồng cảm quá bạn ơi!
2025-11-16 11:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	57fcd551-de6c-452e-93e7-04e261f6fe0c	\N	9320aa87-a31d-45cb-b57c-7069333e6c57	Đồng cảm quá bạn ơi!
2025-11-15 11:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2fd09c9e-8089-4949-bbd5-53465f199a69	\N	6f91d50b-8aff-4803-99ab-b53028981df0	Đồng cảm quá bạn ơi!
2025-11-15 11:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	957d1009-56ea-4f19-bab9-d80765920f4c	\N	06d35722-3bfd-409e-84ef-116aac88c4c3	Đồng cảm quá bạn ơi!
2025-11-15 11:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f23827cb-4db3-4161-ab06-181c94623252	\N	c788d142-afe4-4790-9f7a-d6d6bcb4017a	Đồng cảm quá bạn ơi!
2025-11-15 10:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e989b214-8b01-4e86-aac7-a404cc0e8483	\N	0e8647d3-f2ff-4673-8f48-28e8228661e6	Đồng cảm quá bạn ơi!
2025-11-15 10:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0b9a6e16-75c1-4524-bd16-cc303cb70b0e	\N	f83553c0-8ed8-4cb7-a0eb-1209bd258a17	Đồng cảm quá bạn ơi!
2025-11-14 10:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c313f4b5-2ba6-49db-a32b-7323be63e09a	\N	e0d80e6e-72dc-403f-ae90-5a71399b50e9	Đồng cảm quá bạn ơi!
2025-11-14 10:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fefcce34-89b5-40a6-9d86-4e7b30e2f4e0	\N	1523948a-a727-4f0c-9d52-e33c20f3834e	Đồng cảm quá bạn ơi!
2025-11-14 10:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2fcd1514-4703-4100-b7aa-6c253488844c	\N	f5449411-3ee3-47a9-aa52-7c63aae2de5c	Đồng cảm quá bạn ơi!
2025-11-13 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b2b8272d-bdb2-4a57-abf9-11b3e6f0ac0f	\N	477ea1c4-d0db-46eb-a83d-1887c3066c76	Đồng cảm quá bạn ơi!
2025-11-13 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	50278a43-3fc7-40f9-82e4-f5eabb1b08b1	\N	808e28fe-5c97-4120-966e-0961cc3a7d9b	Đồng cảm quá bạn ơi!
2025-11-13 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f9e4d2d3-59e1-4a85-8484-75f9e179c7d2	\N	b6b6ffc7-5608-48f7-a91b-7624854d4c18	Đồng cảm quá bạn ơi!
2025-11-13 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a99d59f7-2863-4000-aa05-6a046e4abb06	\N	e1293ed0-26c7-40c1-979b-4431bb2d8161	Đồng cảm quá bạn ơi!
2025-11-13 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ab6deec4-9f5f-4e3b-a3a9-ba6d04bba2da	\N	60ef2f7d-e772-42d0-af2d-62221c62400b	Đồng cảm quá bạn ơi!
2025-11-12 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7249992f-54b0-4ae1-a444-10293f4fa55b	\N	3b67bced-d152-49d5-a170-189200f33385	Đồng cảm quá bạn ơi!
2025-11-12 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	094ab4f3-34dc-46fd-a717-6249f8fe3aeb	\N	23cce978-fc18-4d3c-92a4-d82717f7c9ac	Đồng cảm quá bạn ơi!
2025-11-12 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f0220975-53b7-45ca-b60d-4389009ff3f1	\N	3dd06b24-a7c0-49f6-a16e-d1e6a34739be	Đồng cảm quá bạn ơi!
2025-11-12 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	59524091-6b0f-4054-8af9-fab88a80fca1	\N	a5869473-14de-4b81-bf19-c5fcbef3f988	Đồng cảm quá bạn ơi!
2025-11-12 09:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	df7b835c-44de-41c9-8744-f2ceb0054eaa	\N	b6db8f9b-db77-4c20-92cd-62b41bf9c944	Đồng cảm quá bạn ơi!
2025-11-12 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c6e5be6e-9844-4987-a71a-41c23c830ee3	\N	0dc13a3e-bf85-4410-9679-daa0e3f1db35	Đồng cảm quá bạn ơi!
2025-11-12 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d03ce4ad-9db7-492c-9e38-96767b91f59e	\N	4ad73a4d-022d-49b2-9b93-2eeb0f3c4c8a	Đồng cảm quá bạn ơi!
2025-11-12 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6e698e2e-0860-4c41-817a-2eecaba8261e	\N	e6a861b8-ad18-496a-84b6-14406c206656	Đồng cảm quá bạn ơi!
2025-11-12 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d509531f-04a9-4e9c-96be-468060935b04	\N	a07d951d-33aa-4dcd-9d6f-38f0dd3bbbb1	Đồng cảm quá bạn ơi!
2025-11-11 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4a4e6322-7196-4f50-b7c5-34c74872875e	\N	8f178140-5846-4df0-8786-129675be0fff	Đồng cảm quá bạn ơi!
2025-11-11 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	157bf14b-40b2-4aa8-b52d-1d00ab4e6eb5	\N	60808489-351b-4443-a95d-1fee8f8d9ba3	Đồng cảm quá bạn ơi!
2025-11-11 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8f4815ac-1027-4dd9-b85f-be536222b441	\N	e5438053-97d0-40a1-94cf-6504caed7ce7	Đồng cảm quá bạn ơi!
2025-11-11 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4449dd0d-426c-4e12-af31-1b3143a43c4d	\N	b4a3a72d-9a2e-4cc7-9805-e0d7b8460086	Đồng cảm quá bạn ơi!
2025-11-11 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6ace64d4-b159-4c24-a2d2-8b91caa3bdaf	\N	9d71f4bb-1ad9-4ef0-bb20-b99702b32474	Đồng cảm quá bạn ơi!
2025-11-11 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4d7e68ae-a2bc-403a-89a8-95b77d025a73	\N	c5a53e66-d3fd-43b3-9e56-1d175cfe09c4	Đồng cảm quá bạn ơi!
2025-11-11 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	72c2f156-a95e-48d4-8303-b7458d5564bd	\N	4c46dd9f-22b6-43f2-8856-087f30ed0745	Đồng cảm quá bạn ơi!
2025-11-10 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6ff7fde6-1341-415d-908e-e095cf7153d2	\N	1abd00ce-2cd5-4197-b058-5bbabdd79ab2	Đồng cảm quá bạn ơi!
2025-11-10 08:50:57.936814+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a8182d09-1c82-4fc7-a955-e558795c8969	\N	a1434472-6a39-42d1-8322-2242b0faec4c	Đồng cảm quá bạn ơi!
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b8ff92b8-c2f9-4436-a2b9-f3296b1ffc37	\N	488d9dea-8553-4e49-bf2b-106c5e143613	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	dc66d532-a0d5-4c97-82a7-1205a6c798e4	\N	de1aa8cc-6863-47a1-8132-150d762852c6	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9eb10af8-e675-4801-a6aa-90185a8caf61	\N	c5a53e66-d3fd-43b3-9e56-1d175cfe09c4	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7f59ce09-8b76-4512-bbb5-9cab7a542403	\N	23faaa79-5567-4c1b-98ea-11d42b9a5624	Đồng cảm quá bạn ơi!
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cad693b5-d9ff-42d1-90a3-2578ba7eb288	\N	3a488bda-31da-4c0e-a48d-9df821f81f4c	Đồng cảm quá bạn ơi!
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ea7478f1-f8dd-4be4-89c4-d5ecdb23fef4	\N	66662d1b-794a-4641-8886-3e91bb3158aa	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5626e685-b55c-4e35-ba7e-4d785a1ccf04	\N	e554f9a2-fcb9-4c85-a52a-6ea2955117b3	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	abd81d27-689b-4938-ace0-43ced6a877da	\N	9e065a1a-6f22-4a4f-8263-8eef128ffd61	Đồng cảm quá bạn ơi!
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	90b43c8b-6a25-46cf-9c8f-1ae348bbd842	\N	4c46dd9f-22b6-43f2-8856-087f30ed0745	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d07b1587-5646-4731-aab6-018998201701	\N	5aeb9d98-a984-4361-a914-a9c0d171f792	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2570ca87-c105-4a20-b4ca-913cf72163d3	\N	b6940166-e3ce-4374-8aaa-255442a58979	Đồng cảm quá bạn ơi!
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	052ca5ab-77c7-4ec2-8b9d-fa6910e666b9	\N	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	Đồng cảm quá bạn ơi!
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3a3cb978-a003-49d8-a830-52a1363f1bb2	\N	7114471f-f682-41a6-bdb6-3369e68bb7a7	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	04793c74-e896-417a-a86e-8c043f4071a6	\N	e67b6f1e-a2ef-4128-9778-cceb03f71a8e	Mình cũng nghĩ vậy
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c0a10b14-ca33-43e9-b143-6c65ce5ef30a	\N	f366ce18-ef44-47cf-97a5-310852627315	Đồng cảm quá bạn ơi!
2025-12-19 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3562db3e-d0e9-4357-b3e2-5523c1b66028	\N	009e8f8d-1862-4387-9fa0-d35c009a03e6	Mình cũng nghĩ vậy
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a8776d01-abaa-4c64-baaa-d7049d617c05	\N	3dd06b24-a7c0-49f6-a16e-d1e6a34739be	Mình cũng nghĩ vậy
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2d1bb503-d02e-4009-a985-e945cf8dcfda	\N	3ea2b20c-4071-4a2c-a69a-e6583f32297a	Đồng cảm quá bạn ơi!
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d8b2a6c2-8f65-40f5-a57a-ac419a125ca9	\N	74c0890a-7d32-4666-9001-8616fe63af61	Mình cũng nghĩ vậy
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8f3e4579-4b78-4f90-818b-882d86fe69cb	\N	9ce9007d-83b9-4344-ba8b-e8bae232f23d	Mình cũng nghĩ vậy
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f7f9e6c0-e378-480f-ac4e-f9beea481403	\N	d190b3bc-6b6d-48bf-ac30-8b84d9fb842c	Đồng cảm quá bạn ơi!
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6384cc73-22f2-4f08-bc44-1f32759d8476	\N	60808489-351b-4443-a95d-1fee8f8d9ba3	Đồng cảm quá bạn ơi!
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6f56a778-6584-4869-8c22-2d99d4b80e3b	\N	b1461a46-ad73-49e6-88aa-044ab10017e7	Mình cũng nghĩ vậy
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f3bab5d2-bd2f-45ab-9ec6-d24fd60a8e6f	\N	5fac3e18-5f50-4fc0-ab54-05919a94a927	Mình cũng nghĩ vậy
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d1000522-a4d8-41de-9831-46c7a455870f	\N	dbbcd2d5-b9d7-48b6-88ca-af09db4cdaa6	Đồng cảm quá bạn ơi!
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	717aad8c-6521-4627-ab46-d5517a21afe5	\N	8445bbf5-682f-4779-95fa-08c971679f91	Mình cũng nghĩ vậy
2025-12-18 06:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	eed9389d-58f6-46d8-98c4-871c6fce1c57	\N	d0ee6ccb-46f1-44ce-8ae0-76934935ba51	Mình cũng nghĩ vậy
2025-12-18 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a2bd2480-aab5-4ead-b056-f2e0129f51f5	\N	e7e21702-500b-474c-8974-501bc20cf482	Mình cũng nghĩ vậy
2025-12-18 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a020676e-3280-4ec3-8150-ea62fd72b89e	\N	97dcb5e5-2f77-4296-8adf-d17c166a56e1	Đồng cảm quá bạn ơi!
2025-12-18 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	66706adb-e550-4d48-9130-f8d7fae22b35	\N	cec1d8b9-819c-436a-b62f-ffcc52a112d9	Mình cũng nghĩ vậy
2025-12-18 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	14767689-2192-4d86-b423-3a58d6848108	\N	f30b4b1e-0a61-42e2-b458-1c2ee9d5ef33	Đồng cảm quá bạn ơi!
2025-12-18 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9303eb84-5844-4eec-a21b-0b61536e0922	\N	380cbbe2-5e4e-4fbf-8834-0426188b4486	Đồng cảm quá bạn ơi!
2025-12-18 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6f312ecc-942e-41fa-b1d0-b3c43d25d55d	\N	2632f577-b312-4a72-884d-1d94bef08c6c	Đồng cảm quá bạn ơi!
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	28139655-9087-4480-a703-9840b2685819	\N	1c73df41-2c80-416d-b536-455c2b3ee6c1	Đồng cảm quá bạn ơi!
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	21b8908c-38c4-4f37-9088-32bed432e659	\N	08d8aad9-3f6f-474a-b207-676809f9d0a4	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e4a69461-7309-4daf-a548-7ce02cba217a	\N	ed0e7b6c-058a-48bf-a2c1-3f9af8b12528	Đồng cảm quá bạn ơi!
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	69106c61-b2f3-4a12-8fc6-d9198773daad	\N	54db354f-8588-49b2-90aa-fbcbb6dd542c	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4fbdc087-d424-44dc-b850-ea09f795a3e8	\N	54128841-d796-4af0-adb3-2e8ac9b9fd8a	Đồng cảm quá bạn ơi!
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fd055f35-9ea4-4dff-95fb-c01a45839cab	\N	80a80c68-5b98-4043-a0e8-ae6c11bf7961	Đồng cảm quá bạn ơi!
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1fd080cf-052e-423c-a25c-0b2e2df96975	\N	915a00b7-48a4-4ff8-959b-f20c42ae157f	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	31c9164d-eecb-4a44-90a3-c7c0d85cb9a8	\N	57be9dcd-a4bb-46ad-a80e-57ff8cc881c9	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	63ed2085-d3d7-4374-accc-03cb29138087	\N	cdd0d903-6588-4227-a33c-e8a99769f675	Đồng cảm quá bạn ơi!
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	28346196-ab67-4e6d-b965-907cadbf9f6e	\N	3bf42efb-51fe-4faf-9fc9-6a9df2243402	Đồng cảm quá bạn ơi!
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	08d161ee-632e-486b-96c5-c95d6bdbd922	\N	23cce978-fc18-4d3c-92a4-d82717f7c9ac	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1d6cc804-3a3b-491f-b3a6-0dd64259f714	\N	614a72a8-1a61-4f22-bbce-35c735e856ca	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ac7e10c1-c360-4e5d-87be-1495b2c9a9bc	\N	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	Đồng cảm quá bạn ơi!
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	45d4be82-864b-4fe9-8e58-f476352a81a8	\N	057c9a87-24ea-4844-a37e-bf1af1f3c167	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e37a9a2a-ec52-4386-a0fe-7661c4b70f5b	\N	eaabd4e5-b6c1-4678-9cea-58d7190a7f3e	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5436e152-b148-4a6c-ac2d-85137774d8a6	\N	b95c500b-e7d5-4307-9319-55e304e2ca2d	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	84f41121-d6f3-4933-8114-e6e999cee92c	\N	691e36d7-2272-4158-93ea-700bd34fc4d8	Mình cũng nghĩ vậy
2025-12-17 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c99152fb-bf21-4bb2-8632-4c2290a69d45	\N	6f577918-32ff-4dc8-a835-235b2d55c345	Mình cũng nghĩ vậy
2025-12-16 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	889aa833-a5a5-4796-9639-fb23c75e78b2	\N	b6940166-e3ce-4374-8aaa-255442a58979	Mình cũng nghĩ vậy
2025-12-16 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9a029100-0341-4f4a-a9e4-c8f6fef0171d	\N	7246201d-47c5-4367-927a-9adabaf621c7	Mình cũng nghĩ vậy
2025-12-16 05:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	280795fc-f2b3-4fe3-9e8a-9fc43fc2edf7	\N	7acaa218-dbd5-4517-b814-ff1f97bdf6f1	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	93c51d2b-1f0e-423f-8cbc-a91f418d0f46	\N	b6db8f9b-db77-4c20-92cd-62b41bf9c944	Đồng cảm quá bạn ơi!
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f1a5914f-4fd2-4598-92b4-a2f88601b11d	\N	28a23ecf-7e87-4517-817f-71005f2181bc	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e2b92c00-25f3-413a-8b0b-89f97687bad7	\N	ccc4a84e-e519-4526-aa4e-f41f4482c019	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e0be4dbd-7186-4613-b4b3-a1d34f0151fd	\N	729c5095-4965-4b06-8a3e-74f892f58d64	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5d77d1cd-7929-42e8-94a1-b315c8d9db96	\N	e4e541fd-46d3-48ca-b2ad-dc2d30f752bd	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	11b8f575-6632-4b88-9f03-6cc0777079e7	\N	7114471f-f682-41a6-bdb6-3369e68bb7a7	Đồng cảm quá bạn ơi!
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ee202bf5-640f-488e-9a6a-00f724e9d335	\N	051ab58e-69ba-4143-b327-542caf8b0265	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7b386374-cd75-4881-8cd0-d7b73bc20f8d	\N	a07d951d-33aa-4dcd-9d6f-38f0dd3bbbb1	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	57241e39-d5fc-4532-bfd9-af8e0d9ddc1b	\N	3b2a05d2-c06d-4580-97d9-01b3b340af85	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b30e5214-a999-4049-b26f-45cfde1da101	\N	a2003227-c9ee-46e8-800f-ec2a24a90f99	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1966986a-1e4f-473e-b5e9-f995c3b492d8	\N	4d6dc4e8-6018-497e-9ab2-630f51195bd0	Đồng cảm quá bạn ơi!
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	713d404a-29fe-4663-8a67-40b3dfe6ba9b	\N	53af5af3-44dc-4e98-94f3-7dc2a602c2d2	Đồng cảm quá bạn ơi!
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5ed70e32-20d7-4f90-921c-29af63cc52d9	\N	af1518c6-25eb-4d4d-be15-047336e3b091	Mình cũng nghĩ vậy
2025-12-16 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f5f74403-6fe3-424a-b62d-7fd71e604635	\N	6f91d50b-8aff-4803-99ab-b53028981df0	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	bb5c426d-4910-4454-b6ca-03b781fed766	\N	ccaa812c-5688-4086-a76f-4d29eba4aa9f	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fb77b65f-2786-4037-919f-8c2685ba724d	\N	2140c3e5-87fb-4af8-b550-4947527f85c4	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	49af8c3c-00e4-4846-9497-3fd8002ece09	\N	5abc8d96-0dce-46eb-9d46-1ff4f7020e00	Đồng cảm quá bạn ơi!
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b2cb132b-f8bc-41c7-afe3-8549a5d55c4c	\N	fe8d3a4c-aedf-4c69-b77c-fce738f680d2	Đồng cảm quá bạn ơi!
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c9fd4b43-cee4-4116-b5ba-edd22f6bfef2	\N	1c53e1ce-c1dd-4d64-afba-b76249b0c44a	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c861e3fe-2520-4c29-9ad3-f43e6639a8fa	\N	e67b6f1e-a2ef-4128-9778-cceb03f71a8e	Đồng cảm quá bạn ơi!
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	08ae496d-0ce0-4f88-98b1-9b47d2329728	\N	08eef7b4-15a1-44c2-b093-228cb76da93f	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7d1a9f37-5e9c-4418-b434-a524bd6b68ad	\N	e0d645b4-2eee-4f1b-ba6a-24d01c971d16	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	00661ef0-eefc-46df-9bf0-b98315efb04d	\N	31bcf1b7-1479-4d25-a6cb-9cb2cb0ba460	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	da358671-57cc-4060-8edf-46b316a329c0	\N	a7eda267-2926-4574-b931-9087cc71040d	Đồng cảm quá bạn ơi!
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cee65fb2-7685-4001-aaf5-a9575f626255	\N	3b67bced-d152-49d5-a170-189200f33385	Đồng cảm quá bạn ơi!
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8aecd157-652f-4caa-8d17-79c3d320fd44	\N	a694c093-5d90-463e-ab71-79d8b6f79061	Đồng cảm quá bạn ơi!
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	24a0d85e-28f0-43d2-b1fc-6ab3881ef179	\N	329f165e-054a-4190-9b74-d0cb07700e11	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f5ae5302-4e6b-4497-9d6b-4ce84fd0a93d	\N	2b4d404f-af98-4b6e-97e2-487f9b84047d	Đồng cảm quá bạn ơi!
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3c6661fe-b2c7-489b-9271-b6e1e2449ff7	\N	5ff4d30a-548e-4476-bb8e-d8e73cf1f1b5	Mình cũng nghĩ vậy
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	38e839fd-a36a-454f-80aa-cbb69250c681	\N	90bbc811-f855-41f0-98e3-79eacde99da0	Đồng cảm quá bạn ơi!
2025-12-15 04:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d4a77392-e3a0-4d50-9c87-adbbc6333276	\N	12b0b6f0-9820-4732-aba6-331411b6a4a9	Mình cũng nghĩ vậy
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f5f48600-e4c9-44c7-94df-60f5709eea7d	\N	36b82712-226b-4a36-b68e-a4be9699b751	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	89cf7281-bda9-4a5d-8fe5-c6b017c54c9d	\N	ae3a3f5b-3f4f-4375-956f-0a31ffeb4dff	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b8f36688-97a3-416b-bca7-0e37f87f6eac	\N	eeb66971-eb18-4de6-a7d6-dbb01565691e	Mình cũng nghĩ vậy
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	23d2d419-db13-4d8b-a95a-3e72ad8d114b	\N	eba98c94-a2b3-41f4-9236-bd714b17ca34	Mình cũng nghĩ vậy
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	edee30ac-3a61-4d82-aa7c-89d509bb01ca	\N	2610e16a-4484-4285-9f79-10632c59349d	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	30ef7162-06dd-4062-bcfe-12c1f502b686	\N	cec1d8b9-819c-436a-b62f-ffcc52a112d9	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	34c9d8b7-0f45-4da0-9583-1a1debaaa5e9	\N	fb3956bd-ff46-469d-91a6-617dad6e2145	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	88937aca-7327-41f4-a8ab-3766d66ccb2d	\N	c8ce2c04-4e3e-45d5-8d2c-a47831c412c4	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	bb30b6eb-cd4a-40ff-afa4-0cbd47de8607	\N	7342e45e-d093-4738-b89e-f84a24144972	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	00af3b77-8e2b-4359-b40a-b33e006b62fa	\N	009e8f8d-1862-4387-9fa0-d35c009a03e6	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	73799217-785b-4f03-941c-5f7ef9a4398f	\N	0e8647d3-f2ff-4673-8f48-28e8228661e6	Mình cũng nghĩ vậy
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2c9726e0-f5b9-4aea-bc60-663a9c1ec94a	\N	4e7448c6-9db7-4fc2-8f4c-075eae48f1ea	Mình cũng nghĩ vậy
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a265a127-2836-42dd-b4bb-c0a1acdaf5af	\N	256dfa3b-6b08-4076-b027-717b4748f1f3	Mình cũng nghĩ vậy
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6cba8b6a-0180-4431-bbbd-6ca2fbca7ebf	\N	e38fc669-c571-4b01-9031-7c74fcdb9fed	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	458b7690-331c-452f-8c01-81bd6a550807	\N	5f515192-7964-4845-ae91-82e9c74a65ef	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	26de508b-ca7b-44e0-ba8d-08e5064cb349	\N	c92262a6-94dc-4a2a-9236-444a0b09020f	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ded3d99c-e5ea-422a-ba4e-4338236ddc57	\N	477ea1c4-d0db-46eb-a83d-1887c3066c76	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e914d712-86b0-420c-a30f-81d6bec96856	\N	af1518c6-25eb-4d4d-be15-047336e3b091	Đồng cảm quá bạn ơi!
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c39f855b-9a04-4f06-808b-4f8b6a926f64	\N	306fe046-1b25-40e6-8a27-bec37bd32614	Mình cũng nghĩ vậy
2025-12-14 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6ac295fe-99a3-4d42-a020-91393dcb29e9	\N	3b67bced-d152-49d5-a170-189200f33385	Mình cũng nghĩ vậy
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ebc3823f-38f9-4f2f-9061-18234d2603dc	\N	28acbe82-8894-48cf-b1f2-be232ae4f20a	Mình cũng nghĩ vậy
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	71631c02-de5d-4360-84b8-67d16386c752	\N	765b545b-ab9d-4dba-b26b-e9ebc393aede	Đồng cảm quá bạn ơi!
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1d33f2ac-879e-45d0-8f46-2cc31c4a3582	\N	a7bf8fc4-211b-4c93-91a5-2a927127e019	Mình cũng nghĩ vậy
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2ad56450-29b9-4684-8b9a-6b9a04a84763	\N	caf7a7bc-0d09-4668-b59b-7efb63a7ea00	Đồng cảm quá bạn ơi!
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0a4ae676-7928-4d28-abf5-613962784e81	\N	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	Mình cũng nghĩ vậy
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5abb53dc-6713-415e-8b93-66b676b2f68b	\N	4e7448c6-9db7-4fc2-8f4c-075eae48f1ea	Đồng cảm quá bạn ơi!
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d8685c68-57cd-43e5-84b1-be8cd9a60037	\N	eeb66971-eb18-4de6-a7d6-dbb01565691e	Đồng cảm quá bạn ơi!
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4d1078b5-0903-4c0c-bdb1-bb22cd6ac9c2	\N	3ea2b20c-4071-4a2c-a69a-e6583f32297a	Mình cũng nghĩ vậy
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	af647bb4-14f4-409e-85a3-cc5eaad60e26	\N	37a692c5-a433-4c01-a3a4-cdb0918110c3	Đồng cảm quá bạn ơi!
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	540264b8-5b12-438d-b122-c8e7ab45bc44	\N	af5511d8-6187-4402-850c-9a567ff84ee2	Mình cũng nghĩ vậy
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ea76be38-c8c1-4b0f-88ff-7bcd2fdbbfc5	\N	b2023a96-a193-42ac-9de2-fe4be55d04e3	Mình cũng nghĩ vậy
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	31bd96a9-137f-479e-b298-6db8194838d8	\N	b20e0159-de08-4174-8a71-83ebb743c360	Mình cũng nghĩ vậy
2025-12-13 03:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ca615c08-9463-4cb6-a593-96f4c2a17f22	\N	04578903-cbcd-4227-8344-8af8af430449	Mình cũng nghĩ vậy
2025-12-13 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	06148deb-ccd7-4c51-9383-58306b404b70	\N	f51e1a97-cf97-4c57-ad8c-84165bafe12f	Mình cũng nghĩ vậy
2025-12-13 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6374054f-9648-4184-b706-5a14719462dd	\N	9d71f4bb-1ad9-4ef0-bb20-b99702b32474	Đồng cảm quá bạn ơi!
2025-12-13 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cc51b2ce-36bc-4416-9e23-b473d4e3c7d8	\N	57be9dcd-a4bb-46ad-a80e-57ff8cc881c9	Đồng cảm quá bạn ơi!
2025-12-13 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c093f131-bdf8-4696-8113-2fc85441adc2	\N	23bd823f-8c3f-4607-8605-59ff67874886	Mình cũng nghĩ vậy
2025-12-13 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7b424fe3-22c8-4447-91de-79af240f3e8c	\N	329f165e-054a-4190-9b74-d0cb07700e11	Đồng cảm quá bạn ơi!
2025-12-13 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2bd5cd25-46b0-4c49-bd77-4694dbb54186	\N	305c8ceb-c59c-4f6e-b95e-4dc175cb42b9	Mình cũng nghĩ vậy
2025-12-13 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2af58b16-c067-48f3-993d-b1afa8a277f5	\N	9db9f670-0a6e-4fa0-9a6d-2737fb28303f	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	bd66cf96-7e6d-4d99-bb73-786c91a7fa4c	\N	c788d142-afe4-4790-9f7a-d6d6bcb4017a	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3b4a2176-d4a1-41b5-bd25-3aacc5e6a1c1	\N	60ef2f7d-e772-42d0-af2d-62221c62400b	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9bfd7864-34f5-4c62-a7b8-35c734489188	\N	eae6dafb-6483-4269-95b9-7e404a7ef8b6	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	dc5c6811-0ee4-46fd-9039-9529ebb9cd13	\N	eae6dafb-6483-4269-95b9-7e404a7ef8b6	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	47667356-aa54-4a59-a496-503de5bc553a	\N	e5438053-97d0-40a1-94cf-6504caed7ce7	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0d1220e7-6613-49db-89a0-2adcc7875d17	\N	4a1ad6a0-5702-42e7-a756-9801595e1b2c	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6afb0b10-e7c9-41e2-8a1e-434f867f622a	\N	6f91d50b-8aff-4803-99ab-b53028981df0	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cc378b12-2174-4342-92e6-0744294e5429	\N	9a01cba2-9740-4bdc-b3a2-c97fa387145f	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8a847525-ee78-45eb-b4bc-06533d22d4ee	\N	de3c6d3c-9551-4483-8b6d-a89a9673e6e2	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cc6ded9a-1b10-48d4-8d3e-df2888d75198	\N	c56ee46e-b91e-419f-b214-5542b6913882	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	751bb3a1-d2eb-4990-b8a8-77ba23d3cb2c	\N	ad0c8bdf-0ca4-4e7d-b3ec-f4b735d7a10b	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	349b76d9-d6d4-46f9-a99f-7f488114eabd	\N	b81c3242-04a1-49eb-b283-892421cd45c6	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c839e23d-3754-4ef9-8f5a-5537d923845a	\N	8c0f6e42-050d-4a87-82b6-4d407f9be2da	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	07af1b60-b31e-4dac-939c-2470807e68f5	\N	9ddf37da-0863-4bd9-b961-ee25d37c8bd8	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	762ce5ad-d0b7-405c-b88c-800df8c6edc9	\N	37a692c5-a433-4c01-a3a4-cdb0918110c3	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2f7f523f-f4a2-41a2-abbc-f97d7811a527	\N	8a7f2fae-66cd-4800-8d42-2e6860739654	Mình cũng nghĩ vậy
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	741acce7-be83-4740-b10f-4747aa42958c	\N	5aeb9d98-a984-4361-a914-a9c0d171f792	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d893b17f-f7ab-4df7-a496-8526679cca92	\N	3dd06b24-a7c0-49f6-a16e-d1e6a34739be	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	54918ae0-b21d-49b9-a4ad-966ea33d92f4	\N	c158497f-c68c-425c-bb99-8e6814363bc8	Đồng cảm quá bạn ơi!
2025-12-12 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	420203ab-f26f-4459-a7c9-9cd2751bab8a	\N	8ecee724-6c1c-4c1a-bd0d-928c2bff8d0c	Đồng cảm quá bạn ơi!
2025-12-11 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b44332da-3746-47d8-98b5-d3ddd394133b	\N	a7eda267-2926-4574-b931-9087cc71040d	Mình cũng nghĩ vậy
2025-12-11 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8063f8a4-3897-4181-b3b4-cc3a9ddd5ab6	\N	8dbc4147-7063-400c-99a0-97aadef49864	Đồng cảm quá bạn ơi!
2025-12-11 02:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	49a28cb6-1975-4ef7-be29-8f89c7cc4d5d	\N	97921494-ee29-4269-8eb2-6fc8f5d487b5	Mình cũng nghĩ vậy
2025-12-11 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e2c06a99-7b64-42ee-ac2e-442437fb5cad	\N	8a7f2fae-66cd-4800-8d42-2e6860739654	Đồng cảm quá bạn ơi!
2025-12-11 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	aa57cb00-5964-48cc-9318-705c2df3fbfd	\N	915a00b7-48a4-4ff8-959b-f20c42ae157f	Đồng cảm quá bạn ơi!
2025-12-11 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	466c215e-3de4-4a98-98aa-4a3b1b730be1	\N	0cc3c6ec-ff35-4da9-8b2a-08040fe92d4c	Mình cũng nghĩ vậy
2025-12-11 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2aaa8d95-aac8-466a-a5d8-9fc6e1e4ef1d	\N	2b4d404f-af98-4b6e-97e2-487f9b84047d	Mình cũng nghĩ vậy
2025-12-11 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	afbc29e9-0fa4-49a2-9617-9e2e6cbcff5f	\N	64f28997-8065-4c08-ab79-02adc85591a9	Mình cũng nghĩ vậy
2025-12-11 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5dfe6b4c-f276-4810-bee5-71e11387131a	\N	37dc1845-04bb-44bc-b32a-db37f0c25717	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f3a371e2-59cb-473c-aebe-ac8069d28d28	\N	a694c093-5d90-463e-ab71-79d8b6f79061	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cdea0cc0-6257-4654-b21a-527a91dd2573	\N	5c4b1abe-29ca-421e-a95f-6def93804ee5	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	918df699-6248-4a64-a708-b8e3f8c8cb90	\N	0ea2076e-81a4-4e49-a57a-a08dccf048ba	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0af1bedb-8028-4399-9fbf-df1c6cea4be6	\N	306fe046-1b25-40e6-8a27-bec37bd32614	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4b8ab130-1923-42f1-baac-6cea9d72a915	\N	6f05fb7c-7f24-4fb3-8763-312ea2b52779	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4fa970e0-53f3-491c-b860-6795d79c5202	\N	5fac3e18-5f50-4fc0-ab54-05919a94a927	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d52daa5f-f0d6-447e-acd5-798a68df2efb	\N	abb693cf-33ff-44c9-a64d-440ae1904bb6	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5f62c363-c532-4658-b5e2-2b7173d01aee	\N	b0430ad5-341a-416d-95d9-4c11649850d4	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	941480c7-e59d-4559-b0c4-545d2f7121c1	\N	a1434472-6a39-42d1-8322-2242b0faec4c	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	643cd85e-81b3-49a2-abbb-3424e698ea5b	\N	7001b0ed-c7a2-413d-aba3-8a453283ff19	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cb34c699-ad7c-4943-831d-108104c0e82e	\N	80a80c68-5b98-4043-a0e8-ae6c11bf7961	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0a4e54cb-4e41-436e-92bc-abbba9fd0344	\N	3687dfc8-f059-43e0-9088-2a42a0333d0f	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3fa9ddd8-77c9-405b-966e-62e3f702e43f	\N	23bd823f-8c3f-4607-8605-59ff67874886	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4a211627-0c2e-469e-9170-60fb1da4262a	\N	315cbe78-ff19-4a10-9df6-4c324e55a308	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ca6b23df-4df5-493a-b634-b240c63e5865	\N	c319c256-93cb-48dd-83c2-05428f75fa76	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3ffa0b42-eb9f-4d82-bffb-e522a032dd12	\N	a2003227-c9ee-46e8-800f-ec2a24a90f99	Đồng cảm quá bạn ơi!
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ca529e37-4891-4a3d-ae70-ee166a081b8e	\N	018e4a26-93c8-4ac7-99b6-ffef04f067ce	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	393b848b-c114-4e02-9ca7-9a04757929b2	\N	e900c3eb-5d9e-4b0c-8869-6bc21f08c517	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	52050a57-ed93-495c-8451-366f36624ee8	\N	58746496-23d4-4ae4-a1d1-1a3de2ef4609	Mình cũng nghĩ vậy
2025-12-10 01:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0d07d56f-7702-4d5c-a47c-da9d4cba6677	\N	5c4b1abe-29ca-421e-a95f-6def93804ee5	Mình cũng nghĩ vậy
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	eaafc5ad-0e43-4ec1-9e63-8456e95cee53	\N	f86fd3f1-45e2-4998-b465-c10f5483f2e8	Mình cũng nghĩ vậy
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	809d7240-e55f-4085-ac2b-2b18bcba3646	\N	d0ee6ccb-46f1-44ce-8ae0-76934935ba51	Đồng cảm quá bạn ơi!
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7f620d29-2f05-48fc-9eb6-a1c88222f98b	\N	f5c2c87c-6c7c-41a2-a09e-8b3e68a1ece8	Đồng cảm quá bạn ơi!
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3f25b303-60cb-4707-b904-43f534d625d3	\N	691e36d7-2272-4158-93ea-700bd34fc4d8	Đồng cảm quá bạn ơi!
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d2879abf-d139-4731-bd8e-f326c2075f24	\N	8a0db927-d52e-446d-8bc8-c1e16024c283	Mình cũng nghĩ vậy
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d9e67422-e391-4053-bc6a-54f80c793cec	\N	6fbfa0f0-9ddf-4ddb-95ff-ad53393934c5	Mình cũng nghĩ vậy
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7d537b13-7779-4176-b136-488f86a7d419	\N	16e3d542-4347-4c80-9071-5ea979a09556	Đồng cảm quá bạn ơi!
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2e90ca9e-ca80-499a-892c-119172400c3a	\N	16e3d542-4347-4c80-9071-5ea979a09556	Mình cũng nghĩ vậy
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a3ccbcba-c7d3-4a7a-aadd-0632d7a2b092	\N	3f734767-2437-4edb-adca-f957ac247374	Mình cũng nghĩ vậy
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	32be136a-c0c0-4ba1-976a-ec55f4c7b181	\N	31bcf1b7-1479-4d25-a6cb-9cb2cb0ba460	Đồng cảm quá bạn ơi!
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0efb043b-b971-4393-a1a8-6ff7b17fa7f0	\N	d37cc9ff-c891-4f3d-a7d0-0e9f394d6129	Đồng cảm quá bạn ơi!
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	dc028ce9-33c0-4dde-942d-7d1af9f71c8c	\N	38c4f435-0383-4aea-ae64-3b6fcd2ca8a4	Đồng cảm quá bạn ơi!
2025-12-09 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	481103a8-dad9-49e5-86c0-93f2619133be	\N	3e82a004-3c12-4e8b-b0d5-58b34c6e0da4	Đồng cảm quá bạn ơi!
2025-12-08 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	22914a66-e83a-4950-ac50-08bc65093d36	\N	5ff4d30a-548e-4476-bb8e-d8e73cf1f1b5	Đồng cảm quá bạn ơi!
2025-12-08 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1f804eea-e8d7-460e-a173-8501cfcfdfe4	\N	41a7668d-7a11-455b-88f3-9c9cb004615d	Mình cũng nghĩ vậy
2025-12-08 00:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4988268b-b1fd-4e96-bf51-9a792c54d64e	\N	8ecee724-6c1c-4c1a-bd0d-928c2bff8d0c	Mình cũng nghĩ vậy
2025-12-07 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	10292a4b-0a85-4d79-b4fb-f88edf6e1e84	\N	60aa584b-e2de-4997-87ff-3675276a53e7	Đồng cảm quá bạn ơi!
2025-12-07 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7755fd55-768b-4040-a010-1a243aaaae9b	\N	5402a278-6eb5-457d-97a8-b9eb6c48e1c0	Đồng cảm quá bạn ơi!
2025-12-07 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f9ddab75-0af3-462f-a615-073ca3749fbb	\N	436d5545-896f-4b2c-a457-b5d867c31aff	Đồng cảm quá bạn ơi!
2025-12-06 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	27a7f6bf-23cc-40b6-bc28-f5dd0a864495	\N	90bbc811-f855-41f0-98e3-79eacde99da0	Mình cũng nghĩ vậy
2025-12-06 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3ce51976-75af-421b-bcf9-0c1e7ae2ca05	\N	3c88a0e9-f5e8-4b54-85a5-c687f5b62304	Đồng cảm quá bạn ơi!
2025-12-06 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8b8b936c-d1cb-4d8e-b6c0-0c89ba2cc474	\N	e02c1530-d432-499e-bd64-ce6a28247516	Mình cũng nghĩ vậy
2025-12-06 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	174783fe-f941-465a-9bf3-6e0b375e8f31	\N	af3b4dc7-d5f5-412b-9b71-b1e8cfc1c9aa	Đồng cảm quá bạn ơi!
2025-12-06 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f58cbe66-26f1-483c-927a-d9aed4c3acd0	\N	83cade0f-bcf7-4225-b1a3-90d686fc2a3f	Đồng cảm quá bạn ơi!
2025-12-06 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5c2e25fe-c075-4184-8c39-6ef5119cf30c	\N	cd27b1ac-1595-4431-8136-7a6817babe28	Mình cũng nghĩ vậy
2025-12-06 23:52:18.652751+00	\N	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7edb24b5-d0ce-4890-b01a-af7fa94491e7	\N	cd2eca79-ad56-4e4c-8679-bfe92b7d91b1	Đồng cảm quá bạn ơi!
2025-12-25 14:41:54.341883+00	\N	2025-12-25 14:41:54.341883+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	d82dadc2-44d9-4b69-9ee0-bc1308ba9c4c	\N	3305ec0b-5aee-440e-af28-dc46c3c2fc27	hay
2025-12-25 15:14:25.075215+00	\N	2025-12-25 15:14:25.075215+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	fc7edd23-aeca-41bc-a70b-90bcedbe382b	\N	1ddd5e47-9259-4ee3-8e44-119af7d5ab46	hello
2025-12-25 16:08:35.71699+00	\N	2025-12-25 16:08:35.71699+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	69f4625e-d1c0-48b5-816f-9b2e59f4e1dc	\N	5c6abd03-491d-475f-b0e6-6cc41d054919	fun
\.


--
-- Data for Name: post_hashtags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_hashtags (created_at, deleted_at, updated_at, version, hashtag_id, id, post_id) FROM stdin;
\.


--
-- Data for Name: post_likes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_likes (created_at, deleted_at, updated_at, version, id, post_id, user_id) FROM stdin;
2025-12-15 06:44:14.099017+00	\N	2025-12-15 06:44:14.099017+00	0	c7d66d8f-4484-4a2a-9be7-80de2a75e0e5	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-18 08:11:59.283016+00	\N	2025-12-18 08:11:59.283016+00	0	661cfb89-2f25-4133-aed5-c543ae1e9fef	d8ea3c88-e11a-4e96-a194-ace0a16931cb	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-18 08:13:01.277052+00	\N	2025-12-18 08:13:01.277052+00	0	8cc6cebe-77f0-4524-95f2-5c0d95782ca8	523f2954-30c1-471e-89b0-7fd638788ac3	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 05:47:09.068427+00	\N	2025-12-19 05:47:09.068427+00	0	9e49e16a-8755-4d42-b276-36d370f53fd0	9b963a1c-c133-4df0-aadf-e6bea2c1e50d	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 05:47:10.871047+00	\N	2025-12-19 05:47:10.871047+00	0	27023b95-dfd0-4586-ae49-ae42f58b6ff3	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 05:47:12.230606+00	\N	2025-12-19 05:47:12.230606+00	0	de79d30a-61a4-4ff8-b9b8-680dff38e5f3	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 05:47:13.359698+00	\N	2025-12-19 05:47:13.359698+00	0	668d16fc-b582-47f9-99c0-8d2a84ccd25a	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 05:47:16.608189+00	\N	2025-12-19 05:47:16.608189+00	0	28e95802-457a-4295-bea6-27c6041ec2ec	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-19 05:47:17.625126+00	\N	2025-12-19 05:47:17.625126+00	0	b903b1e3-aa3f-4ed2-b371-d9409bd869f9	d8ea3c88-e11a-4e96-a194-ace0a16931cb	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-19 05:47:19.084087+00	\N	2025-12-19 05:47:19.084087+00	0	3c582085-fa4a-48ab-9902-66628f4971a8	523f2954-30c1-471e-89b0-7fd638788ac3	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-19 05:47:21.31371+00	\N	2025-12-19 05:47:21.31371+00	0	b6ec3c2f-f2b0-4a85-b023-5a5055e9f825	8842eecd-91df-4fc0-8b85-e0f1e032d145	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-19 05:48:28.733369+00	\N	2025-12-19 05:48:28.733369+00	0	de05c2ce-fc5c-4ad6-aa7c-14d3ffcbe15f	488d9dea-8553-4e49-bf2b-106c5e143613	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-07 06:49:23.030502+00	\N	\N	0	1327c85e-32e6-4978-a23f-4a24afbe9572	018e4a26-93c8-4ac7-99b6-ffef04f067ce	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-16 06:49:23.030502+00	\N	\N	0	6fa7f972-4683-425b-bddb-156a834a97b5	018e4a26-93c8-4ac7-99b6-ffef04f067ce	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-26 06:49:23.030502+00	\N	\N	0	681da65b-ca00-4847-9221-cc58d6f7112e	1c53e1ce-c1dd-4d64-afba-b76249b0c44a	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-25 06:49:23.030502+00	\N	\N	0	110bc089-bbc8-4dc9-9a2b-9e24976a5d97	1c53e1ce-c1dd-4d64-afba-b76249b0c44a	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-08 06:49:23.030502+00	\N	\N	0	edb670ea-a67e-46d2-b6e7-af359e4c1ec1	28a23ecf-7e87-4517-817f-71005f2181bc	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-07 06:49:23.030502+00	\N	\N	0	58557ee8-0d70-4a8d-af53-64145f586195	329f165e-054a-4190-9b74-d0cb07700e11	3f6ef7ed-8e2f-409a-877e-056971006476
2025-11-30 06:49:23.030502+00	\N	\N	0	53188e23-1f7c-4669-8099-b5e355f51362	3a488bda-31da-4c0e-a48d-9df821f81f4c	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-18 06:49:23.030502+00	\N	\N	0	4b28d8a0-8fa7-40be-8914-59db3dd4b05e	3e82a004-3c12-4e8b-b0d5-58b34c6e0da4	3f6ef7ed-8e2f-409a-877e-056971006476
2025-11-30 06:49:23.030502+00	\N	\N	0	b968bf93-a211-4bef-bbf8-6001361494fe	5ad7114b-d2c8-4ea8-986f-b1ad961f4bf2	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-16 06:49:23.030502+00	\N	\N	0	da3206fd-e809-46de-96a7-074f8a637f5d	69eb4c1b-29b0-45ec-9737-38814966ce06	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-24 06:49:23.030502+00	\N	\N	0	7b5830e1-577b-4b96-bbc5-72823c7b0636	a0576d7a-2356-41d3-8040-2418a8518e49	3f6ef7ed-8e2f-409a-877e-056971006476
2025-11-25 06:49:23.030502+00	\N	\N	0	fbc04cf5-e03a-4792-8c6c-f15a7262db97	a694c11b-ad03-4a7a-bb82-7ac1f30addb0	3f6ef7ed-8e2f-409a-877e-056971006476
2025-11-25 06:49:23.030502+00	\N	\N	0	02dd3a72-c935-4370-96d9-00a54150732c	a7bf8fc4-211b-4c93-91a5-2a927127e019	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-18 06:49:23.030502+00	\N	\N	0	e7666997-c0a1-46ea-ac55-3c13a5b81112	a7eda267-2926-4574-b931-9087cc71040d	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-09 06:49:23.030502+00	\N	\N	0	d2920a91-5845-4f53-9ac1-698dafbe82fa	b4a3a72d-9a2e-4cc7-9805-e0d7b8460086	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-17 06:49:23.030502+00	\N	\N	0	b93bf0d1-d5c5-486c-87eb-c9ac3187be13	baf47fd0-3863-46ba-8875-9963aab9bbcf	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-21 06:49:23.030502+00	\N	\N	0	a3e4e9a0-18b9-4edb-9891-ff58597d5459	c30d8234-dd2d-45bd-83ad-0b18fd840343	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-10 06:49:23.030502+00	\N	\N	0	802282f7-763d-49da-ac6a-a4db874ffc24	e900c3eb-5d9e-4b0c-8869-6bc21f08c517	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-10 06:49:23.030502+00	\N	\N	0	6b6706d7-0a58-4fde-a8b4-60775c610237	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-26 06:49:23.030502+00	\N	\N	0	cb8749e9-ad67-44c4-ad1f-30a3f76f11ae	f79a722d-a6db-48cb-836b-091ec96026fb	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-10 06:49:23.030502+00	\N	\N	0	deecb8a5-ee3f-4130-a21a-1ff28980aa0d	f91cf04e-f6ec-4184-b2b4-a265ec5cb667	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-01 06:49:23.030502+00	\N	\N	0	4debac6e-a592-488e-bc96-489e18288446	f91cf04e-f6ec-4184-b2b4-a265ec5cb667	3f6ef7ed-8e2f-409a-877e-056971006476
2025-11-09 06:50:57.936814+00	\N	\N	0	0e4e21bd-2b68-4e3e-9968-632a92a5ba1a	0ccfeb06-e0d7-4161-b5cb-b497b4b28f0f	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-17 06:50:57.936814+00	\N	\N	0	aa4e780b-4c5d-4dcd-8651-1fcddd15032d	213387bc-4d29-4caf-a532-93b850d29b34	3f6ef7ed-8e2f-409a-877e-056971006476
2025-11-21 06:50:57.936814+00	\N	\N	0	f9a30ac8-7b07-4e06-a2d4-42897f50c159	256dfa3b-6b08-4076-b027-717b4748f1f3	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-05 06:50:57.936814+00	\N	\N	0	68c32765-6f84-4d4e-be91-7b6b6dda9903	311ce3af-5f0a-4011-9e7f-dd2ad8f01fa7	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-09 06:50:57.936814+00	\N	\N	0	d60cd070-615f-43cd-b9c8-a002d72b27d4	31bcf1b7-1479-4d25-a6cb-9cb2cb0ba460	3f6ef7ed-8e2f-409a-877e-056971006476
2025-11-09 06:50:57.936814+00	\N	\N	0	6f221b2f-f62b-4ccd-b90c-4ad0dc2e54d6	329f165e-054a-4190-9b74-d0cb07700e11	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-09 06:50:57.936814+00	\N	\N	0	617de09d-06a1-45f4-924e-e5abddcbe2f2	3b2a05d2-c06d-4580-97d9-01b3b340af85	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-21 06:50:57.936814+00	\N	\N	0	6af4c0fc-6bb9-4a1d-b90c-f026cfa50375	3f734767-2437-4edb-adca-f957ac247374	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-18 06:50:57.936814+00	\N	\N	0	cc719694-032e-4fcd-b18a-fe94f0987445	3f734767-2437-4edb-adca-f957ac247374	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-27 06:50:57.936814+00	\N	\N	0	9869caaf-4c53-48d1-a43d-1158fe9cf000	578c949a-4092-4f8f-8a23-953ef093f6f4	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-16 06:50:57.936814+00	\N	\N	0	255fb6a9-041f-4813-816e-090b4ac2a38e	5ad7114b-d2c8-4ea8-986f-b1ad961f4bf2	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-08 06:50:57.936814+00	\N	\N	0	935cda27-9851-4e44-86f8-00e49c81835b	60808489-351b-4443-a95d-1fee8f8d9ba3	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-08 06:50:57.936814+00	\N	\N	0	9eb2192b-de91-49d0-8c96-73d5343f5f94	60ef2f7d-e772-42d0-af2d-62221c62400b	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-19 06:50:57.936814+00	\N	\N	0	e1290544-1680-4099-9545-c6c18bfdd747	729c5095-4965-4b06-8a3e-74f892f58d64	3f6ef7ed-8e2f-409a-877e-056971006476
2025-11-06 06:50:57.936814+00	\N	\N	0	81c897ad-095d-484d-a928-46accca7704f	73f505b7-771c-4543-8aa8-48ecc6c646f3	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-19 06:50:57.936814+00	\N	\N	0	a3390a13-8d9f-41cf-9899-62bbdfcab90b	73f505b7-771c-4543-8aa8-48ecc6c646f3	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-05 06:50:57.936814+00	\N	\N	0	000a3dcc-bf97-4e2c-94fb-53f8fc5bcbf5	73f505b7-771c-4543-8aa8-48ecc6c646f3	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-13 06:50:57.936814+00	\N	\N	0	fd51fab0-a5a5-44c3-8367-68e122665d1a	92db18d0-2fa3-44c1-a5e7-b7a0b1a15cfb	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-18 06:50:57.936814+00	\N	\N	0	990f7bb6-ae74-49fa-936a-be51a72e6e23	97921494-ee29-4269-8eb2-6fc8f5d487b5	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-05 06:50:57.936814+00	\N	\N	0	41844515-23fe-4062-8c9e-7b6357129232	9db9f670-0a6e-4fa0-9a6d-2737fb28303f	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-06 06:50:57.936814+00	\N	\N	0	b49c9510-a3da-4b90-9c6d-d025d004c20d	ad3b3dc5-a715-47ed-b3e6-7c7691c90292	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-13 06:50:57.936814+00	\N	\N	0	6f0b7cd2-83d4-4cfa-b4a0-70d8ff40de5d	b6b6ffc7-5608-48f7-a91b-7624854d4c18	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-09 06:50:57.936814+00	\N	\N	0	da5f7cac-21aa-49f1-a835-a0994118c40d	b93534d9-4a9f-4e31-a52e-6f1c98012d8c	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-04 06:50:57.936814+00	\N	\N	0	f53b73a5-e3aa-4486-8703-350a40789bd1	bddd6d02-c07e-47cc-bcb3-dfe90830fbee	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-02 06:50:57.936814+00	\N	\N	0	a67e81cf-7e9f-48be-bc5a-3f56042d811c	c34ec469-f699-4cbc-9241-8e0992688aad	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-06 06:50:57.936814+00	\N	\N	0	d1ca6d4a-3300-4a05-850f-d388d624c9a6	e3771fcb-31d8-41dd-8cf7-a065c5ee4430	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-06 06:50:57.936814+00	\N	\N	0	f844732b-7f8d-4cb7-9296-560e267256e2	e7752d99-8f2a-4da4-ad91-d71fd545bc46	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-17 06:50:57.936814+00	\N	\N	0	4f1008f5-b5bf-4a93-9a0a-f98d206a5825	edfd111b-0ce6-47b2-acf4-13272b45a550	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-30 06:52:18.652751+00	\N	\N	0	9db2030c-89f5-4903-b4b2-1ebe5a0eef9a	0ccfeb06-e0d7-4161-b5cb-b497b4b28f0f	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-09 06:52:18.652751+00	\N	\N	0	4298ce2c-15c1-4bdb-b950-95d133fc38a2	107d55ce-e014-4c22-b9a2-abbfe865fcf9	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-22 06:52:18.652751+00	\N	\N	0	d23614d5-8949-49de-a11d-94bcb4da02e4	23bd823f-8c3f-4607-8605-59ff67874886	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-18 06:52:18.652751+00	\N	\N	0	c785d770-52ca-4fa6-a7d0-5b5a2c2ecc18	23cce978-fc18-4d3c-92a4-d82717f7c9ac	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-20 06:52:18.652751+00	\N	\N	0	d1a6da68-3015-45e9-8504-a85b223baf4d	28acbe82-8894-48cf-b1f2-be232ae4f20a	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-01 06:52:18.652751+00	\N	\N	0	81ee98b9-a600-472e-8f10-42982b536129	2b4d404f-af98-4b6e-97e2-487f9b84047d	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-08 06:52:18.652751+00	\N	\N	0	184e9ab7-8b6d-4781-abe4-b530bcf37c4b	31bcf1b7-1479-4d25-a6cb-9cb2cb0ba460	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-11 06:52:18.652751+00	\N	\N	0	f24a78b2-1d3a-4da3-a87e-d467c6174537	3b67bced-d152-49d5-a170-189200f33385	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-10 06:52:18.652751+00	\N	\N	0	527a47cb-b845-4e6f-b21a-3fc5c3d0462c	66662d1b-794a-4641-8886-3e91bb3158aa	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-20 06:52:18.652751+00	\N	\N	0	c8e27aad-3876-45fa-a7f4-6eb025484a55	74c0890a-7d32-4666-9001-8616fe63af61	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-10 06:52:18.652751+00	\N	\N	0	161b3249-9005-4fe4-ba8c-7c6cdaf92fa5	8c0f6e42-050d-4a87-82b6-4d407f9be2da	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-11 06:52:18.652751+00	\N	\N	0	476703a1-de2b-4c90-b9bc-498c5ff1ca88	8dbc4147-7063-400c-99a0-97aadef49864	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-03 06:52:18.652751+00	\N	\N	0	53b7f4ca-3c3f-43eb-b39b-7547ccee2d35	8ecee724-6c1c-4c1a-bd0d-928c2bff8d0c	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-21 06:52:18.652751+00	\N	\N	0	13ff3873-8caa-483c-a2e4-98baaad1c830	90d59886-4e90-4632-827b-069337f887d6	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-09 06:52:18.652751+00	\N	\N	0	c6bcee7c-be33-4cb1-b26d-a68e1ef3440b	9d5e8e94-fe0a-4c88-9791-e3837fda4c73	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-15 06:52:18.652751+00	\N	\N	0	743f2cbb-3d47-4166-a937-9ca8288fe6cd	a9b54525-7574-43c3-84de-60dbf19aa9ac	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-11-22 06:52:18.652751+00	\N	\N	0	a74f5c36-79b8-4d01-b0cc-cabafd50fd57	a9b54525-7574-43c3-84de-60dbf19aa9ac	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-17 06:52:18.652751+00	\N	\N	0	a67f3e96-7235-443a-a31d-4704b5e7c408	ab97709f-d2e6-4967-ab09-3e24512c52a5	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-09 06:52:18.652751+00	\N	\N	0	da37b2b5-df27-41c3-86a0-a09c8c31d3a7	b6db8f9b-db77-4c20-92cd-62b41bf9c944	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-29 06:52:18.652751+00	\N	\N	0	69b86e0a-581f-4246-99f4-65cfeb6681f2	bf252fc0-bead-41f2-80ae-4e2ac5d24545	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-24 06:52:18.652751+00	\N	\N	0	a75cc3f9-23c1-4041-bc79-503539280fb9	ca2771b6-e743-4fb2-9585-49815ea1f159	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-08 06:52:18.652751+00	\N	\N	0	ce3a0854-26f9-41d1-be58-706f09f14725	caf7a7bc-0d09-4668-b59b-7efb63a7ea00	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-14 06:52:18.652751+00	\N	\N	0	73b1cec8-8093-4016-8d23-3445fec4a285	cc59412e-089a-4bc5-a644-e50c0e3a76c6	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-19 06:52:18.652751+00	\N	\N	0	1c18efd1-0a94-45b1-bab5-437bc5892ca1	ccc4a84e-e519-4526-aa4e-f41f4482c019	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-19 06:52:18.652751+00	\N	\N	0	6aa26790-1bdb-4bdb-9920-0892df4f5e8b	cf0e1d28-048d-4b8c-b8ff-b5992a95b087	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-11-24 06:52:18.652751+00	\N	\N	0	257637bd-5bc5-4db6-9733-b11340d75330	d2dc024f-8dd7-4305-b34d-f022a92e8eea	c986c222-633d-4b87-b1c6-af938fb558e7
2025-11-13 06:52:18.652751+00	\N	\N	0	a48c08d2-ffc7-48c3-8fb0-ac9e4a925cff	eae6dafb-6483-4269-95b9-7e404a7ef8b6	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-11 06:52:18.652751+00	\N	\N	0	74b02626-76e8-47ea-b71f-1759fe75849c	f9a96ec1-29a2-4d72-b98a-139470db22a3	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-15 06:52:18.652751+00	\N	\N	0	9b929c6d-0b3b-483c-97fd-5c76dcff285d	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-19 07:02:31.791127+00	\N	2025-12-19 07:02:31.791127+00	0	9b69939b-07ee-4637-a356-fb483fea60f1	5c4b1abe-29ca-421e-a95f-6def93804ee5	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-19 07:02:35.480935+00	\N	2025-12-19 07:02:35.480935+00	0	ae409cfe-eaf3-44a3-8ba6-1121a43b944b	b2023a96-a193-42ac-9de2-fe4be55d04e3	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-19 07:25:27.407835+00	\N	2025-12-19 07:25:27.407835+00	0	81aff3a1-62a4-4b91-8949-a22d1c893378	b2023a96-a193-42ac-9de2-fe4be55d04e3	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 07:25:28.131788+00	\N	2025-12-19 07:25:28.131788+00	0	1ae56386-6596-4712-84da-439fd6521df3	5c4b1abe-29ca-421e-a95f-6def93804ee5	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 07:25:29.543281+00	\N	2025-12-19 07:25:29.543281+00	0	1c78bc35-8229-4e9f-9a6c-134139bf5c10	d0ee6ccb-46f1-44ce-8ae0-76934935ba51	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 07:25:31.510245+00	\N	2025-12-19 07:25:31.510245+00	0	c81f8b43-a7d8-4de9-b2cf-9bb306b77dc1	2140c3e5-87fb-4af8-b550-4947527f85c4	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 07:26:25.233834+00	\N	2025-12-19 07:26:25.233834+00	0	237b91c5-43c3-476a-a3da-905bfc7d962d	c92262a6-94dc-4a2a-9236-444a0b09020f	05479f65-5810-4a18-8454-3f9eb850157e
2025-12-19 07:26:26.608411+00	\N	2025-12-19 07:26:26.608411+00	0	ab4cce84-70b1-4815-a5ce-90d7c186a652	b6940166-e3ce-4374-8aaa-255442a58979	05479f65-5810-4a18-8454-3f9eb850157e
2025-12-19 07:26:27.239979+00	\N	2025-12-19 07:26:27.239979+00	0	05adb541-2e01-463c-bf14-48ee33006aee	6fbfa0f0-9ddf-4ddb-95ff-ad53393934c5	05479f65-5810-4a18-8454-3f9eb850157e
2025-12-19 07:26:28.857342+00	\N	2025-12-19 07:26:28.857342+00	0	04bbe5e1-8c49-4e40-baf3-6b488399590d	a694c093-5d90-463e-ab71-79d8b6f79061	05479f65-5810-4a18-8454-3f9eb850157e
2025-12-19 07:26:30.15114+00	\N	2025-12-19 07:26:30.15114+00	0	5b5fb854-f678-4eb3-95d7-ccd7fa1c15b7	54db354f-8588-49b2-90aa-fbcbb6dd542c	05479f65-5810-4a18-8454-3f9eb850157e
2025-12-19 07:49:48.948481+00	\N	2025-12-19 07:49:48.948481+00	0	fc83c7e9-ef2a-45f0-a7bc-a712f428c5ca	1ddd5e47-9259-4ee3-8e44-119af7d5ab46	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 07:49:51.940952+00	\N	2025-12-19 07:49:51.940952+00	0	3452cbcc-7707-48b9-9614-48c3f50ef151	616a3d42-4670-4ed9-9b3b-88fde8f1fe21	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 07:49:54.619412+00	\N	2025-12-19 07:49:54.619412+00	0	b2dae4e4-cef7-477b-b4b6-cac14df30552	b6940166-e3ce-4374-8aaa-255442a58979	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-19 07:50:18.540182+00	\N	2025-12-19 07:50:18.540182+00	0	f340eab8-777d-49af-9004-6a26c9365af6	b2023a96-a193-42ac-9de2-fe4be55d04e3	05479f65-5810-4a18-8454-3f9eb850157e
2025-12-19 07:50:58.624229+00	\N	2025-12-19 07:50:58.624229+00	0	639b850d-28c6-4929-a444-1f48310d6b78	b20e0159-de08-4174-8a71-83ebb743c360	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-19 07:50:59.596957+00	\N	2025-12-19 07:50:59.596957+00	0	33ba7aac-feac-4414-b4a3-035c7d83c250	06d35722-3bfd-409e-84ef-116aac88c4c3	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-19 07:51:03.680947+00	\N	2025-12-19 07:51:03.680947+00	0	cee5e17e-e3fb-4daf-a784-9033609b370f	c92262a6-94dc-4a2a-9236-444a0b09020f	3f6ef7ed-8e2f-409a-877e-056971006476
2025-12-20 06:31:31.513192+00	\N	2025-12-20 06:31:31.513192+00	0	71a0b127-8484-4481-add4-58a4c438c39a	3305ec0b-5aee-440e-af28-dc46c3c2fc27	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-20 06:31:40.275421+00	\N	2025-12-20 06:31:40.275421+00	0	a690a14c-5995-4b25-b989-1075f424e5d6	c92262a6-94dc-4a2a-9236-444a0b09020f	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-20 07:06:43.028762+00	\N	2025-12-20 07:06:43.028762+00	0	f737a180-cece-442c-a5a3-4a683630090d	3305ec0b-5aee-440e-af28-dc46c3c2fc27	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-20 09:11:52.530524+00	\N	2025-12-20 09:11:52.530524+00	0	306439ba-99e9-4380-92cb-1b7ce1cdc2af	051ab58e-69ba-4143-b327-542caf8b0265	05479f65-5810-4a18-8454-3f9eb850157e
2025-12-20 14:57:12.091731+00	\N	2025-12-20 14:57:12.091731+00	0	a65ef875-91a3-494f-980e-a6b1416f8362	b20e0159-de08-4174-8a71-83ebb743c360	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-22 10:14:11.701005+00	\N	2025-12-22 10:14:11.701005+00	0	d32d777e-d557-4baa-8688-3ca12759e181	23a749de-d376-438d-8bfa-7cd162db2cd0	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-22 10:28:55.989158+00	\N	2025-12-22 10:28:55.989158+00	0	a581f894-6b5b-4d6f-bb54-dd7612d319b1	d8ea3c88-e11a-4e96-a194-ace0a16931cb	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-22 10:30:58.727932+00	\N	2025-12-22 10:30:58.727932+00	0	ac0f61f4-644c-44c8-8dce-5815faccaf07	616a3d42-4670-4ed9-9b3b-88fde8f1fe21	2fbff3dd-1da7-472e-9273-c495a1c0b870
2025-12-22 17:07:36.339143+00	\N	2025-12-22 17:07:36.339143+00	0	126a8b97-ec84-432a-9be5-333c63a78798	051ab58e-69ba-4143-b327-542caf8b0265	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-22 17:07:38.35858+00	\N	2025-12-22 17:07:38.35858+00	0	d07894a2-012c-4d72-a158-006275e76fce	23a749de-d376-438d-8bfa-7cd162db2cd0	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-25 08:39:46.263959+00	\N	2025-12-25 08:39:46.263959+00	0	ba16ee3e-6023-4815-9c4c-890634d18b91	616a3d42-4670-4ed9-9b3b-88fde8f1fe21	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-25 14:00:52.770493+00	\N	2025-12-25 14:00:52.770493+00	0	0ce35af2-c72e-4a4d-b8dd-42df742dd29d	3305ec0b-5aee-440e-af28-dc46c3c2fc27	c986c222-633d-4b87-b1c6-af938fb558e7
2025-12-25 15:25:25.307527+00	\N	2025-12-25 15:25:25.307527+00	0	4a9380e3-c671-4e45-83e4-510a062c59e9	d392e7ba-7cce-4371-bf8a-81200ae3d589	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-25 15:33:21.582259+00	\N	2025-12-25 15:33:21.582259+00	0	303980a6-7a65-46ce-848f-fa647d5a51d3	814e6122-b428-4874-beaf-7f3d3a18a362	1abd3aa6-3068-469f-9c45-a38ad7076fdf
2025-12-25 16:09:19.695331+00	\N	2025-12-25 16:09:19.695331+00	0	bc87fbfc-a5b0-4ee3-b8f3-25ed2212e57a	b5aba5ba-c977-4100-868f-c5bc179a9d3a	1abd3aa6-3068-469f-9c45-a38ad7076fdf
\.


--
-- Data for Name: post_media; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_media (created_at, deleted_at, updated_at, version, id, post_id, description, media_type, object_key, order_index) FROM stdin;
2025-12-13 09:06:13.197391+00	\N	2025-12-13 09:06:13.197391+00	0	62d1329e-ad35-48fa-8fa6-9f53febc41a3	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	\N	IMAGE	b4ec822e-185d-44cb-9d06-0aab1bc0a236-Annotation 2024-10-10 221253.png	\N
2025-12-15 06:54:27.470722+00	\N	2025-12-15 06:54:27.470722+00	0	b6b839fd-211b-4b17-bb72-4fe64fca1ea4	8842eecd-91df-4fc0-8b85-e0f1e032d145	\N	VIDEO	20a2ffa2-d17f-4fb8-b470-722516e9a6e0-Facebook_1_394839319_320794597230345_7050658430727114001_n.mp4	\N
2025-12-15 06:55:22.981654+00	\N	2025-12-15 06:55:22.981654+00	0	6844ec20-4347-44d3-a5a9-5ac4edbaa857	9b963a1c-c133-4df0-aadf-e6bea2c1e50d	\N	VIDEO	e7406541-179e-45e0-9d5c-83b5b6a18b63-Memes_from_Discord720P_HD_1.mp4	\N
2025-12-17 05:55:06.768114+00	\N	2025-12-17 05:55:06.768114+00	0	a52a4f1f-a68d-45c2-9cf5-e73b25c509e9	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	\N	IMAGE	aa44c532-aa0a-432b-bebc-4504f8feb5fa-407914258_3015707855227340_2182413327885734868_n.jpg	\N
2025-12-17 06:48:33.620485+00	\N	2025-12-17 06:48:33.620485+00	0	745a61c2-2479-4097-a50c-62a8a43fb64c	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	\N	IMAGE	0bc63b75-49ed-4511-ba35-fbd7c9d79f0b-420198238_122125069352055338_176253627461992973_n.jpg	0
2025-12-17 06:48:33.730936+00	\N	2025-12-17 06:48:33.730936+00	0	531ec041-2dc7-44a0-ab4c-12457e3b0c07	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	\N	IMAGE	e5afb6ba-af97-4781-a4f2-73d1a6bdeda6-437904095_960984508731902_1517351171542788016_n.jpg	1
2025-12-17 06:48:33.787143+00	\N	2025-12-17 06:48:33.787143+00	0	17469f56-e3f8-45f3-b73f-9e17f70c7b9e	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e	\N	IMAGE	d35be653-f677-434a-bb8c-d85cc4db79b0-aodai.jpg	2
2025-12-18 07:58:15.705001+00	\N	2025-12-18 07:58:15.705001+00	0	28c5394c-e56a-44ed-896b-e2377edd3b77	523f2954-30c1-471e-89b0-7fd638788ac3	\N	IMAGE	63bf31ba-fe97-413c-b643-4473fa46dc32-409777106_372961378732019_6999831694106274015_n.jpg	0
2025-12-19 05:47:53.381552+00	\N	2025-12-19 05:47:53.381552+00	0	e1c5317d-784b-407f-ba31-fcce59d9aa50	488d9dea-8553-4e49-bf2b-106c5e143613	\N	IMAGE	8f061aa3-8c96-4247-9e0e-256fc0f61385-420198238_122125069352055338_176253627461992973_n.jpg	0
2025-12-19 07:48:20.262307+00	\N	2025-12-19 07:48:20.262307+00	0	649eaa11-58b1-45cf-876d-209d9f1def6a	1ddd5e47-9259-4ee3-8e44-119af7d5ab46	\N	IMAGE	380d78ba-d57b-4cb3-992b-9238592376db-407914258_3015707855227340_2182413327885734868_n.jpg	0
2025-12-19 07:48:31.931815+00	\N	2025-12-19 07:48:31.931815+00	0	e7552168-1b50-4d62-8a46-08bafda0abea	616a3d42-4670-4ed9-9b3b-88fde8f1fe21	\N	IMAGE	bb7d41f9-3f66-4b35-b1ac-cdbe1ce2dd8b-405353174_336543555654280_280519606896010122_n.jpg	0
2025-12-19 07:48:46.065757+00	\N	2025-12-19 07:48:46.065757+00	0	8537f548-bbc8-4d90-85ce-004374d42673	3305ec0b-5aee-440e-af28-dc46c3c2fc27	\N	VIDEO	84688813-3d37-4cfc-a9d2-d04a69d24e27-4719158819425378206.mp4	0
2025-12-22 07:59:58.449206+00	\N	2025-12-22 07:59:58.449206+00	0	983d6dbd-026b-4f56-93a2-b59dfca141df	23a749de-d376-438d-8bfa-7cd162db2cd0	\N	IMAGE	f4baf02d-c1bc-46d9-8a65-1b83bd508826-420198238_122125069352055338_176253627461992973_n.jpg	0
2025-12-25 14:37:23.62881+00	\N	2025-12-25 14:37:23.62881+00	0	1a6b64e8-c776-4d66-bbc5-e14cd878b083	814e6122-b428-4874-beaf-7f3d3a18a362	\N	IMAGE	c8e7ec12-2652-43e8-b75c-195dc3c0f662-1000039452.jpg	0
2025-12-25 15:12:26.684615+00	\N	2025-12-25 15:12:26.684615+00	0	d5f97097-5b82-4292-bf1a-e1e71e084fb1	4d77b6ab-3ceb-4097-be66-de926e6fbc9b	\N	VIDEO	95dbc1be-a60d-4f81-813e-74ed24964c52-1000039059.mp4	0
2025-12-25 15:20:18.411638+00	\N	2025-12-25 15:20:18.411638+00	0	b3bc543d-b456-4c05-a6e8-794c026f7ff5	d392e7ba-7cce-4371-bf8a-81200ae3d589	\N	VIDEO	6f2f0c3f-6433-4090-901a-2f1e3ff58b8a-1000039059.mp4	0
2025-12-25 15:21:31.608654+00	\N	2025-12-25 15:21:31.608654+00	0	405bef32-8af7-4d32-8c9b-e853c84ec97e	beacfc19-af44-4d74-ba21-fda81d72293a	\N	VIDEO	cedf901c-13c7-4814-b80e-cc086fedef79-1000039059.mp4	0
2025-12-25 16:06:41.728563+00	\N	2025-12-25 16:06:41.728563+00	0	634ba8db-b485-4393-aaf8-3eac35cd1f41	b5aba5ba-c977-4100-868f-c5bc179a9d3a	\N	VIDEO	622e2ad5-d725-4c97-8904-612b9b1c7f72-1000039455.mp4	0
2025-12-25 16:06:41.779167+00	\N	2025-12-25 16:06:41.779167+00	0	fa325227-6c31-4918-911a-fbb03f02de7a	b5aba5ba-c977-4100-868f-c5bc179a9d3a	\N	IMAGE	bfa0a5de-0db9-4fd1-b020-22f02be14914-1000039452.jpg	1
2025-12-25 16:06:41.85178+00	\N	2025-12-25 16:06:41.85178+00	0	112dc370-8b94-45e7-b7ad-6a2b7bd7548c	b5aba5ba-c977-4100-868f-c5bc179a9d3a	\N	IMAGE	6ff827ca-e308-494f-89d7-6ce0f00a0c9a-1000039451.jpg	2
2025-12-25 16:08:29.507742+00	\N	2025-12-25 16:08:29.507742+00	0	2d28a986-0def-4c60-ac8b-ab04ddc120ea	5c6abd03-491d-475f-b0e6-6cc41d054919	\N	IMAGE	92af2aa8-4116-43b3-9071-55e67a5bbf68-1000039459.jpg	0
2025-12-25 16:08:29.574556+00	\N	2025-12-25 16:08:29.574556+00	0	1cbe7945-4dfb-4c41-bc69-50e681d50ef9	5c6abd03-491d-475f-b0e6-6cc41d054919	\N	IMAGE	8f754a81-db0c-4733-83f7-cbe7d187ded9-1000039458.jpg	1
2025-12-25 16:08:29.71181+00	\N	2025-12-25 16:08:29.71181+00	0	ed16957d-1f03-4420-b5b7-811dd7cc4e90	5c6abd03-491d-475f-b0e6-6cc41d054919	\N	IMAGE	43ad2104-0c47-4191-8f09-c6c2947c96ac-1000039460.jpg	2
\.


--
-- Data for Name: post_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_reports (id, created_at, deleted_at, updated_at, version, description, moderation_comment, reason, status, post_id, reporter_id) FROM stdin;
7ce5b26b-bf23-467c-b628-cdc46d1575cc	2025-12-25 16:22:12.301768+00	\N	2025-12-25 16:22:12.301768+00	0	\N	\N	SPAM	PENDING	051ab58e-69ba-4143-b327-542caf8b0265	1abd3aa6-3068-469f-9c45-a38ad7076fdf
d480121c-c208-4098-b813-c2b224f9636b	2025-12-25 17:17:28.431648+00	\N	2025-12-25 17:17:28.431648+00	0	\N	\N	HATE_SPEECH	PENDING	5c6abd03-491d-475f-b0e6-6cc41d054919	2fbff3dd-1da7-472e-9273-c495a1c0b870
a6f2a3ca-a7b6-45d6-832c-0c63dba01c24	2025-12-25 17:27:12.275773+00	\N	2025-12-25 17:27:12.275773+00	0	\N	\N	SPAM	PENDING	1ddd5e47-9259-4ee3-8e44-119af7d5ab46	2fbff3dd-1da7-472e-9273-c495a1c0b870
01097d58-87bc-421a-963a-734c2e60fb87	2025-12-25 17:27:39.321899+00	\N	2025-12-25 17:27:39.321899+00	0	\N	\N	SPAM	PENDING	814e6122-b428-4874-beaf-7f3d3a18a362	2fbff3dd-1da7-472e-9273-c495a1c0b870
ae42ceba-2309-4c95-a154-69fc8fbd2295	2025-12-25 17:27:55.772642+00	\N	2025-12-25 17:27:55.772642+00	0	\N	\N	INAPPROPRIATE	PENDING	b20e0159-de08-4174-8a71-83ebb743c360	2fbff3dd-1da7-472e-9273-c495a1c0b870
c26954dd-4fc7-48c0-a992-29ee5ab79456	2025-12-25 17:39:21.370188+00	\N	2025-12-25 17:39:21.370188+00	0	\N	\N	SPAM	PENDING	23a749de-d376-438d-8bfa-7cd162db2cd0	2fbff3dd-1da7-472e-9273-c495a1c0b870
9607ce12-bbaa-4164-833e-8fea239a48c1	2025-12-25 17:54:07.47981+00	\N	2025-12-25 17:54:07.47981+00	0	\N	\N	SCAM	PENDING	8842eecd-91df-4fc0-8b85-e0f1e032d145	2fbff3dd-1da7-472e-9273-c495a1c0b870
4e07596f-082b-4ee0-96ad-a6eef4798c16	2025-12-25 18:01:44.930553+00	\N	2025-12-25 18:01:44.930553+00	0	\N	\N	HATE_SPEECH	PENDING	af1518c6-25eb-4d4d-be15-047336e3b091	2fbff3dd-1da7-472e-9273-c495a1c0b870
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (comment_count, created_at, deleted_at, like_count, updated_at, version, author_id, id, content, visibility, location, place_code, place_name, status) FROM stdin;
1	2025-11-10 11:52:18.652751+00	\N	2	2025-12-22 17:07:36.403931+00	2	2fbff3dd-1da7-472e-9273-c495a1c0b870	051ab58e-69ba-4143-b327-542caf8b0265	Thứ 2 buồn quá mọi người ơi 😢	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-22 07:59:57.964731+00	\N	2	2025-12-22 17:07:38.359864+00	2	1abd3aa6-3068-469f-9c45-a38ad7076fdf	23a749de-d376-438d-8bfa-7cd162db2cd0	omae ha shine	PUBLIC	0101000020E610000098EEBFDFF90F5B407BB07BE184F42F40	\N	\N	ACTIVE
0	2025-12-19 07:48:31.845926+00	\N	3	2025-12-25 08:39:46.287447+00	3	05479f65-5810-4a18-8454-3f9eb850157e	616a3d42-4670-4ed9-9b3b-88fde8f1fe21	funfun	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-19 07:48:20.142009+00	\N	1	2025-12-25 15:14:25.077089+00	2	05479f65-5810-4a18-8454-3f9eb850157e	1ddd5e47-9259-4ee3-8e44-119af7d5ab46	single	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-25 14:37:23.333618+00	\N	1	2025-12-25 15:33:21.610321+00	1	1abd3aa6-3068-469f-9c45-a38ad7076fdf	814e6122-b428-4874-beaf-7f3d3a18a362	fundun	PUBLIC	\N	DA_NANG	Đà Nẵng	ACTIVE
2	2025-12-18 07:23:51.499739+00	\N	3	2025-12-22 10:28:56.089945+00	3	c986c222-633d-4b87-b1c6-af938fb558e7	d8ea3c88-e11a-4e96-a194-ace0a16931cb	need some one to talk	PUBLIC	\N	DA_NANG	Đà Nẵng	ACTIVE
1	2025-12-19 07:48:45.885227+00	\N	3	2025-12-25 14:41:54.346324+00	4	05479f65-5810-4a18-8454-3f9eb850157e	3305ec0b-5aee-440e-af28-dc46c3c2fc27	sad	PUBLIC	\N	DA_NANG	Đà Nẵng	ACTIVE
0	2025-12-25 15:12:26.442999+00	\N	0	2025-12-25 15:12:26.442999+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	4d77b6ab-3ceb-4097-be66-de926e6fbc9b	hdpe thì ngon luôn	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-12 12:50:57.936814+00	\N	2	2025-12-20 14:57:12.206412+00	2	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b20e0159-de08-4174-8a71-83ebb743c360	Mới chia tay xong, cần thời gian để heal 💔	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-25 15:20:18.006249+00	\N	1	2025-12-25 15:25:25.30971+00	1	1abd3aa6-3068-469f-9c45-a38ad7076fdf	d392e7ba-7cce-4371-bf8a-81200ae3d589	hdpe thì ngon luôn	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-25 15:21:31.451177+00	\N	0	2025-12-25 15:21:31.451177+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	beacfc19-af44-4d74-ba21-fda81d72293a	hdpe là ngon luôn	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-25 16:08:29.389954+00	\N	0	2025-12-25 16:08:35.718591+00	1	1abd3aa6-3068-469f-9c45-a38ad7076fdf	5c6abd03-491d-475f-b0e6-6cc41d054919	fuck	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-25 16:06:41.631789+00	\N	1	2025-12-25 16:09:19.697514+00	1	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b5aba5ba-c977-4100-868f-c5bc179a9d3a	yessir	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-15 06:54:26.523876+00	\N	1	2025-12-19 05:47:21.318598+00	1	c986c222-633d-4b87-b1c6-af938fb558e7	8842eecd-91df-4fc0-8b85-e0f1e032d145	vui	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-19 14:52:18.652751+00	\N	2	2025-12-19 07:25:28.133832+00	2	2fbff3dd-1da7-472e-9273-c495a1c0b870	5c4b1abe-29ca-421e-a95f-6def93804ee5	Mới chia tay xong, cần thời gian để heal 💔	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-20 13:52:18.652751+00	\N	1	2025-12-19 07:25:29.546583+00	1	2fbff3dd-1da7-472e-9273-c495a1c0b870	d0ee6ccb-46f1-44ce-8ae0-76934935ba51	Hôm nay cảm giác hơi cô đơn, muốn tìm người nói chuyện 😔	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-26 02:52:18.652751+00	\N	1	2025-12-19 07:25:31.512356+00	1	2fbff3dd-1da7-472e-9273-c495a1c0b870	2140c3e5-87fb-4af8-b550-4947527f85c4	\r\nYêu xa có vui không các bạn ơi?	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-16 03:52:18.652751+00	\N	1	2025-12-19 07:26:27.241592+00	1	2fbff3dd-1da7-472e-9273-c495a1c0b870	6fbfa0f0-9ddf-4ddb-95ff-ad53393934c5	Thích người có chiều sâu trong suy nghĩ	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-12 15:52:18.652751+00	\N	1	2025-12-19 07:26:28.859804+00	1	2fbff3dd-1da7-472e-9273-c495a1c0b870	a694c093-5d90-463e-ab71-79d8b6f79061	T30 rồi mà vẫn FA, ai cũng vậy không? 😅	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-11 10:52:18.652751+00	\N	1	2025-12-19 07:26:30.154735+00	1	2fbff3dd-1da7-472e-9273-c495a1c0b870	54db354f-8588-49b2-90aa-fbcbb6dd542c	Weekend này ai rảnh đi bowling không? 🎳	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-14 09:52:18.652751+00	\N	2	2025-12-19 07:49:54.620795+00	2	2fbff3dd-1da7-472e-9273-c495a1c0b870	b6940166-e3ce-4374-8aaa-255442a58979	Ai muốn đi cafe cuối tuần này không nhỉ? ☕	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-26 04:52:18.652751+00	\N	3	2025-12-19 07:50:18.541895+00	3	2fbff3dd-1da7-472e-9273-c495a1c0b870	b2023a96-a193-42ac-9de2-fe4be55d04e3	Tìm người cùng sở thích để kết nối	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-31 06:52:18.652751+00	\N	3	2025-12-20 06:31:40.279497+00	3	2fbff3dd-1da7-472e-9273-c495a1c0b870	c92262a6-94dc-4a2a-9236-444a0b09020f	Single life đôi khi cũng vui nhưng thiếu sự chia sẻ	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-01 00:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c56ee46e-b91e-419f-b214-5542b6913882	Thích người biết nấu ăn quá đi mất 😍🍳	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-28 20:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	34bc6a25-7f07-48ce-900b-7729adb33257	Hôm nay vui quá! Cuối cùng cũng xong deadline 🎉	PUBLIC	\N	\N	\N	ACTIVE
0	2025-10-25 17:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	501dc556-1974-49f7-8137-3c5ce8fa5715	Mệt mỏi quá, cần một chuyến du lịch ngay 😫	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-26 21:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5f1839b1-5f94-4b58-bb3e-04b0d4c86276	Cuộc sống đẹp lắm, hãy lạc quan lên! ☀️	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-30 01:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	161193ed-f655-436d-b937-b559f2a4e506	Stress công việc, cần uống bia thư giãn 🍺	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-06 03:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	3c88a0e9-f5e8-4b54-85a5-c687f5b62304	Sáng nay thức dậy cảm thấy tràn đầy năng lượng 💪	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-05 19:52:18.652751+00	\N	1	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cf0e1d28-048d-4b8c-b8ff-b5992a95b087	Ai cũng có những ngày tồi tệ thôi	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-31 13:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e4e541fd-46d3-48ca-b2ad-dc2d30f752bd	Tối nay mưa to, ở nhà xem phim vậy 🌧️	PUBLIC	\N	\N	\N	ACTIVE
0	2025-10-22 19:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c92acff9-6d7d-4ce7-8484-2b471a93941d	TGIF! Cuối tuần rồi các bạn! 🎊	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-01 03:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5402a278-6eb5-457d-97a8-b9eb6c48e1c0	Hôm nay tâm trạng không ổn lắm...	PUBLIC	\N	\N	\N	ACTIVE
0	2025-10-31 14:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ec1766e6-2b6f-41fd-8208-a3e435aa1430	Phở sáng nay ngon không tưởng! 🍜❤️	PUBLIC	\N	\N	\N	ACTIVE
0	2025-10-26 16:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f8bf6f06-f332-4dd9-8f6e-4144de3036d7	Ai biết quán bún bò Huế ngon ở Hà Nội không?	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-18 22:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	3baef602-ce1b-4cf4-aa3c-8aea7514f2c4	Vừa về từ Đà Lạt, view đẹp muốn xỉu 😍🌲	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-27 21:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	9ddf37da-0863-4bd9-b961-ee25d37c8bd8	Weekend này đi Hạ Long nha! ⛵	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-28 18:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0b85a289-710c-4ed6-b582-02e1e7320997	Bánh mì Sài Gòn không ai sánh được 🥖	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-23 13:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	2610e16a-4484-4285-9f79-10632c59349d	Cà phê sữa đá = happiness 😌☕	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-24 19:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	4e7448c6-9db7-4fc2-8f4c-075eae48f1ea	Planning chuyến đi Phú Quốc tháng sau! 🏖️	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-06 19:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	36b82712-226b-4a36-b68e-a4be9699b751	Lần đầu ăn sushi ngon vậy! 🍣	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-03 01:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	9ce9007d-83b9-4344-ba8b-e8bae232f23d	Hội An đẹp quá trời quá đất 🏮	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-28 05:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	57be9dcd-a4bb-46ad-a80e-57ff8cc881c9	Thèm ăn bún chả Hà Nội ghê 🤤	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-18 14:52:18.652751+00	\N	1	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	eae6dafb-6483-4269-95b9-7e404a7ef8b6	Vừa hoàn thành marathon 21km! 🏃‍♂️	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-10 01:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7246201d-47c5-4367-927a-9adabaf621c7	Gaming all night, ai chơi VALORANT không? 🎮	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-06 18:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a919e148-5b76-4090-b006-36c898e79f38	Học guitar được 3 tháng rồi 🎸	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-16 08:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	eba98c94-a2b3-41f4-9236-bd714b17ca34	Yoga buổi sáng là cách tốt nhất bắt đầu ngày 🧘	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-28 22:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cf0f2100-dff1-489c-a70d-26840d2bb9bd	Vẽ tranh thấy relax quá 🎨	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-16 17:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	1ca95f62-fbce-4411-9943-af73d27253ad	Ai làm handmade với mình không? ✂️	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-08 08:52:18.652751+00	\N	1	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	107d55ce-e014-4c22-b9a2-abbfe865fcf9	Đọc xong quyển sách tuyệt vời! 📖✨	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-11 16:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	9e065a1a-6f22-4a4f-8263-8eef128ffd61	Hôm nay luyện boxing, người mỏi 🥊	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-09 21:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5ff4d30a-548e-4476-bb8e-d8e73cf1f1b5	Chụp ảnh street photography cực ghiền 📷	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-27 18:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	3bf42efb-51fe-4faf-9fc9-6a9df2243402	Tối nay đi xem concert ai cùng không? 🎵	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-27 21:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	cd66ce92-c810-47ba-8556-8dc026b3474f	Lương tháng này về! Đi shopping thôi 💸	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-11 04:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	1c73df41-2c80-416d-b536-455c2b3ee6c1	Làm việc remote thoải mái nhưng cô đơn 💻	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-28 16:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	aaf17932-0432-4189-8667-87581a4f183b	Vừa pass phỏng vấn company mơ ước! 🎉	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-15 19:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	4d6dc4e8-6018-497e-9ab2-630f51195bd0	Thứ 2 với meeting là một 😩	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-28 08:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	dbe0b6e6-ab80-408f-8c87-4978cd9da912	Làm freelancer vui nhưng không stable	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-08 03:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0ea2076e-81a4-4e49-a57a-a08dccf048ba	Đang nghiền ngẫm chuyện lập startup 🚀	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-04 11:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7001b0ed-c7a2-413d-aba3-8a453283ff19	Code cả ngày mà bug không hết 😤	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-24 07:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	41a7668d-7a11-455b-88f3-9c9cb004615d	Được tăng lương rồi! 📈	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-05 23:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	64f28997-8065-4c08-ab79-02adc85591a9	Project launch thành công! 👏	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-09 18:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	5fac3e18-5f50-4fc0-ab54-05919a94a927	Nghỉ phép 1 tuần, chill! 🏝️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-19 10:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	691e36d7-2272-4158-93ea-700bd34fc4d8	Sống ở Hà Nội hay Sài Gòn tốt hơn? 🤔	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-13 00:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7603ae43-b9b2-458b-989f-3eaf59a9e7c4	Thức khuya nhiều không tốt cho sức khỏe	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-22 02:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	bc7c3265-a8c8-488d-ae95-50696deed5c2	Tự nấu ăn tiết kiệm và healthy hơn	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-08 10:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	057c9a87-24ea-4844-a37e-bf1af1f3c167	Mọi người nghĩ sao về kết hôn trước 30?	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-27 00:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	38a013bd-6bd2-41f8-b463-e859b1b2d07c	Sống tối giản giúp mình hạnh phúc hơn ✨	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-14 05:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	279ab098-a3c3-43bd-9c10-b3cb3e6b2aad	Tập thể dục mỗi sáng là thói quen tốt! 🏃	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-21 02:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	908f5189-b876-4f0c-86d0-e043dc5e7a11	Đi du lịch một mình cũng tuyệt đấy 🌍	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-12 12:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b526afa6-056c-4cbc-b701-04633e294a6b	Học tiếng Anh mỗi ngày 📚	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-29 13:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c8ce2c04-4e3e-45d5-8d2c-a47831c412c4	Muốn nuôi chó nhưng chưa sẵn sàng 🐕	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-21 07:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	67bf017e-cf97-43f3-979c-86152a1962ae	Thời tiết Sài Gòn nóng quá 🥵	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-03 11:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	6981b57b-aeb9-49d8-a68b-ac0a0c92321e	Ai muốn đi cafe cùng không? ☕	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-17 06:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	16e3d542-4347-4c80-9071-5ea979a09556	Tối nay rảnh, chill ở nhà xem Netflix 📺	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-08 13:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8445bbf5-682f-4779-95fa-08c971679f91	Weekend này ai đi chơi không? 🎉	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-06 20:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	b0430ad5-341a-416d-95d9-4c11649850d4	Đang tìm người cùng sở thích photography 📸	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-14 17:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	62ed0725-6ca2-4fa7-849e-668a55ef5a3a	Happy hour! Ai đi uống bia? 🍻	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-13 16:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ad0c8bdf-0ca4-4e7d-b3ec-f4b735d7a10b	Tìm bạn đi leo núi cuối tuần! ⛰️	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-25 03:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	af3b4dc7-d5f5-412b-9b71-b1e8cfc1c9aa	Hôm nay tập vất vả nhưng tuyệt 💪	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-02 03:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f30b4b1e-0a61-42e2-b458-1c2ee9d5ef33	Quán cơm tấm này ngon lắm 🍛	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-11 09:52:18.652751+00	\N	1	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	9d5e8e94-fe0a-4c88-9791-e3837fda4c73	Sài Gòn ban đêm đẹp vô cùng 🌃	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-30 07:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	9d2e58ee-afac-4c9c-9ad5-2a9825d8c524	Ai thích nhạc indie không? 🎵	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-25 14:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e38fc669-c571-4b01-9031-7c74fcdb9fed	Weekend đi Vũng Tàu ngắm biển 🌊	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-16 00:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	249f4fe3-239e-4e1e-80f2-ce2feab2d5c1	Cần motivation thức dậy sớm 😅	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-18 18:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c0068e65-3d22-4dbf-8fe0-ec55f2490b17	Tối nay đi chạy bộ công viên không? 🏃‍♀️	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-20 18:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ca332b84-00bd-4346-affe-ca4463f69a9d	Đọc sách mỗi ngày giúp grow nhiều 📖	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-16 03:52:18.652751+00	\N	1	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	28acbe82-8894-48cf-b1f2-be232ae4f20a	Ai chơi tennis với mình không? 🎾	PUBLIC	\N	\N	\N	ACTIVE
0	2025-10-20 14:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	51983de2-afad-41f7-a994-d294d2d5bb5e	Hôm nay làm việc hiệu quả quá! 🚀	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-04 13:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	08eef7b4-15a1-44c2-b093-228cb76da93f	Thèm phở Hà Nội, quán nào ngon? 🍜	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-07 15:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7925c6dc-5954-4b04-9a53-3d0ff505d085	Mới về từ gym, người nhẹ hơn 🏋️	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-30 22:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	c5f0c36a-3152-4b86-a6d0-08d213886be8	Tìm người học tiếng Nhật cùng! 🇯🇵	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-13 16:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	a145e89d-5c58-4c73-aed7-29f8f976e50b	Ai thích đi bar tối thứ 6? 🍸	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-12 05:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	2df9ed85-792b-4c66-afd5-29d1b94fd9d2	Hôm nay cực kỳ productive! ✅	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-16 04:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	2d4e3ef8-3377-40e1-9081-e29292cf2db5	Đang chill tại quán cafe yêu thích ☕❤️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-15 10:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	7114471f-f682-41a6-bdb6-3369e68bb7a7	Tối nay karaoke nha! 🎤	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-17 19:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	305c8ceb-c59c-4f6e-b95e-4dc175cb42b9	Muốn đi Nhật lắm, ai đã đi chưa? 🇯🇵	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-21 07:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e7e21702-500b-474c-8974-501bc20cf482	Thứ 2 này năng lượng tốt! 💯	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-05 21:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	9a1280f2-22a4-41e6-af70-f5f6cd80911d	Ai biết quán lẩu ngon giá hợp lý? 🍲	PUBLIC	\N	\N	\N	ACTIVE
0	2025-12-10 23:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	6a9d0a63-4c3a-49eb-aa12-7a6d8875d8a5	Weekend đi picnic Ecopark! 🧺	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-17 12:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f4715d53-d618-4cbf-911b-5d1768bbe9a3	Hôm nay tâm trạng tốt vô cùng! 😊	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-16 10:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	37a692c5-a433-4c01-a3a4-cdb0918110c3	Đang nghiền ngẫm về cuộc sống... 🤔	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-04 19:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e0d645b4-2eee-4f1b-ba6a-24d01c971d16	Tối nay xem phim kinh dị ai cùng? 👻	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-29 14:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	d37cc9ff-c891-4f3d-a7d0-0e9f394d6129	Học piano được 6 tháng rồi! 🎹	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-14 00:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	e02c1530-d432-499e-bd64-ce6a28247516	Ai thích chụp ảnh vintage? 📷	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-23 14:52:18.652751+00	\N	1	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	8ecee724-6c1c-4c1a-bd0d-928c2bff8d0c	Hôm nay chạy được 5km! 🏃	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-16 16:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0040a600-99a9-4844-9ea5-3ba03e6f7733	Tìm người đi trekking Sapa tháng sau 🏔️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-20 09:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	eeb66971-eb18-4de6-a7d6-dbb01565691e	Quán trà sữa mới này ngon lắm! 🧋	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-24 20:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	fe8d3a4c-aedf-4c69-b77c-fce738f680d2	Ai học marketing cùng mình? 📊	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-03 05:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f5c2c87c-6c7c-41a2-a09e-8b3e68a1ece8	Weekend này stay home relax 🛋️	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-02 21:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f51e1a97-cf97-4c57-ad8c-84165bafe12f	Đang tìm người cùng đam mê nhiếp ảnh	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-29 15:52:18.652751+00	\N	0	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0cc3c6ec-ff35-4da9-8b2a-08040fe92d4c	Thích người có văn hóa đọc sách	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-24 15:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	e6a861b8-ad18-496a-84b6-14406c206656	Ai muốn đi cafe cuối tuần này không nhỉ? ☕	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-03 09:50:57.936814+00	\N	2	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	31bcf1b7-1479-4d25-a6cb-9cb2cb0ba460	Tìm người cùng sở thích để kết nối	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-06 12:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	f778f110-1a0a-471d-9de1-33f3f6f30475	T30 rồi mà vẫn FA, ai cũng vậy không? 😅	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-29 01:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	de1aa8cc-6863-47a1-8132-150d762852c6	\r\nYêu xa có vui không các bạn ơi?	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-04 01:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	53f9fb19-510d-4510-a76f-6f3b4448e541	Weekend này ai rảnh đi bowling không? 🎳	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-18 20:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	98336c18-41fb-4f39-b0e0-39b0e8afe8f2	Thích người biết nấu ăn quá đi mất 😍🍳	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-01 01:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	ec1b4911-d5ff-43af-a7a6-0ffd301ab427	Hôm nay vui quá! Cuối cùng cũng xong deadline 🎉	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-04 10:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	abb693cf-33ff-44c9-a64d-440ae1904bb6	Mệt mỏi quá, cần một chuyến du lịch ngay 😫	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-13 03:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b6db8f9b-db77-4c20-92cd-62b41bf9c944	Thứ 2 buồn quá mọi người ơi 😢	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-20 07:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	e3771fcb-31d8-41dd-8cf7-a065c5ee4430	Cuộc sống đẹp lắm, hãy lạc quan lên! ☀️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-03 20:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	8a7f2fae-66cd-4800-8d42-2e6860739654	Stress công việc, cần uống bia thư giãn 🍺	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-10 04:50:57.936814+00	\N	1	2025-12-19 07:50:59.599401+00	1	1abd3aa6-3068-469f-9c45-a38ad7076fdf	06d35722-3bfd-409e-84ef-116aac88c4c3	Thích người có chiều sâu trong suy nghĩ	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-04 14:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	420e5094-6aa0-42cd-8386-912f01d41dd5	Sáng nay thức dậy cảm thấy tràn đầy năng lượng 💪	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-23 21:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	c34ec469-f699-4cbc-9241-8e0992688aad	Ai cũng có những ngày tồi tệ thôi	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-23 12:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	1781164d-aae4-4f0a-9d83-5d14a70f6990	Tối nay mưa to, ở nhà xem phim vậy 🌧️	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-06 14:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	f68cf51b-5606-4200-b110-9ddd34a13251	TGIF! Cuối tuần rồi các bạn! 🎊	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-23 21:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b81c3242-04a1-49eb-b283-892421cd45c6	Hôm nay tâm trạng không ổn lắm...	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-27 22:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	ab97709f-d2e6-4967-ab09-3e24512c52a5	Phở sáng nay ngon không tưởng! 🍜❤️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-14 14:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	60ef2f7d-e772-42d0-af2d-62221c62400b	Ai biết quán bún bò Huế ngon ở Hà Nội không?	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-23 17:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	7d444e40-3b9d-4b89-94fb-a53ba62467c2	Vừa về từ Đà Lạt, view đẹp muốn xỉu 😍🌲	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-01 19:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	cede95bf-7606-4d9d-8bed-8509e027b61d	Weekend này đi Hạ Long nha! ⛵	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-04 08:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	01fbe6b4-42ea-4f13-aedc-b41b66b63f36	Bánh mì Sài Gòn không ai sánh được 🥖	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-05 10:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	097e8be6-2de8-42ae-bfcf-2951d96bddb6	Cà phê sữa đá = happiness 😌☕	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-22 05:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	7342e45e-d093-4738-b89e-f84a24144972	Planning chuyến đi Phú Quốc tháng sau! 🏖️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-10 12:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	cd2eca79-ad56-4e4c-8679-bfe92b7d91b1	Lần đầu ăn sushi ngon vậy! 🍣	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-05 15:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	c5a53e66-d3fd-43b3-9e56-1d175cfe09c4	Hội An đẹp quá trời quá đất 🏮	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-23 20:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	951c8ef2-0982-4991-9ed1-fa5d3710bd2c	Thèm ăn bún chả Hà Nội ghê 🤤	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-30 19:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	ae3a3f5b-3f4f-4375-956f-0a31ffeb4dff	Vừa hoàn thành marathon 21km! 🏃‍♂️	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-03 13:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	2306c799-2354-4b39-b0e1-f50ca86fa9a7	Gaming all night, ai chơi VALORANT không? 🎮	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-25 14:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	bddd6d02-c07e-47cc-bcb3-dfe90830fbee	Học guitar được 3 tháng rồi 🎸	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-25 18:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	306fe046-1b25-40e6-8a27-bec37bd32614	Yoga buổi sáng là cách tốt nhất bắt đầu ngày 🧘	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-18 17:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	765b545b-ab9d-4dba-b26b-e9ebc393aede	Vẽ tranh thấy relax quá 🎨	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-12 14:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	c788d142-afe4-4790-9f7a-d6d6bcb4017a	Ai làm handmade với mình không? ✂️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-15 05:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	74c0890a-7d32-4666-9001-8616fe63af61	Đọc xong quyển sách tuyệt vời! 📖✨	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-31 19:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	9d71f4bb-1ad9-4ef0-bb20-b99702b32474	Hôm nay luyện boxing, người mỏi 🥊	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-03 10:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	2b4d404f-af98-4b6e-97e2-487f9b84047d	Chụp ảnh street photography cực ghiền 📷	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-21 05:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	a43c9cb1-dabb-43d4-9fa7-f5f378a50f4c	Tối nay đi xem concert ai cùng không? 🎵	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-22 05:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	71458d31-4161-4835-9b98-c70f1787d4a6	Lương tháng này về! Đi shopping thôi 💸	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-23 20:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	8dbc4147-7063-400c-99a0-97aadef49864	Làm việc remote thoải mái nhưng cô đơn 💻	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-17 06:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	f818e29e-2264-47e5-85a7-c5e8a4db8f21	Vừa pass phỏng vấn company mơ ước! 🎉	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-14 09:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	311ce3af-5f0a-4011-9e7f-dd2ad8f01fa7	Thứ 2 với meeting là một 😩	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-29 21:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	5aeb9d98-a984-4361-a914-a9c0d171f792	Làm freelancer vui nhưng không stable	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-22 14:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	3bec3a67-58f3-4a67-a300-5c12de77481c	Đang nghiền ngẫm chuyện lập startup 🚀	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-13 12:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	66662d1b-794a-4641-8886-3e91bb3158aa	Code cả ngày mà bug không hết 😤	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-29 21:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	97dcb5e5-2f77-4296-8adf-d17c166a56e1	Được tăng lương rồi! 📈	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-20 20:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	37dc1845-04bb-44bc-b32a-db37f0c25717	Project launch thành công! 👏	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-23 23:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	4a1ad6a0-5702-42e7-a756-9801595e1b2c	Nghỉ phép 1 tuần, chill! 🏝️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-20 12:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	2632f577-b312-4a72-884d-1d94bef08c6c	Sống ở Hà Nội hay Sài Gòn tốt hơn? 🤔	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-15 21:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	58746496-23d4-4ae4-a1d1-1a3de2ef4609	Thức khuya nhiều không tốt cho sức khỏe	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-18 16:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	4c46dd9f-22b6-43f2-8856-087f30ed0745	Tự nấu ăn tiết kiệm và healthy hơn	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-14 18:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	8a0db927-d52e-446d-8bc8-c1e16024c283	Mọi người nghĩ sao về kết hôn trước 30?	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-02 03:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	59dc22d9-fe1e-4618-8a36-2f768143b988	Sống tối giản giúp mình hạnh phúc hơn ✨	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-27 07:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	e67b6f1e-a2ef-4128-9778-cceb03f71a8e	Tập thể dục mỗi sáng là thói quen tốt! 🏃	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-16 20:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	33e740d7-e199-4fa6-9af9-c1b451c51838	Đi du lịch một mình cũng tuyệt đấy 🌍	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-12 19:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	1523948a-a727-4f0c-9d52-e33c20f3834e	Học tiếng Anh mỗi ngày 📚	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-06 19:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	eaabd4e5-b6c1-4678-9cea-58d7190a7f3e	Muốn nuôi chó nhưng chưa sẵn sàng 🐕	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-26 13:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	e554f9a2-fcb9-4c85-a52a-6ea2955117b3	Thời tiết Sài Gòn nóng quá 🥵	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-15 09:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	23bd823f-8c3f-4607-8605-59ff67874886	Ai muốn đi cafe cùng không? ☕	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-13 23:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	60aa584b-e2de-4997-87ff-3675276a53e7	Tối nay rảnh, chill ở nhà xem Netflix 📺	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-12 16:50:57.936814+00	\N	2	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	a9b54525-7574-43c3-84de-60dbf19aa9ac	Weekend này ai đi chơi không? 🎉	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-28 13:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b93534d9-4a9f-4e31-a52e-6f1c98012d8c	Đang tìm người cùng sở thích photography 📸	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-15 08:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	a07d951d-33aa-4dcd-9d6f-38f0dd3bbbb1	Happy hour! Ai đi uống bia? 🍻	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-27 04:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	d2dc024f-8dd7-4305-b34d-f022a92e8eea	Tìm bạn đi leo núi cuối tuần! ⛰️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-15 13:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	54128841-d796-4af0-adb3-2e8ac9b9fd8a	Hôm nay tập vất vả nhưng tuyệt 💪	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-15 16:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	4ad73a4d-022d-49b2-9b93-2eeb0f3c4c8a	Quán cơm tấm này ngon lắm 🍛	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-02 03:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	614a72a8-1a61-4f22-bbce-35c735e856ca	Sài Gòn ban đêm đẹp vô cùng 🌃	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-11 08:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b6b6ffc7-5608-48f7-a91b-7624854d4c18	Ai thích nhạc indie không? 🎵	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-13 11:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	256dfa3b-6b08-4076-b027-717b4748f1f3	Weekend đi Vũng Tàu ngắm biển 🌊	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-13 19:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	97921494-ee29-4269-8eb2-6fc8f5d487b5	Cần motivation thức dậy sớm 😅	PUBLIC	\N	\N	\N	ACTIVE
0	2025-11-15 15:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	eb1df73b-6280-456f-8778-b62883610970	Tối nay đi chạy bộ công viên không? 🏃‍♀️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-11 11:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	90bbc811-f855-41f0-98e3-79eacde99da0	Đọc sách mỗi ngày giúp grow nhiều 📖	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-26 13:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	04578903-cbcd-4227-8344-8af8af430449	Ai chơi tennis với mình không? 🎾	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-06 02:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	cc59412e-089a-4bc5-a644-e50c0e3a76c6	Hôm nay làm việc hiệu quả quá! 🚀	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-12 00:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	7acaa218-dbd5-4517-b814-ff1f97bdf6f1	Thèm phở Hà Nội, quán nào ngon? 🍜	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-27 07:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	9a4131b4-2029-469c-b261-72971a4cbbbb	Mới về từ gym, người nhẹ hơn 🏋️	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-08 05:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	f9a96ec1-29a2-4d72-b98a-139470db22a3	Tìm người học tiếng Nhật cùng! 🇯🇵	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-22 15:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	ccc4a84e-e519-4526-aa4e-f41f4482c019	Ai thích đi bar tối thứ 6? 🍸	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-22 16:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	3687dfc8-f059-43e0-9088-2a42a0333d0f	Hôm nay cực kỳ productive! ✅	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-02 10:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	bf252fc0-bead-41f2-80ae-4e2ac5d24545	Đang chill tại quán cafe yêu thích ☕❤️	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-17 08:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	213387bc-4d29-4caf-a532-93b850d29b34	Tối nay karaoke nha! 🎤	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-08 09:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	7fbb2bbf-5ca1-4e14-bd0b-c166a67e8232	Muốn đi Nhật lắm, ai đã đi chưa? 🇯🇵	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-09 10:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	915a00b7-48a4-4ff8-959b-f20c42ae157f	Thứ 2 này năng lượng tốt! 💯	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-07 02:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	dbbcd2d5-b9d7-48b6-88ca-af09db4cdaa6	Ai biết quán lẩu ngon giá hợp lý? 🍲	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-11 18:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	0e8647d3-f2ff-4673-8f48-28e8228661e6	Weekend đi picnic Ecopark! 🧺	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-13 19:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	345389ee-235c-4907-8384-d81e42c42ae8	Hôm nay tâm trạng tốt vô cùng! 😊	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-02 15:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	9320aa87-a31d-45cb-b57c-7069333e6c57	Đang nghiền ngẫm về cuộc sống... 🤔	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-02 18:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	e7752d99-8f2a-4da4-ad91-d71fd545bc46	Tối nay xem phim kinh dị ai cùng? 👻	PUBLIC	\N	\N	\N	ACTIVE
1	2025-10-20 22:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	7cc09085-8f78-4e38-967b-8d13070957e2	Học piano được 6 tháng rồi! 🎹	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-25 08:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	e5438053-97d0-40a1-94cf-6504caed7ce7	Ai thích chụp ảnh vintage? 📷	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-22 13:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	884b6db5-5247-43e9-ac9a-9b522216c650	Hôm nay chạy được 5km! 🏃	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-16 18:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	12b0b6f0-9820-4732-aba6-331411b6a4a9	Tìm người đi trekking Sapa tháng sau 🏔️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-15 03:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	23faaa79-5567-4c1b-98ea-11d42b9a5624	Quán trà sữa mới này ngon lắm! 🧋	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-22 15:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	375de7b9-098b-4f15-9bbf-4b5b014f675a	Ai học marketing cùng mình? 📊	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-11 04:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	c158497f-c68c-425c-bb99-8e6814363bc8	Weekend này stay home relax 🛋️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-30 21:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	009e8f8d-1862-4387-9fa0-d35c009a03e6	Đang tìm người cùng đam mê nhiếp ảnh	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-27 07:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	6f577918-32ff-4dc8-a835-235b2d55c345	Thích người có văn hóa đọc sách	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-01 03:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6f91d50b-8aff-4803-99ab-b53028981df0	Mới chia tay xong, cần thời gian để heal 💔	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-03 11:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ed0e7b6c-058a-48bf-a2c1-3f9af8b12528	T30 rồi mà vẫn FA, ai cũng vậy không? 😅	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-07 17:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c30d8234-dd2d-45bd-83ad-0b18fd840343	\r\nYêu xa có vui không các bạn ơi?	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-13 09:06:12.201045+00	\N	3	2025-12-19 05:47:10.874328+00	6	c986c222-633d-4b87-b1c6-af938fb558e7	fbdba4ba-3558-4c0d-9e9e-3dcd093656d5	dog	PUBLIC	\N	\N	\N	ACTIVE
5	2025-12-17 05:55:06.662659+00	\N	2	2025-12-19 05:47:12.231798+00	2	1abd3aa6-3068-469f-9c45-a38ad7076fdf	f6b2f9a7-61d8-464d-a97a-8d75cc806b47	fun	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-26 15:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a694c11b-ad03-4a7a-bb82-7ac1f30addb0	Weekend này ai rảnh đi bowling không? 🎳	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-17 06:48:33.498951+00	\N	2	2025-12-19 05:47:16.613555+00	2	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b2dab698-c3ae-4c8b-b3d1-1d5a5431604e		PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-18 07:58:15.277877+00	\N	2	2025-12-19 05:47:19.085108+00	2	c986c222-633d-4b87-b1c6-af938fb558e7	523f2954-30c1-471e-89b0-7fd638788ac3	fun	PUBLIC	\N	DA_NANG	Đà Nẵng	ACTIVE
2	2025-12-15 06:55:22.706772+00	\N	1	2025-12-19 05:47:09.093168+00	1	c986c222-633d-4b87-b1c6-af938fb558e7	9b963a1c-c133-4df0-aadf-e6bea2c1e50d	funnn	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-30 10:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e0d80e6e-72dc-403f-ae90-5a71399b50e9	Hôm nay cảm giác hơi cô đơn, muốn tìm người nói chuyện 😔	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-05 18:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9db9f670-0a6e-4fa0-9a6d-2737fb28303f	Single life đôi khi cũng vui nhưng thiếu sự chia sẻ	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-28 09:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1ab81feb-545f-46f8-8eb8-7f580f331ca7	Ai muốn đi cafe cuối tuần này không nhỉ? ☕	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-24 02:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	caf7a7bc-0d09-4668-b59b-7efb63a7ea00	Tìm người cùng sở thích để kết nối	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-16 02:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8f178140-5846-4df0-8786-129675be0fff	Thích người có chiều sâu trong suy nghĩ	PUBLIC	\N	\N	\N	ACTIVE
5	2025-12-19 05:47:53.263026+00	\N	1	2025-12-19 05:48:28.737964+00	1	1abd3aa6-3068-469f-9c45-a38ad7076fdf	488d9dea-8553-4e49-bf2b-106c5e143613	ohsshit mucle hellokitty	PUBLIC	0101000020E610000098EEBFDFF90F5B4002AFE0C84DF62F40	\N	\N	ACTIVE
5	2025-12-15 15:49:23.030502+00	\N	2	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1c53e1ce-c1dd-4d64-afba-b76249b0c44a	Thích người biết nấu ăn quá đi mất 😍🍳	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-24 10:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a0576d7a-2356-41d3-8040-2418a8518e49	Hôm nay vui quá! Cuối cùng cũng xong deadline 🎉	PUBLIC	\N	\N	\N	ACTIVE
5	2025-10-31 01:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d190b3bc-6b6d-48bf-ac30-8b84d9fb842c	Mệt mỏi quá, cần một chuyến du lịch ngay 😫	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-22 13:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6fabb14b-cfc7-4afd-98e0-c741db54a528	Thứ 2 buồn quá mọi người ơi 😢	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-22 04:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a1434472-6a39-42d1-8322-2242b0faec4c	Cuộc sống đẹp lắm, hãy lạc quan lên! ☀️	PUBLIC	\N	\N	\N	ACTIVE
4	2025-10-30 00:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	018ce88a-19ec-4e0d-a35c-9f9abbe7d423	Stress công việc, cần uống bia thư giãn 🍺	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-30 00:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	315cbe78-ff19-4a10-9df6-4c324e55a308	Sáng nay thức dậy cảm thấy tràn đầy năng lượng 💪	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-08 08:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a7eda267-2926-4574-b931-9087cc71040d	Ai cũng có những ngày tồi tệ thôi	PUBLIC	\N	\N	\N	ACTIVE
4	2025-10-28 05:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	03729fff-4ed4-4ec8-a45d-0aa62843df4f	Tối nay mưa to, ở nhà xem phim vậy 🌧️	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-10 04:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3b2a05d2-c06d-4580-97d9-01b3b340af85	TGIF! Cuối tuần rồi các bạn! 🎊	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-13 06:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c01425b1-ca97-4d65-b2b2-25ea7366b6e9	Hôm nay tâm trạng không ổn lắm...	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-15 17:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	380cbbe2-5e4e-4fbf-8834-0426188b4486	Phở sáng nay ngon không tưởng! 🍜❤️	PUBLIC	\N	\N	\N	ACTIVE
6	2025-11-26 17:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	af1518c6-25eb-4d4d-be15-047336e3b091	Ai biết quán bún bò Huế ngon ở Hà Nội không?	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-15 11:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	578c949a-4092-4f8f-8a23-953ef093f6f4	Vừa về từ Đà Lạt, view đẹp muốn xỉu 😍🌲	PUBLIC	\N	\N	\N	ACTIVE
5	2025-10-29 01:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	477ea1c4-d0db-46eb-a83d-1887c3066c76	Weekend này đi Hạ Long nha! ⛵	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-23 07:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	38c4f435-0383-4aea-ae64-3b6fcd2ca8a4	Bánh mì Sài Gòn không ai sánh được 🥖	PUBLIC	\N	\N	\N	ACTIVE
4	2025-10-27 01:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b4a3a72d-9a2e-4cc7-9805-e0d7b8460086	Cà phê sữa đá = happiness 😌☕	PUBLIC	\N	\N	\N	ACTIVE
6	2025-11-26 08:49:23.030502+00	\N	2	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	329f165e-054a-4190-9b74-d0cb07700e11	Planning chuyến đi Phú Quốc tháng sau! 🏖️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-03 01:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	436d5545-896f-4b2c-a457-b5d867c31aff	Lần đầu ăn sushi ngon vậy! 🍣	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-14 14:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a5869473-14de-4b81-bf19-c5fcbef3f988	Hội An đẹp quá trời quá đất 🏮	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-19 06:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	83cade0f-bcf7-4225-b1a3-90d686fc2a3f	Thèm ăn bún chả Hà Nội ghê 🤤	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-23 12:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cd27b1ac-1595-4431-8136-7a6817babe28	Vừa hoàn thành marathon 21km! 🏃‍♂️	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-30 01:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fd3c0334-e400-4620-861a-1a98921c2efa	Gaming all night, ai chơi VALORANT không? 🎮	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-09 11:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d3f183f2-5e0f-407a-b29e-ac189105796f	Học guitar được 3 tháng rồi 🎸	PUBLIC	\N	\N	\N	ACTIVE
5	2025-12-09 12:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	c319c256-93cb-48dd-83c2-05428f75fa76	Yoga buổi sáng là cách tốt nhất bắt đầu ngày 🧘	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-16 18:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f79a722d-a6db-48cb-836b-091ec96026fb	Vẽ tranh thấy relax quá 🎨	PUBLIC	\N	\N	\N	ACTIVE
5	2025-12-14 07:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6f05fb7c-7f24-4fb3-8763-312ea2b52779	Ai làm handmade với mình không? ✂️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-19 13:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	baf47fd0-3863-46ba-8875-9963aab9bbcf	Đọc xong quyển sách tuyệt vời! 📖✨	PUBLIC	\N	\N	\N	ACTIVE
4	2025-10-31 08:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	7f83c5f7-a1f5-4704-bfb8-b098e7ca8df0	Hôm nay luyện boxing, người mỏi 🥊	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-16 12:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ca2771b6-e743-4fb2-9585-49815ea1f159	Chụp ảnh street photography cực ghiền 📷	PUBLIC	\N	\N	\N	ACTIVE
5	2025-12-05 15:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3e82a004-3c12-4e8b-b0d5-58b34c6e0da4	Tối nay đi xem concert ai cùng không? 🎵	PUBLIC	\N	\N	\N	ACTIVE
4	2025-10-21 14:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e900c3eb-5d9e-4b0c-8869-6bc21f08c517	Lương tháng này về! Đi shopping thôi 💸	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-28 20:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	90d59886-4e90-4632-827b-069337f887d6	Làm việc remote thoải mái nhưng cô đơn 💻	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-03 11:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5abc8d96-0dce-46eb-9d46-1ff4f7020e00	Vừa pass phỏng vấn company mơ ước! 🎉	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-05 03:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	63b42a9d-4df4-464b-a66f-a83e36899a2c	Thứ 2 với meeting là một 😩	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-02 10:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ad3b3dc5-a715-47ed-b3e6-7c7691c90292	Làm freelancer vui nhưng không stable	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-06 06:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	69eb4c1b-29b0-45ec-9737-38814966ce06	Đang nghiền ngẫm chuyện lập startup 🚀	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-30 18:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	53af5af3-44dc-4e98-94f3-7dc2a602c2d2	Code cả ngày mà bug không hết 😤	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-05 02:49:23.030502+00	\N	2	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3f734767-2437-4edb-adca-f957ac247374	Được tăng lương rồi! 📈	PUBLIC	\N	\N	\N	ACTIVE
1	2025-12-07 03:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	808e28fe-5c97-4120-966e-0961cc3a7d9b	Project launch thành công! 👏	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-07 12:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2e09c782-f52c-42ae-abc9-7c437db06c63	Nghỉ phép 1 tuần, chill! 🏝️	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-30 16:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	9a01cba2-9740-4bdc-b3a2-c97fa387145f	Sống ở Hà Nội hay Sài Gòn tốt hơn? 🤔	PUBLIC	\N	\N	\N	ACTIVE
5	2025-11-05 06:49:23.030502+00	\N	2	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	018e4a26-93c8-4ac7-99b6-ffef04f067ce	Tập thể dục mỗi sáng là thói quen tốt! 🏃	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-25 00:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	de3c6d3c-9551-4483-8b6d-a89a9673e6e2	Đi du lịch một mình cũng tuyệt đấy 🌍	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-03 11:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e9c7308d-897d-4380-bb1e-59484215e180	Học tiếng Anh mỗi ngày 📚	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-14 22:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	08d8aad9-3f6f-474a-b207-676809f9d0a4	Muốn nuôi chó nhưng chưa sẵn sàng 🐕	PUBLIC	\N	\N	\N	ACTIVE
5	2025-11-04 17:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fb3956bd-ff46-469d-91a6-617dad6e2145	Thời tiết Sài Gòn nóng quá 🥵	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-12 23:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5f515192-7964-4845-ae91-82e9c74a65ef	Ai muốn đi cafe cùng không? ☕	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-07 10:50:57.936814+00	\N	0	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	cec1d8b9-819c-436a-b62f-ffcc52a112d9	Hôm nay cảm giác hơi cô đơn, muốn tìm người nói chuyện 😔	PUBLIC	\N	\N	\N	ACTIVE
1	2025-11-23 02:50:57.936814+00	\N	1	\N	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	92db18d0-2fa3-44c1-a5e7-b7a0b1a15cfb	Single life đôi khi cũng vui nhưng thiếu sự chia sẻ	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-15 15:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f5449411-3ee3-47a9-aa52-7c63aae2de5c	Tối nay rảnh, chill ở nhà xem Netflix 📺	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-02 16:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ccaa812c-5688-4086-a76f-4d29eba4aa9f	Weekend này ai đi chơi không? 🎉	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-20 17:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	28a23ecf-7e87-4517-817f-71005f2181bc	Đang tìm người cùng sở thích photography 📸	PUBLIC	\N	\N	\N	ACTIVE
5	2025-11-07 23:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3dd06b24-a7c0-49f6-a16e-d1e6a34739be	Happy hour! Ai đi uống bia? 🍻	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-23 15:49:23.030502+00	\N	2	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f91cf04e-f6ec-4184-b2b4-a265ec5cb667	Tìm bạn đi leo núi cuối tuần! ⛰️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-18 03:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0315b928-6309-4fdd-9d96-4227695fb0ec	Hôm nay tập vất vả nhưng tuyệt 💪	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-30 12:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	60808489-351b-4443-a95d-1fee8f8d9ba3	Quán cơm tấm này ngon lắm 🍛	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-20 19:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	2c11a22a-de1c-41e5-b3f5-5ec90d484f82	Sài Gòn ban đêm đẹp vô cùng 🌃	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-26 18:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a7bf8fc4-211b-4c93-91a5-2a927127e019	Ai thích nhạc indie không? 🎵	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-05 23:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e8c9b48f-bb4e-4885-92bd-7ec972be3865	Weekend đi Vũng Tàu ngắm biển 🌊	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-10 01:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3ea2b20c-4071-4a2c-a69a-e6583f32297a	Cần motivation thức dậy sớm 😅	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-10 09:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	fcd6215b-2abe-427d-9025-bf0c21aec724	Tối nay đi chạy bộ công viên không? 🏃‍♀️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-16 16:49:23.030502+00	\N	2	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0ccfeb06-e0d7-4161-b5cb-b497b4b28f0f	Đọc sách mỗi ngày giúp grow nhiều 📖	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-27 06:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3a488bda-31da-4c0e-a48d-9df821f81f4c	Ai chơi tennis với mình không? 🎾	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-01 18:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	edfd111b-0ce6-47b2-acf4-13272b45a550	Hôm nay làm việc hiệu quả quá! 🚀	PUBLIC	\N	\N	\N	ACTIVE
4	2025-10-23 19:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	ea7dc302-8294-4b76-9edc-808eb27201ee	Thèm phở Hà Nội, quán nào ngon? 🍜	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-14 19:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b1461a46-ad73-49e6-88aa-044ab10017e7	Mới về từ gym, người nhẹ hơn 🏋️	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-16 10:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	6e1d1c2d-1ed6-432c-8104-a7b8b6c476b6	Tìm người học tiếng Nhật cùng! 🇯🇵	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-24 19:49:23.030502+00	\N	3	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	73f505b7-771c-4543-8aa8-48ecc6c646f3	Ai thích đi bar tối thứ 6? 🍸	PUBLIC	\N	\N	\N	ACTIVE
5	2025-10-27 09:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f86fd3f1-45e2-4998-b465-c10f5483f2e8	Hôm nay cực kỳ productive! ✅	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-03 12:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	af5511d8-6187-4402-850c-9a567ff84ee2	Đang chill tại quán cafe yêu thích ☕❤️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-20 15:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5e37c692-bfa3-42df-8a0e-17c891ff9376	Tối nay karaoke nha! 🎤	PUBLIC	\N	\N	\N	ACTIVE
4	2025-10-29 05:49:23.030502+00	\N	2	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	5ad7114b-d2c8-4ea8-986f-b1ad961f4bf2	Muốn đi Nhật lắm, ai đã đi chưa? 🇯🇵	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-09 17:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0dc13a3e-bf85-4410-9679-daa0e3f1db35	Thứ 2 này năng lượng tốt! 💯	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-01 15:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f366ce18-ef44-47cf-97a5-310852627315	Ai biết quán lẩu ngon giá hợp lý? 🍲	PUBLIC	\N	\N	\N	ACTIVE
2	2025-11-15 20:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	f83553c0-8ed8-4cb7-a0eb-1209bd258a17	Weekend đi picnic Ecopark! 🧺	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-13 07:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	59c1da2e-0d70-49a4-a4d3-a1d518717b20	Hôm nay tâm trạng tốt vô cùng! 😊	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-03 17:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	4fd72897-13fc-4a19-9cdf-642de4b8bdc9	Đang nghiền ngẫm về cuộc sống... 🤔	PUBLIC	\N	\N	\N	ACTIVE
4	2025-12-17 01:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8c0f6e42-050d-4a87-82b6-4d407f9be2da	Tối nay xem phim kinh dị ai cùng? 👻	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-02 06:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	729c5095-4965-4b06-8a3e-74f892f58d64	Học piano được 6 tháng rồi! 🎹	PUBLIC	\N	\N	\N	ACTIVE
5	2025-12-01 00:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	80a80c68-5b98-4043-a0e8-ae6c11bf7961	Ai thích chụp ảnh vintage? 📷	PUBLIC	\N	\N	\N	ACTIVE
4	2025-11-09 23:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	b95c500b-e7d5-4307-9319-55e304e2ca2d	Hôm nay chạy được 5km! 🏃	PUBLIC	\N	\N	\N	ACTIVE
5	2025-12-10 05:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	cdd0d903-6588-4227-a33c-e8a99769f675	Tìm người đi trekking Sapa tháng sau 🏔️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-04 06:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	e1293ed0-26c7-40c1-979b-4431bb2d8161	Quán trà sữa mới này ngon lắm! 🧋	PUBLIC	\N	\N	\N	ACTIVE
4	2025-10-31 13:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	3b67bced-d152-49d5-a170-189200f33385	Ai học marketing cùng mình? 📊	PUBLIC	\N	\N	\N	ACTIVE
2	2025-12-02 19:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d1191140-d45f-436b-8365-d25be77222d6	Weekend này stay home relax 🛋️	PUBLIC	\N	\N	\N	ACTIVE
3	2025-12-07 22:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	d84199b9-1574-41d2-8d92-896eafbb2324	Đang tìm người cùng đam mê nhiếp ảnh	PUBLIC	\N	\N	\N	ACTIVE
6	2025-10-20 07:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	a2003227-c9ee-46e8-800f-ec2a24a90f99	Thích người có văn hóa đọc sách	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-12 02:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	8bf2bf65-128f-4015-ad4d-54fd6105dcb8	Thức khuya nhiều không tốt cho sức khỏe	PUBLIC	\N	\N	\N	ACTIVE
2	2025-10-29 20:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	1abd00ce-2cd5-4197-b058-5bbabdd79ab2	Tự nấu ăn tiết kiệm và healthy hơn	PUBLIC	\N	\N	\N	ACTIVE
3	2025-11-15 23:49:23.030502+00	\N	0	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	0f9777a8-e365-4193-939b-8faf60ea7070	Mọi người nghĩ sao về kết hôn trước 30?	PUBLIC	\N	\N	\N	ACTIVE
3	2025-10-21 13:49:23.030502+00	\N	1	\N	0	c986c222-633d-4b87-b1c6-af938fb558e7	23cce978-fc18-4d3c-92a4-d82717f7c9ac	Sống tối giản giúp mình hạnh phúc hơn ✨	PUBLIC	\N	\N	\N	ACTIVE
\.


--
-- Data for Name: review_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.review_responses (id, review_id, response_text, created_at) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (id, reviewer_id, reviewed_user_id, context_type, context_id, rating, punctuality_rating, communication_rating, friendliness_rating, respectfulness_rating, feedback, tags, photo_urls, is_public, is_anonymous, is_flagged, is_hidden, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: safety_checkins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.safety_checkins (id, user_id, event_id, location_lat, location_lng, location_accuracy, checkin_type, is_sos, sos_message, emergency_contacts_notified, notified_at, responded_at, created_at) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: stories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stories (id, background_color, created_at, expires_at, media_type, media_url, text_content, view_count, user_id) FROM stdin;
24c3d17a-eb94-405f-a4d8-49061e27a86a	\N	2025-12-18 17:48:37.445203	2025-12-19 17:48:37.119907	IMAGE	http://localhost:9000/fyn-data/50e1e5f3-decc-4b89-84f0-0dfb194aefa7-1766080115584_scaled_405353174_336543555654280_280519606896010122_n.jpg	\N	1	1abd3aa6-3068-469f-9c45-a38ad7076fdf
3e9fd67e-fa47-4ce5-87c6-1a118449ff49	\N	2025-12-19 07:52:03.980079	2025-12-20 07:52:03.973172	IMAGE	http://localhost:9000/fyn-data/17049eaa-f64d-4002-976d-225fa092b799-1766130723741_scaled_414902459_371930399122072_3732068960835653293_n.jpg	\N	1	05479f65-5810-4a18-8454-3f9eb850157e
3abf0051-4ce7-4af3-9de6-e9fdd8ebcda9	\N	2025-12-13 17:28:07.741428	2025-12-14 17:28:07.738759	IMAGE	http://localhost:9000/fyn-data/49a6825e-5e7a-46fb-9934-3090ac24931b-1765646887471_scaled_obsidian-rpeview.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minioadmin%2F20251213%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251213T172807Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=413238914907a5133004459a1275cdef92486552b50693bd8f2e2a4aebf96fc3	\N	0	2fbff3dd-1da7-472e-9273-c495a1c0b870
335b4afd-ff66-4788-835b-e46b09b8c349	\N	2025-12-22 10:15:19.6874	2025-12-23 10:15:19.668877	IMAGE	http://localhost:9000/fyn-data/a7b2b840-c073-42a1-acd0-f0910757e22d-1766398518444_scaled_415333692_122111175722155227_8902036074651493388_n.jpg	\N	1	c986c222-633d-4b87-b1c6-af938fb558e7
9ce7f1f2-bf8e-44d5-8a24-c380c865bc7f	\N	2025-12-15 07:21:37.568849	2025-12-16 07:21:37.549888	IMAGE	http://localhost:9000/fyn-data/18b4b02d-3a53-4154-aec1-701a66bf7500-1765783297073_scaled_IMG_1615.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minioadmin%2F20251215%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20251215T072137Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8b8f6bef8e37a49eb9f3e7f1eac756fca0cf946e2991e898b14c36871431af2	\N	1	c986c222-633d-4b87-b1c6-af938fb558e7
e9382850-257b-4ec3-8f87-71987ade8ac0	\N	2025-12-25 15:33:40.719334	2025-12-26 15:33:40.702896	IMAGE	http://localhost:9000/fyn-data/77cfefff-ed3a-4f83-8153-ac8b5749b923-1766676820503_scaled_f2afee09-8547-4bad-9ee1-293a8e288b062299740199103080655.jpg	\N	2	1abd3aa6-3068-469f-9c45-a38ad7076fdf
5a779e36-3986-4b89-9620-51c97eebb952	\N	2025-12-21 14:18:22.977708	2025-12-22 14:18:22.924975	IMAGE	http://localhost:9000/fyn-data/035c20cc-e48d-4bb7-8478-a1d91e9b11a1-1766326701279_scaled_409385431_675767838041523_5499927551760620437_n.jpg	\N	2	1abd3aa6-3068-469f-9c45-a38ad7076fdf
0eb5c214-2819-4f21-a4b9-ec039ede8247	\N	2025-12-24 06:54:12.428936	2025-12-25 06:54:12.416205	IMAGE	http://localhost:9000/fyn-data/f8df6b71-cd77-4f53-9f33-f31dba9c656e-1766559251142_scaled_Screenshot 2025-04-01 220716.png	\N	1	2fbff3dd-1da7-472e-9273-c495a1c0b870
e017871c-ecad-450f-b603-7afb424bcf54	\N	2025-12-25 15:01:29.953643	2025-12-26 15:01:29.952485	IMAGE	http://localhost:9000/fyn-data/c31992b7-8201-4931-a836-225b03bfe19d-1766674889585_scaled_409385431_675767838041523_5499927551760620437_n.jpg	\N	2	2fbff3dd-1da7-472e-9273-c495a1c0b870
1a5a83a6-8af6-487f-a1ab-9d560244cb98	\N	2025-12-25 14:41:02.791548	2025-12-26 14:41:02.789255	IMAGE	http://localhost:9000/fyn-data/37af866e-87ee-4a9b-bd5b-153e637ca307-1766673662149_scaled_aodai.jpg	\N	2	c986c222-633d-4b87-b1c6-af938fb558e7
\.


--
-- Data for Name: story_views; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.story_views (id, viewed_at, story_id, viewer_id) FROM stdin;
12c15fa9-95b2-4a2e-b4e0-88d9bc899409	2025-12-15 07:21:47.502573	9ce7f1f2-bf8e-44d5-8a24-c380c865bc7f	2fbff3dd-1da7-472e-9273-c495a1c0b870
10d20cf1-1b40-455e-9295-7584f5d6c716	2025-12-18 17:48:51.667354	24c3d17a-eb94-405f-a4d8-49061e27a86a	c986c222-633d-4b87-b1c6-af938fb558e7
6acad29d-131a-4294-bfa7-9ef4a927f345	2025-12-20 06:35:26.785358	3e9fd67e-fa47-4ce5-87c6-1a118449ff49	c986c222-633d-4b87-b1c6-af938fb558e7
7825c062-f7a2-43e0-bca0-e636960e8064	2025-12-22 10:24:58.866573	335b4afd-ff66-4788-835b-e46b09b8c349	2fbff3dd-1da7-472e-9273-c495a1c0b870
b204687b-2e73-4ef5-8107-5618bf5a1e68	2025-12-22 10:25:00.754188	5a779e36-3986-4b89-9620-51c97eebb952	2fbff3dd-1da7-472e-9273-c495a1c0b870
6aff5387-3690-42c4-a1b5-d883fa7c3162	2025-12-22 10:30:49.724113	5a779e36-3986-4b89-9620-51c97eebb952	c986c222-633d-4b87-b1c6-af938fb558e7
566c2436-0248-4ed8-a676-2c50d3600a98	2025-12-24 06:54:28.525498	0eb5c214-2819-4f21-a4b9-ec039ede8247	c986c222-633d-4b87-b1c6-af938fb558e7
ad49052c-589f-4774-8677-044b1f06a33e	2025-12-25 14:42:22.179678	1a5a83a6-8af6-487f-a1ab-9d560244cb98	1abd3aa6-3068-469f-9c45-a38ad7076fdf
8eab4291-14d6-4c37-8e46-3c55fc7eb641	2025-12-25 15:01:13.343058	1a5a83a6-8af6-487f-a1ab-9d560244cb98	2fbff3dd-1da7-472e-9273-c495a1c0b870
9c578c29-5a48-451c-b578-3e1e2b7b4003	2025-12-25 15:01:56.459976	e017871c-ecad-450f-b603-7afb424bcf54	1abd3aa6-3068-469f-9c45-a38ad7076fdf
303fda25-c13c-4f7c-a5ea-2b0795242c2d	2025-12-25 15:36:59.470803	e9382850-257b-4ec3-8f87-71987ade8ac0	2fbff3dd-1da7-472e-9273-c495a1c0b870
b935508e-3d2f-4b8f-8ffc-8244e071f969	2025-12-25 16:58:50.617157	e9382850-257b-4ec3-8f87-71987ade8ac0	c986c222-633d-4b87-b1c6-af938fb558e7
a357af0d-41a9-4277-bfa4-1dd5fa388414	2025-12-25 16:58:57.751185	e017871c-ecad-450f-b603-7afb424bcf54	c986c222-633d-4b87-b1c6-af938fb558e7
\.


--
-- Data for Name: swipe_actions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.swipe_actions (is_mutual, created_at, deleted_at, updated_at, version, actor_id, id, target_id, action_type) FROM stdin;
f	2025-12-13 11:30:01.932034+00	\N	2025-12-13 11:30:01.932034+00	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	61b9802f-0a64-41a8-acdb-08ccb8186b7a	c986c222-633d-4b87-b1c6-af938fb558e7	LIKE
f	2025-12-13 11:30:39.473591+00	\N	2025-12-13 11:30:39.473591+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	c71c07e3-5566-49c7-b3b2-4a84990385e8	2fbff3dd-1da7-472e-9273-c495a1c0b870	LIKE
f	2025-12-15 08:15:30.737488+00	\N	2025-12-15 08:15:30.737488+00	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	f0c6aa31-5a29-4ee8-bb92-290257e38b3a	1abd3aa6-3068-469f-9c45-a38ad7076fdf	SUPERLIKE
f	2025-12-15 16:43:15.287124+00	\N	2025-12-15 16:43:15.287124+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	1aaf36a0-d4de-450f-a933-baacdba95ac0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	LIKE
f	2025-12-17 09:21:26.808776+00	\N	2025-12-17 09:21:26.808776+00	0	3f6ef7ed-8e2f-409a-877e-056971006476	039e5a6f-e408-43d7-a248-78b71dbc04b9	c986c222-633d-4b87-b1c6-af938fb558e7	LIKE
f	2025-12-18 10:08:58.782344+00	\N	2025-12-18 10:08:58.782344+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	42c12081-8022-4895-95d2-9468ac3a2333	3f6ef7ed-8e2f-409a-877e-056971006476	SUPERLIKE
f	2025-12-18 12:29:36.291005+00	\N	2025-12-18 12:29:36.291005+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	75b821de-c370-46b8-809f-bb7e91ba753c	c986c222-633d-4b87-b1c6-af938fb558e7	LIKE
f	2025-12-20 06:34:47.56069+00	\N	2025-12-20 06:34:47.56069+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	37ce1f91-e201-48af-a5d8-8270f5b45b16	05479f65-5810-4a18-8454-3f9eb850157e	LIKE
f	2025-12-20 06:44:51.188571+00	\N	2025-12-20 06:44:51.188571+00	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	960cdae6-686f-40f7-b7b7-90978dfeed66	3f6ef7ed-8e2f-409a-877e-056971006476	LIKE
f	2025-12-20 06:45:07.526919+00	\N	2025-12-20 06:45:07.526919+00	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	dff9f753-5e4c-41d3-a5cf-2aaa1851b8db	05479f65-5810-4a18-8454-3f9eb850157e	LIKE
f	2025-12-20 06:45:13.288632+00	\N	2025-12-20 06:45:13.288632+00	0	05479f65-5810-4a18-8454-3f9eb850157e	b3f924b1-d468-4315-a915-7e589c42e959	c986c222-633d-4b87-b1c6-af938fb558e7	LIKE
\.


--
-- Data for Name: user_activity_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_activity_logs (id, user_id, action_type, target_type, target_id, metadata, session_id, device_type, created_at) FROM stdin;
\.


--
-- Data for Name: user_blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_blocks (id, blocker_id, blocked_id, reason, created_at) FROM stdin;
\.


--
-- Data for Name: user_followers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_followers (muted, created_at, deleted_at, updated_at, version, follower_id, id, user_id) FROM stdin;
f	2025-12-13 09:05:46.398989+00	\N	2025-12-13 09:05:46.398989+00	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	88d089e8-68d3-41f7-afa7-6457c49f7838	c986c222-633d-4b87-b1c6-af938fb558e7
f	2025-12-13 09:06:37.291513+00	\N	2025-12-13 09:06:37.291513+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	728926a8-6598-4c35-acb9-270e9cdb869e	2fbff3dd-1da7-472e-9273-c495a1c0b870
f	2025-12-15 09:32:26.624064+00	\N	2025-12-15 09:32:26.624064+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	34d5b575-9bd2-4736-873d-819b7997b440	2fbff3dd-1da7-472e-9273-c495a1c0b870
f	2025-12-15 09:32:44.7522+00	\N	2025-12-15 09:32:44.7522+00	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	71a13954-dc0a-430e-b93c-05f6f467216d	1abd3aa6-3068-469f-9c45-a38ad7076fdf
f	2025-12-17 08:23:03.165811+00	\N	2025-12-17 08:23:03.165811+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	08ab78c7-003a-457e-8358-7414ad4491a1	1abd3aa6-3068-469f-9c45-a38ad7076fdf
f	2025-12-17 09:19:34.114357+00	\N	2025-12-17 09:19:34.114357+00	0	3f6ef7ed-8e2f-409a-877e-056971006476	d5b4f6da-d508-4688-935a-5f8a608604b2	c986c222-633d-4b87-b1c6-af938fb558e7
f	2025-12-18 13:18:17.688556+00	\N	2025-12-18 13:18:17.688556+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	75bf948a-3bd3-474f-81bf-419a7bfd2a0e	c986c222-633d-4b87-b1c6-af938fb558e7
f	2025-12-19 07:28:06.536394+00	\N	2025-12-19 07:28:06.536394+00	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	0f7fa1c9-ae29-47a9-a22b-650964445284	05479f65-5810-4a18-8454-3f9eb850157e
f	2025-12-19 07:47:45.63061+00	\N	2025-12-19 07:47:45.63061+00	0	05479f65-5810-4a18-8454-3f9eb850157e	7d463700-35ea-4e74-8cd6-9a49575524e4	3f6ef7ed-8e2f-409a-877e-056971006476
f	2025-12-19 07:47:57.330143+00	\N	2025-12-19 07:47:57.330143+00	0	05479f65-5810-4a18-8454-3f9eb850157e	821385ad-6c0c-4c8f-9d75-c9e03e85419c	c986c222-633d-4b87-b1c6-af938fb558e7
f	2025-12-19 07:50:55.979321+00	\N	2025-12-19 07:50:55.979321+00	0	3f6ef7ed-8e2f-409a-877e-056971006476	1fa2a3d4-051d-4129-b27a-2127d85f0e02	1abd3aa6-3068-469f-9c45-a38ad7076fdf
f	2025-12-19 07:52:16.33863+00	\N	2025-12-19 07:52:16.33863+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	ebb71b4b-ae03-415c-958c-a320a1c3e2e8	05479f65-5810-4a18-8454-3f9eb850157e
f	2025-12-20 08:27:03.224393+00	\N	2025-12-20 08:27:03.224393+00	0	05479f65-5810-4a18-8454-3f9eb850157e	4c737efe-f0d1-4414-9222-f63210a78c0f	1abd3aa6-3068-469f-9c45-a38ad7076fdf
f	2025-12-20 09:10:56.440202+00	\N	2025-12-20 09:10:56.440202+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	8c487c00-d4bd-4c25-84e7-637457b98785	05479f65-5810-4a18-8454-3f9eb850157e
f	2025-12-25 17:00:40.854231+00	\N	2025-12-25 17:00:40.854231+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	4c24c209-01cb-41d0-89c9-870b90cd0dc6	9ef82fed-3a9c-4087-ab31-c47682ed420e
\.


--
-- Data for Name: user_login_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_login_history (success, created_at, deleted_at, updated_at, version, id, user_id, ip_address, user_agent) FROM stdin;
\.


--
-- Data for Name: user_photos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_photos (id, user_id, photo_url, thumbnail_url, display_order, is_primary, is_verified, caption, created_at) FROM stdin;
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles (created_at, deleted_at, updated_at, version, id, user_id, bio, avatar_object_key, location, website, reputation_score, date_of_birth, education_level, gender, total_meets_cancelled, total_meets_completed, total_no_shows) FROM stdin;
2025-12-17 09:19:27.374198+00	\N	2025-12-17 09:20:43.373953+00	1	4292810a-fbbe-4779-a2b4-8d40250ef3df	3f6ef7ed-8e2f-409a-877e-056971006476	\N	47dd3430-126d-4a25-9d1b-b61901cbb8c3-scaled_avatars-MT0IyH3myhQfz3vo-h4BUsw-t240x240.jpg	\N	\N	100	\N	\N	\N	\N	\N	\N
2025-12-15 08:14:52.803191+00	\N	2025-12-18 16:56:10.274898+00	3	0f0de6cf-e641-45c1-8627-82a331c3c976	1abd3aa6-3068-469f-9c45-a38ad7076fdf	1+1=3	2c80dfa5-0f44-4114-b2bc-cb31aa65cc22-scaled_420198238_122125069352055338_176253627461992973_n.jpg	Đà Nẵng	\N	100	2000-01-12	UNIVERSITY	MALE	\N	\N	\N
2025-12-13 09:05:36.527011+00	\N	2025-12-20 06:32:50.066603+00	2	8f674efe-ed89-4810-8e93-8020c66bbb5b	2fbff3dd-1da7-472e-9273-c495a1c0b870	rich people	ff8eccf9-0f3a-42b7-bcd3-422430a4645b-scaled_obsidian-rpeview.png	Hà Nội	\N	100	2000-01-18	POSTGRADUATE	FEMALE	\N	\N	\N
2025-12-19 07:26:17.777432+00	\N	2025-12-20 06:34:38.28142+00	2	b820d96e-112b-400f-be45-fbd5304e283b	05479f65-5810-4a18-8454-3f9eb850157e	fun people	ae7c2478-b5d2-4efd-aebb-8ad24d426174-scaled_anh-meme-tien-hai-huoc_093840868.jpg	Hải Phòng	\N	100	2000-01-04	COLLEGE	MALE	\N	\N	\N
2025-12-13 09:04:35.858605+00	\N	2025-12-22 06:43:47.894184+00	7	135858d9-cede-424a-812a-43683e5470c8	c986c222-633d-4b87-b1c6-af938fb558e7	\N	416e41eb-6b77-4563-ba31-3a406e139e47-scaled_IMG_1615.jpg	\N	\N	94	\N	\N	\N	\N	\N	\N
2025-12-25 08:56:49.760036+00	\N	2025-12-25 08:56:49.760036+00	0	d2999f18-8ef4-4af0-a8b2-d7f0e047af5a	ab989483-cd2e-4073-b4d5-4ecdf42145c9	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 09:05:51.63799+00	\N	2025-12-25 09:05:51.63799+00	0	e6deae93-4b4d-4be6-aac4-bb1dd005d106	823fa1ff-3faa-4de9-9a4a-967dca7bc3a1	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 09:28:06.953393+00	\N	2025-12-25 09:28:06.953393+00	0	a769fcfa-a7bc-4e7e-abf6-335f4cdb2442	f90d4c06-f080-412d-b231-89b0f982e854	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 09:36:38.63223+00	\N	2025-12-25 09:36:38.63223+00	0	785875e8-7a2a-4f5c-bc19-a85570331596	ffbcb60a-8c13-4f85-a207-6b0e02275263	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 09:41:30.329552+00	\N	2025-12-25 09:41:30.329552+00	0	0d09e44e-b568-4e0a-9120-0dcadf0392b7	7b61e3d5-51aa-4759-aa7f-a98aabc03d1e	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 09:51:54.045942+00	\N	2025-12-25 09:51:54.045942+00	0	3b09cae1-45cf-4571-8dd2-6d16cdf67f88	ee4d208b-ff87-4ef8-92fe-ee828a09f67f	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 10:09:51.072512+00	\N	2025-12-25 10:09:51.072512+00	0	a828d4d8-8228-404e-97b1-67a4251aaef2	4d96d3dd-d27d-4b82-a884-7b35e2d21fee	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 10:15:30.769895+00	\N	2025-12-25 10:15:30.769895+00	0	99ec7adc-ce5b-4236-bffa-f0db7f6ca91a	504e5fbc-e4f9-462a-b239-c2b436fc240b	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 10:48:36.764419+00	\N	2025-12-25 10:48:36.764419+00	0	b2b60121-e7c2-4171-96b1-ff4328996a09	81c86022-9d60-478d-85ae-3d8002dd4075	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 10:54:27.16646+00	\N	2025-12-25 10:54:27.16646+00	0	b81bc6d0-6a4e-4cd9-9ae3-26f5d1cc1ae2	0283b0e4-9c5c-4300-aa0f-0af03bc46954	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
2025-12-25 16:57:17.999374+00	\N	2025-12-25 16:57:17.999374+00	0	ed0eeb4d-adfb-43b2-813e-8487b5c513ae	9ef82fed-3a9c-4087-ab31-c47682ed420e	\N	\N	\N	\N	100	\N	\N	\N	0	0	0
\.


--
-- Data for Name: user_profiles_extended; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles_extended (date_of_birth, is_online, is_verified, location_approximate, location_lat, location_lng, max_distance_km, preferred_age_max, preferred_age_min, profile_completeness, reputation_score, total_reviews, verification_level, created_at, deleted_at, last_active_at, updated_at, verified_at, version, id, user_id, company, diet, drinking, education, education_level, exercise_frequency, gender, gender_identity, location_city, location_country, location_district, occupation, personality_type, pronouns, relationship_status, smoking, timezone, available_days, available_time_slots, interests, languages, looking_for, pets, preferred_genders) FROM stdin;
\.


--
-- Data for Name: user_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_reports (id, reporter_id, reported_user_id, reason, description, evidence_urls, context_type, context_id, status, priority, assigned_to, reviewed_at, reviewed_by, resolution_notes, action_taken, created_at, resolved_at) FROM stdin;
\.


--
-- Data for Name: user_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_settings (allow_messages, email_notifications, is_private, push_notifications, created_at, deleted_at, updated_at, version, id, user_id) FROM stdin;
t	t	f	t	2025-12-13 09:04:35.869087+00	\N	2025-12-13 09:04:35.869087+00	0	cc867cef-dda2-4973-a2e1-c9dcbe94f124	c986c222-633d-4b87-b1c6-af938fb558e7
t	t	f	t	2025-12-13 09:05:36.528713+00	\N	2025-12-13 09:05:36.528713+00	0	b38f863e-c6fb-4562-9421-525ede59dd3d	2fbff3dd-1da7-472e-9273-c495a1c0b870
t	t	f	t	2025-12-15 08:14:52.808351+00	\N	2025-12-15 08:14:52.808351+00	0	1cee5fc2-585a-443c-b271-1a4c075d2b5a	1abd3aa6-3068-469f-9c45-a38ad7076fdf
t	t	f	t	2025-12-17 09:19:27.376007+00	\N	2025-12-17 09:19:27.376007+00	0	bd7890cd-f7ed-4e0b-93f3-5173cd2a70c7	3f6ef7ed-8e2f-409a-877e-056971006476
t	t	f	t	2025-12-19 07:26:17.77814+00	\N	2025-12-19 07:26:17.77814+00	0	4c73c0d4-f6dc-4425-a213-d712a69cdc78	05479f65-5810-4a18-8454-3f9eb850157e
t	t	f	t	2025-12-25 08:56:49.762711+00	\N	2025-12-25 08:56:49.762711+00	0	e9d8753d-b540-4706-8197-91956f2bc18f	ab989483-cd2e-4073-b4d5-4ecdf42145c9
t	t	f	t	2025-12-25 09:05:51.638206+00	\N	2025-12-25 09:05:51.638206+00	0	9657453b-6181-477f-8863-5d29d8c79bbc	823fa1ff-3faa-4de9-9a4a-967dca7bc3a1
t	t	f	t	2025-12-25 09:28:06.953997+00	\N	2025-12-25 09:28:06.953997+00	0	dd93244d-ce64-49bf-b6f9-c1cab0d2074e	f90d4c06-f080-412d-b231-89b0f982e854
t	t	f	t	2025-12-25 09:36:38.632772+00	\N	2025-12-25 09:36:38.632772+00	0	b93a7256-e584-432e-acf3-4762303aba9a	ffbcb60a-8c13-4f85-a207-6b0e02275263
t	t	f	t	2025-12-25 09:41:30.330118+00	\N	2025-12-25 09:41:30.330118+00	0	bb382a31-becd-4a1e-888d-62f317763e85	7b61e3d5-51aa-4759-aa7f-a98aabc03d1e
t	t	f	t	2025-12-25 09:51:54.046243+00	\N	2025-12-25 09:51:54.046243+00	0	32cf1c54-2320-4387-b0e6-5615a9119a45	ee4d208b-ff87-4ef8-92fe-ee828a09f67f
t	t	f	t	2025-12-25 10:09:51.073134+00	\N	2025-12-25 10:09:51.073134+00	0	ed1e368b-57f5-4419-8849-9193ece6305e	4d96d3dd-d27d-4b82-a884-7b35e2d21fee
t	t	f	t	2025-12-25 10:15:30.77141+00	\N	2025-12-25 10:15:30.77141+00	0	10062ce9-7904-4a60-ae96-5aaba5070cb1	504e5fbc-e4f9-462a-b239-c2b436fc240b
t	t	f	t	2025-12-25 10:48:36.766495+00	\N	2025-12-25 10:48:36.766495+00	0	c4968537-8af2-4e4f-b032-3947e0f5c65c	81c86022-9d60-478d-85ae-3d8002dd4075
t	t	f	t	2025-12-25 10:54:27.172259+00	\N	2025-12-25 10:54:27.172259+00	0	f87120bc-1806-40e8-b4fc-1053a017e8bd	0283b0e4-9c5c-4300-aa0f-0af03bc46954
t	t	f	t	2025-12-25 16:57:18.002436+00	\N	2025-12-25 16:57:18.002436+00	0	cef31230-97aa-47f4-a624-1435f289a95e	9ef82fed-3a9c-4087-ab31-c47682ed420e
\.


--
-- Data for Name: user_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_stats (id, user_id, total_connections, friends_count, romantic_connections, activity_partners, events_created, events_joined, events_completed, events_cancelled, events_no_show, groups_joined, groups_created, reviews_given, reviews_received, average_rating, reports_received, blocks_received, warnings_received, profile_views, messages_sent, match_rate, updated_at) FROM stdin;
\.


--
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tokens (revoked, created_at, deleted_at, expires_at, updated_at, version, id, user_id, refresh_token, ip_address, user_agent) FROM stdin;
f	2025-12-13 09:04:35.956922+00	\N	2025-12-20 09:04:35.941718+00	2025-12-13 09:04:35.956922+00	0	ce020be1-03fe-4210-a58c-1789127100bc	c986c222-633d-4b87-b1c6-af938fb558e7	be1ec946-2b23-4064-84c6-140f516df455	\N	\N
f	2025-12-13 09:05:36.532906+00	\N	2025-12-20 09:05:36.531126+00	2025-12-13 09:05:36.532906+00	0	34892afe-bc77-4df0-a75b-3b5f7cd71b23	2fbff3dd-1da7-472e-9273-c495a1c0b870	c0c70bfa-4bf1-49d7-8f7e-a4cb4fa3b77f	\N	\N
f	2025-12-13 16:17:11.257286+00	\N	2025-12-20 16:17:11.239342+00	2025-12-13 16:17:11.257286+00	0	e17e9a81-e4f1-4bce-a9e3-97d9fd364dd7	2fbff3dd-1da7-472e-9273-c495a1c0b870	40ce6e5e-dbdf-441c-b156-f5a1ffc343a3	\N	\N
f	2025-12-15 06:30:15.868342+00	\N	2025-12-22 06:30:15.724126+00	2025-12-15 06:30:15.868342+00	0	1867836e-a17c-4331-a778-036347fcfd53	c986c222-633d-4b87-b1c6-af938fb558e7	db358ae8-2460-45d2-a405-cd015fad98e9	\N	\N
f	2025-12-15 06:30:18.865713+00	\N	2025-12-22 06:30:18.864537+00	2025-12-15 06:30:18.865713+00	0	67cf668e-2cf8-408c-a08f-65af10778398	2fbff3dd-1da7-472e-9273-c495a1c0b870	db26239d-5a4e-4e01-a438-cee6813d11ef	\N	\N
f	2025-12-15 06:32:13.18927+00	\N	2025-12-22 06:32:13.184903+00	2025-12-15 06:32:13.18927+00	0	61a0ddb2-62dc-401e-beb2-1c2325e91f71	2fbff3dd-1da7-472e-9273-c495a1c0b870	c2a929b5-b784-45ea-99b4-b27c5579d794	\N	\N
f	2025-12-15 06:52:31.423946+00	\N	2025-12-22 06:52:31.28171+00	2025-12-15 06:52:31.423946+00	0	6df4b5e8-9dd4-4e63-b42d-d3ab2ddf1d2e	2fbff3dd-1da7-472e-9273-c495a1c0b870	476f7d23-e15f-4dda-8135-fcb144063b7b	\N	\N
f	2025-12-15 06:53:12.821571+00	\N	2025-12-22 06:53:12.819296+00	2025-12-15 06:53:12.821571+00	0	d7cba8f1-6941-4d5e-a02c-b1f6c260e16b	c986c222-633d-4b87-b1c6-af938fb558e7	6a2246b6-e9c6-4c02-8481-190cbc6bb732	\N	\N
f	2025-12-15 08:14:52.856946+00	\N	2025-12-22 08:14:52.851444+00	2025-12-15 08:14:52.856946+00	0	ca238316-ca85-4526-8749-56339abff848	1abd3aa6-3068-469f-9c45-a38ad7076fdf	4a68c1ae-117b-4a3f-a03e-68389437c8c8	\N	\N
f	2025-12-16 07:13:02.432047+00	\N	2025-12-23 07:13:02.393559+00	2025-12-16 07:13:02.432047+00	0	f6b0f896-e952-47f4-b70f-2cd523ae83fc	c986c222-633d-4b87-b1c6-af938fb558e7	6fb96400-3c6a-47ff-ade5-cebf283e03a2	\N	\N
f	2025-12-17 05:54:54.324198+00	\N	2025-12-24 05:54:54.21107+00	2025-12-17 05:54:54.324198+00	0	3ecba923-b74d-4d67-856b-2a06db85533e	1abd3aa6-3068-469f-9c45-a38ad7076fdf	5004e10c-350c-418e-98bf-a0eca3e90464	\N	\N
f	2025-12-17 08:21:16.033128+00	\N	2025-12-24 08:21:16.013442+00	2025-12-17 08:21:16.033128+00	0	31a9820a-ae77-4cc2-be4a-c1cbb3b399b1	c986c222-633d-4b87-b1c6-af938fb558e7	95aeae6c-77e1-43f4-a0ae-602311aa6fce	\N	\N
f	2025-12-17 09:19:27.433763+00	\N	2025-12-24 09:19:27.429168+00	2025-12-17 09:19:27.433763+00	0	e0e363ec-5c2e-4f88-82d4-7100bd0a33d9	3f6ef7ed-8e2f-409a-877e-056971006476	3b886ea7-ed6d-4c16-bc4a-c98f86bea483	\N	\N
f	2025-12-18 06:29:43.934693+00	\N	2025-12-25 06:29:43.883497+00	2025-12-18 06:29:43.934693+00	0	4da24495-8863-47c7-97aa-3fd2460160f6	1abd3aa6-3068-469f-9c45-a38ad7076fdf	13ed47ac-cf5d-4fb5-8cba-e856d723dd35	\N	\N
f	2025-12-18 07:29:18.934218+00	\N	2025-12-25 07:29:18.929375+00	2025-12-18 07:29:18.934218+00	0	c5ebfb16-7176-458c-bbad-8f637bf88309	c986c222-633d-4b87-b1c6-af938fb558e7	f271dddf-5029-42b4-a5ab-d9f67f719297	\N	\N
f	2025-12-18 10:08:33.883086+00	\N	2025-12-25 10:08:33.864991+00	2025-12-18 10:08:33.883086+00	0	da7bd401-0905-4ebd-83af-2b2344b4f613	c986c222-633d-4b87-b1c6-af938fb558e7	f6854dab-2a12-490b-b05b-7bb18e93ecfa	\N	\N
f	2025-12-19 05:22:05.688393+00	\N	2025-12-26 05:22:05.569441+00	2025-12-19 05:22:05.688393+00	0	51802764-aa92-4ae8-80ff-2b752444f564	c986c222-633d-4b87-b1c6-af938fb558e7	6fd1019c-0c76-4e48-a304-d073b8253382	\N	\N
f	2025-12-19 07:01:59.410387+00	\N	2025-12-26 07:01:59.383085+00	2025-12-19 07:01:59.410387+00	0	b661d43c-86b2-4b6e-9261-317f5dc72ee0	c986c222-633d-4b87-b1c6-af938fb558e7	231f8e0f-ba12-4305-9faa-efc8cc27bae4	\N	\N
t	2025-12-19 07:02:18.504794+00	\N	2025-12-26 07:02:18.504033+00	2025-12-19 07:25:36.583576+00	1	29c94adc-2a15-4377-b89a-fcec9792f191	1abd3aa6-3068-469f-9c45-a38ad7076fdf	da04d810-9fee-4fd5-b5d7-30b5d2cfea13	\N	\N
f	2025-12-19 07:26:17.869677+00	\N	2025-12-26 07:26:17.868655+00	2025-12-19 07:26:17.869677+00	0	8ffae64a-335e-4f29-ab43-a77f70949792	05479f65-5810-4a18-8454-3f9eb850157e	9ce23f71-fce3-47d4-9b39-01ccad122a3c	\N	\N
t	2025-12-19 07:19:14.895709+00	\N	2025-12-26 07:19:14.857685+00	2025-12-19 07:27:06.647762+00	1	10f03e55-c936-4592-bd58-910147e190a2	c986c222-633d-4b87-b1c6-af938fb558e7	63f6775d-8227-489d-9889-5427f2c26109	\N	\N
t	2025-12-19 07:27:25.707286+00	\N	2025-12-26 07:27:25.705904+00	2025-12-19 07:29:53.93537+00	1	8fbe0d6e-4414-4c2a-9915-3ec6a0baafbb	2fbff3dd-1da7-472e-9273-c495a1c0b870	a4f38976-0fcc-4e5b-910b-ba72aef888c2	\N	\N
t	2025-12-19 07:30:20.124821+00	\N	2025-12-26 07:30:20.099089+00	2025-12-19 07:30:32.065586+00	1	000fa7b6-4a87-4ade-b23b-0b126331a775	1abd3aa6-3068-469f-9c45-a38ad7076fdf	4401d449-7f82-4761-a59c-645f26a05a02	\N	\N
f	2025-12-19 07:43:11.068788+00	\N	2025-12-26 07:43:11.034027+00	2025-12-19 07:43:11.068788+00	0	ce25bec1-aef5-4973-be9c-395ba305190a	c986c222-633d-4b87-b1c6-af938fb558e7	ff3af73b-89a3-4451-97ad-907db3363192	\N	\N
f	2025-12-19 07:46:25.2941+00	\N	2025-12-26 07:46:25.254596+00	2025-12-19 07:46:25.2941+00	0	d2123fc0-cce7-428f-906c-028c4a72c823	c986c222-633d-4b87-b1c6-af938fb558e7	c70c0450-5d40-4e85-9837-5378e89efe9d	\N	\N
f	2025-12-19 07:49:32.600457+00	\N	2025-12-26 07:49:32.599888+00	2025-12-19 07:49:32.600457+00	0	d1663c1d-3975-4235-8cd0-6f9b12acc5b6	1abd3aa6-3068-469f-9c45-a38ad7076fdf	837d3c41-ef50-4cc9-928f-b314d9b037cd	\N	\N
f	2025-12-19 07:50:34.878072+00	\N	2025-12-26 07:50:34.876868+00	2025-12-19 07:50:34.878072+00	0	79896a9c-1ba9-4b8e-8814-5da73761c753	3f6ef7ed-8e2f-409a-877e-056971006476	a48799ad-ba3e-4a37-af38-938ea2ad2861	\N	\N
f	2025-12-20 06:30:12.064804+00	\N	2025-12-27 06:30:12.031163+00	2025-12-20 06:30:12.064804+00	0	6de7d39f-db1f-4e4d-8646-bc3b36ef68cd	c986c222-633d-4b87-b1c6-af938fb558e7	3e45c96f-ca77-43fb-9cde-e7067a2ef677	\N	\N
f	2025-12-20 06:30:38.846919+00	\N	2025-12-27 06:30:38.841797+00	2025-12-20 06:30:38.846919+00	0	1d392516-fbfd-408f-93a9-690581fa0ae2	2fbff3dd-1da7-472e-9273-c495a1c0b870	fc1dd771-308d-4145-9684-6b247c9aa6b2	\N	\N
f	2025-12-20 06:31:22.724423+00	\N	2025-12-27 06:31:22.723374+00	2025-12-20 06:31:22.724423+00	0	b26d6031-cb20-4aff-9c25-4e49683dd718	1abd3aa6-3068-469f-9c45-a38ad7076fdf	40debd04-77ae-4326-a209-cd309dba552c	\N	\N
f	2025-12-20 06:33:52.040362+00	\N	2025-12-27 06:33:52.039295+00	2025-12-20 06:33:52.040362+00	0	93b154db-473d-4a59-9f1e-f63d533ebad0	05479f65-5810-4a18-8454-3f9eb850157e	13fafa46-2bc7-4137-adcd-b1d6a492589d	\N	\N
f	2025-12-20 13:55:51.426778+00	\N	2025-12-27 13:55:51.354724+00	2025-12-20 13:55:51.426778+00	0	21be1747-8af9-4273-94b2-664f6316fac5	1abd3aa6-3068-469f-9c45-a38ad7076fdf	e2d2aade-09c8-4e86-a1e9-cbfc3e96eac2	\N	\N
f	2025-12-20 13:55:51.426777+00	\N	2025-12-27 13:55:51.354665+00	2025-12-20 13:55:51.426777+00	0	6c5414ad-da78-46de-ade4-c73e73b2f89d	c986c222-633d-4b87-b1c6-af938fb558e7	731b2493-c8f9-437c-ba22-af91c3251653	\N	\N
f	2025-12-21 13:42:05.081235+00	\N	2025-12-28 13:42:05.004279+00	2025-12-21 13:42:05.081235+00	0	006f329a-edf5-4c36-90c5-1abbb44a7eef	c986c222-633d-4b87-b1c6-af938fb558e7	2e467926-4827-4fab-a038-5a74a775c997	\N	\N
f	2025-12-21 14:04:38.349223+00	\N	2025-12-28 14:04:38.317504+00	2025-12-21 14:04:38.349223+00	0	b69a0973-d91c-44c6-844a-74ab2e596f11	1abd3aa6-3068-469f-9c45-a38ad7076fdf	b2aca933-2b4d-4fa7-b4cb-ccc4a0a696fc	\N	\N
f	2025-12-22 08:12:13.505259+00	\N	2025-12-29 08:12:13.502689+00	2025-12-22 08:12:13.505259+00	0	9867e768-d012-436e-af93-5753f764458e	2fbff3dd-1da7-472e-9273-c495a1c0b870	69faccc9-55a6-46b0-9208-c4596b25cfac	\N	\N
f	2025-12-22 14:24:58.433194+00	\N	2025-12-29 14:24:58.390806+00	2025-12-22 14:24:58.433194+00	0	94438ff6-6a34-405d-84d6-db7d4c9cf6d1	1abd3aa6-3068-469f-9c45-a38ad7076fdf	9639c44d-281f-4a62-89cd-85625be33040	\N	\N
f	2025-12-22 14:25:01.610975+00	\N	2025-12-29 14:25:01.610036+00	2025-12-22 14:25:01.610975+00	0	8f6aeb8c-3718-4051-b7d5-524fb067d845	c986c222-633d-4b87-b1c6-af938fb558e7	623e250a-9f41-4e05-b950-746b7a492496	\N	\N
f	2025-12-24 06:53:54.946305+00	\N	2025-12-31 06:53:54.94488+00	2025-12-24 06:53:54.946305+00	0	4fdc6423-e00d-44d8-aa36-e9f83a3e8226	c986c222-633d-4b87-b1c6-af938fb558e7	996ad16b-f7e8-4aca-85dd-109a14b63503	\N	\N
t	2025-12-24 06:53:53.952337+00	\N	2025-12-31 06:53:53.899751+00	2025-12-24 08:56:36.239029+00	1	a8e75fcc-17d4-42dc-8bb6-b38b2e875da1	2fbff3dd-1da7-472e-9273-c495a1c0b870	ed9dc8e2-21ab-41ca-b2a0-ab1103215a8d	\N	\N
f	2025-12-24 08:56:42.831031+00	\N	2025-12-31 08:56:42.828784+00	2025-12-24 08:56:42.831031+00	0	95e17ac4-b52b-42b8-8e61-4f33e04cc09c	1abd3aa6-3068-469f-9c45-a38ad7076fdf	8cfc8353-73cd-46f2-bb9c-d2dac29d91d0	\N	\N
f	2025-12-24 10:07:38.319655+00	\N	2025-12-31 10:07:38.30081+00	2025-12-24 10:07:38.319655+00	0	ca2afa36-5399-49bc-920f-a58300bda838	05479f65-5810-4a18-8454-3f9eb850157e	6600d1a8-f31d-4240-924a-2e4601712fa3	\N	\N
f	2025-12-25 08:31:50.179067+00	\N	2026-01-01 08:31:49.821845+00	2025-12-25 08:31:50.179067+00	0	a41404c3-de5d-44db-9702-6559786f5d34	c986c222-633d-4b87-b1c6-af938fb558e7	c3bb5a61-ecfd-4991-9432-906687be38a7	\N	\N
t	2025-12-25 08:21:05.291657+00	\N	2026-01-01 08:21:05.267885+00	2025-12-25 08:47:41.455526+00	1	eb3a5ef7-5664-4b01-9b47-fb066b10ff3e	c986c222-633d-4b87-b1c6-af938fb558e7	b510dfbe-e268-44ed-9ba4-857b5ba67624	\N	\N
t	2025-12-24 08:53:07.209659+00	\N	2025-12-31 08:53:07.172884+00	2025-12-25 09:05:04.31742+00	1	69e10bfb-8d8f-4b59-b842-7a699989f56e	2fbff3dd-1da7-472e-9273-c495a1c0b870	33cc0116-e22a-451d-a626-9cb9aedb4f0d	\N	\N
f	2025-12-25 10:48:37.043759+00	\N	2026-01-01 10:48:37.031544+00	2025-12-25 10:48:37.043759+00	0	54e1d931-d684-4be3-a5c3-81d81a4b0b22	81c86022-9d60-478d-85ae-3d8002dd4075	84391c26-4d7e-49ac-82c0-f6ca6d908314	\N	\N
f	2025-12-25 10:54:27.470989+00	\N	2026-01-01 10:54:27.452039+00	2025-12-25 10:54:27.470989+00	0	64bcf27d-0906-41e2-82cd-f6d8b13958f9	0283b0e4-9c5c-4300-aa0f-0af03bc46954	5408746d-76ab-4fc7-b7ea-d41f5be8f82c	\N	\N
t	2025-12-25 12:00:07.173593+00	\N	2026-01-01 12:00:07.072979+00	2025-12-25 12:01:42.252931+00	1	ad5c1923-de36-4394-ab25-a428f9f685d5	c986c222-633d-4b87-b1c6-af938fb558e7	f4ca1f6c-2d0b-4e8b-8e84-1a5d9c63da80	\N	\N
t	2025-12-25 12:02:22.915516+00	\N	2026-01-01 12:02:22.914551+00	2025-12-25 13:57:19.278513+00	1	8a3c755c-da8a-450e-8104-b4295ceb351a	4d96d3dd-d27d-4b82-a884-7b35e2d21fee	64e393fd-aab1-4797-aece-d480f41ac8ab	\N	\N
t	2025-12-25 12:22:00.175012+00	\N	2026-01-01 12:22:00.168194+00	2025-12-25 15:01:03.601959+00	1	ed9b1773-86d5-4b0e-bbc8-006b9a25b0f8	1abd3aa6-3068-469f-9c45-a38ad7076fdf	46e52240-ab2d-40ff-ba13-b6df1e31b2f2	\N	\N
f	2025-12-25 15:01:09.382466+00	\N	2026-01-01 15:01:09.381786+00	2025-12-25 15:01:09.382466+00	0	3c4a8777-1cab-4a6d-9375-afc87fa93698	2fbff3dd-1da7-472e-9273-c495a1c0b870	559f3825-2983-4034-a380-1ba3df913ff1	\N	\N
t	2025-12-25 14:14:40.123877+00	\N	2026-01-01 14:14:40.120914+00	2025-12-25 16:06:44.215238+00	1	14e30560-aeb1-4672-8e09-80864015202f	1abd3aa6-3068-469f-9c45-a38ad7076fdf	68ce0812-5bc9-48d2-8e39-f17ade42de0d	\N	\N
t	2025-12-25 14:00:28.223713+00	\N	2026-01-01 14:00:28.220274+00	2025-12-25 16:34:05.738144+00	1	9cfa4cad-7559-4062-bea2-5bbde9b5ed0f	c986c222-633d-4b87-b1c6-af938fb558e7	d341b2c2-d9ca-461a-a8e5-60abee464b98	\N	\N
t	2025-12-25 16:06:52.290447+00	\N	2026-01-01 16:06:52.289986+00	2025-12-25 16:32:37.962165+00	1	2fad3a01-f745-4743-a62c-ed11196d5b9e	1abd3aa6-3068-469f-9c45-a38ad7076fdf	ef42d06c-6b6c-4b16-9dca-57332822dd18	\N	\N
f	2025-12-25 16:57:18.005441+00	\N	2026-01-01 16:57:18.004526+00	2025-12-25 16:57:18.005441+00	0	c226516d-9e50-4f54-b2c5-b316ef865459	9ef82fed-3a9c-4087-ab31-c47682ed420e	d5eb1ac8-abea-4a3d-bdd4-7b8b24f7b697	\N	\N
f	2025-12-25 16:58:43.39105+00	\N	2026-01-01 16:58:43.390026+00	2025-12-25 16:58:43.39105+00	0	3b1886cb-f657-42ad-9763-d3d0c0cab2b7	c986c222-633d-4b87-b1c6-af938fb558e7	e5df1f46-737d-4604-8306-d8dfe689e384	\N	\N
f	2025-12-25 17:12:29.824402+00	\N	2026-01-01 17:12:29.784868+00	2025-12-25 17:12:29.824402+00	0	7fbe2e1d-c9b4-4245-8b48-ac9a328c8011	c986c222-633d-4b87-b1c6-af938fb558e7	5b85a6e8-7d7a-48f7-8161-ca714d283964	\N	\N
t	2025-12-25 16:47:49.837387+00	\N	2026-01-01 16:47:49.688067+00	2025-12-25 17:16:31.110781+00	1	e4235bd2-8ab6-4afd-90b8-dc002256af37	e461f255-82ff-4bc4-8a16-09e169d7407b	1b01d24b-fd17-4b29-b3d9-24fa14967501	\N	\N
f	2025-12-25 17:16:42.761588+00	\N	2026-01-01 17:16:42.759661+00	2025-12-25 17:16:42.761588+00	0	213194a5-447f-46bd-98a2-6e2794af6848	e461f255-82ff-4bc4-8a16-09e169d7407b	8d2b872d-4635-413b-8e30-b38a45587c65	\N	\N
t	2025-12-25 17:06:30.339177+00	\N	2026-01-01 17:06:30.338624+00	2025-12-25 17:18:04.345514+00	1	3ac85283-059f-48fa-85ca-499cafdd8335	2fbff3dd-1da7-472e-9273-c495a1c0b870	82f1b1cb-87f0-48f7-aa44-07ae4a0f21cc	\N	\N
f	2025-12-25 17:18:20.891157+00	\N	2026-01-01 17:18:20.890572+00	2025-12-25 17:18:20.891157+00	0	96146063-c38b-46f2-8ee4-5336d8ad0610	e461f255-82ff-4bc4-8a16-09e169d7407b	9c79edd1-cd96-4fb4-9ba1-7fd4b9cc778f	\N	\N
t	2025-12-25 18:14:21.834099+00	\N	2026-01-01 18:14:21.815639+00	2025-12-25 18:57:28.372658+00	1	187b4edc-850f-4c50-b7dc-8d66317c4bcf	e461f255-82ff-4bc4-8a16-09e169d7407b	e5913424-509a-4f57-b699-84b290d01c6d	\N	\N
f	2025-12-25 18:59:19.267306+00	\N	2026-01-01 18:59:19.264308+00	2025-12-25 18:59:19.267306+00	0	1a7190e4-ea5a-45f1-bdae-87bba2fe12f9	1abd3aa6-3068-469f-9c45-a38ad7076fdf	159cb2c5-433c-448f-acf7-ca73a8d57821	\N	\N
\.


--
-- Data for Name: user_verifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_verifications (id, user_id, verification_type, verification_data, verified_at, expires_at, is_valid, verified_by, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (created_at, deleted_at, updated_at, version, id, email, full_name, otp, password_hash, phone, status, username, no_show_count, latitude, longitude, role) FROM stdin;
2025-12-13 09:04:35.786513+00	\N	2025-12-13 09:04:35.786513+00	0	c986c222-633d-4b87-b1c6-af938fb558e7	luan@gmail.com	luan	\N	$2a$10$ipmVDRCyLO1QDE0CQxxrEuIIY0v0XUm52POdX3/8ijVzSIVUSE2iy	+84999999999	ACTIVE	luan	\N	\N	\N	USER
2025-12-13 09:05:36.526346+00	\N	2025-12-13 09:05:36.526346+00	0	2fbff3dd-1da7-472e-9273-c495a1c0b870	ss@gmail.com	ss	\N	$2a$10$H5o.Ln6JdO6OsK96biPO.uEfcKSTrLGO29mvwFdVdGv6VKv0AIi9y	+84888888888	ACTIVE	sss	\N	\N	\N	USER
2025-12-15 08:14:52.775268+00	\N	2025-12-15 08:14:52.775268+00	0	1abd3aa6-3068-469f-9c45-a38ad7076fdf	qqq@gmail.com	qqq	\N	$2a$10$W9Uzb.YOuY4Fr50Il6kYeu48Vz389RVXzzKSR2O8TLEZMAQbaj6km	+8488888888	ACTIVE	qqq	\N	\N	\N	USER
2025-12-17 09:19:27.362057+00	\N	2025-12-17 09:19:27.362057+00	0	3f6ef7ed-8e2f-409a-877e-056971006476	rrr@gmail.com	rrr	\N	$2a$10$D4o9p4WAt3C0fS2FfX4ryev2459OUNN0xanR9JdU4IzgWlyqrOzLm	+84898888889	ACTIVE	rrr	\N	\N	\N	USER
2025-12-19 07:26:17.775916+00	\N	2025-12-19 07:26:17.775916+00	0	05479f65-5810-4a18-8454-3f9eb850157e	eee@gmail.com	eee	\N	$2a$10$PNcN5nVaGxhA49wLash34.qlUMsgHw5YGWXaCI97g1MbkN6shi1yi	+84988888888	ACTIVE	eee	\N	\N	\N	USER
2025-12-25 10:48:36.748204+00	\N	2025-12-25 10:48:36.748204+00	0	81c86022-9d60-478d-85ae-3d8002dd4075	amen@gmail.com	emo	\N	$2a$10$8ZbuBhrJFLAQ6MnAnb.WoOnwGjwM8Y5fGWyqE3JGb9u11v9NFgyAW	+84972035610	ACTIVE	emo	0	\N	\N	USER
2025-12-25 08:56:49.738216+00	\N	2025-12-25 08:56:49.738216+00	0	ab989483-cd2e-4073-b4d5-4ecdf42145c9	thailuanpy1234@gmail.com	fff	189313	$2a$10$zm.W.aSWibGRzfp4hKv/7e7qDpYNbo25RDOVA.Rd34hANqAAkmaqG	+8498888888	ACTIVE	fff	0	\N	\N	USER
2025-12-25 09:05:51.637528+00	\N	2025-12-25 09:05:51.637528+00	0	823fa1ff-3faa-4de9-9a4a-967dca7bc3a1	nguyenbaoluanthai@gmail.com	lll	687033	$2a$10$dtu2l9jnL8u5MuyW3bcpNOHp1u8SxpM8GZnf.FI/uM50CIhBVZLOW	+84976454534	ACTIVE	lll	0	\N	\N	USER
2025-12-25 09:28:06.951739+00	\N	2025-12-25 09:28:06.951739+00	0	f90d4c06-f080-412d-b231-89b0f982e854	leehieu355@gmail.com	bbb	800382	$2a$10$Oppp0KB.wsJ4qcSbntuEFO.XWjTSgPsaa4YSodOqDch1S3RFDn69m	+84988855552	ACTIVE	bbb	0	\N	\N	USER
2025-12-25 09:36:38.629509+00	\N	2025-12-25 09:36:38.629509+00	0	ffbcb60a-8c13-4f85-a207-6b0e02275263	my0588257@gmail.com	iii	233285	$2a$10$4lc6QwfYsVsbxv9fA.NjuuDADRk690aESRdEHJfcFYyeGBG7WDLNe	+84895116541	ACTIVE	iii	0	\N	\N	USER
2025-12-25 09:41:30.32866+00	\N	2025-12-25 09:41:30.32866+00	0	7b61e3d5-51aa-4759-aa7f-a98aabc03d1e	sameya73324448@gmail.com	vvv	652757	$2a$10$.SaXV5fGlh5XF4XEPhaVGee/lVU313Z6ZwVrFgTkGQECU5Lbyvbni	+84972031655	ACTIVE	vvv	0	\N	\N	USER
2025-12-25 09:51:54.045115+00	\N	2025-12-25 09:51:54.045115+00	0	ee4d208b-ff87-4ef8-92fe-ee828a09f67f	bilamd633@gmail.com	zzz	514102	$2a$10$sAmmu.CUO8ARH2cVvwazme9kRqtdNbfFm/TPYua1r8XcvTzoLxVvi	+84672031633	ACTIVE	zzz	0	\N	\N	USER
2025-12-25 10:09:51.071695+00	\N	2025-12-25 10:09:51.071695+00	0	4d96d3dd-d27d-4b82-a884-7b35e2d21fee	qkhaitrieu6@gmail.com	mmm	847023	$2a$10$HpWQsj2dl2FaEDyLcF9g2u0cELqtSORV6kgAuo/Jj8UVmvrt5YvMm	+84973031655	ACTIVE	mmm	0	\N	\N	USER
2025-12-25 10:15:30.766332+00	\N	2025-12-25 10:15:30.766332+00	0	504e5fbc-e4f9-462a-b239-c2b436fc240b	ramev47671@arugy.com	www	126158	$2a$10$oc136gh1FAxhkaaECh0MgeqLQq.xRVkBUjWNKaJFwL9gDotOnMOQG	+84971031655	ACTIVE	www	0	\N	\N	USER
2025-12-25 10:54:27.125306+00	\N	2025-12-25 10:54:27.125306+00	0	0283b0e4-9c5c-4300-aa0f-0af03bc46954	alo@gmail.com	alo	\N	$2a$10$2VVS9FE8m5n0xfuM8sb8ru8IirDnP44HSWhubi0wpwJHeFItEiKqS	+84978456123	ACTIVE	alo	0	\N	\N	USER
2025-12-25 16:29:20.10739+00	\N	2025-12-25 16:29:20.10739+00	0	e461f255-82ff-4bc4-8a16-09e169d7407b	admin@fyn.vn	FYN Admin	\N	$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG	\N	ACTIVE	fyn_admin	0	\N	\N	ADMIN
2025-12-25 16:57:17.996835+00	\N	2025-12-25 16:57:17.996835+00	0	9ef82fed-3a9c-4087-ab31-c47682ed420e	loiphan2102004ptl@gmail.com	Phan Thành Lợi	\N	$2a$10$RmHApIB6XNBVE3RJQDKzHukiMTeJNAsFmMbuhgvhDXB5sgkgKlBTq	+84365196582	ACTIVE	loiphan	0	\N	\N	USER
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: postgres
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: admin_action_logs admin_action_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_action_logs
    ADD CONSTRAINT admin_action_logs_pkey PRIMARY KEY (id);


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
-- Name: post_reports post_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_reports
    ADD CONSTRAINT post_reports_pkey PRIMARY KEY (id);


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
-- Name: post_reports fk7ccpkj5jys037f9pq98l31ya2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_reports
    ADD CONSTRAINT fk7ccpkj5jys037f9pq98l31ya2 FOREIGN KEY (post_id) REFERENCES public.posts(id);


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
-- Name: admin_action_logs fkcgp592vydgfp5fruikg0mmnm3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_action_logs
    ADD CONSTRAINT fkcgp592vydgfp5fruikg0mmnm3 FOREIGN KEY (admin_id) REFERENCES public.users(id);


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
-- Name: post_reports fkqi5fmh45u32i63971en0rmrvo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_reports
    ADD CONSTRAINT fkqi5fmh45u32i63971en0rmrvo FOREIGN KEY (reporter_id) REFERENCES public.users(id);


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

\unrestrict REcnVKfCWWdWNqbC01ef8sE6ywAY9ikR5icxANdg2LA0uGpxiCJj5vG87pYcCPP

