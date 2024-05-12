--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.2

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: sysadmin
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO sysadmin;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: sysadmin
--

COMMENT ON SCHEMA public IS '';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: active_wf_rules(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.active_wf_rules() RETURNS TABLE(workflowid integer, costcenters integer[], departments integer[], cashflows integer[], categories integer[])
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        x.workflowid as workflowid,
    ARRAY_AGG(x."costcenters")  filter(where x."costcenters" <> '{}'),
	ARRAY_AGG(x."departments") filter(where x."departments" <> '{}'),
	ARRAY_AGG(x."cashflows") filter(where x."cashflows" <> '{}'),
	ARRAY_AGG(x."categories") filter(where x."categories" <> '{}')
    FROM 
        (
            SELECT 
                COALESCE(cc."workflowId", dep."workflowId", categ."workflowId", cf."workflowId") AS workflowId, 
                COALESCE(cc."costcenters", '{}') AS "costcenters",
                COALESCE(dep."departments", '{}') AS "departments",
                COALESCE(cf."cashflows", '{}') AS "cashflows",
                COALESCE(categ."categories", '{}') AS "categories"
            FROM 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "costcenters"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'costcenters'
                    GROUP BY 
                        "workflowId"
                ) cc
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "departments"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'departments'
                    GROUP BY 
                        "workflowId"
                ) dep ON cc."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "cashflows"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'cashflows'
                    GROUP BY 
                        "workflowId"
                ) cf ON cf."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "categories"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'categories'
                    GROUP BY 
                        "workflowId"
                ) categ ON categ."workflowId" = cf."workflowId"
        ) x
    JOIN  
        public."WorkFlow" wf ON wf.id = x.workflowId
    WHERE 
        wf.status = true
    GROUP BY 
        x.workflowid;
END;
$$;


ALTER FUNCTION public.active_wf_rules() OWNER TO postgres;

--
-- Name: active_wf_rules2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.active_wf_rules2() RETURNS TABLE(workflowid integer, costcenters integer[], departments integer[], cashflows integer[], categories integer[])
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
    RETURN QUERY
    select 
	x.workflowid,
	unnest(costcenters::integer[]) AS costcenters,
	unnest(departments::integer[]) AS departments,
	unnest(cashflows::integer[]) AS cashflows,
	unnest(categories::integer[]) AS categories
	
	from (
	SELECT 
        x.workflowid as workflowid,
    ARRAY_AGG(x."costcenters")  filter(where x."costcenters" <> '{}'),
	ARRAY_AGG(x."departments") filter(where x."departments" <> '{}'),
	ARRAY_AGG(x."cashflows") filter(where x."cashflows" <> '{}'),
	ARRAY_AGG(x."categories") filter(where x."categories" <> '{}')
    FROM 
        (
            SELECT 
                COALESCE(cc."workflowId", dep."workflowId", categ."workflowId", cf."workflowId") AS workflowId, 
                COALESCE(cc."costcenters", '{}') AS "costcenters",
                COALESCE(dep."departments", '{}') AS "departments",
                COALESCE(cf."cashflows", '{}') AS "cashflows",
                COALESCE(categ."categories", '{}') AS "categories"
            FROM 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "costcenters"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'costcenters'
                    GROUP BY 
                        "workflowId"
                ) cc
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "departments"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'departments'
                    GROUP BY 
                        "workflowId"
                ) dep ON cc."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "cashflows"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'cashflows'
                    GROUP BY 
                        "workflowId"
                ) cf ON cf."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "categories"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'categories'
                    GROUP BY 
                        "workflowId"
                ) categ ON categ."workflowId" = cf."workflowId"
        ) x
    JOIN  
        public."WorkFlow" wf ON wf.id = x.workflowId
    WHERE 
        wf.status = true
    GROUP BY 
        x.workflowid)x;
END;
$$;


ALTER FUNCTION public.active_wf_rules2() OWNER TO postgres;

--
-- Name: active_wf_rules8(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.active_wf_rules8() RETURNS TABLE(workflowid integer, costcenters integer[], departments integer[], cashflows integer[], categories integer[])
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
   RETURN QUERY

SELECT 
    z.workflowid,
    array_agg(y.costcenters) AS costcenters,
    array_agg(y.departments) AS departments,
    array_agg(y.cashflows) AS cashflows,
    array_agg(y.categories) AS categories
FROM (
    SELECT 
        x.workflowid,
        unnest(x.costcenters) AS costcenters,
        unnest(x.departments) AS departments,
        unnest(x.cashflows) AS cashflows,
        unnest(x.categories) AS categories
    FROM (
        SELECT 
            x.workflowid,
            array_agg(x.costcenters) filter (WHERE x.costcenters <> '{}') AS costcenters,
            array_agg(x.departments) filter (WHERE x.departments <> '{}') AS departments,
            array_agg(x.cashflows) filter (WHERE x.cashflows <> '{}') AS cashflows,
            array_agg(x.categories) filter (WHERE x.categories <> '{}') AS categories
        FROM (
            SELECT 
                COALESCE(cc."workflowId", dep."workflowId", categ."workflowId", cf."workflowId") AS workflowId, 
                COALESCE(cc."costcenters", '{}') AS costcenters,
                COALESCE(dep."departments", '{}') AS departments,
                COALESCE(cf."cashflows", '{}') AS cashflows,
                COALESCE(categ."categories", '{}') AS categories
            FROM 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS costcenters
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'costcenters'
                    GROUP BY 
                        "workflowId"
                ) cc
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS departments
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'departments'
                    GROUP BY 
                        "workflowId"
                ) dep ON cc."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS cashflows
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'cashflows'
                    GROUP BY 
                        "workflowId"
                ) cf ON cf."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS categories
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'categories'
                    GROUP BY 
                        "workflowId"
                ) categ ON categ."workflowId" = cf."workflowId"
        ) x
        JOIN  
            public."WorkFlow" wf ON wf.id = x."workflowId"
        WHERE 
            wf."status" = true
        GROUP BY 
            x."workflowid"
    ) x
) y
GROUP BY 
    z."workflowid";

END;
$$;


ALTER FUNCTION public.active_wf_rules8() OWNER TO postgres;

--
-- Name: active_wf_rules9(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.active_wf_rules9() RETURNS TABLE(workflowid integer, costcenters integer[], departments integer[], cashflows integer[], categories integer[])
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
   RETURN QUERY

select 
	-- ARRAY_REMOVE(z.costcenters, NULL) costcenters,
	-- ARRAY_REMOVE(z.departments, NULL) departments,
	-- ARRAY_REMOVE(z.cashflows, NULL) cashflows,
	-- ARRAY_REMOVE(z.categories, NULL) categories
	z.workflowid,z.costcenters,z.departments,z.cashflows,z.categories
	from (
SELECT 
	y.workflowid,
	array_agg(y."costcenters") AS costcenters,
	array_agg(y."departments") AS departments,
	array_agg(y."cashflows") AS cashflows,
	array_agg(y."categories") AS categories
FROM (

    select 
	x."workflowid",
	unnest(x."costcenters"::integer[]) AS costcenters,
	unnest(x."departments"::integer[]) AS departments,
	unnest(x."cashflows"::integer[]) AS cashflows,
	unnest(x."categories"::integer[]) AS categories
	
	from (
	SELECT 
        x."workflowid" as workflowid,
    ARRAY_AGG(x."costcenters")  filter(where x."costcenters" <> '{}') as costcenters,
	ARRAY_AGG(x."departments") filter(where x."departments" <> '{}') as departments,
	ARRAY_AGG(x."cashflows") filter(where x."cashflows" <> '{}') as cashflows,
	ARRAY_AGG(x."categories") filter(where x."categories" <> '{}') as categories
    FROM 
        (
            SELECT 
                COALESCE(cc."workflowId", dep."workflowId", categ."workflowId", cf."workflowId") AS workflowId, 
                COALESCE(cc."costcenters", '{}') AS "costcenters",
                COALESCE(dep."departments", '{}') AS "departments",
                COALESCE(cf."cashflows", '{}') AS "cashflows",
                COALESCE(categ."categories", '{}') AS "categories"
            FROM 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "costcenters"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'costcenters'
                    GROUP BY 
                        "workflowId"
                ) cc
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "departments"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'departments'
                    GROUP BY 
                        "workflowId"
                ) dep ON cc."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "cashflows"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'cashflows'
                    GROUP BY 
                        "workflowId"
                ) cf ON cf."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS "categories"
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'categories'
                    GROUP BY 
                        "workflowId"
                ) categ ON categ."workflowId" = cf."workflowId"
        ) x
    JOIN  
        public."WorkFlow" wf ON wf.id = x.workflowId
    WHERE 
        wf.status = true
    GROUP BY 
        x.workflowid)x
)y
group by y.workflowid)z;


END;
$$;


ALTER FUNCTION public.active_wf_rules9() OWNER TO postgres;

--
-- Name: active_wf_rulesok(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.active_wf_rulesok() RETURNS TABLE(workflowid integer, costcenters integer[], departments integer[], cashflows integer[], categories integer[])
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
   RETURN QUERY
	
SELECT 
    y.workflowid,
	array_remove(array_remove(array_remove(array_remove(array_agg(y.costcenters)::integer[], NULL), NULL), NULL), NULL) costcenters,
	array_remove(array_remove(array_remove(array_remove(array_agg(y.departments)::integer[], NULL), NULL), NULL), NULL) departments,
	array_remove(array_remove(array_remove(array_remove(array_agg(y.cashflows)::integer[], NULL), NULL), NULL), NULL) cashflows,
	array_remove(array_remove(array_remove(array_remove(array_agg(y.categories)::integer[], NULL), NULL), NULL), NULL) categories
FROM (
    SELECT 
        x.workflowid,
        unnest(x.costcenters) AS costcenters,
        unnest(x.departments) AS departments,
        unnest(x.cashflows) AS cashflows,
        unnest(x.categories) AS categories
    FROM (
        SELECT 
            x.workflowid,
            array_agg(x.costcenters) filter (WHERE x.costcenters <> '{}') AS costcenters,
            array_agg(x.departments) filter (WHERE x.departments <> '{}') AS departments,
            array_agg(x.cashflows) filter (WHERE x.cashflows <> '{}') AS cashflows,
            array_agg(x.categories) filter (WHERE x.categories <> '{}') AS categories
        FROM (
            SELECT 
                COALESCE(cc."workflowId", dep."workflowId", categ."workflowId", cf."workflowId") AS workflowId, 
                COALESCE(cc."costcenters", '{}') AS costcenters,
                COALESCE(dep."departments", '{}') AS departments,
                COALESCE(cf."cashflows", '{}') AS cashflows,
                COALESCE(categ."categories", '{}') AS categories
            FROM 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS costcenters
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'costcenters'
                    GROUP BY 
                        "workflowId"
                ) cc
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS departments
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'departments'
                    GROUP BY 
                        "workflowId"
                ) dep ON cc."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS cashflows
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'cashflows'
                    GROUP BY 
                        "workflowId"
                ) cf ON cf."workflowId" = dep."workflowId"
            FULL OUTER JOIN 
                (
                    SELECT 
                        "workflowId",
                        array_agg("ruleFilterValue" ORDER BY "ruleFilterValue") AS categories
                    FROM 
                        public."WorkFlowRules"
                    WHERE 
                        "ruleFilterSource" = 'categories'
                    GROUP BY 
                        "workflowId"
                ) categ ON categ."workflowId" = cf."workflowId"
        ) x
        JOIN  
            public."WorkFlow" wf ON wf.id = x.workflowId
        WHERE 
            wf."status" = true
        GROUP BY 
            x."workflowid"
    ) x
) y
group by y.workflowid;



END;
$$;


ALTER FUNCTION public.active_wf_rulesok() OWNER TO postgres;

--
-- Name: add_days_to_current_date(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_days_to_current_date(days_value integer) RETURNS date
    LANGUAGE plpgsql
    AS $$
DECLARE
    interval_str text;
BEGIN
    interval_str := CONCAT(days_value, ' day');
    RETURN CURRENT_DATE + interval_str::interval;
END;
$$;


ALTER FUNCTION public.add_days_to_current_date(days_value integer) OWNER TO postgres;

--
-- Name: calculate_cashflow_func(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_cashflow_func() RETURNS TABLE(tip text, billingvalue numeric, month_number numeric)
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
   RETURN QUERY
    SELECT x.tip,
           SUM(x.billingValue) AS billingValue,
           EXTRACT(MONTH FROM x."date") AS month_number
    FROM (
        SELECT 'P' AS tip,
               cfdb.date,
               ROUND((cfdb."billingValue" * er.amount)::NUMERIC, 2) AS billingValue
        FROM public."ContractItems" ci
        LEFT JOIN public."Contracts" c ON c."id" = ci."contractId"
        LEFT JOIN public."ContractFinancialDetail" cfd ON cfd."contractItemId" = ci."id"
        LEFT JOIN public."ContractFinancialDetailSchedule" cfdb ON cfdb."contractfinancialItemId" = cfd."id"
        LEFT JOIN public."Currency" cr ON cr."id" = cfdb.currencyid
        LEFT JOIN (
            SELECT * FROM public."ExchangeRates" WHERE public."ExchangeRates"."date" =
                (SELECT MAX("date") FROM public."ExchangeRates") 
        ) er ON er."name" = cr.code
        WHERE ci.active IS TRUE
        AND cfd.active IS TRUE
        AND cfdb.active IS TRUE
        AND c."isPurchasing" IS TRUE
        AND cfdb."date" BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 months'
        
        UNION ALL
        
        SELECT 'I' AS tip,
               cfdb.date,
               ROUND((cfdb."billingValue" * er.amount)::NUMERIC, 2) AS billingValue
        FROM public."ContractItems" ci
        LEFT JOIN public."Contracts" c ON c."id" = ci."contractId"
        LEFT JOIN public."ContractFinancialDetail" cfd ON cfd."contractItemId" = ci."id"
        LEFT JOIN public."ContractFinancialDetailSchedule" cfdb ON cfdb."contractfinancialItemId" = cfd."id"
        LEFT JOIN public."Currency" cr ON cr."id" = cfdb.currencyid
        LEFT JOIN (
            SELECT * FROM public."ExchangeRates" WHERE public."ExchangeRates"."date" =
                (SELECT MAX("date") FROM public."ExchangeRates") 
        ) er ON er."name" = cr.code
        WHERE ci.active IS TRUE
        AND cfd.active IS TRUE
        AND cfdb.active IS TRUE
        AND c."isPurchasing" IS FALSE
        AND cfdb."date" BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 months'
    ) x
    GROUP BY x.tip, EXTRACT(MONTH FROM x."date")
    ORDER BY 1;
    
END;
$$;


ALTER FUNCTION public.calculate_cashflow_func() OWNER TO postgres;

--
-- Name: contracttasktobegenerated(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.contracttasktobegenerated() RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, approvedbyall boolean, approvaltypeinparallel boolean, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
   RETURN QUERY


select  wfts."taskName" ,  wfts."taskNotes",wfx."contractId"  , 
	1 as statusId, 3 as requestorId, wftsu."userId" as assignedId,
	wfts."approvedByAll",wfts."approvalTypeInParallel",
wfts.id as workflowTaskSettingsId, uuid_generate_v4() as Uuid, 
	wftsu."approvalOrderNumber"  as approvalOrderNumber,
wfts."workflowId", ctp."name" as PriorityName,wfts."taskPriorityId" PriorityId, ctr.name ReminderName, 
ctr."days" as ReminderDays, 
ctdd."name" as DueDate, 
ctdd."days" as DueDateDays,
CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL as CalculatedDueDate, 
(CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL)::DATE 
	+ CONCAT(ctr."days" , ' day')::INTERVAL AS CalculatedReminderDate,
wfts."taskSendNotifications", wfts."taskSendReminders",
wfct."statusId" as TaskStatusId
from public."WorkFlowXContracts" wfx 
join public."Contracts" c  on wfx."contractId" =c.id 
join "WorkFlowTaskSettings" wfts on wfts.id=wfx."workflowTaskSettingsId" 
join "WorkFlowTaskSettingsUsers" wftsu  on wftsu."workflowTaskSettingsId" = wfts.id 
join "ContractTasksStatus" cts on cts.id = wfx."ctrstatusId" 
join "ContractStatus" cs  on cs.id =c."statusId" 
left join "ContractTasksPriority" ctp on ctp.id =wfts."taskPriorityId" 
left join "ContractTasksReminders" ctr on ctr.id =wfts."taskReminderId" 
left join "ContractTasksDueDates" ctdd on ctdd.id =wfts."taskDueDateId" 
left join "WorkFlowContractTasks" wfct on wfct."contractId" = c.id and wfct."approvalOrderNumber" = wftsu."approvalOrderNumber" and wfct."workflowTaskSettingsId" = wfx."workflowTaskSettingsId" 
where cs."id" = 1;


END;
$$;


ALTER FUNCTION public.contracttasktobegenerated() OWNER TO sysadmin;

--
-- Name: contracttasktobegeneratedok(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.contracttasktobegeneratedok() RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
   RETURN QUERY

select  wfts."taskName" ,  wfts."taskNotes",wfx."contractId"  , 
	1 as statusId, 3 as requestorId, wftsu."userId" as assignedId,
wfts.id as workflowTaskSettingsId, uuid_generate_v4() as Uuid, 
	wftsu."approvalOrderNumber"  as approvalOrderNumber,
wfts."workflowId", ctp."name" as PriorityName,wfts."taskPriorityId" PriorityId, ctr.name ReminderName, 
ctr."days" as ReminderDays, 
ctdd."name" as DueDate, 
ctdd."days" as DueDateDays,
CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL as CalculatedDueDate, 
(CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL)::DATE 
	+ CONCAT(ctr."days" , ' day')::INTERVAL AS CalculatedReminderDate,
wfts."taskSendNotifications", wfts."taskSendReminders",
wfct."statusId" as TaskStatusId
from public."WorkFlowXContracts" wfx 
join public."Contracts" c  on wfx."contractId" =c.id 
join "WorkFlowTaskSettings" wfts on wfts.id=wfx."workflowTaskSettingsId" 
join "WorkFlowTaskSettingsUsers" wftsu  on wftsu."workflowTaskSettingsId" = wfts.id 
join "ContractTasksStatus" cts on cts.id = wfx."ctrstatusId" 
join "ContractStatus" cs  on cs.id =c."statusId" 
left join "ContractTasksPriority" ctp on ctp.id =wfts."taskPriorityId" 
left join "ContractTasksReminders" ctr on ctr.id =wfts."taskReminderId" 
left join "ContractTasksDueDates" ctdd on ctdd.id =wfts."taskDueDateId" 
left join "WorkFlowContractTasks" wfct on wfct."contractId" = c.id and wfct."approvalOrderNumber" = wftsu."approvalOrderNumber" and wfct."workflowTaskSettingsId" = wfx."workflowTaskSettingsId" 
where 
cs."id" = 1 ;

END;
$$;


ALTER FUNCTION public.contracttasktobegeneratedok() OWNER TO sysadmin;

--
-- Name: contracttasktobegeneratedsecv(integer); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.contracttasktobegeneratedsecv(contractid_param integer) RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, approvedbyall boolean, approvaltypeinparallel boolean, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
    RETURN QUERY
    SELECT  
        wfts."taskName",  
        wfts."taskNotes", 
        wfx."contractId", 
        1 AS statusId, 
        3 AS requestorId, 
        wftsu."userId" AS assignedId,
        wfts."approvedByAll",
        wfts."approvalTypeInParallel",
        wfts.id AS workflowTaskSettingsId, 
      --  uuid_generate_v4() AS Uuid, 
        wftsu."approvalOrderNumber" AS approvalOrderNumber,
        wfts."workflowId", 
        ctp."name" AS PriorityName,
        wfts."taskPriorityId" AS PriorityId, 
        ctr.name AS ReminderName, 
        ctr."days" AS ReminderDays, 
        ctdd."name" AS DueDate, 
        ctdd."days" AS DueDateDays,
        CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL AS CalculatedDueDate, 
        (CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL)::DATE + CONCAT(ctr."days" , ' day')::INTERVAL AS CalculatedReminderDate,
        wfts."taskSendNotifications", 
        wfts."taskSendReminders",
        wfct."statusId" AS TaskStatusId
    FROM 
        public."WorkFlowXContracts" wfx 
        JOIN public."Contracts" c ON wfx."contractId" = c.id 
        JOIN "WorkFlowTaskSettings" wfts ON wfts.id = wfx."workflowTaskSettingsId" 
        JOIN "WorkFlowTaskSettingsUsers" wftsu ON wftsu."workflowTaskSettingsId" = wfts.id 
        JOIN "ContractTasksStatus" cts ON cts.id = wfx."ctrstatusId" 
        JOIN "ContractStatus" cs ON cs.id = c."statusId" 
        LEFT JOIN "ContractTasksPriority" ctp ON ctp.id = wfts."taskPriorityId" 
        LEFT JOIN "ContractTasksReminders" ctr ON ctr.id = wfts."taskReminderId" 
        LEFT JOIN "ContractTasksDueDates" ctdd ON ctdd.id = wfts."taskDueDateId" 
        LEFT JOIN "WorkFlowContractTasks" wfct ON wfct."contractId" = c.id AND wfct."approvalOrderNumber" = wftsu."approvalOrderNumber" AND wfct."workflowTaskSettingsId" = wfx."workflowTaskSettingsId" 
    WHERE 
        wfx."contractId" = contractId_param 
        AND coalesce(wfct."statusId",0) NOT IN (4,5) 
       -- AND cs."id" = 1
    ORDER BY 
        wftsu."approvalOrderNumber" 
    LIMIT 1;
END;
$$;


ALTER FUNCTION public.contracttasktobegeneratedsecv(contractid_param integer) OWNER TO sysadmin;

--
-- Name: contracttasktobegeneratedsecv2(integer); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.contracttasktobegeneratedsecv2(contractid_param integer) RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, approvedbyall boolean, approvaltypeinparallel boolean, workflowtasksettingsid integer, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
    RETURN QUERY
    SELECT  
        wfts."taskName",  
        wfts."taskNotes", 
        wfx."contractId", 
        1 AS statusId, 
        3 AS requestorId, 
        wftsu."userId" AS assignedId,
        wfts."approvedByAll",
        wfts."approvalTypeInParallel",
        wfts.id AS workflowTaskSettingsId, 
      --  uuid_generate_v4() AS Uuid, 
        wftsu."approvalOrderNumber" AS approvalOrderNumber,
        wfts."workflowId", 
        ctp."name" AS PriorityName,
        wfts."taskPriorityId" AS PriorityId, 
        ctr.name AS ReminderName, 
        ctr."days" AS ReminderDays, 
        ctdd."name" AS DueDate, 
        ctdd."days" AS DueDateDays,
        CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL AS CalculatedDueDate, 
        (CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL)::DATE + CONCAT(ctr."days" , ' day')::INTERVAL AS CalculatedReminderDate,
        wfts."taskSendNotifications", 
        wfts."taskSendReminders",
        wfct."statusId" AS TaskStatusId
    FROM 
        public."WorkFlowXContracts" wfx 
        JOIN public."Contracts" c ON wfx."contractId" = c.id 
        JOIN "WorkFlowTaskSettings" wfts ON wfts.id = wfx."workflowTaskSettingsId" 
        JOIN "WorkFlowTaskSettingsUsers" wftsu ON wftsu."workflowTaskSettingsId" = wfts.id 
        JOIN "ContractTasksStatus" cts ON cts.id = wfx."ctrstatusId" 
        JOIN "ContractStatus" cs ON cs.id = c."statusId" 
        LEFT JOIN "ContractTasksPriority" ctp ON ctp.id = wfts."taskPriorityId" 
        LEFT JOIN "ContractTasksReminders" ctr ON ctr.id = wfts."taskReminderId" 
        LEFT JOIN "ContractTasksDueDates" ctdd ON ctdd.id = wfts."taskDueDateId" 
        LEFT JOIN "WorkFlowContractTasks" wfct ON wfct."contractId" = c.id AND wfct."approvalOrderNumber" = wftsu."approvalOrderNumber" AND wfct."workflowTaskSettingsId" = wfx."workflowTaskSettingsId" 
    WHERE 
        wfx."contractId" = contractId_param 
        AND coalesce(wfct."statusId",0) NOT IN (4,5) 
       -- AND cs."id" = 1
    ORDER BY 
        wftsu."approvalOrderNumber" 
    LIMIT 1;
END;
$$;


ALTER FUNCTION public.contracttasktobegeneratedsecv2(contractid_param integer) OWNER TO sysadmin;

--
-- Name: contracttasktobegeneratedsecv3(integer); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.contracttasktobegeneratedsecv3(contractid_param integer) RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, workflowtasksettingsid integer, uuid integer, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
    RETURN QUERY
    SELECT  
        wfts."taskName",  
        wfts."taskNotes", 
        wfx."contractId", 
        1 AS statusId, 
        3 AS requestorId, 
        wftsu."userId" AS assignedId,
        wfts.id AS workflowTaskSettingsId, 
        1 AS uuid1, 
        wftsu."approvalOrderNumber" AS approvalOrderNumber,
        wfts."workflowId", 
        ctp."name" AS PriorityName,
        wfts."taskPriorityId" AS PriorityId, 
        ctr.name AS ReminderName, 
        ctr."days" AS ReminderDays, 
        ctdd."name" AS DueDate, 
        ctdd."days" AS DueDateDays,
        CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL AS CalculatedDueDate, 
        (CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL)::DATE + CONCAT(ctr."days" , ' day')::INTERVAL AS CalculatedReminderDate,
        wfts."taskSendNotifications", 
        wfts."taskSendReminders",
        wfct."statusId" AS TaskStatusId
    FROM 
        public."WorkFlowXContracts" wfx 
        JOIN public."Contracts" c ON wfx."contractId" = c.id 
        JOIN "WorkFlowTaskSettings" wfts ON wfts.id = wfx."workflowTaskSettingsId" 
        JOIN "WorkFlowTaskSettingsUsers" wftsu ON wftsu."workflowTaskSettingsId" = wfts.id 
        JOIN "ContractTasksStatus" cts ON cts.id = wfx."ctrstatusId" 
        JOIN "ContractStatus" cs ON cs.id = c."statusId" 
        LEFT JOIN "ContractTasksPriority" ctp ON ctp.id = wfts."taskPriorityId" 
        LEFT JOIN "ContractTasksReminders" ctr ON ctr.id = wfts."taskReminderId" 
        LEFT JOIN "ContractTasksDueDates" ctdd ON ctdd.id = wfts."taskDueDateId" 
        LEFT JOIN "WorkFlowContractTasks" wfct ON wfct."contractId" = c.id AND wfct."approvalOrderNumber" = wftsu."approvalOrderNumber" AND wfct."workflowTaskSettingsId" = wfx."workflowTaskSettingsId" 
    WHERE 
        wfx."contractId" = contractId_param 
	    AND 
		c."statusId" <> 13
        AND coalesce(wfct."statusId",0) NOT IN (4,5) 
    --    AND wfct."uuid" is null
    ORDER BY 
        wftsu."approvalOrderNumber" 
    LIMIT 1;
END;
$$;


ALTER FUNCTION public.contracttasktobegeneratedsecv3(contractid_param integer) OWNER TO sysadmin;

--
-- Name: contracttasktobegeneratedsecvent(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.contracttasktobegeneratedsecvent() RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, approvedbyall boolean, approvaltypeinparallel boolean, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
   RETURN QUERY
select  wfts."taskName" ,  wfts."taskNotes",wfx."contractId"  , 
	1 as statusId, 3 as requestorId, wftsu."userId" as assignedId,
	wfts."approvedByAll",wfts."approvalTypeInParallel",
wfts.id as workflowTaskSettingsId, uuid_generate_v4() as Uuid, 
	wftsu."approvalOrderNumber"  as approvalOrderNumber,
wfts."workflowId", ctp."name" as PriorityName,wfts."taskPriorityId" PriorityId, ctr.name ReminderName, 
ctr."days" as ReminderDays, 
ctdd."name" as DueDate, 
ctdd."days" as DueDateDays,
CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL as CalculatedDueDate, 
(CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL)::DATE 
	+ CONCAT(ctr."days" , ' day')::INTERVAL AS CalculatedReminderDate,
wfts."taskSendNotifications", wfts."taskSendReminders",
wfct."statusId" as TaskStatusId
from public."WorkFlowXContracts" wfx 
join public."Contracts" c  on wfx."contractId" =c.id 
join "WorkFlowTaskSettings" wfts on wfts.id=wfx."workflowTaskSettingsId" 
join "WorkFlowTaskSettingsUsers" wftsu  on wftsu."workflowTaskSettingsId" = wfts.id 
join "ContractTasksStatus" cts on cts.id = wfx."ctrstatusId" 
join "ContractStatus" cs  on cs.id =c."statusId" 
left join "ContractTasksPriority" ctp on ctp.id =wfts."taskPriorityId" 
left join "ContractTasksReminders" ctr on ctr.id =wfts."taskReminderId" 
left join "ContractTasksDueDates" ctdd on ctdd.id =wfts."taskDueDateId" 
left join "WorkFlowContractTasks" wfct on wfct."contractId" = c.id and wfct."approvalOrderNumber" = wftsu."approvalOrderNumber" and wfct."workflowTaskSettingsId" = wfx."workflowTaskSettingsId" 
where 
--cs."id" = 1 and 
wfts."approvalTypeInParallel" =false ;


END;
$$;


ALTER FUNCTION public.contracttasktobegeneratedsecvent() OWNER TO sysadmin;

--
-- Name: cttobegeneratedsecv(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.cttobegeneratedsecv() RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
    LANGUAGE plpgsql ROWS 10000
    AS $$
BEGIN
    RETURN QUERY
    SELECT  
        wfts."taskName",  
        wfts."taskNotes", 
        wfx."contractId", 
        1 AS statusId, 
        3 AS requestorId, 
        wftsu."userId" AS assignedId,
        wfts.id AS workflowTaskSettingsId, 
        uuid_generate_v4() AS Uuid, 
        wftsu."approvalOrderNumber" AS approvalOrderNumber,
        wfts."workflowId", 
        ctp."name" AS PriorityName,
        wfts."taskPriorityId" AS PriorityId, 
        ctr.name AS ReminderName, 
        ctr."days" AS ReminderDays, 
        ctdd."name" AS DueDate, 
        ctdd."days" AS DueDateDays,
        CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL AS CalculatedDueDate, 
        (CURRENT_DATE::DATE + CONCAT(ctdd."days" , ' day')::INTERVAL)::DATE + CONCAT(ctr."days" , ' day')::INTERVAL AS CalculatedReminderDate,
        wfts."taskSendNotifications", 
        wfts."taskSendReminders",
        wfct."statusId" AS TaskStatusId
    FROM 
        public."WorkFlowXContracts" wfx 
        JOIN public."Contracts" c ON wfx."contractId" = c.id 
        JOIN "WorkFlowTaskSettings" wfts ON wfts.id = wfx."workflowTaskSettingsId" 
        JOIN "WorkFlowTaskSettingsUsers" wftsu ON wftsu."workflowTaskSettingsId" = wfts.id 
        JOIN "ContractTasksStatus" cts ON cts.id = wfx."ctrstatusId" 
        JOIN "ContractStatus" cs ON cs.id = c."statusId" 
        LEFT JOIN "ContractTasksPriority" ctp ON ctp.id = wfts."taskPriorityId" 
        LEFT JOIN "ContractTasksReminders" ctr ON ctr.id = wfts."taskReminderId" 
        LEFT JOIN "ContractTasksDueDates" ctdd ON ctdd.id = wfts."taskDueDateId" 
        LEFT JOIN "WorkFlowContractTasks" wfct ON wfct."contractId" = c.id AND wfct."approvalOrderNumber" = wftsu."approvalOrderNumber" AND wfct."workflowTaskSettingsId" = wfx."workflowTaskSettingsId"  ;

END;
$$;


ALTER FUNCTION public.cttobegeneratedsecv() OWNER TO sysadmin;

--
-- Name: get_contract_details(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_contract_details() RETURNS TABLE(tipcontract text, number text, start_date date, end_date date, sign_date date, completion_date date, remarks text, partner_name text, entity_name text, automatic_renewal text, status_name text, cashflow_name text, category_name text, contract_type_name text, department_name text, cost_center_name text, partner_person_name text, partner_person_role text, partner_person_email text, entity_person_name text, entity_person_role text, entity_person_email text, partner_address text, entity_address text, partner_bank text, partner_currency text, partner_iban text, entity_bank text, entity_currency text, entity_iban text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE
            WHEN c."isPurchasing" = FALSE THEN 'Client'
            ELSE 'Furnizor'
        END AS TipContract,
        c.number,
        c.start::DATE,
        c.end::DATE,
        c.sign::DATE,
        c.completion::DATE,
        COALESCE(c.remarks, '') AS remarks,
        p.name AS partner_name,
        e.name AS entity_name,
       case when  c."automaticRenewal" = true then 'Da' else 'NU' END AS automatic_renewal,
        cs.name AS status_name,
        COALESCE(c2.name, '') AS cashflow_name,
        COALESCE(c3.name, '') AS category_name,
        COALESCE(ct.name, '') AS contract_type_name,
        COALESCE(d.name, '') AS department_name,
        COALESCE(cc.name, '') AS cost_center_name,
        COALESCE(pp.name, '') AS partner_person_name,
        COALESCE(pp.role, '') AS partner_person_role,
        pp.email AS partner_person_email,
        COALESCE(pe.name, '') AS entity_person_name,
        COALESCE(pe.role, '') AS entity_person_role,
        pe.email AS entity_person_email,
        COALESCE(ap."completeAddress", '') AS partner_address,
        COALESCE(ae."completeAddress", '') AS entity_address,
        COALESCE(bp.bank, '') AS partner_bank,
        COALESCE(bp.currency, '') AS partner_currency,
        COALESCE(bp.iban, '') AS partner_iban,
        COALESCE(be.bank, '') AS entity_bank,
        COALESCE(be.currency, '') AS entity_currency,
        COALESCE(be.iban, '') AS entity_iban
    FROM 
        public."Contracts" c 
    JOIN 
        public."ContractStatus" cs ON c."statusId" = cs.id 
    JOIN 
        "Partners" p ON p.id = c."partnersId" 
    JOIN 
        "Partners" e ON e.id = c."entityId"    
    LEFT JOIN 
        "Cashflow" c2 ON c2.id = c."cashflowId" 
    LEFT JOIN 
        "Category" c3 ON c3.id = c."categoryId" 
    LEFT JOIN 
        "ContractType" ct ON ct.id = c."typeId" 
    LEFT JOIN 
        "Department" d ON d.id = c."departmentId" 
    LEFT JOIN 
        "CostCenter" cc ON cc.id = c."costcenterId" 
    LEFT JOIN 
        "Persons" pp ON pp.id = c."partnerpersonsId"
    LEFT JOIN 
        "Persons" pe ON pe.id = c."entitypersonsId"
    LEFT JOIN 
        "Address" ap ON ap.id = c."partneraddressId" 
    LEFT JOIN 
        "Address" ae ON ae.id = c."entityaddressId" 
    LEFT JOIN 
        "Banks" bp ON bp.id = c."partnerbankId"  
    LEFT JOIN 
        "Banks" be ON be.id = c."entitybankId";
END;
$$;


ALTER FUNCTION public.get_contract_details() OWNER TO postgres;

--
-- Name: getauditcontract(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getauditcontract(contractid integer) RETURNS TABLE(contract_id integer, tip_modificare text, data_modificare timestamp without time zone, contract_number text, nume_partener text, nume_entitate text, stare text, start_date timestamp without time zone, end_date timestamp without time zone, sign_date timestamp without time zone, completion_date timestamp without time zone, nume_categorie text, departament text, cashflow text, tip_contract text, centru_cost text, utilizator text)
    LANGUAGE plpgsql
    AS $$
    begin 
	RETURN QUERY
    select
    c.id as contract_id,
        c."operationType" Tip_Modificare,
            c."createdAt" as Data_Modificare,
                c.number as Contract_Number,
                a.name as Nume_Partener,
                b.name as Nume_Entitate,
                cs.name as Stare,
                c.start as Start_Date,
                c.end as End_Date,
                c.sign as Sign_Date,
                c.completion as Completion_Date,
                ca.name as Nume_Categorie,
                dep.name as Departament,
                cf.name as Cashflow,
                ct.name as Tip_Contract,
                cc.name as Centru_Cost,
                us.name as Utilizator
	from public."ContractsAudit" c
    left join public."Partners" a on c."partnersId" = a.id 
	left join public."Partners" b on c."entityId" = b.id 
	left join public."Category" ca  on c."categoryId" = ca.id 
	left join public."ContractStatus" cs on cs."id" = c."statusId"
	left join public."Department" dep  on dep."id" = c."departmentId"
	left join public."Cashflow" cf on cf."id" = c."cashflowId"
	left join public."ContractType" ct on ct."id" = c."typeId"
	left join public."CostCenter"  cc on cc."id" = c."costcenterId"
	left join public."User" us on us."id" = c."userId"
where c.id = contractid;
    end;
    $$;


ALTER FUNCTION public.getauditcontract(contractid integer) OWNER TO postgres;

--
-- Name: remove_duplicates_from_table(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.remove_duplicates_from_table() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH duplicates AS (
        SELECT "workflowTaskSettingsId", "contractId", MAX("id") AS max_id
        FROM "WorkFlowXContracts"
        GROUP BY "workflowTaskSettingsId", "contractId"
        HAVING COUNT(*) > 1
    )
    DELETE FROM "WorkFlowXContracts" wfc
    USING duplicates d
    WHERE wfc."workflowTaskSettingsId" = d."workflowTaskSettingsId"
      AND wfc."contractId" = d."contractId"
      AND wfc."id" < d.max_id;
END;
$$;


ALTER FUNCTION public.remove_duplicates_from_table() OWNER TO sysadmin;

--
-- Name: remove_duplicates_from_table2(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.remove_duplicates_from_table2() RETURNS SETOF text
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH duplicates AS (
        SELECT "workflowTaskSettingsId", "contractId", MAX("id") AS max_id
        FROM "WorkFlowXContracts"
        GROUP BY "workflowTaskSettingsId", "contractId"
        HAVING COUNT(*) > 1
    )
    DELETE FROM "WorkFlowXContracts" wfc
    USING duplicates d
    WHERE wfc."workflowTaskSettingsId" = d."workflowTaskSettingsId"
      AND wfc."contractId" = d."contractId"
      AND wfc."id" < d.max_id;

    RETURN NEXT 'Duplicates removed successfully.';
END;
$$;


ALTER FUNCTION public.remove_duplicates_from_table2() OWNER TO sysadmin;

--
-- Name: remove_duplicates_from_task(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.remove_duplicates_from_task() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH duplicates AS (
        SELECT "contractId", wf."workflowTaskSettingsId",MAX("id") AS max_id
        FROM public."WorkFlowContractTasks" wf
        GROUP BY "workflowTaskSettingsId", "contractId"
        HAVING COUNT(*) > 1
    )
    DELETE FROM "WorkFlowContractTasks" wfc
    USING duplicates d
    WHERE wfc."workflowTaskSettingsId" = d."workflowTaskSettingsId"
      AND wfc."contractId" = d."contractId"
      AND wfc."id" < d.max_id;
END;
$$;


ALTER FUNCTION public.remove_duplicates_from_task() OWNER TO sysadmin;

--
-- Name: remove_duplicates_workflowxcontracts(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.remove_duplicates_workflowxcontracts() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH duplicates AS (
        SELECT "workflowTaskSettingsId", "contractId",
               ROW_NUMBER() OVER (PARTITION BY "workflowTaskSettingsId", "contractId" ORDER BY id) AS rn
        FROM "WorkFlowXContracts"
    )
    DELETE FROM "WorkFlowXContracts"
    WHERE ( "workflowTaskSettingsId", "contractId" ) IN (
        SELECT "workflowTaskSettingsId", "contractId"
        FROM duplicates
        WHERE rn > 1
    );
END;
$$;


ALTER FUNCTION public.remove_duplicates_workflowxcontracts() OWNER TO sysadmin;

--
-- Name: report_cashflow(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.report_cashflow() RETURNS TABLE(contractid integer, tiptranzactie text, partener text, entitate text, numarcontract text, start date, final date, descrierecontract text, cashflow text, data date, procentplusbnr double precision, procentpenalitate double precision, nrzilescadente integer, articol text, cantitate double precision, pretunitarinvaluta double precision, valoareinvaluta double precision, valuta text, cursvalutar double precision, valoareron numeric, platitincasat text, facturat text)
    LANGUAGE plpgsql
    AS $$
    BEGIN
    RETURN QUERY
SELECT c.id AS ContractId,
        CASE
            WHEN c."isPurchasing" = FALSE THEN 'Incasare'
            ELSE 'Plata'
        END AS TipTranzactie,
        p.name  AS Partener,
            e.name  AS Entitate,
                c.number AS NumarContract,
                    c.start::DATE Start,
                        c.end::DATE Final,
                            COALESCE(c.remarks, '') AS DescriereContract,
                                --cs.name AS status_name,
                                    COALESCE(c2.name, '') AS Cashflow,
                                        cfdb.date::DATE Data, --10
    cfd."currencyPercent" ProcentPlusBNR,
        cfd."billingPenaltyPercent" ProcentPenalitate,
            cfd."billingDueDays" NrZileScadente,
                it.name Articol,
                    cfdb."billingQtty" Cantitate,
                        cfdb."billingValue" PretUnitarInValuta,
                            (cfdb."billingQtty" * cfdb."billingValue") ValoareInValuta,
                                cr.code Valuta,
                                    er.amount CursValutar,
                                        ROUND((cfdb."billingQtty" * cfdb."billingValue" * er.amount):: NUMERIC, 2) AS ValoareRon,
                                            CASE
            WHEN cfdb."isPayed" = FALSE THEN 'Nu'
            ELSE 'Da'
        END AS PlatitIncasat,

        CASE
            WHEN cfdb."isInvoiced" = FALSE THEN 'Nu'
            ELSE 'Da'
        END AS Facturat

    FROM
    public."ContractItems" ci
	join public."Item" it on ci."itemid" = it."id"
	left join public."Contracts" c on c."id" = ci."contractId"
  	left join public."ContractFinancialDetail" cfd on cfd."contractItemId" = ci."id"
	left join public."ContractFinancialDetailSchedule" cfdb 
	left join public."Currency" cr on cr."id" = cfdb.currencyid
	left join(select * from public."ExchangeRates" 
		where public."ExchangeRates"."date" =
    (select max("date") from public."ExchangeRates") 
	) er  
	on er."name" = cr.code
	on cfdb."contractfinancialItemId" = cfd."id"
    JOIN
    public."ContractStatus" cs ON c."statusId" = cs.id
    JOIN
    "Partners" p ON p.id = c."partnersId"
    JOIN
    "Partners" e ON e.id = c."entityId"    
    LEFT JOIN
    "Cashflow" c2 ON c2.id = c."cashflowId" 
    LEFT JOIN
    "ContractType" ct ON ct.id = c."typeId" 
    LEFT JOIN
    "Banks" bp ON bp.id = c."partnerbankId"  
    LEFT JOIN
    "Banks" be ON be.id = c."entitybankId"
where ci.active is true and cfd.active is true and cfdb.active is true;
    END;
    $$;


ALTER FUNCTION public.report_cashflow() OWNER TO sysadmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Address; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Address" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "addressName" text,
    "addressType" text,
    "Country" text,
    "County" text,
    "City" text,
    "Street" text,
    "Number" text,
    "postalCode" text,
    "completeAddress" text,
    "partnerId" integer NOT NULL,
    "Status" boolean,
    "Default" boolean,
    aggregate boolean
);


ALTER TABLE public."Address" OWNER TO sysadmin;

--
-- Name: Address_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Address_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Address_id_seq" OWNER TO sysadmin;

--
-- Name: Address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Address_id_seq" OWNED BY public."Address".id;


--
-- Name: Alerts; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Alerts" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    "isActive" boolean NOT NULL,
    subject text NOT NULL,
    text text NOT NULL,
    internal_emails text NOT NULL,
    nrofdays integer NOT NULL,
    param text NOT NULL,
    "isActivePartner" boolean NOT NULL,
    "isActivePerson" boolean NOT NULL
);


ALTER TABLE public."Alerts" OWNER TO sysadmin;

--
-- Name: AlertsHistory; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."AlertsHistory" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "alertId" integer NOT NULL,
    "alertContent" text NOT NULL,
    "sentTo" text NOT NULL,
    "contractId" integer NOT NULL,
    criteria text NOT NULL,
    param text NOT NULL,
    nrofdays integer NOT NULL
);


ALTER TABLE public."AlertsHistory" OWNER TO sysadmin;

--
-- Name: AlertsHistory_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."AlertsHistory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."AlertsHistory_id_seq" OWNER TO sysadmin;

--
-- Name: AlertsHistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."AlertsHistory_id_seq" OWNED BY public."AlertsHistory".id;


--
-- Name: Alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Alerts_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Alerts_id_seq" OWNER TO sysadmin;

--
-- Name: Alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Alerts_id_seq" OWNED BY public."Alerts".id;


--
-- Name: Bank; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Bank" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Bank" OWNER TO sysadmin;

--
-- Name: Bank_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Bank_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Bank_id_seq" OWNER TO sysadmin;

--
-- Name: Bank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Bank_id_seq" OWNED BY public."Bank".id;


--
-- Name: Banks; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Banks" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "partnerId" integer NOT NULL,
    bank text,
    branch text,
    currency text,
    iban text,
    status boolean
);


ALTER TABLE public."Banks" OWNER TO sysadmin;

--
-- Name: Banks_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Banks_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Banks_id_seq" OWNER TO sysadmin;

--
-- Name: Banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Banks_id_seq" OWNED BY public."Banks".id;


--
-- Name: BillingFrequency; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."BillingFrequency" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."BillingFrequency" OWNER TO sysadmin;

--
-- Name: BillingFrequency_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."BillingFrequency_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."BillingFrequency_id_seq" OWNER TO sysadmin;

--
-- Name: BillingFrequency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."BillingFrequency_id_seq" OWNED BY public."BillingFrequency".id;


--
-- Name: Cashflow; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Cashflow" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Cashflow" OWNER TO sysadmin;

--
-- Name: Cashflow_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Cashflow_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Cashflow_id_seq" OWNER TO sysadmin;

--
-- Name: Cashflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Cashflow_id_seq" OWNED BY public."Cashflow".id;


--
-- Name: Category; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Category" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Category" OWNER TO sysadmin;

--
-- Name: Category_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Category_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Category_id_seq" OWNER TO sysadmin;

--
-- Name: Category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Category_id_seq" OWNED BY public."Category".id;


--
-- Name: ContractAlertSchedule; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractAlertSchedule" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "contractId" integer NOT NULL,
    "alertId" integer NOT NULL,
    alertname text NOT NULL,
    "datetoBeSent" timestamp(3) without time zone NOT NULL,
    "isActive" boolean NOT NULL,
    status boolean NOT NULL,
    subject text NOT NULL,
    nrofdays integer NOT NULL
);


ALTER TABLE public."ContractAlertSchedule" OWNER TO sysadmin;

--
-- Name: ContractAlertSchedule_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractAlertSchedule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractAlertSchedule_id_seq" OWNER TO sysadmin;

--
-- Name: ContractAlertSchedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractAlertSchedule_id_seq" OWNED BY public."ContractAlertSchedule".id;


--
-- Name: ContractAttachments; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractAttachments" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    size integer NOT NULL,
    path text NOT NULL,
    mimetype text NOT NULL,
    originalname text NOT NULL,
    encoding text NOT NULL,
    fieldname text NOT NULL,
    filename text NOT NULL,
    destination text NOT NULL,
    "contractId" integer
);


ALTER TABLE public."ContractAttachments" OWNER TO sysadmin;

--
-- Name: ContractAttachments_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractAttachments_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractAttachments_id_seq" OWNER TO sysadmin;

--
-- Name: ContractAttachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractAttachments_id_seq" OWNED BY public."ContractAttachments".id;


--
-- Name: ContractContent; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractContent" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    content text NOT NULL,
    "contractId" integer
);


ALTER TABLE public."ContractContent" OWNER TO sysadmin;

--
-- Name: ContractContent_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractContent_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractContent_id_seq" OWNER TO sysadmin;

--
-- Name: ContractContent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractContent_id_seq" OWNED BY public."ContractContent".id;


--
-- Name: ContractDynamicFields; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractDynamicFields" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "contractId" integer NOT NULL,
    "dffInt1" integer,
    "dffInt2" integer,
    "dffInt3" integer,
    "dffInt4" integer,
    "dffString1" text,
    "dffString2" text,
    "dffString3" text,
    "dffString4" text,
    "dffDate1" timestamp(3) without time zone,
    "dffDate2" timestamp(3) without time zone
);


ALTER TABLE public."ContractDynamicFields" OWNER TO sysadmin;

--
-- Name: ContractDynamicFields_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractDynamicFields_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractDynamicFields_id_seq" OWNER TO sysadmin;

--
-- Name: ContractDynamicFields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractDynamicFields_id_seq" OWNED BY public."ContractDynamicFields".id;


--
-- Name: ContractFinancialDetail; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractFinancialDetail" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    itemid integer,
    "currencyValue" double precision,
    "currencyPercent" double precision,
    "billingDay" integer NOT NULL,
    "billingQtty" double precision NOT NULL,
    "billingFrequencyid" integer,
    "measuringUnitid" integer,
    "paymentTypeid" integer,
    "billingPenaltyPercent" double precision NOT NULL,
    "billingDueDays" integer NOT NULL,
    remarks character varying(150),
    "guaranteeLetter" boolean,
    "guaranteeLetterCurrencyid" integer,
    "guaranteeLetterDate" timestamp(3) without time zone,
    "guaranteeLetterValue" double precision,
    "contractItemId" integer,
    active boolean DEFAULT true,
    price double precision NOT NULL,
    currencyid integer,
    "advancePercent" double precision,
    "goodexecutionLetter" boolean,
    "goodexecutionLetterBankId" integer,
    "goodexecutionLetterCurrencyId" integer,
    "goodexecutionLetterDate" timestamp(3) without time zone,
    "goodexecutionLetterInfo" text,
    "goodexecutionLetterValue" double precision,
    "guaranteeLetterBankId" integer,
    "guaranteeLetterInfo" text
);


ALTER TABLE public."ContractFinancialDetail" OWNER TO sysadmin;

--
-- Name: ContractFinancialDetailSchedule; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractFinancialDetailSchedule" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    itemid integer,
    date timestamp(3) without time zone NOT NULL,
    "measuringUnitid" integer,
    "billingQtty" double precision NOT NULL,
    "totalContractValue" double precision NOT NULL,
    "billingValue" double precision NOT NULL,
    "isInvoiced" boolean NOT NULL,
    "isPayed" boolean NOT NULL,
    currencyid integer,
    active boolean DEFAULT true NOT NULL,
    "contractfinancialItemId" integer
);


ALTER TABLE public."ContractFinancialDetailSchedule" OWNER TO sysadmin;

--
-- Name: ContractFinancialDetailSchedule_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractFinancialDetailSchedule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractFinancialDetailSchedule_id_seq" OWNER TO sysadmin;

--
-- Name: ContractFinancialDetailSchedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractFinancialDetailSchedule_id_seq" OWNED BY public."ContractFinancialDetailSchedule".id;


--
-- Name: ContractFinancialDetail_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractFinancialDetail_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractFinancialDetail_id_seq" OWNER TO sysadmin;

--
-- Name: ContractFinancialDetail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractFinancialDetail_id_seq" OWNED BY public."ContractFinancialDetail".id;


--
-- Name: ContractItems; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractItems" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "contractId" integer NOT NULL,
    itemid integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    "billingFrequencyid" integer NOT NULL,
    "currencyValue" double precision,
    currencyid integer NOT NULL
);


ALTER TABLE public."ContractItems" OWNER TO sysadmin;

--
-- Name: ContractItems_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractItems_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractItems_id_seq" OWNER TO sysadmin;

--
-- Name: ContractItems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractItems_id_seq" OWNED BY public."ContractItems".id;


--
-- Name: ContractStatus; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractStatus" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."ContractStatus" OWNER TO sysadmin;

--
-- Name: ContractStatus_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractStatus_id_seq" OWNER TO sysadmin;

--
-- Name: ContractStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractStatus_id_seq" OWNED BY public."ContractStatus".id;


--
-- Name: ContractTasks; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractTasks" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "taskName" text NOT NULL,
    "contractId" integer,
    due timestamp(3) without time zone NOT NULL,
    notes text NOT NULL,
    "assignedId" integer NOT NULL,
    "requestorId" integer NOT NULL,
    "statusId" integer NOT NULL,
    rejected_reason text NOT NULL,
    "taskPriorityId" integer NOT NULL,
    type text NOT NULL,
    uuid text NOT NULL
);


ALTER TABLE public."ContractTasks" OWNER TO sysadmin;

--
-- Name: ContractTasksDueDates; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractTasksDueDates" (
    id integer NOT NULL,
    name text NOT NULL,
    days integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."ContractTasksDueDates" OWNER TO sysadmin;

--
-- Name: ContractTasksDueDates_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractTasksDueDates_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractTasksDueDates_id_seq" OWNER TO sysadmin;

--
-- Name: ContractTasksDueDates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractTasksDueDates_id_seq" OWNED BY public."ContractTasksDueDates".id;


--
-- Name: ContractTasksPriority; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractTasksPriority" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."ContractTasksPriority" OWNER TO sysadmin;

--
-- Name: ContractTasksPriority_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractTasksPriority_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractTasksPriority_id_seq" OWNER TO sysadmin;

--
-- Name: ContractTasksPriority_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractTasksPriority_id_seq" OWNED BY public."ContractTasksPriority".id;


--
-- Name: ContractTasksReminders; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractTasksReminders" (
    id integer NOT NULL,
    name text NOT NULL,
    days integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."ContractTasksReminders" OWNER TO sysadmin;

--
-- Name: ContractTasksReminders_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractTasksReminders_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractTasksReminders_id_seq" OWNER TO sysadmin;

--
-- Name: ContractTasksReminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractTasksReminders_id_seq" OWNED BY public."ContractTasksReminders".id;


--
-- Name: ContractTasksStatus; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractTasksStatus" (
    id integer NOT NULL,
    name text NOT NULL,
    "Desription" text DEFAULT ''::text NOT NULL
);


ALTER TABLE public."ContractTasksStatus" OWNER TO sysadmin;

--
-- Name: ContractTasksStatus_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractTasksStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractTasksStatus_id_seq" OWNER TO sysadmin;

--
-- Name: ContractTasksStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractTasksStatus_id_seq" OWNED BY public."ContractTasksStatus".id;


--
-- Name: ContractTasks_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractTasks_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractTasks_id_seq" OWNER TO sysadmin;

--
-- Name: ContractTasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractTasks_id_seq" OWNED BY public."ContractTasks".id;


--
-- Name: ContractTemplates; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractTemplates" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    active boolean NOT NULL,
    "contractTypeId" integer,
    notes text NOT NULL,
    content text NOT NULL
);


ALTER TABLE public."ContractTemplates" OWNER TO sysadmin;

--
-- Name: ContractTemplates_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractTemplates_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractTemplates_id_seq" OWNER TO sysadmin;

--
-- Name: ContractTemplates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractTemplates_id_seq" OWNED BY public."ContractTemplates".id;


--
-- Name: ContractType; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractType" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."ContractType" OWNER TO sysadmin;

--
-- Name: ContractType_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractType_id_seq" OWNER TO sysadmin;

--
-- Name: ContractType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractType_id_seq" OWNED BY public."ContractType".id;


--
-- Name: Contracts; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Contracts" (
    id integer NOT NULL,
    number text NOT NULL,
    start timestamp(3) without time zone NOT NULL,
    "end" timestamp(3) without time zone NOT NULL,
    sign timestamp(3) without time zone,
    completion timestamp(3) without time zone,
    remarks text,
    "partnersId" integer NOT NULL,
    "entityId" integer NOT NULL,
    "entityaddressId" integer,
    "entitybankId" integer,
    "entitypersonsId" integer,
    "parentId" integer DEFAULT 0,
    "partneraddressId" integer,
    "partnerbankId" integer,
    "partnerpersonsId" integer,
    "automaticRenewal" boolean DEFAULT false,
    "departmentId" integer,
    "cashflowId" integer,
    "categoryId" integer,
    "costcenterId" integer DEFAULT 1 NOT NULL,
    "statusId" integer NOT NULL,
    "typeId" integer NOT NULL,
    "paymentTypeId" integer,
    "userId" integer,
    "isPurchasing" boolean DEFAULT false,
    "locationId" integer
);


ALTER TABLE public."Contracts" OWNER TO sysadmin;

--
-- Name: ContractsAudit; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractsAudit" (
    auditid integer NOT NULL,
    number text NOT NULL,
    "typeId" integer,
    "costcenterId" integer,
    "statusId" integer NOT NULL,
    start timestamp(3) without time zone,
    "end" timestamp(3) without time zone,
    sign timestamp(3) without time zone,
    completion timestamp(3) without time zone,
    remarks text,
    "categoryId" integer,
    "departmentId" integer,
    "cashflowId" integer,
    "automaticRenewal" boolean,
    "partnersId" integer,
    "entityId" integer,
    "parentId" integer,
    "partnerpersonsId" integer,
    "entitypersonsId" integer,
    "entityaddressId" integer,
    "partneraddressId" integer,
    "entitybankId" integer,
    "partnerbankId" integer,
    "contractAttachmentsId" integer,
    "paymentTypeId" integer,
    "contractContentId" integer,
    id integer NOT NULL,
    "operationType" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "userId" integer,
    "locationId" integer
);


ALTER TABLE public."ContractsAudit" OWNER TO sysadmin;

--
-- Name: ContractsAudit_auditid_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractsAudit_auditid_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractsAudit_auditid_seq" OWNER TO sysadmin;

--
-- Name: ContractsAudit_auditid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractsAudit_auditid_seq" OWNED BY public."ContractsAudit".auditid;


--
-- Name: Contracts_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Contracts_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Contracts_id_seq" OWNER TO sysadmin;

--
-- Name: Contracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Contracts_id_seq" OWNED BY public."Contracts".id;


--
-- Name: CostCenter; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."CostCenter" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."CostCenter" OWNER TO sysadmin;

--
-- Name: CostCenter_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."CostCenter_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."CostCenter_id_seq" OWNER TO sysadmin;

--
-- Name: CostCenter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."CostCenter_id_seq" OWNED BY public."CostCenter".id;


--
-- Name: Currency; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Currency" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Currency" OWNER TO sysadmin;

--
-- Name: Currency_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Currency_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Currency_id_seq" OWNER TO sysadmin;

--
-- Name: Currency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Currency_id_seq" OWNED BY public."Currency".id;


--
-- Name: Department; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Department" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Department" OWNER TO sysadmin;

--
-- Name: Department_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Department_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Department_id_seq" OWNER TO sysadmin;

--
-- Name: Department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Department_id_seq" OWNED BY public."Department".id;


--
-- Name: DynamicFields; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."DynamicFields" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fieldname text NOT NULL,
    fieldlabel text NOT NULL,
    fieldorder integer NOT NULL,
    fieldtype text NOT NULL
);


ALTER TABLE public."DynamicFields" OWNER TO sysadmin;

--
-- Name: DynamicFields_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."DynamicFields_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DynamicFields_id_seq" OWNER TO sysadmin;

--
-- Name: DynamicFields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."DynamicFields_id_seq" OWNED BY public."DynamicFields".id;


--
-- Name: ExchangeRates; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ExchangeRates" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    date text NOT NULL,
    amount double precision NOT NULL,
    name text NOT NULL,
    multiplier integer NOT NULL
);


ALTER TABLE public."ExchangeRates" OWNER TO sysadmin;

--
-- Name: ExchangeRates_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ExchangeRates_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ExchangeRates_id_seq" OWNER TO sysadmin;

--
-- Name: ExchangeRates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ExchangeRates_id_seq" OWNED BY public."ExchangeRates".id;


--
-- Name: Groups; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Groups" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text,
    description text
);


ALTER TABLE public."Groups" OWNER TO sysadmin;

--
-- Name: Groups_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Groups_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Groups_id_seq" OWNER TO sysadmin;

--
-- Name: Groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Groups_id_seq" OWNED BY public."Groups".id;


--
-- Name: Item; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Item" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Item" OWNER TO sysadmin;

--
-- Name: Item_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Item_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Item_id_seq" OWNER TO sysadmin;

--
-- Name: Item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Item_id_seq" OWNED BY public."Item".id;


--
-- Name: Location; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Location" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Location" OWNER TO sysadmin;

--
-- Name: Location_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Location_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Location_id_seq" OWNER TO sysadmin;

--
-- Name: Location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Location_id_seq" OWNED BY public."Location".id;


--
-- Name: MeasuringUnit; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."MeasuringUnit" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."MeasuringUnit" OWNER TO sysadmin;

--
-- Name: MeasuringUnit_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."MeasuringUnit_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."MeasuringUnit_id_seq" OWNER TO sysadmin;

--
-- Name: MeasuringUnit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."MeasuringUnit_id_seq" OWNED BY public."MeasuringUnit".id;


--
-- Name: Partners; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Partners" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    fiscal_code text NOT NULL,
    commercial_reg text NOT NULL,
    state text NOT NULL,
    type text NOT NULL,
    email text NOT NULL,
    remarks text NOT NULL,
    "contractsId" integer,
    "isVatPayer" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Partners" OWNER TO sysadmin;

--
-- Name: Partners_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Partners_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Partners_id_seq" OWNER TO sysadmin;

--
-- Name: Partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Partners_id_seq" OWNED BY public."Partners".id;


--
-- Name: PaymentType; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."PaymentType" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."PaymentType" OWNER TO sysadmin;

--
-- Name: PaymentType_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."PaymentType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."PaymentType_id_seq" OWNER TO sysadmin;

--
-- Name: PaymentType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."PaymentType_id_seq" OWNED BY public."PaymentType".id;


--
-- Name: Persons; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Persons" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name text NOT NULL,
    phone text,
    email text,
    "partnerId" integer NOT NULL,
    role text,
    legalrepresent boolean
);


ALTER TABLE public."Persons" OWNER TO sysadmin;

--
-- Name: Persons_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Persons_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Persons_id_seq" OWNER TO sysadmin;

--
-- Name: Persons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Persons_id_seq" OWNED BY public."Persons".id;


--
-- Name: Role; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Role" (
    id integer NOT NULL,
    "roleName" text NOT NULL
);


ALTER TABLE public."Role" OWNER TO sysadmin;

--
-- Name: Role_User; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."Role_User" (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "roleId" integer NOT NULL
);


ALTER TABLE public."Role_User" OWNER TO sysadmin;

--
-- Name: Role_User_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Role_User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Role_User_id_seq" OWNER TO sysadmin;

--
-- Name: Role_User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Role_User_id_seq" OWNED BY public."Role_User".id;


--
-- Name: Role_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."Role_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Role_id_seq" OWNER TO sysadmin;

--
-- Name: Role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."Role_id_seq" OWNED BY public."Role".id;


--
-- Name: User; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."User" (
    id integer NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    picture text,
    status boolean NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."User" OWNER TO sysadmin;

--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."User_id_seq" OWNER TO sysadmin;

--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- Name: WorkFlow; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."WorkFlow" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "wfName" text NOT NULL,
    "wfDescription" text NOT NULL,
    status boolean NOT NULL
);


ALTER TABLE public."WorkFlow" OWNER TO sysadmin;

--
-- Name: WorkFlowContractTasks; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."WorkFlowContractTasks" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "contractId" integer,
    "statusId" integer NOT NULL,
    "requestorId" integer NOT NULL,
    "assignedId" integer NOT NULL,
    "workflowTaskSettingsId" integer NOT NULL,
    "approvalOrderNumber" integer NOT NULL,
    duedates timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    reminders timestamp(3) without time zone NOT NULL,
    "taskPriorityId" integer NOT NULL,
    text text NOT NULL,
    uuid text NOT NULL
);


ALTER TABLE public."WorkFlowContractTasks" OWNER TO sysadmin;

--
-- Name: WorkFlowContractTasks_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."WorkFlowContractTasks_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."WorkFlowContractTasks_id_seq" OWNER TO sysadmin;

--
-- Name: WorkFlowContractTasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."WorkFlowContractTasks_id_seq" OWNED BY public."WorkFlowContractTasks".id;


--
-- Name: WorkFlowRejectActions; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."WorkFlowRejectActions" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "workflowId" integer NOT NULL,
    "sendNotificationsToAllApprovers" boolean NOT NULL,
    "sendNotificationsToContractResponsible" boolean NOT NULL
);


ALTER TABLE public."WorkFlowRejectActions" OWNER TO sysadmin;

--
-- Name: WorkFlowRejectActions_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."WorkFlowRejectActions_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."WorkFlowRejectActions_id_seq" OWNER TO sysadmin;

--
-- Name: WorkFlowRejectActions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."WorkFlowRejectActions_id_seq" OWNED BY public."WorkFlowRejectActions".id;


--
-- Name: WorkFlowRules; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."WorkFlowRules" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "workflowId" integer NOT NULL,
    "ruleFilterSource" text NOT NULL,
    "ruleFilterName" text NOT NULL,
    "ruleFilterValue" integer NOT NULL,
    "ruleFilterValueName" text DEFAULT 'NA'::text NOT NULL
);


ALTER TABLE public."WorkFlowRules" OWNER TO sysadmin;

--
-- Name: WorkFlowRules_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."WorkFlowRules_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."WorkFlowRules_id_seq" OWNER TO sysadmin;

--
-- Name: WorkFlowRules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."WorkFlowRules_id_seq" OWNED BY public."WorkFlowRules".id;


--
-- Name: WorkFlowTaskSettings; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."WorkFlowTaskSettings" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "workflowId" integer NOT NULL,
    "taskName" text NOT NULL,
    "taskNotes" text NOT NULL,
    "taskSendNotifications" boolean NOT NULL,
    "taskSendReminders" boolean NOT NULL,
    "taskReminderId" integer NOT NULL,
    "taskPriorityId" integer NOT NULL,
    "taskDueDateId" integer NOT NULL
);


ALTER TABLE public."WorkFlowTaskSettings" OWNER TO sysadmin;

--
-- Name: WorkFlowTaskSettingsUsers; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."WorkFlowTaskSettingsUsers" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "workflowTaskSettingsId" integer NOT NULL,
    "userId" integer NOT NULL,
    "approvalOrderNumber" integer NOT NULL,
    "approvalStepName" text NOT NULL
);


ALTER TABLE public."WorkFlowTaskSettingsUsers" OWNER TO sysadmin;

--
-- Name: WorkFlowTaskSettingsUsers_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."WorkFlowTaskSettingsUsers_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."WorkFlowTaskSettingsUsers_id_seq" OWNER TO sysadmin;

--
-- Name: WorkFlowTaskSettingsUsers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."WorkFlowTaskSettingsUsers_id_seq" OWNED BY public."WorkFlowTaskSettingsUsers".id;


--
-- Name: WorkFlowTaskSettings_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."WorkFlowTaskSettings_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."WorkFlowTaskSettings_id_seq" OWNER TO sysadmin;

--
-- Name: WorkFlowTaskSettings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."WorkFlowTaskSettings_id_seq" OWNED BY public."WorkFlowTaskSettings".id;


--
-- Name: WorkFlowXContracts; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."WorkFlowXContracts" (
    id integer NOT NULL,
    "updateadAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "contractId" integer,
    "wfstatusId" integer NOT NULL,
    "ctrstatusId" integer NOT NULL,
    "workflowTaskSettingsId" integer NOT NULL
);


ALTER TABLE public."WorkFlowXContracts" OWNER TO sysadmin;

--
-- Name: WorkFlowXContracts_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."WorkFlowXContracts_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."WorkFlowXContracts_id_seq" OWNER TO sysadmin;

--
-- Name: WorkFlowXContracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."WorkFlowXContracts_id_seq" OWNED BY public."WorkFlowXContracts".id;


--
-- Name: WorkFlow_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."WorkFlow_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."WorkFlow_id_seq" OWNER TO sysadmin;

--
-- Name: WorkFlow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."WorkFlow_id_seq" OWNED BY public."WorkFlow".id;


--
-- Name: _GroupsToPartners; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."_GroupsToPartners" (
    "A" integer NOT NULL,
    "B" integer NOT NULL
);


ALTER TABLE public."_GroupsToPartners" OWNER TO sysadmin;

--
-- Name: _GroupsToUser; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."_GroupsToUser" (
    "A" integer NOT NULL,
    "B" integer NOT NULL
);


ALTER TABLE public."_GroupsToUser" OWNER TO sysadmin;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO sysadmin;

--
-- Name: Address id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Address" ALTER COLUMN id SET DEFAULT nextval('public."Address_id_seq"'::regclass);


--
-- Name: Alerts id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Alerts" ALTER COLUMN id SET DEFAULT nextval('public."Alerts_id_seq"'::regclass);


--
-- Name: AlertsHistory id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."AlertsHistory" ALTER COLUMN id SET DEFAULT nextval('public."AlertsHistory_id_seq"'::regclass);


--
-- Name: Bank id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Bank" ALTER COLUMN id SET DEFAULT nextval('public."Bank_id_seq"'::regclass);


--
-- Name: Banks id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Banks" ALTER COLUMN id SET DEFAULT nextval('public."Banks_id_seq"'::regclass);


--
-- Name: BillingFrequency id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."BillingFrequency" ALTER COLUMN id SET DEFAULT nextval('public."BillingFrequency_id_seq"'::regclass);


--
-- Name: Cashflow id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Cashflow" ALTER COLUMN id SET DEFAULT nextval('public."Cashflow_id_seq"'::regclass);


--
-- Name: Category id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Category" ALTER COLUMN id SET DEFAULT nextval('public."Category_id_seq"'::regclass);


--
-- Name: ContractAlertSchedule id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractAlertSchedule" ALTER COLUMN id SET DEFAULT nextval('public."ContractAlertSchedule_id_seq"'::regclass);


--
-- Name: ContractAttachments id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractAttachments" ALTER COLUMN id SET DEFAULT nextval('public."ContractAttachments_id_seq"'::regclass);


--
-- Name: ContractContent id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractContent" ALTER COLUMN id SET DEFAULT nextval('public."ContractContent_id_seq"'::regclass);


--
-- Name: ContractDynamicFields id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractDynamicFields" ALTER COLUMN id SET DEFAULT nextval('public."ContractDynamicFields_id_seq"'::regclass);


--
-- Name: ContractFinancialDetail id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail" ALTER COLUMN id SET DEFAULT nextval('public."ContractFinancialDetail_id_seq"'::regclass);


--
-- Name: ContractFinancialDetailSchedule id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetailSchedule" ALTER COLUMN id SET DEFAULT nextval('public."ContractFinancialDetailSchedule_id_seq"'::regclass);


--
-- Name: ContractItems id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractItems" ALTER COLUMN id SET DEFAULT nextval('public."ContractItems_id_seq"'::regclass);


--
-- Name: ContractStatus id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractStatus" ALTER COLUMN id SET DEFAULT nextval('public."ContractStatus_id_seq"'::regclass);


--
-- Name: ContractTasks id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasks" ALTER COLUMN id SET DEFAULT nextval('public."ContractTasks_id_seq"'::regclass);


--
-- Name: ContractTasksDueDates id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasksDueDates" ALTER COLUMN id SET DEFAULT nextval('public."ContractTasksDueDates_id_seq"'::regclass);


--
-- Name: ContractTasksPriority id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasksPriority" ALTER COLUMN id SET DEFAULT nextval('public."ContractTasksPriority_id_seq"'::regclass);


--
-- Name: ContractTasksReminders id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasksReminders" ALTER COLUMN id SET DEFAULT nextval('public."ContractTasksReminders_id_seq"'::regclass);


--
-- Name: ContractTasksStatus id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasksStatus" ALTER COLUMN id SET DEFAULT nextval('public."ContractTasksStatus_id_seq"'::regclass);


--
-- Name: ContractTemplates id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTemplates" ALTER COLUMN id SET DEFAULT nextval('public."ContractTemplates_id_seq"'::regclass);


--
-- Name: ContractType id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractType" ALTER COLUMN id SET DEFAULT nextval('public."ContractType_id_seq"'::regclass);


--
-- Name: Contracts id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts" ALTER COLUMN id SET DEFAULT nextval('public."Contracts_id_seq"'::regclass);


--
-- Name: ContractsAudit auditid; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractsAudit" ALTER COLUMN auditid SET DEFAULT nextval('public."ContractsAudit_auditid_seq"'::regclass);


--
-- Name: CostCenter id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."CostCenter" ALTER COLUMN id SET DEFAULT nextval('public."CostCenter_id_seq"'::regclass);


--
-- Name: Currency id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Currency" ALTER COLUMN id SET DEFAULT nextval('public."Currency_id_seq"'::regclass);


--
-- Name: Department id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Department" ALTER COLUMN id SET DEFAULT nextval('public."Department_id_seq"'::regclass);


--
-- Name: DynamicFields id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."DynamicFields" ALTER COLUMN id SET DEFAULT nextval('public."DynamicFields_id_seq"'::regclass);


--
-- Name: ExchangeRates id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ExchangeRates" ALTER COLUMN id SET DEFAULT nextval('public."ExchangeRates_id_seq"'::regclass);


--
-- Name: Groups id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Groups" ALTER COLUMN id SET DEFAULT nextval('public."Groups_id_seq"'::regclass);


--
-- Name: Item id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Item" ALTER COLUMN id SET DEFAULT nextval('public."Item_id_seq"'::regclass);


--
-- Name: Location id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Location" ALTER COLUMN id SET DEFAULT nextval('public."Location_id_seq"'::regclass);


--
-- Name: MeasuringUnit id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."MeasuringUnit" ALTER COLUMN id SET DEFAULT nextval('public."MeasuringUnit_id_seq"'::regclass);


--
-- Name: Partners id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Partners" ALTER COLUMN id SET DEFAULT nextval('public."Partners_id_seq"'::regclass);


--
-- Name: PaymentType id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."PaymentType" ALTER COLUMN id SET DEFAULT nextval('public."PaymentType_id_seq"'::regclass);


--
-- Name: Persons id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Persons" ALTER COLUMN id SET DEFAULT nextval('public."Persons_id_seq"'::regclass);


--
-- Name: Role id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Role" ALTER COLUMN id SET DEFAULT nextval('public."Role_id_seq"'::regclass);


--
-- Name: Role_User id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Role_User" ALTER COLUMN id SET DEFAULT nextval('public."Role_User_id_seq"'::regclass);


--
-- Name: User id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- Name: WorkFlow id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlow" ALTER COLUMN id SET DEFAULT nextval('public."WorkFlow_id_seq"'::regclass);


--
-- Name: WorkFlowContractTasks id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowContractTasks" ALTER COLUMN id SET DEFAULT nextval('public."WorkFlowContractTasks_id_seq"'::regclass);


--
-- Name: WorkFlowRejectActions id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowRejectActions" ALTER COLUMN id SET DEFAULT nextval('public."WorkFlowRejectActions_id_seq"'::regclass);


--
-- Name: WorkFlowRules id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowRules" ALTER COLUMN id SET DEFAULT nextval('public."WorkFlowRules_id_seq"'::regclass);


--
-- Name: WorkFlowTaskSettings id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettings" ALTER COLUMN id SET DEFAULT nextval('public."WorkFlowTaskSettings_id_seq"'::regclass);


--
-- Name: WorkFlowTaskSettingsUsers id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettingsUsers" ALTER COLUMN id SET DEFAULT nextval('public."WorkFlowTaskSettingsUsers_id_seq"'::regclass);


--
-- Name: WorkFlowXContracts id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowXContracts" ALTER COLUMN id SET DEFAULT nextval('public."WorkFlowXContracts_id_seq"'::regclass);


--
-- Data for Name: Address; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Address" (id, "updateadAt", "createdAt", "addressName", "addressType", "Country", "County", "City", "Street", "Number", "postalCode", "completeAddress", "partnerId", "Status", "Default", aggregate) FROM stdin;
1	2024-04-01 10:28:11.773	2024-04-01 10:28:11.773	Bucuresti	Adresa Sociala	Romania	Bucureşti	Sector 3	Vlad Judetul	2		Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:	1	t	t	t
2	2024-04-01 10:30:31.725	2024-04-01 10:30:31.725	Traian	Adresa Comerciala	Romania	Bucureşti	Sector 3	Traian	234	234	Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234	3	t	t	t
3	2024-04-19 11:30:54.178	2024-04-19 11:30:54.178	Dragonul Rosu	Adresa Comerciala	Romania	Ilfov	Dobroeşti	Dragonul Rosu	Nr 1-10		Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal:	4	t	t	t
\.


--
-- Data for Name: Alerts; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Alerts" (id, "updateadAt", "createdAt", name, "isActive", subject, text, internal_emails, nrofdays, param, "isActivePartner", "isActivePerson") FROM stdin;
2	2024-05-06 13:41:16.59	2024-04-01 10:24:45.162	Expirare Contract	t	Expirare Contract	Va informam faptul ca urmeaza sa expire contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract este in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.	office@companie.ro	30	Data Final	f	f
1	2024-05-06 17:28:53.205	2024-04-01 10:24:45.162	Contract Inchis inainte de termen	t	Contract Inchis inainte de termen	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">ContractNumber</span> din data de <span style="color: rgb(230, 0, 0);">StartDate</span> la partenerul <span style="color: rgb(230, 0, 0);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">EntityName</span> si reprezinta <span style="color: rgb(230, 0, 0);">ShortDescription</span>.</h2>	office@companie.ro	0	Inchis la data	f	f
\.


--
-- Data for Name: AlertsHistory; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."AlertsHistory" (id, "updateadAt", "createdAt", "alertId", "alertContent", "sentTo", "contractId", criteria, param, nrofdays) FROM stdin;
1	2024-04-02 07:00:00.081	2024-04-02 07:00:00.081	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
2	2024-04-03 07:00:00.066	2024-04-03 07:00:00.066	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
3	2024-04-04 07:00:00.1	2024-04-04 07:00:00.1	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
4	2024-04-05 07:00:00.056	2024-04-05 07:00:00.056	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
5	2024-04-08 07:00:00.214	2024-04-08 07:00:00.214	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
7	2024-04-09 07:00:00.085	2024-04-09 07:00:00.085	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 03.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
6	2024-04-09 07:00:00.084	2024-04-09 07:00:00.084	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
8	2024-04-21 07:00:00.109	2024-04-21 07:00:00.109	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 08.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
9	2024-04-21 07:00:00.109	2024-04-21 07:00:00.109	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 08.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
10	2024-04-23 07:00:00.142	2024-04-23 07:00:00.142	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
11	2024-04-23 07:00:00.149	2024-04-23 07:00:00.149	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
12	2024-04-23 07:00:00.148	2024-04-23 07:00:00.148	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
13	2024-04-23 07:00:00.152	2024-04-23 07:00:00.152	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
14	2024-04-23 07:00:00.154	2024-04-23 07:00:00.154	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
15	2024-04-24 07:00:00.014	2024-04-24 07:00:00.014	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
16	2024-04-24 07:00:00.039	2024-04-24 07:00:00.039	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
17	2024-04-24 07:00:00.044	2024-04-24 07:00:00.044	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
18	2024-04-24 07:00:00.05	2024-04-24 07:00:00.05	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
19	2024-04-24 07:00:00.052	2024-04-24 07:00:00.052	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
20	2024-04-26 07:00:00.039	2024-04-26 07:00:00.039	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
21	2024-04-26 07:00:00.04	2024-04-26 07:00:00.04	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
22	2024-04-26 07:00:00.06	2024-04-26 07:00:00.06	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
23	2024-04-26 07:00:00.066	2024-04-26 07:00:00.066	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
24	2024-04-26 07:00:00.067	2024-04-26 07:00:00.067	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
25	2024-04-29 07:00:00.053	2024-04-29 07:00:00.053	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
26	2024-04-29 07:00:00.069	2024-04-29 07:00:00.069	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
27	2024-04-29 07:00:00.124	2024-04-29 07:00:00.124	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
28	2024-04-29 07:00:00.127	2024-04-29 07:00:00.127	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
29	2024-04-29 07:00:00.132	2024-04-29 07:00:00.132	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
30	2024-04-29 07:00:00.138	2024-04-29 07:00:00.138	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
31	2024-04-30 07:00:00.049	2024-04-30 07:00:00.049	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
32	2024-04-30 07:00:00.059	2024-04-30 07:00:00.059	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
33	2024-04-30 07:00:00.073	2024-04-30 07:00:00.073	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
34	2024-04-30 07:00:00.077	2024-04-30 07:00:00.077	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
35	2024-04-30 07:00:00.05	2024-04-30 07:00:00.05	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
36	2024-04-30 07:00:00.085	2024-04-30 07:00:00.085	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
37	2024-05-02 07:00:00.053	2024-05-02 07:00:00.053	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
38	2024-05-02 07:00:00.057	2024-05-02 07:00:00.057	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 08.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	45	Data Final	end	30
39	2024-05-02 07:00:00.073	2024-05-02 07:00:00.073	1	Va informam faptul ca a fost inchis contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
40	2024-05-02 07:00:00.074	2024-05-02 07:00:00.074	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
41	2024-05-02 07:00:00.077	2024-05-02 07:00:00.077	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
42	2024-05-02 07:00:00.08	2024-05-02 07:00:00.08	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
43	2024-05-02 07:00:00.083	2024-05-02 07:00:00.083	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
44	2024-05-02 07:00:00.089	2024-05-02 07:00:00.089	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 23423.	to: a@a.com bcc:razvan.mustata@gmail.com	40	Data Final	end	30
45	2024-05-02 07:00:00.093	2024-05-02 07:00:00.093	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
46	2024-05-02 07:00:00.102	2024-05-02 07:00:00.102	2	Va informam faptul ca urmeaza sa expire contractul cu numarul ert din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta ert.	to: a@a.com bcc:razvan.mustata@gmail.com	41	Data Final	end	30
47	2024-05-02 07:00:00.105	2024-05-02 07:00:00.105	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	42	Data Final	end	30
48	2024-05-02 07:00:00.108	2024-05-02 07:00:00.108	2	Va informam faptul ca urmeaza sa expire contractul cu numarul teste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta et.	to: a@a.com bcc:razvan.mustata@gmail.com	47	Data Final	end	30
49	2024-05-04 07:00:00.055	2024-05-04 07:00:00.055	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
50	2024-05-04 07:00:00.103	2024-05-04 07:00:00.103	1	Va informam faptul ca a fost inchis contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
51	2024-05-04 07:00:00.104	2024-05-04 07:00:00.104	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 08.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	45	Data Final	end	30
53	2024-05-04 07:00:00.112	2024-05-04 07:00:00.112	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
55	2024-05-04 07:00:00.117	2024-05-04 07:00:00.117	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
64	2024-05-04 07:00:00.2	2024-05-04 07:00:00.2	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234 din data de 23.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	51	Data Final	end	30
52	2024-05-04 07:00:00.112	2024-05-04 07:00:00.112	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
54	2024-05-04 07:00:00.115	2024-05-04 07:00:00.115	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
56	2024-05-04 07:00:00.119	2024-05-04 07:00:00.119	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 23423.	to: a@a.com bcc:razvan.mustata@gmail.com	40	Data Final	end	30
57	2024-05-04 07:00:00.174	2024-05-04 07:00:00.174	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
58	2024-05-04 07:00:00.186	2024-05-04 07:00:00.186	2	Va informam faptul ca urmeaza sa expire contractul cu numarul ert din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta ert.	to: a@a.com bcc:razvan.mustata@gmail.com	41	Data Final	end	30
59	2024-05-04 07:00:00.189	2024-05-04 07:00:00.189	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	42	Data Final	end	30
60	2024-05-04 07:00:00.191	2024-05-04 07:00:00.191	2	Va informam faptul ca urmeaza sa expire contractul cu numarul teste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta et.	to: a@a.com bcc:razvan.mustata@gmail.com	47	Data Final	end	30
61	2024-05-04 07:00:00.193	2024-05-04 07:00:00.193	2	Va informam faptul ca urmeaza sa expire contractul cu numarul rrr din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta rrr.	to: a@a.com bcc:razvan.mustata@gmail.com	53	Data Final	end	30
62	2024-05-04 07:00:00.196	2024-05-04 07:00:00.196	2	Va informam faptul ca urmeaza sa expire contractul cu numarul testeteste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta testeteste.	to: a@a.com bcc:razvan.mustata@gmail.com	49	Data Final	end	30
63	2024-05-04 07:00:00.198	2024-05-04 07:00:00.198	2	Va informam faptul ca urmeaza sa expire contractul cu numarul reject din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta reject.	to: a@a.com bcc:razvan.mustata@gmail.com	50	Data Final	end	30
65	2024-05-04 07:00:00.201	2024-05-04 07:00:00.201	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	52	Data Final	end	30
66	2024-05-06 07:00:00.113	2024-05-06 07:00:00.113	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
67	2024-05-06 07:00:00.128	2024-05-06 07:00:00.128	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 08.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	45	Data Final	end	30
68	2024-05-06 07:00:00.23	2024-05-06 07:00:00.23	1	Va informam faptul ca a fost inchis contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
69	2024-05-06 07:00:00.235	2024-05-06 07:00:00.235	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
70	2024-05-06 07:00:00.235	2024-05-06 07:00:00.235	1	Va informam faptul ca a fost inchis contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract a fost in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
71	2024-05-06 07:00:00.237	2024-05-06 07:00:00.237	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
72	2024-05-06 07:00:00.24	2024-05-06 07:00:00.24	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
73	2024-05-06 07:00:00.245	2024-05-06 07:00:00.245	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 23423.	to: a@a.com bcc:razvan.mustata@gmail.com	40	Data Final	end	30
74	2024-05-06 07:00:00.247	2024-05-06 07:00:00.247	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
75	2024-05-06 07:00:00.249	2024-05-06 07:00:00.249	2	Va informam faptul ca urmeaza sa expire contractul cu numarul ert din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta ert.	to: a@a.com bcc:razvan.mustata@gmail.com	41	Data Final	end	30
76	2024-05-06 07:00:00.251	2024-05-06 07:00:00.251	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	42	Data Final	end	30
77	2024-05-06 07:00:00.252	2024-05-06 07:00:00.252	2	Va informam faptul ca urmeaza sa expire contractul cu numarul teste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta et.	to: a@a.com bcc:razvan.mustata@gmail.com	47	Data Final	end	30
78	2024-05-06 07:00:00.254	2024-05-06 07:00:00.254	2	Va informam faptul ca urmeaza sa expire contractul cu numarul rrr din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta rrr.	to: a@a.com bcc:razvan.mustata@gmail.com	53	Data Final	end	30
79	2024-05-06 07:00:00.255	2024-05-06 07:00:00.255	2	Va informam faptul ca urmeaza sa expire contractul cu numarul testeteste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta testeteste.	to: a@a.com bcc:razvan.mustata@gmail.com	49	Data Final	end	30
80	2024-05-06 07:00:00.256	2024-05-06 07:00:00.256	2	Va informam faptul ca urmeaza sa expire contractul cu numarul reject din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta reject.	to: a@a.com bcc:razvan.mustata@gmail.com	50	Data Final	end	30
81	2024-05-06 07:00:00.259	2024-05-06 07:00:00.259	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234 din data de 23.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	51	Data Final	end	30
82	2024-05-06 07:00:00.26	2024-05-06 07:00:00.26	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	52	Data Final	end	30
83	2024-05-06 13:59:45.198	2024-05-06 13:59:45.198	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(0, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
84	2024-05-06 13:59:45.339	2024-05-06 13:59:45.339	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(2, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
85	2024-05-06 13:59:45.375	2024-05-06 13:59:45.375	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(0, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
86	2024-05-06 13:59:50.111	2024-05-06 13:59:50.111	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(0, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
87	2024-05-06 13:59:50.137	2024-05-06 13:59:50.137	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(2, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
88	2024-05-06 13:59:50.164	2024-05-06 13:59:50.164	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(0, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
89	2024-05-06 13:59:55.044	2024-05-06 13:59:55.044	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(0, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
90	2024-05-06 13:59:55.068	2024-05-06 13:59:55.068	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(2, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
91	2024-05-06 13:59:55.091	2024-05-06 13:59:55.091	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(0, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
92	2024-05-06 14:03:00.327	2024-05-06 14:03:00.327	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(0, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
93	2024-05-06 14:03:00.389	2024-05-06 14:03:00.389	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(2, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
94	2024-05-06 14:03:00.526	2024-05-06 14:03:00.526	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(> 5, a5, 2m, <.fn); background-color: rgb(a2, c, ip);">ContractNumber</span> din data de <span style="background-color: rgb(t, 50, <); color: rgba(0, 255, 255, 0.5);">StartDate</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ShortDescription</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
95	2024-05-06 14:04:20.261	2024-05-06 14:04:20.261	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(255, 255, 255, 0.87); background-color: rgb(42, 50, 61);">1</span> din data de <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">09.04.2024</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">NIRO INVESTMENT SA</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
96	2024-05-06 14:04:20.433	2024-05-06 14:04:20.433	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(255, 255, 255, 0.87); background-color: rgb(42, 50, 61);">n2</span> din data de <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">02.04.2024</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">DRAGONUL ROSU SA </span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">n2</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
97	2024-05-06 14:04:20.479	2024-05-06 14:04:20.479	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(255, 255, 255, 0.87); background-color: rgb(42, 50, 61);">1</span> din data de <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">11.04.2024</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">NIRO INVESTMENT SA</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
98	2024-05-06 17:24:00.101	2024-05-06 17:24:00.101	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(255, 255, 255, 0.87); background-color: rgb(42, 50, 61);">1</span> din data de <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">09.04.2024</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">NIRO INVESTMENT SA</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
99	2024-05-06 17:24:00.192	2024-05-06 17:24:00.192	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(255, 255, 255, 0.87); background-color: rgb(42, 50, 61);">n2</span> din data de <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">02.04.2024</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">DRAGONUL ROSU SA </span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">n2</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
100	2024-05-06 17:24:00.212	2024-05-06 17:24:00.212	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgba(255, 255, 255, 0.87); background-color: rgb(42, 50, 61);">1</span> din data de <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">11.04.2024</span> la partenerul <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">NIRO INVESTMENT SA</span> si reprezinta <span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
101	2024-05-06 17:26:05.047	2024-05-06 17:26:05.047	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
102	2024-05-06 17:26:05.123	2024-05-06 17:26:05.123	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">n2</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
103	2024-05-06 17:26:05.18	2024-05-06 17:26:05.18	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
104	2024-05-06 17:26:10.053	2024-05-06 17:26:10.053	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
105	2024-05-06 17:26:10.081	2024-05-06 17:26:10.081	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">n2</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
106	2024-05-06 17:26:10.097	2024-05-06 17:26:10.097	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
107	2024-05-06 17:26:15.053	2024-05-06 17:26:15.053	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
108	2024-05-06 17:26:15.066	2024-05-06 17:26:15.066	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">n2</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
109	2024-05-06 17:26:15.079	2024-05-06 17:26:15.079	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
110	2024-05-06 17:26:20.038	2024-05-06 17:26:20.038	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
111	2024-05-06 17:26:20.055	2024-05-06 17:26:20.055	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">n2</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
112	2024-05-06 17:26:20.068	2024-05-06 17:26:20.068	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
113	2024-05-06 17:26:25.045	2024-05-06 17:26:25.045	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
114	2024-05-06 17:26:25.055	2024-05-06 17:26:25.055	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">n2</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
115	2024-05-06 17:26:25.093	2024-05-06 17:26:25.093	1	<p>Va informam faptul ca a fost inchis contractul cu numarul <span style="background-color: rgb(42, 50, 61); color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0); background-color: rgb(42, 50, 61);">Vanzare</span>.</p>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
116	2024-05-06 17:29:10.048	2024-05-06 17:29:10.048	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
117	2024-05-06 17:29:10.142	2024-05-06 17:29:10.142	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0);">n2</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
118	2024-05-06 17:29:10.206	2024-05-06 17:29:10.206	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
119	2024-05-07 07:00:00.285	2024-05-07 07:00:00.285	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	56	Data Final	end	30
120	2024-05-07 07:00:00.319	2024-05-07 07:00:00.319	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 08.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	45	Data Final	end	30
121	2024-05-07 07:00:00.339	2024-05-07 07:00:00.339	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
122	2024-05-07 07:00:00.346	2024-05-07 07:00:00.346	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
123	2024-05-07 07:00:00.373	2024-05-07 07:00:00.373	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
124	2024-05-07 07:00:00.373	2024-05-07 07:00:00.373	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
125	2024-05-07 07:00:00.376	2024-05-07 07:00:00.376	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 23423.	to: a@a.com bcc:razvan.mustata@gmail.com	40	Data Final	end	30
126	2024-05-07 07:00:00.378	2024-05-07 07:00:00.378	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
127	2024-05-07 07:00:00.38	2024-05-07 07:00:00.38	2	Va informam faptul ca urmeaza sa expire contractul cu numarul ert din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta ert.	to: a@a.com bcc:razvan.mustata@gmail.com	41	Data Final	end	30
128	2024-05-07 07:00:00.384	2024-05-07 07:00:00.384	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	42	Data Final	end	30
129	2024-05-07 07:00:00.385	2024-05-07 07:00:00.385	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0);">n2</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
130	2024-05-07 07:00:00.416	2024-05-07 07:00:00.416	2	Va informam faptul ca urmeaza sa expire contractul cu numarul teste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta et.	to: a@a.com bcc:razvan.mustata@gmail.com	47	Data Final	end	30
131	2024-05-07 07:00:00.419	2024-05-07 07:00:00.419	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	57	Data Final	end	30
132	2024-05-07 07:00:00.421	2024-05-07 07:00:00.421	2	Va informam faptul ca urmeaza sa expire contractul cu numarul rrr din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta rrr.	to: a@a.com bcc:razvan.mustata@gmail.com	53	Data Final	end	30
133	2024-05-07 07:00:00.423	2024-05-07 07:00:00.423	2	Va informam faptul ca urmeaza sa expire contractul cu numarul testeteste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta testeteste.	to: a@a.com bcc:razvan.mustata@gmail.com	49	Data Final	end	30
134	2024-05-07 07:00:00.424	2024-05-07 07:00:00.424	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 435453 din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 35.	to: a@a.com bcc:razvan.mustata@gmail.com	54	Data Final	end	30
135	2024-05-07 07:00:00.426	2024-05-07 07:00:00.426	2	Va informam faptul ca urmeaza sa expire contractul cu numarul reject din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta reject.	to: a@a.com bcc:razvan.mustata@gmail.com	50	Data Final	end	30
136	2024-05-07 07:00:00.427	2024-05-07 07:00:00.427	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234 din data de 23.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	51	Data Final	end	30
137	2024-05-07 07:00:00.43	2024-05-07 07:00:00.43	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	52	Data Final	end	30
138	2024-05-07 07:00:00.431	2024-05-07 07:00:00.431	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
139	2024-05-07 07:00:00.432	2024-05-07 07:00:00.432	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	58	Data Final	end	30
140	2024-05-07 07:00:00.438	2024-05-07 07:00:00.438	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	61	Data Final	end	30
141	2024-05-07 07:00:00.441	2024-05-07 07:00:00.441	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 5435 din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	59	Data Final	end	30
142	2024-05-07 07:00:00.442	2024-05-07 07:00:00.442	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta ewr.	to: a@a.com bcc:razvan.mustata@gmail.com	60	Data Final	end	30
143	2024-05-07 07:00:00.447	2024-05-07 07:00:00.447	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 2354 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 235.	to: a@a.com bcc:razvan.mustata@gmail.com	62	Data Final	end	30
144	2024-05-07 07:00:00.448	2024-05-07 07:00:00.448	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	63	Data Final	end	30
145	2024-05-08 07:00:00.332	2024-05-08 07:00:00.332	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	56	Data Final	end	30
146	2024-05-08 07:00:00.515	2024-05-08 07:00:00.515	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 08.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	45	Data Final	end	30
147	2024-05-08 07:00:00.549	2024-05-08 07:00:00.549	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
148	2024-05-08 07:00:00.558	2024-05-08 07:00:00.558	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
149	2024-05-08 07:00:00.56	2024-05-08 07:00:00.56	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
150	2024-05-08 07:00:00.57	2024-05-08 07:00:00.57	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
151	2024-05-08 07:00:00.595	2024-05-08 07:00:00.595	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 23423.	to: a@a.com bcc:razvan.mustata@gmail.com	40	Data Final	end	30
152	2024-05-08 07:00:00.616	2024-05-08 07:00:00.616	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
153	2024-05-08 07:00:00.626	2024-05-08 07:00:00.626	2	Va informam faptul ca urmeaza sa expire contractul cu numarul ert din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta ert.	to: a@a.com bcc:razvan.mustata@gmail.com	41	Data Final	end	30
154	2024-05-08 07:00:00.633	2024-05-08 07:00:00.633	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	42	Data Final	end	30
155	2024-05-08 07:00:00.638	2024-05-08 07:00:00.638	2	Va informam faptul ca urmeaza sa expire contractul cu numarul teste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta et.	to: a@a.com bcc:razvan.mustata@gmail.com	47	Data Final	end	30
156	2024-05-08 07:00:00.657	2024-05-08 07:00:00.657	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	57	Data Final	end	30
157	2024-05-08 07:00:00.673	2024-05-08 07:00:00.673	2	Va informam faptul ca urmeaza sa expire contractul cu numarul rrr din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta rrr.	to: a@a.com bcc:razvan.mustata@gmail.com	53	Data Final	end	30
158	2024-05-08 07:00:00.683	2024-05-08 07:00:00.683	2	Va informam faptul ca urmeaza sa expire contractul cu numarul testeteste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta testeteste.	to: a@a.com bcc:razvan.mustata@gmail.com	49	Data Final	end	30
159	2024-05-08 07:00:00.703	2024-05-08 07:00:00.703	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 435453 din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 35.	to: a@a.com bcc:razvan.mustata@gmail.com	54	Data Final	end	30
160	2024-05-08 07:00:00.736	2024-05-08 07:00:00.736	2	Va informam faptul ca urmeaza sa expire contractul cu numarul reject din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta reject.	to: a@a.com bcc:razvan.mustata@gmail.com	50	Data Final	end	30
161	2024-05-08 07:00:00.748	2024-05-08 07:00:00.748	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234 din data de 23.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	51	Data Final	end	30
162	2024-05-08 07:00:00.768	2024-05-08 07:00:00.768	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	52	Data Final	end	30
163	2024-05-08 07:00:00.767	2024-05-08 07:00:00.767	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0);">n2</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
165	2024-05-08 07:00:00.785	2024-05-08 07:00:00.785	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	61	Data Final	end	30
168	2024-05-08 07:00:00.893	2024-05-08 07:00:00.893	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 2354 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 235.	to: a@a.com bcc:razvan.mustata@gmail.com	62	Data Final	end	30
164	2024-05-08 07:00:00.772	2024-05-08 07:00:00.772	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	58	Data Final	end	30
167	2024-05-08 07:00:00.844	2024-05-08 07:00:00.844	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta ewr.	to: a@a.com bcc:razvan.mustata@gmail.com	60	Data Final	end	30
166	2024-05-08 07:00:00.802	2024-05-08 07:00:00.802	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 5435 din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	59	Data Final	end	30
169	2024-05-08 07:00:00.912	2024-05-08 07:00:00.912	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
170	2024-05-08 07:00:00.913	2024-05-08 07:00:00.913	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	63	Data Final	end	30
171	2024-05-09 04:29:15.085	2024-05-09 04:29:15.085	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
172	2024-05-09 04:29:15.771	2024-05-09 04:29:15.771	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0);">n2</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
173	2024-05-09 04:29:15.789	2024-05-09 04:29:15.789	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
174	2024-05-09 07:00:00.184	2024-05-09 07:00:00.184	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	56	Data Final	end	30
175	2024-05-09 07:00:00.223	2024-05-09 07:00:00.223	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 08.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	45	Data Final	end	30
176	2024-05-09 07:00:00.232	2024-05-09 07:00:00.232	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
177	2024-05-09 07:00:00.233	2024-05-09 07:00:00.233	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
178	2024-05-09 07:00:00.234	2024-05-09 07:00:00.234	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
179	2024-05-09 07:00:00.237	2024-05-09 07:00:00.237	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
180	2024-05-09 07:00:00.238	2024-05-09 07:00:00.238	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 23423.	to: a@a.com bcc:razvan.mustata@gmail.com	40	Data Final	end	30
181	2024-05-09 07:00:00.24	2024-05-09 07:00:00.24	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
182	2024-05-09 07:00:00.241	2024-05-09 07:00:00.241	2	Va informam faptul ca urmeaza sa expire contractul cu numarul ert din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta ert.	to: a@a.com bcc:razvan.mustata@gmail.com	41	Data Final	end	30
183	2024-05-09 07:00:00.246	2024-05-09 07:00:00.246	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	42	Data Final	end	30
184	2024-05-09 07:00:00.248	2024-05-09 07:00:00.248	2	Va informam faptul ca urmeaza sa expire contractul cu numarul teste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta et.	to: a@a.com bcc:razvan.mustata@gmail.com	47	Data Final	end	30
185	2024-05-09 07:00:00.25	2024-05-09 07:00:00.25	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	57	Data Final	end	30
186	2024-05-09 07:00:00.262	2024-05-09 07:00:00.262	2	Va informam faptul ca urmeaza sa expire contractul cu numarul rrr din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta rrr.	to: a@a.com bcc:razvan.mustata@gmail.com	53	Data Final	end	30
187	2024-05-09 07:00:00.279	2024-05-09 07:00:00.279	2	Va informam faptul ca urmeaza sa expire contractul cu numarul testeteste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta testeteste.	to: a@a.com bcc:razvan.mustata@gmail.com	49	Data Final	end	30
188	2024-05-09 07:00:00.28	2024-05-09 07:00:00.28	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 435453 din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 35.	to: a@a.com bcc:razvan.mustata@gmail.com	54	Data Final	end	30
189	2024-05-09 07:00:00.298	2024-05-09 07:00:00.298	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0);">n2</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
190	2024-05-09 07:00:00.299	2024-05-09 07:00:00.299	2	Va informam faptul ca urmeaza sa expire contractul cu numarul reject din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta reject.	to: a@a.com bcc:razvan.mustata@gmail.com	50	Data Final	end	30
191	2024-05-09 07:00:00.3	2024-05-09 07:00:00.3	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234 din data de 23.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	51	Data Final	end	30
192	2024-05-09 07:00:00.303	2024-05-09 07:00:00.303	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	52	Data Final	end	30
193	2024-05-09 07:00:00.304	2024-05-09 07:00:00.304	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	58	Data Final	end	30
194	2024-05-09 07:00:00.305	2024-05-09 07:00:00.305	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	61	Data Final	end	30
196	2024-05-09 07:00:00.308	2024-05-09 07:00:00.308	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta ewr.	to: a@a.com bcc:razvan.mustata@gmail.com	60	Data Final	end	30
197	2024-05-09 07:00:00.309	2024-05-09 07:00:00.309	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
195	2024-05-09 07:00:00.307	2024-05-09 07:00:00.307	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 5435 din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	59	Data Final	end	30
198	2024-05-09 07:00:00.309	2024-05-09 07:00:00.309	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 2354 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 235.	to: a@a.com bcc:razvan.mustata@gmail.com	62	Data Final	end	30
199	2024-05-09 07:00:00.311	2024-05-09 07:00:00.311	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	63	Data Final	end	30
200	2024-05-09 07:00:00.312	2024-05-09 07:00:00.312	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4 din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 4.	to: a@a.com bcc:razvan.mustata@gmail.com	65	Data Final	end	30
201	2024-05-09 17:00:00.146	2024-05-09 17:00:00.146	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
202	2024-05-09 17:00:00.22	2024-05-09 17:00:00.22	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0);">n2</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
203	2024-05-09 17:00:00.237	2024-05-09 17:00:00.237	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
205	2024-05-10 07:00:00.433	2024-05-10 07:00:00.433	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
204	2024-05-10 07:00:00.321	2024-05-10 07:00:00.321	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	56	Data Final	end	30
206	2024-05-10 07:00:00.458	2024-05-10 07:00:00.458	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 08.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	45	Data Final	end	30
207	2024-05-10 07:00:00.47	2024-05-10 07:00:00.47	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0);">n2</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
208	2024-05-10 07:00:00.487	2024-05-10 07:00:00.487	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
209	2024-05-10 07:00:00.49	2024-05-10 07:00:00.49	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
210	2024-05-10 07:00:00.493	2024-05-10 07:00:00.493	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
211	2024-05-10 07:00:00.496	2024-05-10 07:00:00.496	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 23423.	to: a@a.com bcc:razvan.mustata@gmail.com	40	Data Final	end	30
212	2024-05-10 07:00:00.498	2024-05-10 07:00:00.498	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
213	2024-05-10 07:00:00.501	2024-05-10 07:00:00.501	2	Va informam faptul ca urmeaza sa expire contractul cu numarul ert din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta ert.	to: a@a.com bcc:razvan.mustata@gmail.com	41	Data Final	end	30
214	2024-05-10 07:00:00.503	2024-05-10 07:00:00.503	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
215	2024-05-10 07:00:00.53	2024-05-10 07:00:00.53	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	42	Data Final	end	30
216	2024-05-10 07:00:00.532	2024-05-10 07:00:00.532	2	Va informam faptul ca urmeaza sa expire contractul cu numarul teste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta et.	to: a@a.com bcc:razvan.mustata@gmail.com	47	Data Final	end	30
217	2024-05-10 07:00:00.534	2024-05-10 07:00:00.534	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	57	Data Final	end	30
218	2024-05-10 07:00:00.538	2024-05-10 07:00:00.538	2	Va informam faptul ca urmeaza sa expire contractul cu numarul rrr din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta rrr.	to: a@a.com bcc:razvan.mustata@gmail.com	53	Data Final	end	30
219	2024-05-10 07:00:00.54	2024-05-10 07:00:00.54	2	Va informam faptul ca urmeaza sa expire contractul cu numarul testeteste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta testeteste.	to: a@a.com bcc:razvan.mustata@gmail.com	49	Data Final	end	30
220	2024-05-10 07:00:00.543	2024-05-10 07:00:00.543	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 435453 din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 35.	to: a@a.com bcc:razvan.mustata@gmail.com	54	Data Final	end	30
221	2024-05-10 07:00:00.544	2024-05-10 07:00:00.544	2	Va informam faptul ca urmeaza sa expire contractul cu numarul reject din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta reject.	to: a@a.com bcc:razvan.mustata@gmail.com	50	Data Final	end	30
222	2024-05-10 07:00:00.546	2024-05-10 07:00:00.546	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234 din data de 23.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	51	Data Final	end	30
223	2024-05-10 07:00:00.548	2024-05-10 07:00:00.548	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	52	Data Final	end	30
224	2024-05-10 07:00:00.55	2024-05-10 07:00:00.55	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	58	Data Final	end	30
225	2024-05-10 07:00:00.551	2024-05-10 07:00:00.551	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	61	Data Final	end	30
226	2024-05-10 07:00:00.553	2024-05-10 07:00:00.553	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 5435 din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	59	Data Final	end	30
227	2024-05-10 07:00:00.555	2024-05-10 07:00:00.555	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta ewr.	to: a@a.com bcc:razvan.mustata@gmail.com	60	Data Final	end	30
228	2024-05-10 07:00:00.557	2024-05-10 07:00:00.557	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 2354 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 235.	to: a@a.com bcc:razvan.mustata@gmail.com	62	Data Final	end	30
229	2024-05-10 07:00:00.558	2024-05-10 07:00:00.558	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	63	Data Final	end	30
230	2024-05-10 07:00:00.56	2024-05-10 07:00:00.56	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4 din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 4.	to: a@a.com bcc:razvan.mustata@gmail.com	65	Data Final	end	30
231	2024-05-12 07:00:00.229	2024-05-12 07:00:00.229	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	56	Data Final	end	30
233	2024-05-12 07:00:00.345	2024-05-12 07:00:00.345	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">09.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	26	Inchis la data	completion	0
232	2024-05-12 07:00:00.336	2024-05-12 07:00:00.336	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 08.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	45	Data Final	end	30
234	2024-05-12 07:00:00.348	2024-05-12 07:00:00.348	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 09.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	26	Data Final	end	30
235	2024-05-12 07:00:00.352	2024-05-12 07:00:00.352	2	Va informam faptul ca urmeaza sa expire contractul cu numarul n2 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta n2.	to: a@a.com bcc:razvan.mustata@gmail.com	27	Data Final	end	30
236	2024-05-12 07:00:00.356	2024-05-12 07:00:00.356	2	Va informam faptul ca urmeaza sa expire contractul cu numarul werrew din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	29	Data Final	end	30
237	2024-05-12 07:00:00.358	2024-05-12 07:00:00.358	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 23423.	to: a@a.com bcc:razvan.mustata@gmail.com	40	Data Final	end	30
238	2024-05-12 07:00:00.364	2024-05-12 07:00:00.364	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">n2</span> din data de <span style="color: rgb(230, 0, 0);">02.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span> si reprezinta <span style="color: rgb(230, 0, 0);">n2</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	27	Inchis la data	completion	0
239	2024-05-12 07:00:00.364	2024-05-12 07:00:00.364	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 1 din data de 11.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta Vanzare.	to: a@a.com bcc:razvan.mustata@gmail.com	1	Data Final	end	30
240	2024-05-12 07:00:00.367	2024-05-12 07:00:00.367	2	Va informam faptul ca urmeaza sa expire contractul cu numarul ert din data de 03.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta ert.	to: a@a.com bcc:razvan.mustata@gmail.com	41	Data Final	end	30
241	2024-05-12 07:00:00.375	2024-05-12 07:00:00.375	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.04.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	42	Data Final	end	30
242	2024-05-12 07:00:00.378	2024-05-12 07:00:00.378	2	Va informam faptul ca urmeaza sa expire contractul cu numarul teste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta et.	to: a@a.com bcc:razvan.mustata@gmail.com	47	Data Final	end	30
243	2024-05-12 07:00:00.38	2024-05-12 07:00:00.38	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4543 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 435.	to: a@a.com bcc:razvan.mustata@gmail.com	57	Data Final	end	30
244	2024-05-12 07:00:00.381	2024-05-12 07:00:00.381	2	Va informam faptul ca urmeaza sa expire contractul cu numarul rrr din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta rrr.	to: a@a.com bcc:razvan.mustata@gmail.com	53	Data Final	end	30
245	2024-05-12 07:00:00.383	2024-05-12 07:00:00.383	2	Va informam faptul ca urmeaza sa expire contractul cu numarul testeteste din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta testeteste.	to: a@a.com bcc:razvan.mustata@gmail.com	49	Data Final	end	30
250	2024-05-12 07:00:00.407	2024-05-12 07:00:00.407	1	<h2>Va informam faptul ca a fost inchis contractul cu numarul <span style="color: rgb(230, 0, 0);">1</span> din data de <span style="color: rgb(230, 0, 0);">11.04.2024</span> la partenerul <span style="color: rgb(230, 0, 0);">SoftHub</span>. Acest contract a fost in vigoare in compania <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span> si reprezinta <span style="color: rgb(230, 0, 0);">Vanzare</span>.</h2>	to: a@a.com bcc:razvan.mustata@gmail.com	1	Inchis la data	completion	0
251	2024-05-12 07:00:00.426	2024-05-12 07:00:00.426	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	58	Data Final	end	30
252	2024-05-12 07:00:00.427	2024-05-12 07:00:00.427	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	61	Data Final	end	30
253	2024-05-12 07:00:00.445	2024-05-12 07:00:00.445	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 5435 din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 345.	to: a@a.com bcc:razvan.mustata@gmail.com	59	Data Final	end	30
254	2024-05-12 07:00:00.446	2024-05-12 07:00:00.446	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta ewr.	to: a@a.com bcc:razvan.mustata@gmail.com	60	Data Final	end	30
255	2024-05-12 07:00:00.447	2024-05-12 07:00:00.447	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 2354 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 235.	to: a@a.com bcc:razvan.mustata@gmail.com	62	Data Final	end	30
256	2024-05-12 07:00:00.448	2024-05-12 07:00:00.448	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234234 din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania DRAGONUL ROSU SA  si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	63	Data Final	end	30
257	2024-05-12 07:00:00.45	2024-05-12 07:00:00.45	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 4 din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 4.	to: a@a.com bcc:razvan.mustata@gmail.com	65	Data Final	end	30
258	2024-05-12 07:00:00.451	2024-05-12 07:00:00.451	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	70	Data Final	end	30
259	2024-05-12 07:00:00.453	2024-05-12 07:00:00.453	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 546 din data de 10.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 456.	to: a@a.com bcc:razvan.mustata@gmail.com	71	Data Final	end	30
260	2024-05-12 07:00:00.454	2024-05-12 07:00:00.454	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 546aa din data de 11.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 456aa.	to: a@a.com bcc:razvan.mustata@gmail.com	72	Data Final	end	30
246	2024-05-12 07:00:00.384	2024-05-12 07:00:00.384	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 435453 din data de 07.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 35.	to: a@a.com bcc:razvan.mustata@gmail.com	54	Data Final	end	30
247	2024-05-12 07:00:00.389	2024-05-12 07:00:00.389	2	Va informam faptul ca urmeaza sa expire contractul cu numarul reject din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta reject.	to: a@a.com bcc:razvan.mustata@gmail.com	50	Data Final	end	30
248	2024-05-12 07:00:00.391	2024-05-12 07:00:00.391	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234 din data de 23.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 234.	to: a@a.com bcc:razvan.mustata@gmail.com	51	Data Final	end	30
249	2024-05-12 07:00:00.393	2024-05-12 07:00:00.393	2	Va informam faptul ca urmeaza sa expire contractul cu numarul wer din data de 02.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta wer.	to: a@a.com bcc:razvan.mustata@gmail.com	52	Data Final	end	30
\.


--
-- Data for Name: Bank; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Bank" (id, name) FROM stdin;
1	Alpha Bank
2	BRCI
3	Banca FEROVIARA
4	Intesa Sanpaolo
5	BCR
6	BCR Banca pentru Locuinţe
7	Eximbank
8	Banca Românească
9	Banca Transilvania
10	Leumi
11	BRD
12	CEC Bank
13	Crédit Agricole
14	Credit Europe
15	Garanti Bank
16	Idea Bank
17	Libra Bank
18	Vista Bank
19	OTP Bank
20	Patria Bank
21	First Bank
22	Porsche Bank
23	ProCredit Bank
24	Raiffeisen
25	Aedificium Banca pentru Locuinte
26	UniCredit
27	Alior Bank
28	BLOM Bank France
29	BNP Paribas
30	Citibank
31	ING
32	TBI 
\.


--
-- Data for Name: Banks; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Banks" (id, "updateadAt", "createdAt", "partnerId", bank, branch, currency, iban, status) FROM stdin;
1	2024-04-01 10:28:30.207	2024-04-01 10:28:30.207	1	ING	Tineretului	RON	423423423	t
2	2024-04-01 10:30:49.506	2024-04-01 10:30:49.506	3	Alpha Bank	Stefan cel mare	RON	234423423423	t
3	2024-04-19 11:31:10.228	2024-04-19 11:31:10.228	4	Alpha Bank	Stefan cel Mare	RON	23442243423423	t
\.


--
-- Data for Name: BillingFrequency; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."BillingFrequency" (id, name) FROM stdin;
1	Zilnic
2	Săptămânal
3	Lunar
4	Trimestrial
5	Semestrial
6	Anual
7	Personalizat
\.


--
-- Data for Name: Cashflow; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Cashflow" (id, name) FROM stdin;
1	Incasari operationale
2	Incasari financiare
3	Plati operationale
4	Plati investitionale
5	Plati financiare
6	Tranzactii InterCompany
7	Salarii
8	Furnizori activitate curenta
9	Utilitati
10	Auto combustibili si reparatii
11	Paza
12	Publicitate si sponsorizare
13	Deplasari + diurne
14	Marfa MUDR
15	Restituiri clienti
16	Investitii in curs
17	Investitii finalizate
18	Asigurari/ leasing , comisioane banci
19	Restituire credite si dobanzi
20	Impozit pe profit
21	Impozite locale
22	TVA de plata  
23	Taxa salarii
24	Tranzactii intercompany
25	Transfer bancar(credit)
26	Transfer bancar(debit)
27	Plati Deconturi
28	Investitii Proprii
29	Compensari/Girari/Retururi
\.


--
-- Data for Name: Category; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Category" (id, name) FROM stdin;
1	Consultanta
2	Inchiriere
3	Dezvoltare
\.


--
-- Data for Name: ContractAlertSchedule; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractAlertSchedule" (id, "updateadAt", "createdAt", "contractId", "alertId", alertname, "datetoBeSent", "isActive", status, subject, nrofdays) FROM stdin;
1	2024-04-01 10:50:00.048	2024-04-01 10:50:00.048	1	2	Expirare Contract	2024-03-31 21:00:00	t	t	Expirare Contract	30
2	2024-04-01 10:50:00.053	2024-04-01 10:50:00.053	2	2	Expirare Contract	2024-05-31 21:00:00	t	t	Expirare Contract	30
3	2024-04-01 10:50:00.056	2024-04-01 10:50:00.056	1	1	Contract Inchis inainte de termen	2024-04-30 21:00:00	t	t	Contract Inchis inainte de termen	0
4	2024-04-01 10:50:00.059	2024-04-01 10:50:00.059	2	1	Contract Inchis inainte de termen	2024-06-30 21:00:00	t	t	Contract Inchis inainte de termen	0
5	2024-04-04 06:30:00.042	2024-04-04 06:30:00.042	4	2	Expirare Contract	2024-08-26 21:00:00	t	t	Expirare Contract	30
6	2024-04-04 06:30:00.042	2024-04-04 06:30:00.042	4	1	Contract Inchis inainte de termen	2024-09-25 21:00:00	t	t	Contract Inchis inainte de termen	0
7	2024-04-04 06:30:00.045	2024-04-04 06:30:00.045	3	2	Expirare Contract	2024-08-02 21:00:00	t	t	Expirare Contract	30
8	2024-04-04 06:30:00.046	2024-04-04 06:30:00.046	3	1	Contract Inchis inainte de termen	2024-09-01 21:00:00	t	t	Contract Inchis inainte de termen	0
9	2024-04-19 11:40:00.199	2024-04-19 11:40:00.199	5	2	Expirare Contract	2024-12-01 22:00:00	t	t	Expirare Contract	30
10	2024-04-19 11:40:00.199	2024-04-19 11:40:00.199	5	1	Contract Inchis inainte de termen	2024-12-31 22:00:00	t	t	Contract Inchis inainte de termen	0
11	2024-04-19 12:10:00.067	2024-04-19 12:10:00.067	6	1	Contract Inchis inainte de termen	2024-09-30 21:00:00	t	t	Contract Inchis inainte de termen	0
12	2024-04-19 12:10:00.073	2024-04-19 12:10:00.073	6	2	Expirare Contract	2024-08-31 21:00:00	t	t	Expirare Contract	30
13	2024-04-21 06:20:00.087	2024-04-21 06:20:00.087	7	1	Contract Inchis inainte de termen	2024-12-31 22:00:00	t	t	Contract Inchis inainte de termen	0
14	2024-04-21 06:20:00.089	2024-04-21 06:20:00.089	7	2	Expirare Contract	2024-12-01 22:00:00	t	t	Expirare Contract	30
15	2024-04-21 07:00:00.092	2024-04-21 07:00:00.092	8	2	Expirare Contract	2024-12-01 22:00:00	t	t	Expirare Contract	30
16	2024-04-21 07:00:00.092	2024-04-21 07:00:00.092	8	1	Contract Inchis inainte de termen	2024-12-31 22:00:00	t	t	Contract Inchis inainte de termen	0
17	2024-04-21 07:10:00.066	2024-04-21 07:10:00.066	9	1	Contract Inchis inainte de termen	2024-12-31 22:00:00	t	t	Contract Inchis inainte de termen	0
18	2024-04-21 07:10:00.074	2024-04-21 07:10:00.074	9	2	Expirare Contract	2024-12-01 22:00:00	t	t	Expirare Contract	30
19	2024-04-21 07:30:00.088	2024-04-21 07:30:00.088	24	1	Contract Inchis inainte de termen	2024-10-31 22:00:00	t	t	Contract Inchis inainte de termen	0
20	2024-04-21 07:30:00.098	2024-04-21 07:30:00.098	24	2	Expirare Contract	2024-10-01 22:00:00	t	t	Expirare Contract	30
21	2024-04-21 07:50:00.126	2024-04-21 07:50:00.126	25	1	Contract Inchis inainte de termen	2025-01-03 22:00:00	t	t	Contract Inchis inainte de termen	0
22	2024-04-21 07:50:00.128	2024-04-21 07:50:00.128	25	2	Expirare Contract	2024-12-04 22:00:00	t	t	Expirare Contract	30
23	2024-04-21 08:00:00.115	2024-04-21 08:00:00.115	26	2	Expirare Contract	2024-04-07 21:00:00	t	t	Expirare Contract	30
24	2024-04-21 08:00:00.116	2024-04-21 08:00:00.116	26	1	Contract Inchis inainte de termen	2024-05-07 21:00:00	t	t	Contract Inchis inainte de termen	0
25	2024-04-22 04:49:40.047	2024-04-22 04:49:40.047	27	2	Expirare Contract	2024-03-31 21:00:00	t	t	Expirare Contract	30
26	2024-04-22 04:50:00.024	2024-04-22 04:50:00.024	27	1	Contract Inchis inainte de termen	2024-04-30 21:00:00	t	t	Contract Inchis inainte de termen	0
27	2024-04-22 06:01:30.016	2024-04-22 06:01:30.016	28	2	Expirare Contract	2024-08-01 21:00:00	t	t	Expirare Contract	30
28	2024-04-22 06:10:00.082	2024-04-22 06:10:00.082	28	1	Contract Inchis inainte de termen	2024-08-31 21:00:00	t	t	Contract Inchis inainte de termen	0
29	2024-04-26 11:38:00.037	2024-04-26 11:38:00.037	29	2	Expirare Contract	2024-03-31 21:00:00	t	t	Expirare Contract	30
30	2024-04-26 11:40:00.058	2024-04-26 11:40:00.058	29	1	Contract Inchis inainte de termen	2024-04-30 21:00:00	t	t	Contract Inchis inainte de termen	0
31	2024-04-29 04:46:10.031	2024-04-29 04:46:10.031	30	2	Expirare Contract	2024-11-01 22:00:00	t	t	Expirare Contract	30
32	2024-04-29 04:50:00.082	2024-04-29 04:50:00.082	30	1	Contract Inchis inainte de termen	2024-12-01 22:00:00	t	t	Contract Inchis inainte de termen	0
33	2024-04-29 04:54:00.039	2024-04-29 04:54:00.039	31	2	Expirare Contract	2024-11-25 22:00:00	t	t	Expirare Contract	30
34	2024-04-29 05:00:00.061	2024-04-29 05:00:00.061	31	1	Contract Inchis inainte de termen	2024-12-25 22:00:00	t	t	Contract Inchis inainte de termen	0
35	2024-04-29 15:51:30.183	2024-04-29 15:51:30.183	32	2	Expirare Contract	2024-10-07 22:00:00	t	t	Expirare Contract	30
36	2024-04-29 16:00:00.054	2024-04-29 16:00:00.054	32	1	Contract Inchis inainte de termen	2024-11-06 22:00:00	t	t	Contract Inchis inainte de termen	0
37	2024-04-30 07:19:20.019	2024-04-30 07:19:20.019	33	2	Expirare Contract	2024-07-30 21:00:00	t	t	Expirare Contract	30
38	2024-04-30 07:20:00.052	2024-04-30 07:20:00.052	33	1	Contract Inchis inainte de termen	2024-08-29 21:00:00	t	t	Contract Inchis inainte de termen	0
39	2024-04-30 07:23:10.025	2024-04-30 07:23:10.025	34	2	Expirare Contract	2024-10-06 22:00:00	t	t	Expirare Contract	30
40	2024-04-30 07:23:20.022	2024-04-30 07:23:20.022	35	2	Expirare Contract	2024-10-06 22:00:00	t	t	Expirare Contract	30
41	2024-04-30 07:30:00.043	2024-04-30 07:30:00.043	34	1	Contract Inchis inainte de termen	2024-11-05 22:00:00	t	t	Contract Inchis inainte de termen	0
42	2024-04-30 07:30:00.047	2024-04-30 07:30:00.047	35	1	Contract Inchis inainte de termen	2024-11-05 22:00:00	t	t	Contract Inchis inainte de termen	0
43	2024-04-30 09:42:50.022	2024-04-30 09:42:50.022	36	2	Expirare Contract	2024-07-15 21:00:00	t	t	Expirare Contract	30
44	2024-04-30 09:50:00.072	2024-04-30 09:50:00.072	36	1	Contract Inchis inainte de termen	2024-08-14 21:00:00	t	t	Contract Inchis inainte de termen	0
45	2024-04-30 09:51:50.029	2024-04-30 09:51:50.029	37	2	Expirare Contract	2024-06-24 21:00:00	t	t	Expirare Contract	30
46	2024-04-30 10:00:00.062	2024-04-30 10:00:00.062	37	1	Contract Inchis inainte de termen	2024-07-24 21:00:00	t	t	Contract Inchis inainte de termen	0
47	2024-04-30 11:18:30.027	2024-04-30 11:18:30.027	38	2	Expirare Contract	2024-10-07 22:00:00	t	t	Expirare Contract	30
48	2024-04-30 11:20:00.068	2024-04-30 11:20:00.068	38	1	Contract Inchis inainte de termen	2024-11-06 22:00:00	t	t	Contract Inchis inainte de termen	0
49	2024-04-30 11:22:20.033	2024-04-30 11:22:20.033	39	2	Expirare Contract	2024-07-23 21:00:00	t	t	Expirare Contract	30
50	2024-04-30 11:30:00.052	2024-04-30 11:30:00.052	39	1	Contract Inchis inainte de termen	2024-08-22 21:00:00	t	t	Contract Inchis inainte de termen	0
51	2024-04-30 11:51:10.034	2024-04-30 11:51:10.034	40	2	Expirare Contract	2024-03-31 21:00:00	t	t	Expirare Contract	30
52	2024-04-30 12:00:00.061	2024-04-30 12:00:00.061	40	1	Contract Inchis inainte de termen	2024-04-30 21:00:00	t	t	Contract Inchis inainte de termen	0
53	2024-04-30 12:17:30.038	2024-04-30 12:17:30.038	41	2	Expirare Contract	2024-03-25 21:00:00	t	t	Expirare Contract	30
54	2024-04-30 12:20:00.079	2024-04-30 12:20:00.079	41	1	Contract Inchis inainte de termen	2024-04-24 21:00:00	t	t	Contract Inchis inainte de termen	0
55	2024-04-30 12:26:50.039	2024-04-30 12:26:50.039	42	2	Expirare Contract	2024-03-31 21:00:00	t	t	Expirare Contract	30
56	2024-04-30 12:30:00.096	2024-04-30 12:30:00.096	42	1	Contract Inchis inainte de termen	2024-04-30 21:00:00	t	t	Contract Inchis inainte de termen	0
57	2024-04-30 12:33:40.076	2024-04-30 12:33:40.076	43	2	Expirare Contract	2024-10-07 22:00:00	t	t	Expirare Contract	30
58	2024-05-02 04:50:00.099	2024-05-02 04:50:00.099	43	1	Contract Inchis inainte de termen	2024-11-06 22:00:00	t	t	Contract Inchis inainte de termen	0
59	2024-05-02 05:07:40.013	2024-05-02 05:07:40.013	44	2	Expirare Contract	2024-06-16 21:00:00	t	t	Expirare Contract	30
60	2024-05-02 05:10:00.061	2024-05-02 05:10:00.061	44	1	Contract Inchis inainte de termen	2024-07-16 21:00:00	t	t	Contract Inchis inainte de termen	0
61	2024-05-02 05:21:30.038	2024-05-02 05:21:30.038	45	2	Expirare Contract	2024-04-21 21:00:00	t	t	Expirare Contract	30
62	2024-05-02 05:30:00.048	2024-05-02 05:30:00.048	45	1	Contract Inchis inainte de termen	2024-05-21 21:00:00	t	t	Contract Inchis inainte de termen	0
63	2024-05-02 06:42:50.042	2024-05-02 06:42:50.042	46	2	Expirare Contract	2024-07-08 21:00:00	t	t	Expirare Contract	30
64	2024-05-02 06:50:00.052	2024-05-02 06:50:00.052	46	1	Contract Inchis inainte de termen	2024-08-07 21:00:00	t	t	Contract Inchis inainte de termen	0
65	2024-05-02 06:56:50.048	2024-05-02 06:56:50.048	47	2	Expirare Contract	2024-05-01 21:00:00	t	t	Expirare Contract	30
66	2024-05-02 07:00:00.141	2024-05-02 07:00:00.141	47	1	Contract Inchis inainte de termen	2024-05-31 21:00:00	t	t	Contract Inchis inainte de termen	0
67	2024-05-02 07:07:20.052	2024-05-02 07:07:20.052	48	2	Expirare Contract	2024-07-08 21:00:00	t	t	Expirare Contract	30
68	2024-05-02 07:10:00.079	2024-05-02 07:10:00.079	48	1	Contract Inchis inainte de termen	2024-08-07 21:00:00	t	t	Contract Inchis inainte de termen	0
69	2024-05-02 07:32:20.066	2024-05-02 07:32:20.066	49	2	Expirare Contract	2024-04-29 21:00:00	t	t	Expirare Contract	30
70	2024-05-02 07:37:40.065	2024-05-02 07:37:40.065	50	2	Expirare Contract	2024-04-30 21:00:00	t	t	Expirare Contract	30
71	2024-05-02 07:40:00.119	2024-05-02 07:40:00.119	49	1	Contract Inchis inainte de termen	2024-05-29 21:00:00	t	t	Contract Inchis inainte de termen	0
72	2024-05-02 07:40:00.121	2024-05-02 07:40:00.121	50	1	Contract Inchis inainte de termen	2024-05-30 21:00:00	t	t	Contract Inchis inainte de termen	0
73	2024-05-02 07:46:40.059	2024-05-02 07:46:40.059	51	2	Expirare Contract	2024-05-01 21:00:00	t	t	Expirare Contract	30
74	2024-05-02 07:50:00.092	2024-05-02 07:50:00.092	51	1	Contract Inchis inainte de termen	2024-05-31 21:00:00	t	t	Contract Inchis inainte de termen	0
75	2024-05-02 09:36:20.068	2024-05-02 09:36:20.068	52	2	Expirare Contract	2024-04-23 21:00:00	t	t	Expirare Contract	30
76	2024-05-02 09:40:00.181	2024-05-02 09:40:00.181	52	1	Contract Inchis inainte de termen	2024-05-23 21:00:00	t	t	Contract Inchis inainte de termen	0
77	2024-05-02 09:49:00.09	2024-05-02 09:49:00.09	53	2	Expirare Contract	2024-04-29 21:00:00	t	t	Expirare Contract	30
78	2024-05-02 09:50:00.098	2024-05-02 09:50:00.098	53	1	Contract Inchis inainte de termen	2024-05-29 21:00:00	t	t	Contract Inchis inainte de termen	0
79	2024-05-06 08:04:40.083	2024-05-06 08:04:40.083	54	2	Expirare Contract	2024-05-01 21:00:00	t	t	Expirare Contract	30
80	2024-05-06 08:10:00.103	2024-05-06 08:10:00.103	54	1	Contract Inchis inainte de termen	2024-05-31 21:00:00	t	t	Contract Inchis inainte de termen	0
81	2024-05-06 08:35:50.106	2024-05-06 08:35:50.106	55	2	Expirare Contract	2024-10-08 22:00:00	t	t	Expirare Contract	30
82	2024-05-06 08:40:00.323	2024-05-06 08:40:00.323	55	1	Contract Inchis inainte de termen	2024-11-07 22:00:00	t	t	Contract Inchis inainte de termen	0
83	2024-05-06 12:42:50.033	2024-05-06 12:42:50.033	56	2	Expirare Contract	2024-04-21 21:00:00	t	t	Expirare Contract	30
84	2024-05-06 12:43:00.098	2024-05-06 12:43:00.098	57	2	Expirare Contract	2024-04-21 21:00:00	t	t	Expirare Contract	30
85	2024-05-06 12:45:40.077	2024-05-06 12:45:40.077	58	2	Expirare Contract	2024-04-28 21:00:00	t	t	Expirare Contract	30
86	2024-05-06 12:48:00.123	2024-05-06 12:48:00.123	59	2	Expirare Contract	2024-04-20 21:00:00	t	t	Expirare Contract	30
87	2024-05-06 12:49:50.102	2024-05-06 12:49:50.102	60	2	Expirare Contract	2024-04-29 21:00:00	t	t	Expirare Contract	30
88	2024-05-06 12:50:00.094	2024-05-06 12:50:00.094	56	1	Contract Inchis inainte de termen	2024-05-21 21:00:00	t	t	Contract Inchis inainte de termen	0
89	2024-05-06 12:50:00.151	2024-05-06 12:50:00.151	57	1	Contract Inchis inainte de termen	2024-05-21 21:00:00	t	t	Contract Inchis inainte de termen	0
90	2024-05-06 12:50:00.168	2024-05-06 12:50:00.168	58	1	Contract Inchis inainte de termen	2024-05-28 21:00:00	t	t	Contract Inchis inainte de termen	0
91	2024-05-06 12:50:00.17	2024-05-06 12:50:00.17	59	1	Contract Inchis inainte de termen	2024-05-20 21:00:00	t	t	Contract Inchis inainte de termen	0
92	2024-05-06 12:50:00.172	2024-05-06 12:50:00.172	60	1	Contract Inchis inainte de termen	2024-05-29 21:00:00	t	t	Contract Inchis inainte de termen	0
93	2024-05-06 12:51:40.111	2024-05-06 12:51:40.111	61	2	Expirare Contract	2024-04-28 21:00:00	t	t	Expirare Contract	30
94	2024-05-06 12:53:50.102	2024-05-06 12:53:50.102	62	2	Expirare Contract	2024-04-12 21:00:00	t	t	Expirare Contract	30
95	2024-05-06 13:00:00.22	2024-05-06 13:00:00.22	61	1	Contract Inchis inainte de termen	2024-05-28 21:00:00	t	t	Contract Inchis inainte de termen	0
96	2024-05-06 13:00:00.235	2024-05-06 13:00:00.235	62	1	Contract Inchis inainte de termen	2024-05-12 21:00:00	t	t	Contract Inchis inainte de termen	0
97	2024-05-06 13:09:20.105	2024-05-06 13:09:20.105	63	2	Expirare Contract	2024-04-29 21:00:00	t	t	Expirare Contract	30
98	2024-05-06 13:10:00.119	2024-05-06 13:10:00.119	63	1	Contract Inchis inainte de termen	2024-05-29 21:00:00	t	t	Contract Inchis inainte de termen	0
99	2024-05-08 05:47:00.092	2024-05-08 05:47:00.092	64	2	Expirare Contract	2027-04-01 21:00:00	t	t	Expirare Contract	30
100	2024-05-08 05:50:00.132	2024-05-08 05:50:00.132	64	1	Contract Inchis inainte de termen	2027-05-01 21:00:00	t	t	Contract Inchis inainte de termen	0
101	2024-05-08 07:28:10.115	2024-05-08 07:28:10.115	65	2	Expirare Contract	2024-04-29 21:00:00	t	t	Expirare Contract	30
102	2024-05-08 07:30:00.198	2024-05-08 07:30:00.198	65	1	Contract Inchis inainte de termen	2024-05-29 21:00:00	t	t	Contract Inchis inainte de termen	0
103	2024-05-08 08:31:40.113	2024-05-08 08:31:40.113	66	2	Expirare Contract	2024-12-01 22:00:00	t	t	Expirare Contract	30
104	2024-05-08 08:40:00.195	2024-05-08 08:40:00.195	66	1	Contract Inchis inainte de termen	2024-12-31 22:00:00	t	t	Contract Inchis inainte de termen	0
105	2024-05-09 07:25:10.074	2024-05-09 07:25:10.074	67	2	Expirare Contract	2024-12-02 22:00:00	t	t	Expirare Contract	30
106	2024-05-09 07:30:00.187	2024-05-09 07:30:00.187	67	1	Contract Inchis inainte de termen	2025-01-01 22:00:00	t	t	Contract Inchis inainte de termen	0
107	2024-05-09 07:48:00.092	2024-05-09 07:48:00.092	68	2	Expirare Contract	2024-12-02 22:00:00	t	t	Expirare Contract	30
108	2024-05-09 07:50:00.116	2024-05-09 07:50:00.116	68	1	Contract Inchis inainte de termen	2025-01-01 22:00:00	t	t	Contract Inchis inainte de termen	0
109	2024-05-10 09:32:00.147	2024-05-10 09:32:00.147	69	2	Expirare Contract	2024-06-17 21:00:00	t	t	Expirare Contract	30
110	2024-05-10 09:38:50.137	2024-05-10 09:38:50.137	70	2	Expirare Contract	2024-04-16 21:00:00	t	t	Expirare Contract	30
111	2024-05-10 09:41:40.12	2024-05-10 09:41:40.12	71	2	Expirare Contract	2024-05-01 21:00:00	t	t	Expirare Contract	30
112	2024-05-10 09:43:20.104	2024-05-10 09:43:20.104	72	2	Expirare Contract	2024-05-02 21:00:00	t	t	Expirare Contract	30
113	2024-05-10 09:50:00.166	2024-05-10 09:50:00.166	69	1	Contract Inchis inainte de termen	2024-07-17 21:00:00	t	t	Contract Inchis inainte de termen	0
114	2024-05-10 09:50:00.179	2024-05-10 09:50:00.179	70	1	Contract Inchis inainte de termen	2024-05-16 21:00:00	t	t	Contract Inchis inainte de termen	0
115	2024-05-10 09:50:00.181	2024-05-10 09:50:00.181	71	1	Contract Inchis inainte de termen	2024-05-31 21:00:00	t	t	Contract Inchis inainte de termen	0
116	2024-05-10 09:50:00.183	2024-05-10 09:50:00.183	72	1	Contract Inchis inainte de termen	2024-06-01 21:00:00	t	t	Contract Inchis inainte de termen	0
\.


--
-- Data for Name: ContractAttachments; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractAttachments" (id, "updateadAt", "createdAt", size, path, mimetype, originalname, encoding, fieldname, filename, destination, "contractId") FROM stdin;
1	2024-04-21 06:19:31.121	2024-04-21 06:19:31.106	3473	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1713680371099-848862678.gif	image/gif	barcode (4).gif	7bit	files	files-1713680371099-848862678.gif	/Users/razvanmustata/Projects/contracts/backend/Uploads	7
2	2024-04-21 06:19:31.131	2024-04-21 06:19:31.106	3434	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1713680371101-433415306.gif	image/gif	barcode (5).gif	7bit	files	files-1713680371101-433415306.gif	/Users/razvanmustata/Projects/contracts/backend/Uploads	7
3	2024-04-21 07:40:56.056	2024-04-21 07:40:56.051	3434	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1713685256042-210911360.gif	image/gif	barcode (5).gif	7bit	files	files-1713685256042-210911360.gif	/Users/razvanmustata/Projects/contracts/backend/Uploads	9
4	2024-04-21 07:40:56.058	2024-04-21 07:40:56.051	3473	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1713685256043-26991649.gif	image/gif	barcode (4).gif	7bit	files	files-1713685256043-26991649.gif	/Users/razvanmustata/Projects/contracts/backend/Uploads	9
5	2024-04-21 07:40:56.06	2024-04-21 07:40:56.051	3455	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1713685256043-459356937.gif	image/gif	barcode (3).gif	7bit	files	files-1713685256043-459356937.gif	/Users/razvanmustata/Projects/contracts/backend/Uploads	9
6	2024-04-21 07:55:09.56	2024-04-21 07:55:09.555	3455	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1713686109549-213736848.gif	image/gif	barcode (3).gif	7bit	files	files-1713686109549-213736848.gif	/Users/razvanmustata/Projects/contracts/backend/Uploads	1
8	2024-04-21 07:55:09.565	2024-04-21 07:55:09.555	3473	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1713686109550-610616914.gif	image/gif	barcode (4).gif	7bit	files	files-1713686109550-610616914.gif	/Users/razvanmustata/Projects/contracts/backend/Uploads	1
9	2024-05-06 10:14:36.56	2024-05-06 10:14:36.555	101148	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1714990476548-630024431.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	raport_export_1713857302636.xlsx	7bit	files	files-1714990476548-630024431.xlsx	/Users/razvanmustata/Projects/contracts/backend/Uploads	35
10	2024-05-06 13:09:23.354	2024-05-06 13:09:23.344	22346	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715000963337-85077173.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	scadentar_export_1713946657697.xlsx	7bit	files	files-1715000963337-85077173.xlsx	/Users/razvanmustata/Projects/contracts/backend/Uploads	63
11	2024-05-08 04:18:52.1	2024-05-08 04:18:52.092	24639	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715141932088-214830819.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	extinctoare_export_1713963542889.xlsx	7bit	files	files-1715141932088-214830819.xlsx	/Users/razvanmustata/Projects/contracts/backend/Uploads	44
13	2024-05-08 11:40:08.141	2024-05-08 11:40:08.119	19287	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715168408111-801926476.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	scadentar_export_1715149986628.xlsx	7bit	files	files-1715168408111-801926476.xlsx	/Users/razvanmustata/Projects/contracts/backend/Uploads	66
14	2024-05-08 11:40:08.142	2024-05-08 11:40:08.119	19287	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715168408112-269553442.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	scadentar_export_1715149972815.xlsx	7bit	files	files-1715168408112-269553442.xlsx	/Users/razvanmustata/Projects/contracts/backend/Uploads	66
15	2024-05-08 11:40:08.144	2024-05-08 11:40:08.119	17534	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715168408112-276765800.pdf	application/pdf	scandetar (17).pdf	7bit	files	files-1715168408112-276765800.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	66
16	2024-05-08 11:40:08.145	2024-05-08 11:40:08.119	19287	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715168408113-653477388.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	scadentar_export_1715149640210.xlsx	7bit	files	files-1715168408113-653477388.xlsx	/Users/razvanmustata/Projects/contracts/backend/Uploads	66
17	2024-05-08 11:40:08.147	2024-05-08 11:40:08.119	21576	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715168408114-425981706.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	scadentar_export_1715150125086.xlsx	7bit	files	files-1715168408114-425981706.xlsx	/Users/razvanmustata/Projects/contracts/backend/Uploads	66
18	2024-05-09 08:57:26.092	2024-05-09 08:57:26.076	16749	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715245046071-953786349.xlsx	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	scadentar_export_1715056382703.xlsx	7bit	files	files-1715245046071-953786349.xlsx	/Users/razvanmustata/Projects/contracts/backend/Uploads	67
\.


--
-- Data for Name: ContractContent; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractContent" (id, "updateadAt", "createdAt", content, "contractId") FROM stdin;
1	2024-04-05 05:53:59.879	2024-04-05 05:53:13.618	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">33</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">03.04.2024</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right"><span style="color: rgb(19, 40, 75);">| 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right"><span style="color: rgb(19, 40, 75);">6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right"><span style="color: rgb(19, 40, 75);"> | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right"><span style="color: rgb(19, 40, 75);">6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	3
2	2024-04-08 05:59:55.491	2024-04-08 05:59:55.491	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">1</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">02.04.2024</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	1
3	2024-04-21 06:21:26.729	2024-04-21 06:21:26.729	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">7</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">undefined</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">DRAGONUL ROSU SA </strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal:</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	7
4	2024-04-21 07:42:41.239	2024-04-21 07:42:36.43	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">345</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">undefined</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	9
5	2024-04-23 06:54:27.086	2024-04-23 06:54:27.086	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">44</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">undefined</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	8
6	2024-05-03 07:52:12.621	2024-05-03 07:52:12.621	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">999</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">08.04.2024</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	32
7	2024-05-06 10:10:14.659	2024-05-06 10:10:14.659	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">aa</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">12.04.2024</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	34
9	2024-05-08 07:55:23.139	2024-05-08 07:55:23.139	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">4</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">25.05.2024</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	65
11	2024-05-09 09:04:17.966	2024-05-09 09:04:17.966	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">pebune</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">03.05.2024</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	67
10	2024-05-09 13:16:11.416	2024-05-08 11:39:45.644	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">pebune</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">02.05.2024</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	66
12	2024-05-10 03:47:45.485	2024-05-10 03:46:49.256	<p class="ql-align-center"><strong style="color: rgb(0, 102, 204);">CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong style="color: rgb(0, 102, 204);">NR.: 4543/undefined</strong></p><p><span style="color: rgb(0, 102, 204);">Intre:&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">SoftHub</strong><span style="color: rgb(0, 102, 204);"> , cu sediul social in </span><strong style="color: rgb(0, 102, 204);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong><span style="color: rgb(0, 102, 204);">, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („</span><strong style="color: rgb(0, 102, 204);">Prestatorul</strong><span style="color: rgb(0, 102, 204);">"), pe de o parte; </span><strong style="color: rgb(0, 102, 204);">si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(0, 102, 204);">NIRO INVESTMENT SA, </strong><span style="color: rgb(0, 102, 204);">persoană juridică română, cu sediul în </span><strong style="color: rgb(0, 102, 204);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong><span style="color: rgb(0, 102, 204);">, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează</span><strong style="color: rgb(0, 102, 204);"> </strong><span style="color: rgb(0, 102, 204);">(</span><strong style="color: rgb(0, 102, 204);">„Beneficiarul</strong><span style="color: rgb(0, 102, 204);">")</span><strong style="color: rgb(0, 102, 204);">, </strong><span style="color: rgb(0, 102, 204);">pe de alta parte,&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">Denumite in continuare, individual, „</span><strong style="color: rgb(0, 102, 204);">Partea</strong><span style="color: rgb(0, 102, 204);">" si, in mod colectiv, „</span><strong style="color: rgb(0, 102, 204);">Partile</strong><span style="color: rgb(0, 102, 204);">", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“</span><strong style="color: rgb(0, 102, 204);">Contractul</strong><span style="color: rgb(0, 102, 204);">”), dupa cum urmeaza:&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului </span><strong style="color: rgb(0, 102, 204);">Charisma </strong><span style="color: rgb(0, 102, 204);">cu platforma</span><strong style="color: rgb(0, 102, 204);">/</strong><span style="color: rgb(0, 102, 204);">aplicația </span><strong style="color: rgb(0, 102, 204);">CEC Bank</strong><span style="color: rgb(0, 102, 204);">, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („</span><strong style="color: rgb(0, 102, 204);">Serviciile</strong><span style="color: rgb(0, 102, 204);">”).</span></p><p class="ql-align-right"><span style="color: rgb(0, 102, 204);">P a g e 2 | 6&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p><span style="color: rgb(0, 102, 204);">Prestatorul isi asuma urmatoarele obligatii:&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p><span style="color: rgb(0, 102, 204);">Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de </span><strong style="color: rgb(0, 102, 204);">800(optsute) Euro</strong><span style="color: rgb(0, 102, 204);">. Prestatorul nu este plătitor de TVA.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</span></p><p class="ql-align-right"><span style="color: rgb(0, 102, 204);">P a g e 3 | 6&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art.6. Durata Contractului&nbsp;</strong></p><p><span style="color: rgb(0, 102, 204);">6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">6.2. Prestatorul se angajează ca, până la data de </span><strong style="color: rgb(0, 102, 204);">20.02.2024</strong><span style="color: rgb(0, 102, 204);">, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“</span><strong style="color: rgb(0, 102, 204);">Termen de finalizare</strong><span style="color: rgb(0, 102, 204);">”)&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">6.3. Termenul de finalizare este ferm.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">(a) prin acordul scris al Părţilor;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</span></p><p class="ql-align-right"><span style="color: rgb(0, 102, 204);">P a g e 4 | 6&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">contract.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art. 10. Litigii&nbsp;</strong></p><p><span style="color: rgb(0, 102, 204);">10.1. Prezentul Contract este guvernat de legea română.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong style="color: rgb(0, 102, 204);">Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">12.1. Prezentul Contract are caracter </span><em style="color: rgb(0, 102, 204);">intuitu personae </em><span style="color: rgb(0, 102, 204);">in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</span></p><p class="ql-align-right"><span style="color: rgb(0, 102, 204);">P a g e 6 | 6&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</span></p><p class="ql-align-justify"><strong style="color: rgb(0, 102, 204);">Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</span></p><p class="ql-align-justify"><span style="color: rgb(0, 102, 204);">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</span></p><p><span style="color: rgb(0, 102, 204);">Beneficiar, Prestator,&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong><span style="color: rgb(0, 102, 204);">Director General, Administrator,&nbsp;</span></p><p><strong style="color: rgb(0, 102, 204);">Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(0, 102, 204);">&nbsp;</span></p>	56
13	2024-05-10 09:35:35.187	2024-05-10 09:35:35.187	<p class="ql-align-center"><strong>aaaCONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">ContractNumber</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">SignDate</strong></p><p>bbbIntre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">PartnerName</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">PartnerAddress</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">EntityName</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">EntityAddress</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	69
14	2024-05-10 09:42:52.339	2024-05-10 09:41:39.494	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">546</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">undefined</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	71
15	2024-05-10 09:48:05.697	2024-05-10 09:48:05.697	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">546aa</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">undefined</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	72
8	2024-05-10 09:55:50.678	2024-05-06 12:28:02.993	<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">43345</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">03.05.2024</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">SoftHub</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">NIRO INVESTMENT SA</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>	44
\.


--
-- Data for Name: ContractDynamicFields; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractDynamicFields" (id, "updateadAt", "createdAt", "contractId", "dffInt1", "dffInt2", "dffInt3", "dffInt4", "dffString1", "dffString2", "dffString3", "dffString4", "dffDate1", "dffDate2") FROM stdin;
2	2024-04-01 10:58:37.159	2024-04-01 10:44:02.151	2	55	\N	\N	\N	555aaa				2024-04-02 21:00:00	1970-01-02 00:00:00
33	2024-05-02 06:56:46.098	2024-05-02 06:56:46.098	47	\N	\N	\N	\N					\N	\N
34	2024-05-02 07:10:44.95	2024-05-02 07:07:13.651	48	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
35	2024-05-02 07:32:19.819	2024-05-02 07:32:19.819	49	\N	\N	\N	\N					\N	\N
36	2024-05-02 07:37:30.843	2024-05-02 07:37:30.843	50	\N	\N	\N	\N					\N	\N
37	2024-05-02 09:06:05.804	2024-05-02 07:46:30.313	51	\N	\N	\N	\N					\N	\N
38	2024-05-02 09:36:12.951	2024-05-02 09:36:12.951	52	\N	\N	\N	\N					\N	\N
39	2024-05-02 09:50:28.063	2024-05-02 09:48:55.258	53	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
40	2024-05-06 08:04:31.969	2024-05-06 08:04:31.969	54	\N	\N	\N	\N					\N	\N
18	2024-05-06 08:30:32.44	2024-04-29 15:51:29.945	32	\N	\N	\N	\N					1970-01-03 00:00:00	1970-01-03 00:00:00
41	2024-05-06 08:35:45.339	2024-05-06 08:35:45.339	55	\N	\N	\N	\N					1970-01-04 00:00:00	1970-01-04 00:00:00
20	2024-05-06 10:51:00.62	2024-04-30 07:23:04.415	34	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
19	2024-05-06 11:49:32.775	2024-04-30 07:19:11.642	33	\N	\N	\N	\N					\N	\N
21	2024-05-06 11:54:16.159	2024-04-30 07:23:13.779	35	\N	\N	\N	\N					1970-01-03 00:00:00	1970-01-03 00:00:00
7	2024-04-21 06:19:13.651	2024-04-21 06:19:13.651	7	\N	\N	\N	\N					\N	\N
8	2024-04-21 06:52:48.523	2024-04-21 06:52:48.523	8	\N	\N	\N	\N					\N	\N
30	2024-05-06 12:28:18.785	2024-05-02 05:07:37.334	44	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
42	2024-05-06 12:42:40.565	2024-05-06 12:42:40.565	56	\N	\N	\N	\N					\N	\N
43	2024-05-06 12:42:59.978	2024-05-06 12:42:59.978	57	\N	\N	\N	\N					\N	\N
44	2024-05-06 12:45:34.244	2024-05-06 12:45:34.244	58	\N	\N	\N	\N					\N	\N
11	2024-04-21 07:41:24.616	2024-04-21 07:41:24.616	25	555	\N	\N	\N	test				2029-05-03 21:00:00	1970-01-04 00:00:00
12	2024-04-21 07:54:39.544	2024-04-21 07:54:39.544	26	\N	\N	\N	\N					1970-01-08 00:00:00	1970-01-08 00:00:00
45	2024-05-06 12:47:52.374	2024-05-06 12:47:52.374	59	\N	\N	\N	\N					\N	\N
10	2024-04-22 04:06:48.83	2024-04-21 07:22:38.21	24	\N	\N	\N	\N					1970-01-03 00:00:00	1970-01-03 00:00:00
46	2024-05-06 12:49:48.958	2024-05-06 12:49:48.958	60	\N	\N	\N	\N					\N	\N
9	2024-04-22 04:07:40.012	2024-04-21 07:02:03.925	9	555	\N	\N	\N	test				2029-05-03 21:00:00	1970-01-04 00:00:00
47	2024-05-06 12:51:35.273	2024-05-06 12:51:35.273	61	\N	\N	\N	\N					\N	\N
48	2024-05-06 12:53:46.519	2024-05-06 12:53:46.519	62	\N	\N	\N	\N					\N	\N
49	2024-05-06 13:09:10.604	2024-05-06 13:09:10.604	63	\N	\N	\N	\N					\N	\N
50	2024-05-08 05:46:53.666	2024-05-08 05:46:53.666	64	\N	\N	\N	\N					\N	\N
51	2024-05-08 07:28:08.325	2024-05-08 07:28:08.325	65	\N	\N	\N	\N					\N	\N
52	2024-05-08 11:40:46.018	2024-05-08 08:31:39.048	66	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
14	2024-04-26 11:24:34.168	2024-04-22 06:01:20.072	28	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
53	2024-05-09 07:25:02.934	2024-05-09 07:25:02.934	67	\N	\N	\N	\N					1970-01-03 00:00:00	1970-01-03 00:00:00
15	2024-04-26 11:37:51.319	2024-04-26 11:37:51.319	29	\N	\N	\N	\N					\N	\N
4	2024-04-29 04:39:58.318	2024-04-04 06:23:09.567	4	\N	\N	\N	\N					1970-01-09 00:00:00	1970-01-09 00:00:00
17	2024-04-29 04:53:58.856	2024-04-29 04:53:58.856	31	\N	\N	\N	\N					\N	\N
1	2024-04-29 06:13:52.07	2024-04-01 10:34:39.663	1	64	\N	\N	\N	54				1970-01-11 00:00:00	1970-01-11 00:00:00
6	2024-04-29 07:32:07.862	2024-04-19 12:05:55.16	6	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
3	2024-04-29 14:17:53.993	2024-04-04 06:20:01.844	3	\N	\N	\N	\N					1970-01-21 00:00:00	1970-01-21 00:00:00
54	2024-05-09 07:47:55.744	2024-05-09 07:47:55.744	68	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
5	2024-04-29 14:36:03.73	2024-04-19 11:34:14.527	5	\N	\N	\N	\N					\N	\N
13	2024-04-29 15:46:37.501	2024-04-22 04:47:48.256	27	\N	\N	\N	\N					1970-01-04 00:00:00	1970-01-04 00:00:00
16	2024-04-29 15:48:37.742	2024-04-29 04:46:02.266	30	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
22	2024-04-30 09:42:46.483	2024-04-30 09:42:46.483	36	\N	\N	\N	\N					\N	\N
23	2024-04-30 09:51:42.001	2024-04-30 09:51:42.001	37	\N	\N	\N	\N					\N	\N
24	2024-04-30 11:18:25.16	2024-04-30 11:18:25.16	38	\N	\N	\N	\N					\N	\N
25	2024-04-30 11:22:17.961	2024-04-30 11:22:17.961	39	\N	\N	\N	\N					\N	\N
26	2024-04-30 11:51:04.079	2024-04-30 11:51:04.079	40	\N	\N	\N	\N					\N	\N
27	2024-04-30 12:17:22.73	2024-04-30 12:17:22.73	41	\N	\N	\N	\N					\N	\N
28	2024-04-30 12:26:49.492	2024-04-30 12:26:49.492	42	\N	\N	\N	\N					\N	\N
29	2024-04-30 12:33:20.569	2024-04-30 12:33:20.569	43	\N	\N	\N	\N					\N	\N
31	2024-05-02 05:21:28.814	2024-05-02 05:21:28.814	45	\N	\N	\N	\N					\N	\N
32	2024-05-02 06:42:46.67	2024-05-02 06:42:46.67	46	\N	\N	\N	\N					\N	\N
55	2024-05-10 09:31:53.772	2024-05-10 09:31:53.772	69	\N	\N	\N	\N					1970-01-03 00:00:00	1970-01-03 00:00:00
56	2024-05-10 09:38:45.996	2024-05-10 09:38:45.996	70	\N	\N	\N	\N					\N	\N
57	2024-05-10 09:41:30.153	2024-05-10 09:41:30.153	71	\N	\N	\N	\N					\N	\N
58	2024-05-10 09:43:13.145	2024-05-10 09:43:13.145	72	\N	\N	\N	\N					1970-01-02 00:00:00	1970-01-02 00:00:00
\.


--
-- Data for Name: ContractFinancialDetail; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractFinancialDetail" (id, "updateadAt", "createdAt", itemid, "currencyValue", "currencyPercent", "billingDay", "billingQtty", "billingFrequencyid", "measuringUnitid", "paymentTypeid", "billingPenaltyPercent", "billingDueDays", remarks, "guaranteeLetter", "guaranteeLetterCurrencyid", "guaranteeLetterDate", "guaranteeLetterValue", "contractItemId", active, price, currencyid, "advancePercent", "goodexecutionLetter", "goodexecutionLetterBankId", "goodexecutionLetterCurrencyId", "goodexecutionLetterDate", "goodexecutionLetterInfo", "goodexecutionLetterValue", "guaranteeLetterBankId", "guaranteeLetterInfo") FROM stdin;
56	2024-05-09 11:06:00.071	2024-05-09 09:56:48.089	1	\N	0	1	1	3	1	2	10	10	bbb	t	3	2024-05-05 21:00:00	8888	91	t	999	2	0	t	4	5	2024-05-06 21:00:00	2	999999	1	1
57	2024-05-09 11:24:04.773	2024-05-09 11:08:27.999	2	\N	0	1	1	4	1	2	10	10		t	2	2024-05-12 21:00:00	8888	92	t	888	2	0	f	\N	\N	1970-01-01 00:00:00		\N	4	
\.


--
-- Data for Name: ContractFinancialDetailSchedule; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractFinancialDetailSchedule" (id, "updateadAt", "createdAt", itemid, date, "measuringUnitid", "billingQtty", "totalContractValue", "billingValue", "isInvoiced", "isPayed", currencyid, active, "contractfinancialItemId") FROM stdin;
524	2024-05-09 11:24:04.788	2024-05-09 11:24:04.788	2	2024-05-01 00:00:00	1	1	888	888	f	f	2	t	57
525	2024-05-09 11:24:04.788	2024-05-09 11:24:04.788	2	2024-08-01 00:00:00	1	1	888	888	f	f	2	t	57
526	2024-05-09 11:24:04.788	2024-05-09 11:24:04.788	2	2024-11-01 00:00:00	1	1	888	888	f	f	2	t	57
509	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2024-05-01 00:00:00	\N	1	333	333	f	f	2	t	56
510	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2024-06-01 00:00:00	\N	1	333	333	f	f	2	t	56
511	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2024-07-01 00:00:00	\N	1	333	333	f	f	2	t	56
512	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2024-08-01 00:00:00	\N	1	333	333	f	f	2	t	56
513	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2024-09-01 00:00:00	\N	1	333	333	f	f	2	t	56
514	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2024-10-01 00:00:00	\N	1	333	333	f	f	2	t	56
515	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2024-11-01 00:00:00	\N	1	333	333	f	f	2	t	56
516	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2024-12-01 00:00:00	\N	1	333	333	f	f	2	t	56
517	2024-05-09 11:06:00.09	2024-05-09 11:06:00.09	1	2025-01-01 00:00:00	\N	1	333	333	f	f	2	t	56
\.


--
-- Data for Name: ContractItems; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractItems" (id, "updateadAt", "createdAt", "contractId", itemid, active, "billingFrequencyid", "currencyValue", currencyid) FROM stdin;
91	2024-05-09 11:06:00.066	2024-05-09 09:56:48.043	66	1	t	3	\N	2
92	2024-05-09 11:24:04.76	2024-05-09 11:08:27.993	67	2	t	4	\N	2
\.


--
-- Data for Name: ContractStatus; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractStatus" (id, name) FROM stdin;
1	In lucru
2	Asteapta aprobarea
3	In curs de revizuire
4	Aprobat
5	In executie
6	Activ
7	Expirat
8	Finalizat
9	Reinnoit
10	Modificat
11	Inchis inainte de termen
12	Contestat
13	Respins
\.


--
-- Data for Name: ContractTasks; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTasks" (id, "updateadAt", "createdAt", "taskName", "contractId", due, notes, "assignedId", "requestorId", "statusId", rejected_reason, "taskPriorityId", type, uuid) FROM stdin;
9	2024-04-30 05:21:47.648	2024-04-30 05:21:47.648		32	2024-04-30 05:16:54.44		2	5	2	werwer	2	action_task	
10	2024-04-30 06:13:08.894	2024-04-30 06:13:08.894	Real	32	2024-04-27 21:00:00	Real	1	1	4	Yupi	3	action_task	
16	2024-04-30 08:08:04.188	2024-04-30 08:08:04.188	23423	32	2024-04-30 08:07:34.264	<p>234432432324324</p>	1	2	1	234243423	1	action_task	
7	2024-04-30 09:37:35.887	2024-04-30 05:01:36.711	65439	32	2024-04-30 05:01:22.405	4569	5	1	3		1	action_task	
14	2024-04-30 09:37:35.887	2024-04-30 07:57:55.871	I am	35	2024-04-28 21:00:00		5	2	2	Contracte dep. IT	1	action_task	
17	2024-04-30 09:43:05.042	2024-04-30 09:43:05.042	Flux dep op	36	2024-05-01 00:00:00	<p>Numar Contract: test flux ;&nbsp;</p><p>Data semnarii: 02.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 15.08.2024 ;&nbsp;</p><p>Scurta descriere: Sa se faca mentenanta!;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	674aacd2-6675-4d27-be7f-e36ecb119318
55	2024-05-08 07:29:05.117	2024-05-08 07:29:05.117	Flux aprobare contracte dep Operational	65	2024-05-09 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">4</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">25.05.2024</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">07.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">30.05.2024</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">4</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de inchiriere</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">RO245678833</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">j40/2022</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">234423423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Generic </span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">razvan.mustata@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746150044</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Rep</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">0</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">NA</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p>	2	3	1		2	approval_task	0d3abe6b-47ab-4eb5-afec-685b9f024693
8	2024-04-30 06:50:02.68	2024-04-30 05:17:17	werwer3310	32	2024-03-31 21:00:00	0werwer12	2	5	2	re990	1	action_task	
11	2024-04-30 07:04:52.983	2024-04-30 06:58:45.204	5rz1	32	2024-04-28 21:00:00	1d	2	5	2	111m	1	action_task	
12	2024-04-30 07:24:05.047	2024-04-30 07:24:05.047	Flux dep op	34	2024-05-01 00:00:00	<p>Numar Contract: aa ;&nbsp;</p><p>Data semnarii: 12.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 06.11.2024 ;&nbsp;</p><p>Scurta descriere: sadada;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	8c74842e-5950-436c-8403-d3e21ac38ac4
13	2024-04-30 07:24:05.047	2024-04-30 07:24:05.047	Flux dep op	35	2024-05-01 00:00:00	<p>Numar Contract: aa ;&nbsp;</p><p>Data semnarii: 12.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 06.11.2024 ;&nbsp;</p><p>Scurta descriere: sadada;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	94e76917-01d9-483e-aa68-4800d23b2bed
15	2024-04-30 07:59:50.986	2024-04-30 07:59:50.986	asdsdsa	32	2024-04-30 07:59:34.367		1	2	4	asdsads	1	action_task	
18	2024-04-30 09:44:25.045	2024-04-30 09:44:25.045	Flux dep op	36	2024-05-01 00:00:00	<p>Numar Contract: test flux ;&nbsp;</p><p>Data semnarii: 02.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 15.08.2024 ;&nbsp;</p><p>Scurta descriere: Sa se faca mentenanta!;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	1		2	approval_task	f6dd22bc-dde1-40de-b9e2-d02096885c59
19	2024-04-30 09:53:38.09	2024-04-30 09:52:05.045	Flux dep op	37	2024-05-01 00:00:00	<p>Numar Contract: 2233 ;&nbsp;</p><p>Data semnarii: 09.04.2024 ;&nbsp;</p><p>Incepand cu data: 01.05.2024 ;&nbsp;</p><p>Termene de finalizare: 25.07.2024 ;&nbsp;</p><p>Scurta descriere: 3333;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	7ceb281b-9e66-42b5-9fcd-6e2c0c21ea63
56	2024-05-08 11:41:40.342	2024-05-08 11:41:05.094	Flux aprobare contracte dep Operational	66	2024-05-09 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">pebune</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">02.05.2024</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">02.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">01.01.2025</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">wer</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de Vanzare-Cumparare</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">RO245678833</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">j40/2022</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">234423423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Generic </span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">razvan.mustata@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746150044</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Rep</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Inchiriere</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">200</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">EUR</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Lunar</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">Ordin de Plată</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">Oră (h)</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">3</span>;</p>	2	3	4		2	approval_task	51e6ebcb-57b9-49b4-9130-0f1a3f1ca470
20	2024-04-30 09:54:30.4	2024-04-30 09:53:40.043	Flux dep op	37	2024-05-01 00:00:00	<p>Numar Contract: 2233 ;&nbsp;</p><p>Data semnarii: 09.04.2024 ;&nbsp;</p><p>Incepand cu data: 01.05.2024 ;&nbsp;</p><p>Termene de finalizare: 25.07.2024 ;&nbsp;</p><p>Scurta descriere: 3333;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	4		2	approval_task	7e4aa197-d0d6-4b0a-9d2f-170049a404d4
21	2024-04-30 11:19:18.994	2024-04-30 11:19:05.048	Flux dep op	38	2024-05-01 00:00:00	<p>Numar Contract: 345 ;&nbsp;</p><p>Data semnarii: 24.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 07.11.2024 ;&nbsp;</p><p>Scurta descriere: 34534534534;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	794d9467-b97c-4bb1-b982-d1dbeba99d77
57	2024-05-08 11:41:48.763	2024-05-08 11:41:30.143	Flux aprobare contracte dep Operational	66	2024-05-09 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">pebune</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">02.05.2024</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">02.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">01.01.2025</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">wer</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de Vanzare-Cumparare</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">RO245678833</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">j40/2022</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">234423423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Generic </span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">razvan.mustata@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746150044</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Rep</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Inchiriere</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">200</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">EUR</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Lunar</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">Ordin de Plată</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">Oră (h)</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">3</span>;</p>	1	3	4		2	approval_task	07f63b83-7cda-47b9-b28c-ccfc59d4914d
22	2024-04-30 11:19:52.332	2024-04-30 11:19:20.048	Flux dep op	38	2024-05-01 00:00:00	<p>Numar Contract: 345 ;&nbsp;</p><p>Data semnarii: 24.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 07.11.2024 ;&nbsp;</p><p>Scurta descriere: 34534534534;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	4		2	approval_task	4e610a41-11d5-464b-b070-c1e64dc5507e
23	2024-04-30 11:23:47.428	2024-04-30 11:23:05.052	Flux dep op	39	2024-05-01 00:00:00	<p>Numar Contract: wer999 ;&nbsp;</p><p>Data semnarii: 20.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 23.08.2024 ;&nbsp;</p><p>Scurta descriere: ewrwer;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: DRAGONUL ROSU SA ;&nbsp;</p><p>Reg Comertului Entitate: 15419962 ;&nbsp;</p><p>Cod Fiscal Entitate: J23/780/2003 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>Iban Entitate: 23442243423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Victor Prodescu ;&nbsp;</p><p>Email Entitate: victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746112233 ;&nbsp;</p><p>Rol Persoana Entitate: IT Manager;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	8a718551-cac6-49da-b76a-ad2db83b4f0e
58	2024-05-09 07:26:05.092	2024-05-09 07:26:05.092	Flux aprobare contracte dep Operational	67	2024-05-10 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">pebune</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">03.05.2024</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">03.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">02.01.2025</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">act aditional</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de Vanzare-Cumparare</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">RO245678833</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">j40/2022</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">234423423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Generic </span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">razvan.mustata@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746150044</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Rep</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">0</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">NA</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p>	2	3	1		2	approval_task	541d05f7-97ed-497e-a41a-a670348690e3
24	2024-04-30 11:24:45.027	2024-04-30 11:23:50.047	Flux dep op	39	2024-05-01 00:00:00	<p>Numar Contract: wer999 ;&nbsp;</p><p>Data semnarii: 20.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 23.08.2024 ;&nbsp;</p><p>Scurta descriere: ewrwer;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: DRAGONUL ROSU SA ;&nbsp;</p><p>Reg Comertului Entitate: 15419962 ;&nbsp;</p><p>Cod Fiscal Entitate: J23/780/2003 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>Iban Entitate: 23442243423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Victor Prodescu ;&nbsp;</p><p>Email Entitate: victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746112233 ;&nbsp;</p><p>Rol Persoana Entitate: IT Manager;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	4		2	approval_task	6db03a4e-0536-452f-bf29-a5a55baf11a5
25	2024-04-30 11:52:28.852	2024-04-30 11:52:05.045	Flux dep op	40	2024-05-01 00:00:00	<p>Numar Contract: 234234 ;&nbsp;</p><p>Data semnarii: 13.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 01.05.2024 ;&nbsp;</p><p>Scurta descriere: 23423;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: DRAGONUL ROSU SA ;&nbsp;</p><p>Reg Comertului Entitate: 15419962 ;&nbsp;</p><p>Cod Fiscal Entitate: J23/780/2003 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>Iban Entitate: 23442243423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Victor Prodescu ;&nbsp;</p><p>Email Entitate: victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746112233 ;&nbsp;</p><p>Rol Persoana Entitate: IT Manager;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	1fd4635e-8195-453e-9129-380e1f23e027
59	2024-05-10 09:32:05.148	2024-05-10 09:32:05.148	Flux aprobare contracte dep Operational	69	2024-05-11 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">43345aa</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">04.05.2024</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">03.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">18.07.2024</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">345345aa</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de Vanzare-Cumparare</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">RO245678833</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">j40/2022</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">234423423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Generic </span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">razvan.mustata@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746150044</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Rep</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">0</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">NA</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p>	2	3	1		2	approval_task	83a7ff0d-579c-4948-b525-a497922cae8f
26	2024-04-30 11:52:48.423	2024-04-30 11:52:30.056	Flux dep op	40	2024-05-01 00:00:00	<p>Numar Contract: 234234 ;&nbsp;</p><p>Data semnarii: 13.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 01.05.2024 ;&nbsp;</p><p>Scurta descriere: 23423;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: DRAGONUL ROSU SA ;&nbsp;</p><p>Reg Comertului Entitate: 15419962 ;&nbsp;</p><p>Cod Fiscal Entitate: J23/780/2003 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>Iban Entitate: 23442243423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Victor Prodescu ;&nbsp;</p><p>Email Entitate: victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746112233 ;&nbsp;</p><p>Rol Persoana Entitate: IT Manager;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	4		2	approval_task	ff9a7576-3dd1-4591-90df-7d51b733f956
27	2024-04-30 12:19:10.861	2024-04-30 12:18:05.061	Task Contracte dep. IT4	41	2024-05-01 00:00:00	<p>ert ;&nbsp;</p><p>20.04.2024 ;&nbsp;</p><p>03.04.2024 ;&nbsp;</p><p>25.04.2024 ;&nbsp;</p><p>SoftHub ;&nbsp;</p><p>NIRO INVESTMENT SA ;&nbsp;</p><p>ert ;&nbsp;</p><p>J40/23/20422 ;&nbsp;</p><p>RO2456788 ;&nbsp;</p><p>Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>ING ;&nbsp;</p><p>Tineretului ;&nbsp;</p><p>423423423 ;&nbsp;</p><p>Razvan Mustata ;&nbsp;</p><p>razvan.mustata@gmail.com ;&nbsp;</p><p>+40746150001 ;&nbsp;</p><p>Manager ;&nbsp;</p><p>RO245678833 ;&nbsp;</p><p>j40/2022 ;&nbsp;</p><p>Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>234423423423 ;&nbsp;</p><p>RON ;&nbsp;</p><p>Generic  ;&nbsp;</p><p>razvan.mustata@nirogroup.ro ;&nbsp;</p><p>0746150044 ;&nbsp;</p><p>IT Rep ;&nbsp;</p><p>Contracte de inchiriere ;&nbsp;</p>	2	3	4		2	approval_task	bbf486fe-bac9-4986-b4ed-4624ad480a8d
28	2024-04-30 12:27:18.12	2024-04-30 12:27:05.067	Task Contracte dep. IT4	42	2024-05-01 00:00:00	<p>wer ;&nbsp;</p><p>18.04.2024 ;&nbsp;</p><p>02.04.2024 ;&nbsp;</p><p>01.05.2024 ;&nbsp;</p><p>SoftHub ;&nbsp;</p><p>DRAGONUL ROSU SA  ;&nbsp;</p><p>wer ;&nbsp;</p><p>J40/23/20422 ;&nbsp;</p><p>RO2456788 ;&nbsp;</p><p>Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>ING ;&nbsp;</p><p>Tineretului ;&nbsp;</p><p>423423423 ;&nbsp;</p><p>Razvan Mustata ;&nbsp;</p><p>razvan.mustata@gmail.com ;&nbsp;</p><p>+40746150001 ;&nbsp;</p><p>Manager ;&nbsp;</p><p>15419962 ;&nbsp;</p><p>J23/780/2003 ;&nbsp;</p><p>Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>23442243423423 ;&nbsp;</p><p>RON ;&nbsp;</p><p>Victor Prodescu ;&nbsp;</p><p>victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>0746112233 ;&nbsp;</p><p>IT Manager ;&nbsp;</p><p>Contracte de Vanzare-Cumparare ;&nbsp;</p>	2	3	4		2	approval_task	98984c68-0f77-48dd-95d2-c03bfa9877cd
60	2024-05-10 09:42:05.089	2024-05-10 09:42:05.089	Flux aprobare contracte dep Operational	71	2024-05-11 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">546</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">undefined</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">10.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">01.06.2024</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">456</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de servicii</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">RO245678833</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">j40/2022</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">234423423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Generic </span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">razvan.mustata@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746150044</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Rep</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">0</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">NA</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p>	2	3	1		2	approval_task	de982f32-1e01-4591-9c77-c75a149640b6
29	2024-04-30 12:34:25.192	2024-04-30 12:34:05.08	Flux aprobare contracte dep Operational	43	2024-05-01 00:00:00	<p>Numar Contract: wer ;&nbsp;</p><p>Data semnarii: 10.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 07.11.2024 ;&nbsp;</p><p>Scurta descriere: wer;&nbsp;</p><p>Tip Contract: Contracte de servicii;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: DRAGONUL ROSU SA ;&nbsp;</p><p>Reg Comertului Entitate: 15419962 ;&nbsp;</p><p>Cod Fiscal Entitate: J23/780/2003 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>Iban Entitate: 23442243423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Victor Prodescu ;&nbsp;</p><p>Email Entitate: victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746112233 ;&nbsp;</p><p>Rol Persoana Entitate: IT Manager;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	4b6070f4-ef57-4d93-b4f6-b94b7ad77aca
30	2024-04-30 12:34:46.278	2024-04-30 12:34:30.072	Flux aprobare contracte dep Operational	43	2024-05-01 00:00:00	<p>Numar Contract: wer ;&nbsp;</p><p>Data semnarii: 10.04.2024 ;&nbsp;</p><p>Incepand cu data: 02.04.2024 ;&nbsp;</p><p>Termene de finalizare: 07.11.2024 ;&nbsp;</p><p>Scurta descriere: wer;&nbsp;</p><p>Tip Contract: Contracte de servicii;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: DRAGONUL ROSU SA ;&nbsp;</p><p>Reg Comertului Entitate: 15419962 ;&nbsp;</p><p>Cod Fiscal Entitate: J23/780/2003 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>Iban Entitate: 23442243423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Victor Prodescu ;&nbsp;</p><p>Email Entitate: victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746112233 ;&nbsp;</p><p>Rol Persoana Entitate: IT Manager;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	4		2	approval_task	8fd2b0c0-6c52-4b8a-828e-be95a06f8f5c
31	2024-05-02 05:08:30.564	2024-05-02 05:08:05.064	Flux aprobare contracte dep Operational	44	2024-05-03 00:00:00	<p>Numar Contract: 43345 ;&nbsp;</p><p>Data semnarii: 03.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 17.07.2024 ;&nbsp;</p><p>Scurta descriere: 345345;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	6f4e42e8-9791-4757-a994-2a4659dea842
32	2024-05-02 05:08:35.068	2024-05-02 05:08:35.068	Flux aprobare contracte dep Operational	44	2024-05-03 00:00:00	<p>Numar Contract: 43345 ;&nbsp;</p><p>Data semnarii: 03.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 17.07.2024 ;&nbsp;</p><p>Scurta descriere: 345345;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	1		2	approval_task	0051fdb5-7307-470d-ade4-97673e1c516a
33	2024-05-02 05:22:05.064	2024-05-02 05:22:05.064	Flux aprobare contracte dep Operational	45	2024-05-03 00:00:00	<p>Numar Contract: wer ;&nbsp;</p><p>Data semnarii: undefined ;&nbsp;</p><p>Incepand cu data: 08.05.2024 ;&nbsp;</p><p>Termene de finalizare: 22.05.2024 ;&nbsp;</p><p>Scurta descriere: 345;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	1eae9e83-60a6-404a-912d-4a283aa14956
61	2024-05-10 09:44:05.319	2024-05-10 09:44:05.319	Flux aprobare contracte dep Operational	72	2024-05-11 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">546aa</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">undefined</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">11.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">02.06.2024</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">456aa</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de servicii</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">RO245678833</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">j40/2022</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">234423423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Generic </span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">razvan.mustata@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746150044</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Rep</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">0</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">NA</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p>	2	3	1		2	approval_task	cfd66a2c-7204-4965-ab2b-8138dfc93e84
34	2024-05-02 05:22:20.071	2024-05-02 05:22:20.071	Flux aprobare contracte dep Operational	45	2024-05-03 00:00:00	<p>Numar Contract: wer ;&nbsp;</p><p>Data semnarii: undefined ;&nbsp;</p><p>Incepand cu data: 08.05.2024 ;&nbsp;</p><p>Termene de finalizare: 22.05.2024 ;&nbsp;</p><p>Scurta descriere: 345;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	1		2	approval_task	81b25ab1-2ffb-4f0c-9d16-1d2cde29fd38
35	2024-05-02 06:43:05.074	2024-05-02 06:43:05.074	Flux aprobare contracte dep Operational	46	2024-05-03 00:00:00	<p>Numar Contract: 345 ;&nbsp;</p><p>Data semnarii: 10.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 08.08.2024 ;&nbsp;</p><p>Scurta descriere: 345345345;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	a2828a8d-1aae-4497-a791-90516da9339b
36	2024-05-02 06:57:05.073	2024-05-02 06:57:05.073	Flux aprobare contracte dep Operational	47	2024-05-03 00:00:00	<p>Numar Contract: teste ;&nbsp;</p><p>Data semnarii: 16.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 01.06.2024 ;&nbsp;</p><p>Scurta descriere: et;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	43f241b4-fec8-435f-9cde-8fab12ad564b
37	2024-05-02 07:08:20.072	2024-05-02 07:08:05.062	Flux aprobare contracte dep Operational	48	2024-05-03 00:00:00	<p>Numar Contract: final ;&nbsp;</p><p>Data semnarii: 14.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 08.08.2024 ;&nbsp;</p><p>Scurta descriere: wer;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: DRAGONUL ROSU SA ;&nbsp;</p><p>Reg Comertului Entitate: 15419962 ;&nbsp;</p><p>Cod Fiscal Entitate: J23/780/2003 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>Iban Entitate: 23442243423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Victor Prodescu ;&nbsp;</p><p>Email Entitate: victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746112233 ;&nbsp;</p><p>Rol Persoana Entitate: IT Manager;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	0cf7ef7f-f972-4150-9516-12d5eebf77a4
38	2024-05-02 07:09:56.562	2024-05-02 07:08:25.067	Flux aprobare contracte dep Operational	48	2024-05-03 00:00:00	<p>Numar Contract: final ;&nbsp;</p><p>Data semnarii: 14.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 08.08.2024 ;&nbsp;</p><p>Scurta descriere: wer;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: DRAGONUL ROSU SA ;&nbsp;</p><p>Reg Comertului Entitate: 15419962 ;&nbsp;</p><p>Cod Fiscal Entitate: J23/780/2003 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal: ;&nbsp;</p><p>Iban Entitate: 23442243423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Victor Prodescu ;&nbsp;</p><p>Email Entitate: victor.prodescu1@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746112233 ;&nbsp;</p><p>Rol Persoana Entitate: IT Manager;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	5		2	approval_task	dcb4b087-0dcc-4696-a650-3cbbcba0f9ef
39	2024-05-02 07:33:26.489	2024-05-02 07:33:05.071	Flux aprobare contracte dep Operational	49	2024-05-03 00:00:00	<p>Numar Contract: testeteste ;&nbsp;</p><p>Data semnarii: 15.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 30.05.2024 ;&nbsp;</p><p>Scurta descriere: testeteste;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	5		2	approval_task	56d049f6-09bd-459d-82ad-0c3a58317743
40	2024-05-02 07:38:22.845	2024-05-02 07:38:05.075	Flux aprobare contracte dep Operational	50	2024-05-03 00:00:00	<p>Numar Contract: reject ;&nbsp;</p><p>Data semnarii: 15.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 31.05.2024 ;&nbsp;</p><p>Scurta descriere: reject;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	b685325e-8646-40fd-8018-3ca62ec1347f
41	2024-05-02 07:39:18.637	2024-05-02 07:38:25.072	Flux aprobare contracte dep Operational	50	2024-05-03 00:00:00	<p>Numar Contract: reject ;&nbsp;</p><p>Data semnarii: 15.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 31.05.2024 ;&nbsp;</p><p>Scurta descriere: reject;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	5		2	approval_task	bdee1ab1-a1fe-45f3-a09f-e0dcfd6c375b
42	2024-05-02 07:47:15.709	2024-05-02 07:47:05.074	Flux aprobare contracte dep Operational	51	2024-05-03 00:00:00	<p>Numar Contract: 234 ;&nbsp;</p><p>Data semnarii: 20.05.2024 ;&nbsp;</p><p>Incepand cu data: 23.05.2024 ;&nbsp;</p><p>Termene de finalizare: 01.06.2024 ;&nbsp;</p><p>Scurta descriere: 234;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	dc1f3e5e-aa1c-4287-a544-7d136b873bde
43	2024-05-02 07:47:49.701	2024-05-02 07:47:20.079	Flux aprobare contracte dep Operational	51	2024-05-03 00:00:00	<p>Numar Contract: 234 ;&nbsp;</p><p>Data semnarii: 20.05.2024 ;&nbsp;</p><p>Incepand cu data: 23.05.2024 ;&nbsp;</p><p>Termene de finalizare: 01.06.2024 ;&nbsp;</p><p>Scurta descriere: 234;&nbsp;</p><p>Tip Contract: Contracte de Vanzare-Cumparare;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	5		2	approval_task	069ccabc-6205-478d-9977-22965dbb2dc4
44	2024-05-02 09:37:56.05	2024-05-02 09:37:05.083	Flux aprobare contracte dep Operational	52	2024-05-03 00:00:00	<p>Numar Contract: wer ;&nbsp;</p><p>Data semnarii: 03.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 24.05.2024 ;&nbsp;</p><p>Scurta descriere: wer;&nbsp;</p><p>Tip Contract: Contracte de servicii;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	e84189e2-fd69-45f0-a15b-f8c7e8ef97a1
45	2024-05-02 09:38:57.701	2024-05-02 09:38:00.15	Flux aprobare contracte dep Operational	52	2024-05-03 00:00:00	<p>Numar Contract: wer ;&nbsp;</p><p>Data semnarii: 03.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 24.05.2024 ;&nbsp;</p><p>Scurta descriere: wer;&nbsp;</p><p>Tip Contract: Contracte de servicii;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	5		2	approval_task	18e3b433-d241-4c0a-8534-31a50c1fb4f7
46	2024-05-02 09:39:05.069	2024-05-02 09:39:05.069	Flux aprobare contracte dep Operational	52	2024-05-03 00:00:00	<p>Numar Contract: wer ;&nbsp;</p><p>Data semnarii: 03.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 24.05.2024 ;&nbsp;</p><p>Scurta descriere: wer;&nbsp;</p><p>Tip Contract: Contracte de servicii;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	dc20a5c2-3da7-4dfc-bced-9d80c0588617
47	2024-05-02 09:49:15.906	2024-05-02 09:49:05.08	Flux aprobare contracte dep Operational	53	2024-05-03 00:00:00	<p>Numar Contract: rrr ;&nbsp;</p><p>Data semnarii: 08.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 30.05.2024 ;&nbsp;</p><p>Scurta descriere: rrr;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	083411da-fdc6-4502-a0d5-df3cf49dc0e7
48	2024-05-02 09:49:33.729	2024-05-02 09:49:20.073	Flux aprobare contracte dep Operational	53	2024-05-03 00:00:00	<p>Numar Contract: rrr ;&nbsp;</p><p>Data semnarii: 08.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 30.05.2024 ;&nbsp;</p><p>Scurta descriere: rrr;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	5		2	approval_task	fbfa188f-2a80-436d-a224-b5e2f1e17d71
49	2024-05-02 09:50:44.739	2024-05-02 09:50:30.092	Flux aprobare contracte dep Operational	53	2024-05-03 00:00:00	<p>Numar Contract: rrr ;&nbsp;</p><p>Data semnarii: 08.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 30.05.2024 ;&nbsp;</p><p>Scurta descriere: rrr;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	4		2	approval_task	a07ebfe3-fe40-4cd2-92c0-1c2d80c4f748
50	2024-05-02 09:51:06.069	2024-05-02 09:50:45.073	Flux aprobare contracte dep Operational	53	2024-05-03 00:00:00	<p>Numar Contract: rrr ;&nbsp;</p><p>Data semnarii: 08.05.2024 ;&nbsp;</p><p>Incepand cu data: 02.05.2024 ;&nbsp;</p><p>Termene de finalizare: 30.05.2024 ;&nbsp;</p><p>Scurta descriere: rrr;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	1	3	4		2	approval_task	01e27dcc-1ca4-42e2-9d16-7338ae6bb9cf
51	2024-05-06 08:05:05.127	2024-05-06 08:05:05.127	Flux aprobare contracte dep Operational	54	2024-05-07 00:00:00	<p>Numar Contract: 435453 ;&nbsp;</p><p>Data semnarii: 29.05.2024 ;&nbsp;</p><p>Incepand cu data: 07.05.2024 ;&nbsp;</p><p>Termene de finalizare: 01.06.2024 ;&nbsp;</p><p>Scurta descriere: 35;&nbsp;</p><p>Tip Contract: Contracte de inchiriere;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	6196ab3c-109b-4ea0-b0aa-fb80f01d84a4
52	2024-05-06 08:36:05.097	2024-05-06 08:36:05.097	Flux aprobare contracte dep Operational	55	2024-05-07 00:00:00	<p>Numar Contract: 999acta ;&nbsp;</p><p>Data semnarii: 09.04.2024 ;&nbsp;</p><p>Incepand cu data: 03.04.2024 ;&nbsp;</p><p>Termene de finalizare: 08.11.2024 ;&nbsp;</p><p>Scurta descriere: Sa se faca un site cu 50% si 50% parteneriat.;&nbsp;</p><p>Tip Contract: Contracte de parteneriat;&nbsp;</p><p><br></p><p>Nume Partener: SoftHub;&nbsp;</p><p>Reg Comertului Partener: J40/23/20422</p><p>Cod Fiscal Partener: RO2456788 ;&nbsp;</p><p>Adresa Partener: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal: ;&nbsp;</p><p>Banca Partener: ING ;&nbsp;</p><p>Filiala Banca Partener: Tineretului ;&nbsp;</p><p>Iban Partener: 423423423 ;&nbsp;</p><p>Persoana Partener: Razvan Mustata ;&nbsp;</p><p>Email Partener: razvan.mustata@gmail.com ;&nbsp;</p><p>Telefon Partener: +40746150001 ;&nbsp;</p><p>Rol Persoana Partener: Manager ;&nbsp;</p><p><br></p><p>Nume Entitate: NIRO INVESTMENT SA;&nbsp;</p><p>Reg Comertului Entitate: RO245678833 ;&nbsp;</p><p>Cod Fiscal Entitate: j40/2022 ;&nbsp;</p><p>Adresa Entitate: Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234 ;&nbsp;</p><p>Iban Entitate: 234423423423 ;&nbsp;</p><p>Valuta Cont Iban Entitate: RON ;&nbsp;</p><p>Persoana Entitate:&nbsp;Generic  ;&nbsp;</p><p>Email Entitate: razvan.mustata@nirogroup.ro ;&nbsp;</p><p>Telefon Entitate: 0746150044 ;&nbsp;</p><p>Rol Persoana Entitate: IT Rep;&nbsp;</p><p><br></p><p>Obiect de contract: NA;</p><p>Pretul contractului: 0;</p><p>Valuta contractului: NA;</p><p>Recurenta: NA&nbsp;</p><p>Tip Plata: NA;</p><p>Unitate de masura: NA;</p><p>Note plata: NA;</p>	2	3	1		2	approval_task	6f545758-da97-414b-bdc7-1bb003ba5c28
53	2024-05-06 12:50:05.102	2024-05-06 12:50:05.102	Flux aprobare contracte dep Operational	60	2024-05-07 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">wer</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">undefined</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">02.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">30.05.2024</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ewr</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de colaborare</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">DRAGONUL ROSU SA </span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">15419962</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">J23/780/2003</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Ilfov, Oras:Dobroeşti, Strada:Dragonul Rosu, Numar:Nr 1-10, Cod Postal:</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">23442243423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Victor Prodescu</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">victor.prodescu1@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746112233</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Manager</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">0</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">NA</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p>	2	3	1		2	approval_task	6352fb98-b199-4206-bfb7-96445251f1c6
54	2024-05-06 12:52:05.36	2024-05-06 12:52:05.36	Flux aprobare contracte dep Operational	61	2024-05-07 00:00:00	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">wer</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">undefined</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">07.05.2024</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">29.05.2024</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">wer</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Contracte de inchiriere</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">SoftHub</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">J40/23/20422</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">RO2456788</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad Judetul, Numar:2, Cod Postal:</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">ING</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">Tineretului</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">423423423</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">Razvan Mustata</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">razvan.mustata@gmail.com</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">+40746150001</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">Manager</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">NIRO INVESTMENT SA</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">RO245678833</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">j40/2022</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Traian, Numar:234, Cod Postal:234</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">234423423423</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">RON</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">Generic </span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">razvan.mustata@nirogroup.ro</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">0746150044</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">IT Rep</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">0</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">NA</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">NA</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">NA</span>;</p>	2	3	1		2	approval_task	c12e28a9-8405-4eef-b7e1-6f0aee087525
\.


--
-- Data for Name: ContractTasksDueDates; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTasksDueDates" (id, name, days) FROM stdin;
1	In ziua generarii task-ului	0
2	La o zi dupa start flux	1
3	La 2 zile dupa start flux	2
4	La 3 zile dupa start flux	3
5	La 4 zile dupa start flux	4
6	La 5 zile dupa start flux	5
\.


--
-- Data for Name: ContractTasksPriority; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTasksPriority" (id, name) FROM stdin;
1	Normală
2	Foarte Importantă
3	Importanță Maximă
\.


--
-- Data for Name: ContractTasksReminders; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTasksReminders" (id, name, days) FROM stdin;
1	La data limită	0
2	1 zi inainte de data limită	-1
3	2 zile inainte de data limită	-2
4	3 zile inainte de data limită	-3
5	4 zile inainte de data limită	-4
6	5 zile inainte de data limită	-5
\.


--
-- Data for Name: ContractTasksStatus; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTasksStatus" (id, name, "Desription") FROM stdin;
1	In curs	
2	Finalizat	
3	Anulat	
4	Aprobat	
5	Respins	
\.


--
-- Data for Name: ContractTemplates; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTemplates" (id, "updateadAt", "createdAt", name, active, "contractTypeId", notes, content) FROM stdin;
1	2024-04-21 07:45:26.132	2024-04-05 05:52:25.04	CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI 	t	3		<p class="ql-align-center"><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p class="ql-align-center"><strong>NR.: </strong><strong style="color: rgb(255, 153, 0);">ContractNumber</strong><strong>/</strong><strong style="color: rgb(255, 153, 0);">SignDate</strong></p><p>Intre:&nbsp;</p><p><strong style="color: rgb(255, 153, 0);">PartnerName</strong> , cu sediul social in <strong style="color: rgb(255, 153, 0);">PartnerAddress</strong>, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p class="ql-align-justify"><strong style="color: rgb(255, 153, 0);">EntityName</strong><strong>, </strong>persoană juridică română, cu sediul în <strong style="color: rgb(255, 153, 0);">EntityAddress</strong>, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p class="ql-align-justify">1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p class="ql-align-justify">1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p class="ql-align-justify">2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">2 | 6&nbsp;</span></p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p class="ql-align-justify">b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p class="ql-align-justify">a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p class="ql-align-justify">b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p class="ql-align-justify">c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p class="ql-align-justify">5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p class="ql-align-justify">5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p class="ql-align-justify">5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p class="ql-align-justify">5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">3 | 6&nbsp;</span></p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p class="ql-align-justify">6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p class="ql-align-justify">7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p class="ql-align-justify">(a) prin acordul scris al Părţilor;&nbsp;</p><p class="ql-align-justify">(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p class="ql-align-justify">(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p class="ql-align-justify">(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p class="ql-align-justify">(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p class="ql-align-justify">7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p class="ql-align-justify">7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p class="ql-align-justify">8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p class="ql-align-justify">8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p class="ql-align-justify">8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">4 | 6&nbsp;</span></p><p>contract.&nbsp;</p><p class="ql-align-justify">8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p class="ql-align-justify">8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p class="ql-align-justify">9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p class="ql-align-justify">9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p class="ql-align-justify">9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p class="ql-align-justify">9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p class="ql-align-justify">9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p class="ql-align-justify">9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p class="ql-align-justify">9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p class="ql-align-justify">10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p class="ql-align-justify"><br></p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p class="ql-align-justify">12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p class="ql-align-right">P a g e <span style="color: rgb(19, 40, 75);">6 | 6&nbsp;</span></p><p class="ql-align-justify">răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p class="ql-align-justify"><strong>Art. 13. Clauze finale&nbsp;</strong></p><p class="ql-align-justify">13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p class="ql-align-justify">13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p class="ql-align-justify">13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p class="ql-align-justify">Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong><span style="color: rgb(19, 40, 75);">&nbsp;</span></p>
\.


--
-- Data for Name: ContractType; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractType" (id, name) FROM stdin;
1	Contracte de Vanzare-Cumparare
2	Contracte de inchiriere
3	Contracte de servicii
4	Contracte de parteneriat
5	Contracte de colaborare
6	Contracte de constructie
7	Contracte de licentiere
8	Contracte de franciză
9	Contracte de imprumut
10	Contracte de agent
11	Contracte de dezvoltare Software
12	Contracte de asigurare
13	Contracte imobiliare
14	Contracte de mentenanta
15	Contracte abonament
16	Contract de schimb
17	Contract de report
18	Contract de antrepriză
19	Contract de asociere în participație
20	Contract de transport
21	Contract de mandat
22	Contract de comision
23	Contract de consignație
24	Contract de agenție
25	Contract de intermediere
26	Contract de depozit
27	Contract de cont curent
28	Contract de joc și pariu
29	Contract de donație
30	Contract de fiducie
31	Contract de leasing
32	Contract de factoring
\.


--
-- Data for Name: Contracts; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Contracts" (id, number, start, "end", sign, completion, remarks, "partnersId", "entityId", "entityaddressId", "entitybankId", "entitypersonsId", "parentId", "partneraddressId", "partnerbankId", "partnerpersonsId", "automaticRenewal", "departmentId", "cashflowId", "categoryId", "costcenterId", "statusId", "typeId", "paymentTypeId", "userId", "isPurchasing", "locationId") FROM stdin;
44	43345	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	2	2	0	1	1	1	t	3	2	1	2	4	1	\N	5	t	1
7	7	2024-04-01 21:00:00	2024-12-31 22:00:00	\N	\N	7	1	4	3	3	3	0	1	1	1	t	1	1	1	2	2	2	\N	1	f	\N
56	4543	2024-05-01 21:00:00	2024-05-21 21:00:00	\N	\N	435	1	3	2	2	2	0	1	1	1	f	1	3	2	3	5	3	\N	5	t	3
36	test flux	2024-04-01 21:00:00	2024-08-14 21:00:00	2024-04-01 21:00:00	\N	Sa se faca mentenanta!	1	3	2	2	2	0	1	1	1	t	3	1	1	1	4	1	\N	5	t	\N
37	2233	2024-04-30 21:00:00	2024-07-24 21:00:00	2024-04-08 21:00:00	\N	3333	1	3	2	2	2	0	1	1	1	t	3	2	1	3	4	1	\N	5	t	\N
8	44	2024-04-01 21:00:00	2024-12-31 22:00:00	\N	\N	44	1	3	2	2	2	0	1	1	1	t	\N	2	2	1	1	2	\N	5	f	\N
25	345_1	2024-04-04 21:00:00	2025-01-03 22:00:00	\N	\N	345_1	1	3	2	2	2	9	1	1	1	t	\N	3	2	3	2	2	\N	\N	f	\N
45	wer	2024-05-07 21:00:00	2024-05-21 21:00:00	\N	\N	345	1	3	2	2	2	0	1	1	1	f	3	\N	2	1	13	2	\N	1	t	\N
2	2	2024-04-02 21:00:00	2024-07-01 21:00:00	2024-04-02 21:00:00	\N	\N	1	3	2	2	2	0	1	1	1	f	\N	2	2	8	4	3	\N	1	f	\N
38	345	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-23 21:00:00	\N	34534534534	1	3	2	2	2	0	1	1	1	t	3	3	2	1	4	2	\N	5	t	\N
26	1	2024-04-08 21:00:00	2024-05-07 21:00:00	2024-04-08 21:00:00	2024-04-14 21:00:00	Vanzare	1	3	2	2	2	1	1	1	1	t	3	2	1	3	2	1	\N	\N	f	\N
28	n3	2024-04-01 21:00:00	2024-08-31 21:00:00	2024-04-01 21:00:00	\N	3	1	3	2	2	2	0	1	1	1	f	3	2	1	1	1	2	\N	5	t	\N
27	n2	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-01 21:00:00	2024-04-30 21:00:00	n2	1	4	3	3	3	0	1	1	1	f	1	2	1	3	1	3	\N	5	t	\N
33	423	2024-04-01 21:00:00	2024-08-29 21:00:00	2024-04-01 21:00:00	\N	234	1	4	3	3	3	0	1	1	1	t	3	2	1	2	1	2	\N	5	t	\N
29	werrew	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-03 21:00:00	\N	wer	1	3	2	2	2	0	1	1	1	t	1	2	2	2	1	1	\N	5	t	\N
4	44a	2024-04-08 21:00:00	2024-06-30 21:00:00	2024-04-08 21:00:00	\N	x	1	3	2	2	2	0	1	1	1	f	3	4	3	8	1	4	\N	5	t	\N
39	wer999	2024-04-01 21:00:00	2024-08-22 21:00:00	2024-04-19 21:00:00	\N	ewrwer	1	4	3	3	3	0	1	1	1	t	3	2	1	2	4	1	\N	5	t	\N
46	345	2024-05-01 21:00:00	2024-08-07 21:00:00	2024-05-09 21:00:00	\N	345345345	1	3	2	2	2	0	1	1	1	t	3	1	2	1	13	1	\N	1	t	\N
40	234234	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-12 21:00:00	\N	23423	1	4	3	3	3	0	1	1	1	t	3	2	1	3	4	2	\N	5	t	\N
31	a2	2024-04-01 21:00:00	2024-12-25 22:00:00	\N	\N	test	1	4	3	3	3	0	1	1	1	t	3	4	1	3	1	2	\N	5	t	\N
1	1	2024-04-10 21:00:00	2024-05-09 21:00:00	2024-04-10 21:00:00	2024-04-16 21:00:00	Vanzare	1	3	2	2	2	0	1	1	1	t	3	2	1	3	1	1	\N	1	t	\N
6	334	2024-04-01 21:00:00	2024-09-30 21:00:00	2024-04-01 21:00:00	\N	Test0	1	4	3	3	3	0	1	1	1	t	3	2	2	3	1	1	\N	5	t	\N
9	345	2024-04-04 21:00:00	2024-08-24 21:00:00	\N	\N	345	1	3	2	2	2	0	1	1	1	t	3	3	2	3	4	2	\N	5	t	\N
41	ert	2024-04-02 21:00:00	2024-04-24 21:00:00	2024-04-19 21:00:00	\N	ert	1	3	2	2	2	0	1	1	1	t	3	1	2	3	4	2	\N	5	t	\N
42	wer	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-17 21:00:00	\N	wer	1	4	3	3	3	0	1	1	1	f	3	1	1	1	4	1	\N	5	t	\N
5	43	2024-04-02 21:00:00	2024-08-07 21:00:00	2024-04-20 21:00:00	\N	Mentenanta	1	4	3	3	3	0	1	1	1	t	3	1	1	1	4	1	\N	5	t	\N
3	33	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x88	1	3	2	2	2	0	1	1	1	f	3	2	2	3	4	3	\N	5	t	\N
47	teste	2024-05-01 21:00:00	2024-05-31 21:00:00	2024-05-15 21:00:00	\N	et	1	3	2	2	2	0	1	1	1	t	3	1	3	3	13	1	\N	1	t	\N
30	a1	2024-04-01 21:00:00	2024-12-01 22:00:00	2024-04-01 21:00:00	\N	aaa1	1	3	2	2	2	0	1	1	1	t	3	2	1	3	1	1	\N	5	t	\N
43	wer	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-09 21:00:00	\N	wer	1	4	3	3	3	0	1	1	1	f	3	3	2	3	4	3	\N	5	t	\N
57	4543	2024-05-01 21:00:00	2024-05-21 21:00:00	\N	\N	435	1	3	2	2	2	0	1	1	1	f	1	3	2	3	5	3	\N	5	t	3
53	rrr	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-07 21:00:00	\N	rrr	1	3	2	2	2	0	1	1	1	f	3	1	1	2	4	2	\N	5	t	\N
48	final	2024-05-01 21:00:00	2024-08-07 21:00:00	2024-05-13 21:00:00	\N	wer	1	4	3	3	3	0	1	1	1	t	3	2	1	2	1	2	\N	5	t	\N
49	testeteste	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-14 21:00:00	\N	testeteste	1	3	2	2	2	0	1	1	1	f	3	2	2	2	13	1	\N	5	t	\N
54	435453	2024-05-06 21:00:00	2024-05-31 21:00:00	2024-05-28 21:00:00	\N	35	1	3	2	2	2	0	1	1	1	f	3	2	2	1	4	2	\N	5	t	\N
50	reject	2024-05-01 21:00:00	2024-05-30 21:00:00	2024-05-14 21:00:00	\N	reject	1	3	2	2	2	0	1	1	1	f	3	2	1	3	13	2	\N	5	t	\N
51	234	2024-05-22 21:00:00	2024-05-31 21:00:00	2024-05-19 21:00:00	\N	234	1	3	2	2	2	0	1	1	1	f	3	2	2	3	1	1	\N	5	t	\N
52	wer	2024-05-01 21:00:00	2024-05-23 21:00:00	2024-05-02 21:00:00	\N	wer	1	3	2	2	2	0	1	1	1	t	3	2	1	2	4	3	\N	5	t	\N
24	88	2024-04-03 21:00:00	2024-06-28 21:00:00	\N	\N	88	1	3	2	2	2	0	1	1	1	t	1	2	2	3	2	2	\N	5	t	1
32	999	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-07 21:00:00	\N	Sa se faca un site cu 50% si 50% parteneriat.	1	3	2	2	2	0	1	1	1	f	3	2	1	2	1	4	\N	5	t	1
35	aa	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadadam	1	3	2	2	2	0	1	1	1	t	3	1	2	1	1	2	\N	5	t	\N
55	999acta	2024-04-02 21:00:00	2024-11-07 22:00:00	2024-04-08 21:00:00	\N	Sa se faca un site cu 50% si 50% parteneriat.	1	3	2	2	2	32	1	1	1	f	3	2	1	2	1	4	\N	\N	f	2
34	aa	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadada	1	3	2	2	2	0	1	1	1	t	3	1	2	1	3	2	\N	5	t	2
58	wer	2024-05-21 21:00:00	2024-05-28 21:00:00	\N	\N	wer	1	3	2	2	2	0	1	1	1	t	1	3	2	3	2	2	\N	5	t	3
61	wer	2024-05-06 21:00:00	2024-05-28 21:00:00	\N	\N	wer	1	3	2	2	2	0	1	1	1	t	3	4	2	2	3	2	\N	5	t	2
59	5435	2024-05-21 21:00:00	2024-05-20 21:00:00	\N	\N	345	1	3	2	2	2	0	1	1	1	t	1	4	3	4	2	2	\N	5	t	3
60	wer	2024-05-01 21:00:00	2024-05-29 21:00:00	\N	\N	ewr	1	4	3	3	3	0	1	1	1	f	3	2	1	2	6	5	\N	5	t	1
62	2354	2024-05-01 21:00:00	2024-05-12 21:00:00	\N	\N	235	1	4	3	3	3	0	1	1	1	f	1	3	2	3	3	2	\N	5	t	2
63	234234	2024-05-01 21:00:00	2024-05-29 21:00:00	\N	\N	234	1	4	3	3	3	0	1	1	1	t	1	2	2	3	5	2	\N	5	f	2
64	testfin	2024-05-01 21:00:00	2027-05-01 21:00:00	2024-05-14 21:00:00	\N	nimic	1	3	2	2	2	0	1	1	1	f	1	3	1	3	5	3	\N	1	t	1
65	4	2024-05-06 21:00:00	2024-05-29 21:00:00	2024-05-24 21:00:00	\N	4	1	3	2	2	2	0	1	1	1	f	3	2	2	3	5	2	\N	5	t	2
66	pebune	2024-05-01 21:00:00	2024-12-31 22:00:00	2024-05-01 21:00:00	\N	wer	1	3	2	2	2	0	1	1	1	f	3	2	3	3	4	1	\N	5	t	1
67	pebune	2024-05-02 21:00:00	2025-01-01 22:00:00	2024-05-02 21:00:00	\N	act aditional	1	3	2	2	2	66	1	1	1	f	3	2	3	3	4	1	\N	\N	f	1
68	7	2024-04-02 21:00:00	2025-01-01 22:00:00	\N	\N	7	1	4	3	3	3	7	1	1	1	t	1	1	1	2	2	2	\N	\N	f	\N
69	43345aa	2024-05-02 21:00:00	2024-07-17 21:00:00	2024-05-03 21:00:00	\N	345345aa	1	3	2	2	2	44	1	1	1	t	3	2	1	2	4	1	\N	\N	f	1
70	wer	2024-05-01 21:00:00	2024-05-16 21:00:00	\N	\N	wer	1	3	2	2	2	0	1	1	1	f	1	2	1	1	3	2	\N	5	t	1
71	546	2024-05-09 21:00:00	2024-05-31 21:00:00	\N	\N	456	1	3	2	2	2	0	1	1	1	f	3	3	3	3	2	3	\N	5	t	1
72	546aa	2024-05-10 21:00:00	2024-06-01 21:00:00	\N	\N	456aa	1	3	2	2	2	71	1	1	1	f	3	3	3	3	2	3	\N	\N	f	1
\.


--
-- Data for Name: ContractsAudit; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractsAudit" (auditid, number, "typeId", "costcenterId", "statusId", start, "end", sign, completion, remarks, "categoryId", "departmentId", "cashflowId", "automaticRenewal", "partnersId", "entityId", "parentId", "partnerpersonsId", "entitypersonsId", "entityaddressId", "partneraddressId", "entitybankId", "partnerbankId", "contractAttachmentsId", "paymentTypeId", "contractContentId", id, "operationType", "createdAt", "updateadAt", "userId", "locationId") FROM stdin;
1	1	1	3	1	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-01 21:00:00	\N	Vanzare	1	1	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	I	2024-04-01 10:34:39.666	2024-04-01 10:34:39.666	1	\N
2	2	3	8	3	2024-04-01 21:00:00	2024-06-30 21:00:00	2024-04-01 21:00:00	\N	\N	2	1	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	2	I	2024-04-01 10:44:02.154	2024-04-01 10:44:02.154	1	\N
3	2	3	8	3	2024-04-02 21:00:00	2024-07-01 21:00:00	2024-04-02 21:00:00	\N	\N	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	2	U	2024-04-01 10:58:37.185	2024-04-01 10:58:37.185	1	\N
4	33	3	3	2	2024-04-01 21:00:00	2024-08-31 21:00:00	2024-04-01 21:00:00	\N	x	3	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	I	2024-04-04 06:20:01.848	2024-04-04 06:20:01.848	1	\N
5	44	4	8	1	2024-04-01 21:00:00	2024-09-25 21:00:00	2024-04-01 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	I	2024-04-04 06:23:09.57	2024-04-04 06:23:09.57	1	\N
6	33	3	3	2	2024-04-02 21:00:00	2024-09-01 21:00:00	2024-04-02 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-04 06:23:28.875	2024-04-04 06:23:28.875	1	\N
7	1	1	3	1	2024-04-02 21:00:00	2024-05-01 21:00:00	2024-04-02 21:00:00	2024-04-08 21:00:00	Vanzare	1	1	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-08 06:01:50.913	2024-04-08 06:01:50.913	1	\N
8	33	3	3	1	2024-04-03 21:00:00	2024-09-02 21:00:00	2024-04-03 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-11 12:23:14.926	2024-04-11 12:23:14.926	1	\N
9	33	3	3	1	2024-04-04 21:00:00	2024-09-03 21:00:00	2024-04-04 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-11 13:04:10.204	2024-04-11 13:04:10.204	1	\N
10	44	4	8	1	2024-04-02 21:00:00	2024-09-26 21:00:00	2024-04-02 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-11 13:13:37.899	2024-04-11 13:13:37.899	1	\N
11	44	4	8	1	2024-04-03 21:00:00	2024-09-27 21:00:00	2024-04-03 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-11 13:15:34.848	2024-04-11 13:15:34.848	1	\N
12	44	4	8	4	2024-04-03 21:00:00	2024-09-27 21:00:00	2024-04-03 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-11 13:15:44.759	2024-04-11 13:15:44.759	1	\N
13	44	4	8	4	2024-04-03 21:00:00	2024-09-27 21:00:00	2024-04-03 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-11 13:15:51.931	2024-04-11 13:15:51.931	1	\N
14	44	4	8	1	2024-04-04 21:00:00	2024-09-28 21:00:00	2024-04-04 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-12 05:14:43.213	2024-04-12 05:14:43.213	1	\N
15	1	1	3	1	2024-04-03 21:00:00	2024-05-02 21:00:00	2024-04-03 21:00:00	2024-04-09 21:00:00	Vanzare	1	2	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-12 05:15:53.76	2024-04-12 05:15:53.76	1	\N
16	1	1	3	1	2024-04-04 21:00:00	2024-05-03 21:00:00	2024-04-04 21:00:00	2024-04-10 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-12 05:21:24.389	2024-04-12 05:21:24.389	1	\N
17	1	1	3	1	2024-04-05 21:00:00	2024-05-04 21:00:00	2024-04-05 21:00:00	2024-04-11 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-12 05:24:07.439	2024-04-12 05:24:07.439	1	\N
18	33	3	3	1	2024-04-05 21:00:00	2024-09-04 21:00:00	2024-04-05 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 06:27:49.121	2024-04-12 06:27:49.121	1	\N
19	44	4	8	1	2024-04-05 21:00:00	2024-09-29 21:00:00	2024-04-05 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-12 06:27:59.461	2024-04-12 06:27:59.461	1	\N
20	1	1	3	1	2024-04-06 21:00:00	2024-05-05 21:00:00	2024-04-06 21:00:00	2024-04-12 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-12 06:31:38.499	2024-04-12 06:31:38.499	1	\N
21	1	1	3	1	2024-04-07 21:00:00	2024-05-06 21:00:00	2024-04-07 21:00:00	2024-04-13 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-12 06:32:44.062	2024-04-12 06:32:44.062	1	\N
22	1	1	3	1	2024-04-07 21:00:00	2024-05-06 21:00:00	2024-04-07 21:00:00	2024-04-13 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-12 06:33:28.351	2024-04-12 06:33:28.351	1	\N
23	1	1	3	1	2024-04-07 21:00:00	2024-05-06 21:00:00	2024-04-07 21:00:00	2024-04-13 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-12 06:33:55.712	2024-04-12 06:33:55.712	1	\N
24	33	3	3	1	2024-04-06 21:00:00	2024-09-05 21:00:00	2024-04-06 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 07:28:01.46	2024-04-12 07:28:01.46	1	\N
25	33	3	3	1	2024-04-07 21:00:00	2024-09-06 21:00:00	2024-04-07 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 07:29:35.999	2024-04-12 07:29:35.999	1	\N
26	44	4	8	1	2024-04-06 21:00:00	2024-09-30 21:00:00	2024-04-06 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-12 07:34:00.391	2024-04-12 07:34:00.391	1	\N
27	33	3	3	1	2024-04-08 21:00:00	2024-09-07 21:00:00	2024-04-08 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 07:34:08.851	2024-04-12 07:34:08.851	1	\N
28	33	3	3	1	2024-04-09 21:00:00	2024-09-08 21:00:00	2024-04-09 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 07:34:17.698	2024-04-12 07:34:17.698	1	\N
29	33	3	3	1	2024-04-10 21:00:00	2024-09-09 21:00:00	2024-04-10 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 08:24:05.485	2024-04-12 08:24:05.485	1	\N
30	33	3	3	1	2024-04-11 21:00:00	2024-09-10 21:00:00	2024-04-11 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 08:28:17.089	2024-04-12 08:28:17.089	1	\N
31	33	3	3	1	2024-04-12 21:00:00	2024-09-11 21:00:00	2024-04-12 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 08:31:18.777	2024-04-12 08:31:18.777	1	\N
32	33	3	3	1	2024-04-13 21:00:00	2024-09-12 21:00:00	2024-04-13 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 08:32:42.93	2024-04-12 08:32:42.93	1	\N
33	33	3	3	1	2024-04-13 21:00:00	2024-09-12 21:00:00	2024-04-13 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 08:33:22.636	2024-04-12 08:33:22.636	1	\N
34	33	3	3	1	2024-04-13 21:00:00	2024-09-12 21:00:00	2024-04-13 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 08:38:16.671	2024-04-12 08:38:16.671	1	\N
35	33	3	3	1	2024-04-14 21:00:00	2024-09-13 21:00:00	2024-04-14 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 08:39:20.181	2024-04-12 08:39:20.181	1	\N
36	33	3	3	1	2024-04-15 21:00:00	2024-09-14 21:00:00	2024-04-15 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 09:41:35.156	2024-04-12 09:41:35.156	1	\N
37	33	3	3	1	2024-04-16 21:00:00	2024-09-15 21:00:00	2024-04-16 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 09:43:58.302	2024-04-12 09:43:58.302	1	\N
38	33	3	3	1	2024-04-17 21:00:00	2024-09-16 21:00:00	2024-04-17 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 09:44:32.969	2024-04-12 09:44:32.969	1	\N
39	33	3	3	1	2024-04-18 21:00:00	2024-09-17 21:00:00	2024-04-18 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 09:52:04.274	2024-04-12 09:52:04.274	1	\N
40	33	3	3	4	2024-04-18 21:00:00	2024-09-17 21:00:00	2024-04-18 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 12:26:20.841	2024-04-12 12:26:20.841	1	\N
41	33	3	3	4	2024-04-18 21:00:00	2024-09-17 21:00:00	2024-04-18 21:00:00	\N	x	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-12 12:26:40.211	2024-04-12 12:26:40.211	1	\N
42	2	3	8	4	2024-04-02 21:00:00	2024-07-01 21:00:00	2024-04-02 21:00:00	\N	\N	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	2	U	2024-04-12 12:35:34.987	2024-04-12 12:35:34.987	1	\N
43	2	3	8	4	2024-04-02 21:00:00	2024-07-01 21:00:00	2024-04-02 21:00:00	\N	\N	2	2	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	2	U	2024-04-12 12:35:46.552	2024-04-12 12:35:46.552	1	\N
44	44	4	8	1	2024-04-07 21:00:00	2024-10-01 21:00:00	2024-04-07 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-12 12:40:36.058	2024-04-12 12:40:36.058	1	\N
45	44	4	8	4	2024-04-07 21:00:00	2024-10-01 21:00:00	2024-04-07 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-12 12:41:05.455	2024-04-12 12:41:05.455	1	\N
46	44	4	8	4	2024-04-07 21:00:00	2024-10-01 21:00:00	2024-04-07 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-12 12:41:13.291	2024-04-12 12:41:13.291	1	\N
47	43	1	1	1	2024-04-01 21:00:00	2024-12-31 22:00:00	2024-04-19 21:00:00	\N	Mentenanta	1	1	1	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	5	I	2024-04-19 11:34:14.531	2024-04-19 11:34:14.531	1	\N
48	334	1	3	1	2024-04-01 21:00:00	2024-09-30 21:00:00	2024-04-01 21:00:00	\N	Test	2	2	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	6	I	2024-04-19 12:05:55.163	2024-04-19 12:05:55.163	5	\N
49	334	1	3	4	2024-04-01 21:00:00	2024-09-30 21:00:00	2024-04-01 21:00:00	\N	Test	2	2	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	6	U	2024-04-19 12:06:32.372	2024-04-19 12:06:32.372	5	\N
50	334	1	3	4	2024-04-01 21:00:00	2024-09-30 21:00:00	2024-04-01 21:00:00	\N	Test	2	2	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	6	U	2024-04-19 12:06:55.127	2024-04-19 12:06:55.127	5	\N
51	334	1	3	4	2024-04-01 21:00:00	2024-09-30 21:00:00	2024-04-01 21:00:00	\N	Test	2	2	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	6	U	2024-04-19 12:07:01.574	2024-04-19 12:07:01.574	5	\N
52	7	2	2	1	2024-04-01 21:00:00	2024-12-31 22:00:00	\N	\N	7	1	1	1	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	7	I	2024-04-21 06:19:13.654	2024-04-21 06:19:13.654	1	\N
53	44	2	1	1	2024-04-01 21:00:00	2024-12-31 22:00:00	\N	\N	44	2	2	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	8	I	2024-04-21 06:52:48.525	2024-04-21 06:52:48.525	5	\N
54	345	2	3	1	2024-04-01 21:00:00	2024-12-31 22:00:00	\N	\N	345	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	9	I	2024-04-21 07:02:03.928	2024-04-21 07:02:03.928	5	\N
55	44	4	8	4	2024-04-08 21:00:00	2024-06-30 21:00:00	2024-04-08 21:00:00	\N	x	3	1	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-21 07:09:35.155	2024-04-21 07:09:35.155	1	\N
56	88	2	3	2	2024-04-01 21:00:00	2024-10-31 22:00:00	\N	\N	88	2	2	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	24	I	2024-04-21 07:22:38.217	2024-04-21 07:22:38.217	1	\N
57	88	2	3	1	2024-04-02 21:00:00	2024-11-01 22:00:00	\N	\N	88	2	1	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	24	U	2024-04-21 07:31:27.436	2024-04-21 07:31:27.436	1	\N
58	345	2	3	2	2024-04-02 21:00:00	2025-01-01 22:00:00	\N	\N	345	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	9	U	2024-04-21 07:39:22.959	2024-04-21 07:39:22.959	1	\N
59	345	2	3	2	2024-04-03 21:00:00	2025-01-02 22:00:00	\N	\N	345	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	9	U	2024-04-21 07:39:55.215	2024-04-21 07:39:55.215	1	\N
60	345_1	2	3	2	2024-04-04 21:00:00	2025-01-03 22:00:00	\N	\N	345_1	2	2	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	25	I	2024-04-21 07:41:24.619	2024-04-21 07:41:24.619	\N	\N
61	1	1	3	2	2024-04-08 21:00:00	2024-05-07 21:00:00	2024-04-08 21:00:00	2024-04-14 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	26	I	2024-04-21 07:54:39.549	2024-04-21 07:54:39.549	\N	\N
62	1	1	3	2	2024-04-08 21:00:00	2024-05-07 21:00:00	2024-04-08 21:00:00	2024-04-14 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-21 07:56:43.996	2024-04-21 07:56:43.996	1	\N
63	88	2	3	2	2024-04-03 21:00:00	2024-06-28 21:00:00	\N	\N	88	2	1	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	24	U	2024-04-22 04:06:48.849	2024-04-22 04:06:48.849	5	\N
64	43	1	1	2	2024-04-02 21:00:00	2024-08-07 21:00:00	2024-04-20 21:00:00	\N	Mentenanta	1	1	1	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	5	U	2024-04-22 04:07:16.553	2024-04-22 04:07:16.553	5	\N
65	345	2	3	2	2024-04-04 21:00:00	2024-08-24 21:00:00	\N	\N	345	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	9	U	2024-04-22 04:07:40.02	2024-04-22 04:07:40.02	5	\N
66	1	1	3	1	2024-04-09 21:00:00	2024-05-08 21:00:00	2024-04-09 21:00:00	2024-04-15 21:00:00	Vanzare	1	1	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-22 04:12:31.426	2024-04-22 04:12:31.426	5	\N
67	1	1	3	3	2024-04-10 21:00:00	2024-05-09 21:00:00	2024-04-10 21:00:00	2024-04-16 21:00:00	Vanzare	1	1	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-22 04:20:05.919	2024-04-22 04:20:05.919	5	\N
68	1	1	3	1	2024-04-10 21:00:00	2024-05-09 21:00:00	2024-04-10 21:00:00	2024-04-16 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-22 04:20:15.435	2024-04-22 04:20:15.435	5	\N
69	1	1	3	1	2024-04-10 21:00:00	2024-05-09 21:00:00	2024-04-10 21:00:00	2024-04-16 21:00:00	Vanzare	1	1	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-22 04:20:18.882	2024-04-22 04:20:18.882	5	\N
70	33	3	3	1	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x	2	1	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-22 04:21:25.262	2024-04-22 04:21:25.262	5	\N
71	33	3	3	4	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x	2	1	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-22 04:23:01.021	2024-04-22 04:23:01.021	5	\N
72	33	3	3	4	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x	2	1	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-22 04:24:28.873	2024-04-22 04:24:28.873	5	\N
73	33	3	3	4	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x	2	1	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-22 04:26:20.469	2024-04-22 04:26:20.469	5	\N
74	n2	3	3	1	2024-04-01 21:00:00	2024-04-30 21:00:00	\N	\N	n2	1	1	2	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	27	I	2024-04-22 04:47:48.262	2024-04-22 04:47:48.262	1	\N
75	n2	3	3	1	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-01 21:00:00	2024-04-30 21:00:00	n2	1	1	2	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	27	U	2024-04-22 04:53:29.285	2024-04-22 04:53:29.285	5	\N
76	n3	2	1	2	2024-04-01 21:00:00	2024-08-31 21:00:00	2024-04-01 21:00:00	\N	3	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	28	I	2024-04-22 06:01:20.075	2024-04-22 06:01:20.075	5	\N
77	n2	3	3	4	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-01 21:00:00	2024-04-30 21:00:00	n2	1	1	2	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	27	U	2024-04-25 10:29:40.938	2024-04-25 10:29:40.938	5	\N
78	33	3	3	1	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x	2	1	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-26 11:24:21.746	2024-04-26 11:24:21.746	5	\N
79	n3	2	1	1	2024-04-01 21:00:00	2024-08-31 21:00:00	2024-04-01 21:00:00	\N	3	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	28	U	2024-04-26 11:24:34.174	2024-04-26 11:24:34.174	5	\N
80	n2	3	3	1	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-01 21:00:00	2024-04-30 21:00:00	n2	1	1	2	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	27	U	2024-04-26 11:32:03.847	2024-04-26 11:32:03.847	5	\N
81	werrew	1	2	1	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-03 21:00:00	\N	wer	2	1	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	29	I	2024-04-26 11:37:51.322	2024-04-26 11:37:51.322	5	\N
82	44a	4	8	1	2024-04-08 21:00:00	2024-06-30 21:00:00	2024-04-08 21:00:00	\N	x	3	3	4	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	4	U	2024-04-29 04:39:58.352	2024-04-29 04:39:58.352	5	\N
83	a1	1	3	1	2024-04-01 21:00:00	2024-12-01 22:00:00	2024-04-01 21:00:00	\N	aaa1	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	30	I	2024-04-29 04:46:02.269	2024-04-29 04:46:02.269	5	\N
84	a1	1	3	4	2024-04-01 21:00:00	2024-12-01 22:00:00	2024-04-01 21:00:00	\N	aaa1	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	30	U	2024-04-29 04:47:59.706	2024-04-29 04:47:59.706	5	\N
85	a1	1	3	4	2024-04-01 21:00:00	2024-12-01 22:00:00	2024-04-01 21:00:00	\N	aaa1	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	30	U	2024-04-29 04:48:19.798	2024-04-29 04:48:19.798	5	\N
86	a1	1	3	4	2024-04-01 21:00:00	2024-12-01 22:00:00	2024-04-01 21:00:00	\N	aaa1	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	30	U	2024-04-29 04:48:39.907	2024-04-29 04:48:39.907	5	\N
87	a2	2	3	1	2024-04-01 21:00:00	2024-12-25 22:00:00	\N	\N	test	1	3	4	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	31	I	2024-04-29 04:53:58.858	2024-04-29 04:53:58.858	5	\N
88	a2	2	3	4	2024-04-01 21:00:00	2024-12-25 22:00:00	\N	\N	test	1	3	4	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	31	U	2024-04-29 05:05:26.118	2024-04-29 05:05:26.118	5	\N
89	a2	2	3	4	2024-04-01 21:00:00	2024-12-25 22:00:00	\N	\N	test	1	3	4	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	31	U	2024-04-29 05:05:36.828	2024-04-29 05:05:36.828	5	\N
90	a2	2	3	4	2024-04-01 21:00:00	2024-12-25 22:00:00	\N	\N	test	1	3	4	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	31	U	2024-04-29 05:06:14.85	2024-04-29 05:06:14.85	5	\N
91	a2	2	3	4	2024-04-01 21:00:00	2024-12-25 22:00:00	\N	\N	test	1	3	4	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	31	U	2024-04-29 05:06:48.18	2024-04-29 05:06:48.18	5	\N
92	1	1	3	1	2024-04-10 21:00:00	2024-05-09 21:00:00	2024-04-10 21:00:00	2024-04-16 21:00:00	Vanzare	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	1	U	2024-04-29 06:13:52.086	2024-04-29 06:13:52.086	1	\N
93	334	1	3	1	2024-04-01 21:00:00	2024-09-30 21:00:00	2024-04-01 21:00:00	\N	Test0	2	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	6	U	2024-04-29 07:32:07.877	2024-04-29 07:32:07.877	5	\N
94	345	2	3	4	2024-04-04 21:00:00	2024-08-24 21:00:00	\N	\N	345	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	9	U	2024-04-29 07:36:02.187	2024-04-29 07:36:02.187	5	\N
95	345	2	3	4	2024-04-04 21:00:00	2024-08-24 21:00:00	\N	\N	345	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	9	U	2024-04-29 07:36:15.959	2024-04-29 07:36:15.959	5	\N
96	33	3	3	1	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x88	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-29 14:17:54.012	2024-04-29 14:17:54.012	5	\N
97	43	1	1	2	2024-04-02 21:00:00	2024-08-07 21:00:00	2024-04-20 21:00:00	\N	Mentenanta	1	3	1	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	5	U	2024-04-29 14:35:16.889	2024-04-29 14:35:16.889	5	\N
98	43	1	1	1	2024-04-02 21:00:00	2024-08-07 21:00:00	2024-04-20 21:00:00	\N	Mentenanta	1	3	1	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	5	U	2024-04-29 14:36:03.74	2024-04-29 14:36:03.74	5	\N
99	43	1	1	4	2024-04-02 21:00:00	2024-08-07 21:00:00	2024-04-20 21:00:00	\N	Mentenanta	1	3	1	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	5	U	2024-04-29 15:41:29.209	2024-04-29 15:41:29.209	5	\N
100	33	3	3	4	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x88	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-29 15:41:42.742	2024-04-29 15:41:42.742	5	\N
101	43	1	1	4	2024-04-02 21:00:00	2024-08-07 21:00:00	2024-04-20 21:00:00	\N	Mentenanta	1	3	1	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	5	U	2024-04-29 15:41:51.513	2024-04-29 15:41:51.513	5	\N
102	33	3	3	4	2024-04-19 21:00:00	2024-09-18 21:00:00	2024-04-19 21:00:00	\N	x88	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	3	U	2024-04-29 15:42:02.974	2024-04-29 15:42:02.974	5	\N
103	a1	1	3	1	2024-04-01 21:00:00	2024-12-01 22:00:00	2024-04-01 21:00:00	\N	aaa1	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	30	U	2024-04-29 15:48:37.751	2024-04-29 15:48:37.751	5	\N
104	999	4	2	1	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-07 21:00:00	\N	Sa se faca un site cu 50% si 50% parteneriat.	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	32	I	2024-04-29 15:51:29.948	2024-04-29 15:51:29.948	5	\N
105	999	4	2	4	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-07 21:00:00	\N	Sa se faca un site cu 50% si 50% parteneriat.	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	32	U	2024-04-29 15:52:43.421	2024-04-29 15:52:43.421	5	\N
106	999	4	2	1	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-07 21:00:00	\N	Sa se faca un site cu 50% si 50% parteneriat.	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	32	U	2024-04-30 07:17:35.334	2024-04-30 07:17:35.334	5	\N
107	423	2	2	1	2024-04-01 21:00:00	2024-08-29 21:00:00	2024-04-01 21:00:00	\N	234	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	33	I	2024-04-30 07:19:11.646	2024-04-30 07:19:11.646	5	\N
108	aa	2	1	3	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadada	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	34	I	2024-04-30 07:23:04.417	2024-04-30 07:23:04.417	5	\N
109	aa	2	1	1	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadada	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	35	I	2024-04-30 07:23:13.781	2024-04-30 07:23:13.781	5	\N
110	test flux	1	1	1	2024-04-01 21:00:00	2024-08-14 21:00:00	2024-04-01 21:00:00	\N	Sa se faca mentenanta!	1	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	36	I	2024-04-30 09:42:46.486	2024-04-30 09:42:46.486	5	\N
111	test flux	1	1	4	2024-04-01 21:00:00	2024-08-14 21:00:00	2024-04-01 21:00:00	\N	Sa se faca mentenanta!	1	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	36	U	2024-04-30 09:44:24.317	2024-04-30 09:44:24.317	5	\N
112	test flux	1	1	4	2024-04-01 21:00:00	2024-08-14 21:00:00	2024-04-01 21:00:00	\N	Sa se faca mentenanta!	1	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	36	U	2024-04-30 09:45:32.818	2024-04-30 09:45:32.818	5	\N
113	2233	1	3	1	2024-04-30 21:00:00	2024-07-24 21:00:00	2024-04-08 21:00:00	\N	3333	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	37	I	2024-04-30 09:51:42.003	2024-04-30 09:51:42.003	5	\N
114	2233	1	3	4	2024-04-30 21:00:00	2024-07-24 21:00:00	2024-04-08 21:00:00	\N	3333	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	37	U	2024-04-30 09:53:38.101	2024-04-30 09:53:38.101	5	\N
115	2233	1	3	4	2024-04-30 21:00:00	2024-07-24 21:00:00	2024-04-08 21:00:00	\N	3333	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	37	U	2024-04-30 09:54:30.408	2024-04-30 09:54:30.408	5	\N
116	345	2	1	1	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-23 21:00:00	\N	34534534534	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	38	I	2024-04-30 11:18:25.163	2024-04-30 11:18:25.163	5	\N
117	345	2	1	4	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-23 21:00:00	\N	34534534534	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	38	U	2024-04-30 11:19:19.007	2024-04-30 11:19:19.007	5	\N
118	345	2	1	4	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-23 21:00:00	\N	34534534534	2	3	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	38	U	2024-04-30 11:19:52.342	2024-04-30 11:19:52.342	5	\N
119	wer999	1	2	1	2024-04-01 21:00:00	2024-08-22 21:00:00	2024-04-19 21:00:00	\N	ewrwer	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	39	I	2024-04-30 11:22:17.963	2024-04-30 11:22:17.963	5	\N
120	wer999	1	2	4	2024-04-01 21:00:00	2024-08-22 21:00:00	2024-04-19 21:00:00	\N	ewrwer	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	39	U	2024-04-30 11:23:47.449	2024-04-30 11:23:47.449	5	\N
121	wer999	1	2	4	2024-04-01 21:00:00	2024-08-22 21:00:00	2024-04-19 21:00:00	\N	ewrwer	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	39	U	2024-04-30 11:24:45.052	2024-04-30 11:24:45.052	5	\N
122	234234	2	3	1	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-12 21:00:00	\N	23423	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	40	I	2024-04-30 11:51:04.081	2024-04-30 11:51:04.081	5	\N
123	234234	2	3	4	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-12 21:00:00	\N	23423	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	40	U	2024-04-30 11:52:28.873	2024-04-30 11:52:28.873	5	\N
124	234234	2	3	4	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-12 21:00:00	\N	23423	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	40	U	2024-04-30 11:52:48.442	2024-04-30 11:52:48.442	5	\N
125	ert	2	3	1	2024-04-02 21:00:00	2024-04-24 21:00:00	2024-04-19 21:00:00	\N	ert	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	41	I	2024-04-30 12:17:22.732	2024-04-30 12:17:22.732	5	\N
126	ert	2	3	4	2024-04-02 21:00:00	2024-04-24 21:00:00	2024-04-19 21:00:00	\N	ert	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	41	U	2024-04-30 12:18:27.087	2024-04-30 12:18:27.087	5	\N
127	ert	2	3	4	2024-04-02 21:00:00	2024-04-24 21:00:00	2024-04-19 21:00:00	\N	ert	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	41	U	2024-04-30 12:19:10.875	2024-04-30 12:19:10.875	5	\N
128	wer	1	1	1	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-17 21:00:00	\N	wer	1	3	1	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	42	I	2024-04-30 12:26:49.495	2024-04-30 12:26:49.495	5	\N
129	wer	1	1	4	2024-04-01 21:00:00	2024-04-30 21:00:00	2024-04-17 21:00:00	\N	wer	1	3	1	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	42	U	2024-04-30 12:27:18.148	2024-04-30 12:27:18.148	5	\N
130	wer	3	3	1	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-09 21:00:00	\N	wer	2	3	3	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	43	I	2024-04-30 12:33:20.57	2024-04-30 12:33:20.57	5	\N
131	wer	3	3	4	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-09 21:00:00	\N	wer	2	3	3	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	43	U	2024-04-30 12:34:25.212	2024-04-30 12:34:25.212	5	\N
132	wer	3	3	4	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-09 21:00:00	\N	wer	2	3	3	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	43	U	2024-04-30 12:34:46.301	2024-04-30 12:34:46.301	5	\N
133	43345	1	2	1	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	I	2024-05-02 05:07:37.336	2024-05-02 05:07:37.336	1	\N
134	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-02 05:08:30.624	2024-05-02 05:08:30.624	1	\N
135	wer	2	\N	1	2024-05-07 21:00:00	2024-05-21 21:00:00	\N	\N	345	2	3	\N	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	45	I	2024-05-02 05:21:28.816	2024-05-02 05:21:28.816	1	\N
136	wer	2	1	13	2024-05-07 21:00:00	2024-05-21 21:00:00	\N	\N	345	2	3	\N	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	45	U	2024-05-02 05:22:19.479	2024-05-02 05:22:19.479	1	\N
137	345	1	1	1	2024-05-01 21:00:00	2024-08-07 21:00:00	2024-05-09 21:00:00	\N	345345345	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	46	I	2024-05-02 06:42:46.673	2024-05-02 06:42:46.673	1	\N
138	345	1	1	13	2024-05-01 21:00:00	2024-08-07 21:00:00	2024-05-09 21:00:00	\N	345345345	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	46	U	2024-05-02 06:43:23.167	2024-05-02 06:43:23.167	1	\N
139	teste	1	3	4	2024-05-01 21:00:00	2024-05-31 21:00:00	2024-05-15 21:00:00	\N	et	3	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	47	I	2024-05-02 06:56:46.1	2024-05-02 06:56:46.1	1	\N
140	teste	1	3	13	2024-05-01 21:00:00	2024-05-31 21:00:00	2024-05-15 21:00:00	\N	et	3	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	47	U	2024-05-02 06:57:22.615	2024-05-02 06:57:22.615	1	\N
141	final	2	2	1	2024-05-01 21:00:00	2024-08-07 21:00:00	2024-05-13 21:00:00	\N	wer	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	48	I	2024-05-02 07:07:13.652	2024-05-02 07:07:13.652	1	\N
142	final	2	2	4	2024-05-01 21:00:00	2024-08-07 21:00:00	2024-05-13 21:00:00	\N	wer	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	48	U	2024-05-02 07:08:20.109	2024-05-02 07:08:20.109	1	\N
143	final	2	2	13	2024-05-01 21:00:00	2024-08-07 21:00:00	2024-05-13 21:00:00	\N	wer	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	48	U	2024-05-02 07:09:56.576	2024-05-02 07:09:56.576	1	\N
144	final	2	2	1	2024-05-01 21:00:00	2024-08-07 21:00:00	2024-05-13 21:00:00	\N	wer	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	48	U	2024-05-02 07:10:44.955	2024-05-02 07:10:44.955	5	\N
145	testeteste	1	2	1	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-14 21:00:00	\N	testeteste	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	49	I	2024-05-02 07:32:19.822	2024-05-02 07:32:19.822	5	\N
146	testeteste	1	2	13	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-14 21:00:00	\N	testeteste	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	49	U	2024-05-02 07:33:26.517	2024-05-02 07:33:26.517	5	\N
147	reject	2	3	1	2024-05-01 21:00:00	2024-05-30 21:00:00	2024-05-14 21:00:00	\N	reject	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	50	I	2024-05-02 07:37:30.845	2024-05-02 07:37:30.845	5	\N
148	reject	2	3	4	2024-05-01 21:00:00	2024-05-30 21:00:00	2024-05-14 21:00:00	\N	reject	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	50	U	2024-05-02 07:38:22.868	2024-05-02 07:38:22.868	5	\N
149	reject	2	3	13	2024-05-01 21:00:00	2024-05-30 21:00:00	2024-05-14 21:00:00	\N	reject	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	50	U	2024-05-02 07:39:18.653	2024-05-02 07:39:18.653	5	\N
150	234	1	3	1	2024-05-22 21:00:00	2024-05-31 21:00:00	2024-05-19 21:00:00	\N	234	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	51	I	2024-05-02 07:46:30.315	2024-05-02 07:46:30.315	5	\N
151	234	1	3	4	2024-05-22 21:00:00	2024-05-31 21:00:00	2024-05-19 21:00:00	\N	234	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	51	U	2024-05-02 07:47:15.734	2024-05-02 07:47:15.734	5	\N
152	234	1	3	13	2024-05-22 21:00:00	2024-05-31 21:00:00	2024-05-19 21:00:00	\N	234	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	51	U	2024-05-02 07:47:49.798	2024-05-02 07:47:49.798	5	\N
153	234	1	3	1	2024-05-22 21:00:00	2024-05-31 21:00:00	2024-05-19 21:00:00	\N	234	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	51	U	2024-05-02 09:06:03.833	2024-05-02 09:06:03.833	5	\N
154	234	1	3	1	2024-05-22 21:00:00	2024-05-31 21:00:00	2024-05-19 21:00:00	\N	234	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	51	U	2024-05-02 09:06:05.811	2024-05-02 09:06:05.811	5	\N
155	wer	3	2	1	2024-05-01 21:00:00	2024-05-23 21:00:00	2024-05-02 21:00:00	\N	wer	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	52	I	2024-05-02 09:36:12.954	2024-05-02 09:36:12.954	5	\N
156	wer	3	2	4	2024-05-01 21:00:00	2024-05-23 21:00:00	2024-05-02 21:00:00	\N	wer	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	52	U	2024-05-02 09:37:56.088	2024-05-02 09:37:56.088	5	\N
157	rrr	2	2	1	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-07 21:00:00	\N	rrr	1	3	1	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	53	I	2024-05-02 09:48:55.26	2024-05-02 09:48:55.26	5	\N
158	rrr	2	2	4	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-07 21:00:00	\N	rrr	1	3	1	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	53	U	2024-05-02 09:49:15.938	2024-05-02 09:49:15.938	5	\N
159	rrr	2	2	13	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-07 21:00:00	\N	rrr	1	3	1	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	53	U	2024-05-02 09:49:33.738	2024-05-02 09:49:33.738	5	\N
160	rrr	2	2	1	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-07 21:00:00	\N	rrr	1	3	1	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	53	U	2024-05-02 09:50:28.07	2024-05-02 09:50:28.07	5	\N
161	rrr	2	2	4	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-07 21:00:00	\N	rrr	1	3	1	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	53	U	2024-05-02 09:50:44.755	2024-05-02 09:50:44.755	5	\N
162	rrr	2	2	4	2024-05-01 21:00:00	2024-05-29 21:00:00	2024-05-07 21:00:00	\N	rrr	1	3	1	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	53	U	2024-05-02 09:51:06.088	2024-05-02 09:51:06.088	5	\N
163	435453	2	1	4	2024-05-06 21:00:00	2024-05-31 21:00:00	2024-05-28 21:00:00	\N	35	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	54	I	2024-05-06 08:04:31.974	2024-05-06 08:04:31.974	5	\N
164	999	4	2	1	2024-04-01 21:00:00	2024-11-06 22:00:00	2024-04-07 21:00:00	\N	Sa se faca un site cu 50% si 50% parteneriat.	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	32	U	2024-05-06 08:30:32.464	2024-05-06 08:30:32.464	5	1
165	999acta	4	2	1	2024-04-02 21:00:00	2024-11-07 22:00:00	2024-04-08 21:00:00	\N	Sa se faca un site cu 50% si 50% parteneriat.	1	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	55	I	2024-05-06 08:35:45.342	2024-05-06 08:35:45.342	\N	2
166	aa	2	1	3	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadada	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	34	U	2024-05-06 10:51:00.63	2024-05-06 10:51:00.63	5	2
167	423	2	2	1	2024-04-01 21:00:00	2024-08-29 21:00:00	2024-04-01 21:00:00	\N	234	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	33	U	2024-05-06 11:41:28.629	2024-05-06 11:41:28.629	5	\N
168	423	2	2	1	2024-04-01 21:00:00	2024-08-29 21:00:00	2024-04-01 21:00:00	\N	234	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	33	U	2024-05-06 11:49:31.042	2024-05-06 11:49:31.042	5	\N
169	423	2	2	1	2024-04-01 21:00:00	2024-08-29 21:00:00	2024-04-01 21:00:00	\N	234	1	3	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	33	U	2024-05-06 11:49:32.781	2024-05-06 11:49:32.781	5	\N
170	aa	2	1	1	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadada	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	35	U	2024-05-06 11:49:43.023	2024-05-06 11:49:43.023	5	\N
171	aa	2	1	1	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadada	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	35	U	2024-05-06 11:49:43.76	2024-05-06 11:49:43.76	5	\N
172	aa	2	1	1	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadada	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	35	U	2024-05-06 11:49:43.963	2024-05-06 11:49:43.963	5	\N
173	aa	2	1	1	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadada	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	35	U	2024-05-06 11:49:57.652	2024-05-06 11:49:57.652	5	\N
174	aa	2	1	1	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadadam	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	35	U	2024-05-06 11:50:26.06	2024-05-06 11:50:26.06	5	\N
175	aa	2	1	1	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadadam	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	35	U	2024-05-06 11:52:12.738	2024-05-06 11:52:12.738	5	\N
176	aa	2	1	1	2024-04-01 21:00:00	2024-11-05 22:00:00	2024-04-11 21:00:00	\N	sadadam	2	3	1	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	35	U	2024-05-06 11:54:16.176	2024-05-06 11:54:16.176	5	\N
177	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:00:44.356	2024-05-06 12:00:44.356	5	\N
178	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:01:12.917	2024-05-06 12:01:12.917	5	\N
179	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:01:12.95	2024-05-06 12:01:12.95	5	\N
180	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:01:17.492	2024-05-06 12:01:17.492	5	1
181	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:04:21.843	2024-05-06 12:04:21.843	5	1
182	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:04:54.073	2024-05-06 12:04:54.073	5	1
183	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:04:54.17	2024-05-06 12:04:54.17	5	1
184	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:27:20.944	2024-05-06 12:27:20.944	5	1
185	43345	1	2	4	2024-05-01 21:00:00	2024-07-16 21:00:00	2024-05-02 21:00:00	\N	345345	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	44	U	2024-05-06 12:28:18.791	2024-05-06 12:28:18.791	5	1
189	5435	2	4	2	2024-05-21 21:00:00	2024-05-20 21:00:00	\N	\N	345	3	1	4	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	59	I	2024-05-06 12:47:52.378	2024-05-06 12:47:52.378	5	3
190	wer	5	2	6	2024-05-01 21:00:00	2024-05-29 21:00:00	\N	\N	ewr	1	3	2	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	60	I	2024-05-06 12:49:48.961	2024-05-06 12:49:48.961	5	1
186	4543	3	3	5	2024-05-01 21:00:00	2024-05-21 21:00:00	\N	\N	435	2	1	3	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	56	I	2024-05-06 12:42:40.568	2024-05-06 12:42:40.568	5	3
187	4543	3	3	5	2024-05-01 21:00:00	2024-05-21 21:00:00	\N	\N	435	2	1	3	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	57	I	2024-05-06 12:42:59.98	2024-05-06 12:42:59.98	5	3
188	wer	2	3	2	2024-05-21 21:00:00	2024-05-28 21:00:00	\N	\N	wer	2	1	3	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	58	I	2024-05-06 12:45:34.246	2024-05-06 12:45:34.246	5	3
191	wer	2	2	3	2024-05-06 21:00:00	2024-05-28 21:00:00	\N	\N	wer	2	3	4	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	61	I	2024-05-06 12:51:35.276	2024-05-06 12:51:35.276	5	2
192	2354	2	3	3	2024-05-01 21:00:00	2024-05-12 21:00:00	\N	\N	235	2	1	3	f	1	4	\N	1	3	3	1	3	1	\N	\N	\N	62	I	2024-05-06 12:53:46.521	2024-05-06 12:53:46.521	5	2
193	234234	2	3	5	2024-05-01 21:00:00	2024-05-29 21:00:00	\N	\N	234	2	1	2	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	63	I	2024-05-06 13:09:10.609	2024-05-06 13:09:10.609	5	2
194	testfin	3	3	5	2024-05-01 21:00:00	2027-05-01 21:00:00	2024-05-14 21:00:00	\N	nimic	1	1	3	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	64	I	2024-05-08 05:46:53.671	2024-05-08 05:46:53.671	1	1
195	4	2	3	5	2024-05-06 21:00:00	2024-05-29 21:00:00	2024-05-24 21:00:00	\N	4	2	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	65	I	2024-05-08 07:28:08.328	2024-05-08 07:28:08.328	5	2
196	pebune	1	3	3	2024-05-01 21:00:00	2024-12-31 22:00:00	2024-05-01 21:00:00	\N	wer	3	1	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	66	I	2024-05-08 08:31:39.051	2024-05-08 08:31:39.051	5	1
197	pebune	1	3	1	2024-05-01 21:00:00	2024-12-31 22:00:00	2024-05-01 21:00:00	\N	wer	3	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	66	U	2024-05-08 11:40:46.033	2024-05-08 11:40:46.033	5	1
198	pebune	1	3	4	2024-05-01 21:00:00	2024-12-31 22:00:00	2024-05-01 21:00:00	\N	wer	3	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	66	U	2024-05-08 11:41:27.813	2024-05-08 11:41:27.813	5	1
199	pebune	1	3	4	2024-05-01 21:00:00	2024-12-31 22:00:00	2024-05-01 21:00:00	\N	wer	3	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	66	U	2024-05-08 11:41:40.35	2024-05-08 11:41:40.35	5	1
200	pebune	1	3	4	2024-05-01 21:00:00	2024-12-31 22:00:00	2024-05-01 21:00:00	\N	wer	3	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	66	U	2024-05-08 11:41:48.785	2024-05-08 11:41:48.785	5	1
201	pebune	1	3	4	2024-05-02 21:00:00	2025-01-01 22:00:00	2024-05-02 21:00:00	\N	act aditional	3	3	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	67	I	2024-05-09 07:25:02.937	2024-05-09 07:25:02.937	\N	1
202	7	2	2	2	2024-04-02 21:00:00	2025-01-01 22:00:00	\N	\N	7	1	1	1	t	1	4	\N	1	3	3	1	3	1	\N	\N	\N	68	I	2024-05-09 07:47:55.746	2024-05-09 07:47:55.746	\N	\N
203	43345aa	1	2	4	2024-05-02 21:00:00	2024-07-17 21:00:00	2024-05-03 21:00:00	\N	345345aa	1	3	2	t	1	3	\N	1	2	2	1	2	1	\N	\N	\N	69	I	2024-05-10 09:31:53.774	2024-05-10 09:31:53.774	\N	1
204	wer	2	1	3	2024-05-01 21:00:00	2024-05-16 21:00:00	\N	\N	wer	1	1	2	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	70	I	2024-05-10 09:38:45.998	2024-05-10 09:38:45.998	5	1
205	546	3	3	2	2024-05-09 21:00:00	2024-05-31 21:00:00	\N	\N	456	3	3	3	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	71	I	2024-05-10 09:41:30.156	2024-05-10 09:41:30.156	5	1
206	546aa	3	3	2	2024-05-10 21:00:00	2024-06-01 21:00:00	\N	\N	456aa	3	3	3	f	1	3	\N	1	2	2	1	2	1	\N	\N	\N	72	I	2024-05-10 09:43:13.148	2024-05-10 09:43:13.148	\N	1
\.


--
-- Data for Name: CostCenter; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."CostCenter" (id, name) FROM stdin;
1	Abonamente RATB
2	Achizitii carti de specialitate
3	Achizitii de specialitate
4	Achizitii produse auto
5	Administratia pietelor
6	Administratie
7	Alpinisti utilitari
8	Alte cheltuieli
9	Alte cheltuieli si evenimente
10	Alte facilitati - masa personal, utilitati, servicii, abonamente RATB
11	Alte facilitati personal alte persoane
12	Alte obiective
13	Alte taxe (Reg. comert, mediu, urbanism, avize)
14	Altele
15	Amenajare incinta
16	Andimed - medicina muncii
17	Anunturi piblicitare, taxe postale si alte taxe
18	Anunturi publicitare, taxe postale
19	Apa
20	Apa menajera
21	Apartamente
22	Apele Romane
23	Ascensorul Schindler - servicii mentenanta
24	Asigurari auto casco si RCA
25	Asigurari cladiri si de viata
26	Autofinantare
27	Autorizatie/Licenta utilizare muzica
28	Bonuri de masa
29	Bonuri de masa alte persoane
30	Bugetul Managerului General
31	Carburant Auto
32	Carburant auto personal Tesa
33	Cheltuieli administrare si intretinere
34	Cheltuieli Comunicare
35	Cheltuieli comunicare
36	Cheltuieli cu personalul
37	Cheltuieli financiare
38	Cheltuieli imagine
39	Cheltuieli linie CFR / taxa drumuri/ taxa poduri
40	Cheltuieli Neprevazute
41	Cheltuieli neprevazute
42	Cheltuieli personal alte obiective fara profit
43	Cheltuieli personal Tesa
44	Cheltuieli sp. SNCFR 
45	Cheltuieli transport
46	Cheltuieli utilitati
\.


--
-- Data for Name: Currency; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Currency" (id, code, name) FROM stdin;
1	RON	LEU
2	EUR	Euro
3	USD	Dolarul SUA
4	CHF	Francul elveţian
5	GBP	Lira sterlină
6	BGN	Leva bulgarească
7	RUB	Rubla rusească
8	ZAR	Randul sud-african
9	BRL	Realul brazilian
10	CNY	Renminbi-ul chinezesc
11	INR	Rupia indiană
12	MXN	Peso-ul mexican
13	NZD	Dolarul neo-zeelandez
14	RSD	Dinarul sârbesc
15	UAH	Hryvna ucraineană
16	TRY	Noua lira turcească
17	AUD	Dolarul australian
18	CAD	Dolarul canadian
19	CZK	Coroana cehă
20	DKK	Coroana daneză
21	EGP	Lira egipteană
22	HUF	Forinți maghiari
23	JPY	Yeni japonezi
24	MDL	Leul moldovenesc
25	NOK	Coroana norvegiană
26	PLN	Zlotul polonez
27	SEK	Coroana suedeză
28	AED	Dirhamul Emiratelor Arabe
29	THB	Bahtul thailandez
\.


--
-- Data for Name: Department; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Department" (id, name) FROM stdin;
1	ITC
3	Operational
\.


--
-- Data for Name: DynamicFields; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."DynamicFields" (id, "updateadAt", "createdAt", fieldname, fieldlabel, fieldorder, fieldtype) FROM stdin;
1	2024-04-01 10:41:01.051	2024-04-01 10:41:01.051	dffInt1	Numar 1	1	Int
2	2024-04-01 10:41:21.506	2024-04-01 10:41:21.506	dffDate1	Data 1	2	Date
3	2024-04-01 10:41:40.705	2024-04-01 10:41:40.705	dffString1	Text	3	String
4	2024-05-10 10:16:58.885	2024-05-10 10:16:58.885	dffString2	String2	4	String
5	2024-05-10 10:18:44.573	2024-05-10 10:18:44.573	dffDate2	Data2	8	Date
\.


--
-- Data for Name: ExchangeRates; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ExchangeRates" (id, "updateadAt", "createdAt", date, amount, name, multiplier) FROM stdin;
1	2024-04-01 10:57:00.428	2024-04-01 10:57:00.428	2024-04-01	1	RON	1
2	2024-04-01 10:57:00.434	2024-04-01 10:57:00.434	2024-04-01	1.2546	AED	1
3	2024-04-01 10:57:00.435	2024-04-01 10:57:00.435	2024-04-01	3.0058	AUD	1
4	2024-04-01 10:57:00.438	2024-04-01 10:57:00.438	2024-04-01	2.5411	BGN	1
5	2024-04-01 10:57:00.439	2024-04-01 10:57:00.439	2024-04-01	0.9188	BRL	1
6	2024-04-01 10:57:00.44	2024-04-01 10:57:00.44	2024-04-01	3.4056	CAD	1
7	2024-04-01 10:57:00.442	2024-04-01 10:57:00.442	2024-04-01	5.1124	CHF	1
8	2024-04-01 10:57:00.443	2024-04-01 10:57:00.443	2024-04-01	0.6372	CNY	1
9	2024-04-01 10:57:00.445	2024-04-01 10:57:00.445	2024-04-01	0.1965	CZK	1
10	2024-04-01 10:57:00.446	2024-04-01 10:57:00.446	2024-04-01	0.6663	DKK	1
11	2024-04-01 10:57:00.447	2024-04-01 10:57:00.447	2024-04-01	0.0977	EGP	1
12	2024-04-01 10:57:00.448	2024-04-01 10:57:00.448	2024-04-01	4.97	EUR	1
13	2024-04-01 10:57:00.449	2024-04-01 10:57:00.449	2024-04-01	5.8152	GBP	1
14	2024-04-01 10:57:00.45	2024-04-01 10:57:00.45	2024-04-01	1.2613	HUF	100
15	2024-04-01 10:57:00.451	2024-04-01 10:57:00.451	2024-04-01	0.0553	INR	1
16	2024-04-01 10:57:00.452	2024-04-01 10:57:00.452	2024-04-01	3.0439	JPY	100
17	2024-04-01 10:57:00.453	2024-04-01 10:57:00.453	2024-04-01	0.3414	KRW	100
18	2024-04-01 10:57:00.453	2024-04-01 10:57:00.453	2024-04-01	0.2613	MDL	1
19	2024-04-01 10:57:00.454	2024-04-01 10:57:00.454	2024-04-01	0.2783	MXN	1
20	2024-04-01 10:57:00.455	2024-04-01 10:57:00.455	2024-04-01	0.4248	NOK	1
21	2024-04-01 10:57:00.455	2024-04-01 10:57:00.455	2024-04-01	2.7564	NZD	1
22	2024-04-01 10:57:00.456	2024-04-01 10:57:00.456	2024-04-01	1.1584	PLN	1
23	2024-04-01 10:57:00.457	2024-04-01 10:57:00.457	2024-04-01	0.0424	RSD	1
24	2024-04-01 10:57:00.457	2024-04-01 10:57:00.457	2024-04-01	0.0498	RUB	1
25	2024-04-01 10:57:00.458	2024-04-01 10:57:00.458	2024-04-01	0.4313	SEK	1
26	2024-04-01 10:57:00.458	2024-04-01 10:57:00.458	2024-04-01	0.1265	THB	1
27	2024-04-01 10:57:00.459	2024-04-01 10:57:00.459	2024-04-01	0.1422	TRY	1
28	2024-04-01 10:57:00.46	2024-04-01 10:57:00.46	2024-04-01	0.1177	UAH	1
29	2024-04-01 10:57:00.46	2024-04-01 10:57:00.46	2024-04-01	4.6074	USD	1
30	2024-04-01 10:57:00.461	2024-04-01 10:57:00.461	2024-04-01	333.3834	XAU	1
31	2024-04-01 10:57:00.462	2024-04-01 10:57:00.462	2024-04-01	6.1017	XDR	1
32	2024-04-01 10:57:00.462	2024-04-01 10:57:00.462	2024-04-01	0.2446	ZAR	1
33	2024-04-02 06:00:03.225	2024-04-02 06:00:03.225	2024-04-02	1	RON	1
34	2024-04-02 06:00:03.244	2024-04-02 06:00:03.244	2024-04-02	1.2546	AED	1
35	2024-04-02 06:00:03.247	2024-04-02 06:00:03.247	2024-04-02	3.0058	AUD	1
36	2024-04-02 06:00:03.247	2024-04-02 06:00:03.247	2024-04-02	2.5411	BGN	1
37	2024-04-02 06:00:03.248	2024-04-02 06:00:03.248	2024-04-02	0.9188	BRL	1
38	2024-04-02 06:00:03.249	2024-04-02 06:00:03.249	2024-04-02	3.4056	CAD	1
39	2024-04-02 06:00:03.25	2024-04-02 06:00:03.25	2024-04-02	5.1124	CHF	1
40	2024-04-02 06:00:03.25	2024-04-02 06:00:03.25	2024-04-02	0.6372	CNY	1
41	2024-04-02 06:00:03.251	2024-04-02 06:00:03.251	2024-04-02	0.1965	CZK	1
42	2024-04-02 06:00:03.252	2024-04-02 06:00:03.252	2024-04-02	0.6663	DKK	1
43	2024-04-02 06:00:03.253	2024-04-02 06:00:03.253	2024-04-02	0.0977	EGP	1
44	2024-04-02 06:00:03.253	2024-04-02 06:00:03.253	2024-04-02	4.97	EUR	1
45	2024-04-02 06:00:03.254	2024-04-02 06:00:03.254	2024-04-02	5.8152	GBP	1
46	2024-04-02 06:00:03.255	2024-04-02 06:00:03.255	2024-04-02	1.2613	HUF	100
47	2024-04-02 06:00:03.256	2024-04-02 06:00:03.256	2024-04-02	0.0553	INR	1
48	2024-04-02 06:00:03.256	2024-04-02 06:00:03.256	2024-04-02	3.0439	JPY	100
49	2024-04-02 06:00:03.257	2024-04-02 06:00:03.257	2024-04-02	0.3414	KRW	100
50	2024-04-02 06:00:03.258	2024-04-02 06:00:03.258	2024-04-02	0.2613	MDL	1
51	2024-04-02 06:00:03.258	2024-04-02 06:00:03.258	2024-04-02	0.2783	MXN	1
52	2024-04-02 06:00:03.259	2024-04-02 06:00:03.259	2024-04-02	0.4248	NOK	1
53	2024-04-02 06:00:03.259	2024-04-02 06:00:03.259	2024-04-02	2.7564	NZD	1
54	2024-04-02 06:00:03.26	2024-04-02 06:00:03.26	2024-04-02	1.1584	PLN	1
55	2024-04-02 06:00:03.261	2024-04-02 06:00:03.261	2024-04-02	0.0424	RSD	1
56	2024-04-02 06:00:03.262	2024-04-02 06:00:03.262	2024-04-02	0.0498	RUB	1
57	2024-04-02 06:00:03.262	2024-04-02 06:00:03.262	2024-04-02	0.4313	SEK	1
58	2024-04-02 06:00:03.263	2024-04-02 06:00:03.263	2024-04-02	0.1265	THB	1
59	2024-04-02 06:00:03.264	2024-04-02 06:00:03.264	2024-04-02	0.1422	TRY	1
60	2024-04-02 06:00:03.265	2024-04-02 06:00:03.265	2024-04-02	0.1177	UAH	1
61	2024-04-02 06:00:03.266	2024-04-02 06:00:03.266	2024-04-02	4.6074	USD	1
62	2024-04-02 06:00:03.266	2024-04-02 06:00:03.266	2024-04-02	333.3834	XAU	1
63	2024-04-02 06:00:03.267	2024-04-02 06:00:03.267	2024-04-02	6.1017	XDR	1
64	2024-04-02 06:00:03.268	2024-04-02 06:00:03.268	2024-04-02	0.2446	ZAR	1
65	2024-04-03 06:00:00.864	2024-04-03 06:00:00.864	2024-04-03	1	RON	1
66	2024-04-03 06:00:00.89	2024-04-03 06:00:00.89	2024-04-03	1.2601	AED	1
67	2024-04-03 06:00:00.892	2024-04-03 06:00:00.892	2024-04-03	3.0123	AUD	1
68	2024-04-03 06:00:00.893	2024-04-03 06:00:00.893	2024-04-03	2.5414	BGN	1
69	2024-04-03 06:00:00.895	2024-04-03 06:00:00.895	2024-04-03	0.9154	BRL	1
70	2024-04-03 06:00:00.898	2024-04-03 06:00:00.898	2024-04-03	3.4132	CAD	1
71	2024-04-03 06:00:00.901	2024-04-03 06:00:00.901	2024-04-03	5.093	CHF	1
72	2024-04-03 06:00:00.902	2024-04-03 06:00:00.902	2024-04-03	0.6395	CNY	1
73	2024-04-03 06:00:00.903	2024-04-03 06:00:00.903	2024-04-03	0.1962	CZK	1
74	2024-04-03 06:00:00.905	2024-04-03 06:00:00.905	2024-04-03	0.6664	DKK	1
75	2024-04-03 06:00:00.906	2024-04-03 06:00:00.906	2024-04-03	0.0981	EGP	1
76	2024-04-03 06:00:00.909	2024-04-03 06:00:00.909	2024-04-03	4.9705	EUR	1
77	2024-04-03 06:00:00.91	2024-04-03 06:00:00.91	2024-04-03	5.8148	GBP	1
78	2024-04-03 06:00:00.911	2024-04-03 06:00:00.911	2024-04-03	1.2587	HUF	100
79	2024-04-03 06:00:00.912	2024-04-03 06:00:00.912	2024-04-03	0.0555	INR	1
80	2024-04-03 06:00:00.913	2024-04-03 06:00:00.913	2024-04-03	3.0508	JPY	100
81	2024-04-03 06:00:00.914	2024-04-03 06:00:00.914	2024-04-03	0.3427	KRW	100
82	2024-04-03 06:00:00.915	2024-04-03 06:00:00.915	2024-04-03	0.2613	MDL	1
83	2024-04-03 06:00:00.915	2024-04-03 06:00:00.915	2024-04-03	0.2789	MXN	1
84	2024-04-03 06:00:00.916	2024-04-03 06:00:00.916	2024-04-03	0.4247	NOK	1
85	2024-04-03 06:00:00.917	2024-04-03 06:00:00.917	2024-04-03	2.7576	NZD	1
86	2024-04-03 06:00:00.918	2024-04-03 06:00:00.918	2024-04-03	1.1577	PLN	1
87	2024-04-03 06:00:00.919	2024-04-03 06:00:00.919	2024-04-03	0.0424	RSD	1
88	2024-04-03 06:00:00.92	2024-04-03 06:00:00.92	2024-04-03	0.05	RUB	1
89	2024-04-03 06:00:00.92	2024-04-03 06:00:00.92	2024-04-03	0.4297	SEK	1
90	2024-04-03 06:00:00.921	2024-04-03 06:00:00.921	2024-04-03	0.1263	THB	1
91	2024-04-03 06:00:00.922	2024-04-03 06:00:00.922	2024-04-03	0.1437	TRY	1
92	2024-04-03 06:00:00.922	2024-04-03 06:00:00.922	2024-04-03	0.1176	UAH	1
93	2024-04-03 06:00:00.923	2024-04-03 06:00:00.923	2024-04-03	4.6276	USD	1
94	2024-04-03 06:00:00.923	2024-04-03 06:00:00.923	2024-04-03	336.2958	XAU	1
95	2024-04-03 06:00:00.924	2024-04-03 06:00:00.924	2024-04-03	6.1169	XDR	1
96	2024-04-03 06:00:00.925	2024-04-03 06:00:00.925	2024-04-03	0.246	ZAR	1
97	2024-04-04 06:00:01.711	2024-04-04 06:00:01.711	2024-04-04	1	RON	1
98	2024-04-04 06:00:01.759	2024-04-04 06:00:01.759	2024-04-04	1.2563	AED	1
99	2024-04-04 06:00:01.768	2024-04-04 06:00:01.768	2024-04-04	3.003	AUD	1
100	2024-04-04 06:00:01.77	2024-04-04 06:00:01.77	2024-04-04	2.5405	BGN	1
101	2024-04-04 06:00:01.771	2024-04-04 06:00:01.771	2024-04-04	0.9107	BRL	1
102	2024-04-04 06:00:01.774	2024-04-04 06:00:01.774	2024-04-04	3.399	CAD	1
103	2024-04-04 06:00:01.777	2024-04-04 06:00:01.777	2024-04-04	5.0765	CHF	1
104	2024-04-04 06:00:01.779	2024-04-04 06:00:01.779	2024-04-04	0.6376	CNY	1
105	2024-04-04 06:00:01.781	2024-04-04 06:00:01.781	2024-04-04	0.1963	CZK	1
106	2024-04-04 06:00:01.782	2024-04-04 06:00:01.782	2024-04-04	0.6662	DKK	1
107	2024-04-04 06:00:01.784	2024-04-04 06:00:01.784	2024-04-04	0.097	EGP	1
108	2024-04-04 06:00:01.785	2024-04-04 06:00:01.785	2024-04-04	4.9689	EUR	1
109	2024-04-04 06:00:01.786	2024-04-04 06:00:01.786	2024-04-04	5.8041	GBP	1
110	2024-04-04 06:00:01.787	2024-04-04 06:00:01.787	2024-04-04	1.2635	HUF	100
111	2024-04-04 06:00:01.788	2024-04-04 06:00:01.788	2024-04-04	0.0553	INR	1
112	2024-04-04 06:00:01.789	2024-04-04 06:00:01.789	2024-04-04	3.0406	JPY	100
113	2024-04-04 06:00:01.79	2024-04-04 06:00:01.79	2024-04-04	0.3417	KRW	100
114	2024-04-04 06:00:01.791	2024-04-04 06:00:01.791	2024-04-04	0.2615	MDL	1
115	2024-04-04 06:00:01.792	2024-04-04 06:00:01.792	2024-04-04	0.2783	MXN	1
116	2024-04-04 06:00:01.792	2024-04-04 06:00:01.792	2024-04-04	0.4256	NOK	1
117	2024-04-04 06:00:01.793	2024-04-04 06:00:01.793	2024-04-04	2.7529	NZD	1
118	2024-04-04 06:00:01.794	2024-04-04 06:00:01.794	2024-04-04	1.1569	PLN	1
119	2024-04-04 06:00:01.795	2024-04-04 06:00:01.795	2024-04-04	0.0424	RSD	1
120	2024-04-04 06:00:01.795	2024-04-04 06:00:01.795	2024-04-04	0.0499	RUB	1
121	2024-04-04 06:00:01.796	2024-04-04 06:00:01.796	2024-04-04	0.4296	SEK	1
122	2024-04-04 06:00:01.797	2024-04-04 06:00:01.797	2024-04-04	0.1257	THB	1
123	2024-04-04 06:00:01.811	2024-04-04 06:00:01.811	2024-04-04	0.1444	TRY	1
124	2024-04-04 06:00:01.84	2024-04-04 06:00:01.84	2024-04-04	0.1178	UAH	1
125	2024-04-04 06:00:01.858	2024-04-04 06:00:01.858	2024-04-04	4.6139	USD	1
126	2024-04-04 06:00:01.859	2024-04-04 06:00:01.859	2024-04-04	336.9552	XAU	1
127	2024-04-04 06:00:01.86	2024-04-04 06:00:01.86	2024-04-04	6.1041	XDR	1
128	2024-04-04 06:00:01.861	2024-04-04 06:00:01.861	2024-04-04	0.2456	ZAR	1
129	2024-04-05 06:00:00.85	2024-04-05 06:00:00.85	2024-04-05	1	RON	1
130	2024-04-05 06:00:00.865	2024-04-05 06:00:00.865	2024-04-05	1.2462	AED	1
131	2024-04-05 06:00:00.868	2024-04-05 06:00:00.868	2024-04-05	3.0224	AUD	1
132	2024-04-05 06:00:00.87	2024-04-05 06:00:00.87	2024-04-05	2.5415	BGN	1
133	2024-04-05 06:00:00.872	2024-04-05 06:00:00.872	2024-04-05	0.9078	BRL	1
134	2024-04-05 06:00:00.874	2024-04-05 06:00:00.874	2024-04-05	3.3897	CAD	1
135	2024-04-05 06:00:00.877	2024-04-05 06:00:00.877	2024-04-05	5.0503	CHF	1
136	2024-04-05 06:00:00.879	2024-04-05 06:00:00.879	2024-04-05	0.6326	CNY	1
137	2024-04-05 06:00:00.88	2024-04-05 06:00:00.88	2024-04-05	0.1965	CZK	1
138	2024-04-05 06:00:00.881	2024-04-05 06:00:00.881	2024-04-05	0.6664	DKK	1
139	2024-04-05 06:00:00.883	2024-04-05 06:00:00.883	2024-04-05	0.0966	EGP	1
140	2024-04-05 06:00:00.884	2024-04-05 06:00:00.884	2024-04-05	4.9708	EUR	1
141	2024-04-05 06:00:00.885	2024-04-05 06:00:00.885	2024-04-05	5.7955	GBP	1
142	2024-04-05 06:00:00.887	2024-04-05 06:00:00.887	2024-04-05	1.2682	HUF	100
143	2024-04-05 06:00:00.888	2024-04-05 06:00:00.888	2024-04-05	0.0548	INR	1
144	2024-04-05 06:00:00.889	2024-04-05 06:00:00.889	2024-04-05	3.016	JPY	100
145	2024-04-05 06:00:00.89	2024-04-05 06:00:00.89	2024-04-05	0.3397	KRW	100
146	2024-04-05 06:00:00.89	2024-04-05 06:00:00.89	2024-04-05	0.2601	MDL	1
147	2024-04-05 06:00:00.891	2024-04-05 06:00:00.891	2024-04-05	0.2767	MXN	1
148	2024-04-05 06:00:00.892	2024-04-05 06:00:00.892	2024-04-05	0.4283	NOK	1
149	2024-04-05 06:00:00.893	2024-04-05 06:00:00.893	2024-04-05	2.7647	NZD	1
150	2024-04-05 06:00:00.894	2024-04-05 06:00:00.894	2024-04-05	1.1568	PLN	1
151	2024-04-05 06:00:00.895	2024-04-05 06:00:00.895	2024-04-05	0.0424	RSD	1
152	2024-04-05 06:00:00.895	2024-04-05 06:00:00.895	2024-04-05	0.0495	RUB	1
153	2024-04-05 06:00:00.896	2024-04-05 06:00:00.896	2024-04-05	0.4318	SEK	1
154	2024-04-05 06:00:00.897	2024-04-05 06:00:00.897	2024-04-05	0.1247	THB	1
155	2024-04-05 06:00:00.897	2024-04-05 06:00:00.897	2024-04-05	0.1435	TRY	1
156	2024-04-05 06:00:00.898	2024-04-05 06:00:00.898	2024-04-05	0.1174	UAH	1
157	2024-04-05 06:00:00.899	2024-04-05 06:00:00.899	2024-04-05	4.5763	USD	1
158	2024-04-05 06:00:00.9	2024-04-05 06:00:00.9	2024-04-05	337.4428	XAU	1
159	2024-04-05 06:00:00.901	2024-04-05 06:00:00.901	2024-04-05	6.0736	XDR	1
160	2024-04-05 06:00:00.901	2024-04-05 06:00:00.901	2024-04-05	0.2459	ZAR	1
161	2024-04-08 06:00:00.282	2024-04-08 06:00:00.282	2024-04-08	1	RON	1
162	2024-04-08 06:00:00.288	2024-04-08 06:00:00.288	2024-04-08	1.2481	AED	1
163	2024-04-08 06:00:00.29	2024-04-08 06:00:00.29	2024-04-08	3.0186	AUD	1
164	2024-04-08 06:00:00.29	2024-04-08 06:00:00.29	2024-04-08	2.5401	BGN	1
165	2024-04-08 06:00:00.291	2024-04-08 06:00:00.291	2024-04-08	0.906	BRL	1
166	2024-04-08 06:00:00.292	2024-04-08 06:00:00.292	2024-04-08	3.3816	CAD	1
167	2024-04-08 06:00:00.294	2024-04-08 06:00:00.294	2024-04-08	5.0765	CHF	1
168	2024-04-08 06:00:00.295	2024-04-08 06:00:00.295	2024-04-08	0.6336	CNY	1
169	2024-04-08 06:00:00.296	2024-04-08 06:00:00.296	2024-04-08	0.1963	CZK	1
170	2024-04-08 06:00:00.296	2024-04-08 06:00:00.296	2024-04-08	0.666	DKK	1
171	2024-04-08 06:00:00.297	2024-04-08 06:00:00.297	2024-04-08	0.0967	EGP	1
172	2024-04-08 06:00:00.3	2024-04-08 06:00:00.3	2024-04-08	4.9681	EUR	1
173	2024-04-08 06:00:00.3	2024-04-08 06:00:00.3	2024-04-08	5.7907	GBP	1
174	2024-04-08 06:00:00.301	2024-04-08 06:00:00.301	2024-04-08	1.2718	HUF	100
175	2024-04-08 06:00:00.302	2024-04-08 06:00:00.302	2024-04-08	0.055	INR	1
176	2024-04-08 06:00:00.302	2024-04-08 06:00:00.302	2024-04-08	3.0274	JPY	100
177	2024-04-08 06:00:00.303	2024-04-08 06:00:00.303	2024-04-08	0.3396	KRW	100
178	2024-04-08 06:00:00.304	2024-04-08 06:00:00.304	2024-04-08	0.258	MDL	1
179	2024-04-08 06:00:00.305	2024-04-08 06:00:00.305	2024-04-08	0.2771	MXN	1
180	2024-04-08 06:00:00.305	2024-04-08 06:00:00.305	2024-04-08	0.4278	NOK	1
181	2024-04-08 06:00:00.306	2024-04-08 06:00:00.306	2024-04-08	2.7595	NZD	1
182	2024-04-08 06:00:00.307	2024-04-08 06:00:00.307	2024-04-08	1.1585	PLN	1
183	2024-04-08 06:00:00.307	2024-04-08 06:00:00.307	2024-04-08	0.0424	RSD	1
184	2024-04-08 06:00:00.308	2024-04-08 06:00:00.308	2024-04-08	0.0496	RUB	1
185	2024-04-08 06:00:00.308	2024-04-08 06:00:00.308	2024-04-08	0.4305	SEK	1
186	2024-04-08 06:00:00.309	2024-04-08 06:00:00.309	2024-04-08	0.1251	THB	1
187	2024-04-08 06:00:00.309	2024-04-08 06:00:00.309	2024-04-08	0.1432	TRY	1
188	2024-04-08 06:00:00.31	2024-04-08 06:00:00.31	2024-04-08	0.1181	UAH	1
189	2024-04-08 06:00:00.311	2024-04-08 06:00:00.311	2024-04-08	4.5835	USD	1
190	2024-04-08 06:00:00.312	2024-04-08 06:00:00.312	2024-04-08	337.7523	XAU	1
191	2024-04-08 06:00:00.314	2024-04-08 06:00:00.314	2024-04-08	6.079	XDR	1
192	2024-04-08 06:00:00.315	2024-04-08 06:00:00.315	2024-04-08	0.246	ZAR	1
193	2024-04-09 06:00:00.657	2024-04-09 06:00:00.657	2024-04-09	1	RON	1
194	2024-04-09 06:00:00.691	2024-04-09 06:00:00.691	2024-04-09	1.2494	AED	1
195	2024-04-09 06:00:00.693	2024-04-09 06:00:00.693	2024-04-09	3.0207	AUD	1
196	2024-04-09 06:00:00.7	2024-04-09 06:00:00.7	2024-04-09	2.54	BGN	1
197	2024-04-09 06:00:00.702	2024-04-09 06:00:00.702	2024-04-09	0.9056	BRL	1
198	2024-04-09 06:00:00.704	2024-04-09 06:00:00.704	2024-04-09	3.3746	CAD	1
199	2024-04-09 06:00:00.707	2024-04-09 06:00:00.707	2024-04-09	5.0663	CHF	1
200	2024-04-09 06:00:00.709	2024-04-09 06:00:00.709	2024-04-09	0.6342	CNY	1
201	2024-04-09 06:00:00.711	2024-04-09 06:00:00.711	2024-04-09	0.1962	CZK	1
202	2024-04-09 06:00:00.713	2024-04-09 06:00:00.713	2024-04-09	0.6661	DKK	1
203	2024-04-09 06:00:00.714	2024-04-09 06:00:00.714	2024-04-09	0.0963	EGP	1
204	2024-04-09 06:00:00.716	2024-04-09 06:00:00.716	2024-04-09	4.9678	EUR	1
205	2024-04-09 06:00:00.717	2024-04-09 06:00:00.717	2024-04-09	5.7923	GBP	1
206	2024-04-09 06:00:00.719	2024-04-09 06:00:00.719	2024-04-09	1.273	HUF	100
207	2024-04-09 06:00:00.72	2024-04-09 06:00:00.72	2024-04-09	0.0551	INR	1
208	2024-04-09 06:00:00.721	2024-04-09 06:00:00.721	2024-04-09	3.0207	JPY	100
209	2024-04-09 06:00:00.722	2024-04-09 06:00:00.722	2024-04-09	0.3384	KRW	100
210	2024-04-09 06:00:00.723	2024-04-09 06:00:00.723	2024-04-09	0.2586	MDL	1
211	2024-04-09 06:00:00.725	2024-04-09 06:00:00.725	2024-04-09	0.2787	MXN	1
212	2024-04-09 06:00:00.726	2024-04-09 06:00:00.726	2024-04-09	0.4285	NOK	1
213	2024-04-09 06:00:00.727	2024-04-09 06:00:00.727	2024-04-09	2.7612	NZD	1
214	2024-04-09 06:00:00.728	2024-04-09 06:00:00.728	2024-04-09	1.1605	PLN	1
215	2024-04-09 06:00:00.729	2024-04-09 06:00:00.729	2024-04-09	0.0424	RSD	1
216	2024-04-09 06:00:00.73	2024-04-09 06:00:00.73	2024-04-09	0.0496	RUB	1
217	2024-04-09 06:00:00.731	2024-04-09 06:00:00.731	2024-04-09	0.4327	SEK	1
218	2024-04-09 06:00:00.732	2024-04-09 06:00:00.732	2024-04-09	0.1251	THB	1
219	2024-04-09 06:00:00.733	2024-04-09 06:00:00.733	2024-04-09	0.1434	TRY	1
220	2024-04-09 06:00:00.734	2024-04-09 06:00:00.734	2024-04-09	0.1177	UAH	1
221	2024-04-09 06:00:00.735	2024-04-09 06:00:00.735	2024-04-09	4.5881	USD	1
222	2024-04-09 06:00:00.736	2024-04-09 06:00:00.736	2024-04-09	344.6541	XAU	1
223	2024-04-09 06:00:00.736	2024-04-09 06:00:00.736	2024-04-09	6.0814	XDR	1
224	2024-04-09 06:00:00.737	2024-04-09 06:00:00.737	2024-04-09	0.2467	ZAR	1
225	2024-04-10 06:30:01.979	2024-04-10 06:30:01.979	2024-04-10	1	RON	1
226	2024-04-10 06:30:01.994	2024-04-10 06:30:01.994	2024-04-10	1.2453	AED	1
227	2024-04-10 06:30:01.995	2024-04-10 06:30:01.995	2024-04-10	3.0275	AUD	1
228	2024-04-10 06:30:01.997	2024-04-10 06:30:01.997	2024-04-10	2.5402	BGN	1
229	2024-04-10 06:30:01.999	2024-04-10 06:30:01.999	2024-04-10	0.91	BRL	1
230	2024-04-10 06:30:02	2024-04-10 06:30:02	2024-04-10	3.3709	CAD	1
231	2024-04-10 06:30:02.002	2024-04-10 06:30:02.002	2024-04-10	5.0608	CHF	1
232	2024-04-10 06:30:02.003	2024-04-10 06:30:02.003	2024-04-10	0.6323	CNY	1
233	2024-04-10 06:30:02.004	2024-04-10 06:30:02.004	2024-04-10	0.1958	CZK	1
234	2024-04-10 06:30:02.005	2024-04-10 06:30:02.005	2024-04-10	0.6661	DKK	1
235	2024-04-10 06:30:02.006	2024-04-10 06:30:02.006	2024-04-10	0.0962	EGP	1
236	2024-04-10 06:30:02.008	2024-04-10 06:30:02.008	2024-04-10	4.9682	EUR	1
237	2024-04-10 06:30:02.009	2024-04-10 06:30:02.009	2024-04-10	5.7986	GBP	1
238	2024-04-10 06:30:02.01	2024-04-10 06:30:02.01	2024-04-10	1.2775	HUF	100
239	2024-04-10 06:30:02.01	2024-04-10 06:30:02.01	2024-04-10	0.0549	INR	1
240	2024-04-10 06:30:02.011	2024-04-10 06:30:02.011	2024-04-10	3.013	JPY	100
241	2024-04-10 06:30:02.012	2024-04-10 06:30:02.012	2024-04-10	0.3377	KRW	100
242	2024-04-10 06:30:02.013	2024-04-10 06:30:02.013	2024-04-10	0.2592	MDL	1
243	2024-04-10 06:30:02.014	2024-04-10 06:30:02.014	2024-04-10	0.2811	MXN	1
244	2024-04-10 06:30:02.014	2024-04-10 06:30:02.014	2024-04-10	0.4289	NOK	1
245	2024-04-10 06:30:02.015	2024-04-10 06:30:02.015	2024-04-10	2.767	NZD	1
246	2024-04-10 06:30:02.016	2024-04-10 06:30:02.016	2024-04-10	1.1666	PLN	1
247	2024-04-10 06:30:02.016	2024-04-10 06:30:02.016	2024-04-10	0.0424	RSD	1
248	2024-04-10 06:30:02.017	2024-04-10 06:30:02.017	2024-04-10	0.0492	RUB	1
249	2024-04-10 06:30:02.017	2024-04-10 06:30:02.017	2024-04-10	0.4341	SEK	1
250	2024-04-10 06:30:02.018	2024-04-10 06:30:02.018	2024-04-10	0.1258	THB	1
251	2024-04-10 06:30:02.018	2024-04-10 06:30:02.018	2024-04-10	0.1421	TRY	1
252	2024-04-10 06:30:02.019	2024-04-10 06:30:02.019	2024-04-10	0.1173	UAH	1
253	2024-04-10 06:30:02.02	2024-04-10 06:30:02.02	2024-04-10	4.5729	USD	1
254	2024-04-10 06:30:02.02	2024-04-10 06:30:02.02	2024-04-10	347.529	XAU	1
255	2024-04-10 06:30:02.021	2024-04-10 06:30:02.021	2024-04-10	6.07	XDR	1
256	2024-04-10 06:30:02.026	2024-04-10 06:30:02.026	2024-04-10	0.2476	ZAR	1
257	2024-04-11 06:30:02.266	2024-04-11 06:30:02.266	2024-04-11	1	RON	1
258	2024-04-11 06:30:02.289	2024-04-11 06:30:02.289	2024-04-11	1.2457	AED	1
259	2024-04-11 06:30:02.292	2024-04-11 06:30:02.292	2024-04-11	3.0306	AUD	1
260	2024-04-11 06:30:02.293	2024-04-11 06:30:02.293	2024-04-11	2.5407	BGN	1
261	2024-04-11 06:30:02.294	2024-04-11 06:30:02.294	2024-04-11	0.9133	BRL	1
262	2024-04-11 06:30:02.295	2024-04-11 06:30:02.295	2024-04-11	3.372	CAD	1
263	2024-04-11 06:30:02.297	2024-04-11 06:30:02.297	2024-04-11	5.0644	CHF	1
264	2024-04-11 06:30:02.299	2024-04-11 06:30:02.299	2024-04-11	0.6325	CNY	1
265	2024-04-11 06:30:02.3	2024-04-11 06:30:02.3	2024-04-11	0.196	CZK	1
266	2024-04-11 06:30:02.302	2024-04-11 06:30:02.302	2024-04-11	0.6662	DKK	1
267	2024-04-11 06:30:02.303	2024-04-11 06:30:02.303	2024-04-11	0.0962	EGP	1
268	2024-04-11 06:30:02.304	2024-04-11 06:30:02.304	2024-04-11	4.9692	EUR	1
269	2024-04-11 06:30:02.305	2024-04-11 06:30:02.305	2024-04-11	5.8075	GBP	1
270	2024-04-11 06:30:02.306	2024-04-11 06:30:02.306	2024-04-11	1.2752	HUF	100
271	2024-04-11 06:30:02.306	2024-04-11 06:30:02.306	2024-04-11	0.055	INR	1
272	2024-04-11 06:30:02.307	2024-04-11 06:30:02.307	2024-04-11	3.013	JPY	100
273	2024-04-11 06:30:02.308	2024-04-11 06:30:02.308	2024-04-11	0.3384	KRW	100
274	2024-04-11 06:30:02.309	2024-04-11 06:30:02.309	2024-04-11	0.2588	MDL	1
275	2024-04-11 06:30:02.31	2024-04-11 06:30:02.31	2024-04-11	0.2801	MXN	1
276	2024-04-11 06:30:02.311	2024-04-11 06:30:02.311	2024-04-11	0.4291	NOK	1
277	2024-04-11 06:30:02.312	2024-04-11 06:30:02.312	2024-04-11	2.779	NZD	1
278	2024-04-11 06:30:02.313	2024-04-11 06:30:02.313	2024-04-11	1.1663	PLN	1
279	2024-04-11 06:30:02.314	2024-04-11 06:30:02.314	2024-04-11	0.0424	RSD	1
280	2024-04-11 06:30:02.314	2024-04-11 06:30:02.314	2024-04-11	0.049	RUB	1
281	2024-04-11 06:30:02.315	2024-04-11 06:30:02.315	2024-04-11	0.4341	SEK	1
282	2024-04-11 06:30:02.316	2024-04-11 06:30:02.316	2024-04-11	0.1257	THB	1
283	2024-04-11 06:30:02.316	2024-04-11 06:30:02.316	2024-04-11	0.1418	TRY	1
284	2024-04-11 06:30:02.318	2024-04-11 06:30:02.318	2024-04-11	0.1172	UAH	1
285	2024-04-11 06:30:02.318	2024-04-11 06:30:02.318	2024-04-11	4.5748	USD	1
286	2024-04-11 06:30:02.319	2024-04-11 06:30:02.319	2024-04-11	345.4062	XAU	1
287	2024-04-11 06:30:02.32	2024-04-11 06:30:02.32	2024-04-11	6.0725	XDR	1
288	2024-04-11 06:30:02.32	2024-04-11 06:30:02.32	2024-04-11	0.2467	ZAR	1
289	2024-04-12 06:00:04.237	2024-04-12 06:00:04.237	2024-04-12	1	RON	1
290	2024-04-12 06:00:04.25	2024-04-12 06:00:04.25	2024-04-12	1.2614	AED	1
291	2024-04-12 06:00:04.253	2024-04-12 06:00:04.253	2024-04-12	3.0203	AUD	1
292	2024-04-12 06:00:04.254	2024-04-12 06:00:04.254	2024-04-12	2.5412	BGN	1
293	2024-04-12 06:00:04.257	2024-04-12 06:00:04.257	2024-04-12	0.9144	BRL	1
294	2024-04-12 06:00:04.258	2024-04-12 06:00:04.258	2024-04-12	3.3838	CAD	1
295	2024-04-12 06:00:04.259	2024-04-12 06:00:04.259	2024-04-12	5.0725	CHF	1
296	2024-04-12 06:00:04.26	2024-04-12 06:00:04.26	2024-04-12	0.64	CNY	1
297	2024-04-12 06:00:04.261	2024-04-12 06:00:04.261	2024-04-12	0.1958	CZK	1
298	2024-04-12 06:00:04.262	2024-04-12 06:00:04.262	2024-04-12	0.6662	DKK	1
299	2024-04-12 06:00:04.263	2024-04-12 06:00:04.263	2024-04-12	0.0974	EGP	1
300	2024-04-12 06:00:04.263	2024-04-12 06:00:04.263	2024-04-12	4.9703	EUR	1
301	2024-04-12 06:00:04.264	2024-04-12 06:00:04.264	2024-04-12	5.8071	GBP	1
302	2024-04-12 06:00:04.264	2024-04-12 06:00:04.264	2024-04-12	1.2733	HUF	100
303	2024-04-12 06:00:04.265	2024-04-12 06:00:04.265	2024-04-12	0.0556	INR	1
304	2024-04-12 06:00:04.266	2024-04-12 06:00:04.266	2024-04-12	3.0239	JPY	100
305	2024-04-12 06:00:04.266	2024-04-12 06:00:04.266	2024-04-12	0.3379	KRW	100
306	2024-04-12 06:00:04.267	2024-04-12 06:00:04.267	2024-04-12	0.2594	MDL	1
307	2024-04-12 06:00:04.268	2024-04-12 06:00:04.268	2024-04-12	0.2813	MXN	1
308	2024-04-12 06:00:04.268	2024-04-12 06:00:04.268	2024-04-12	0.4283	NOK	1
309	2024-04-12 06:00:04.269	2024-04-12 06:00:04.269	2024-04-12	2.7735	NZD	1
310	2024-04-12 06:00:04.27	2024-04-12 06:00:04.27	2024-04-12	1.1662	PLN	1
311	2024-04-12 06:00:04.27	2024-04-12 06:00:04.27	2024-04-12	0.0424	RSD	1
312	2024-04-12 06:00:04.271	2024-04-12 06:00:04.271	2024-04-12	0.0493	RUB	1
313	2024-04-12 06:00:04.272	2024-04-12 06:00:04.272	2024-04-12	0.4316	SEK	1
314	2024-04-12 06:00:04.272	2024-04-12 06:00:04.272	2024-04-12	0.1265	THB	1
315	2024-04-12 06:00:04.273	2024-04-12 06:00:04.273	2024-04-12	0.1435	TRY	1
316	2024-04-12 06:00:04.274	2024-04-12 06:00:04.274	2024-04-12	0.1182	UAH	1
317	2024-04-12 06:00:04.274	2024-04-12 06:00:04.274	2024-04-12	4.6322	USD	1
318	2024-04-12 06:00:04.275	2024-04-12 06:00:04.275	2024-04-12	347.0367	XAU	1
319	2024-04-12 06:00:04.275	2024-04-12 06:00:04.275	2024-04-12	6.1158	XDR	1
320	2024-04-12 06:00:04.276	2024-04-12 06:00:04.276	2024-04-12	0.2459	ZAR	1
321	2024-04-21 06:30:00.425	2024-04-21 06:30:00.425	2024-04-21	1	RON	1
322	2024-04-21 06:30:00.436	2024-04-21 06:30:00.436	2024-04-21	1.2712	AED	1
323	2024-04-21 06:30:00.438	2024-04-21 06:30:00.438	2024-04-21	2.9982	AUD	1
324	2024-04-21 06:30:00.439	2024-04-21 06:30:00.439	2024-04-21	2.5444	BGN	1
325	2024-04-21 06:30:00.44	2024-04-21 06:30:00.44	2024-04-21	0.8906	BRL	1
326	2024-04-21 06:30:00.442	2024-04-21 06:30:00.442	2024-04-21	3.3943	CAD	1
327	2024-04-21 06:30:00.443	2024-04-21 06:30:00.443	2024-04-21	5.1404	CHF	1
328	2024-04-21 06:30:00.445	2024-04-21 06:30:00.445	2024-04-21	0.6447	CNY	1
329	2024-04-21 06:30:00.446	2024-04-21 06:30:00.446	2024-04-21	0.197	CZK	1
330	2024-04-21 06:30:00.447	2024-04-21 06:30:00.447	2024-04-21	0.6669	DKK	1
331	2024-04-21 06:30:00.448	2024-04-21 06:30:00.448	2024-04-21	0.0966	EGP	1
332	2024-04-21 06:30:00.451	2024-04-21 06:30:00.451	2024-04-21	4.9764	EUR	1
333	2024-04-21 06:30:00.452	2024-04-21 06:30:00.452	2024-04-21	5.8125	GBP	1
334	2024-04-21 06:30:00.453	2024-04-21 06:30:00.453	2024-04-21	1.261	HUF	100
335	2024-04-21 06:30:00.454	2024-04-21 06:30:00.454	2024-04-21	0.0559	INR	1
336	2024-04-21 06:30:00.455	2024-04-21 06:30:00.455	2024-04-21	3.0228	JPY	100
337	2024-04-21 06:30:00.458	2024-04-21 06:30:00.458	2024-04-21	0.3383	KRW	100
338	2024-04-21 06:30:00.458	2024-04-21 06:30:00.458	2024-04-21	0.2591	MDL	1
339	2024-04-21 06:30:00.459	2024-04-21 06:30:00.459	2024-04-21	0.2704	MXN	1
340	2024-04-21 06:30:00.46	2024-04-21 06:30:00.46	2024-04-21	0.4231	NOK	1
341	2024-04-21 06:30:00.461	2024-04-21 06:30:00.461	2024-04-21	2.7527	NZD	1
342	2024-04-21 06:30:00.461	2024-04-21 06:30:00.461	2024-04-21	1.1514	PLN	1
343	2024-04-21 06:30:00.462	2024-04-21 06:30:00.462	2024-04-21	0.0425	RSD	1
344	2024-04-21 06:30:00.462	2024-04-21 06:30:00.462	2024-04-21	0.05	RUB	1
345	2024-04-21 06:30:00.463	2024-04-21 06:30:00.463	2024-04-21	0.4259	SEK	1
346	2024-04-21 06:30:00.463	2024-04-21 06:30:00.463	2024-04-21	0.1267	THB	1
347	2024-04-21 06:30:00.464	2024-04-21 06:30:00.464	2024-04-21	0.1438	TRY	1
348	2024-04-21 06:30:00.464	2024-04-21 06:30:00.464	2024-04-21	0.1172	UAH	1
349	2024-04-21 06:30:00.465	2024-04-21 06:30:00.465	2024-04-21	4.6687	USD	1
350	2024-04-21 06:30:00.465	2024-04-21 06:30:00.465	2024-04-21	357.7647	XAU	1
351	2024-04-21 06:30:00.466	2024-04-21 06:30:00.466	2024-04-21	6.1447	XDR	1
352	2024-04-21 06:30:00.466	2024-04-21 06:30:00.466	2024-04-21	0.2433	ZAR	1
353	2024-04-22 06:00:03.991	2024-04-22 06:00:03.991	2024-04-22	1	RON	1
354	2024-04-22 06:00:04.037	2024-04-22 06:00:04.037	2024-04-22	1.2712	AED	1
355	2024-04-22 06:00:04.038	2024-04-22 06:00:04.038	2024-04-22	2.9982	AUD	1
356	2024-04-22 06:00:04.04	2024-04-22 06:00:04.04	2024-04-22	2.5444	BGN	1
357	2024-04-22 06:00:04.041	2024-04-22 06:00:04.041	2024-04-22	0.8906	BRL	1
358	2024-04-22 06:00:04.043	2024-04-22 06:00:04.043	2024-04-22	3.3943	CAD	1
359	2024-04-22 06:00:04.045	2024-04-22 06:00:04.045	2024-04-22	5.1404	CHF	1
360	2024-04-22 06:00:04.046	2024-04-22 06:00:04.046	2024-04-22	0.6447	CNY	1
361	2024-04-22 06:00:04.048	2024-04-22 06:00:04.048	2024-04-22	0.197	CZK	1
362	2024-04-22 06:00:04.049	2024-04-22 06:00:04.049	2024-04-22	0.6669	DKK	1
363	2024-04-22 06:00:04.05	2024-04-22 06:00:04.05	2024-04-22	0.0966	EGP	1
364	2024-04-22 06:00:04.051	2024-04-22 06:00:04.051	2024-04-22	4.9764	EUR	1
365	2024-04-22 06:00:04.052	2024-04-22 06:00:04.052	2024-04-22	5.8125	GBP	1
366	2024-04-22 06:00:04.053	2024-04-22 06:00:04.053	2024-04-22	1.261	HUF	100
367	2024-04-22 06:00:04.054	2024-04-22 06:00:04.054	2024-04-22	0.0559	INR	1
368	2024-04-22 06:00:04.054	2024-04-22 06:00:04.054	2024-04-22	3.0228	JPY	100
369	2024-04-22 06:00:04.055	2024-04-22 06:00:04.055	2024-04-22	0.3383	KRW	100
370	2024-04-22 06:00:04.056	2024-04-22 06:00:04.056	2024-04-22	0.2591	MDL	1
371	2024-04-22 06:00:04.057	2024-04-22 06:00:04.057	2024-04-22	0.2704	MXN	1
372	2024-04-22 06:00:04.057	2024-04-22 06:00:04.057	2024-04-22	0.4231	NOK	1
373	2024-04-22 06:00:04.06	2024-04-22 06:00:04.06	2024-04-22	2.7527	NZD	1
374	2024-04-22 06:00:04.061	2024-04-22 06:00:04.061	2024-04-22	1.1514	PLN	1
375	2024-04-22 06:00:04.062	2024-04-22 06:00:04.062	2024-04-22	0.0425	RSD	1
376	2024-04-22 06:00:04.062	2024-04-22 06:00:04.062	2024-04-22	0.05	RUB	1
377	2024-04-22 06:00:04.063	2024-04-22 06:00:04.063	2024-04-22	0.4259	SEK	1
378	2024-04-22 06:00:04.063	2024-04-22 06:00:04.063	2024-04-22	0.1267	THB	1
379	2024-04-22 06:00:04.064	2024-04-22 06:00:04.064	2024-04-22	0.1438	TRY	1
380	2024-04-22 06:00:04.065	2024-04-22 06:00:04.065	2024-04-22	0.1172	UAH	1
381	2024-04-22 06:00:04.066	2024-04-22 06:00:04.066	2024-04-22	4.6687	USD	1
382	2024-04-22 06:00:04.066	2024-04-22 06:00:04.066	2024-04-22	357.7647	XAU	1
383	2024-04-22 06:00:04.067	2024-04-22 06:00:04.067	2024-04-22	6.1447	XDR	1
384	2024-04-22 06:00:04.068	2024-04-22 06:00:04.068	2024-04-22	0.2433	ZAR	1
385	2024-04-23 06:00:04.903	2024-04-23 06:00:04.903	2024-04-23	1	RON	1
386	2024-04-23 06:00:04.917	2024-04-23 06:00:04.917	2024-04-23	1.2719	AED	1
387	2024-04-23 06:00:04.92	2024-04-23 06:00:04.92	2024-04-23	3.0068	AUD	1
388	2024-04-23 06:00:04.922	2024-04-23 06:00:04.922	2024-04-23	2.5441	BGN	1
389	2024-04-23 06:00:04.922	2024-04-23 06:00:04.922	2024-04-23	0.897	BRL	1
390	2024-04-23 06:00:04.925	2024-04-23 06:00:04.925	2024-04-23	3.404	CAD	1
391	2024-04-23 06:00:04.926	2024-04-23 06:00:04.926	2024-04-23	5.1247	CHF	1
392	2024-04-23 06:00:04.927	2024-04-23 06:00:04.927	2024-04-23	0.6449	CNY	1
393	2024-04-23 06:00:04.928	2024-04-23 06:00:04.928	2024-04-23	0.1969	CZK	1
394	2024-04-23 06:00:04.929	2024-04-23 06:00:04.929	2024-04-23	0.6669	DKK	1
395	2024-04-23 06:00:04.93	2024-04-23 06:00:04.93	2024-04-23	0.0971	EGP	1
396	2024-04-23 06:00:04.93	2024-04-23 06:00:04.93	2024-04-23	4.9758	EUR	1
397	2024-04-23 06:00:04.931	2024-04-23 06:00:04.931	2024-04-23	5.7677	GBP	1
398	2024-04-23 06:00:04.931	2024-04-23 06:00:04.931	2024-04-23	1.2603	HUF	100
399	2024-04-23 06:00:04.932	2024-04-23 06:00:04.932	2024-04-23	0.056	INR	1
400	2024-04-23 06:00:04.933	2024-04-23 06:00:04.933	2024-04-23	3.0182	JPY	100
401	2024-04-23 06:00:04.934	2024-04-23 06:00:04.934	2024-04-23	0.3387	KRW	100
402	2024-04-23 06:00:04.935	2024-04-23 06:00:04.935	2024-04-23	0.2597	MDL	1
403	2024-04-23 06:00:04.936	2024-04-23 06:00:04.936	2024-04-23	0.274	MXN	1
404	2024-04-23 06:00:04.937	2024-04-23 06:00:04.937	2024-04-23	0.4241	NOK	1
405	2024-04-23 06:00:04.937	2024-04-23 06:00:04.937	2024-04-23	2.7592	NZD	1
406	2024-04-23 06:00:04.938	2024-04-23 06:00:04.938	2024-04-23	1.1519	PLN	1
407	2024-04-23 06:00:04.939	2024-04-23 06:00:04.939	2024-04-23	0.0425	RSD	1
408	2024-04-23 06:00:04.939	2024-04-23 06:00:04.939	2024-04-23	0.05	RUB	1
409	2024-04-23 06:00:04.94	2024-04-23 06:00:04.94	2024-04-23	0.4281	SEK	1
410	2024-04-23 06:00:04.941	2024-04-23 06:00:04.941	2024-04-23	0.1263	THB	1
411	2024-04-23 06:00:04.942	2024-04-23 06:00:04.942	2024-04-23	0.1433	TRY	1
412	2024-04-23 06:00:04.943	2024-04-23 06:00:04.943	2024-04-23	0.1174	UAH	1
413	2024-04-23 06:00:04.944	2024-04-23 06:00:04.944	2024-04-23	4.6712	USD	1
414	2024-04-23 06:00:04.945	2024-04-23 06:00:04.945	2024-04-23	354.4765	XAU	1
415	2024-04-23 06:00:04.945	2024-04-23 06:00:04.945	2024-04-23	6.1419	XDR	1
416	2024-04-23 06:00:04.946	2024-04-23 06:00:04.946	2024-04-23	0.2447	ZAR	1
417	2024-04-24 06:00:00.194	2024-04-24 06:00:00.194	2024-04-24	1	RON	1
418	2024-04-24 06:00:00.221	2024-04-24 06:00:00.221	2024-04-24	1.2715	AED	1
419	2024-04-24 06:00:00.224	2024-04-24 06:00:00.224	2024-04-24	3.0092	AUD	1
420	2024-04-24 06:00:00.225	2024-04-24 06:00:00.225	2024-04-24	2.5443	BGN	1
421	2024-04-24 06:00:00.226	2024-04-24 06:00:00.226	2024-04-24	0.9039	BRL	1
422	2024-04-24 06:00:00.227	2024-04-24 06:00:00.227	2024-04-24	3.4052	CAD	1
423	2024-04-24 06:00:00.228	2024-04-24 06:00:00.228	2024-04-24	5.1198	CHF	1
424	2024-04-24 06:00:00.229	2024-04-24 06:00:00.229	2024-04-24	0.6444	CNY	1
425	2024-04-24 06:00:00.231	2024-04-24 06:00:00.231	2024-04-24	0.1969	CZK	1
426	2024-04-24 06:00:00.232	2024-04-24 06:00:00.232	2024-04-24	0.667	DKK	1
427	2024-04-24 06:00:00.232	2024-04-24 06:00:00.232	2024-04-24	0.0971	EGP	1
428	2024-04-24 06:00:00.233	2024-04-24 06:00:00.233	2024-04-24	4.9762	EUR	1
429	2024-04-24 06:00:00.234	2024-04-24 06:00:00.234	2024-04-24	5.7698	GBP	1
430	2024-04-24 06:00:00.235	2024-04-24 06:00:00.235	2024-04-24	1.2629	HUF	100
431	2024-04-24 06:00:00.236	2024-04-24 06:00:00.236	2024-04-24	0.056	INR	1
432	2024-04-24 06:00:00.237	2024-04-24 06:00:00.237	2024-04-24	3.016	JPY	100
433	2024-04-24 06:00:00.239	2024-04-24 06:00:00.239	2024-04-24	0.3388	KRW	100
434	2024-04-24 06:00:00.24	2024-04-24 06:00:00.24	2024-04-24	0.26	MDL	1
435	2024-04-24 06:00:00.241	2024-04-24 06:00:00.241	2024-04-24	0.2728	MXN	1
436	2024-04-24 06:00:00.241	2024-04-24 06:00:00.241	2024-04-24	0.4241	NOK	1
437	2024-04-24 06:00:00.242	2024-04-24 06:00:00.242	2024-04-24	2.7564	NZD	1
438	2024-04-24 06:00:00.243	2024-04-24 06:00:00.243	2024-04-24	1.1508	PLN	1
439	2024-04-24 06:00:00.244	2024-04-24 06:00:00.244	2024-04-24	0.0425	RSD	1
440	2024-04-24 06:00:00.244	2024-04-24 06:00:00.244	2024-04-24	0.05	RUB	1
441	2024-04-24 06:00:00.245	2024-04-24 06:00:00.245	2024-04-24	0.4286	SEK	1
442	2024-04-24 06:00:00.246	2024-04-24 06:00:00.246	2024-04-24	0.126	THB	1
443	2024-04-24 06:00:00.246	2024-04-24 06:00:00.246	2024-04-24	0.1435	TRY	1
444	2024-04-24 06:00:00.247	2024-04-24 06:00:00.247	2024-04-24	0.118	UAH	1
445	2024-04-24 06:00:00.247	2024-04-24 06:00:00.247	2024-04-24	4.6699	USD	1
446	2024-04-24 06:00:00.248	2024-04-24 06:00:00.248	2024-04-24	344.5697	XAU	1
447	2024-04-24 06:00:00.249	2024-04-24 06:00:00.249	2024-04-24	6.1406	XDR	1
448	2024-04-24 06:00:00.25	2024-04-24 06:00:00.25	2024-04-24	0.2425	ZAR	1
449	2024-04-26 06:00:00.483	2024-04-26 06:00:00.483	2024-04-26	1	RON	1
450	2024-04-26 06:00:00.509	2024-04-26 06:00:00.509	2024-04-26	1.2629	AED	1
451	2024-04-26 06:00:00.512	2024-04-26 06:00:00.512	2024-04-26	3.0283	AUD	1
452	2024-04-26 06:00:00.513	2024-04-26 06:00:00.513	2024-04-26	2.5444	BGN	1
453	2024-04-26 06:00:00.514	2024-04-26 06:00:00.514	2024-04-26	0.9012	BRL	1
454	2024-04-26 06:00:00.515	2024-04-26 06:00:00.515	2024-04-26	3.392	CAD	1
455	2024-04-26 06:00:00.516	2024-04-26 06:00:00.516	2024-04-26	5.0843	CHF	1
456	2024-04-26 06:00:00.517	2024-04-26 06:00:00.517	2024-04-26	0.6401	CNY	1
457	2024-04-26 06:00:00.518	2024-04-26 06:00:00.518	2024-04-26	0.1974	CZK	1
458	2024-04-26 06:00:00.519	2024-04-26 06:00:00.519	2024-04-26	0.6672	DKK	1
459	2024-04-26 06:00:00.52	2024-04-26 06:00:00.52	2024-04-26	0.0968	EGP	1
460	2024-04-26 06:00:00.52	2024-04-26 06:00:00.52	2024-04-26	4.9763	EUR	1
461	2024-04-26 06:00:00.522	2024-04-26 06:00:00.522	2024-04-26	5.8067	GBP	1
462	2024-04-26 06:00:00.523	2024-04-26 06:00:00.523	2024-04-26	1.2671	HUF	100
463	2024-04-26 06:00:00.523	2024-04-26 06:00:00.523	2024-04-26	0.0557	INR	1
464	2024-04-26 06:00:00.524	2024-04-26 06:00:00.524	2024-04-26	2.9797	JPY	100
465	2024-04-26 06:00:00.525	2024-04-26 06:00:00.525	2024-04-26	0.3376	KRW	100
466	2024-04-26 06:00:00.525	2024-04-26 06:00:00.525	2024-04-26	0.2601	MDL	1
467	2024-04-26 06:00:00.527	2024-04-26 06:00:00.527	2024-04-26	0.2723	MXN	1
468	2024-04-26 06:00:00.527	2024-04-26 06:00:00.527	2024-04-26	0.4234	NOK	1
469	2024-04-26 06:00:00.528	2024-04-26 06:00:00.528	2024-04-26	2.765	NZD	1
470	2024-04-26 06:00:00.529	2024-04-26 06:00:00.529	2024-04-26	1.1532	PLN	1
471	2024-04-26 06:00:00.53	2024-04-26 06:00:00.53	2024-04-26	0.0425	RSD	1
472	2024-04-26 06:00:00.531	2024-04-26 06:00:00.531	2024-04-26	0.0503	RUB	1
473	2024-04-26 06:00:00.532	2024-04-26 06:00:00.532	2024-04-26	0.4274	SEK	1
474	2024-04-26 06:00:00.533	2024-04-26 06:00:00.533	2024-04-26	0.1254	THB	1
475	2024-04-26 06:00:00.533	2024-04-26 06:00:00.533	2024-04-26	0.143	TRY	1
476	2024-04-26 06:00:00.534	2024-04-26 06:00:00.534	2024-04-26	0.117	UAH	1
477	2024-04-26 06:00:00.535	2024-04-26 06:00:00.535	2024-04-26	4.6386	USD	1
478	2024-04-26 06:00:00.536	2024-04-26 06:00:00.536	2024-04-26	346.8933	XAU	1
479	2024-04-26 06:00:00.537	2024-04-26 06:00:00.537	2024-04-26	6.1159	XDR	1
480	2024-04-26 06:00:00.537	2024-04-26 06:00:00.537	2024-04-26	0.2442	ZAR	1
481	2024-04-29 06:00:00.332	2024-04-29 06:00:00.332	2024-04-29	1	RON	1
482	2024-04-29 06:00:00.346	2024-04-29 06:00:00.346	2024-04-29	1.2626	AED	1
483	2024-04-29 06:00:00.349	2024-04-29 06:00:00.349	2024-04-29	3.032	AUD	1
484	2024-04-29 06:00:00.35	2024-04-29 06:00:00.35	2024-04-29	2.5444	BGN	1
485	2024-04-29 06:00:00.351	2024-04-29 06:00:00.351	2024-04-29	0.8988	BRL	1
486	2024-04-29 06:00:00.352	2024-04-29 06:00:00.352	2024-04-29	3.3966	CAD	1
487	2024-04-29 06:00:00.357	2024-04-29 06:00:00.357	2024-04-29	5.0832	CHF	1
488	2024-04-29 06:00:00.358	2024-04-29 06:00:00.358	2024-04-29	0.6399	CNY	1
489	2024-04-29 06:00:00.359	2024-04-29 06:00:00.359	2024-04-29	0.1978	CZK	1
490	2024-04-29 06:00:00.361	2024-04-29 06:00:00.361	2024-04-29	0.6673	DKK	1
491	2024-04-29 06:00:00.362	2024-04-29 06:00:00.362	2024-04-29	0.0968	EGP	1
492	2024-04-29 06:00:00.363	2024-04-29 06:00:00.363	2024-04-29	4.9765	EUR	1
493	2024-04-29 06:00:00.365	2024-04-29 06:00:00.365	2024-04-29	5.8018	GBP	1
494	2024-04-29 06:00:00.365	2024-04-29 06:00:00.365	2024-04-29	1.2662	HUF	100
495	2024-04-29 06:00:00.366	2024-04-29 06:00:00.366	2024-04-29	0.0556	INR	1
496	2024-04-29 06:00:00.367	2024-04-29 06:00:00.367	2024-04-29	2.9616	JPY	100
497	2024-04-29 06:00:00.368	2024-04-29 06:00:00.368	2024-04-29	0.3369	KRW	100
498	2024-04-29 06:00:00.369	2024-04-29 06:00:00.369	2024-04-29	0.2597	MDL	1
499	2024-04-29 06:00:00.37	2024-04-29 06:00:00.37	2024-04-29	0.2686	MXN	1
500	2024-04-29 06:00:00.371	2024-04-29 06:00:00.371	2024-04-29	0.422	NOK	1
501	2024-04-29 06:00:00.372	2024-04-29 06:00:00.372	2024-04-29	2.7605	NZD	1
502	2024-04-29 06:00:00.373	2024-04-29 06:00:00.373	2024-04-29	1.1498	PLN	1
503	2024-04-29 06:00:00.374	2024-04-29 06:00:00.374	2024-04-29	0.0425	RSD	1
504	2024-04-29 06:00:00.375	2024-04-29 06:00:00.375	2024-04-29	0.0504	RUB	1
505	2024-04-29 06:00:00.376	2024-04-29 06:00:00.376	2024-04-29	0.4261	SEK	1
506	2024-04-29 06:00:00.377	2024-04-29 06:00:00.377	2024-04-29	0.1255	THB	1
507	2024-04-29 06:00:00.378	2024-04-29 06:00:00.378	2024-04-29	0.1428	TRY	1
508	2024-04-29 06:00:00.378	2024-04-29 06:00:00.378	2024-04-29	0.1171	UAH	1
509	2024-04-29 06:00:00.379	2024-04-29 06:00:00.379	2024-04-29	4.6373	USD	1
510	2024-04-29 06:00:00.379	2024-04-29 06:00:00.379	2024-04-29	350.3208	XAU	1
511	2024-04-29 06:00:00.38	2024-04-29 06:00:00.38	2024-04-29	6.1121	XDR	1
512	2024-04-29 06:00:00.381	2024-04-29 06:00:00.381	2024-04-29	0.2442	ZAR	1
513	2024-04-30 06:00:03.205	2024-04-30 06:00:03.205	2024-04-30	1	RON	1
514	2024-04-30 06:00:03.212	2024-04-30 06:00:03.212	2024-04-30	1.2644	AED	1
515	2024-04-30 06:00:03.213	2024-04-30 06:00:03.213	2024-04-30	3.0481	AUD	1
516	2024-04-30 06:00:03.214	2024-04-30 06:00:03.214	2024-04-30	2.5441	BGN	1
517	2024-04-30 06:00:03.215	2024-04-30 06:00:03.215	2024-04-30	0.9075	BRL	1
518	2024-04-30 06:00:03.216	2024-04-30 06:00:03.216	2024-04-30	3.4013	CAD	1
519	2024-04-30 06:00:03.217	2024-04-30 06:00:03.217	2024-04-30	5.0948	CHF	1
520	2024-04-30 06:00:03.218	2024-04-30 06:00:03.218	2024-04-30	0.6411	CNY	1
521	2024-04-30 06:00:03.219	2024-04-30 06:00:03.219	2024-04-30	0.1976	CZK	1
522	2024-04-30 06:00:03.22	2024-04-30 06:00:03.22	2024-04-30	0.6671	DKK	1
523	2024-04-30 06:00:03.221	2024-04-30 06:00:03.221	2024-04-30	0.0975	EGP	1
524	2024-04-30 06:00:03.222	2024-04-30 06:00:03.222	2024-04-30	4.9758	EUR	1
525	2024-04-30 06:00:03.223	2024-04-30 06:00:03.223	2024-04-30	5.82	GBP	1
526	2024-04-30 06:00:03.223	2024-04-30 06:00:03.223	2024-04-30	1.269	HUF	100
527	2024-04-30 06:00:03.224	2024-04-30 06:00:03.224	2024-04-30	0.0556	INR	1
528	2024-04-30 06:00:03.225	2024-04-30 06:00:03.225	2024-04-30	2.9807	JPY	100
529	2024-04-30 06:00:03.226	2024-04-30 06:00:03.226	2024-04-30	0.3373	KRW	100
530	2024-04-30 06:00:03.227	2024-04-30 06:00:03.227	2024-04-30	0.2598	MDL	1
531	2024-04-30 06:00:03.228	2024-04-30 06:00:03.228	2024-04-30	0.2712	MXN	1
532	2024-04-30 06:00:03.228	2024-04-30 06:00:03.228	2024-04-30	0.4224	NOK	1
533	2024-04-30 06:00:03.229	2024-04-30 06:00:03.229	2024-04-30	2.7744	NZD	1
534	2024-04-30 06:00:03.23	2024-04-30 06:00:03.23	2024-04-30	1.151	PLN	1
535	2024-04-30 06:00:03.23	2024-04-30 06:00:03.23	2024-04-30	0.0425	RSD	1
536	2024-04-30 06:00:03.231	2024-04-30 06:00:03.231	2024-04-30	0.0498	RUB	1
537	2024-04-30 06:00:03.231	2024-04-30 06:00:03.231	2024-04-30	0.4255	SEK	1
538	2024-04-30 06:00:03.232	2024-04-30 06:00:03.232	2024-04-30	0.1254	THB	1
539	2024-04-30 06:00:03.233	2024-04-30 06:00:03.233	2024-04-30	0.1436	TRY	1
540	2024-04-30 06:00:03.233	2024-04-30 06:00:03.233	2024-04-30	0.117	UAH	1
541	2024-04-30 06:00:03.234	2024-04-30 06:00:03.234	2024-04-30	4.6438	USD	1
542	2024-04-30 06:00:03.234	2024-04-30 06:00:03.234	2024-04-30	349.8708	XAU	1
543	2024-04-30 06:00:03.235	2024-04-30 06:00:03.235	2024-04-30	6.1209	XDR	1
544	2024-04-30 06:00:03.236	2024-04-30 06:00:03.236	2024-04-30	0.2476	ZAR	1
545	2024-05-02 06:00:08.552	2024-05-02 06:00:08.552	2024-05-02	1	RON	1
546	2024-05-02 06:00:08.559	2024-05-02 06:00:08.559	2024-05-02	1.2622	AED	1
547	2024-05-02 06:00:08.561	2024-05-02 06:00:08.561	2024-05-02	3.0287	AUD	1
548	2024-05-02 06:00:08.562	2024-05-02 06:00:08.562	2024-05-02	2.5441	BGN	1
549	2024-05-02 06:00:08.563	2024-05-02 06:00:08.563	2024-05-02	0.9058	BRL	1
550	2024-05-02 06:00:08.563	2024-05-02 06:00:08.563	2024-05-02	3.3885	CAD	1
551	2024-05-02 06:00:08.564	2024-05-02 06:00:08.564	2024-05-02	5.0891	CHF	1
552	2024-05-02 06:00:08.565	2024-05-02 06:00:08.565	2024-05-02	0.6404	CNY	1
553	2024-05-02 06:00:08.565	2024-05-02 06:00:08.565	2024-05-02	0.1977	CZK	1
554	2024-05-02 06:00:08.566	2024-05-02 06:00:08.566	2024-05-02	0.6672	DKK	1
555	2024-05-02 06:00:08.567	2024-05-02 06:00:08.567	2024-05-02	0.0968	EGP	1
556	2024-05-02 06:00:08.567	2024-05-02 06:00:08.567	2024-05-02	4.9759	EUR	1
557	2024-05-02 06:00:08.568	2024-05-02 06:00:08.568	2024-05-02	5.8194	GBP	1
558	2024-05-02 06:00:08.568	2024-05-02 06:00:08.568	2024-05-02	1.2736	HUF	100
559	2024-05-02 06:00:08.569	2024-05-02 06:00:08.569	2024-05-02	0.0556	INR	1
560	2024-05-02 06:00:08.57	2024-05-02 06:00:08.57	2024-05-02	2.9563	JPY	100
561	2024-05-02 06:00:08.57	2024-05-02 06:00:08.57	2024-05-02	0.3359	KRW	100
562	2024-05-02 06:00:08.571	2024-05-02 06:00:08.571	2024-05-02	0.2606	MDL	1
563	2024-05-02 06:00:08.572	2024-05-02 06:00:08.572	2024-05-02	0.2729	MXN	1
564	2024-05-02 06:00:08.572	2024-05-02 06:00:08.572	2024-05-02	0.4212	NOK	1
565	2024-05-02 06:00:08.573	2024-05-02 06:00:08.573	2024-05-02	2.7588	NZD	1
566	2024-05-02 06:00:08.573	2024-05-02 06:00:08.573	2024-05-02	1.1508	PLN	1
567	2024-05-02 06:00:08.574	2024-05-02 06:00:08.574	2024-05-02	0.0425	RSD	1
568	2024-05-02 06:00:08.575	2024-05-02 06:00:08.575	2024-05-02	0.0496	RUB	1
569	2024-05-02 06:00:08.575	2024-05-02 06:00:08.575	2024-05-02	0.423	SEK	1
570	2024-05-02 06:00:08.576	2024-05-02 06:00:08.576	2024-05-02	0.1251	THB	1
571	2024-05-02 06:00:08.576	2024-05-02 06:00:08.576	2024-05-02	0.1434	TRY	1
572	2024-05-02 06:00:08.577	2024-05-02 06:00:08.577	2024-05-02	0.1174	UAH	1
573	2024-05-02 06:00:08.578	2024-05-02 06:00:08.578	2024-05-02	4.6361	USD	1
574	2024-05-02 06:00:08.578	2024-05-02 06:00:08.578	2024-05-02	345.2064	XAU	1
575	2024-05-02 06:00:08.579	2024-05-02 06:00:08.579	2024-05-02	6.1122	XDR	1
576	2024-05-02 06:00:08.579	2024-05-02 06:00:08.579	2024-05-02	0.2481	ZAR	1
577	2024-05-03 08:00:00.976	2024-05-03 08:00:00.976	2024-05-03	1	RON	1
578	2024-05-03 08:00:00.979	2024-05-03 08:00:00.979	2024-05-03	1.266	AED	1
579	2024-05-03 08:00:00.98	2024-05-03 08:00:00.98	2024-05-03	3.0368	AUD	1
580	2024-05-03 08:00:00.981	2024-05-03 08:00:00.981	2024-05-03	2.5444	BGN	1
581	2024-05-03 08:00:00.982	2024-05-03 08:00:00.982	2024-05-03	0.8953	BRL	1
582	2024-05-03 08:00:00.983	2024-05-03 08:00:00.983	2024-05-03	3.3893	CAD	1
583	2024-05-03 08:00:00.984	2024-05-03 08:00:00.984	2024-05-03	5.0964	CHF	1
584	2024-05-03 08:00:00.986	2024-05-03 08:00:00.986	2024-05-03	0.6422	CNY	1
585	2024-05-03 08:00:00.986	2024-05-03 08:00:00.986	2024-05-03	0.198	CZK	1
586	2024-05-03 08:00:00.987	2024-05-03 08:00:00.987	2024-05-03	0.6671	DKK	1
587	2024-05-03 08:00:00.988	2024-05-03 08:00:00.988	2024-05-03	0.0968	EGP	1
588	2024-05-03 08:00:00.989	2024-05-03 08:00:00.989	2024-05-03	4.9764	EUR	1
589	2024-05-03 08:00:00.99	2024-05-03 08:00:00.99	2024-05-03	5.818	GBP	1
590	2024-05-03 08:00:00.991	2024-05-03 08:00:00.991	2024-05-03	1.2774	HUF	100
591	2024-05-03 08:00:00.992	2024-05-03 08:00:00.992	2024-05-03	0.0557	INR	1
592	2024-05-03 08:00:00.993	2024-05-03 08:00:00.993	2024-05-03	2.9944	JPY	100
593	2024-05-03 08:00:00.994	2024-05-03 08:00:00.994	2024-05-03	0.338	KRW	100
594	2024-05-03 08:00:00.994	2024-05-03 08:00:00.994	2024-05-03	0.2617	MDL	1
595	2024-05-03 08:00:00.995	2024-05-03 08:00:00.995	2024-05-03	0.2743	MXN	1
596	2024-05-03 08:00:00.995	2024-05-03 08:00:00.995	2024-05-03	0.4198	NOK	1
597	2024-05-03 08:00:00.996	2024-05-03 08:00:00.996	2024-05-03	2.7572	NZD	1
598	2024-05-03 08:00:00.997	2024-05-03 08:00:00.997	2024-05-03	1.1482	PLN	1
599	2024-05-03 08:00:00.998	2024-05-03 08:00:00.998	2024-05-03	0.0425	RSD	1
600	2024-05-03 08:00:00.999	2024-05-03 08:00:00.999	2024-05-03	0.0504	RUB	1
601	2024-05-03 08:00:01	2024-05-03 08:00:01	2024-05-03	0.4254	SEK	1
602	2024-05-03 08:00:01.001	2024-05-03 08:00:01.001	2024-05-03	0.1259	THB	1
603	2024-05-03 08:00:01.002	2024-05-03 08:00:01.002	2024-05-03	0.1436	TRY	1
604	2024-05-03 08:00:01.002	2024-05-03 08:00:01.002	2024-05-03	0.1175	UAH	1
605	2024-05-03 08:00:01.003	2024-05-03 08:00:01.003	2024-05-03	4.65	USD	1
606	2024-05-03 08:00:01.004	2024-05-03 08:00:01.004	2024-05-03	344.1075	XAU	1
607	2024-05-03 08:00:01.005	2024-05-03 08:00:01.005	2024-05-03	6.1277	XDR	1
608	2024-05-03 08:00:01.006	2024-05-03 08:00:01.006	2024-05-03	0.2497	ZAR	1
609	2024-05-04 07:00:02.312	2024-05-04 07:00:02.312	2024-05-04	1	RON	1
610	2024-05-04 07:00:02.319	2024-05-04 07:00:02.319	2024-05-04	1.266	AED	1
611	2024-05-04 07:00:02.321	2024-05-04 07:00:02.321	2024-05-04	3.0368	AUD	1
612	2024-05-04 07:00:02.321	2024-05-04 07:00:02.321	2024-05-04	2.5444	BGN	1
613	2024-05-04 07:00:02.322	2024-05-04 07:00:02.322	2024-05-04	0.8953	BRL	1
614	2024-05-04 07:00:02.324	2024-05-04 07:00:02.324	2024-05-04	3.3893	CAD	1
615	2024-05-04 07:00:02.325	2024-05-04 07:00:02.325	2024-05-04	5.0964	CHF	1
616	2024-05-04 07:00:02.326	2024-05-04 07:00:02.326	2024-05-04	0.6422	CNY	1
617	2024-05-04 07:00:02.327	2024-05-04 07:00:02.327	2024-05-04	0.198	CZK	1
618	2024-05-04 07:00:02.327	2024-05-04 07:00:02.327	2024-05-04	0.6671	DKK	1
619	2024-05-04 07:00:02.33	2024-05-04 07:00:02.33	2024-05-04	0.0968	EGP	1
620	2024-05-04 07:00:02.331	2024-05-04 07:00:02.331	2024-05-04	4.9764	EUR	1
621	2024-05-04 07:00:02.332	2024-05-04 07:00:02.332	2024-05-04	5.818	GBP	1
622	2024-05-04 07:00:02.333	2024-05-04 07:00:02.333	2024-05-04	1.2774	HUF	100
623	2024-05-04 07:00:02.333	2024-05-04 07:00:02.333	2024-05-04	0.0557	INR	1
624	2024-05-04 07:00:02.334	2024-05-04 07:00:02.334	2024-05-04	2.9944	JPY	100
625	2024-05-04 07:00:02.334	2024-05-04 07:00:02.334	2024-05-04	0.338	KRW	100
626	2024-05-04 07:00:02.335	2024-05-04 07:00:02.335	2024-05-04	0.2617	MDL	1
627	2024-05-04 07:00:02.335	2024-05-04 07:00:02.335	2024-05-04	0.2743	MXN	1
628	2024-05-04 07:00:02.336	2024-05-04 07:00:02.336	2024-05-04	0.4198	NOK	1
629	2024-05-04 07:00:02.337	2024-05-04 07:00:02.337	2024-05-04	2.7572	NZD	1
630	2024-05-04 07:00:02.337	2024-05-04 07:00:02.337	2024-05-04	1.1482	PLN	1
631	2024-05-04 07:00:02.338	2024-05-04 07:00:02.338	2024-05-04	0.0425	RSD	1
632	2024-05-04 07:00:02.338	2024-05-04 07:00:02.338	2024-05-04	0.0504	RUB	1
633	2024-05-04 07:00:02.339	2024-05-04 07:00:02.339	2024-05-04	0.4254	SEK	1
634	2024-05-04 07:00:02.34	2024-05-04 07:00:02.34	2024-05-04	0.1259	THB	1
635	2024-05-04 07:00:02.341	2024-05-04 07:00:02.341	2024-05-04	0.1436	TRY	1
636	2024-05-04 07:00:02.342	2024-05-04 07:00:02.342	2024-05-04	0.1175	UAH	1
637	2024-05-04 07:00:02.343	2024-05-04 07:00:02.343	2024-05-04	4.65	USD	1
638	2024-05-04 07:00:02.343	2024-05-04 07:00:02.343	2024-05-04	344.1075	XAU	1
639	2024-05-04 07:00:02.344	2024-05-04 07:00:02.344	2024-05-04	6.1277	XDR	1
640	2024-05-04 07:00:02.347	2024-05-04 07:00:02.347	2024-05-04	0.2497	ZAR	1
641	2024-05-05 06:00:04.546	2024-05-05 06:00:04.546	2024-05-05	1	RON	1
642	2024-05-05 06:00:04.582	2024-05-05 06:00:04.582	2024-05-05	1.266	AED	1
643	2024-05-05 06:00:04.584	2024-05-05 06:00:04.584	2024-05-05	3.0368	AUD	1
644	2024-05-05 06:00:04.585	2024-05-05 06:00:04.585	2024-05-05	2.5444	BGN	1
645	2024-05-05 06:00:04.586	2024-05-05 06:00:04.586	2024-05-05	0.8953	BRL	1
646	2024-05-05 06:00:04.587	2024-05-05 06:00:04.587	2024-05-05	3.3893	CAD	1
647	2024-05-05 06:00:04.59	2024-05-05 06:00:04.59	2024-05-05	5.0964	CHF	1
648	2024-05-05 06:00:04.591	2024-05-05 06:00:04.591	2024-05-05	0.6422	CNY	1
649	2024-05-05 06:00:04.592	2024-05-05 06:00:04.592	2024-05-05	0.198	CZK	1
650	2024-05-05 06:00:04.593	2024-05-05 06:00:04.593	2024-05-05	0.6671	DKK	1
651	2024-05-05 06:00:04.594	2024-05-05 06:00:04.594	2024-05-05	0.0968	EGP	1
652	2024-05-05 06:00:04.595	2024-05-05 06:00:04.595	2024-05-05	4.9764	EUR	1
653	2024-05-05 06:00:04.596	2024-05-05 06:00:04.596	2024-05-05	5.818	GBP	1
654	2024-05-05 06:00:04.597	2024-05-05 06:00:04.597	2024-05-05	1.2774	HUF	100
655	2024-05-05 06:00:04.598	2024-05-05 06:00:04.598	2024-05-05	0.0557	INR	1
656	2024-05-05 06:00:04.599	2024-05-05 06:00:04.599	2024-05-05	2.9944	JPY	100
657	2024-05-05 06:00:04.6	2024-05-05 06:00:04.6	2024-05-05	0.338	KRW	100
658	2024-05-05 06:00:04.601	2024-05-05 06:00:04.601	2024-05-05	0.2617	MDL	1
659	2024-05-05 06:00:04.602	2024-05-05 06:00:04.602	2024-05-05	0.2743	MXN	1
660	2024-05-05 06:00:04.603	2024-05-05 06:00:04.603	2024-05-05	0.4198	NOK	1
661	2024-05-05 06:00:04.604	2024-05-05 06:00:04.604	2024-05-05	2.7572	NZD	1
662	2024-05-05 06:00:04.604	2024-05-05 06:00:04.604	2024-05-05	1.1482	PLN	1
663	2024-05-05 06:00:04.605	2024-05-05 06:00:04.605	2024-05-05	0.0425	RSD	1
664	2024-05-05 06:00:04.605	2024-05-05 06:00:04.605	2024-05-05	0.0504	RUB	1
665	2024-05-05 06:00:04.606	2024-05-05 06:00:04.606	2024-05-05	0.4254	SEK	1
666	2024-05-05 06:00:04.607	2024-05-05 06:00:04.607	2024-05-05	0.1259	THB	1
667	2024-05-05 06:00:04.607	2024-05-05 06:00:04.607	2024-05-05	0.1436	TRY	1
668	2024-05-05 06:00:04.608	2024-05-05 06:00:04.608	2024-05-05	0.1175	UAH	1
669	2024-05-05 06:00:04.608	2024-05-05 06:00:04.608	2024-05-05	4.65	USD	1
670	2024-05-05 06:00:04.609	2024-05-05 06:00:04.609	2024-05-05	344.1075	XAU	1
671	2024-05-05 06:00:04.609	2024-05-05 06:00:04.609	2024-05-05	6.1277	XDR	1
672	2024-05-05 06:00:04.61	2024-05-05 06:00:04.61	2024-05-05	0.2497	ZAR	1
673	2024-05-06 06:00:00.348	2024-05-06 06:00:00.348	2024-05-06	1	RON	1
674	2024-05-06 06:00:00.375	2024-05-06 06:00:00.375	2024-05-06	1.266	AED	1
675	2024-05-06 06:00:00.377	2024-05-06 06:00:00.377	2024-05-06	3.0368	AUD	1
676	2024-05-06 06:00:00.377	2024-05-06 06:00:00.377	2024-05-06	2.5444	BGN	1
677	2024-05-06 06:00:00.378	2024-05-06 06:00:00.378	2024-05-06	0.8953	BRL	1
678	2024-05-06 06:00:00.379	2024-05-06 06:00:00.379	2024-05-06	3.3893	CAD	1
679	2024-05-06 06:00:00.38	2024-05-06 06:00:00.38	2024-05-06	5.0964	CHF	1
680	2024-05-06 06:00:00.38	2024-05-06 06:00:00.38	2024-05-06	0.6422	CNY	1
681	2024-05-06 06:00:00.382	2024-05-06 06:00:00.382	2024-05-06	0.198	CZK	1
682	2024-05-06 06:00:00.382	2024-05-06 06:00:00.382	2024-05-06	0.6671	DKK	1
683	2024-05-06 06:00:00.383	2024-05-06 06:00:00.383	2024-05-06	0.0968	EGP	1
684	2024-05-06 06:00:00.383	2024-05-06 06:00:00.383	2024-05-06	4.9764	EUR	1
685	2024-05-06 06:00:00.385	2024-05-06 06:00:00.385	2024-05-06	5.818	GBP	1
686	2024-05-06 06:00:00.386	2024-05-06 06:00:00.386	2024-05-06	1.2774	HUF	100
687	2024-05-06 06:00:00.387	2024-05-06 06:00:00.387	2024-05-06	0.0557	INR	1
688	2024-05-06 06:00:00.387	2024-05-06 06:00:00.387	2024-05-06	2.9944	JPY	100
689	2024-05-06 06:00:00.388	2024-05-06 06:00:00.388	2024-05-06	0.338	KRW	100
690	2024-05-06 06:00:00.388	2024-05-06 06:00:00.388	2024-05-06	0.2617	MDL	1
691	2024-05-06 06:00:00.389	2024-05-06 06:00:00.389	2024-05-06	0.2743	MXN	1
692	2024-05-06 06:00:00.389	2024-05-06 06:00:00.389	2024-05-06	0.4198	NOK	1
693	2024-05-06 06:00:00.39	2024-05-06 06:00:00.39	2024-05-06	2.7572	NZD	1
694	2024-05-06 06:00:00.391	2024-05-06 06:00:00.391	2024-05-06	1.1482	PLN	1
695	2024-05-06 06:00:00.392	2024-05-06 06:00:00.392	2024-05-06	0.0425	RSD	1
696	2024-05-06 06:00:00.392	2024-05-06 06:00:00.392	2024-05-06	0.0504	RUB	1
697	2024-05-06 06:00:00.393	2024-05-06 06:00:00.393	2024-05-06	0.4254	SEK	1
698	2024-05-06 06:00:00.394	2024-05-06 06:00:00.394	2024-05-06	0.1259	THB	1
699	2024-05-06 06:00:00.395	2024-05-06 06:00:00.395	2024-05-06	0.1436	TRY	1
700	2024-05-06 06:00:00.395	2024-05-06 06:00:00.395	2024-05-06	0.1175	UAH	1
701	2024-05-06 06:00:00.396	2024-05-06 06:00:00.396	2024-05-06	4.65	USD	1
702	2024-05-06 06:00:00.397	2024-05-06 06:00:00.397	2024-05-06	344.1075	XAU	1
703	2024-05-06 06:00:00.397	2024-05-06 06:00:00.397	2024-05-06	6.1277	XDR	1
704	2024-05-06 06:00:00.398	2024-05-06 06:00:00.398	2024-05-06	0.2497	ZAR	1
705	2024-05-07 06:00:00.395	2024-05-07 06:00:00.395	2024-05-07	1	RON	1
706	2024-05-07 06:00:00.403	2024-05-07 06:00:00.403	2024-05-07	1.266	AED	1
707	2024-05-07 06:00:00.405	2024-05-07 06:00:00.405	2024-05-07	3.0368	AUD	1
708	2024-05-07 06:00:00.406	2024-05-07 06:00:00.406	2024-05-07	2.5444	BGN	1
709	2024-05-07 06:00:00.406	2024-05-07 06:00:00.406	2024-05-07	0.8953	BRL	1
710	2024-05-07 06:00:00.407	2024-05-07 06:00:00.407	2024-05-07	3.3893	CAD	1
711	2024-05-07 06:00:00.408	2024-05-07 06:00:00.408	2024-05-07	5.0964	CHF	1
712	2024-05-07 06:00:00.409	2024-05-07 06:00:00.409	2024-05-07	0.6422	CNY	1
713	2024-05-07 06:00:00.41	2024-05-07 06:00:00.41	2024-05-07	0.198	CZK	1
714	2024-05-07 06:00:00.41	2024-05-07 06:00:00.41	2024-05-07	0.6671	DKK	1
715	2024-05-07 06:00:00.411	2024-05-07 06:00:00.411	2024-05-07	0.0968	EGP	1
716	2024-05-07 06:00:00.411	2024-05-07 06:00:00.411	2024-05-07	4.9764	EUR	1
717	2024-05-07 06:00:00.412	2024-05-07 06:00:00.412	2024-05-07	5.818	GBP	1
718	2024-05-07 06:00:00.413	2024-05-07 06:00:00.413	2024-05-07	1.2774	HUF	100
719	2024-05-07 06:00:00.413	2024-05-07 06:00:00.413	2024-05-07	0.0557	INR	1
720	2024-05-07 06:00:00.414	2024-05-07 06:00:00.414	2024-05-07	2.9944	JPY	100
721	2024-05-07 06:00:00.414	2024-05-07 06:00:00.414	2024-05-07	0.338	KRW	100
722	2024-05-07 06:00:00.415	2024-05-07 06:00:00.415	2024-05-07	0.2617	MDL	1
723	2024-05-07 06:00:00.416	2024-05-07 06:00:00.416	2024-05-07	0.2743	MXN	1
724	2024-05-07 06:00:00.416	2024-05-07 06:00:00.416	2024-05-07	0.4198	NOK	1
725	2024-05-07 06:00:00.417	2024-05-07 06:00:00.417	2024-05-07	2.7572	NZD	1
726	2024-05-07 06:00:00.418	2024-05-07 06:00:00.418	2024-05-07	1.1482	PLN	1
727	2024-05-07 06:00:00.418	2024-05-07 06:00:00.418	2024-05-07	0.0425	RSD	1
728	2024-05-07 06:00:00.419	2024-05-07 06:00:00.419	2024-05-07	0.0504	RUB	1
729	2024-05-07 06:00:00.419	2024-05-07 06:00:00.419	2024-05-07	0.4254	SEK	1
730	2024-05-07 06:00:00.42	2024-05-07 06:00:00.42	2024-05-07	0.1259	THB	1
731	2024-05-07 06:00:00.42	2024-05-07 06:00:00.42	2024-05-07	0.1436	TRY	1
732	2024-05-07 06:00:00.421	2024-05-07 06:00:00.421	2024-05-07	0.1175	UAH	1
733	2024-05-07 06:00:00.421	2024-05-07 06:00:00.421	2024-05-07	4.65	USD	1
734	2024-05-07 06:00:00.422	2024-05-07 06:00:00.422	2024-05-07	344.1075	XAU	1
735	2024-05-07 06:00:00.423	2024-05-07 06:00:00.423	2024-05-07	6.1277	XDR	1
736	2024-05-07 06:00:00.423	2024-05-07 06:00:00.423	2024-05-07	0.2497	ZAR	1
737	2024-05-08 06:00:01.98	2024-05-08 06:00:01.98	2024-05-08	1	RON	1
738	2024-05-08 06:00:01.99	2024-05-08 06:00:01.99	2024-05-08	1.2593	AED	1
739	2024-05-08 06:00:01.992	2024-05-08 06:00:01.992	2024-05-08	3.0498	AUD	1
740	2024-05-08 06:00:01.993	2024-05-08 06:00:01.993	2024-05-08	2.544	BGN	1
741	2024-05-08 06:00:01.993	2024-05-08 06:00:01.993	2024-05-08	0.9112	BRL	1
742	2024-05-08 06:00:01.994	2024-05-08 06:00:01.994	2024-05-08	3.3792	CAD	1
743	2024-05-08 06:00:01.996	2024-05-08 06:00:01.996	2024-05-08	5.0905	CHF	1
744	2024-05-08 06:00:01.997	2024-05-08 06:00:01.997	2024-05-08	0.6408	CNY	1
745	2024-05-08 06:00:01.998	2024-05-08 06:00:01.998	2024-05-08	0.199	CZK	1
746	2024-05-08 06:00:01.999	2024-05-08 06:00:01.999	2024-05-08	0.6671	DKK	1
747	2024-05-08 06:00:02	2024-05-08 06:00:02	2024-05-08	0.0969	EGP	1
748	2024-05-08 06:00:02.001	2024-05-08 06:00:02.001	2024-05-08	4.9757	EUR	1
749	2024-05-08 06:00:02.002	2024-05-08 06:00:02.002	2024-05-08	5.7992	GBP	1
750	2024-05-08 06:00:02.003	2024-05-08 06:00:02.003	2024-05-08	1.2777	HUF	100
751	2024-05-08 06:00:02.004	2024-05-08 06:00:02.004	2024-05-08	0.0554	INR	1
752	2024-05-08 06:00:02.005	2024-05-08 06:00:02.005	2024-05-08	2.9925	JPY	100
753	2024-05-08 06:00:02.005	2024-05-08 06:00:02.005	2024-05-08	0.3398	KRW	100
754	2024-05-08 06:00:02.006	2024-05-08 06:00:02.006	2024-05-08	0.2614	MDL	1
755	2024-05-08 06:00:02.007	2024-05-08 06:00:02.007	2024-05-08	0.2742	MXN	1
756	2024-05-08 06:00:02.008	2024-05-08 06:00:02.008	2024-05-08	0.4255	NOK	1
757	2024-05-08 06:00:02.01	2024-05-08 06:00:02.01	2024-05-08	2.7758	NZD	1
758	2024-05-08 06:00:02.01	2024-05-08 06:00:02.01	2024-05-08	1.1545	PLN	1
759	2024-05-08 06:00:02.011	2024-05-08 06:00:02.011	2024-05-08	0.0425	RSD	1
760	2024-05-08 06:00:02.012	2024-05-08 06:00:02.012	2024-05-08	0.0508	RUB	1
761	2024-05-08 06:00:02.012	2024-05-08 06:00:02.012	2024-05-08	0.4259	SEK	1
762	2024-05-08 06:00:02.013	2024-05-08 06:00:02.013	2024-05-08	0.1254	THB	1
763	2024-05-08 06:00:02.014	2024-05-08 06:00:02.014	2024-05-08	0.1433	TRY	1
764	2024-05-08 06:00:02.014	2024-05-08 06:00:02.014	2024-05-08	0.1177	UAH	1
765	2024-05-08 06:00:02.015	2024-05-08 06:00:02.015	2024-05-08	4.6253	USD	1
766	2024-05-08 06:00:02.016	2024-05-08 06:00:02.016	2024-05-08	344.1151	XAU	1
767	2024-05-08 06:00:02.017	2024-05-08 06:00:02.017	2024-05-08	6.1098	XDR	1
768	2024-05-08 06:00:02.017	2024-05-08 06:00:02.017	2024-05-08	0.2505	ZAR	1
769	2024-05-09 06:00:02.718	2024-05-09 06:00:02.718	2024-05-09	1	RON	1
770	2024-05-09 06:00:02.743	2024-05-09 06:00:02.743	2024-05-09	1.2601	AED	1
771	2024-05-09 06:00:02.746	2024-05-09 06:00:02.746	2024-05-09	3.0419	AUD	1
772	2024-05-09 06:00:02.747	2024-05-09 06:00:02.747	2024-05-09	2.5442	BGN	1
773	2024-05-09 06:00:02.748	2024-05-09 06:00:02.748	2024-05-09	0.9121	BRL	1
774	2024-05-09 06:00:02.748	2024-05-09 06:00:02.748	2024-05-09	3.3667	CAD	1
775	2024-05-09 06:00:02.754	2024-05-09 06:00:02.754	2024-05-09	5.093	CHF	1
776	2024-05-09 06:00:02.754	2024-05-09 06:00:02.754	2024-05-09	0.6407	CNY	1
777	2024-05-09 06:00:02.755	2024-05-09 06:00:02.755	2024-05-09	0.1987	CZK	1
778	2024-05-09 06:00:02.757	2024-05-09 06:00:02.757	2024-05-09	0.6671	DKK	1
779	2024-05-09 06:00:02.758	2024-05-09 06:00:02.758	2024-05-09	0.0973	EGP	1
780	2024-05-09 06:00:02.759	2024-05-09 06:00:02.759	2024-05-09	4.9761	EUR	1
781	2024-05-09 06:00:02.76	2024-05-09 06:00:02.76	2024-05-09	5.7804	GBP	1
782	2024-05-09 06:00:02.761	2024-05-09 06:00:02.761	2024-05-09	1.278	HUF	100
783	2024-05-09 06:00:02.762	2024-05-09 06:00:02.762	2024-05-09	0.0554	INR	1
784	2024-05-09 06:00:02.763	2024-05-09 06:00:02.763	2024-05-09	2.9789	JPY	100
785	2024-05-09 06:00:02.764	2024-05-09 06:00:02.764	2024-05-09	0.3398	KRW	100
786	2024-05-09 06:00:02.764	2024-05-09 06:00:02.764	2024-05-09	0.2606	MDL	1
787	2024-05-09 06:00:02.765	2024-05-09 06:00:02.765	2024-05-09	0.2739	MXN	1
788	2024-05-09 06:00:02.766	2024-05-09 06:00:02.766	2024-05-09	0.4234	NOK	1
789	2024-05-09 06:00:02.767	2024-05-09 06:00:02.767	2024-05-09	2.7718	NZD	1
790	2024-05-09 06:00:02.767	2024-05-09 06:00:02.767	2024-05-09	1.1534	PLN	1
791	2024-05-09 06:00:02.768	2024-05-09 06:00:02.768	2024-05-09	0.0425	RSD	1
792	2024-05-09 06:00:02.769	2024-05-09 06:00:02.769	2024-05-09	0.0504	RUB	1
793	2024-05-09 06:00:02.769	2024-05-09 06:00:02.769	2024-05-09	0.4245	SEK	1
794	2024-05-09 06:00:02.77	2024-05-09 06:00:02.77	2024-05-09	0.1253	THB	1
795	2024-05-09 06:00:02.771	2024-05-09 06:00:02.771	2024-05-09	0.1435	TRY	1
796	2024-05-09 06:00:02.771	2024-05-09 06:00:02.771	2024-05-09	0.1175	UAH	1
797	2024-05-09 06:00:02.772	2024-05-09 06:00:02.772	2024-05-09	4.6285	USD	1
798	2024-05-09 06:00:02.773	2024-05-09 06:00:02.773	2024-05-09	343.9028	XAU	1
799	2024-05-09 06:00:02.773	2024-05-09 06:00:02.773	2024-05-09	6.1083	XDR	1
800	2024-05-09 06:00:02.774	2024-05-09 06:00:02.774	2024-05-09	0.2492	ZAR	1
801	2024-05-10 06:00:01.391	2024-05-10 06:00:01.391	2024-05-10	1	RON	1
802	2024-05-10 06:00:01.428	2024-05-10 06:00:01.428	2024-05-10	1.2623	AED	1
803	2024-05-10 06:00:01.432	2024-05-10 06:00:01.432	2024-05-10	3.0491	AUD	1
804	2024-05-10 06:00:01.433	2024-05-10 06:00:01.433	2024-05-10	2.5438	BGN	1
805	2024-05-10 06:00:01.436	2024-05-10 06:00:01.436	2024-05-10	0.9107	BRL	1
806	2024-05-10 06:00:01.438	2024-05-10 06:00:01.438	2024-05-10	3.3769	CAD	1
807	2024-05-10 06:00:01.44	2024-05-10 06:00:01.44	2024-05-10	5.0974	CHF	1
808	2024-05-10 06:00:01.441	2024-05-10 06:00:01.441	2024-05-10	0.6416	CNY	1
809	2024-05-10 06:00:01.442	2024-05-10 06:00:01.442	2024-05-10	0.1991	CZK	1
810	2024-05-10 06:00:01.444	2024-05-10 06:00:01.444	2024-05-10	0.667	DKK	1
811	2024-05-10 06:00:01.454	2024-05-10 06:00:01.454	2024-05-10	0.0979	EGP	1
812	2024-05-10 06:00:01.457	2024-05-10 06:00:01.457	2024-05-10	4.9753	EUR	1
813	2024-05-10 06:00:01.459	2024-05-10 06:00:01.459	2024-05-10	5.7883	GBP	1
814	2024-05-10 06:00:01.461	2024-05-10 06:00:01.461	2024-05-10	1.281	HUF	100
815	2024-05-10 06:00:01.472	2024-05-10 06:00:01.472	2024-05-10	0.0555	INR	1
816	2024-05-10 06:00:01.481	2024-05-10 06:00:01.481	2024-05-10	2.9731	JPY	100
817	2024-05-10 06:00:01.494	2024-05-10 06:00:01.494	2024-05-10	0.3382	KRW	100
818	2024-05-10 06:00:01.506	2024-05-10 06:00:01.506	2024-05-10	0.2606	MDL	1
819	2024-05-10 06:00:01.523	2024-05-10 06:00:01.523	2024-05-10	0.2734	MXN	1
820	2024-05-10 06:00:01.542	2024-05-10 06:00:01.542	2024-05-10	0.4242	NOK	1
821	2024-05-10 06:00:01.56	2024-05-10 06:00:01.56	2024-05-10	2.781	NZD	1
822	2024-05-10 06:00:01.578	2024-05-10 06:00:01.578	2024-05-10	1.1577	PLN	1
823	2024-05-10 06:00:01.581	2024-05-10 06:00:01.581	2024-05-10	0.0425	RSD	1
824	2024-05-10 06:00:01.584	2024-05-10 06:00:01.584	2024-05-10	0.05	RUB	1
825	2024-05-10 06:00:01.59	2024-05-10 06:00:01.59	2024-05-10	0.4242	SEK	1
826	2024-05-10 06:00:01.6	2024-05-10 06:00:01.6	2024-05-10	0.1255	THB	1
827	2024-05-10 06:00:01.606	2024-05-10 06:00:01.606	2024-05-10	0.1439	TRY	1
828	2024-05-10 06:00:01.611	2024-05-10 06:00:01.611	2024-05-10	0.1172	UAH	1
829	2024-05-10 06:00:01.612	2024-05-10 06:00:01.612	2024-05-10	4.6364	USD	1
830	2024-05-10 06:00:01.613	2024-05-10 06:00:01.613	2024-05-10	343.9627	XAU	1
831	2024-05-10 06:00:01.615	2024-05-10 06:00:01.615	2024-05-10	6.1135	XDR	1
832	2024-05-10 06:00:01.616	2024-05-10 06:00:01.616	2024-05-10	0.2498	ZAR	1
833	2024-05-12 06:30:00.66	2024-05-12 06:30:00.66	2024-05-12	1	RON	1
834	2024-05-12 06:30:00.681	2024-05-12 06:30:00.681	2024-05-12	1.2561	AED	1
835	2024-05-12 06:30:00.683	2024-05-12 06:30:00.683	2024-05-12	3.0503	AUD	1
836	2024-05-12 06:30:00.683	2024-05-12 06:30:00.683	2024-05-12	2.544	BGN	1
837	2024-05-12 06:30:00.684	2024-05-12 06:30:00.684	2024-05-12	0.8972	BRL	1
838	2024-05-12 06:30:00.685	2024-05-12 06:30:00.685	2024-05-12	3.3721	CAD	1
839	2024-05-12 06:30:00.686	2024-05-12 06:30:00.686	2024-05-12	5.0909	CHF	1
840	2024-05-12 06:30:00.687	2024-05-12 06:30:00.687	2024-05-12	0.6386	CNY	1
841	2024-05-12 06:30:00.688	2024-05-12 06:30:00.688	2024-05-12	0.1994	CZK	1
842	2024-05-12 06:30:00.688	2024-05-12 06:30:00.688	2024-05-12	0.667	DKK	1
843	2024-05-12 06:30:00.689	2024-05-12 06:30:00.689	2024-05-12	0.0973	EGP	1
844	2024-05-12 06:30:00.69	2024-05-12 06:30:00.69	2024-05-12	4.9756	EUR	1
845	2024-05-12 06:30:00.69	2024-05-12 06:30:00.69	2024-05-12	5.7832	GBP	1
846	2024-05-12 06:30:00.691	2024-05-12 06:30:00.691	2024-05-12	1.2824	HUF	100
847	2024-05-12 06:30:00.692	2024-05-12 06:30:00.692	2024-05-12	0.0552	INR	1
848	2024-05-12 06:30:00.692	2024-05-12 06:30:00.692	2024-05-12	2.9633	JPY	100
849	2024-05-12 06:30:00.693	2024-05-12 06:30:00.693	2024-05-12	0.3379	KRW	100
850	2024-05-12 06:30:00.694	2024-05-12 06:30:00.694	2024-05-12	0.2605	MDL	1
851	2024-05-12 06:30:00.694	2024-05-12 06:30:00.694	2024-05-12	0.2755	MXN	1
852	2024-05-12 06:30:00.695	2024-05-12 06:30:00.695	2024-05-12	0.4265	NOK	1
853	2024-05-12 06:30:00.696	2024-05-12 06:30:00.696	2024-05-12	2.777	NZD	1
854	2024-05-12 06:30:00.696	2024-05-12 06:30:00.696	2024-05-12	1.1586	PLN	1
855	2024-05-12 06:30:00.697	2024-05-12 06:30:00.697	2024-05-12	0.0425	RSD	1
856	2024-05-12 06:30:00.698	2024-05-12 06:30:00.698	2024-05-12	0.05	RUB	1
857	2024-05-12 06:30:00.698	2024-05-12 06:30:00.698	2024-05-12	0.4258	SEK	1
858	2024-05-12 06:30:00.699	2024-05-12 06:30:00.699	2024-05-12	0.1257	THB	1
859	2024-05-12 06:30:00.699	2024-05-12 06:30:00.699	2024-05-12	0.1432	TRY	1
860	2024-05-12 06:30:00.7	2024-05-12 06:30:00.7	2024-05-12	0.1161	UAH	1
861	2024-05-12 06:30:00.701	2024-05-12 06:30:00.701	2024-05-12	4.6134	USD	1
862	2024-05-12 06:30:00.701	2024-05-12 06:30:00.701	2024-05-12	351.8267	XAU	1
863	2024-05-12 06:30:00.702	2024-05-12 06:30:00.702	2024-05-12	6.0952	XDR	1
864	2024-05-12 06:30:00.702	2024-05-12 06:30:00.702	2024-05-12	0.2506	ZAR	1
\.


--
-- Data for Name: Groups; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Groups" (id, "updateadAt", "createdAt", name, description) FROM stdin;
1	2024-04-01 10:32:12.048	2024-04-01 10:32:12.048	Niro	Niro Group
2	2024-04-19 11:32:07.756	2024-04-19 11:32:07.756	Dragon	Dragon
3	2024-04-19 11:35:17.677	2024-04-19 11:35:17.677	Toate Entitatile	Toate Entitatile
\.


--
-- Data for Name: Item; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Item" (id, name) FROM stdin;
1	Inchiriere
2	Mentenanta
\.


--
-- Data for Name: Location; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Location" (id, name) FROM stdin;
1	Traian
2	Dragon
3	Lascar Catargiu
4	Ceres
\.


--
-- Data for Name: MeasuringUnit; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."MeasuringUnit" (id, name) FROM stdin;
1	Lună (lună)
2	Oră (h)
3	Zi (zi)
4	An (an)
5	Metru (m)
6	Metru pătrat (m²)
7	Centimetru (cm)
8	Centimetru pătrat (cm²)
9	Kilometru (km)
10	Milimetru (mm)
11	Milă (mi)
12	Gram (g)
13	Kilogram (kg)
14	Tona metrică (t)
15	Miligram (mg)
16	Centigram (cg)
17	Uncie (oz)
18	Mililitru (ml)
19	Centilitru (cl)
20	Secundă (s)
21	Minut (min)
22	Săptămână (săptămână)
23	Centimetru cub (cm³ sau cc)
24	Metru cub (m³)
25	Mililitru (ml)
26	Hectolitră (hl)
27	Calorie (cal)
28	Kilocalorie (kcal)
29	Watt-ora (Wh)
30	Kilowatt-ora (kWh)
31	Hectare (ha)
\.


--
-- Data for Name: Partners; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Partners" (id, "updateadAt", "createdAt", name, fiscal_code, commercial_reg, state, type, email, remarks, "contractsId", "isVatPayer") FROM stdin;
1	2024-04-01 10:28:31.487	2024-04-01 10:27:37.455	SoftHub	RO2456788	J40/23/20422	Activ	Furnizor	a@a.com		\N	f
3	2024-04-01 10:30:50.658	2024-04-01 10:29:59.073	NIRO INVESTMENT SA	RO245678833	j40/2022	Activ	Entitate			\N	f
4	2024-04-19 11:31:12.212	2024-04-19 11:29:16.648	DRAGONUL ROSU SA 	15419962	J23/780/2003	Activ	Entitate			\N	f
5	2024-05-06 10:03:35.55	2024-05-06 10:01:25.175	Incremental	RO99123	j40/RO99123	Activ	Furnizor	i@i.com		\N	t
\.


--
-- Data for Name: PaymentType; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."PaymentType" (id, name) FROM stdin;
1	Numerar
2	Ordin de Plată
3	Cec
4	Bilet la ordin
5	Transfer Bancar
6	Virament Bancar
7	Portofel Digital(PayPal, Venmo...)
8	Bitcoin și Criptomonede
9	Card de Debit
10	Card de Credit
\.


--
-- Data for Name: Persons; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Persons" (id, "updateadAt", "createdAt", name, phone, email, "partnerId", role, legalrepresent) FROM stdin;
1	2024-04-01 10:27:37.455	2024-04-01 10:27:37.455	Razvan Mustata	+40746150001	razvan.mustata@gmail.com	1	Manager	t
3	2024-04-19 11:30:09.57	2024-04-19 11:30:09.57	Victor Prodescu	0746112233	victor.prodescu1@nirogroup.ro	4	IT Manager	t
2	2024-04-21 07:38:36.304	2024-04-01 10:29:59.073	Generic 	0746150044	razvan.mustata@nirogroup.ro	3	IT Rep	t
\.


--
-- Data for Name: Role; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Role" (id, "roleName") FROM stdin;
1	Administrator
2	Reader
3	Requestor
4	Editor
\.


--
-- Data for Name: Role_User; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Role_User" (id, "userId", "roleId") FROM stdin;
4	1	1
5	1	4
6	1	3
7	1	2
8	1	1
1	1	4
2	1	3
3	1	2
9	3	2
12	3	4
10	3	1
11	3	3
15	2	2
17	4	4
18	4	3
19	4	2
20	4	1
21	5	4
22	5	3
23	5	2
24	5	1
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."User" (id, name, email, password, "createdAt", picture, status, "updatedAt") FROM stdin;
3	admin	admin@gmail.com	$2b$04$uaG48ZpB5L7cGeRcTESSkuCNL.EknBnkHobAr0F949WSdt20M9Wki	2024-04-09 06:15:50.661	avatar-1711971721050-737063223.jpeg	t	2024-04-10 11:15:52.479
1	razvan	razvan.mustata@nirogroup.ro	$2b$04$Xb95kMzfjaydfxF2MpncxOpqEAuCcX3DWdYbIda3b9UWjpP63awH6	2024-04-01 10:33:16.556	avatar-1711967596544-863576033.png	t	2024-04-10 11:16:28.009
4	dragon	dragon@dragonulrosu.ro	$2b$04$0ROttqvk8qo6U0rfKj/eiulwpdPoQwbpQTQiyZs30j2ZntFd2a4re	2024-04-19 11:32:51.013	avatar-1713526370999-421365357.jpeg	t	2024-04-19 11:32:51.013
5	Administrator	a@a.com	$2b$04$SjnqVRCvgNThxQfadeCgB.z881jaATK0R2ihb8s6yOgy3uwSixHMi	2024-04-19 11:36:01.045	avatar-1713526561040-907768723.jpeg	t	2024-04-19 11:36:01.045
2	nu	nu@nu.com	$2b$04$WWRJCbMyu2eKVbLXXl.zle2HmkaEqPWBosbEO7ARNCSwLP9ZjE/e6	2024-04-01 11:42:01.058	avatar-1714651098451-671752087.gif	t	2024-05-02 11:58:18.475
\.


--
-- Data for Name: WorkFlow; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlow" (id, "updateadAt", "createdAt", "wfName", "wfDescription", status) FROM stdin;
143	2024-04-30 12:31:54.117	2024-04-29 07:31:17.251	Contracte dep. ITa	Contracte dep. IT2ae	f
144	2024-05-06 11:24:36.658	2024-04-29 14:17:26.4	Flux aprobare contracte dep Operational	Flux aprobare contracte dep Operational	t
\.


--
-- Data for Name: WorkFlowContractTasks; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowContractTasks" (id, "updateadAt", "createdAt", "contractId", "statusId", "requestorId", "assignedId", "workflowTaskSettingsId", "approvalOrderNumber", duedates, name, reminders, "taskPriorityId", text, uuid) FROM stdin;
844	2024-04-29 07:34:05.13	2024-04-29 07:34:05.13	30	1	3	2	70	1	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	3922cd96-e02c-4eb2-9bf1-312919861170
843	2024-04-29 07:34:05.129	2024-04-29 07:34:05.129	26	1	3	2	70	1	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	ee6183ef-38e4-49f6-a4df-1a761d58d3be
847	2024-04-29 07:34:05.13	2024-04-29 07:34:05.13	4	1	3	2	70	1	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	1a0371c6-338d-43b1-843f-3e1107e58a9f
846	2024-04-29 07:34:05.13	2024-04-29 07:34:05.13	1	1	3	2	70	1	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	d27a8c40-8502-4dd4-b449-0d2299217cc7
842	2024-04-29 07:34:05.129	2024-04-29 07:34:05.129	28	1	3	2	70	1	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	33cca1f6-2665-43c2-8476-7c9afc73648b
845	2024-04-29 07:34:05.13	2024-04-29 07:34:05.13	31	1	3	2	70	1	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	79ca8253-2931-494e-8061-ec76ddafedb2
848	2024-04-29 07:34:05.13	2024-04-29 07:34:05.13	6	1	3	2	70	1	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	846dd3fb-d4a8-4dd4-a595-889bd6f9dc3a
849	2024-04-29 07:36:02.176	2024-04-29 07:34:05.13	9	4	3	2	70	1	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	acae9b40-4257-45c4-8685-544d0100528f
850	2024-04-29 07:36:15.946	2024-04-29 07:36:05.024	9	4	3	1	70	2	2024-04-30 00:00:00	Task Contracte dep. IT	2024-04-29 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	0daac203-8c15-4705-a425-687a270555c4
852	2024-04-29 15:41:29.174	2024-04-29 14:36:05.066	5	4	3	2	71	1	2024-04-30 00:00:00	Flux dep op	2024-04-28 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	120009e3-65bf-4636-ba82-bdbaff416b71
851	2024-04-29 15:41:42.723	2024-04-29 14:19:05.046	3	4	3	2	71	1	2024-04-30 00:00:00	Flux dep op	2024-04-28 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p><p>Item;</p><p>Currency;</p><p>Frequency;</p><p>MeasuringUnit;</p><p>PaymentType;</p><p>TotalContractValue;</p><p>PaymentRemarks</p>	c21b4e23-4676-4f22-8e37-ea7856f6983c
854	2024-04-29 15:42:02.952	2024-04-29 15:41:45.05	3	4	3	1	71	2	2024-04-30 00:00:00	Flux dep op	2024-04-28 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	52c00bd0-d7e3-49cf-9f89-2471e8b0b125
899	2024-05-08 11:41:40.339	2024-05-08 11:41:05.089	66	4	3	2	71	1	2024-05-09 00:00:00	Flux aprobare contracte dep Operational	2024-05-07 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	51e6ebcb-57b9-49b4-9130-0f1a3f1ca470
853	2024-04-29 15:41:51.493	2024-04-29 15:41:30.059	5	4	3	1	71	2	2024-04-30 00:00:00	Flux dep op	2024-04-28 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	793eb6b4-fc79-44c8-aa2d-c0aa982bda6d
855	2024-04-29 15:52:43.392	2024-04-29 15:52:05.091	32	4	3	2	71	1	2024-04-30 00:00:00	Flux dep op	2024-04-28 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	34d88bcd-9053-473a-9820-a37a091ef9ee
856	2024-04-29 15:52:45.038	2024-04-29 15:52:45.038	32	1	3	1	71	2	2024-04-30 00:00:00	Flux dep op	2024-04-28 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	ef0e8b4c-aa73-4394-b384-430b09a4eedf
902	2024-05-10 09:32:05.135	2024-05-10 09:32:05.135	69	1	3	2	71	1	2024-05-11 00:00:00	Flux aprobare contracte dep Operational	2024-05-09 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	83a7ff0d-579c-4948-b525-a497922cae8f
857	2024-04-30 07:20:05.038	2024-04-30 07:20:05.038	33	1	3	2	71	1	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	6ea3c5a2-7f35-437b-8808-e1b5307f51a2
858	2024-04-30 07:24:05.043	2024-04-30 07:24:05.043	34	1	3	2	71	1	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	8c74842e-5950-436c-8403-d3e21ac38ac4
859	2024-04-30 07:24:05.044	2024-04-30 07:24:05.044	35	1	3	2	71	1	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	94e76917-01d9-483e-aa68-4800d23b2bed
903	2024-05-10 09:42:05.084	2024-05-10 09:42:05.084	71	1	3	2	71	1	2024-05-11 00:00:00	Flux aprobare contracte dep Operational	2024-05-09 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	de982f32-1e01-4591-9c77-c75a149640b6
860	2024-04-30 09:44:24.292	2024-04-30 09:43:05.036	36	4	3	2	71	1	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	674aacd2-6675-4d27-be7f-e36ecb119318
861	2024-04-30 09:45:32.806	2024-04-30 09:44:25.042	36	4	3	1	71	2	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	f6dd22bc-dde1-40de-b9e2-d02096885c59
904	2024-05-10 09:44:05.278	2024-05-10 09:44:05.278	72	1	3	2	71	1	2024-05-11 00:00:00	Flux aprobare contracte dep Operational	2024-05-09 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	cfd66a2c-7204-4965-ab2b-8138dfc93e84
862	2024-04-30 09:53:38.085	2024-04-30 09:52:05.041	37	4	3	2	71	1	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	7ceb281b-9e66-42b5-9fcd-6e2c0c21ea63
863	2024-04-30 09:54:30.395	2024-04-30 09:53:40.041	37	4	3	1	71	2	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	7e4aa197-d0d6-4b0a-9d2f-170049a404d4
864	2024-04-30 11:19:18.988	2024-04-30 11:19:05.045	38	4	3	2	71	1	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	794d9467-b97c-4bb1-b982-d1dbeba99d77
865	2024-04-30 11:19:52.328	2024-04-30 11:19:20.045	38	4	3	1	71	2	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	4e610a41-11d5-464b-b070-c1e64dc5507e
866	2024-04-30 11:23:47.419	2024-04-30 11:23:05.048	39	4	3	2	71	1	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	8a718551-cac6-49da-b76a-ad2db83b4f0e
867	2024-04-30 11:24:45.018	2024-04-30 11:23:50.045	39	4	3	1	71	2	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	6db03a4e-0536-452f-bf29-a5a55baf11a5
868	2024-04-30 11:52:28.845	2024-04-30 11:52:05.042	40	4	3	2	71	1	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	1fd4635e-8195-453e-9129-380e1f23e027
869	2024-04-30 11:52:48.419	2024-04-30 11:52:30.054	40	4	3	1	71	2	2024-05-01 00:00:00	Flux dep op	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	ff9a7576-3dd1-4591-90df-7d51b733f956
870	2024-04-30 12:19:10.858	2024-04-30 12:18:05.058	41	4	3	2	70	1	2024-05-01 00:00:00	Task Contracte dep. IT4	2024-04-30 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	bbf486fe-bac9-4986-b4ed-4624ad480a8d
871	2024-04-30 12:27:18.117	2024-04-30 12:27:05.064	42	4	3	2	70	1	2024-05-01 00:00:00	Task Contracte dep. IT4	2024-04-30 00:00:00	2	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	98984c68-0f77-48dd-95d2-c03bfa9877cd
872	2024-04-30 12:34:25.188	2024-04-30 12:34:05.076	43	4	3	2	71	1	2024-05-01 00:00:00	Flux aprobare contracte dep Operational	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	4b6070f4-ef57-4d93-b4f6-b94b7ad77aca
873	2024-04-30 12:34:46.259	2024-04-30 12:34:30.07	43	4	3	1	71	2	2024-05-01 00:00:00	Flux aprobare contracte dep Operational	2024-04-29 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	8fd2b0c0-6c52-4b8a-828e-be95a06f8f5c
874	2024-05-02 05:08:30.548	2024-05-02 05:08:05.059	44	4	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	6f4e42e8-9791-4757-a994-2a4659dea842
875	2024-05-02 05:08:49.382	2024-05-02 05:08:35.063	44	5	3	1	71	2	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	0051fdb5-7307-470d-ade4-97673e1c516a
876	2024-05-02 05:22:19.471	2024-05-02 05:22:05.06	45	5	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	1eae9e83-60a6-404a-912d-4a283aa14956
877	2024-05-02 05:22:20.066	2024-05-02 05:22:20.066	45	1	3	1	71	2	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	81b25ab1-2ffb-4f0c-9d16-1d2cde29fd38
878	2024-05-02 06:43:23.138	2024-05-02 06:43:05.07	46	5	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	a2828a8d-1aae-4497-a791-90516da9339b
879	2024-05-02 06:57:22.577	2024-05-02 06:57:05.07	47	5	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	43f241b4-fec8-435f-9cde-8fab12ad564b
880	2024-05-02 07:08:20.047	2024-05-02 07:08:05.058	48	4	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	0cf7ef7f-f972-4150-9516-12d5eebf77a4
881	2024-05-02 07:09:56.567	2024-05-02 07:08:25.063	48	5	3	1	71	2	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	dcb4b087-0dcc-4696-a650-3cbbcba0f9ef
882	2024-05-02 07:33:26.502	2024-05-02 07:33:05.066	49	5	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	56d049f6-09bd-459d-82ad-0c3a58317743
883	2024-05-02 07:38:22.84	2024-05-02 07:38:05.069	50	4	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	b685325e-8646-40fd-8018-3ca62ec1347f
884	2024-05-02 07:39:18.645	2024-05-02 07:38:25.069	50	5	3	1	71	2	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	bdee1ab1-a1fe-45f3-a09f-e0dcfd6c375b
885	2024-05-02 07:47:15.701	2024-05-02 07:47:05.069	51	4	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	dc1f3e5e-aa1c-4287-a544-7d136b873bde
886	2024-05-02 07:47:49.762	2024-05-02 07:47:20.075	51	5	3	1	71	2	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	069ccabc-6205-478d-9977-22965dbb2dc4
889	2024-05-02 09:39:05.066	2024-05-02 09:39:05.066	52	1	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	dc20a5c2-3da7-4dfc-bced-9d80c0588617
892	2024-05-02 09:50:44.738	2024-05-02 09:50:30.087	53	4	3	2	71	1	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	a07ebfe3-fe40-4cd2-92c0-1c2d80c4f748
893	2024-05-02 09:51:06.066	2024-05-02 09:50:45.071	53	4	3	1	71	2	2024-05-03 00:00:00	Flux aprobare contracte dep Operational	2024-05-01 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	01e27dcc-1ca4-42e2-9d16-7338ae6bb9cf
894	2024-05-06 08:05:05.111	2024-05-06 08:05:05.111	54	1	3	2	71	1	2024-05-07 00:00:00	Flux aprobare contracte dep Operational	2024-05-05 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	6196ab3c-109b-4ea0-b0aa-fb80f01d84a4
895	2024-05-06 08:36:05.087	2024-05-06 08:36:05.087	55	1	3	2	71	1	2024-05-07 00:00:00	Flux aprobare contracte dep Operational	2024-05-05 00:00:00	2	<p>Numar Contract: ContractNumber ;&nbsp;</p><p>Data semnarii: SignDate ;&nbsp;</p><p>Incepand cu data: StartDate ;&nbsp;</p><p>Termene de finalizare: FinalDate ;&nbsp;</p><p>Scurta descriere: ShortDescription;&nbsp;</p><p>Tip Contract: Type;&nbsp;</p><p><br></p><p>Nume Partener: PartnerName;&nbsp;</p><p>Reg Comertului Partener: PartnerComercialReg</p><p>Cod Fiscal Partener: PartnerFiscalCode ;&nbsp;</p><p>Adresa Partener: PartnerAddress ;&nbsp;</p><p>Banca Partener: PartnerBank ;&nbsp;</p><p>Filiala Banca Partener: PartnerBranch ;&nbsp;</p><p>Iban Partener: PartnerIban ;&nbsp;</p><p>Persoana Partener: PartnerPerson ;&nbsp;</p><p>Email Partener: PartnerEmail ;&nbsp;</p><p>Telefon Partener: PartnerPhone ;&nbsp;</p><p>Rol Persoana Partener: PartnerRole ;&nbsp;</p><p><br></p><p>Nume Entitate: EntityName;&nbsp;</p><p>Reg Comertului Entitate: EntityFiscalCode ;&nbsp;</p><p>Cod Fiscal Entitate: EntityComercialReg ;&nbsp;</p><p>Adresa Entitate: EntityAddress ;&nbsp;</p><p>Iban Entitate: EntityIban ;&nbsp;</p><p>Valuta Cont Iban Entitate: EntityCurrency ;&nbsp;</p><p>Persoana Entitate:&nbsp;EntityPerson ;&nbsp;</p><p>Email Entitate: EntityEmail ;&nbsp;</p><p>Telefon Entitate: EntityPhone ;&nbsp;</p><p>Rol Persoana Entitate: EntityRole;&nbsp;</p><p><br></p><p>Obiect de contract: Item;</p><p>Pretul contractului: TotalContractValue;</p><p>Valuta contractului: Currency;</p><p>Recurenta: Frequency&nbsp;</p><p>Tip Plata: PaymentType;</p><p>Unitate de masura: MeasuringUnit;</p><p>Note plata: PaymentRemarks;</p>	6f545758-da97-414b-bdc7-1bb003ba5c28
896	2024-05-06 12:50:05.092	2024-05-06 12:50:05.092	60	1	3	2	71	1	2024-05-07 00:00:00	Flux aprobare contracte dep Operational	2024-05-05 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	6352fb98-b199-4206-bfb7-96445251f1c6
897	2024-05-06 12:52:05.286	2024-05-06 12:52:05.286	61	1	3	2	71	1	2024-05-07 00:00:00	Flux aprobare contracte dep Operational	2024-05-05 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	c12e28a9-8405-4eef-b7e1-6f0aee087525
898	2024-05-08 07:29:05.107	2024-05-08 07:29:05.107	65	1	3	2	71	1	2024-05-09 00:00:00	Flux aprobare contracte dep Operational	2024-05-07 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	0d3abe6b-47ab-4eb5-afec-685b9f024693
900	2024-05-08 11:41:48.76	2024-05-08 11:41:30.137	66	4	3	1	71	2	2024-05-09 00:00:00	Flux aprobare contracte dep Operational	2024-05-07 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	07f63b83-7cda-47b9-b28c-ccfc59d4914d
901	2024-05-09 07:26:05.084	2024-05-09 07:26:05.084	67	1	3	2	71	1	2024-05-10 00:00:00	Flux aprobare contracte dep Operational	2024-05-08 00:00:00	2	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	541d05f7-97ed-497e-a41a-a670348690e3
\.


--
-- Data for Name: WorkFlowRejectActions; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowRejectActions" (id, "updateadAt", "createdAt", "workflowId", "sendNotificationsToAllApprovers", "sendNotificationsToContractResponsible") FROM stdin;
\.


--
-- Data for Name: WorkFlowRules; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowRules" (id, "updateadAt", "createdAt", "workflowId", "ruleFilterSource", "ruleFilterName", "ruleFilterValue", "ruleFilterValueName") FROM stdin;
231	2024-04-30 12:31:54.13	2024-04-30 12:31:54.13	143	departments	Departament	3	Operational
233	2024-05-06 11:24:36.665	2024-05-06 11:24:36.665	144	departments	Departament	3	Operational
\.


--
-- Data for Name: WorkFlowTaskSettings; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowTaskSettings" (id, "updateadAt", "createdAt", "workflowId", "taskName", "taskNotes", "taskSendNotifications", "taskSendReminders", "taskReminderId", "taskPriorityId", "taskDueDateId") FROM stdin;
70	2024-04-30 12:31:54.134	2024-04-29 07:31:17.279	143	Task Contracte dep. IT4	<p>ContractNumber ;&nbsp;</p><p>SignDate ;&nbsp;</p><p>StartDate ;&nbsp;</p><p>FinalDate ;&nbsp;</p><p>PartnerName ;&nbsp;</p><p>EntityName ;&nbsp;</p><p>ShortDescription ;&nbsp;</p><p>PartnerComercialReg ;&nbsp;</p><p>PartnerFiscalCode ;&nbsp;</p><p>PartnerAddress ;&nbsp;</p><p>PartnerBank ;&nbsp;</p><p>PartnerBranch ;&nbsp;</p><p>PartnerIban ;&nbsp;</p><p>PartnerPerson ;&nbsp;</p><p>PartnerEmail ;&nbsp;</p><p>PartnerPhone ;&nbsp;</p><p>PartnerRole ;&nbsp;</p><p>EntityFiscalCode ;&nbsp;</p><p>EntityComercialReg ;&nbsp;</p><p>EntityAddress ;&nbsp;</p><p>EntityIban ;&nbsp;</p><p>EntityCurrency ;&nbsp;</p><p>EntityPerson ;&nbsp;</p><p>EntityEmail ;&nbsp;</p><p>EntityPhone ;&nbsp;</p><p>EntityRole ;&nbsp;</p><p>Type ;&nbsp;</p>	t	t	2	2	2
71	2024-05-06 11:24:36.677	2024-04-29 14:17:26.451	144	Flux aprobare contracte dep Operational	<p>Numar Contract: <span style="color: rgb(230, 0, 0);">ContractNumber</span> ;&nbsp;</p><p>Data semnarii: <span style="color: rgb(230, 0, 0);">SignDate</span> ;&nbsp;</p><p>Incepand cu data: <span style="color: rgb(230, 0, 0);">StartDate</span> ;&nbsp;</p><p>Termene de finalizare: <span style="color: rgb(230, 0, 0);">FinalDate</span> ;&nbsp;</p><p>Scurta descriere: <span style="color: rgb(230, 0, 0);">ShortDescription</span>;&nbsp;</p><p>Tip Contract: <span style="color: rgb(230, 0, 0);">Type</span>;&nbsp;</p><p><br></p><p>Nume Partener: <span style="color: rgb(230, 0, 0);">PartnerName</span>;&nbsp;</p><p>Reg Comertului Partener: <span style="color: rgb(230, 0, 0);">PartnerComercialReg</span></p><p>Cod Fiscal Partener: <span style="color: rgb(230, 0, 0);">PartnerFiscalCode</span> ;&nbsp;</p><p>Adresa Partener: <span style="color: rgb(230, 0, 0);">PartnerAddress</span> ;&nbsp;</p><p>Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBank</span> ;&nbsp;</p><p>Filiala Banca Partener: <span style="color: rgb(230, 0, 0);">PartnerBranch</span> ;&nbsp;</p><p>Iban Partener: <span style="color: rgb(230, 0, 0);">PartnerIban</span> ;&nbsp;</p><p>Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerPerson</span> ;&nbsp;</p><p>Email Partener: <span style="color: rgb(230, 0, 0);">PartnerEmail</span> ;&nbsp;</p><p>Telefon Partener: <span style="color: rgb(230, 0, 0);">PartnerPhone</span> ;&nbsp;</p><p>Rol Persoana Partener: <span style="color: rgb(230, 0, 0);">PartnerRole</span> ;&nbsp;</p><p><br></p><p>Nume Entitate: <span style="color: rgb(230, 0, 0);">EntityName</span>;&nbsp;</p><p>Reg Comertului Entitate: <span style="color: rgb(230, 0, 0);">EntityFiscalCode</span> ;&nbsp;</p><p>Cod Fiscal Entitate: <span style="color: rgb(230, 0, 0);">EntityComercialReg</span> ;&nbsp;</p><p>Adresa Entitate: <span style="color: rgb(230, 0, 0);">EntityAddress</span> ;&nbsp;</p><p>Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityIban</span> ;&nbsp;</p><p>Valuta Cont Iban Entitate: <span style="color: rgb(230, 0, 0);">EntityCurrency</span> ;&nbsp;</p><p>Persoana Entitate:&nbsp;<span style="color: rgb(230, 0, 0);">EntityPerson</span> ;&nbsp;</p><p>Email Entitate: <span style="color: rgb(230, 0, 0);">EntityEmail</span> ;&nbsp;</p><p>Telefon Entitate: <span style="color: rgb(230, 0, 0);">EntityPhone</span> ;&nbsp;</p><p>Rol Persoana Entitate: <span style="color: rgb(230, 0, 0);">EntityRole</span>;&nbsp;</p><p><br></p><p>Obiect de contract: <span style="color: rgb(230, 0, 0);">Item</span>;</p><p>Pretul contractului: <span style="color: rgb(230, 0, 0);">TotalContractValue</span>;</p><p>Valuta contractului: <span style="color: rgb(230, 0, 0);">Currency</span>;</p><p>Recurenta: <span style="color: rgb(230, 0, 0);">Frequency</span>&nbsp;</p><p>Tip Plata: <span style="color: rgb(230, 0, 0);">PaymentType</span>;</p><p>Unitate de masura: <span style="color: rgb(230, 0, 0);">MeasuringUnit</span>;</p><p>Note plata: <span style="color: rgb(230, 0, 0);">PaymentRemarks</span>;</p>	t	t	3	2	2
\.


--
-- Data for Name: WorkFlowTaskSettingsUsers; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowTaskSettingsUsers" (id, "updateadAt", "createdAt", "workflowTaskSettingsId", "userId", "approvalOrderNumber", "approvalStepName") FROM stdin;
157	2024-04-30 12:31:54.137	2024-04-30 12:31:54.137	70	2	1	p1
158	2024-04-30 12:31:54.141	2024-04-30 12:31:54.141	70	1	2	p2
161	2024-05-06 11:24:36.685	2024-05-06 11:24:36.685	71	2	1	a1
162	2024-05-06 11:24:36.691	2024-05-06 11:24:36.691	71	1	2	a2
\.


--
-- Data for Name: WorkFlowXContracts; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowXContracts" (id, "updateadAt", "createdAt", "contractId", "wfstatusId", "ctrstatusId", "workflowTaskSettingsId") FROM stdin;
664	2024-04-29 07:34:00.073	2024-04-29 07:34:00.073	26	1	2	70
665	2024-04-29 07:34:00.085	2024-04-29 07:34:00.085	28	1	2	70
666	2024-04-29 07:34:00.087	2024-04-29 07:34:00.087	9	1	2	70
667	2024-04-29 07:34:00.089	2024-04-29 07:34:00.089	4	1	2	70
668	2024-04-29 07:34:00.091	2024-04-29 07:34:00.091	30	1	2	70
669	2024-04-29 07:34:00.093	2024-04-29 07:34:00.093	31	1	2	70
670	2024-04-29 07:34:00.096	2024-04-29 07:34:00.096	1	1	2	70
671	2024-04-29 07:34:00.099	2024-04-29 07:34:00.099	6	1	2	70
672	2024-04-29 14:19:00.05	2024-04-29 14:19:00.05	26	1	2	71
673	2024-04-29 14:19:00.08	2024-04-29 14:19:00.08	28	1	2	71
674	2024-04-29 14:19:00.082	2024-04-29 14:19:00.082	4	1	2	71
675	2024-04-29 14:19:00.084	2024-04-29 14:19:00.084	30	1	2	71
676	2024-04-29 14:19:00.087	2024-04-29 14:19:00.087	31	1	2	71
677	2024-04-29 14:19:00.089	2024-04-29 14:19:00.089	1	1	2	71
678	2024-04-29 14:19:00.091	2024-04-29 14:19:00.091	6	1	2	71
679	2024-04-29 14:19:00.093	2024-04-29 14:19:00.093	9	1	2	71
680	2024-04-29 14:19:00.095	2024-04-29 14:19:00.095	3	1	2	71
681	2024-04-29 14:36:00.071	2024-04-29 14:36:00.071	5	1	2	71
682	2024-04-29 15:52:00.046	2024-04-29 15:52:00.046	32	1	2	71
683	2024-04-30 07:20:00.036	2024-04-30 07:20:00.036	33	1	2	71
684	2024-04-30 07:24:00.029	2024-04-30 07:24:00.029	34	1	2	71
685	2024-04-30 07:24:00.035	2024-04-30 07:24:00.035	35	1	2	71
686	2024-04-30 09:43:00.033	2024-04-30 09:43:00.033	36	1	2	71
687	2024-04-30 09:52:00.103	2024-04-30 09:52:00.103	37	1	2	71
688	2024-04-30 11:19:00.033	2024-04-30 11:19:00.033	38	1	2	71
689	2024-04-30 11:23:00.042	2024-04-30 11:23:00.042	39	1	2	71
690	2024-04-30 11:52:00.043	2024-04-30 11:52:00.043	40	1	2	71
691	2024-04-30 12:15:00.058	2024-04-30 12:15:00.058	32	1	2	70
692	2024-04-30 12:15:00.068	2024-04-30 12:15:00.068	33	1	2	70
693	2024-04-30 12:15:00.074	2024-04-30 12:15:00.074	34	1	2	70
694	2024-04-30 12:15:00.076	2024-04-30 12:15:00.076	35	1	2	70
695	2024-04-30 12:15:00.08	2024-04-30 12:15:00.08	36	1	2	70
696	2024-04-30 12:15:00.083	2024-04-30 12:15:00.083	37	1	2	70
697	2024-04-30 12:15:00.085	2024-04-30 12:15:00.085	38	1	2	70
698	2024-04-30 12:15:00.089	2024-04-30 12:15:00.089	39	1	2	70
699	2024-04-30 12:15:00.09	2024-04-30 12:15:00.09	40	1	2	70
700	2024-04-30 12:15:00.095	2024-04-30 12:15:00.095	5	1	2	70
701	2024-04-30 12:15:00.097	2024-04-30 12:15:00.097	3	1	2	70
702	2024-04-30 12:18:00.047	2024-04-30 12:18:00.047	41	1	2	71
703	2024-04-30 12:18:00.069	2024-04-30 12:18:00.069	41	1	2	70
704	2024-04-30 12:27:00.05	2024-04-30 12:27:00.05	42	1	2	71
705	2024-04-30 12:27:00.073	2024-04-30 12:27:00.073	42	1	2	70
706	2024-04-30 12:34:00.056	2024-04-30 12:34:00.056	43	1	2	71
707	2024-05-02 05:08:00.028	2024-05-02 05:08:00.028	44	1	2	71
708	2024-05-02 05:22:00.044	2024-05-02 05:22:00.044	45	1	2	71
709	2024-05-02 06:43:00.052	2024-05-02 06:43:00.052	46	1	2	71
711	2024-05-02 06:58:00.054	2024-05-02 06:58:00.054	47	1	2	71
714	2024-05-02 07:29:00.058	2024-05-02 07:29:00.058	48	1	2	71
717	2024-05-02 07:37:00.094	2024-05-02 07:37:00.094	49	1	2	71
719	2024-05-02 07:40:00.097	2024-05-02 07:40:00.097	50	1	2	71
722	2024-05-02 09:01:00.075	2024-05-02 09:01:00.075	51	1	2	71
724	2024-05-02 09:39:00.072	2024-05-02 09:39:00.072	52	1	2	71
726	2024-05-02 09:50:00.078	2024-05-02 09:50:00.078	53	1	2	71
727	2024-05-06 08:05:00.082	2024-05-06 08:05:00.082	54	1	2	71
728	2024-05-06 08:36:00.185	2024-05-06 08:36:00.185	55	1	2	71
729	2024-05-06 12:50:00.117	2024-05-06 12:50:00.117	60	1	2	71
730	2024-05-06 12:52:00.164	2024-05-06 12:52:00.164	61	1	2	71
731	2024-05-08 07:29:00.192	2024-05-08 07:29:00.192	65	1	2	71
732	2024-05-08 11:41:00.091	2024-05-08 11:41:00.091	66	1	2	71
733	2024-05-09 07:26:00.086	2024-05-09 07:26:00.086	67	1	2	71
734	2024-05-10 09:32:00.131	2024-05-10 09:32:00.131	69	1	2	71
735	2024-05-10 09:42:00.1	2024-05-10 09:42:00.1	71	1	2	71
736	2024-05-10 09:44:00.118	2024-05-10 09:44:00.118	72	1	2	71
\.


--
-- Data for Name: _GroupsToPartners; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."_GroupsToPartners" ("A", "B") FROM stdin;
1	3
2	4
3	3
3	4
\.


--
-- Data for Name: _GroupsToUser; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."_GroupsToUser" ("A", "B") FROM stdin;
1	1
1	2
1	3
2	4
3	5
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
dac8594d-1e18-4d95-82a0-69e0b7a3449d	ad8576d14b2c62fc95045ce2cd68c064a5e509abfcfe7bcd4663b7deeede4b32	2024-04-01 13:22:15.157308+03	20240131114230_init	\N	\N	2024-04-01 13:22:15.152759+03	1
ac7f7f23-bdf1-415e-be7d-583c1609f106	23a86e2369db98c99fdec859419347f3fe4e8ecd52e2f689e3c2c3e03a098063	2024-04-01 13:22:14.921124+03	20240104130027_init	\N	\N	2024-04-01 13:22:14.909638+03	1
519e81d9-9c3d-42e4-9806-7624f17c2cb4	977ec891876257e28e037c4c9432ef9110adad6c75b9a3f31b73c823c6ae32d3	2024-04-01 13:22:15.052888+03	20240116134140_bank	\N	\N	2024-04-01 13:22:15.047057+03	1
b1e7b342-1bff-4f98-b4d2-c9861405f47b	4da2a23903cbbcef13e542877f574cb1a1e01fc341d2bcb4d9571f55c4b57292	2024-04-01 13:22:14.928346+03	20240104133214_init	\N	\N	2024-04-01 13:22:14.921875+03	1
a011c6f7-134e-45ec-b343-ce1d9477564c	92a320941ead86308ba6bfa68593da156875e47bf7037ba7acf2667ba46aeb77	2024-04-01 13:22:14.933445+03	20240104141916_init	\N	\N	2024-04-01 13:22:14.928964+03	1
6c30c460-6a3c-421b-a60b-19bbd108caa0	1fdbf30c850caab5676b69dda360e2eb25e79c8b0d9179eaf4f8973287de5ee5	2024-04-01 13:22:15.090508+03	20240126104551_init	\N	\N	2024-04-01 13:22:15.082706+03	1
a9ec06b6-69c9-4a14-a863-462e1a125c62	8879b3c1b4dbc53cec49b5b1069a8cf5fff45819428284d66f75be5e4c6f2219	2024-04-01 13:22:14.958191+03	20240104143603_init	\N	\N	2024-04-01 13:22:14.934243+03	1
46b826be-bf82-46e2-8e67-4fee11514853	7e4715ed7ce572c45c920ff2787e78d219fd9aea0b4899f6af90336a710634dd	2024-04-01 13:22:15.055929+03	20240116135120_bank2	\N	\N	2024-04-01 13:22:15.053684+03	1
e0c71cce-9237-40b3-bdaa-b6e2dbdd33c5	8f2ad4636fb9bd644824bd7438888a640ccd490e838e90f8f35c8aba7e2b93ac	2024-04-01 13:22:14.9737+03	20240108125945_init	\N	\N	2024-04-01 13:22:14.958822+03	1
757c8a0f-f75b-4b2e-bc84-002ebf237805	ed60132fe1e6c18d361f612cfca7c420021075dac021c37f2b80bb6324d2a937	2024-04-01 13:22:14.976716+03	20240109101645_without_unique	\N	\N	2024-04-01 13:22:14.974313+03	1
51e5753e-d70e-417d-b965-a117a0e8611b	e1843cee6c521f57dfd32d538f166465e416c06c103956a5f0530e1e48af45c9	2024-04-01 13:22:14.990869+03	20240110101455_nomenclatoare	\N	\N	2024-04-01 13:22:14.977367+03	1
cd2d117b-1bc2-414b-8ed8-3a944338e9e6	39433a0e5c3b9fdf1a8f56bdb14fd7fa2b9b1ca15697b9c16cc9e4c1f92727a5	2024-04-01 13:22:15.05796+03	20240118120039_init	\N	\N	2024-04-01 13:22:15.056437+03	1
cba73e68-9c5c-49d1-a4b8-51934ea3c2ec	50258465afcd5d29ce2193d799f3681dfcec8d9cc1dcdbb932fbf1b24f8f9179	2024-04-01 13:22:14.993515+03	20240112153345_add_cat	\N	\N	2024-04-01 13:22:14.991545+03	1
644df034-4aa2-4658-b7f7-49431d62d0fd	a7626cf287742bbe4ca0b3302595a6d8ee01675263ebf7b74d0f16c8e3803f2e	2024-04-01 13:22:15.00796+03	20240114055127_add_lookups	\N	\N	2024-04-01 13:22:14.994199+03	1
1ce9a0d9-e0d5-47dd-9311-4dde3c247ede	d4de14ee2dfcf17d9908fa793769d1ae8b4452b6e05d026ae8e1815d40562173	2024-04-01 13:22:15.121778+03	20240128161837_init	\N	\N	2024-04-01 13:22:15.116684+03	1
3df3aa2c-e2c5-43d7-b281-1b84cd86b495	43f7a84ca76a1dd6dea71e1e3c495f1cd9e361ea5ac1ea4b54c928609be101a2	2024-04-01 13:22:15.025888+03	20240115081246_partner	\N	\N	2024-04-01 13:22:15.008699+03	1
0297feb0-29b3-4f41-8b37-12a392704455	5dfb88c01f54bdf003872be93ee719948e699b2239aa6c38e0de993fcb291822	2024-04-01 13:22:15.063754+03	20240118120207_init	\N	\N	2024-04-01 13:22:15.058325+03	1
097c5d32-e25a-4267-82d7-b30251fc0f59	95b3f8c0c67b2e22ee3f5a02ec18fef109827d6f7e30fb9ff214959e369b70b0	2024-04-01 13:22:15.029337+03	20240115081401_partner	\N	\N	2024-04-01 13:22:15.026369+03	1
d5a7462e-016c-4288-9557-c0aade3fac14	07ae453f14f60aa396fa5923109e1e9c7764c5e0583ca7dbc95e7c441f4bad59	2024-04-01 13:22:15.034006+03	20240115092006_init	\N	\N	2024-04-01 13:22:15.030143+03	1
519efbed-79c8-4ca0-aa1d-263263b7d4d5	00b40340787314adf18075a4c719ea9c1fe4630afaaac0c5bb880f887244f724	2024-04-01 13:22:15.09326+03	20240126105841_init	\N	\N	2024-04-01 13:22:15.091156+03	1
857e2e98-fcc8-4d0a-b679-e42edf2dda5e	be50eef072f565cc3f69431afd017cc9b8b9e1b7628d23f9a4cf0033e6edc4ca	2024-04-01 13:22:15.043377+03	20240116083536_address	\N	\N	2024-04-01 13:22:15.034995+03	1
c278cd06-a8f9-4c06-ab84-8bed34903d58	39e80257772bdc7ade25a4f4bac482f8077b51864b4b7fdd87efc3da2885e80e	2024-04-01 13:22:15.066334+03	20240118120348_init	\N	\N	2024-04-01 13:22:15.064567+03	1
e3a8d394-3ac4-4b6b-96a4-e6299e50ed94	0720788796ebecfd565f0b688a07def4632bf46a9cbc5d2b7807fc982871d099	2024-04-01 13:22:15.046301+03	20240116100636_address2	\N	\N	2024-04-01 13:22:15.044044+03	1
42465a82-6a37-48bf-8d2e-85e1d3fd1be0	61ee0d8a5b7b2cb4ad11185acede721e1a342c2cbf56bf9734a8a4dd86e08305	2024-04-01 13:22:15.06882+03	20240118142955_init	\N	\N	2024-04-01 13:22:15.067118+03	1
ad7a3769-a87d-479a-a1a9-20b15249c429	6536256885a20c3fb822093472a941f6c09f5b29345d4920891bf44eaa6cba6c	2024-04-01 13:22:15.070795+03	20240119095713_init	\N	\N	2024-04-01 13:22:15.069273+03	1
335609d3-48d6-47c0-b10e-dd192131f8cc	f2aa161f99b17be209b9bfe5d6bd674a2e72a856dd2ff9f1bd7320e457237694	2024-04-01 13:22:15.09632+03	20240126122744_init	\N	\N	2024-04-01 13:22:15.093794+03	1
0d5e9cf1-8391-48cd-961b-d7510ef0340d	d6be293aa2ef7a5446954e91ec546a16782eebdf39c74e6bea8154d5518561d0	2024-04-01 13:22:15.075469+03	20240119102921_init	\N	\N	2024-04-01 13:22:15.071563+03	1
2a371da4-6063-473a-9013-b21b229f4a39	7678c385cf3ea035dd0497ba02d2953807b7cfd6cb6947a86968ad537cc719cc	2024-04-01 13:22:15.082191+03	20240125113624_init	\N	\N	2024-04-01 13:22:15.076036+03	1
20a82197-d708-4eb5-9a73-1a31e661772c	799189d35baa4313617c887d873b3c34edd2aa820ca79a0af5711f8e5584bc75	2024-04-01 13:22:15.147725+03	20240130082940_init	\N	\N	2024-04-01 13:22:15.142237+03	1
afdca281-1a23-4b42-ac10-f2d5c2ebce0d	7d4ae120cb9151f649135125b2cc8dfaacf724974836f2002cce719128408d6f	2024-04-01 13:22:15.100439+03	20240126124359_init	\N	\N	2024-04-01 13:22:15.096995+03	1
ffc1e2c9-1848-41aa-b593-b97d87778f6d	52652cb8679e0232d5df45175aa6732f022e208572110cdfeffb8d7520139332	2024-04-01 13:22:15.124292+03	20240129062205_init	\N	\N	2024-04-01 13:22:15.122175+03	1
47837428-9dea-40e5-9508-012f9e24d113	658eb499ce0aef6e91cebc84ee16d3bad3d9997495b44100efc8d2a3535252d7	2024-04-01 13:22:15.112024+03	20240128153759_init	\N	\N	2024-04-01 13:22:15.101463+03	1
06c54176-c724-4ec1-aa7b-52ba93dc49dc	6bce4b7971628c4f1e59a5f58920830eabb54d060633600725fcbb4e52ef0903	2024-04-01 13:22:15.116052+03	20240128153945_init	\N	\N	2024-04-01 13:22:15.112593+03	1
aa338eaa-ad1d-4b5a-9464-7cafc3074820	72466053ded1e79556ea68fe2d65f65aa4b3b1c849b9023e1c3593c115aadcab	2024-04-01 13:22:15.130992+03	20240129070106_init	\N	\N	2024-04-01 13:22:15.124843+03	1
22baf555-8479-4063-8ebd-ed1d59fff955	9aad9ca02d27fff8e1650c510d86d83cc12262f8f513bd6519824b7b28443e9d	2024-04-01 13:22:15.14182+03	20240129072018_init	\N	\N	2024-04-01 13:22:15.131418+03	1
c4f00f75-7232-46ab-a67f-abdc6a18d75f	df4793be4a989e39745bb8ca9478ab1935149c16274d0fc634aa0de3867efd81	2024-04-01 13:22:15.152335+03	20240130083818_init	\N	\N	2024-04-01 13:22:15.148158+03	1
3ac9ff5c-29a4-4f91-bc31-b36fb94acf85	0c0906dcb8391dad5972bbaea86a8d2bad51ced4c152d06d07ef005462046e17	2024-04-01 13:22:15.162172+03	20240201094410_init	\N	\N	2024-04-01 13:22:15.160111+03	1
ee8b95da-e1dc-486f-99fa-243d0f0257ef	69c5d55790477b301f0fdf18e4c62219382294902dc53d631cd3d8e42fc53f28	2024-04-01 13:22:15.159559+03	20240201093629_init	\N	\N	2024-04-01 13:22:15.157776+03	1
e9638fa3-260f-493c-983f-f55178d7015d	8f3747eb875999978dc041819964fc44cc95aa6f30993d4298347e4f64f0a50d	2024-04-01 13:22:15.16455+03	20240201095542_init	\N	\N	2024-04-01 13:22:15.162759+03	1
06899a8f-42c5-4f4e-8358-a921e22d389d	e2ebc20c1477adb8c3658642c80736a1d3885306ec19bc02babff0add4e1576d	2024-04-01 13:22:15.16791+03	20240201102051_init	\N	\N	2024-04-01 13:22:15.165114+03	1
5eb208e0-e174-4bd3-b657-92f554a0ea3e	35638aa42bf8eae5e465fb3a938d61e704d2c7949fbc7dd3316f43579825d9f2	2024-04-01 13:22:15.173127+03	20240205065253_init	\N	\N	2024-04-01 13:22:15.168528+03	1
5f919185-5f57-4b0e-a7ee-cd04cb33aebf	6d58e52871e48b439dfe34583be4e49253c20082ecbfe0104efc31a78af476bb	2024-04-01 13:22:15.180876+03	20240205095417_init	\N	\N	2024-04-01 13:22:15.173738+03	1
1f3c4655-6e83-4e27-b8a6-51213c4eace9	d318c7469a6b6d8252ce8a978e91c6b8a13497bc5e458b4713d3b79900521e68	2024-04-01 13:22:15.186316+03	20240205113433_init	\N	\N	2024-04-01 13:22:15.181305+03	1
9d9c6807-787e-42c4-b6a6-2cf9de1491fc	830cc21e3141505a045c668842ed2213c4565140d99dcfd03bf8811755c2bae4	2024-04-01 13:22:15.306168+03	20240220131517_init	\N	\N	2024-04-01 13:22:15.303366+03	1
09b669ef-9c40-4a04-99e8-c7ae541674e0	953cccbd987f900b363e653cfe2def20a9e1ec9a4e6c109cd69bc5a22e261cf3	2024-04-01 13:22:15.189631+03	20240205113712_init	\N	\N	2024-04-01 13:22:15.186893+03	1
695f0ddb-560c-42ec-b980-d34416eac08f	e019647f6f598f7ef86acb15bacbe24be275e3558fd6371dd5847b7fe5bba0ce	2024-04-01 13:22:15.237574+03	20240212085056_init	\N	\N	2024-04-01 13:22:15.236263+03	1
bf468d25-35d3-4407-b202-1e07e9aa0f0a	6c4aca507cf7ff9993738a7c7d0f921b0d434feea674ff52073db9c48e5b7049	2024-04-01 13:22:15.200623+03	20240206110336_init	\N	\N	2024-04-01 13:22:15.19028+03	1
06e0d2dc-7c37-46f4-b224-c5b33b367e0c	36960761bf8945e0b9aaf2d25d39a97482bc2ff36a1e2fcfee85f718c52d96e9	2024-04-01 13:22:15.202277+03	20240206125522_init	\N	\N	2024-04-01 13:22:15.201027+03	1
758f00f2-c23c-4ae1-b22a-b7dd56dba130	f4c574e6218885173cc314a56e3a740641e6cb4d546d489b864f0e395c760cab	2024-04-01 13:22:15.267278+03	20240216131812_init	\N	\N	2024-04-01 13:22:15.264663+03	1
18595e43-f5fe-4658-9d69-1a4f9d87c4c9	5f998307b8fd03ab76eeeaa82ea480a7d4e5eaa8203a8ff09431aa5686d51858	2024-04-01 13:22:15.203849+03	20240206125818_init	\N	\N	2024-04-01 13:22:15.202706+03	1
2817c092-5923-4011-b2a1-7bf2200c79a0	7fdd2980aef4995dbd048d16c92534034c8b4b34a7853691d3903eb313243c77	2024-04-01 13:22:15.241929+03	20240213090136_init	\N	\N	2024-04-01 13:22:15.237926+03	1
fac36e1b-cfb0-4de1-8de9-ca974aabb648	94c2a8c709c3b6c51cfb50a917a19fd7272b2a9780e5af1e2957681b86c5fced	2024-04-01 13:22:15.208352+03	20240207100614_init	\N	\N	2024-04-01 13:22:15.204207+03	1
0dd175b8-d6c1-44a7-997f-5d8315b91b48	d6a162eddbb96991f0f55683123c6e97668648ef39f9a94fae54abe80614dfb7	2024-04-01 13:22:15.213333+03	20240207104440_init	\N	\N	2024-04-01 13:22:15.208815+03	1
16ad1ac1-96ed-43c9-8564-9ece020e9890	af9a72c66447653e81958bc713315f1bffbbcb738d07693529dda46ac6a47df2	2024-04-01 13:22:15.215514+03	20240207105654_init	\N	\N	2024-04-01 13:22:15.213744+03	1
67be0fcf-2bd1-4de9-a2bd-2a3c1e5b99c3	51993c60d53428cc9b954f1c94c97c31a80ed28751b0dfc660354554ca053443	2024-04-01 13:22:15.243678+03	20240213090610_init	\N	\N	2024-04-01 13:22:15.242337+03	1
c24c214a-efe1-47e5-b370-a93bcef4e8d2	33bce8917466d1bf06cd5aa38b2e93c0bf7a9859d1b85e352aed48bb520bf47f	2024-04-01 13:22:15.219708+03	20240207110138_init	\N	\N	2024-04-01 13:22:15.216091+03	1
dbb15613-2d14-4b1e-b7b6-46717b276de8	c3c6464ea30a9da42aa4aebee71e025880539966286bf112242bcbf38ad59086	2024-04-01 13:22:15.221642+03	20240207111109_init	\N	\N	2024-04-01 13:22:15.220092+03	1
3bd21426-2f86-40c3-bf4e-59cf876386e7	87daa102f90741df943e65e9ed96b43b209ac9743f5c12083beb6e8779c5ec5e	2024-04-01 13:22:15.2912+03	20240220091623_init	\N	\N	2024-04-01 13:22:15.284388+03	1
d1d0de1f-c38f-4a94-b1c3-05b85844b709	f723b838032e8f790f5a2f1d2ee4c27550b71be8b809540cb9e584d983721f50	2024-04-01 13:22:15.223146+03	20240208130939_init	\N	\N	2024-04-01 13:22:15.222048+03	1
a3f80411-7961-4e61-8282-f850cca4f6e1	1cf57200905e31d5e96fdcdb7afa1062ea1fb4ac39e816dd636d5d1ff219418a	2024-04-01 13:22:15.248542+03	20240214100544_init	\N	\N	2024-04-01 13:22:15.244058+03	1
372a544c-985b-47b3-8a37-de98d9097011	6767a6af3ca39854907ae760a129ae4396d4c00dcb59ec19a1ab3b34a4926bf7	2024-04-01 13:22:15.227075+03	20240209131756_init	\N	\N	2024-04-01 13:22:15.223495+03	1
60edcee5-5895-4c30-aee1-877760df6163	058804677db817f2cebe5e426eee5c4be998d2501fde05e8a82435c7cadf72c8	2024-04-01 13:22:15.232578+03	20240212071630_init	\N	\N	2024-04-01 13:22:15.227615+03	1
c14a0462-3eb9-441b-a9c2-047fc3cee6c1	301c44321c0d3958f0475f6d389746b2d9a276d8517cad58c3972aaad9728682	2024-04-01 13:22:15.27044+03	20240220084932_init	\N	\N	2024-04-01 13:22:15.26773+03	1
7fb7154b-99ef-425c-b9d6-68c5114fb2fb	cff20eedaeab53a91b6bbe37d8f98579ccdaef2cac1d3e69819f4ca553e84c29	2024-04-01 13:22:15.234336+03	20240212073715_init	\N	\N	2024-04-01 13:22:15.233052+03	1
9b4d453e-daf5-4903-9a7e-8b48b8b2660e	ab2e383159e390310c7283d7798445e01da1a9f3be55f5e740a1a103b24c1211	2024-04-01 13:22:15.252368+03	20240214170817_init	\N	\N	2024-04-01 13:22:15.249056+03	1
7506a2a3-5397-46a8-a0b4-979d587ceb27	0dc56e1712cc2627ff6c212f7d2c050f912458a9db1afa4ad52d37c5fb97fd76	2024-04-01 13:22:15.235905+03	20240212075104_init	\N	\N	2024-04-01 13:22:15.234719+03	1
78da0442-91db-4138-8ba6-f5fa4e987c75	03b6766d1a3e68f2ddb73b9077dbd02bfc57b6060d955be9a2163121c2d4fb50	2024-04-01 13:22:15.253787+03	20240214174300_init	\N	\N	2024-04-01 13:22:15.252772+03	1
10bc8044-e77a-4887-8b02-ddda841b429d	93f036899128aefffcc52cd203de7bdc86431b440336a203e726bd6e7e4640ab	2024-04-01 13:22:15.257956+03	20240215092732_init	\N	\N	2024-04-01 13:22:15.254185+03	1
d41cce8d-2296-40d1-ad85-8ba38d3b0aca	60e76f2cc649ec22ab1d49d2682a57bbdc848ed71f82ed835ea2ccac1289132e	2024-04-01 13:22:15.27381+03	20240220085352_init	\N	\N	2024-04-01 13:22:15.270896+03	1
9549e772-3cab-4879-a165-02845393aab4	d7aa74aa04e518b426301307318b9703bafbef81bfd35abb668ea7b87ea43737	2024-04-01 13:22:15.26122+03	20240216124347_init	\N	\N	2024-04-01 13:22:15.258487+03	1
82c197e5-ef78-4a3f-a2f7-0bb1fb1cc477	7296e1bde7bb6726414cad2e10ba3fba89100afa608a70dcba914604241b6be6	2024-04-01 13:22:15.264222+03	20240216124527_init	\N	\N	2024-04-01 13:22:15.26176+03	1
165ca945-e037-4868-9566-327e26b2a9da	ee788d2ac973bc49a46259db6ab8077c2265c54f1ec1fa74e204adc577a6b456	2024-04-01 13:22:15.30117+03	20240220123400_init	\N	\N	2024-04-01 13:22:15.299626+03	1
cdda4fd7-8f09-4bc5-84ac-f81b24a76b59	7f5c6a8698866b2134f63d0b653ef37302c4caf5e3a14fce1d0c73ca4eab8e7b	2024-04-01 13:22:15.27591+03	20240220085632_init	\N	\N	2024-04-01 13:22:15.274352+03	1
7a3784c5-63a2-46a6-a22c-b2765026bb53	03a3bc9a4eafe57f39184592e734601fc1d6347b397f32c791809d74e553f414	2024-04-01 13:22:15.294069+03	20240220093249_init	\N	\N	2024-04-01 13:22:15.291762+03	1
92055d25-c109-4a51-90ae-4473c724e9ff	6bcba9312176f27295cf4153d295e40bb8a7ecb10a8d921c34720b8cd4fb5788	2024-04-01 13:22:15.281201+03	20240220090727_init	\N	\N	2024-04-01 13:22:15.276353+03	1
30795666-8daf-4305-8987-0d8584d795ea	a4351b023814c6c07c830d6f299c65bdcdbde4362afc57aaf0e7a2af538a3353	2024-04-01 13:22:15.283686+03	20240220091025_init	\N	\N	2024-04-01 13:22:15.281735+03	1
e019ca34-bcc0-4f3d-89c3-48b9ffbe173c	9295fb1d80436946c228c6e16fdb9260b0ded452fb07136d402f57b11a031c78	2024-04-01 13:22:15.296966+03	20240220112317_init	\N	\N	2024-04-01 13:22:15.294813+03	1
f4321e85-ed28-4d25-bc39-5bdfd4f33f40	aeaaf1d2fd2b15332503a92d0111e5c6441e0889c68dcc33d8bcfe97654d17d5	2024-04-01 13:22:15.299119+03	20240220121344_init	\N	\N	2024-04-01 13:22:15.297473+03	1
733a5a19-4b1f-4af1-9717-eef543780233	d293fa174d4e166f71a21ec28eeaa2294aaf3d6da7fd79ea9e76a0dee66dcde8	2024-04-01 13:22:15.302975+03	20240220130657_init	\N	\N	2024-04-01 13:22:15.301633+03	1
9ed584f9-ded8-4356-99ed-9dbcf59a0c77	c87440f6264f313707f131a6817c888e789a1e50cd8bb4f74da15d2c7b504ec1	2024-04-01 13:22:15.3107+03	20240220131909_init	\N	\N	2024-04-01 13:22:15.308632+03	1
ebf33891-0c77-46ab-a19f-25c1f2530530	ea9407543f9c2a29d9525b39b1ba8311d0d7c477fef543bbb33df6261512d3fb	2024-04-01 13:22:15.308153+03	20240220131838_init	\N	\N	2024-04-01 13:22:15.306601+03	1
f9ede11f-5664-49a0-ae99-848542d92683	48f8ba2191241af3103837dfb07621446116815ab5594edfabcaf9d890203721	2024-04-01 13:22:15.314697+03	20240221103250_init	\N	\N	2024-04-01 13:22:15.311275+03	1
9094f654-0e49-43a8-be4a-a5dc4f305839	5ef36795bb27e57ed21d7efcbfe868c12058a769c17d9fb67547a279e92fe985	2024-04-01 13:22:15.317062+03	20240221112252_init	\N	\N	2024-04-01 13:22:15.315121+03	1
20c9bb74-03e7-4fbc-94ac-8c14a21b6361	897cddeeeb140b1f1d53efa3a65fcbfeb509a75d69228c59aac00f1463c4c6d7	2024-04-01 13:22:15.319272+03	20240222081723_init	\N	\N	2024-04-01 13:22:15.317507+03	1
01d1b0e1-40f6-41a9-9819-15af17109046	5608940768bf3f0782a1a88fa7e562acc5a441df4492ee1ffc6126f65445c677	2024-04-01 13:22:15.322794+03	20240223084731_init	\N	\N	2024-04-01 13:22:15.319688+03	1
300a9e0f-7b6d-4eef-a52b-016dd1448a91	db351485ebdf8b230caf5ebaa0e06aebade7d44752d5a9e93d38920c28886431	2024-04-01 13:22:15.325357+03	20240223092705_init	\N	\N	2024-04-01 13:22:15.32321+03	1
8ed46654-e340-4c35-a62f-31572c3e312b	fc22fb479697bdef382d68a8698bfa2cd974efb780a8d45e6b3d2d80429d6c0e	2024-04-01 13:22:15.327394+03	20240223094441_init	\N	\N	2024-04-01 13:22:15.32589+03	1
9d64b663-44cb-4ed4-b76d-0a8b22522e33	d3aa5ee095b805d575a7b0b2a7e9ddab9736e7f153ec45c10141006c3530955d	2024-04-01 13:22:15.380376+03	20240301140900_init	\N	\N	2024-04-01 13:22:15.376126+03	1
a0d1ced3-afa4-42f7-951e-b08634fbd6af	dd0698a2369bc4d5c3c578b4ecf95f782937384ac70bbb587803de3e364cb437	2024-04-01 13:22:15.330372+03	20240223095255_init	\N	\N	2024-04-01 13:22:15.328028+03	1
6ac97b4f-38e7-4f44-80ee-152e77abdfd2	100e8efb61f7cd1373751e214d35d064dd45ef0d35cdc8f768fc298bdb15ac0a	2024-04-01 13:22:15.331981+03	20240226074024_init	\N	\N	2024-04-01 13:22:15.330833+03	1
82a0fbad-1765-45e5-87c8-875c2990fb85	993d4c7db6741eda9c4f7f0d36c0a2f6e7673c81e60335b252960a47e1e77f01	2024-04-01 13:22:15.407894+03	20240315083220_init	\N	\N	2024-04-01 13:22:15.40642+03	1
acadd8c8-2d32-4b72-bcd9-95bf646353b4	19234c0875a9738eacc57a982bd47e84d36c3a39f8b28732e53a86f41f00a6c9	2024-04-01 13:22:15.336343+03	20240226090217_init	\N	\N	2024-04-01 13:22:15.332421+03	1
bfdf6508-ca1e-4eb0-8a03-5d0c6d2b30dc	d8bb15a47b140e9c6459d0a7ab47a7e7b7b34ceedc0737c4f138dc01575ac31c	2024-04-01 13:22:15.382639+03	20240301141213_init	\N	\N	2024-04-01 13:22:15.380851+03	1
d809444c-ea89-43ef-8478-e596792db053	daf5aadcda116a4ac58165fe96cef096db3961b3f1b13965de5e191f8de6368f	2024-04-01 13:22:15.3385+03	20240226092751_init	\N	\N	2024-04-01 13:22:15.336784+03	1
f4dbf332-6909-474a-bbc7-919ab3432c05	28c8b960720b30afaae39f7374de14de0d8ddd05d1f69eaab2c5dd06f2a2ed32	2024-04-01 13:22:15.340701+03	20240226134631_init	\N	\N	2024-04-01 13:22:15.338886+03	1
f104b991-b019-4023-b3bd-efa929c5c4ce	7bb4cce50a90e6782ea1a5a2bd271412c2d469c9a5d10c86d72f2d966144788a	2024-04-01 13:22:15.343294+03	20240226173020_init	\N	\N	2024-04-01 13:22:15.34114+03	1
574cc983-291c-4292-8299-9c090e5d2021	4ca2e4f2848faec42ae0c102e6ff9edcb3cacab8226c460a14b2bb65f67f9c78	2024-04-01 13:22:15.386149+03	20240302090628_init	\N	\N	2024-04-01 13:22:15.383385+03	1
ce8fc73b-087a-4092-b924-2ffc5d799cd3	3260f67e24a4f60b89b02f77ff056c6600571c8e43d9adddf65131386e724fbc	2024-04-01 13:22:15.346316+03	20240227100539_init	\N	\N	2024-04-01 13:22:15.343764+03	1
aba9196e-fa72-4c3a-9a58-08001939d731	6d6e517933f3350b9f0d6ccdc075d7ddd873ed7504c6fc16d210e027fc4f503c	2024-04-01 13:22:15.351054+03	20240228124252_init	\N	\N	2024-04-01 13:22:15.346779+03	1
62e9fc10-29e5-4989-9a0f-7f1240df4991	f890e3cce45046ca37514f946131bfe0ddb68813f7580905b61864da28869163	2024-04-01 13:22:15.461106+03	20240329071353_init	\N	\N	2024-04-01 13:22:15.45208+03	1
f274f83b-942d-4a8e-8957-2a475167e570	91e0db8cd2dfc855cfac5f47ad7d9549d2b49fd67729dade614f14212bc69d7a	2024-04-01 13:22:15.352763+03	20240228124922_init	\N	\N	2024-04-01 13:22:15.35149+03	1
1ff9603c-9728-4fc9-af8b-42e30d05533a	aaf2fd3dc9f15d7ef6fec78cfa366d5182307a602e1f4c5cbca8bc0bdf6ab6a2	2024-04-01 13:22:15.390272+03	20240302102616_init	\N	\N	2024-04-01 13:22:15.386524+03	1
a0a66497-746c-4a8a-aac1-7cb36ede0336	55234eab3e1fff02c41e22ef4cef95b8ffb09dad1c67c771776e1b7f00e656ad	2024-04-01 13:22:15.366996+03	20240229124820_init	\N	\N	2024-04-01 13:22:15.35322+03	1
7a333b1e-1a79-4412-a8ef-4851f8ae12b7	1d378adb3194015b5b2e36f3b39d812af75d50e7438476a95e1afb0a97cc075d	2024-04-01 13:22:15.369108+03	20240229142853_init	\N	\N	2024-04-01 13:22:15.367619+03	1
bb9ed3b4-242b-4a4f-9431-253dc3c000f9	d140d32efdf50f326e29791d20eabfd4fec07fad5addeaaf2a621c21fe26e19f	2024-04-01 13:22:15.411359+03	20240316044303_init	\N	\N	2024-04-01 13:22:15.408301+03	1
8ae45f20-5113-4d6b-bda6-761525371f21	14973e7960f62f883fe593057cdfd463062a0fdc4aa5a4f08e440d31514010db	2024-04-01 13:22:15.373897+03	20240229162414_init	\N	\N	2024-04-01 13:22:15.369674+03	1
d0aff5dc-8ae0-439f-afc0-213cdc563991	013abe447e39a8e7fa0903ea9db946d642354188f052fa7e12858d3317bc75a5	2024-04-01 13:22:15.39335+03	20240302103202_init	\N	\N	2024-04-01 13:22:15.390659+03	1
77c479b1-418a-4b43-8522-d24ecc1b2d58	868b35c23537d330ffffca8cec0941d42fcf9059c176d59c14710b5b031c5a39	2024-04-01 13:22:15.375732+03	20240229163813_init	\N	\N	2024-04-01 13:22:15.374298+03	1
fb7ff38c-b492-4665-979d-1b6b9ec3a153	1bb62a5524d9d5566c634fd653d96b5278f84a73623a94e21ea44a5a7599aa31	2024-04-01 13:22:15.400531+03	20240302125237_init	\N	\N	2024-04-01 13:22:15.393731+03	1
c065166c-cd24-4136-82d5-75523b22879d	95c962c9c5d06171551475a650e1fcf2bc62251fa8b74eea43abd59f8500c034	2024-04-01 13:22:15.402558+03	20240310075259_init	\N	\N	2024-04-01 13:22:15.400963+03	1
a453e302-027d-4422-8a1f-66110dd409a5	fe0714d8e345980e2b67568cd3a1f26c73fcddc1799f7fae6777c1074687b2a8	2024-04-01 13:22:15.414253+03	20240316051345_init	\N	\N	2024-04-01 13:22:15.412008+03	1
e7611372-722c-4540-b113-7e2ffa7b1f7c	8a4ad99b03ede20eca5ec8c9c21d38099836dec415a077eb92313e9c9b7375b3	2024-04-01 13:22:15.40473+03	20240313111549_init	\N	\N	2024-04-01 13:22:15.402901+03	1
459b5699-274f-410a-a773-4e12970dc5a6	156d17d4c03d81a47f3eb8a5cecf9766cc2544022672badf2c983359da491e11	2024-04-01 13:22:15.406082+03	20240313112528_init	\N	\N	2024-04-01 13:22:15.405068+03	1
f5bf2b60-38b4-40c0-b473-5f7a35dc31a9	673e6f4dea0c5f8e68558ca16a126d2e87d5c5dc0c474752930732ac1b5a829c	2024-04-01 18:44:03.947502+03	20240401154403_init	\N	\N	2024-04-01 18:44:03.943755+03	1
3b1c3038-1455-4d0d-81f3-3556a6cb9a7e	2635b01e7f4c31f0f5345ca2c3ee2107321ea53d923e10e8325442a16339abc6	2024-04-01 13:22:15.420518+03	20240319062450_init	\N	\N	2024-04-01 13:22:15.414998+03	1
534f5ca7-2a70-40ca-ba6f-258fb94b2711	c88614186fcd95b579bfa9400af9a5321bf9e7260f737773ed6725049d76b042	2024-04-01 13:22:15.502453+03	20240401093739_init	\N	\N	2024-04-01 13:22:15.462094+03	1
16b058e3-f68d-4b32-8f0d-de9ef042f149	124d94dfdfba46094876f7c25f517409447f25768c44aa45001143300b74022f	2024-04-01 13:22:15.44222+03	20240327101254_init	\N	\N	2024-04-01 13:22:15.421133+03	1
3dd7a85a-165f-4ac3-b27d-9ada28d6031d	6e012447ca56175ea00b468e234703d7de1151ee243e1f1882932d825dad47b2	2024-04-01 13:22:15.450518+03	20240327165257_init	\N	\N	2024-04-01 13:22:15.443162+03	1
2b022980-1449-478d-894d-fdfee089c0a4	e0e397caf16b5b5dbf444d56cfbecfb88a11d9b00c09aa4ff0ecad12d6f9d9af	2024-04-01 17:34:54.039604+03	20240401143454_init	\N	\N	2024-04-01 17:34:54.034994+03	1
f349dc78-8f08-48e8-8a30-78f152a365a5	287dc725f801ce5457bbae2dec456ccd669f728b7d6d7004cc6b22fe51e16751	2024-04-01 13:22:17.133296+03	20240401102217_init	\N	\N	2024-04-01 13:22:17.131004+03	1
61579711-8fab-4c6b-95f6-60cdddd507e4	a4f15f98d61bd23bf3354499d404e48395cbbfcc0fd44b25a1c166478e380d81	2024-04-01 14:39:26.654999+03	20240401113926_init	\N	\N	2024-04-01 14:39:26.651253+03	1
e29d2c7c-1892-461c-bf49-b35ca9a952ad	aa9eb51089bcd7cad662f014412029db05ff49fdbd395eb45d8b332aa8f1b09b	2024-04-01 17:38:38.801228+03	20240401143838_init	\N	\N	2024-04-01 17:38:38.643454+03	1
f95ab990-cffc-4293-badb-8c449ef4c8e5	3c9d186059ba36aa1a076a9b226e5fbeede5378e229f15a749b777e1bce99ae7	2024-04-02 16:19:31.565836+03	20240402131931_init	\N	\N	2024-04-02 16:19:31.559383+03	1
71f8215a-41cc-451c-83d9-d978ddedb2e6	9691c15d9916ca37cecaac555eb7ecd529050f69b847ac55c46f6f515f1e500d	2024-04-01 19:19:41.240418+03	20240401161941_init	\N	\N	2024-04-01 19:19:41.215351+03	1
b90d820d-9d49-437f-b50d-aa908a1bb806	e8b88188bd187cd9145804a0b0f58f870cf7d6b2a890c7e8f67fa26e8f7c4a91	2024-04-02 16:51:07.40196+03	20240402135107_init	\N	\N	2024-04-02 16:51:07.395386+03	1
95e34c5d-c4cf-4476-949d-7b361d060b46	516491528340768b832068f77cf89dac2118d80dbcaedf410d9448a393b06786	2024-04-03 11:56:25.87163+03	20240403085625_init	\N	\N	2024-04-03 11:56:25.8422+03	1
fad8887b-d061-4f9c-928f-b186338d878c	d7da15ec33e34151f7145a47bdec0b848cc216a4c863983fde9ab4ac1807bed2	2024-04-09 11:07:38.561721+03	20240409080738_init	\N	\N	2024-04-09 11:07:38.507615+03	1
3d727c5b-2975-466f-b3d4-4ed26671c424	930fbf76a69808284f96a22d2b1dfa5ae1c9c8d094fc46b6888ebe34b353978e	2024-04-26 13:23:22.985675+03	20240426102322_init	\N	\N	2024-04-26 13:23:22.974571+03	1
2ac1a0bf-127c-47b8-9fa3-bebe17ffe190	71ac49f7b69fcd70ccc8aeb539f66979033fe4f73b69fda665ddf345be5a2ab7	2024-04-29 10:20:37.042305+03	20240429072037_init	\N	\N	2024-04-29 10:20:37.03707+03	1
069df26f-f429-4de9-8456-bd5b47521fa5	e11c05790dd638077bdec7a82621a2506a522d50de08acf6b6e82484558be795	2024-04-30 07:19:06.272191+03	20240430041906_init	\N	\N	2024-04-30 07:19:06.259645+03	1
5278834f-5a17-4437-9a31-8f23e91bae39	ff0742a15ea3b269af99b138d5504083225e87397c2ee5e2657008216d87945c	2024-05-06 10:23:10.140413+03	20240506072310_init	\N	\N	2024-05-06 10:23:10.118457+03	1
ac6903a7-a93e-41c4-9714-2375f558f0a6	7d62796421b0b614fa4f8d07ec149c6f0e60cc44bbf2859819bc148d3154cc01	2024-05-06 11:10:36.109544+03	20240506081036_init	\N	\N	2024-05-06 11:10:36.103716+03	1
6550e0c2-ad4a-4065-9a8e-ba0a975fb04a	30554d5f52a0366e49d149fc377e3e42f7d6b268f9076b410aace2b1b77a4f97	2024-05-06 12:56:03.79194+03	20240506095603_init	\N	\N	2024-05-06 12:56:03.786677+03	1
ffcce4da-0c50-4505-b639-e45172efcfd2	b01ba1c379a15ba6d94f898b7b814ef3622cf7048e62b5f1b99f01ed1de068a6	2024-05-07 09:12:55.91106+03	20240507061255_init	\N	\N	2024-05-07 09:12:55.88983+03	1
57852738-c61f-47bb-970e-a92c857942e9	f45c055c5d43c3fa002d74340d4453578983d1073602a56876d6407e90efd510	2024-05-07 09:20:17.733362+03	20240507062017_init	\N	\N	2024-05-07 09:20:17.730258+03	1
65a36b57-9021-493d-92e7-34e5a0961060	c25bac8442a32b22e8793a9013aa407b6abd03262b340799718fb58a495a7013	2024-05-07 11:21:44.880063+03	20240507082144_init	\N	\N	2024-05-07 11:21:44.874153+03	1
2c1ff3c4-6aae-47ac-bc2e-63df2a1cb999	3b1b7f0dcd8432c379941f75454836bb40c2e633f8f67216ca1047ed61a7985e	2024-05-07 11:32:53.324959+03	20240507083253_init	\N	\N	2024-05-07 11:32:53.319869+03	1
7120dade-925e-4ff8-8828-f7dc0223059a	dea441fc20c58619ca191707a46190c2811e759aedb53f8281c8e9f34eca610e	2024-05-07 12:01:35.317556+03	20240507090135_init	\N	\N	2024-05-07 12:01:35.298158+03	1
8761e175-6b0d-4dcb-8e1f-bf508cd0921a	a66e928a6834856b7bb24932cd4c96ea8f6a6504b1ba414fefce2e77f4fcdf09	2024-05-07 12:17:08.862248+03	20240507091708_init	\N	\N	2024-05-07 12:17:08.855049+03	1
287fe808-5867-40e9-a311-28f09ce520a0	51305ce39116e6dd740243d1435591af00ebd78de1f8f74e4b44e28771f18ee5	2024-05-09 11:28:59.638361+03	20240509082859_init	\N	\N	2024-05-09 11:28:59.634196+03	1
\.


--
-- Name: Address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Address_id_seq"', 3, true);


--
-- Name: AlertsHistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."AlertsHistory_id_seq"', 260, true);


--
-- Name: Alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Alerts_id_seq"', 2, true);


--
-- Name: Bank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Bank_id_seq"', 32, true);


--
-- Name: Banks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Banks_id_seq"', 3, true);


--
-- Name: BillingFrequency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."BillingFrequency_id_seq"', 7, true);


--
-- Name: Cashflow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Cashflow_id_seq"', 29, true);


--
-- Name: Category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Category_id_seq"', 3, true);


--
-- Name: ContractAlertSchedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractAlertSchedule_id_seq"', 116, true);


--
-- Name: ContractAttachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractAttachments_id_seq"', 18, true);


--
-- Name: ContractContent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractContent_id_seq"', 15, true);


--
-- Name: ContractDynamicFields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractDynamicFields_id_seq"', 58, true);


--
-- Name: ContractFinancialDetailSchedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractFinancialDetailSchedule_id_seq"', 526, true);


--
-- Name: ContractFinancialDetail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractFinancialDetail_id_seq"', 57, true);


--
-- Name: ContractItems_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractItems_id_seq"', 92, true);


--
-- Name: ContractStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractStatus_id_seq"', 13, true);


--
-- Name: ContractTasksDueDates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTasksDueDates_id_seq"', 6, true);


--
-- Name: ContractTasksPriority_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTasksPriority_id_seq"', 3, true);


--
-- Name: ContractTasksReminders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTasksReminders_id_seq"', 6, true);


--
-- Name: ContractTasksStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTasksStatus_id_seq"', 2, true);


--
-- Name: ContractTasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTasks_id_seq"', 61, true);


--
-- Name: ContractTemplates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTemplates_id_seq"', 1, true);


--
-- Name: ContractType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractType_id_seq"', 32, true);


--
-- Name: ContractsAudit_auditid_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractsAudit_auditid_seq"', 206, true);


--
-- Name: Contracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Contracts_id_seq"', 72, true);


--
-- Name: CostCenter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."CostCenter_id_seq"', 46, true);


--
-- Name: Currency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Currency_id_seq"', 29, true);


--
-- Name: Department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Department_id_seq"', 3, true);


--
-- Name: DynamicFields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."DynamicFields_id_seq"', 5, true);


--
-- Name: ExchangeRates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ExchangeRates_id_seq"', 864, true);


--
-- Name: Groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Groups_id_seq"', 3, true);


--
-- Name: Item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Item_id_seq"', 2, true);


--
-- Name: Location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Location_id_seq"', 4, true);


--
-- Name: MeasuringUnit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."MeasuringUnit_id_seq"', 31, true);


--
-- Name: Partners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Partners_id_seq"', 5, true);


--
-- Name: PaymentType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."PaymentType_id_seq"', 10, true);


--
-- Name: Persons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Persons_id_seq"', 3, true);


--
-- Name: Role_User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Role_User_id_seq"', 24, true);


--
-- Name: Role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Role_id_seq"', 4, true);


--
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."User_id_seq"', 5, true);


--
-- Name: WorkFlowContractTasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowContractTasks_id_seq"', 904, true);


--
-- Name: WorkFlowRejectActions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowRejectActions_id_seq"', 1, false);


--
-- Name: WorkFlowRules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowRules_id_seq"', 233, true);


--
-- Name: WorkFlowTaskSettingsUsers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowTaskSettingsUsers_id_seq"', 162, true);


--
-- Name: WorkFlowTaskSettings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowTaskSettings_id_seq"', 71, true);


--
-- Name: WorkFlowXContracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowXContracts_id_seq"', 736, true);


--
-- Name: WorkFlow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlow_id_seq"', 144, true);


--
-- Name: Address Address_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Address"
    ADD CONSTRAINT "Address_pkey" PRIMARY KEY (id);


--
-- Name: AlertsHistory AlertsHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."AlertsHistory"
    ADD CONSTRAINT "AlertsHistory_pkey" PRIMARY KEY (id);


--
-- Name: Alerts Alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Alerts"
    ADD CONSTRAINT "Alerts_pkey" PRIMARY KEY (id);


--
-- Name: Bank Bank_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Bank"
    ADD CONSTRAINT "Bank_pkey" PRIMARY KEY (id);


--
-- Name: Banks Banks_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Banks"
    ADD CONSTRAINT "Banks_pkey" PRIMARY KEY (id);


--
-- Name: BillingFrequency BillingFrequency_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."BillingFrequency"
    ADD CONSTRAINT "BillingFrequency_pkey" PRIMARY KEY (id);


--
-- Name: Cashflow Cashflow_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Cashflow"
    ADD CONSTRAINT "Cashflow_pkey" PRIMARY KEY (id);


--
-- Name: Category Category_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "Category_pkey" PRIMARY KEY (id);


--
-- Name: ContractAlertSchedule ContractAlertSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractAlertSchedule"
    ADD CONSTRAINT "ContractAlertSchedule_pkey" PRIMARY KEY (id);


--
-- Name: ContractAttachments ContractAttachments_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractAttachments"
    ADD CONSTRAINT "ContractAttachments_pkey" PRIMARY KEY (id);


--
-- Name: ContractContent ContractContent_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractContent"
    ADD CONSTRAINT "ContractContent_pkey" PRIMARY KEY (id);


--
-- Name: ContractDynamicFields ContractDynamicFields_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractDynamicFields"
    ADD CONSTRAINT "ContractDynamicFields_pkey" PRIMARY KEY (id);


--
-- Name: ContractFinancialDetailSchedule ContractFinancialDetailSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetailSchedule"
    ADD CONSTRAINT "ContractFinancialDetailSchedule_pkey" PRIMARY KEY (id);


--
-- Name: ContractFinancialDetail ContractFinancialDetail_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_pkey" PRIMARY KEY (id);


--
-- Name: ContractItems ContractItems_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractItems"
    ADD CONSTRAINT "ContractItems_pkey" PRIMARY KEY (id);


--
-- Name: ContractStatus ContractStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractStatus"
    ADD CONSTRAINT "ContractStatus_pkey" PRIMARY KEY (id);


--
-- Name: ContractTasksDueDates ContractTasksDueDates_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasksDueDates"
    ADD CONSTRAINT "ContractTasksDueDates_pkey" PRIMARY KEY (id);


--
-- Name: ContractTasksPriority ContractTasksPriority_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasksPriority"
    ADD CONSTRAINT "ContractTasksPriority_pkey" PRIMARY KEY (id);


--
-- Name: ContractTasksReminders ContractTasksReminders_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasksReminders"
    ADD CONSTRAINT "ContractTasksReminders_pkey" PRIMARY KEY (id);


--
-- Name: ContractTasksStatus ContractTasksStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasksStatus"
    ADD CONSTRAINT "ContractTasksStatus_pkey" PRIMARY KEY (id);


--
-- Name: ContractTasks ContractTasks_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasks"
    ADD CONSTRAINT "ContractTasks_pkey" PRIMARY KEY (id);


--
-- Name: ContractTemplates ContractTemplates_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTemplates"
    ADD CONSTRAINT "ContractTemplates_pkey" PRIMARY KEY (id);


--
-- Name: ContractType ContractType_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractType"
    ADD CONSTRAINT "ContractType_pkey" PRIMARY KEY (id);


--
-- Name: ContractsAudit ContractsAudit_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractsAudit"
    ADD CONSTRAINT "ContractsAudit_pkey" PRIMARY KEY (auditid);


--
-- Name: Contracts Contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_pkey" PRIMARY KEY (id);


--
-- Name: CostCenter CostCenter_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."CostCenter"
    ADD CONSTRAINT "CostCenter_pkey" PRIMARY KEY (id);


--
-- Name: Currency Currency_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Currency"
    ADD CONSTRAINT "Currency_pkey" PRIMARY KEY (id);


--
-- Name: Department Department_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Department"
    ADD CONSTRAINT "Department_pkey" PRIMARY KEY (id);


--
-- Name: DynamicFields DynamicFields_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."DynamicFields"
    ADD CONSTRAINT "DynamicFields_pkey" PRIMARY KEY (id);


--
-- Name: ExchangeRates ExchangeRates_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ExchangeRates"
    ADD CONSTRAINT "ExchangeRates_pkey" PRIMARY KEY (id);


--
-- Name: Groups Groups_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Groups"
    ADD CONSTRAINT "Groups_pkey" PRIMARY KEY (id);


--
-- Name: Item Item_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Item"
    ADD CONSTRAINT "Item_pkey" PRIMARY KEY (id);


--
-- Name: Location Location_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Location"
    ADD CONSTRAINT "Location_pkey" PRIMARY KEY (id);


--
-- Name: MeasuringUnit MeasuringUnit_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."MeasuringUnit"
    ADD CONSTRAINT "MeasuringUnit_pkey" PRIMARY KEY (id);


--
-- Name: Partners Partners_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Partners"
    ADD CONSTRAINT "Partners_pkey" PRIMARY KEY (id);


--
-- Name: PaymentType PaymentType_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."PaymentType"
    ADD CONSTRAINT "PaymentType_pkey" PRIMARY KEY (id);


--
-- Name: Persons Persons_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Persons"
    ADD CONSTRAINT "Persons_pkey" PRIMARY KEY (id);


--
-- Name: Role_User Role_User_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Role_User"
    ADD CONSTRAINT "Role_User_pkey" PRIMARY KEY (id);


--
-- Name: Role Role_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: WorkFlowContractTasks WorkFlowContractTasks_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowContractTasks"
    ADD CONSTRAINT "WorkFlowContractTasks_pkey" PRIMARY KEY (id);


--
-- Name: WorkFlowRejectActions WorkFlowRejectActions_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowRejectActions"
    ADD CONSTRAINT "WorkFlowRejectActions_pkey" PRIMARY KEY (id);


--
-- Name: WorkFlowRules WorkFlowRules_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowRules"
    ADD CONSTRAINT "WorkFlowRules_pkey" PRIMARY KEY (id);


--
-- Name: WorkFlowTaskSettingsUsers WorkFlowTaskSettingsUsers_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettingsUsers"
    ADD CONSTRAINT "WorkFlowTaskSettingsUsers_pkey" PRIMARY KEY (id);


--
-- Name: WorkFlowTaskSettings WorkFlowTaskSettings_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettings"
    ADD CONSTRAINT "WorkFlowTaskSettings_pkey" PRIMARY KEY (id);


--
-- Name: WorkFlowXContracts WorkFlowXContracts_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowXContracts"
    ADD CONSTRAINT "WorkFlowXContracts_pkey" PRIMARY KEY (id);


--
-- Name: WorkFlow WorkFlow_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlow"
    ADD CONSTRAINT "WorkFlow_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Bank_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Bank_name_key" ON public."Bank" USING btree (name);


--
-- Name: BillingFrequency_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "BillingFrequency_name_key" ON public."BillingFrequency" USING btree (name);


--
-- Name: Cashflow_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Cashflow_name_key" ON public."Cashflow" USING btree (name);


--
-- Name: Category_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Category_name_key" ON public."Category" USING btree (name);


--
-- Name: ContractContent_contractId_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "ContractContent_contractId_key" ON public."ContractContent" USING btree ("contractId");


--
-- Name: ContractStatus_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "ContractStatus_name_key" ON public."ContractStatus" USING btree (name);


--
-- Name: ContractTasksDueDates_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "ContractTasksDueDates_name_key" ON public."ContractTasksDueDates" USING btree (name);


--
-- Name: ContractTasksPriority_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "ContractTasksPriority_name_key" ON public."ContractTasksPriority" USING btree (name);


--
-- Name: ContractTasksReminders_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "ContractTasksReminders_name_key" ON public."ContractTasksReminders" USING btree (name);


--
-- Name: ContractTasksStatus_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "ContractTasksStatus_name_key" ON public."ContractTasksStatus" USING btree (name);


--
-- Name: CostCenter_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "CostCenter_name_key" ON public."CostCenter" USING btree (name);


--
-- Name: Currency_code_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Currency_code_key" ON public."Currency" USING btree (code);


--
-- Name: Currency_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Currency_name_key" ON public."Currency" USING btree (name);


--
-- Name: Department_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Department_name_key" ON public."Department" USING btree (name);


--
-- Name: DynamicFields_fieldname_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "DynamicFields_fieldname_key" ON public."DynamicFields" USING btree (fieldname);


--
-- Name: DynamicFields_fieldorder_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "DynamicFields_fieldorder_key" ON public."DynamicFields" USING btree (fieldorder);


--
-- Name: Item_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Item_name_key" ON public."Item" USING btree (name);


--
-- Name: Location_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Location_name_key" ON public."Location" USING btree (name);


--
-- Name: Partners_commercial_reg_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Partners_commercial_reg_key" ON public."Partners" USING btree (commercial_reg);


--
-- Name: Partners_fiscal_code_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Partners_fiscal_code_key" ON public."Partners" USING btree (fiscal_code);


--
-- Name: Partners_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Partners_name_key" ON public."Partners" USING btree (name);


--
-- Name: PaymentType_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "PaymentType_name_key" ON public."PaymentType" USING btree (name);


--
-- Name: Persons_email_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Persons_email_key" ON public."Persons" USING btree (email);


--
-- Name: Persons_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "Persons_name_key" ON public."Persons" USING btree (name);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "User_name_key" ON public."User" USING btree (name);


--
-- Name: _GroupsToPartners_AB_unique; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "_GroupsToPartners_AB_unique" ON public."_GroupsToPartners" USING btree ("A", "B");


--
-- Name: _GroupsToPartners_B_index; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE INDEX "_GroupsToPartners_B_index" ON public."_GroupsToPartners" USING btree ("B");


--
-- Name: _GroupsToUser_AB_unique; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "_GroupsToUser_AB_unique" ON public."_GroupsToUser" USING btree ("A", "B");


--
-- Name: _GroupsToUser_B_index; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE INDEX "_GroupsToUser_B_index" ON public."_GroupsToUser" USING btree ("B");


--
-- Name: Address Address_partnerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Address"
    ADD CONSTRAINT "Address_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES public."Partners"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Banks Banks_partnerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Banks"
    ADD CONSTRAINT "Banks_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES public."Partners"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContractAttachments ContractAttachments_contractId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractAttachments"
    ADD CONSTRAINT "ContractAttachments_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES public."Contracts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractContent ContractContent_contractId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractContent"
    ADD CONSTRAINT "ContractContent_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES public."Contracts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractDynamicFields ContractDynamicFields_contractId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractDynamicFields"
    ADD CONSTRAINT "ContractDynamicFields_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES public."Contracts"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractFinancialDetailSchedule ContractFinancialDetailSchedule_contractfinancialItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetailSchedule"
    ADD CONSTRAINT "ContractFinancialDetailSchedule_contractfinancialItemId_fkey" FOREIGN KEY ("contractfinancialItemId") REFERENCES public."ContractFinancialDetail"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContractFinancialDetailSchedule ContractFinancialDetailSchedule_currencyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetailSchedule"
    ADD CONSTRAINT "ContractFinancialDetailSchedule_currencyid_fkey" FOREIGN KEY (currencyid) REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractFinancialDetailSchedule ContractFinancialDetailSchedule_itemid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetailSchedule"
    ADD CONSTRAINT "ContractFinancialDetailSchedule_itemid_fkey" FOREIGN KEY (itemid) REFERENCES public."Item"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractFinancialDetailSchedule ContractFinancialDetailSchedule_measuringUnitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetailSchedule"
    ADD CONSTRAINT "ContractFinancialDetailSchedule_measuringUnitid_fkey" FOREIGN KEY ("measuringUnitid") REFERENCES public."MeasuringUnit"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractFinancialDetail ContractFinancialDetail_contractItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_contractItemId_fkey" FOREIGN KEY ("contractItemId") REFERENCES public."ContractItems"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContractFinancialDetail ContractFinancialDetail_currencyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_currencyid_fkey" FOREIGN KEY (currencyid) REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractFinancialDetail ContractFinancialDetail_goodexecutionLetterBankId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_goodexecutionLetterBankId_fkey" FOREIGN KEY ("goodexecutionLetterBankId") REFERENCES public."Bank"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContractFinancialDetail ContractFinancialDetail_goodexecutionLetterCurrencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_goodexecutionLetterCurrencyId_fkey" FOREIGN KEY ("goodexecutionLetterCurrencyId") REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractFinancialDetail ContractFinancialDetail_guaranteeLetterBankId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_guaranteeLetterBankId_fkey" FOREIGN KEY ("guaranteeLetterBankId") REFERENCES public."Bank"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContractFinancialDetail ContractFinancialDetail_guaranteeLetterCurrencyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_guaranteeLetterCurrencyid_fkey" FOREIGN KEY ("guaranteeLetterCurrencyid") REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractFinancialDetail ContractFinancialDetail_measuringUnitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_measuringUnitid_fkey" FOREIGN KEY ("measuringUnitid") REFERENCES public."MeasuringUnit"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractFinancialDetail ContractFinancialDetail_paymentTypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractFinancialDetail"
    ADD CONSTRAINT "ContractFinancialDetail_paymentTypeid_fkey" FOREIGN KEY ("paymentTypeid") REFERENCES public."PaymentType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ContractItems ContractItems_billingFrequencyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractItems"
    ADD CONSTRAINT "ContractItems_billingFrequencyid_fkey" FOREIGN KEY ("billingFrequencyid") REFERENCES public."BillingFrequency"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractItems ContractItems_contractId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractItems"
    ADD CONSTRAINT "ContractItems_contractId_fkey" FOREIGN KEY ("contractId") REFERENCES public."Contracts"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractItems ContractItems_currencyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractItems"
    ADD CONSTRAINT "ContractItems_currencyid_fkey" FOREIGN KEY (currencyid) REFERENCES public."Currency"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractItems ContractItems_itemid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractItems"
    ADD CONSTRAINT "ContractItems_itemid_fkey" FOREIGN KEY (itemid) REFERENCES public."Item"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractTasks ContractTasks_assignedId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasks"
    ADD CONSTRAINT "ContractTasks_assignedId_fkey" FOREIGN KEY ("assignedId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractTasks ContractTasks_requestorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasks"
    ADD CONSTRAINT "ContractTasks_requestorId_fkey" FOREIGN KEY ("requestorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractTasks ContractTasks_statusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasks"
    ADD CONSTRAINT "ContractTasks_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES public."ContractTasksStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractTasks ContractTasks_taskPriorityId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTasks"
    ADD CONSTRAINT "ContractTasks_taskPriorityId_fkey" FOREIGN KEY ("taskPriorityId") REFERENCES public."ContractTasksPriority"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ContractTemplates ContractTemplates_contractTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractTemplates"
    ADD CONSTRAINT "ContractTemplates_contractTypeId_fkey" FOREIGN KEY ("contractTypeId") REFERENCES public."ContractType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_cashflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_cashflowId_fkey" FOREIGN KEY ("cashflowId") REFERENCES public."Cashflow"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public."Category"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_costcenterId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_costcenterId_fkey" FOREIGN KEY ("costcenterId") REFERENCES public."CostCenter"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Contracts Contracts_departmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES public."Department"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_entityId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_entityId_fkey" FOREIGN KEY ("entityId") REFERENCES public."Partners"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Contracts Contracts_entityaddressId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_entityaddressId_fkey" FOREIGN KEY ("entityaddressId") REFERENCES public."Address"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_entitybankId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_entitybankId_fkey" FOREIGN KEY ("entitybankId") REFERENCES public."Banks"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_entitypersonsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_entitypersonsId_fkey" FOREIGN KEY ("entitypersonsId") REFERENCES public."Persons"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_locationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES public."Location"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_partneraddressId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_partneraddressId_fkey" FOREIGN KEY ("partneraddressId") REFERENCES public."Address"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_partnerbankId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_partnerbankId_fkey" FOREIGN KEY ("partnerbankId") REFERENCES public."Banks"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_partnerpersonsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_partnerpersonsId_fkey" FOREIGN KEY ("partnerpersonsId") REFERENCES public."Persons"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_partnersId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_partnersId_fkey" FOREIGN KEY ("partnersId") REFERENCES public."Partners"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Contracts Contracts_paymentTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_paymentTypeId_fkey" FOREIGN KEY ("paymentTypeId") REFERENCES public."PaymentType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Contracts Contracts_statusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES public."ContractStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Contracts Contracts_typeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES public."ContractType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Contracts Contracts_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Persons Persons_partnerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Persons"
    ADD CONSTRAINT "Persons_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES public."Partners"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Role_User Role_User_roleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Role_User"
    ADD CONSTRAINT "Role_User_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Role_User Role_User_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Role_User"
    ADD CONSTRAINT "Role_User_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: WorkFlowContractTasks WorkFlowContractTasks_assignedId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowContractTasks"
    ADD CONSTRAINT "WorkFlowContractTasks_assignedId_fkey" FOREIGN KEY ("assignedId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowContractTasks WorkFlowContractTasks_requestorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowContractTasks"
    ADD CONSTRAINT "WorkFlowContractTasks_requestorId_fkey" FOREIGN KEY ("requestorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowContractTasks WorkFlowContractTasks_statusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowContractTasks"
    ADD CONSTRAINT "WorkFlowContractTasks_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES public."ContractTasksStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowContractTasks WorkFlowContractTasks_taskPriorityId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowContractTasks"
    ADD CONSTRAINT "WorkFlowContractTasks_taskPriorityId_fkey" FOREIGN KEY ("taskPriorityId") REFERENCES public."ContractTasksPriority"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowContractTasks WorkFlowContractTasks_workflowTaskSettingsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowContractTasks"
    ADD CONSTRAINT "WorkFlowContractTasks_workflowTaskSettingsId_fkey" FOREIGN KEY ("workflowTaskSettingsId") REFERENCES public."WorkFlowTaskSettings"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowRejectActions WorkFlowRejectActions_workflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowRejectActions"
    ADD CONSTRAINT "WorkFlowRejectActions_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES public."WorkFlow"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowRules WorkFlowRules_workflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowRules"
    ADD CONSTRAINT "WorkFlowRules_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES public."WorkFlow"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowTaskSettingsUsers WorkFlowTaskSettingsUsers_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettingsUsers"
    ADD CONSTRAINT "WorkFlowTaskSettingsUsers_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowTaskSettingsUsers WorkFlowTaskSettingsUsers_workflowTaskSettingsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettingsUsers"
    ADD CONSTRAINT "WorkFlowTaskSettingsUsers_workflowTaskSettingsId_fkey" FOREIGN KEY ("workflowTaskSettingsId") REFERENCES public."WorkFlowTaskSettings"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowTaskSettings WorkFlowTaskSettings_taskDueDateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettings"
    ADD CONSTRAINT "WorkFlowTaskSettings_taskDueDateId_fkey" FOREIGN KEY ("taskDueDateId") REFERENCES public."ContractTasksDueDates"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowTaskSettings WorkFlowTaskSettings_taskPriorityId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettings"
    ADD CONSTRAINT "WorkFlowTaskSettings_taskPriorityId_fkey" FOREIGN KEY ("taskPriorityId") REFERENCES public."ContractTasksPriority"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowTaskSettings WorkFlowTaskSettings_taskReminderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettings"
    ADD CONSTRAINT "WorkFlowTaskSettings_taskReminderId_fkey" FOREIGN KEY ("taskReminderId") REFERENCES public."ContractTasksReminders"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowTaskSettings WorkFlowTaskSettings_workflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowTaskSettings"
    ADD CONSTRAINT "WorkFlowTaskSettings_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES public."WorkFlow"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowXContracts WorkFlowXContracts_ctrstatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowXContracts"
    ADD CONSTRAINT "WorkFlowXContracts_ctrstatusId_fkey" FOREIGN KEY ("ctrstatusId") REFERENCES public."ContractStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowXContracts WorkFlowXContracts_wfstatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowXContracts"
    ADD CONSTRAINT "WorkFlowXContracts_wfstatusId_fkey" FOREIGN KEY ("wfstatusId") REFERENCES public."ContractTasksStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: WorkFlowXContracts WorkFlowXContracts_workflowTaskSettingsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."WorkFlowXContracts"
    ADD CONSTRAINT "WorkFlowXContracts_workflowTaskSettingsId_fkey" FOREIGN KEY ("workflowTaskSettingsId") REFERENCES public."WorkFlowTaskSettings"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: _GroupsToPartners _GroupsToPartners_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."_GroupsToPartners"
    ADD CONSTRAINT "_GroupsToPartners_A_fkey" FOREIGN KEY ("A") REFERENCES public."Groups"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _GroupsToPartners _GroupsToPartners_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."_GroupsToPartners"
    ADD CONSTRAINT "_GroupsToPartners_B_fkey" FOREIGN KEY ("B") REFERENCES public."Partners"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _GroupsToUser _GroupsToUser_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."_GroupsToUser"
    ADD CONSTRAINT "_GroupsToUser_A_fkey" FOREIGN KEY ("A") REFERENCES public."Groups"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _GroupsToUser _GroupsToUser_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."_GroupsToUser"
    ADD CONSTRAINT "_GroupsToUser_B_fkey" FOREIGN KEY ("B") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: sysadmin
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

