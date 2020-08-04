--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3 (Ubuntu 12.3-1.pgdg18.04+1)
-- Dumped by pg_dump version 12.3 (Ubuntu 12.3-1.pgdg18.04+1)

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
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


--
-- Name: get_week_report(date); Type: FUNCTION; Schema: public; Owner: max
--

CREATE FUNCTION public.get_week_report(input_date date) RETURNS TABLE(office_id integer, mon integer, tue integer, wed integer, thu integer, fri integer, sat integer, sun integer, total integer)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    start_week_date DATE := DATE_TRUNC('week', input_date)::DATE;
    end_week_date DATE := DATE_TRUNC('week', input_date)::DATE + INTERVAL '6 days';
BEGIN
    RETURN QUERY
    SELECT * 
    FROM crosstab(
        $$WITH cte AS(
            SELECT mcio.office_id, 
                   EXTRACT(isodow FROM rmcs.rented_at) AS week_day, 
                   COUNT(*) AS rented_movies 
            FROM movie_copy_in_office AS mcio 
                 INNER JOIN rented_movie_copy_status AS rmcs 
                 ON mcio.id = rmcs.id_movie_copy_in_office 
                   AND rmcs.rented_at::DATE 
                     BETWEEN $$ || QUOTE_LITERAL(start_week_date) || $$ AND $$ || QUOTE_LITERAL(end_week_date) ||
            $$GROUP BY 1, 2
            )
          TABLE cte
          UNION ALL
          SELECT office_id, 999 AS week_day, SUM(rented_movies) AS rented_movies
          FROM cte
          GROUP BY 1
          ORDER BY 1$$,
        $$VALUES (1), (2), (3), (4), (5), (6), (7), (999)$$
    ) AS (office_id int, 
          "Mon" int, 
          "Tue" int, 
          "Wed" int, 
          "Thu" int, 
          "Fri" int, 
          "Sat" int, 
          "Sun" int, 
          "Total" int);
END
$_$;


ALTER FUNCTION public.get_week_report(input_date date) OWNER TO max;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actor; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.actor (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    patronym character varying(50),
    biography text NOT NULL,
    birthday date NOT NULL,
    date_of_death date,
    has_oscar boolean NOT NULL,
    country_id integer NOT NULL
);


ALTER TABLE public.actor OWNER TO max;

--
-- Name: actor_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.actor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.actor_id_seq OWNER TO max;

--
-- Name: actor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.actor_id_seq OWNED BY public.actor.id;


