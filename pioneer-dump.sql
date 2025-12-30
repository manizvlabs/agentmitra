--
-- PostgreSQL database dump
--

\restrict SdlZBzOi76k3xqe1eTwf0Usxlhrrk7L2OOaMtddhQWa6OcAFRxL4qcU0rR1AQd9

-- Dumped from database version 16.10 (Homebrew)
-- Dumped by pg_dump version 16.10 (Homebrew)

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
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: manish
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO manish;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: flags; Type: TABLE; Schema: public; Owner: manish
--

CREATE TABLE public.flags (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    description text DEFAULT 'No description provided.'::text NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    version integer DEFAULT 1,
    rollout integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT valid_rollout CHECK (((rollout >= 0) AND (rollout <= 100)))
);


ALTER TABLE public.flags OWNER TO manish;

--
-- Name: flags_id_seq; Type: SEQUENCE; Schema: public; Owner: manish
--

CREATE SEQUENCE public.flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.flags_id_seq OWNER TO manish;

--
-- Name: flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: manish
--

ALTER SEQUENCE public.flags_id_seq OWNED BY public.flags.id;


--
-- Name: keys; Type: TABLE; Schema: public; Owner: manish
--

CREATE TABLE public.keys (
    id integer NOT NULL,
    sdk_key character varying(36),
    is_valid boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.keys OWNER TO manish;

--
-- Name: keys_id_seq; Type: SEQUENCE; Schema: public; Owner: manish
--

CREATE SEQUENCE public.keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.keys_id_seq OWNER TO manish;

--
-- Name: keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: manish
--

ALTER SEQUENCE public.keys_id_seq OWNED BY public.keys.id;


--
-- Name: logs; Type: TABLE; Schema: public; Owner: manish
--

CREATE TABLE public.logs (
    id integer NOT NULL,
    flag_id integer NOT NULL,
    title character varying(100) NOT NULL,
    description character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.logs OWNER TO manish;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: manish
--

CREATE SEQUENCE public.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.logs_id_seq OWNER TO manish;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: manish
--

ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;


--
-- Name: flags id; Type: DEFAULT; Schema: public; Owner: manish
--

ALTER TABLE ONLY public.flags ALTER COLUMN id SET DEFAULT nextval('public.flags_id_seq'::regclass);


--
-- Name: keys id; Type: DEFAULT; Schema: public; Owner: manish
--

ALTER TABLE ONLY public.keys ALTER COLUMN id SET DEFAULT nextval('public.keys_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: manish
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);


--
-- Data for Name: flags; Type: TABLE DATA; Schema: public; Owner: manish
--

COPY public.flags (id, title, description, is_active, version, rollout, updated_at, created_at) FROM stdin;
2	CONTAINER_COLOUR_FEATURE	Controls container color in demo	t	1	100	2025-11-27 13:29:03.379551+05:30	2025-11-27 13:29:03.379551+05:30
3	agent_dashboard_enabled	Enable agent dashboard features	t	1	100	2025-11-27 13:29:03.379551+05:30	2025-11-27 13:29:03.379551+05:30
4	whatsapp_integration_enabled	Enable WhatsApp business integration	t	1	100	2025-11-27 13:29:03.379551+05:30	2025-11-27 13:29:03.379551+05:30
6	dashboard_enabled	Enable main dashboard access	t	1	100	2025-11-29 04:26:00.504354+05:30	2025-11-29 04:26:00.504356+05:30
7	login_enabled	Enable login functionality	t	1	100	2025-11-29 04:26:00.517779+05:30	2025-11-29 04:26:00.517782+05:30
8	registration_enabled	Enable user registration	t	1	100	2025-11-29 04:26:00.518446+05:30	2025-11-29 04:26:00.518447+05:30
9	otp_verification_enabled	Enable OTP verification	t	1	100	2025-11-29 04:26:00.519143+05:30	2025-11-29 04:26:00.519145+05:30
1	LOGIN_MICROSERVICE	Redirects users to the login microservice	t	1	0	2025-11-29 09:59:58.215488+05:30	2025-11-27 13:02:28.347346+05:30
5	customer_dashboard_enabled	Enable customer dashboard features	t	1	0	2025-11-29 09:59:58.215488+05:30	2025-11-27 13:29:03.379551+05:30
10	is_test	test flag	t	1	100	2025-12-01 13:17:04.712884+05:30	2025-12-01 13:16:58.898604+05:30
\.


--
-- Data for Name: keys; Type: TABLE DATA; Schema: public; Owner: manish
--

COPY public.keys (id, sdk_key, is_valid, created_at) FROM stdin;
1	test-sdk-key-12345	t	2025-11-27 19:15:23.876169
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: manish
--

COPY public.logs (id, flag_id, title, description, created_at) FROM stdin;
1	1	LOGIN_MICROSERVICE	Created new flag: LOGIN_MICROSERVICE	2025-11-27 13:02:28.34882+05:30
2	10	is_test	Flag created.	2025-12-01 13:16:58.993334+05:30
3	10	is_test	Flag is_test toggled on	2025-12-01 13:17:04.918492+05:30
\.


--
-- Name: flags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: manish
--

SELECT pg_catalog.setval('public.flags_id_seq', 14, true);


--
-- Name: keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: manish
--

SELECT pg_catalog.setval('public.keys_id_seq', 1, true);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: manish
--

SELECT pg_catalog.setval('public.logs_id_seq', 3, true);


--
-- Name: flags flags_pkey; Type: CONSTRAINT; Schema: public; Owner: manish
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (id);


--
-- Name: flags flags_title_key; Type: CONSTRAINT; Schema: public; Owner: manish
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_title_key UNIQUE (title);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: manish
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: flags tg_flags_updated_at; Type: TRIGGER; Schema: public; Owner: manish
--

CREATE TRIGGER tg_flags_updated_at BEFORE UPDATE ON public.flags FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO pioneer;


--
-- Name: TABLE flags; Type: ACL; Schema: public; Owner: manish
--

GRANT ALL ON TABLE public.flags TO pioneer;


--
-- Name: SEQUENCE flags_id_seq; Type: ACL; Schema: public; Owner: manish
--

GRANT SELECT,USAGE ON SEQUENCE public.flags_id_seq TO pioneer;


--
-- Name: TABLE keys; Type: ACL; Schema: public; Owner: manish
--

GRANT ALL ON TABLE public.keys TO pioneer;


--
-- Name: SEQUENCE keys_id_seq; Type: ACL; Schema: public; Owner: manish
--

GRANT SELECT,USAGE ON SEQUENCE public.keys_id_seq TO pioneer;


--
-- Name: TABLE logs; Type: ACL; Schema: public; Owner: manish
--

GRANT ALL ON TABLE public.logs TO pioneer;


--
-- Name: SEQUENCE logs_id_seq; Type: ACL; Schema: public; Owner: manish
--

GRANT SELECT,USAGE ON SEQUENCE public.logs_id_seq TO pioneer;


--
-- PostgreSQL database dump complete
--

\unrestrict SdlZBzOi76k3xqe1eTwf0Usxlhrrk7L2OOaMtddhQWa6OcAFRxL4qcU0rR1AQd9