--
-- Name: country; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.country (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.country OWNER TO max;

--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.country_id_seq OWNER TO max;

--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.country_id_seq OWNED BY public.country.id;


--
-- Name: customer; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.customer (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    patronym character varying(50),
    address character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    country_id integer NOT NULL
);


ALTER TABLE public.customer OWNER TO max;

--
-- Name: customer_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customer_id_seq OWNER TO max;

--
-- Name: customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.customer_id_seq OWNED BY public.customer.id;


--
-- Name: department; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.department (
    id integer NOT NULL,
    office_id integer NOT NULL
);


ALTER TABLE public.department OWNER TO max;

--
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_id_seq OWNER TO max;

--
-- Name: department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.department_id_seq OWNED BY public.department.id;


--
-- Name: employee; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.employee (
    id integer NOT NULL,
    department_id integer,
    rank_id integer NOT NULL,
    country_id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    patronym character varying(50),
    address character varying(100) NOT NULL,
    avatar bytea,
    salary integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    hired_date timestamp without time zone DEFAULT now() NOT NULL,
    office_id integer NOT NULL
);


ALTER TABLE public.employee OWNER TO max;

--
-- Name: employee_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_id_seq OWNER TO max;

--
-- Name: employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.employee_id_seq OWNED BY public.employee.id;


--
-- Name: genre; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.genre (
    id integer NOT NULL,
    name character varying(50)
);


ALTER TABLE public.genre OWNER TO max;

--
-- Name: genre_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.genre_id_seq OWNER TO max;

--
-- Name: genre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.genre_id_seq OWNED BY public.genre.id;


--
-- Name: language; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.language (
    id integer NOT NULL,
    name character varying(50)
);


ALTER TABLE public.language OWNER TO max;

--
-- Name: language_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.language_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.language_id_seq OWNER TO max;

--
-- Name: language_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.language_id_seq OWNED BY public.language.id;


--
-- Name: movie; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.movie (
    id integer NOT NULL,
    name character varying(75) NOT NULL,
    release_year smallint NOT NULL,
    description text NOT NULL,
    running_time smallint NOT NULL
);


ALTER TABLE public.movie OWNER TO max;

--
-- Name: movie_actor_m2m; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.movie_actor_m2m (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    actor_id integer NOT NULL
);


ALTER TABLE public.movie_actor_m2m OWNER TO max;

--
-- Name: movie_actor_m2m_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.movie_actor_m2m_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_actor_m2m_id_seq OWNER TO max;

--
-- Name: movie_actor_m2m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.movie_actor_m2m_id_seq OWNED BY public.movie_actor_m2m.id;


--
-- Name: movie_copy_in_office; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.movie_copy_in_office (
    id integer NOT NULL,
    office_id integer NOT NULL,
    movie_id integer NOT NULL,
    amount integer NOT NULL
);


ALTER TABLE public.movie_copy_in_office OWNER TO max;

--
-- Name: movie_copy_in_office_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.movie_copy_in_office_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_copy_in_office_id_seq OWNER TO max;

--
-- Name: movie_copy_in_office_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.movie_copy_in_office_id_seq OWNED BY public.movie_copy_in_office.id;


--
-- Name: movie_country_m2m; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.movie_country_m2m (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    country_id integer NOT NULL
);


ALTER TABLE public.movie_country_m2m OWNER TO max;

--
-- Name: movie_country_m2m_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.movie_country_m2m_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_country_m2m_id_seq OWNER TO max;

--
-- Name: movie_country_m2m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.movie_country_m2m_id_seq OWNED BY public.movie_country_m2m.id;


--
-- Name: movie_genre_m2m; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.movie_genre_m2m (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE public.movie_genre_m2m OWNER TO max;

--
-- Name: movie_genre_m2m_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.movie_genre_m2m_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_genre_m2m_id_seq OWNER TO max;

--
-- Name: movie_genre_m2m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.movie_genre_m2m_id_seq OWNED BY public.movie_genre_m2m.id;


--
-- Name: movie_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.movie_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_id_seq OWNER TO max;

--
-- Name: movie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.movie_id_seq OWNED BY public.movie.id;


--
-- Name: movie_language_m2m; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.movie_language_m2m (
    id integer NOT NULL,
    movie_id integer NOT NULL,
    language_id integer NOT NULL
);


ALTER TABLE public.movie_language_m2m OWNER TO max;

--
-- Name: movie_language_m2m_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.movie_language_m2m_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_language_m2m_id_seq OWNER TO max;

--
-- Name: movie_language_m2m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.movie_language_m2m_id_seq OWNED BY public.movie_language_m2m.id;


--
-- Name: movie_rating_in_office; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.movie_rating_in_office (
    id integer NOT NULL,
    office_id integer NOT NULL,
    customer_id integer NOT NULL,
    movie_id integer NOT NULL,
    value smallint,
    CONSTRAINT movie_rating_in_office_value_check CHECK (((value >= 1) AND (value <= 5)))
);


ALTER TABLE public.movie_rating_in_office OWNER TO max;

--
-- Name: movie_rating_in_office_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.movie_rating_in_office_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_rating_in_office_id_seq OWNER TO max;

--
-- Name: movie_rating_in_office_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.movie_rating_in_office_id_seq OWNED BY public.movie_rating_in_office.id;


--
-- Name: office; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.office (
    id integer NOT NULL
);


ALTER TABLE public.office OWNER TO max;

--
-- Name: office_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.office_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.office_id_seq OWNER TO max;

--
-- Name: office_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.office_id_seq OWNED BY public.office.id;


--
-- Name: rank; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.rank (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.rank OWNER TO max;

--
-- Name: rank_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.rank_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rank_id_seq OWNER TO max;

--
-- Name: rank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.rank_id_seq OWNED BY public.rank.id;


--
-- Name: rented_movie_copy_status; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.rented_movie_copy_status (
    id integer NOT NULL,
    id_movie_copy_in_office integer NOT NULL,
    employee_id integer NOT NULL,
    customer_id integer NOT NULL,
    rented_at timestamp without time zone DEFAULT now() NOT NULL,
    returned_at timestamp without time zone
);


ALTER TABLE public.rented_movie_copy_status OWNER TO max;

--
-- Name: rented_movie_copy_status_id_seq; Type: SEQUENCE; Schema: public; Owner: max
--

CREATE SEQUENCE public.rented_movie_copy_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rented_movie_copy_status_id_seq OWNER TO max;

--
-- Name: rented_movie_copy_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: max
--

ALTER SEQUENCE public.rented_movie_copy_status_id_seq OWNED BY public.rented_movie_copy_status.id;


--
-- Name: var_name1; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.var_name1 (
    date_trunc timestamp with time zone
);


ALTER TABLE public.var_name1 OWNER TO max;

--
-- Name: var_name2; Type: TABLE; Schema: public; Owner: max
--

CREATE TABLE public.var_name2 (
    id integer,
    name character varying(50),
    surname character varying(50),
    patronym character varying(50),
    address character varying(100),
    email character varying(100),
    is_active boolean,
    created_at timestamp without time zone,
    country_id integer
);


ALTER TABLE public.var_name2 OWNER TO max;

--
-- Name: actor id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.actor ALTER COLUMN id SET DEFAULT nextval('public.actor_id_seq'::regclass);


--
-- Name: country id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.country ALTER COLUMN id SET DEFAULT nextval('public.country_id_seq'::regclass);


--
-- Name: customer id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.customer ALTER COLUMN id SET DEFAULT nextval('public.customer_id_seq'::regclass);


--
-- Name: department id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.department ALTER COLUMN id SET DEFAULT nextval('public.department_id_seq'::regclass);


--
-- Name: employee id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.employee ALTER COLUMN id SET DEFAULT nextval('public.employee_id_seq'::regclass);


--
-- Name: genre id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.genre ALTER COLUMN id SET DEFAULT nextval('public.genre_id_seq'::regclass);


--
-- Name: language id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.language ALTER COLUMN id SET DEFAULT nextval('public.language_id_seq'::regclass);


--
-- Name: movie id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie ALTER COLUMN id SET DEFAULT nextval('public.movie_id_seq'::regclass);


--
-- Name: movie_actor_m2m id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_actor_m2m ALTER COLUMN id SET DEFAULT nextval('public.movie_actor_m2m_id_seq'::regclass);


--
-- Name: movie_copy_in_office id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_copy_in_office ALTER COLUMN id SET DEFAULT nextval('public.movie_copy_in_office_id_seq'::regclass);


--
-- Name: movie_country_m2m id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_country_m2m ALTER COLUMN id SET DEFAULT nextval('public.movie_country_m2m_id_seq'::regclass);


--
-- Name: movie_genre_m2m id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_genre_m2m ALTER COLUMN id SET DEFAULT nextval('public.movie_genre_m2m_id_seq'::regclass);


--
-- Name: movie_language_m2m id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_language_m2m ALTER COLUMN id SET DEFAULT nextval('public.movie_language_m2m_id_seq'::regclass);


--
-- Name: movie_rating_in_office id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_rating_in_office ALTER COLUMN id SET DEFAULT nextval('public.movie_rating_in_office_id_seq'::regclass);


--
-- Name: office id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.office ALTER COLUMN id SET DEFAULT nextval('public.office_id_seq'::regclass);


--
-- Name: rank id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.rank ALTER COLUMN id SET DEFAULT nextval('public.rank_id_seq'::regclass);


--
-- Name: rented_movie_copy_status id; Type: DEFAULT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.rented_movie_copy_status ALTER COLUMN id SET DEFAULT nextval('public.rented_movie_copy_status_id_seq'::regclass);


--
-- Data for Name: actor; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.actor (id, name, surname, patronym, biography, birthday, date_of_death, has_oscar, country_id) FROM stdin;
1	Brigitte	Hesslet	\N	some bio	1979-04-23	\N	t	1
2	John	Cake	Alles	some bio	1900-04-23	1996-03-22	t	4
3	Alex	Pancake	Sweet	some bio	1985-04-23	\N	t	9
4	Vasyl	Kit	Petrovich	some bio	1970-04-23	2000-05-22	f	3
5	Ivan	Patrov	Olegovich	some bio	1956-02-23	\N	f	2
6	Luidzhi	Gucci	\N	some bio	1977-03-23	\N	f	6
7	Candy	Shop	\N	some bio	1988-02-13	\N	f	5
8	Petro	Plyashka	\N	some bio	1965-02-13	\N	f	7
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.country (id, name) FROM stdin;
1	USA
2	Russia
3	Ukraine
4	Canada
5	Australia
6	Italy
7	Germany
8	France
9	Belgium
10	Denmark
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.customer (id, name, surname, patronym, address, email, is_active, created_at, country_id) FROM stdin;
2	Ivan	Qwertyev	Petrovich	some adress 543	ivan@gmail.com	t	2020-07-27 17:36:06.225811	2
3	Chris	Blue	Allen	some address 324	christop@gmail.com	t	2020-07-27 17:36:39.937297	4
4	Jack	Lolland	Fur	some address fds 3324	jack.l@gmail.com	t	2020-07-27 17:37:13.19251	8
5	Catalina	Erme	\N	some address 24	catalina@gmail.com	t	2020-07-27 17:37:46.503218	6
1	John	Evans	Dallen	some adress 223	john@gmail.com	t	2020-07-27 17:34:41.025637	1
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.department (id, office_id) FROM stdin;
1	1
2	1
3	1
4	2
5	2
6	2
7	3
8	3
9	3
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.employee (id, department_id, rank_id, country_id, name, surname, patronym, address, avatar, salary, is_active, hired_date, office_id) FROM stdin;
1	1	1	1	Joshua	Blum	Deer	some address 25	\N	700	t	2019-03-23 00:00:00	1
3	2	1	5	Deer	Peer	\N	some address 314	\N	500	t	2018-02-02 00:00:00	1
5	3	1	6	Jojo	Sader	\N	address 987	\N	350	t	2015-04-12 00:00:00	1
7	4	1	7	Reinhard	Hessler	\N	address ffer 23	\N	700	t	2014-07-01 00:00:00	2
9	5	1	7	Leticia	Lol	Herh	address wqe 123	\N	600	t	2013-08-12 00:00:00	2
11	6	1	8	George	Balter	Gagb	some dist 432	\N	900	t	2019-09-23 00:00:00	2
13	7	1	2	Ivan	Yolov	Evgenievich	some prosp 12	\N	500	t	2019-05-23 00:00:00	3
17	9	1	4	Margaret	Tetcher	Gaben	super district 324	\N	700	t	2019-07-23 00:00:00	3
15	8	1	3	Petro	Shkirka	Evgenovich	some prosp 75	\N	450	t	2018-05-23 00:00:00	3
4	\N	2	5	Huan	Fter	\N	some address 654	\N	1000	t	2017-02-03 00:00:00	1
12	\N	2	8	Yan	Hedaforen	Loleran	some ggg 234	\N	1200	t	2018-02-12 00:00:00	2
18	\N	2	4	John	Homeless	Somebody	kek district 645	\N	1000	t	2016-04-12 00:00:00	3
2	\N	3	1	Mary	Nein	Def	some address 12	\N	1000	t	2019-03-22 00:00:00	1
6	\N	4	6	Heroku	Benitto	\N	address 111	\N	700	t	2017-04-20 00:00:00	1
8	\N	3	7	Gerda	Fur	\N	address ger 246	\N	1000	t	2015-05-12 00:00:00	2
10	\N	4	7	Adolf	Merh	\N	address bfg 543	\N	1000	t	2018-08-12 00:00:00	2
16	\N	3	3	Viktor	Bamper	Panasovich	some vul 153	\N	650	t	2015-03-12 00:00:00	3
14	\N	4	2	Petr	Vasiliev	Antonovich	some eqw 764	\N	600	t	2020-03-12 00:00:00	3
\.


--
-- Data for Name: genre; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.genre (id, name) FROM stdin;
1	Horror
2	Adventure
3	Comedy
4	Crime
5	Drama
6	Mystery
7	Saga
8	Satire
9	Western
\.


--
-- Data for Name: language; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.language (id, name) FROM stdin;
1	English
2	Russian
3	Ukranian
4	German
5	French
6	Italian
7	Spanish
8	Polish
\.


--
-- Data for Name: movie; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.movie (id, name, release_year, description, running_time) FROM stdin;
1	Fury	2014	In early April 1945, the Allies make their final push into the dark heart of Nazi Germany, encountering radical and increasingly fanatical resistance.	135
2	Reservoir Dogs	1992	After the heist, White flees with Orange, who was shot in the stomach by an armed woman during the escape and is bleeding severely in the back of the getaway car. At one of Joe's warehouses, White and Orange rendezvous with Pink, who believes that the job was a setup, and that the police were waiting for them.	99
3	Airplane!	1980	Ex-fighter pilot Ted Striker is a traumatized war veteran turned taxi driver. Because of his pathological fear of flying and "drinking problem" (being unable to take a drink without splashing it on his face), he has been unable to hold a responsible job. His wartime girlfriend, Elaine Dickinson, now a flight attendant, leaves him before boarding her assigned flight from Los Angeles to Chicago.	87
4	Pan's Labyrinth	2006	In a fairy tale, Princess Moanna, whose father is the king of the underworld, visits the human world, where the sunlight blinds her and erases her memory. She becomes mortal and eventually dies. The king believes that eventually, her spirit will return to the underworld, so he builds labyrinths (which act as portals) around the world in preparation for her return.	119
5	The Deer Hunter	1978	You have to think about one shot. One shot is what it's all about. A deer's gotta be taken with one shot.	183
6	Close Encounters of the Third Kind	1977	How come I know so much? What the hell is going on around here? Who the hell are you people?	137
7	Up	2009	Adventure is out there!	96
8	Rocky	1976	In 1975, the heavyweight boxing world champion, Apollo Creed, announces plans to hold a title bout in Philadelphia during the upcoming United States Bicentennial. However, he is informed five weeks from the fight date that his scheduled opponent is unable to compete due to an injured hand. With all other potential replacements booked up or otherwise unavailable, Creed decides to spice things up by giving a local contender a chance to challenge him.	119
\.


--
-- Data for Name: movie_actor_m2m; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.movie_actor_m2m (id, movie_id, actor_id) FROM stdin;
1	1	1
2	1	7
4	2	2
5	2	6
8	3	8
9	3	6
10	3	2
11	5	4
12	6	2
13	7	7
14	7	6
15	7	3
16	8	5
3	1	2
\.


--
-- Data for Name: movie_copy_in_office; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.movie_copy_in_office (id, office_id, movie_id, amount) FROM stdin;
1	1	1	1
3	1	4	3
4	1	5	1
5	2	8	2
7	2	5	2
8	3	3	2
9	3	7	3
10	3	6	1
2	1	3	3
\.


--
-- Data for Name: movie_country_m2m; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.movie_country_m2m (id, movie_id, country_id) FROM stdin;
1	1	1
2	1	4
3	1	8
4	2	2
5	2	5
6	3	1
7	4	6
8	5	1
9	5	4
10	6	9
11	7	1
12	7	10
13	8	1
\.


--
-- Data for Name: movie_genre_m2m; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.movie_genre_m2m (id, movie_id, genre_id) FROM stdin;
1	1	1
2	1	9
3	2	5
4	3	3
5	3	1
6	4	1
7	4	7
8	5	1
9	5	8
10	6	2
11	7	6
12	7	7
13	8	2
\.


--
-- Data for Name: movie_language_m2m; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.movie_language_m2m (id, movie_id, language_id) FROM stdin;
1	1	1
2	1	2
3	1	3
4	1	4
5	2	1
6	2	4
7	3	1
8	3	5
9	4	7
10	4	8
11	4	3
12	5	1
13	6	6
14	6	2
15	7	1
16	7	2
17	8	1
\.


--
-- Data for Name: movie_rating_in_office; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.movie_rating_in_office (id, office_id, customer_id, movie_id, value) FROM stdin;
2	1	1	1	5
3	1	2	1	4
4	1	3	1	3
5	1	4	3	4
6	1	5	3	4
7	1	3	3	4
15	3	1	6	2
\.


--
-- Data for Name: office; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.office (id) FROM stdin;
1
2
3
\.


--
-- Data for Name: rank; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.rank (id, name) FROM stdin;
1	salesperson
2	manager
3	consultant
4	janitor
\.


--
-- Data for Name: rented_movie_copy_status; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.rented_movie_copy_status (id, id_movie_copy_in_office, employee_id, customer_id, rented_at, returned_at) FROM stdin;
4	2	1	2	2020-07-29 11:08:36	\N
5	2	1	5	2020-07-29 11:08:36	\N
6	1	1	3	2020-08-12 11:08:36	\N
1	3	1	1	2020-07-29 11:08:36	2020-07-29 15:19:39.931
2	3	1	4	2020-07-29 11:08:36	2020-07-29 15:19:44.163
3	3	1	2	2020-07-29 11:08:36	2020-07-29 15:19:44.163
7	10	15	3	2020-07-30 09:08:36	\N
8	2	1	3	2020-07-30 19:08:36	\N
\.


--
-- Data for Name: var_name1; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.var_name1 (date_trunc) FROM stdin;
2012-06-11 00:00:00+03
\.


--
-- Data for Name: var_name2; Type: TABLE DATA; Schema: public; Owner: max
--

COPY public.var_name2 (id, name, surname, patronym, address, email, is_active, created_at, country_id) FROM stdin;
2	Ivan	Qwertyev	Petrovich	some adress 543	ivan@gmail.com	t	2020-07-27 17:36:06.225811	2
3	Chris	Blue	Allen	some address 324	christop@gmail.com	t	2020-07-27 17:36:39.937297	4
4	Jack	Lolland	Fur	some address fds 3324	jack.l@gmail.com	t	2020-07-27 17:37:13.19251	8
5	Catalina	Erme	\N	some address 24	catalina@gmail.com	t	2020-07-27 17:37:46.503218	6
1	John	Evans	Dallen	some adress 223	john@gmail.com	t	2020-07-27 17:34:41.025637	1
\.


--
-- Name: actor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.actor_id_seq', 8, true);


--
-- Name: country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.country_id_seq', 10, true);


--
-- Name: customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.customer_id_seq', 5, true);


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.department_id_seq', 9, true);


--
-- Name: employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.employee_id_seq', 18, true);


--
-- Name: genre_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.genre_id_seq', 9, true);


--
-- Name: language_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.language_id_seq', 17, true);


--
-- Name: movie_actor_m2m_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.movie_actor_m2m_id_seq', 16, true);


--
-- Name: movie_copy_in_office_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.movie_copy_in_office_id_seq', 10, true);


--
-- Name: movie_country_m2m_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.movie_country_m2m_id_seq', 13, true);


--
-- Name: movie_genre_m2m_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.movie_genre_m2m_id_seq', 13, true);


--
-- Name: movie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.movie_id_seq', 8, true);


--
-- Name: movie_language_m2m_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.movie_language_m2m_id_seq', 17, true);


--
-- Name: movie_rating_in_office_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.movie_rating_in_office_id_seq', 15, true);


--
-- Name: office_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.office_id_seq', 1, false);


--
-- Name: rank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.rank_id_seq', 4, true);


--
-- Name: rented_movie_copy_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: max
--

SELECT pg_catalog.setval('public.rented_movie_copy_status_id_seq', 8, true);


--
-- Name: actor actor_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.actor
    ADD CONSTRAINT actor_pkey PRIMARY KEY (id);


--
-- Name: country country_name_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_name_key UNIQUE (name);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- Name: genre genre_name_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_name_key UNIQUE (name);


--
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (id);


--
-- Name: language language_name_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.language
    ADD CONSTRAINT language_name_key UNIQUE (name);


--
-- Name: language language_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.language
    ADD CONSTRAINT language_pkey PRIMARY KEY (id);


--
-- Name: movie_actor_m2m movie_actor_m2m_movie_id_actor_id_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_actor_m2m
    ADD CONSTRAINT movie_actor_m2m_movie_id_actor_id_key UNIQUE (movie_id, actor_id);


--
-- Name: movie_actor_m2m movie_actor_m2m_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_actor_m2m
    ADD CONSTRAINT movie_actor_m2m_pkey PRIMARY KEY (id);


--
-- Name: movie_copy_in_office movie_copy_in_office_office_id_movie_id_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_copy_in_office
    ADD CONSTRAINT movie_copy_in_office_office_id_movie_id_key UNIQUE (office_id, movie_id);


--
-- Name: movie_copy_in_office movie_copy_in_office_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_copy_in_office
    ADD CONSTRAINT movie_copy_in_office_pkey PRIMARY KEY (id);


--
-- Name: movie_country_m2m movie_country_m2m_movie_id_country_id_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_country_m2m
    ADD CONSTRAINT movie_country_m2m_movie_id_country_id_key UNIQUE (movie_id, country_id);


--
-- Name: movie_country_m2m movie_country_m2m_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_country_m2m
    ADD CONSTRAINT movie_country_m2m_pkey PRIMARY KEY (id);


--
-- Name: movie_genre_m2m movie_genre_m2m_movie_id_genre_id_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_genre_m2m
    ADD CONSTRAINT movie_genre_m2m_movie_id_genre_id_key UNIQUE (movie_id, genre_id);


--
-- Name: movie_genre_m2m movie_genre_m2m_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_genre_m2m
    ADD CONSTRAINT movie_genre_m2m_pkey PRIMARY KEY (id);


--
-- Name: movie_language_m2m movie_language_m2m_movie_id_language_id_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_language_m2m
    ADD CONSTRAINT movie_language_m2m_movie_id_language_id_key UNIQUE (movie_id, language_id);


--
-- Name: movie_language_m2m movie_language_m2m_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_language_m2m
    ADD CONSTRAINT movie_language_m2m_pkey PRIMARY KEY (id);


--
-- Name: movie movie_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie
    ADD CONSTRAINT movie_pkey PRIMARY KEY (id);


--
-- Name: movie_rating_in_office movie_rating_in_office_office_id_customer_id_movie_id_key; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_rating_in_office
    ADD CONSTRAINT movie_rating_in_office_office_id_customer_id_movie_id_key UNIQUE (office_id, customer_id, movie_id);


--
-- Name: movie_rating_in_office movie_rating_in_office_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_rating_in_office
    ADD CONSTRAINT movie_rating_in_office_pkey PRIMARY KEY (id);


--
-- Name: office office_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.office
    ADD CONSTRAINT office_pkey PRIMARY KEY (id);


--
-- Name: rank rank_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.rank
    ADD CONSTRAINT rank_pkey PRIMARY KEY (id);


--
-- Name: rented_movie_copy_status rented_movie_copy_status_pkey; Type: CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.rented_movie_copy_status
    ADD CONSTRAINT rented_movie_copy_status_pkey PRIMARY KEY (id);


--
-- Name: actor actor_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.actor
    ADD CONSTRAINT actor_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(id);


--
-- Name: customer customer_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(id);


--
-- Name: department department_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.office(id);


--
-- Name: employee employee_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(id);


--
-- Name: employee employee_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: employee employee_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.office(id);


--
-- Name: employee employee_rank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_rank_id_fkey FOREIGN KEY (rank_id) REFERENCES public.rank(id);


--
-- Name: movie_actor_m2m movie_actor_m2m_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_actor_m2m
    ADD CONSTRAINT movie_actor_m2m_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actor(id);


--
-- Name: movie_actor_m2m movie_actor_m2m_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_actor_m2m
    ADD CONSTRAINT movie_actor_m2m_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie(id);


--
-- Name: movie_copy_in_office movie_copy_in_office_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_copy_in_office
    ADD CONSTRAINT movie_copy_in_office_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie(id);


--
-- Name: movie_copy_in_office movie_copy_in_office_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_copy_in_office
    ADD CONSTRAINT movie_copy_in_office_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.office(id);


--
-- Name: movie_country_m2m movie_country_m2m_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_country_m2m
    ADD CONSTRAINT movie_country_m2m_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(id);


--
-- Name: movie_country_m2m movie_country_m2m_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_country_m2m
    ADD CONSTRAINT movie_country_m2m_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie(id);


--
-- Name: movie_genre_m2m movie_genre_m2m_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_genre_m2m
    ADD CONSTRAINT movie_genre_m2m_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genre(id);


--
-- Name: movie_genre_m2m movie_genre_m2m_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_genre_m2m
    ADD CONSTRAINT movie_genre_m2m_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie(id);


--
-- Name: movie_language_m2m movie_language_m2m_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_language_m2m
    ADD CONSTRAINT movie_language_m2m_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id);


--
-- Name: movie_language_m2m movie_language_m2m_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_language_m2m
    ADD CONSTRAINT movie_language_m2m_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie(id);


--
-- Name: movie_rating_in_office movie_rating_in_office_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_rating_in_office
    ADD CONSTRAINT movie_rating_in_office_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(id);


--
-- Name: movie_rating_in_office movie_rating_in_office_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_rating_in_office
    ADD CONSTRAINT movie_rating_in_office_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie(id);


--
-- Name: movie_rating_in_office movie_rating_in_office_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.movie_rating_in_office
    ADD CONSTRAINT movie_rating_in_office_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.office(id);


--
-- Name: rented_movie_copy_status rented_movie_copy_status_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.rented_movie_copy_status
    ADD CONSTRAINT rented_movie_copy_status_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(id);


--
-- Name: rented_movie_copy_status rented_movie_copy_status_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.rented_movie_copy_status
    ADD CONSTRAINT rented_movie_copy_status_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(id);


--
-- Name: rented_movie_copy_status rented_movie_copy_status_id_movie_copy_in_office_fkey; Type: FK CONSTRAINT; Schema: public; Owner: max
--

ALTER TABLE ONLY public.rented_movie_copy_status
    ADD CONSTRAINT rented_movie_copy_status_id_movie_copy_in_office_fkey FOREIGN KEY (id_movie_copy_in_office) REFERENCES public.movie_copy_in_office(id);


--
-- Name: COLUMN employee.office_id; Type: ACL; Schema: public; Owner: max
--

GRANT ALL(office_id) ON TABLE public.employee TO max;


--
-- Name: COLUMN rented_movie_copy_status.returned_at; Type: ACL; Schema: public; Owner: max
--

GRANT ALL(returned_at) ON TABLE public.rented_movie_copy_status TO max;


--
-- PostgreSQL database dump complete
--

