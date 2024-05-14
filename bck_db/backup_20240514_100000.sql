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
-- Name: active_wf_rulesok(); Type: FUNCTION; Schema: public; Owner: sysadmin
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


select * from public.active_wf_rulesok();

END;
$$;


ALTER FUNCTION public.active_wf_rulesok() OWNER TO sysadmin;

--
-- Name: calculate_cashflow_func(); Type: FUNCTION; Schema: public; Owner: sysadmin
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


ALTER FUNCTION public.calculate_cashflow_func() OWNER TO sysadmin;

--
-- Name: contracttasktobegenerated(); Type: FUNCTION; Schema: public; Owner: sysadmin
--

CREATE FUNCTION public.contracttasktobegenerated() RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, approvedbyall boolean, approvaltypeinparallel boolean, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean)
    LANGUAGE plpgsql ROWS 10000
    AS $$
    BEGIN
   RETURN QUERY

select wfts."taskName", wfts."taskNotes", wfx."contractId",
        1 as statusId, 3 as requestorId, wftsu."userId" as assignedId,
        wfts."approvedByAll", wfts."approvalTypeInParallel",
        wfts.id as workflowTaskSettingsId, uuid_generate_v4() as Uuid,
        wftsu."approvalOrderNumber" as approvalOrderNumber,
        wfts."workflowId", ctp."name" as PriorityName, wfts."taskPriorityId" PriorityId, ctr.name ReminderName,
        ctr."days" as ReminderDays,
        ctdd."name" as DueDate,
        ctdd."days" as DueDateDays,
        CURRENT_DATE:: DATE + CONCAT(ctdd."days", ' day'):: INTERVAL as CalculatedDueDate,
        (CURRENT_DATE:: DATE + CONCAT(ctdd."days", ' day')::INTERVAL):: DATE
        + CONCAT(ctr."days", ' day')::INTERVAL AS CalculatedReminderDate,
        wfts."taskSendNotifications", wfts."taskSendReminders"
        from public."WorkFlowXContracts" wfx 
        join public."Contracts" c  on wfx."contractId" = c.id 
        join "WorkFlowTaskSettings" wfts on wfts.id = wfx."workflowTaskSettingsId" 
        join "WorkFlowTaskSettingsUsers" wftsu  on wftsu."workflowTaskSettingsId" = wfts.id 
        join "ContractTasksStatus" cts on cts.id = wfx."ctrstatusId" 
        join "ContractStatus" cs  on cs.id = wfx."ctrstatusId" 
        left join "ContractTasksPriority" ctp on ctp.id = wfts."taskPriorityId" 
        left join "ContractTasksReminders" ctr on ctr.id = wfts."taskReminderId" 
        left join "ContractTasksDueDates" ctdd on ctdd.id = wfts."taskDueDateId"
        where wfx."ctrstatusId" <>2;

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
        CURRENT_DATE:: DATE + CONCAT(ctdd."days", ' day')::INTERVAL AS CalculatedDueDate,
        (CURRENT_DATE:: DATE + CONCAT(ctdd."days", ' day')::INTERVAL):: DATE + CONCAT(ctr."days", ' day')::INTERVAL AS CalculatedReminderDate,
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
        LEFT JOIN "WorkFlowContractTasks" wfct ON wfct."contractId" = c.id 
        AND wfct."approvalOrderNumber" = wftsu."approvalOrderNumber" 
        AND wfct."workflowTaskSettingsId" = wfx."workflowTaskSettingsId";
        END;
        $$;


ALTER FUNCTION public.cttobegeneratedsecv() OWNER TO sysadmin;

--
-- Name: get_contract_details(); Type: FUNCTION; Schema: public; Owner: sysadmin
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


ALTER FUNCTION public.get_contract_details() OWNER TO sysadmin;

--
-- Name: getauditcontract(integer); Type: FUNCTION; Schema: public; Owner: sysadmin
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


ALTER FUNCTION public.getauditcontract(contractid integer) OWNER TO sysadmin;

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
            WITH duplicates AS(
                SELECT "contractId", wf."workflowTaskSettingsId", MAX("id") AS max_id
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
-- Name: ContractWFStatus; Type: TABLE; Schema: public; Owner: sysadmin
--

CREATE TABLE public."ContractWFStatus" (
    id integer NOT NULL,
    name text NOT NULL,
    "Desription" text DEFAULT ''::text NOT NULL
);


ALTER TABLE public."ContractWFStatus" OWNER TO sysadmin;

--
-- Name: ContractWFStatus_id_seq; Type: SEQUENCE; Schema: public; Owner: sysadmin
--

CREATE SEQUENCE public."ContractWFStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ContractWFStatus_id_seq" OWNER TO sysadmin;

--
-- Name: ContractWFStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysadmin
--

ALTER SEQUENCE public."ContractWFStatus_id_seq" OWNED BY public."ContractWFStatus".id;


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
    "locationId" integer,
    "statusWFId" integer DEFAULT 1
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
    "statusId" integer DEFAULT 1,
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
    "locationId" integer,
    "statusWFId" integer DEFAULT 1
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
-- Name: ContractWFStatus id; Type: DEFAULT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractWFStatus" ALTER COLUMN id SET DEFAULT nextval('public."ContractWFStatus_id_seq"'::regclass);


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
1	2024-05-13 13:12:07.672	2024-05-13 13:12:07.672	Dragon	Adresa Comerciala	Romania	Ilfov	Dobroeşti	Dragonul	3	4	Tara:Romania, \n                Judet:Ilfov, \n                Oras:Dobroeşti, \n                Strada:Dragonul, Numar:3, Cod Postal:4	1	t	t	t
2	2024-05-13 13:16:47.845	2024-05-13 13:16:47.845	bucuresti	Adresa Comerciala	Romania	Bucureşti	Sector 3	Vlad	4	4	Tara:Romania, Judet:Bucureşti, Oras:Sector 3, Strada:Vlad, Numar:4, Cod Postal:4	2	t	t	t
\.


--
-- Data for Name: Alerts; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Alerts" (id, "updateadAt", "createdAt", name, "isActive", subject, text, internal_emails, nrofdays, param, "isActivePartner", "isActivePerson") FROM stdin;
1	2024-05-13 10:48:36.18	2024-05-13 10:48:36.18	Contract Inchis inainte de termen	t	Contract Inchis inainte de termen	Va informam faptul ca a fost inchis contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract a fost in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.	office@companie.ro	0	Inchis la data	f	f
2	2024-05-13 10:48:36.18	2024-05-13 10:48:36.18	Expirare Contract	t	Expirare Contract	Va informam faptul ca urmeaza sa expire contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract este in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.	office@companie.ro	30	Data Final	f	f
3	2024-05-13 10:48:36.18	2024-05-13 10:48:36.18	Reminder	t	Reminder	Va informam faptul ca aveti de finalizat task-ul	office@companie.ro	1	Data Reminder	f	f
\.


--
-- Data for Name: AlertsHistory; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."AlertsHistory" (id, "updateadAt", "createdAt", "alertId", "alertContent", "sentTo", "contractId", criteria, param, nrofdays) FROM stdin;
1	2024-05-14 07:00:00.028	2024-05-14 07:00:00.028	2	Va informam faptul ca urmeaza sa expire contractul cu numarul 234324 din data de 22.05.2024 la partenerul SoftHub. Acest contract este in vigoare in compania NIRO INVESTMENT SA si reprezinta 234.	to:  bcc:razvan.mustata@gmail.com	11	Data Final	end	30
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
1	2024-05-13 13:12:07.672	2024-05-13 13:12:07.672	1	Alpha Bank	Tineretului	EUR	234242423	t
2	2024-05-13 13:17:12.493	2024-05-13 13:17:12.493	2	ING	Tineret	EUR	r345345	t
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
1	ITC
\.


--
-- Data for Name: ContractAlertSchedule; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractAlertSchedule" (id, "updateadAt", "createdAt", "contractId", "alertId", alertname, "datetoBeSent", "isActive", status, subject, nrofdays) FROM stdin;
1	2024-05-13 14:15:10.025	2024-05-13 14:15:10.025	1	2	Expirare Contract	2024-12-01 22:00:00	t	t	Expirare Contract	30
2	2024-05-13 14:20:00.049	2024-05-13 14:20:00.049	1	1	Contract Inchis inainte de termen	2024-12-31 22:00:00	t	t	Contract Inchis inainte de termen	0
3	2024-05-13 16:22:50.012	2024-05-13 16:22:50.012	2	2	Expirare Contract	2024-10-31 22:00:00	t	t	Expirare Contract	30
4	2024-05-13 16:30:00.11	2024-05-13 16:30:00.11	2	1	Contract Inchis inainte de termen	2024-11-30 22:00:00	t	t	Contract Inchis inainte de termen	0
5	2024-05-13 16:31:50.009	2024-05-13 16:31:50.009	3	2	Expirare Contract	2024-10-02 22:00:00	t	t	Expirare Contract	30
6	2024-05-13 16:38:00.016	2024-05-13 16:38:00.016	4	2	Expirare Contract	2024-10-21 22:00:00	t	t	Expirare Contract	30
7	2024-05-13 16:40:00.072	2024-05-13 16:40:00.072	3	1	Contract Inchis inainte de termen	2024-11-01 22:00:00	t	t	Contract Inchis inainte de termen	0
8	2024-05-13 16:40:00.075	2024-05-13 16:40:00.075	4	1	Contract Inchis inainte de termen	2024-11-20 22:00:00	t	t	Contract Inchis inainte de termen	0
9	2024-05-13 16:46:50.016	2024-05-13 16:46:50.016	5	2	Expirare Contract	2024-07-30 21:00:00	t	t	Expirare Contract	30
10	2024-05-13 16:50:00.02	2024-05-13 16:50:00.02	5	1	Contract Inchis inainte de termen	2024-08-29 21:00:00	t	t	Contract Inchis inainte de termen	0
11	2024-05-13 16:59:00.019	2024-05-13 16:59:00.019	6	2	Expirare Contract	2024-10-29 22:00:00	t	t	Expirare Contract	30
12	2024-05-13 17:00:00.046	2024-05-13 17:00:00.046	6	1	Contract Inchis inainte de termen	2024-11-28 22:00:00	t	t	Contract Inchis inainte de termen	0
13	2024-05-13 17:07:40.017	2024-05-13 17:07:40.017	7	2	Expirare Contract	2024-10-29 22:00:00	t	t	Expirare Contract	30
14	2024-05-13 17:10:00.043	2024-05-13 17:10:00.043	7	1	Contract Inchis inainte de termen	2024-11-28 22:00:00	t	t	Contract Inchis inainte de termen	0
15	2024-05-13 17:10:10.018	2024-05-13 17:10:10.018	8	2	Expirare Contract	2024-11-20 22:00:00	t	t	Expirare Contract	30
16	2024-05-13 17:11:40.023	2024-05-13 17:11:40.023	9	2	Expirare Contract	2024-07-29 21:00:00	t	t	Expirare Contract	30
17	2024-05-13 17:14:00.098	2024-05-13 17:14:00.098	10	2	Expirare Contract	2024-10-28 22:00:00	t	t	Expirare Contract	30
18	2024-05-13 17:18:10.026	2024-05-13 17:18:10.026	11	2	Expirare Contract	2024-04-23 21:00:00	t	t	Expirare Contract	30
19	2024-05-13 17:20:00.031	2024-05-13 17:20:00.031	8	1	Contract Inchis inainte de termen	2024-12-20 22:00:00	t	t	Contract Inchis inainte de termen	0
20	2024-05-13 17:20:00.034	2024-05-13 17:20:00.034	9	1	Contract Inchis inainte de termen	2024-08-28 21:00:00	t	t	Contract Inchis inainte de termen	0
21	2024-05-13 17:20:00.036	2024-05-13 17:20:00.036	10	1	Contract Inchis inainte de termen	2024-11-27 22:00:00	t	t	Contract Inchis inainte de termen	0
22	2024-05-13 17:20:00.038	2024-05-13 17:20:00.038	11	1	Contract Inchis inainte de termen	2024-05-23 21:00:00	t	t	Contract Inchis inainte de termen	0
23	2024-05-13 17:29:20.029	2024-05-13 17:29:20.029	12	2	Expirare Contract	2024-07-29 21:00:00	t	t	Expirare Contract	30
24	2024-05-13 17:30:00.065	2024-05-13 17:30:00.065	12	1	Contract Inchis inainte de termen	2024-08-28 21:00:00	t	t	Contract Inchis inainte de termen	0
25	2024-05-13 17:36:40.02	2024-05-13 17:36:40.02	13	2	Expirare Contract	2024-05-28 21:00:00	t	t	Expirare Contract	30
26	2024-05-13 17:40:00.077	2024-05-13 17:40:00.077	13	1	Contract Inchis inainte de termen	2024-06-27 21:00:00	t	t	Contract Inchis inainte de termen	0
27	2024-05-13 17:40:10.029	2024-05-13 17:40:10.029	14	2	Expirare Contract	2024-08-27 21:00:00	t	t	Expirare Contract	30
28	2024-05-13 17:43:50.021	2024-05-13 17:43:50.021	15	2	Expirare Contract	2024-07-31 21:00:00	t	t	Expirare Contract	30
29	2024-05-14 03:30:00.154	2024-05-14 03:30:00.154	14	1	Contract Inchis inainte de termen	2024-09-26 21:00:00	t	t	Contract Inchis inainte de termen	0
30	2024-05-14 03:30:00.325	2024-05-14 03:30:00.325	15	1	Contract Inchis inainte de termen	2024-08-30 21:00:00	t	t	Contract Inchis inainte de termen	0
31	2024-05-14 03:31:20.026	2024-05-14 03:31:20.026	16	2	Expirare Contract	2024-07-01 21:00:00	t	t	Expirare Contract	30
32	2024-05-14 03:40:00.061	2024-05-14 03:40:00.061	16	1	Contract Inchis inainte de termen	2024-07-31 21:00:00	t	t	Contract Inchis inainte de termen	0
33	2024-05-14 03:41:10.021	2024-05-14 03:41:10.021	17	2	Expirare Contract	2024-06-23 21:00:00	t	t	Expirare Contract	30
34	2024-05-14 03:50:00.066	2024-05-14 03:50:00.066	17	1	Contract Inchis inainte de termen	2024-07-23 21:00:00	t	t	Contract Inchis inainte de termen	0
35	2024-05-14 03:50:20.026	2024-05-14 03:50:20.026	18	2	Expirare Contract	2024-06-19 21:00:00	t	t	Expirare Contract	30
36	2024-05-14 04:00:00.104	2024-05-14 04:00:00.104	18	1	Contract Inchis inainte de termen	2024-07-19 21:00:00	t	t	Contract Inchis inainte de termen	0
37	2024-05-14 04:35:10.034	2024-05-14 04:35:10.034	19	2	Expirare Contract	2024-07-08 21:00:00	t	t	Expirare Contract	30
38	2024-05-14 04:38:10.021	2024-05-14 04:38:10.021	20	2	Expirare Contract	2024-07-22 21:00:00	t	t	Expirare Contract	30
39	2024-05-14 04:40:00.038	2024-05-14 04:40:00.038	19	1	Contract Inchis inainte de termen	2024-08-07 21:00:00	t	t	Contract Inchis inainte de termen	0
40	2024-05-14 04:40:00.039	2024-05-14 04:40:00.039	20	1	Contract Inchis inainte de termen	2024-08-21 21:00:00	t	t	Contract Inchis inainte de termen	0
41	2024-05-14 06:07:40.027	2024-05-14 06:07:40.027	21	2	Expirare Contract	2024-10-28 22:00:00	t	t	Expirare Contract	30
42	2024-05-14 06:10:00.052	2024-05-14 06:10:00.052	21	1	Contract Inchis inainte de termen	2024-11-27 22:00:00	t	t	Contract Inchis inainte de termen	0
43	2024-05-14 06:22:00.056	2024-05-14 06:22:00.056	22	2	Expirare Contract	2024-08-30 21:00:00	t	t	Expirare Contract	30
44	2024-05-14 06:23:40.134	2024-05-14 06:23:40.134	23	2	Expirare Contract	2024-11-26 22:00:00	t	t	Expirare Contract	30
45	2024-05-14 06:28:20.034	2024-05-14 06:28:20.034	24	2	Expirare Contract	2024-10-31 22:00:00	t	t	Expirare Contract	30
46	2024-05-14 06:30:00.053	2024-05-14 06:30:00.053	22	1	Contract Inchis inainte de termen	2024-09-29 21:00:00	t	t	Contract Inchis inainte de termen	0
47	2024-05-14 06:30:00.055	2024-05-14 06:30:00.055	23	1	Contract Inchis inainte de termen	2024-12-26 22:00:00	t	t	Contract Inchis inainte de termen	0
48	2024-05-14 06:30:00.057	2024-05-14 06:30:00.057	24	1	Contract Inchis inainte de termen	2024-11-30 22:00:00	t	t	Contract Inchis inainte de termen	0
49	2024-05-14 06:32:20.027	2024-05-14 06:32:20.027	25	2	Expirare Contract	2024-07-23 21:00:00	t	t	Expirare Contract	30
50	2024-05-14 06:40:00.044	2024-05-14 06:40:00.044	25	1	Contract Inchis inainte de termen	2024-08-22 21:00:00	t	t	Contract Inchis inainte de termen	0
\.


--
-- Data for Name: ContractAttachments; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractAttachments" (id, "updateadAt", "createdAt", size, path, mimetype, originalname, encoding, fieldname, filename, destination, "contractId") FROM stdin;
1	2024-05-13 14:15:41.486	2024-05-13 14:15:41.471	746950	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715609741462-50099382.pdf	application/pdf	contract_exp (4).pdf	7bit	files	files-1715609741462-50099382.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	1
2	2024-05-13 16:23:15.899	2024-05-13 16:23:15.887	925010	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715617395857-954730103.pdf	application/pdf	exported_content (29).pdf	7bit	files	files-1715617395857-954730103.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	2
3	2024-05-13 16:23:15.903	2024-05-13 16:23:15.887	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715617395867-551961327.pdf	application/pdf	exported_content (28).pdf	7bit	files	files-1715617395867-551961327.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	2
4	2024-05-13 16:23:15.904	2024-05-13 16:23:15.887	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715617395871-628407222.pdf	application/pdf	exported_content (27).pdf	7bit	files	files-1715617395871-628407222.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	2
5	2024-05-13 16:23:15.905	2024-05-13 16:23:15.887	859532	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715617395876-995767811.pdf	application/pdf	exported_content (26).pdf	7bit	files	files-1715617395876-995767811.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	2
6	2024-05-13 16:23:15.906	2024-05-13 16:23:15.887	834296	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715617395880-621408910.pdf	application/pdf	exported_content (25).pdf	7bit	files	files-1715617395880-621408910.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	2
7	2024-05-13 16:31:57.128	2024-05-13 16:31:57.126	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715617917107-132394444.pdf	application/pdf	exported_content (28).pdf	7bit	files	files-1715617917107-132394444.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	3
8	2024-05-13 16:31:57.13	2024-05-13 16:31:57.126	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715617917115-841876679.pdf	application/pdf	exported_content (27).pdf	7bit	files	files-1715617917115-841876679.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	3
9	2024-05-13 16:31:57.131	2024-05-13 16:31:57.126	859532	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715617917120-247752164.pdf	application/pdf	exported_content (26).pdf	7bit	files	files-1715617917120-247752164.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	3
10	2024-05-13 16:36:02.085	2024-05-13 16:36:02.082	795652	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618162070-320135680.pdf	application/pdf	contract_exp.pdf	7bit	files	files-1715618162070-320135680.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	3
11	2024-05-13 16:38:04.949	2024-05-13 16:38:04.943	859532	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618284920-823296800.pdf	application/pdf	exported_content (26).pdf	7bit	files	files-1715618284920-823296800.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	4
12	2024-05-13 16:38:04.953	2024-05-13 16:38:04.943	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618284927-314570649.pdf	application/pdf	exported_content (27).pdf	7bit	files	files-1715618284927-314570649.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	4
13	2024-05-13 16:38:04.954	2024-05-13 16:38:04.943	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618284931-162863096.pdf	application/pdf	exported_content (28).pdf	7bit	files	files-1715618284931-162863096.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	4
14	2024-05-13 16:38:04.955	2024-05-13 16:38:04.943	925010	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618284937-147164030.pdf	application/pdf	exported_content (29).pdf	7bit	files	files-1715618284937-147164030.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	4
15	2024-05-13 16:39:11.671	2024-05-13 16:39:11.669	834296	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618351660-916898835.pdf	application/pdf	exported_content (25).pdf	7bit	files	files-1715618351660-916898835.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	4
16	2024-05-13 16:40:37.78	2024-05-13 16:40:37.778	746950	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618437764-295988622.pdf	application/pdf	contract_exp (4).pdf	7bit	files	files-1715618437764-295988622.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	4
17	2024-05-13 16:40:37.783	2024-05-13 16:40:37.778	746950	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618437772-967049758.pdf	application/pdf	contract_exp (3).pdf	7bit	files	files-1715618437772-967049758.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	4
24	2024-05-14 04:08:52.326	2024-05-14 04:08:52.304	834296	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715659732284-798080052.pdf	application/pdf	exported_content (25).pdf	7bit	files	files-1715659732284-798080052.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	11
19	2024-05-13 16:47:00.75	2024-05-13 16:47:00.746	859532	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618820736-543844681.pdf	application/pdf	exported_content (26).pdf	7bit	files	files-1715618820736-543844681.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	5
20	2024-05-13 16:47:00.751	2024-05-13 16:47:00.746	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715618820741-399517331.pdf	application/pdf	exported_content (27).pdf	7bit	files	files-1715618820741-399517331.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	5
21	2024-05-13 16:59:02.226	2024-05-13 16:59:02.224	729306	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715619542206-885231264.pdf	application/pdf	contract_exp (5).pdf	7bit	files	files-1715619542206-885231264.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	6
22	2024-05-13 16:59:02.228	2024-05-13 16:59:02.224	834296	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715619542216-4798236.pdf	application/pdf	exported_content (25).pdf	7bit	files	files-1715619542216-4798236.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	6
23	2024-05-13 16:59:02.23	2024-05-13 16:59:02.224	859532	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715619542219-234254461.pdf	application/pdf	exported_content (26).pdf	7bit	files	files-1715619542219-234254461.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	6
25	2024-05-14 04:08:52.337	2024-05-14 04:08:52.304	859532	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715659732293-137456093.pdf	application/pdf	exported_content (26).pdf	7bit	files	files-1715659732293-137456093.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	11
26	2024-05-14 04:08:52.339	2024-05-14 04:08:52.304	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715659732297-69575190.pdf	application/pdf	exported_content (27).pdf	7bit	files	files-1715659732297-69575190.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	11
27	2024-05-14 06:32:28.83	2024-05-14 06:32:28.825	833540	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715668348806-385226708.pdf	application/pdf	exported_content (27).pdf	7bit	files	files-1715668348806-385226708.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	25
29	2024-05-14 06:32:28.85	2024-05-14 06:32:28.825	925010	/Users/razvanmustata/Projects/contracts/backend/Uploads/files-1715668348819-515822921.pdf	application/pdf	exported_content (29).pdf	7bit	files	files-1715668348819-515822921.pdf	/Users/razvanmustata/Projects/contracts/backend/Uploads	25
\.


--
-- Data for Name: ContractContent; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractContent" (id, "updateadAt", "createdAt", content, "contractId") FROM stdin;
1	2024-05-13 17:29:32.063	2024-05-13 17:29:32.063	<p><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p><strong>NR.: </strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">23432</span><strong>/</strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">undefined</span></p><p>Intre:&nbsp;</p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span> cu sediul social in Bucureşti, sectorul 3, Str. Vlad Judeţul nr. 2, camera nr. 1,&nbsp;bloc V14A, scara 2, etaj 1, ap. 33, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">NIRO INVESTMENT SA</span><strong>, </strong>persoană juridică română, cu sediul în Comuna Dobroeşti, Sat Fundeni, str. Dragonul Roşu, nr. 1-10, etaj 3, biroul nr. 2-4, Centrul Comercial Dragonul Roşu Megashop, judeţ Ilfov, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p>1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p>1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p>2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p>P a g e 2 | 6&nbsp;</p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p>b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p>b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p>c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p>5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p>5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p>5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p>5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p>P a g e 3 | 6&nbsp;</p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p>6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p>7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p>(a) prin acordul scris al Părţilor;&nbsp;</p><p>(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p>(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p>(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p>(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p>7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p>7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p>8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p>8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p>8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p>P a g e 4 | 6&nbsp;</p><p>contract.&nbsp;</p><p>8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p>8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p>9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p>9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p>9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p>9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p>9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p>9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p>9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p>10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p>Fiecare Parte se obligă să nu divulge terţelor persoane, fără acordul prealabil exprimat în scris al&nbsp;celeilalte Parţi, informaţia obţinută în procesul executării prezentului Contract, precum şi să o&nbsp;utilizeze numai în scopurile executării prezentului Contract. Obligaţia nu se aplică informaţiei: a.&nbsp;divulgate la solicitarea unor autoritati publice cu atributii, făcută în conformitate cu legislaţia în&nbsp;vigoare; b. care este de domeniul public la momentul divulgării; c. divulgate în cadrul unui proces&nbsp;judiciar între Parţi privind acest Contract; d. divulgate acţionarilor Părţii, persoanelor cu funcţii de&nbsp;răspundere, salariaţilor, reprezentanţilor, agenţilor, consultanţilor, auditorilor, cedenţilor,&nbsp;</p><p>P a g e 5 | 6&nbsp;</p><p>succesorilor şi/sau întreprinderilor afiliate ale Parţii care sunt implicate în executarea prezentului&nbsp;Contract, referitor la care Partea va trebui:- să limiteze divulgarea informaţiei numai către cei ce au&nbsp;nevoie de ea pentru îndeplinirea obligaţiilor sale faţă de Parte;- sa asigure folosirea informaţiei&nbsp;exclusiv in scopurile nemijlocit legate de ceea pentru ce informaţia este divulgata;- sa informeze toate&nbsp;aceste persoane privind obligaţia lor de a păstra confidenţialitatea informaţiei în modul stabilit de prezentul Contract.&nbsp;</p><p>Sunt considerate informații confidențiale și fac obiectul prezentelor clauze, datele de identificare&nbsp;(nume, semnătură, serie și număr CI etc.) ale reprezentanților Părților, care se vor regăsi pe&nbsp;documentele emise de (schimbate între) Parți în perioada derulării Contractului și care nu sunt de&nbsp;domeniul public la momentul divulgării. Prelucrarea de către Părți a datelor cu caracter personal ale&nbsp;persoanelor vizate mai sus se va realiza cu respectarea principiilor și drepturilor acestora care decurg&nbsp;din punerea în aplicare a REGULAMENTUL (UE) 2016/679 AL PARLAMENTULUI EUROPEAN ȘI AL&nbsp;CONSILIULUI privind protecția persoanelor fizice în ceea ce privește prelucrarea datelor cu caracter&nbsp;personal – GDPR. În spiritul GDPR, Părțile au următoarele drepturi de acces la datele personale ale&nbsp;angajaților/reprezentanților proprii, operate de cealaltă Parte:a) Dreptul de acces la date; b) reptul&nbsp;la rectificarea datelor; c) Dreptul la ștergerea datelor; d)Dreptul la restricționarea prelucrării; e)&nbsp;Dreptul la portabilitatea datelor; f) Dreptul de opoziție la prelucrarea datelor; g) Dreptul de a nu fi&nbsp;supus unor decizii automatizate, inclusiv profilarea; h) Dreptul la notificarea destinatarilor privind&nbsp;rectificarea, ștergerea ori restricționarea datelor cu caracter personal.&nbsp;</p><p>Conform legislației naționale în vigoare în domeniu, datele personale solicitate de beneficiar sunt&nbsp;necesare pentru buna derulare a Contractului (completarea facturilor, documentelor contabile) și nu&nbsp;vor fi folosite în alte scopuri.&nbsp;</p><p>Datele personale obținute sunt procesate în bazele de date și pe serverele Niro Investment S.A. (societate afiliata), pe întreaga durată a raporturilor contractuale și ulterior, conform politicilor&nbsp;interne, pe durata necesară îndeplinirii obligațiilor legale ce ii revin. Respectarea cerințelor legale&nbsp;aplicabile sunt permanent monitorizate, inclusiv prin Responsabilul de protecție a datelor cu caracter&nbsp;personal ce poate fi contactat la dpo@nirogroup.ro. Reclamațiile privind posibila încălcare a&nbsp;drepturilor privind prelucrarea datelor cu caracter personal pot fi adresate Autorității Naționale de&nbsp;Supraveghere a Prelucrării Datelor cu Caracter Personal la adresa www.dataprotection.ro.&nbsp;</p><p>Oricare dintre Părţile contractante se obligă, în termenii şi condiţiile prezentului Contract, să păstreze&nbsp;strict confidenţiale, pe durata Contractului şi după incetarea acestuia, toate datele şi informaţiile,&nbsp;divulgate în orice manieră de către cealaltă Parte, în executarea Contractului. Excepţie de la prezenta&nbsp;obligaţie sunt cazurile în care divulgarea este necesară pentru executarea Contractului şi se face&nbsp;numai avand consimţământul scris, expres si prealabil al celeilalte Părţi sau daca divulgarea este&nbsp;solicitată, în mod legal, de către autorităţile de drept.&nbsp;</p><p>În cazul în care oricare dintre Părţi va încălca obligaţia de confidenţialitate, aceasta va fi obligată la&nbsp;plata de daune-interese în favoarea Părţii prejudiciate.&nbsp;</p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p>12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p>P a g e 6 | 6&nbsp;</p><p>răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p><strong>Art. 13. Clauze finale&nbsp;</strong></p><p>13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p>13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p>13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p>Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong>&nbsp;</p>	12
2	2024-05-13 17:46:10.966	2024-05-13 17:46:10.966	<p><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p><strong>NR.: </strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">55</span><strong>/</strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">undefined</span></p><p>Intre:&nbsp;</p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span> cu sediul social in Bucureşti, sectorul 3, Str. Vlad Judeţul nr. 2, camera nr. 1,&nbsp;bloc V14A, scara 2, etaj 1, ap. 33, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">NIRO INVESTMENT SA</span><strong>, </strong>persoană juridică română, cu sediul în Comuna Dobroeşti, Sat Fundeni, str. Dragonul Roşu, nr. 1-10, etaj 3, biroul nr. 2-4, Centrul Comercial Dragonul Roşu Megashop, judeţ Ilfov, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p>1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p>1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p>2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p>P a g e 2 | 6&nbsp;</p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p>b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p>b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p>c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p>5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p>5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p>5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p>5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p>P a g e 3 | 6&nbsp;</p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p>6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p>7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p>(a) prin acordul scris al Părţilor;&nbsp;</p><p>(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p>(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p>(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p>(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p>7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p>7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p>8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p>8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p>8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p>P a g e 4 | 6&nbsp;</p><p>contract.&nbsp;</p><p>8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p>8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p>9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p>9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p>9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p>9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p>9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p>9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p>9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p>10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p>Fiecare Parte se obligă să nu divulge terţelor persoane, fără acordul prealabil exprimat în scris al&nbsp;celeilalte Parţi, informaţia obţinută în procesul executării prezentului Contract, precum şi să o&nbsp;utilizeze numai în scopurile executării prezentului Contract. Obligaţia nu se aplică informaţiei: a.&nbsp;divulgate la solicitarea unor autoritati publice cu atributii, făcută în conformitate cu legislaţia în&nbsp;vigoare; b. care este de domeniul public la momentul divulgării; c. divulgate în cadrul unui proces&nbsp;judiciar între Parţi privind acest Contract; d. divulgate acţionarilor Părţii, persoanelor cu funcţii de&nbsp;răspundere, salariaţilor, reprezentanţilor, agenţilor, consultanţilor, auditorilor, cedenţilor,&nbsp;</p><p>P a g e 5 | 6&nbsp;</p><p>succesorilor şi/sau întreprinderilor afiliate ale Parţii care sunt implicate în executarea prezentului&nbsp;Contract, referitor la care Partea va trebui:- să limiteze divulgarea informaţiei numai către cei ce au&nbsp;nevoie de ea pentru îndeplinirea obligaţiilor sale faţă de Parte;- sa asigure folosirea informaţiei&nbsp;exclusiv in scopurile nemijlocit legate de ceea pentru ce informaţia este divulgata;- sa informeze toate&nbsp;aceste persoane privind obligaţia lor de a păstra confidenţialitatea informaţiei în modul stabilit de prezentul Contract.&nbsp;</p><p>Sunt considerate informații confidențiale și fac obiectul prezentelor clauze, datele de identificare&nbsp;(nume, semnătură, serie și număr CI etc.) ale reprezentanților Părților, care se vor regăsi pe&nbsp;documentele emise de (schimbate între) Parți în perioada derulării Contractului și care nu sunt de&nbsp;domeniul public la momentul divulgării. Prelucrarea de către Părți a datelor cu caracter personal ale&nbsp;persoanelor vizate mai sus se va realiza cu respectarea principiilor și drepturilor acestora care decurg&nbsp;din punerea în aplicare a REGULAMENTUL (UE) 2016/679 AL PARLAMENTULUI EUROPEAN ȘI AL&nbsp;CONSILIULUI privind protecția persoanelor fizice în ceea ce privește prelucrarea datelor cu caracter&nbsp;personal – GDPR. În spiritul GDPR, Părțile au următoarele drepturi de acces la datele personale ale&nbsp;angajaților/reprezentanților proprii, operate de cealaltă Parte:a) Dreptul de acces la date; b) reptul&nbsp;la rectificarea datelor; c) Dreptul la ștergerea datelor; d)Dreptul la restricționarea prelucrării; e)&nbsp;Dreptul la portabilitatea datelor; f) Dreptul de opoziție la prelucrarea datelor; g) Dreptul de a nu fi&nbsp;supus unor decizii automatizate, inclusiv profilarea; h) Dreptul la notificarea destinatarilor privind&nbsp;rectificarea, ștergerea ori restricționarea datelor cu caracter personal.&nbsp;</p><p>Conform legislației naționale în vigoare în domeniu, datele personale solicitate de beneficiar sunt&nbsp;necesare pentru buna derulare a Contractului (completarea facturilor, documentelor contabile) și nu&nbsp;vor fi folosite în alte scopuri.&nbsp;</p><p>Datele personale obținute sunt procesate în bazele de date și pe serverele Niro Investment S.A. (societate afiliata), pe întreaga durată a raporturilor contractuale și ulterior, conform politicilor&nbsp;interne, pe durata necesară îndeplinirii obligațiilor legale ce ii revin. Respectarea cerințelor legale&nbsp;aplicabile sunt permanent monitorizate, inclusiv prin Responsabilul de protecție a datelor cu caracter&nbsp;personal ce poate fi contactat la dpo@nirogroup.ro. Reclamațiile privind posibila încălcare a&nbsp;drepturilor privind prelucrarea datelor cu caracter personal pot fi adresate Autorității Naționale de&nbsp;Supraveghere a Prelucrării Datelor cu Caracter Personal la adresa www.dataprotection.ro.&nbsp;</p><p>Oricare dintre Părţile contractante se obligă, în termenii şi condiţiile prezentului Contract, să păstreze&nbsp;strict confidenţiale, pe durata Contractului şi după incetarea acestuia, toate datele şi informaţiile,&nbsp;divulgate în orice manieră de către cealaltă Parte, în executarea Contractului. Excepţie de la prezenta&nbsp;obligaţie sunt cazurile în care divulgarea este necesară pentru executarea Contractului şi se face&nbsp;numai avand consimţământul scris, expres si prealabil al celeilalte Părţi sau daca divulgarea este&nbsp;solicitată, în mod legal, de către autorităţile de drept.&nbsp;</p><p>În cazul în care oricare dintre Părţi va încălca obligaţia de confidenţialitate, aceasta va fi obligată la&nbsp;plata de daune-interese în favoarea Părţii prejudiciate.&nbsp;</p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p>12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p>P a g e 6 | 6&nbsp;</p><p>răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p><strong>Art. 13. Clauze finale&nbsp;</strong></p><p>13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p>13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p>13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p>Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong>&nbsp;</p>	5
3	2024-05-14 04:10:49.087	2024-05-14 04:10:49.087	<p><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p><strong>NR.: </strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">234324</span><strong>/</strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">undefined</span></p><p>Intre:&nbsp;</p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span> cu sediul social in Bucureşti, sectorul 3, Str. Vlad Judeţul nr. 2, camera nr. 1,&nbsp;bloc V14A, scara 2, etaj 1, ap. 33, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">NIRO INVESTMENT SA</span><strong>, </strong>persoană juridică română, cu sediul în Comuna Dobroeşti, Sat Fundeni, str. Dragonul Roşu, nr. 1-10, etaj 3, biroul nr. 2-4, Centrul Comercial Dragonul Roşu Megashop, judeţ Ilfov, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p>1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p>1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p>2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p>P a g e 2 | 6&nbsp;</p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p>b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p>b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p>c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p>5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p>5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p>5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p>5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p>P a g e 3 | 6&nbsp;</p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p>6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p>7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p>(a) prin acordul scris al Părţilor;&nbsp;</p><p>(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p>(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p>(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p>(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p>7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p>7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p>8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p>8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p>8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p>P a g e 4 | 6&nbsp;</p><p>contract.&nbsp;</p><p>8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p>8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p>9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p>9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p>9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p>9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p>9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p>9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p>9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p>10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p>Fiecare Parte se obligă să nu divulge terţelor persoane, fără acordul prealabil exprimat în scris al&nbsp;celeilalte Parţi, informaţia obţinută în procesul executării prezentului Contract, precum şi să o&nbsp;utilizeze numai în scopurile executării prezentului Contract. Obligaţia nu se aplică informaţiei: a.&nbsp;divulgate la solicitarea unor autoritati publice cu atributii, făcută în conformitate cu legislaţia în&nbsp;vigoare; b. care este de domeniul public la momentul divulgării; c. divulgate în cadrul unui proces&nbsp;judiciar între Parţi privind acest Contract; d. divulgate acţionarilor Părţii, persoanelor cu funcţii de&nbsp;răspundere, salariaţilor, reprezentanţilor, agenţilor, consultanţilor, auditorilor, cedenţilor,&nbsp;</p><p>P a g e 5 | 6&nbsp;</p><p>succesorilor şi/sau întreprinderilor afiliate ale Parţii care sunt implicate în executarea prezentului&nbsp;Contract, referitor la care Partea va trebui:- să limiteze divulgarea informaţiei numai către cei ce au&nbsp;nevoie de ea pentru îndeplinirea obligaţiilor sale faţă de Parte;- sa asigure folosirea informaţiei&nbsp;exclusiv in scopurile nemijlocit legate de ceea pentru ce informaţia este divulgata;- sa informeze toate&nbsp;aceste persoane privind obligaţia lor de a păstra confidenţialitatea informaţiei în modul stabilit de prezentul Contract.&nbsp;</p><p>Sunt considerate informații confidențiale și fac obiectul prezentelor clauze, datele de identificare&nbsp;(nume, semnătură, serie și număr CI etc.) ale reprezentanților Părților, care se vor regăsi pe&nbsp;documentele emise de (schimbate între) Parți în perioada derulării Contractului și care nu sunt de&nbsp;domeniul public la momentul divulgării. Prelucrarea de către Părți a datelor cu caracter personal ale&nbsp;persoanelor vizate mai sus se va realiza cu respectarea principiilor și drepturilor acestora care decurg&nbsp;din punerea în aplicare a REGULAMENTUL (UE) 2016/679 AL PARLAMENTULUI EUROPEAN ȘI AL&nbsp;CONSILIULUI privind protecția persoanelor fizice în ceea ce privește prelucrarea datelor cu caracter&nbsp;personal – GDPR. În spiritul GDPR, Părțile au următoarele drepturi de acces la datele personale ale&nbsp;angajaților/reprezentanților proprii, operate de cealaltă Parte:a) Dreptul de acces la date; b) reptul&nbsp;la rectificarea datelor; c) Dreptul la ștergerea datelor; d)Dreptul la restricționarea prelucrării; e)&nbsp;Dreptul la portabilitatea datelor; f) Dreptul de opoziție la prelucrarea datelor; g) Dreptul de a nu fi&nbsp;supus unor decizii automatizate, inclusiv profilarea; h) Dreptul la notificarea destinatarilor privind&nbsp;rectificarea, ștergerea ori restricționarea datelor cu caracter personal.&nbsp;</p><p>Conform legislației naționale în vigoare în domeniu, datele personale solicitate de beneficiar sunt&nbsp;necesare pentru buna derulare a Contractului (completarea facturilor, documentelor contabile) și nu&nbsp;vor fi folosite în alte scopuri.&nbsp;</p><p>Datele personale obținute sunt procesate în bazele de date și pe serverele Niro Investment S.A. (societate afiliata), pe întreaga durată a raporturilor contractuale și ulterior, conform politicilor&nbsp;interne, pe durata necesară îndeplinirii obligațiilor legale ce ii revin. Respectarea cerințelor legale&nbsp;aplicabile sunt permanent monitorizate, inclusiv prin Responsabilul de protecție a datelor cu caracter&nbsp;personal ce poate fi contactat la dpo@nirogroup.ro. Reclamațiile privind posibila încălcare a&nbsp;drepturilor privind prelucrarea datelor cu caracter personal pot fi adresate Autorității Naționale de&nbsp;Supraveghere a Prelucrării Datelor cu Caracter Personal la adresa www.dataprotection.ro.&nbsp;</p><p>Oricare dintre Părţile contractante se obligă, în termenii şi condiţiile prezentului Contract, să păstreze&nbsp;strict confidenţiale, pe durata Contractului şi după incetarea acestuia, toate datele şi informaţiile,&nbsp;divulgate în orice manieră de către cealaltă Parte, în executarea Contractului. Excepţie de la prezenta&nbsp;obligaţie sunt cazurile în care divulgarea este necesară pentru executarea Contractului şi se face&nbsp;numai avand consimţământul scris, expres si prealabil al celeilalte Părţi sau daca divulgarea este&nbsp;solicitată, în mod legal, de către autorităţile de drept.&nbsp;</p><p>În cazul în care oricare dintre Părţi va încălca obligaţia de confidenţialitate, aceasta va fi obligată la&nbsp;plata de daune-interese în favoarea Părţii prejudiciate.&nbsp;</p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p>12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p>P a g e 6 | 6&nbsp;</p><p>răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p><strong>Art. 13. Clauze finale&nbsp;</strong></p><p>13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p>13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p>13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p>Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong>&nbsp;</p>	11
4	2024-05-14 06:32:42.564	2024-05-14 06:32:42.564	<p><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p><strong>NR.: </strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ok2</span><strong>/</strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">undefined</span></p><p>Intre:&nbsp;</p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SoftHub</span> cu sediul social in Bucureşti, sectorul 3, Str. Vlad Judeţul nr. 2, camera nr. 1,&nbsp;bloc V14A, scara 2, etaj 1, ap. 33, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">NIRO INVESTMENT SA</span><strong>, </strong>persoană juridică română, cu sediul în Comuna Dobroeşti, Sat Fundeni, str. Dragonul Roşu, nr. 1-10, etaj 3, biroul nr. 2-4, Centrul Comercial Dragonul Roşu Megashop, judeţ Ilfov, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p>1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice.&nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract.&nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice,&nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare,&nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p>1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p>2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p>P a g e 2 | 6&nbsp;</p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p>b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator;&nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p>b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p>c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p>5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p>5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p>5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p>5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p>P a g e 3 | 6&nbsp;</p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p>6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p>7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p>(a) prin acordul scris al Părţilor;&nbsp;</p><p>(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p>(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p>(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p>(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p>7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p>7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p>8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p>8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p>8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p>P a g e 4 | 6&nbsp;</p><p>contract.&nbsp;</p><p>8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p>8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p>9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p>9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p>9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor.&nbsp;</p><p>9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p>9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p>9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p>9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p>10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p>Fiecare Parte se obligă să nu divulge terţelor persoane, fără acordul prealabil exprimat în scris al&nbsp;celeilalte Parţi, informaţia obţinută în procesul executării prezentului Contract, precum şi să o&nbsp;utilizeze numai în scopurile executării prezentului Contract. Obligaţia nu se aplică informaţiei: a.&nbsp;divulgate la solicitarea unor autoritati publice cu atributii, făcută în conformitate cu legislaţia în&nbsp;vigoare; b. care este de domeniul public la momentul divulgării; c. divulgate în cadrul unui proces&nbsp;judiciar între Parţi privind acest Contract; d. divulgate acţionarilor Părţii, persoanelor cu funcţii de&nbsp;răspundere, salariaţilor, reprezentanţilor, agenţilor, consultanţilor, auditorilor, cedenţilor,&nbsp;</p><p>P a g e 5 | 6&nbsp;</p><p>succesorilor şi/sau întreprinderilor afiliate ale Parţii care sunt implicate în executarea prezentului&nbsp;Contract, referitor la care Partea va trebui:- să limiteze divulgarea informaţiei numai către cei ce au&nbsp;nevoie de ea pentru îndeplinirea obligaţiilor sale faţă de Parte;- sa asigure folosirea informaţiei&nbsp;exclusiv in scopurile nemijlocit legate de ceea pentru ce informaţia este divulgata;- sa informeze toate&nbsp;aceste persoane privind obligaţia lor de a păstra confidenţialitatea informaţiei în modul stabilit de prezentul Contract.&nbsp;</p><p>Sunt considerate informații confidențiale și fac obiectul prezentelor clauze, datele de identificare&nbsp;(nume, semnătură, serie și număr CI etc.) ale reprezentanților Părților, care se vor regăsi pe&nbsp;documentele emise de (schimbate între) Parți în perioada derulării Contractului și care nu sunt de&nbsp;domeniul public la momentul divulgării. Prelucrarea de către Părți a datelor cu caracter personal ale&nbsp;persoanelor vizate mai sus se va realiza cu respectarea principiilor și drepturilor acestora care decurg&nbsp;din punerea în aplicare a REGULAMENTUL (UE) 2016/679 AL PARLAMENTULUI EUROPEAN ȘI AL&nbsp;CONSILIULUI privind protecția persoanelor fizice în ceea ce privește prelucrarea datelor cu caracter&nbsp;personal – GDPR. În spiritul GDPR, Părțile au următoarele drepturi de acces la datele personale ale&nbsp;angajaților/reprezentanților proprii, operate de cealaltă Parte:a) Dreptul de acces la date; b) reptul&nbsp;la rectificarea datelor; c) Dreptul la ștergerea datelor; d)Dreptul la restricționarea prelucrării; e)&nbsp;Dreptul la portabilitatea datelor; f) Dreptul de opoziție la prelucrarea datelor; g) Dreptul de a nu fi&nbsp;supus unor decizii automatizate, inclusiv profilarea; h) Dreptul la notificarea destinatarilor privind&nbsp;rectificarea, ștergerea ori restricționarea datelor cu caracter personal.&nbsp;</p><p>Conform legislației naționale în vigoare în domeniu, datele personale solicitate de beneficiar sunt&nbsp;necesare pentru buna derulare a Contractului (completarea facturilor, documentelor contabile) și nu&nbsp;vor fi folosite în alte scopuri.&nbsp;</p><p>Datele personale obținute sunt procesate în bazele de date și pe serverele Niro Investment S.A. (societate afiliata), pe întreaga durată a raporturilor contractuale și ulterior, conform politicilor&nbsp;interne, pe durata necesară îndeplinirii obligațiilor legale ce ii revin. Respectarea cerințelor legale&nbsp;aplicabile sunt permanent monitorizate, inclusiv prin Responsabilul de protecție a datelor cu caracter&nbsp;personal ce poate fi contactat la dpo@nirogroup.ro. Reclamațiile privind posibila încălcare a&nbsp;drepturilor privind prelucrarea datelor cu caracter personal pot fi adresate Autorității Naționale de&nbsp;Supraveghere a Prelucrării Datelor cu Caracter Personal la adresa www.dataprotection.ro.&nbsp;</p><p>Oricare dintre Părţile contractante se obligă, în termenii şi condiţiile prezentului Contract, să păstreze&nbsp;strict confidenţiale, pe durata Contractului şi după incetarea acestuia, toate datele şi informaţiile,&nbsp;divulgate în orice manieră de către cealaltă Parte, în executarea Contractului. Excepţie de la prezenta&nbsp;obligaţie sunt cazurile în care divulgarea este necesară pentru executarea Contractului şi se face&nbsp;numai avand consimţământul scris, expres si prealabil al celeilalte Părţi sau daca divulgarea este&nbsp;solicitată, în mod legal, de către autorităţile de drept.&nbsp;</p><p>În cazul în care oricare dintre Părţi va încălca obligaţia de confidenţialitate, aceasta va fi obligată la&nbsp;plata de daune-interese în favoarea Părţii prejudiciate.&nbsp;</p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p>12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p>P a g e 6 | 6&nbsp;</p><p>răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc.&nbsp;</p><p><strong>Art. 13. Clauze finale&nbsp;</strong></p><p>13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului.&nbsp;</p><p>13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti.&nbsp;</p><p>13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii.&nbsp;</p><p>Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, Prestator,&nbsp;</p><p><strong>NIRO INVESTMENT S.A. SOFTHUB AG S.R.L. </strong>Director General, Administrator,&nbsp;</p><p><strong>Mihaela Istrate Razvan Mihai Mustata</strong>&nbsp;</p>	25
\.


--
-- Data for Name: ContractDynamicFields; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractDynamicFields" (id, "updateadAt", "createdAt", "contractId", "dffInt1", "dffInt2", "dffInt3", "dffInt4", "dffString1", "dffString2", "dffString3", "dffString4", "dffDate1", "dffDate2") FROM stdin;
1	2024-05-13 14:15:09.084	2024-05-13 14:15:09.084	1	\N	\N	\N	\N					\N	\N
2	2024-05-13 16:22:45.786	2024-05-13 16:22:45.786	2	\N	\N	\N	\N					\N	\N
3	2024-05-13 16:31:44.296	2024-05-13 16:31:44.296	3	\N	\N	\N	\N					\N	\N
4	2024-05-13 16:37:51.105	2024-05-13 16:37:51.105	4	\N	\N	\N	\N					\N	\N
5	2024-05-13 16:46:47.645	2024-05-13 16:46:47.645	5	\N	\N	\N	\N					\N	\N
6	2024-05-13 16:58:50.853	2024-05-13 16:58:50.853	6	\N	\N	\N	\N					\N	\N
7	2024-05-13 17:07:31.628	2024-05-13 17:07:31.628	7	\N	\N	\N	\N					\N	\N
8	2024-05-13 17:10:06.202	2024-05-13 17:10:06.202	8	\N	\N	\N	\N					\N	\N
9	2024-05-13 17:11:30.297	2024-05-13 17:11:30.297	9	\N	\N	\N	\N					\N	\N
10	2024-05-13 17:13:59.766	2024-05-13 17:13:59.766	10	\N	\N	\N	\N					\N	\N
11	2024-05-13 17:18:07.244	2024-05-13 17:18:07.244	11	\N	\N	\N	\N					\N	\N
12	2024-05-13 17:29:17.228	2024-05-13 17:29:17.228	12	\N	\N	\N	\N					\N	\N
13	2024-05-13 17:36:37.936	2024-05-13 17:36:37.936	13	\N	\N	\N	\N					\N	\N
14	2024-05-13 17:40:00.294	2024-05-13 17:40:00.294	14	\N	\N	\N	\N					\N	\N
15	2024-05-13 17:43:46.794	2024-05-13 17:43:46.794	15	\N	\N	\N	\N					\N	\N
16	2024-05-14 03:31:14.742	2024-05-14 03:31:14.742	16	\N	\N	\N	\N					\N	\N
17	2024-05-14 03:41:09.81	2024-05-14 03:41:09.81	17	\N	\N	\N	\N					\N	\N
18	2024-05-14 03:50:18.953	2024-05-14 03:50:18.953	18	\N	\N	\N	\N					\N	\N
19	2024-05-14 04:35:01.747	2024-05-14 04:35:01.747	19	\N	\N	\N	\N					\N	\N
20	2024-05-14 04:38:09.301	2024-05-14 04:38:09.301	20	\N	\N	\N	\N					\N	\N
21	2024-05-14 06:07:36.608	2024-05-14 06:07:36.608	21	\N	\N	\N	\N					\N	\N
22	2024-05-14 06:21:51.455	2024-05-14 06:21:51.455	22	\N	\N	\N	\N					\N	\N
23	2024-05-14 06:23:37.416	2024-05-14 06:23:37.416	23	\N	\N	\N	\N					\N	\N
24	2024-05-14 06:28:14.907	2024-05-14 06:28:14.907	24	\N	\N	\N	\N					\N	\N
25	2024-05-14 06:32:15.968	2024-05-14 06:32:15.968	25	\N	\N	\N	\N					\N	\N
\.


--
-- Data for Name: ContractFinancialDetail; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractFinancialDetail" (id, "updateadAt", "createdAt", itemid, "currencyValue", "currencyPercent", "billingDay", "billingQtty", "billingFrequencyid", "measuringUnitid", "paymentTypeid", "billingPenaltyPercent", "billingDueDays", remarks, "guaranteeLetter", "guaranteeLetterCurrencyid", "guaranteeLetterDate", "guaranteeLetterValue", "contractItemId", active, price, currencyid, "advancePercent", "goodexecutionLetter", "goodexecutionLetterBankId", "goodexecutionLetterCurrencyId", "goodexecutionLetterDate", "goodexecutionLetterInfo", "goodexecutionLetterValue", "guaranteeLetterBankId", "guaranteeLetterInfo") FROM stdin;
1	2024-05-14 04:10:20.853	2024-05-14 04:10:20.853	1	\N	0	1	1	3	3	2	1	10		\N	\N	\N	0	3	t	555	2	5	f	\N	\N	\N		\N	\N	
2	2024-05-14 06:03:13.655	2024-05-14 06:03:13.655	1	\N	0	1	1	3	1	2	3	10		\N	\N	\N	0	7	t	333	2	30	f	\N	\N	\N		\N	\N	
3	2024-05-14 06:26:22.39	2024-05-14 06:26:22.39	1	\N	0	1	1	3	1	2	3	10		\N	\N	\N	0	9	t	3332	2	3	f	\N	\N	\N		\N	\N	
4	2024-05-14 06:28:51.102	2024-05-14 06:28:51.102	1	\N	0	1	1	3	1	2	5	10		\N	\N	\N	0	10	t	500	3	5	f	\N	\N	\N		\N	\N	
5	2024-05-14 06:34:04.775	2024-05-14 06:34:04.775	1	\N	0	1	1	4	2	2	2	10		t	2	2024-05-12 21:00:00	222	11	t	555	2	2	t	2	1	2024-05-20 21:00:00	2222	22222	3	222
\.


--
-- Data for Name: ContractFinancialDetailSchedule; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractFinancialDetailSchedule" (id, "updateadAt", "createdAt", itemid, date, "measuringUnitid", "billingQtty", "totalContractValue", "billingValue", "isInvoiced", "isPayed", currencyid, active, "contractfinancialItemId") FROM stdin;
1	2024-05-14 04:10:20.859	2024-05-14 04:10:20.859	1	2024-05-01 00:00:00	3	1	555	555	f	f	2	t	1
2	2024-05-14 06:28:51.106	2024-05-14 06:28:51.106	1	2024-05-01 00:00:00	1	1	500	500	f	f	3	t	4
3	2024-05-14 06:28:51.106	2024-05-14 06:28:51.106	1	2024-06-01 00:00:00	1	1	500	500	f	f	3	t	4
4	2024-05-14 06:28:51.106	2024-05-14 06:28:51.106	1	2024-07-01 00:00:00	1	1	500	500	f	f	3	t	4
5	2024-05-14 06:28:51.106	2024-05-14 06:28:51.106	1	2024-08-01 00:00:00	1	1	500	500	f	f	3	t	4
6	2024-05-14 06:28:51.106	2024-05-14 06:28:51.106	1	2024-09-01 00:00:00	1	1	500	500	f	f	3	t	4
7	2024-05-14 06:28:51.106	2024-05-14 06:28:51.106	1	2024-10-01 00:00:00	1	1	500	500	f	f	3	t	4
8	2024-05-14 06:28:51.106	2024-05-14 06:28:51.106	1	2024-11-01 00:00:00	1	1	500	500	f	f	3	t	4
9	2024-05-14 06:28:51.106	2024-05-14 06:28:51.106	1	2024-12-01 00:00:00	1	1	500	500	f	f	3	t	4
10	2024-05-14 06:34:04.779	2024-05-14 06:34:04.779	1	2024-05-01 00:00:00	2	1	555	555	f	f	2	t	5
11	2024-05-14 06:34:04.779	2024-05-14 06:34:04.779	1	2024-08-01 00:00:00	2	1	555	555	f	f	2	t	5
\.


--
-- Data for Name: ContractItems; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractItems" (id, "updateadAt", "createdAt", "contractId", itemid, active, "billingFrequencyid", "currencyValue", currencyid) FROM stdin;
1	2024-05-13 14:16:29.125	2024-05-13 14:16:29.125	1	1	t	3	1000	2
2	2024-05-13 16:25:47.944	2024-05-13 16:25:47.944	1	1	t	3	1000	2
3	2024-05-14 04:10:20.838	2024-05-14 04:10:20.838	11	1	t	3	555	2
4	2024-05-14 05:50:32.328	2024-05-14 05:50:32.328	20	1	t	3	0	2
5	2024-05-14 06:00:29.998	2024-05-14 06:00:29.998	20	1	t	3	0	2
6	2024-05-14 06:00:47.597	2024-05-14 06:00:47.597	20	1	t	3	0	2
7	2024-05-14 06:03:13.651	2024-05-14 06:03:13.651	1	1	t	3	333	2
8	2024-05-14 06:08:09.599	2024-05-14 06:08:09.599	21	1	t	3	0	2
9	2024-05-14 06:26:22.381	2024-05-14 06:26:22.381	23	1	t	3	3332	2
10	2024-05-14 06:28:51.097	2024-05-14 06:28:51.097	24	1	t	3	500	3
11	2024-05-14 06:34:04.771	2024-05-14 06:34:04.771	25	1	t	4	555	2
\.


--
-- Data for Name: ContractStatus; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractStatus" (id, name) FROM stdin;
1	In lucru
2	Activ
3	Finalizat
4	Reziliat
5	Anulat
\.


--
-- Data for Name: ContractTasks; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTasks" (id, "updateadAt", "createdAt", "taskName", "contractId", due, notes, "assignedId", "requestorId", "statusId", rejected_reason, "taskPriorityId", type, uuid) FROM stdin;
1	2024-05-13 17:44:13.355	2024-05-13 17:44:13.355	werew	15	2024-05-13 17:43:49.155	<p>wer</p>	4	3	1		1	action_task	
2	2024-05-14 04:11:51.973	2024-05-14 04:11:51.973	Contracte dep. IT	11	2024-05-14 04:11:26.037	<p>rrr</p>	3	4	1		2	action_task	
3	2024-05-14 06:33:00.972	2024-05-14 06:33:00.972	eee	25	2024-05-14 06:32:45.052	<p>eee</p>	3	4	1	eee	1	action_task	
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
2	1 zi inainte de data limită	1
3	2 zile inainte de data limită	2
4	3 zile inainte de data limită	3
5	4 zile inainte de data limită	4
6	5 zile inainte de data limită	5
\.


--
-- Data for Name: ContractTasksStatus; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTasksStatus" (id, name, "Desription") FROM stdin;
1	In lucru	
2	Finalizat	
3	Respins	
4	Anulat	
\.


--
-- Data for Name: ContractTemplates; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractTemplates" (id, "updateadAt", "createdAt", name, active, "contractTypeId", notes, content) FROM stdin;
1	2024-05-13 17:28:14.534	2024-05-13 17:28:14.534	CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI 	t	3		<p><strong>CONTRACT PRESTARI SERVICII IN TEHNOLOGIA INFORMATIEI&nbsp;</strong></p><p><strong>NR.: </strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">ContractNumber</span><strong>/</strong><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">SignDate</span></p><p>Intre:&nbsp;</p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">PartnerName</span> cu sediul social in Bucureşti, sectorul 3, Str. Vlad Judeţul nr. 2, camera nr. 1,&nbsp;bloc V14A, scara 2, etaj 1, ap. 33, adresa email: razvan.mustata@gmail.com, inregistrata la Registrul&nbsp;Comertului cu nr. J40/2456/2017, CUI 37130972, reprezentata legal prin Razvan Mihai Mustata Administrator, in calitate de prestator („<strong>Prestatorul</strong>"), pe de o parte; <strong>si&nbsp;</strong></p><p><span style="background-color: rgb(42, 50, 61); color: rgba(255, 255, 255, 0.87);">EntityName</span><strong>, </strong>persoană juridică română, cu sediul în Comuna Dobroeşti, Sat Fundeni, str. Dragonul Roşu, nr. 1-10, etaj 3, biroul nr. 2-4, Centrul Comercial Dragonul Roşu Megashop, judeţ Ilfov, înregistrată la Registrul Comerţului sub nr. J23/227/2002, Cod de Înregistrare Fiscala RO6951013, reprezentata legal prin Mihaela Istrate - Director General, denumită în cele ce urmează<strong> </strong>(<strong>„Beneficiarul</strong>")<strong>, </strong>pe de alta parte,&nbsp;</p><p>Denumite in continuare, individual, „<strong>Partea</strong>" si, in mod colectiv, „<strong>Partile</strong>", au incheiat prezentul&nbsp;Contract prestari servicii in tehnologia informatiei (“<strong>Contractul</strong>”), dupa cum urmeaza:&nbsp;</p><p><strong>Art. 1. Dispoziții generale&nbsp;</strong></p><p>1.1. În aplicarea caracterului independent al activităţilor desfăşurate în temeiul prezentului Contract,&nbsp;Părţile înţeleg şi convin ca niciuna dintre Părţi nu va solicita celeilalte Părţi şi nu va suporta niciun fel&nbsp;de cheltuieli aferente unor elemente pe care legislaţia română le consideră a fi de natură a reflecta&nbsp;natura dependentă a unei activităţi economice. &nbsp;</p><p>1.2. Pe durata prezentului Contract, Prestatorul va furniza Serviciile prevăzute în Contract. &nbsp;</p><p>1.3. Prestatorul îşi va suporta propriile sale cheltuieli în interesul desfăşurării activităţii, precum orice&nbsp;tipuri de cheltuieli aferente:&nbsp;</p><p>a) deplasării de la/la sediul Părţilor sau al altor persoane fizice/juridice, &nbsp;</p><p>b) timpului de odihnă, în care Parţile nu-şi execută prestaţiile unele faţă de altele, c) imposibilităţii temporare de realizare a prestaţiilor contractuale ca urmare a unui concediu&nbsp;medical sau oricăror cauze asemenătoare, &nbsp;</p><p>d) oricăror altor situaţii de natura celor prevăzute la alin. 1-3.&nbsp;</p><p>1.4. Serviciile vor fi prestate de Prestator din orice locatie adecvata, folosind baza materiala a&nbsp;Prestatorului (statie de lucru, conexiune internet, software specializat de dezvoltare, software&nbsp;specializat de testare etc.), iar livrabilele vor fi furnizate electronic Beneficiarului (prin email sau&nbsp;încărcare pe serverele specializate ale Beneficiarului).&nbsp;</p><p><strong>Art. 2. Obiectul Contractului&nbsp;</strong></p><p>2.1. Prestatorul se obliga sa furnizeze, la solicitarea Beneficiarului si in beneficiul acestuia, servicii de&nbsp;integrare a sistemului <strong>Charisma </strong>cu platforma<strong>/</strong>aplicația <strong>CEC Bank</strong>, pentru export extrase de cont și&nbsp;efectuare plăți în sistem internet banking („<strong>Serviciile</strong>”).</p><p>P a g e 2 | 6&nbsp;</p><p><strong>Art. 3. Obligatiile Prestatorului&nbsp;</strong></p><p>Prestatorul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) sa presteze Serviciile catre Beneficiar conform solicitarilor acestuia si sa asigure&nbsp;finalizarea corespunzatoare si in timp util a acestora, la standardele de calitate cerute si&nbsp;in termenele agreate;&nbsp;</p><p>b) sa furnizeze Serviciile spre satisfactia rezonabila a Beneficiarului, Beneficiarul putand&nbsp;solicita Prestatorului sa rectifice orice Servicii care au fost prestate in mod&nbsp;necorespunzator; &nbsp;</p><p>c) pe toată perioada realizării obligaţiilor prezentului Contract, să comunice Beneficiarului,&nbsp;orice modificare cu privire la sediul social, denumire, divizare, fuziune;&nbsp;</p><p>d) să presteze Serviciile prin utilizarea doar a propriilor sale bunuri şi/sau capitaluri (spaţii&nbsp;de birouri/producţie, echipamente, aparatură şi oricare altele asemenea);&nbsp;</p><p>e) să presteze serviciile cu respectarea principiului independenţei activităţii desfăşurate de&nbsp;Prestator consfinţită de dispoziţiile art. 4 lit.a) din O.U.G. nr. 44/2008.&nbsp;</p><p><strong>Art.4. Obligatiile Beneficiarului&nbsp;</strong></p><p>Beneficiarul isi asuma urmatoarele obligatii:&nbsp;</p><p>a) în sensul Art. 3, lit. e), Partile inteleg si convin ca nu se afla si nici nu vor intra intr-o relatie&nbsp;de subordonare una fata de cealalta, fata de organele de conducere ale celeilalte Parti sau&nbsp;fata de alte entitati care detin controlul asupra/ sunt detinute de cealalta Parte;&nbsp;</p><p>b) sa puna la dispozitia Prestatorului informatiile solicitate de acesta, legate de activitatea&nbsp;Beneficiarului, care sunt necesare pentru buna executare a serviciilor asumate de&nbsp;Prestator;&nbsp;</p><p>c) sa plateasca Prestatorului, in termenii stabiliti prin prezentul Contract, pretul prevazut&nbsp;pentru Serviciile prestate, pe baza facturii emise de Prestator, insotita de devizul de lucru,&nbsp;aprobat de Beneficiar.&nbsp;</p><p><strong>Art. 5. Pretul Contractului și modalitatea de plată&nbsp;</strong></p><p>5.1. În schimbul Serviciilor prestate, Beneficiarul se obliga sa plateasca Prestatorului remuneratia&nbsp;datorată în cuantum de <strong>800(optsute) Euro</strong>. Prestatorul nu este plătitor de TVA.&nbsp;</p><p>5.2. Plata Serviciilor se va face in baza unui deviz agreat de ambele Parti care atesta serviciile&nbsp;efectuate, durata lor si termenii de calitate, deviz care va fi furnizat de catre Prestator Beneficiarului&nbsp;la data emiterii facturii fiscale.&nbsp;</p><p>5.3. Plata remunerației datorate Prestatorului se va face la finalizare Serviciilor, în termen de&nbsp;maximum 10 (zece) zile lucrătoare de la data acceptării la plată a facturii fiscale emise de Prestator.&nbsp;</p><p>5.4. Plata se efectueaza în contul Prestatorului cod RO17INGB0000999906676339 deschis la ING&nbsp;BANK NV pe numele Prestatorului.&nbsp;</p><p>P a g e 3 | 6&nbsp;</p><p><strong>Art.6. Durata Contractului&nbsp;</strong></p><p>6.1. Contractul își produce efectele de la data semnării prezentului inscris de către ambele Părți și&nbsp;este valabil până la îndeplinirea tuturor obligațiilor contractuale.&nbsp;</p><p>6.2. Prestatorul se angajează ca, până la data de <strong>20.02.2024</strong>, să finalizeze Serviciile la care se&nbsp;angajează prin prezentul Contract (“<strong>Termen de finalizare</strong>”)&nbsp;</p><p>6.3. Termenul de finalizare este ferm.&nbsp;</p><p>6.4. In cazul in care Prestatorul nu isi indeplineste corespunzător obligatiile asumate prin Contract,&nbsp;Beneficiarul este indreptatit sa perceapa penalitati de intarziere de 0,5% pe zi de intarziere, calculat&nbsp;din valoarea totala a Contractului. In cazul in care Beneficiarul nu onoreaza plata in termenii prevazuți&nbsp;prin Contract, acesta are obligatia de a plati penalitati de intarziere de 0,5% pe zi de intarziere,&nbsp;calculat din suma datorată. Cuantumul penalităților poate depăși valoarea la care ele au fost calculate.&nbsp;</p><p><strong>Art.7. Încetarea Contractului&nbsp;</strong></p><p>7.1. Prezentul Contract încetează în oricare din următoarele modalităţi:&nbsp;</p><p>(a) prin acordul scris al Părţilor;&nbsp;</p><p>(b) prin ajungerea la termen și/sau îndeplinirea tuturor obligațiilor contractuale; (c) prin demararea procedurilor de faliment, dizolvare sau lichidare a oricăreia dintre Părţi; (d) în caz de forţa majoră, în condițiile legii;&nbsp;</p><p>(e) prin denuntarea unilaterala a Contractului de catre Beneficiar, oricand, indiferent de motiv,&nbsp;transmitand Prestatorului o notificare prealabila cu minim 10 (zece) zile calendaristice înainte&nbsp;de data la care operează încetarea Contractului;&nbsp;</p><p>(f) prin cesionarea de către Prestator a drepturile şi obligaţiilor sale prevăzute prin Contract, fără&nbsp;acordul scris, expres și prealabil al Beneficiarului;&nbsp;</p><p>(g) prin rezilierea unilaterală de către oricare dintre Părți, în baza unei notificări de reziliere&nbsp;transmisă celeilalte Părți conform Art. 1.552 Codul Civil, în măsura în care acesta nu&nbsp;îndeplineşte sau îndeplineşte în mod necorespunzător obligatiile sale şi nu le remediază în&nbsp;termenul indicat de catre cealaltă Parte;&nbsp;</p><p>7.2. Încetarea Contractului nu va avea niciun efect asupra obligațiilor deja scadente între Părți la data&nbsp;survenirii acesteia.&nbsp;</p><p>7.3. Prestatorul se afla de drept in inatrziere odata cu implinirea Termenului de finalizare. 7.4. Decalarea termenelor de executie determina decalarea corespunzatoare a platilor.&nbsp;</p><p><strong>Art. 8. Forta majora&nbsp;</strong></p><p>8.1. Forta majora exonereaza de raspundere Partea care o invoca, dar numai in masura si pentru&nbsp;perioada in care Partea este impiedicata sau intarziata sa-si execute obligatia din pricina situatiei de&nbsp;forta majora. Partea care invoca forta majora va depune toate eforturile rezonabile pentru a reduce&nbsp;cat mai mult posibil efectele rezultand din forta majora.&nbsp;</p><p>8.2. Forta majora exonereaza de raspundere Partea care o invoca, in conditiile legii, daca o comunica&nbsp;in scris, celeilalte Parti in termen de 15 zile de la producere si o dovedeste printr-un certificat oficial,&nbsp;in termen de 15 de zile de la data invocarii ei.&nbsp;</p><p>8.3. Prin forta majora se inteleg toate evenimentele si/sau imprejurarile independente de vointa&nbsp;partii care invoca forta majora, imprevizibile si de neinlaturat si care, survenind dupa incheierea&nbsp;contractului, impiedica ori intirzie, total sau partial, indeplinirea obligatiilor izvorind din acest&nbsp;</p><p>P a g e 4 | 6&nbsp;</p><p>contract.&nbsp;</p><p>8.4. Pentru orice intarziere si/sau neindeplinire a obligatiilor contractuale de catre oricare din Parti&nbsp;ca urmare a situatiei de forta majora, niciuna din Parti nu va fi indreptatita sa pretinda celeilalte Parti&nbsp;penalitati, dobanzi, ori despagubiri care altfel ar fi fost platibile.&nbsp;</p><p>8.5. Daca, datorita situatiei de forta majora, una din Parti este impiedicata sa-si indeplineasca, total&nbsp;sau partial obligatiile sale contractuale pe o perioada mai mare 1 luna, atunci oricare Parte va avea&nbsp;dreptul, in lipsa unei alte intelegeri, sa rezilieze contractul, printr-o notificare scrisa adresata&nbsp;celeilalte Parti. In acesta situatie, Partile vor stabili consecintele rezilierii.&nbsp;</p><p><strong>Art. 9. Notificari, adrese, comunicari&nbsp;</strong></p><p>9.1. Orice adresă, notificare, comunicare sau cerere făcută în legătură cu executarea prezentului&nbsp;Contract vor fi făcute în scris.&nbsp;</p><p>9.2. Orice adresă, notificare, comunicare sau cerere este consideră valabil făcută, dacă va fi transmisă&nbsp;celeilalte Părți la adresa menționată în prezentul Contract, prin poștă, cu scrisoare recomandată cu&nbsp;confirmare de primire.&nbsp;</p><p>9.3. Toate aceste comunicări se pot face și prin fax, e-mail, cu condiția confirmării în scris a primirii&nbsp;lor. &nbsp;</p><p>9.4. Toate notificările şi comunicările privind prezentul Contract vor fi trimise la adresele mentionate&nbsp;in preambulul Contractului.&nbsp;</p><p>9.5. În cazul în care o Parte își schimbă datele de contact, aceasta are obligația de a notifica acest&nbsp;eveniment celeilalte Părți în termen de maxim 1 zi lucrătoare, calculat de la momentul producerii&nbsp;schimbării, în caz contrar considerându-se că scrisoarea/notificarea/cererea a fost trimisă în mod&nbsp;valabil la datele cunoscute în momentul încheierii Contractului.&nbsp;</p><p>9.6. Orice adresa, notificare, comunicare sau cerere transmisă prin fax/e-mail se va considera ca fiind&nbsp;trimisă în prima zi lucrătoare după cea în care a fost expediată;&nbsp;</p><p>9.7. Data la care se va considera primită o notificare/adresa/cerere/comunicare este data menționată&nbsp;în raportul de confirmare.&nbsp;</p><p><strong>Art. 10. Litigii&nbsp;</strong></p><p>10.1. Prezentul Contract este guvernat de legea română.&nbsp;</p><p>10.2. Orice neînţelegere rezultată din valabilitatea, executarea şi interpretarea prezentului Contract&nbsp;va fi soluţionată în mod amiabil. Când aceasta nu este posibilă, litigiul va fi depus spre soluţionare&nbsp;instantelor competente de la sediul Beneficiarului.&nbsp;</p><p><strong>Art.11. CLAUZA DE CONFIDENȚIALITATE SI DE PROTECTIE A DATELOR PERSONALE (GDPR).&nbsp;</strong></p><p>Fiecare Parte se obligă să nu divulge terţelor persoane, fără acordul prealabil exprimat în scris al&nbsp; celeilalte Parţi, informaţia obţinută în procesul executării prezentului Contract, precum şi să o&nbsp; utilizeze numai în scopurile executării prezentului Contract. Obligaţia nu se aplică informaţiei: a.&nbsp; divulgate la solicitarea unor autoritati publice cu atributii, făcută în conformitate cu legislaţia în&nbsp; vigoare; b. care este de domeniul public la momentul divulgării; c. divulgate în cadrul unui proces&nbsp; judiciar între Parţi privind acest Contract; d. divulgate acţionarilor Părţii, persoanelor cu funcţii de&nbsp; răspundere, salariaţilor, reprezentanţilor, agenţilor, consultanţilor, auditorilor, cedenţilor,&nbsp;</p><p>P a g e 5 | 6&nbsp;</p><p>succesorilor şi/sau întreprinderilor afiliate ale Parţii care sunt implicate în executarea prezentului&nbsp; Contract, referitor la care Partea va trebui:- să limiteze divulgarea informaţiei numai către cei ce au&nbsp; nevoie de ea pentru îndeplinirea obligaţiilor sale faţă de Parte;- sa asigure folosirea informaţiei&nbsp; exclusiv in scopurile nemijlocit legate de ceea pentru ce informaţia este divulgata;- sa informeze toate&nbsp; aceste persoane privind obligaţia lor de a păstra confidenţialitatea informaţiei în modul stabilit de prezentul Contract.&nbsp;</p><p>Sunt considerate informații confidențiale și fac obiectul prezentelor clauze, datele de identificare&nbsp; (nume, semnătură, serie și număr CI etc.) ale reprezentanților Părților, care se vor regăsi pe&nbsp; documentele emise de (schimbate între) Parți în perioada derulării Contractului și care nu sunt de&nbsp; domeniul public la momentul divulgării. Prelucrarea de către Părți a datelor cu caracter personal ale&nbsp; persoanelor vizate mai sus se va realiza cu respectarea principiilor și drepturilor acestora care decurg&nbsp; din punerea în aplicare a REGULAMENTUL (UE) 2016/679 AL PARLAMENTULUI EUROPEAN ȘI AL&nbsp; CONSILIULUI privind protecția persoanelor fizice în ceea ce privește prelucrarea datelor cu caracter&nbsp; personal – GDPR. În spiritul GDPR, Părțile au următoarele drepturi de acces la datele personale ale&nbsp; angajaților/reprezentanților proprii, operate de cealaltă Parte:a) Dreptul de acces la date; b) reptul&nbsp; la rectificarea datelor; c) Dreptul la ștergerea datelor; d)Dreptul la restricționarea prelucrării; e)&nbsp; Dreptul la portabilitatea datelor; f) Dreptul de opoziție la prelucrarea datelor; g) Dreptul de a nu fi&nbsp; supus unor decizii automatizate, inclusiv profilarea; h) Dreptul la notificarea destinatarilor privind&nbsp; rectificarea, ștergerea ori restricționarea datelor cu caracter personal. &nbsp;</p><p>Conform legislației naționale în vigoare în domeniu, datele personale solicitate de beneficiar sunt&nbsp; necesare pentru buna derulare a Contractului (completarea facturilor, documentelor contabile) și nu&nbsp; vor fi folosite în alte scopuri. &nbsp;</p><p>Datele personale obținute sunt procesate în bazele de date și pe serverele Niro Investment S.A. (societate afiliata), pe întreaga durată a raporturilor contractuale și ulterior, conform politicilor&nbsp; interne, pe durata necesară îndeplinirii obligațiilor legale ce ii revin. Respectarea cerințelor legale&nbsp; aplicabile sunt permanent monitorizate, inclusiv prin Responsabilul de protecție a datelor cu caracter&nbsp; personal ce poate fi contactat la dpo@nirogroup.ro. Reclamațiile privind posibila încălcare a&nbsp; drepturilor privind prelucrarea datelor cu caracter personal pot fi adresate Autorității Naționale de&nbsp; Supraveghere a Prelucrării Datelor cu Caracter Personal la adresa www.dataprotection.ro.&nbsp;</p><p>Oricare dintre Părţile contractante se obligă, în termenii şi condiţiile prezentului Contract, să păstreze&nbsp; strict confidenţiale, pe durata Contractului şi după incetarea acestuia, toate datele şi informaţiile,&nbsp; divulgate în orice manieră de către cealaltă Parte, în executarea Contractului. Excepţie de la prezenta&nbsp; obligaţie sunt cazurile în care divulgarea este necesară pentru executarea Contractului şi se face&nbsp; numai avand consimţământul scris, expres si prealabil al celeilalte Părţi sau daca divulgarea este&nbsp; solicitată, în mod legal, de către autorităţile de drept.&nbsp;</p><p>În cazul în care oricare dintre Părţi va încălca obligaţia de confidenţialitate, aceasta va fi obligată la&nbsp; plata de daune-interese în favoarea Părţii prejudiciate.&nbsp;</p><p><strong>Art.12. Cesiunea Contractului&nbsp;</strong></p><p>12.1. Prezentul Contract are caracter <em>intuitu personae </em>in privinta Prestatorului; acesta nu poate&nbsp;transmite unei terţe persoane, total sau parţial, drepturile şi obligaţiile ce ii revin prin prezentul&nbsp;Contract, decât dacă a obţinut acordul scris și prealabil al Beneficiarului, care acord trebuie transmis&nbsp;Prestatorului în termen de 5 (cinci) zile lucrătoare de la momentul primirii notificării. În lipsa unui&nbsp;</p><p>P a g e 6 | 6&nbsp;</p><p>răspuns scris și expres exprimat în acest sens, se consideră că Partea nu consimte la cesiunea&nbsp;Contractului şi aceasta nu poate avea loc. &nbsp;</p><p><strong>Art. 13. Clauze finale&nbsp;</strong></p><p>13.1. Partile sunt de drept in intarziere in cazul neindeplinirii sau indeplinirii necorespunzatoare a&nbsp;oricareia din obligatiile ce le revin potrivit Contractului. &nbsp;</p><p>13.2. Reprezentanţii Părţilor declară că sunt pe deplin împuterniciţi pentru semnarea Contractului&nbsp;şi că Partea pe care o reprezintă este valabil înregistrată şi are deplină capacitate pentru încheierea&nbsp;prezentului acord şi pentru exercitarea drepturilor şi executarea obligaţiilor prevăzute prin acesta. 13.3. Partile declara ca toate prevederile Contractului au fost negociate cu buna–credinta, le-au&nbsp;citit, si le-au asumat si sunt de acord cu acestea asa cum sunt consemnate prin prezentul inscris.&nbsp;13.4. Ambele Parti declara ca isi asuma, pe toata durata contractuala, riscul schimbarii&nbsp;imprejurarilor (de orice natura- inclusiv, dar fara a se limita la, cele politice, economice, comerciale si&nbsp;financiare) existente la data incheierii Contractului, cu respectarea prevederilor Art. 1271 Cod civil.&nbsp;13.5. Prezentul Contract este supus legii romane si interpretat in conformitate cu prevederile&nbsp;acesteia. Orice litigiu, controversa sau pretentie a Partilor, decurgand din sau in legatura cu prezentul&nbsp;Contract si care nu a fost solutionata de Parti in mod amiabil, va fi supusa, spre solutionare, instantelor&nbsp;judecatoresti competente din Bucuresti. &nbsp;</p><p>13.6. Contract poate fi modificat exclusiv prin incheierea de acte aditionale.&nbsp;13.7. Prevederile contractuale sunt integral obligatorii pentru Partile semnatare si succesorii lor in&nbsp;drepturi si obligatii. &nbsp;</p><p>Prezentul Contract a fost incheiat in 2 (două) exemplare astazi, 01.02.2024, cate un exemplar pentru&nbsp;fiecare Parte.&nbsp;</p><p>Beneficiar, \t\t\t\t\t\tPrestator, &nbsp;</p><p><strong>NIRO INVESTMENT S.A. \t\t\t\tSOFTHUB AG S.R.L. </strong>Director General, \t\t\t\t\tAdministrator,&nbsp;</p><p><strong>Mihaela Istrate \t\t\t\t\tRazvan Mihai Mustata</strong>&nbsp;</p>
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
33	Contracte de Vanzare-Cumparare
34	Contracte de inchiriere
35	Contracte de servicii
36	Contracte de parteneriat
37	Contracte de colaborare
38	Contracte de constructie
39	Contracte de licentiere
40	Contracte de franciză
41	Contracte de imprumut
42	Contracte de agent
43	Contracte de dezvoltare Software
44	Contracte de asigurare
45	Contracte imobiliare
46	Contracte de mentenanta
47	Contracte abonament
48	Contract de schimb
49	Contract de report
50	Contract de antrepriză
51	Contract de asociere în participație
52	Contract de transport
53	Contract de mandat
54	Contract de comision
55	Contract de consignație
56	Contract de agenție
57	Contract de intermediere
58	Contract de depozit
59	Contract de cont curent
60	Contract de joc și pariu
61	Contract de donație
62	Contract de fiducie
63	Contract de leasing
64	Contract de factoring
65	Contracte de Vanzare-Cumparare
66	Contracte de inchiriere
67	Contracte de servicii
68	Contracte de parteneriat
69	Contracte de colaborare
70	Contracte de constructie
71	Contracte de licentiere
72	Contracte de franciză
73	Contracte de imprumut
74	Contracte de agent
75	Contracte de dezvoltare Software
76	Contracte de asigurare
77	Contracte imobiliare
78	Contracte de mentenanta
79	Contracte abonament
80	Contract de schimb
81	Contract de report
82	Contract de antrepriză
83	Contract de asociere în participație
84	Contract de transport
85	Contract de mandat
86	Contract de comision
87	Contract de consignație
88	Contract de agenție
89	Contract de intermediere
90	Contract de depozit
91	Contract de cont curent
92	Contract de joc și pariu
93	Contract de donație
94	Contract de fiducie
95	Contract de leasing
96	Contract de factoring
\.


--
-- Data for Name: ContractWFStatus; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractWFStatus" (id, name, "Desription") FROM stdin;
1	In lucru	
2	Asteapta aprobarea	
3	Aprobat	
4	Respins	
\.


--
-- Data for Name: Contracts; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Contracts" (id, number, start, "end", sign, completion, remarks, "partnersId", "entityId", "entityaddressId", "entitybankId", "entitypersonsId", "parentId", "partneraddressId", "partnerbankId", "partnerpersonsId", "automaticRenewal", "departmentId", "cashflowId", "categoryId", "costcenterId", "statusId", "typeId", "paymentTypeId", "userId", "isPurchasing", "locationId", "statusWFId") FROM stdin;
1	1	2024-05-01 21:00:00	2024-12-31 22:00:00	\N	\N	1	2	1	1	1	1	0	2	2	2	f	1	2	1	2	2	2	\N	3	t	1	\N
2	34	2024-05-01 21:00:00	2024-11-30 22:00:00	\N	\N	444	2	1	1	1	1	0	2	2	2	f	1	2	1	1	1	2	\N	4	t	1	1
3	5	2024-05-01 21:00:00	2024-11-01 22:00:00	\N	\N	5	2	1	1	1	1	0	2	2	2	f	1	2	1	3	1	2	\N	4	t	1	1
4	4	2024-05-01 21:00:00	2024-11-20 22:00:00	\N	\N	4	2	1	1	1	1	0	2	2	2	f	1	1	1	2	1	4	\N	4	t	1	1
5	55	2024-05-13 21:00:00	2024-08-29 21:00:00	\N	\N	5	2	1	1	1	1	0	2	2	2	f	1	1	1	2	1	2	\N	4	t	1	1
6	55	2024-05-01 21:00:00	2024-11-28 22:00:00	\N	\N	345	2	1	1	1	1	0	2	2	2	f	1	4	1	2	1	1	\N	4	t	1	1
7	345	2024-05-01 21:00:00	2024-11-28 22:00:00	\N	\N	345	2	1	1	1	1	0	2	2	2	f	1	2	1	2	1	2	\N	4	t	1	1
8	3543	2024-05-01 21:00:00	2024-12-20 22:00:00	\N	\N	345	2	1	1	1	1	0	2	2	2	f	1	1	1	2	1	2	\N	4	t	1	1
9	3344	2024-05-01 21:00:00	2024-08-28 21:00:00	\N	\N	4	2	1	1	1	1	0	2	2	2	f	1	1	1	4	1	2	\N	4	t	1	1
10	234432432	2024-05-01 21:00:00	2024-11-27 22:00:00	\N	\N	x	2	1	1	1	1	0	2	2	2	f	1	5	1	3	1	1	\N	4	t	1	1
11	234324	2024-05-21 21:00:00	2024-05-23 21:00:00	\N	\N	234	2	1	1	1	1	0	2	2	2	f	1	3	1	4	1	1	\N	4	t	1	1
12	23432	2024-05-01 21:00:00	2024-08-28 21:00:00	\N	\N	jj	2	1	1	1	1	0	2	2	2	f	1	6	1	2	2	3	\N	4	t	1	1
13	32432	2024-05-01 21:00:00	2024-06-27 21:00:00	\N	\N	234	2	1	1	1	1	0	2	2	2	f	1	2	1	2	2	2	\N	4	t	1	2
14	werewrew	2024-05-13 21:00:00	2024-09-26 21:00:00	\N	\N	23	2	1	1	1	1	0	2	2	2	f	1	3	1	3	4	5	\N	3	t	1	4
15	32432	2024-05-01 21:00:00	2024-08-30 21:00:00	\N	\N	23	2	1	1	1	1	0	2	2	2	f	1	2	1	2	1	2	\N	3	t	1	1
16	t	2024-05-01 21:00:00	2024-07-31 21:00:00	\N	\N	t	2	1	1	1	1	0	2	2	2	f	1	5	1	3	3	1	\N	4	t	1	1
17	555	2024-05-14 21:00:00	2024-07-23 21:00:00	\N	\N	5	2	1	1	1	1	0	2	2	2	f	1	6	1	3	4	4	\N	4	t	1	3
18	c3	2024-05-01 21:00:00	2024-07-19 21:00:00	\N	\N	ff	2	1	1	1	1	0	2	2	2	f	1	4	1	3	5	2	\N	4	t	1	1
19	24	2024-05-01 21:00:00	2024-08-07 21:00:00	\N	\N	jj	2	1	1	1	1	0	2	2	2	f	1	3	1	2	2	2	\N	4	t	1	3
20	erre	2024-05-08 21:00:00	2024-08-21 21:00:00	\N	\N	ert	2	1	1	1	1	0	2	2	2	f	1	3	1	3	3	2	\N	4	t	1	2
21	234	2024-05-01 21:00:00	2024-11-27 22:00:00	\N	\N	234	2	1	1	1	1	0	2	2	2	f	1	1	1	3	3	2	\N	4	t	1	3
22	24	2024-05-01 21:00:00	2024-09-29 21:00:00	\N	\N	m	2	1	1	1	1	0	2	2	2	f	1	3	1	4	1	1	\N	4	t	1	1
23	23	2024-05-01 21:00:00	2024-12-26 22:00:00	\N	\N	24	2	1	1	1	1	0	2	2	2	f	1	4	1	3	1	1	\N	4	t	1	1
24	ok	2024-05-01 21:00:00	2024-11-30 22:00:00	\N	\N	24	2	1	1	1	1	0	2	2	2	f	1	1	1	2	3	1	\N	4	t	1	1
25	ok2	2024-05-01 21:00:00	2024-08-22 21:00:00	\N	\N	2	2	1	1	1	1	0	2	2	2	f	1	5	1	2	3	1	\N	4	t	1	2
\.


--
-- Data for Name: ContractsAudit; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ContractsAudit" (auditid, number, "typeId", "costcenterId", "statusId", start, "end", sign, completion, remarks, "categoryId", "departmentId", "cashflowId", "automaticRenewal", "partnersId", "entityId", "parentId", "partnerpersonsId", "entitypersonsId", "entityaddressId", "partneraddressId", "entitybankId", "partnerbankId", "contractAttachmentsId", "paymentTypeId", "contractContentId", id, "operationType", "createdAt", "updateadAt", "userId", "locationId", "statusWFId") FROM stdin;
1	1	2	2	2	2024-05-01 21:00:00	2024-12-31 22:00:00	\N	\N	1	1	1	2	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	1	I	2024-05-13 14:15:09.088	2024-05-13 14:15:09.088	3	1	1
2	34	2	1	1	2024-05-01 21:00:00	2024-11-30 22:00:00	\N	\N	444	1	1	2	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	2	I	2024-05-13 16:22:45.79	2024-05-13 16:22:45.79	4	1	1
3	5	2	3	1	2024-05-01 21:00:00	2024-11-01 22:00:00	\N	\N	5	1	1	2	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	3	I	2024-05-13 16:31:44.298	2024-05-13 16:31:44.298	4	1	1
4	4	4	2	1	2024-05-01 21:00:00	2024-11-20 22:00:00	\N	\N	4	1	1	1	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	4	I	2024-05-13 16:37:51.107	2024-05-13 16:37:51.107	4	1	1
5	55	2	2	1	2024-05-13 21:00:00	2024-08-29 21:00:00	\N	\N	5	1	1	1	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	5	I	2024-05-13 16:46:47.648	2024-05-13 16:46:47.648	4	1	1
6	55	1	2	1	2024-05-01 21:00:00	2024-11-28 22:00:00	\N	\N	345	1	1	4	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	6	I	2024-05-13 16:58:50.855	2024-05-13 16:58:50.855	4	1	1
7	345	2	2	1	2024-05-01 21:00:00	2024-11-28 22:00:00	\N	\N	345	1	1	2	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	7	I	2024-05-13 17:07:31.632	2024-05-13 17:07:31.632	4	1	1
8	3543	2	2	1	2024-05-01 21:00:00	2024-12-20 22:00:00	\N	\N	345	1	1	1	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	8	I	2024-05-13 17:10:06.203	2024-05-13 17:10:06.203	4	1	1
9	3344	2	4	1	2024-05-01 21:00:00	2024-08-28 21:00:00	\N	\N	4	1	1	1	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	9	I	2024-05-13 17:11:30.299	2024-05-13 17:11:30.299	4	1	1
10	234432432	1	3	1	2024-05-01 21:00:00	2024-11-27 22:00:00	\N	\N	x	1	1	5	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	10	I	2024-05-13 17:13:59.769	2024-05-13 17:13:59.769	4	1	1
11	234324	1	4	1	2024-05-21 21:00:00	2024-05-23 21:00:00	\N	\N	234	1	1	3	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	11	I	2024-05-13 17:18:07.246	2024-05-13 17:18:07.246	4	1	1
12	23432	3	2	2	2024-05-01 21:00:00	2024-08-28 21:00:00	\N	\N	jj	1	1	6	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	12	I	2024-05-13 17:29:17.23	2024-05-13 17:29:17.23	4	1	1
13	32432	2	2	2	2024-05-01 21:00:00	2024-06-27 21:00:00	\N	\N	234	1	1	2	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	13	I	2024-05-13 17:36:37.94	2024-05-13 17:36:37.94	4	1	1
14	werewrew	5	3	4	2024-05-13 21:00:00	2024-09-26 21:00:00	\N	\N	23	1	1	3	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	14	I	2024-05-13 17:40:00.297	2024-05-13 17:40:00.297	3	1	1
15	32432	2	2	1	2024-05-01 21:00:00	2024-08-30 21:00:00	\N	\N	23	1	1	2	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	15	I	2024-05-13 17:43:46.797	2024-05-13 17:43:46.797	3	1	1
16	t	1	3	3	2024-05-01 21:00:00	2024-07-31 21:00:00	\N	\N	t	1	1	5	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	16	I	2024-05-14 03:31:14.745	2024-05-14 03:31:14.745	4	1	1
17	555	4	3	4	2024-05-14 21:00:00	2024-07-23 21:00:00	\N	\N	5	1	1	6	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	17	I	2024-05-14 03:41:09.812	2024-05-14 03:41:09.812	4	1	1
18	c3	2	3	5	2024-05-01 21:00:00	2024-07-19 21:00:00	\N	\N	ff	1	1	4	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	18	I	2024-05-14 03:50:18.956	2024-05-14 03:50:18.956	4	1	1
19	24	2	2	2	2024-05-01 21:00:00	2024-08-07 21:00:00	\N	\N	jj	1	1	3	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	19	I	2024-05-14 04:35:01.749	2024-05-14 04:35:01.749	4	1	1
20	erre	2	3	3	2024-05-08 21:00:00	2024-08-21 21:00:00	\N	\N	ert	1	1	3	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	20	I	2024-05-14 04:38:09.303	2024-05-14 04:38:09.303	4	1	1
21	234	2	3	3	2024-05-01 21:00:00	2024-11-27 22:00:00	\N	\N	234	1	1	1	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	21	I	2024-05-14 06:07:36.61	2024-05-14 06:07:36.61	4	1	1
22	24	1	4	1	2024-05-01 21:00:00	2024-09-29 21:00:00	\N	\N	m	1	1	3	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	22	I	2024-05-14 06:21:51.457	2024-05-14 06:21:51.457	4	1	1
23	23	1	3	1	2024-05-01 21:00:00	2024-12-26 22:00:00	\N	\N	24	1	1	4	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	23	I	2024-05-14 06:23:37.419	2024-05-14 06:23:37.419	4	1	1
24	ok	1	2	3	2024-05-01 21:00:00	2024-11-30 22:00:00	\N	\N	24	1	1	1	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	24	I	2024-05-14 06:28:14.909	2024-05-14 06:28:14.909	4	1	1
25	ok2	1	2	3	2024-05-01 21:00:00	2024-08-22 21:00:00	\N	\N	2	1	1	5	f	2	1	\N	2	1	1	2	1	2	\N	\N	\N	25	I	2024-05-14 06:32:15.97	2024-05-14 06:32:15.97	4	1	1
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
\.


--
-- Data for Name: DynamicFields; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."DynamicFields" (id, "updateadAt", "createdAt", fieldname, fieldlabel, fieldorder, fieldtype) FROM stdin;
1	2024-05-14 04:22:01.003	2024-05-14 04:22:01.003	dffInt1	Int1	1	Int
\.


--
-- Data for Name: ExchangeRates; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."ExchangeRates" (id, "updateadAt", "createdAt", date, amount, name, multiplier) FROM stdin;
1	2024-05-14 06:00:00.556	2024-05-14 06:00:00.556	2024-05-14	1	RON	1
2	2024-05-14 06:00:00.564	2024-05-14 06:00:00.564	2024-05-14	1.2566	AED	1
3	2024-05-14 06:00:00.566	2024-05-14 06:00:00.566	2024-05-14	3.0493	AUD	1
4	2024-05-14 06:00:00.568	2024-05-14 06:00:00.568	2024-05-14	2.5444	BGN	1
5	2024-05-14 06:00:00.569	2024-05-14 06:00:00.569	2024-05-14	0.8948	BRL	1
6	2024-05-14 06:00:00.57	2024-05-14 06:00:00.57	2024-05-14	3.3742	CAD	1
7	2024-05-14 06:00:00.573	2024-05-14 06:00:00.573	2024-05-14	5.0892	CHF	1
8	2024-05-14 06:00:00.574	2024-05-14 06:00:00.574	2024-05-14	0.638	CNY	1
9	2024-05-14 06:00:00.575	2024-05-14 06:00:00.575	2024-05-14	0.2006	CZK	1
10	2024-05-14 06:00:00.576	2024-05-14 06:00:00.576	2024-05-14	0.667	DKK	1
11	2024-05-14 06:00:00.577	2024-05-14 06:00:00.577	2024-05-14	0.0981	EGP	1
12	2024-05-14 06:00:00.58	2024-05-14 06:00:00.58	2024-05-14	4.9765	EUR	1
13	2024-05-14 06:00:00.581	2024-05-14 06:00:00.581	2024-05-14	5.7819	GBP	1
14	2024-05-14 06:00:00.582	2024-05-14 06:00:00.582	2024-05-14	1.2855	HUF	100
15	2024-05-14 06:00:00.583	2024-05-14 06:00:00.583	2024-05-14	0.0553	INR	1
16	2024-05-14 06:00:00.584	2024-05-14 06:00:00.584	2024-05-14	2.9611	JPY	100
17	2024-05-14 06:00:00.585	2024-05-14 06:00:00.585	2024-05-14	0.3375	KRW	100
18	2024-05-14 06:00:00.586	2024-05-14 06:00:00.586	2024-05-14	0.2605	MDL	1
19	2024-05-14 06:00:00.586	2024-05-14 06:00:00.586	2024-05-14	0.2758	MXN	1
20	2024-05-14 06:00:00.587	2024-05-14 06:00:00.587	2024-05-14	0.4249	NOK	1
21	2024-05-14 06:00:00.588	2024-05-14 06:00:00.588	2024-05-14	2.7738	NZD	1
22	2024-05-14 06:00:00.588	2024-05-14 06:00:00.588	2024-05-14	1.161	PLN	1
23	2024-05-14 06:00:00.589	2024-05-14 06:00:00.589	2024-05-14	0.0425	RSD	1
24	2024-05-14 06:00:00.589	2024-05-14 06:00:00.589	2024-05-14	0.0504	RUB	1
25	2024-05-14 06:00:00.59	2024-05-14 06:00:00.59	2024-05-14	0.4248	SEK	1
26	2024-05-14 06:00:00.591	2024-05-14 06:00:00.591	2024-05-14	0.1254	THB	1
27	2024-05-14 06:00:00.591	2024-05-14 06:00:00.591	2024-05-14	0.1433	TRY	1
28	2024-05-14 06:00:00.592	2024-05-14 06:00:00.592	2024-05-14	0.1165	UAH	1
29	2024-05-14 06:00:00.592	2024-05-14 06:00:00.592	2024-05-14	4.6156	USD	1
30	2024-05-14 06:00:00.593	2024-05-14 06:00:00.593	2024-05-14	347.3272	XAU	1
31	2024-05-14 06:00:00.594	2024-05-14 06:00:00.594	2024-05-14	6.0959	XDR	1
32	2024-05-14 06:00:00.595	2024-05-14 06:00:00.595	2024-05-14	0.2511	ZAR	1
\.


--
-- Data for Name: Groups; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Groups" (id, "updateadAt", "createdAt", name, description) FROM stdin;
2	2024-05-13 15:59:12.708	2024-05-13 13:12:40.667	Niro	Niro
\.


--
-- Data for Name: Item; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Item" (id, name) FROM stdin;
1	Mentenanta
\.


--
-- Data for Name: Location; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."Location" (id, name) FROM stdin;
1	Traian
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
1	2024-05-13 13:12:07.672	2024-05-13 13:12:07.672	NIRO INVESTMENT SA	RO2456788	J40/23/20422	Activ	Entitate			\N	t
2	2024-05-13 13:17:15.366	2024-05-13 13:16:13.916	SoftHub	ro000001	j4044	Activ	Furnizor			\N	f
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
1	2024-05-13 13:12:07.672	2024-05-13 13:12:07.672	razvan Niro	+40746150001	razvan.mustata@nirogroup.ro	1	Consultant	t
2	2024-05-13 13:16:13.916	2024-05-13 13:16:13.916	Razvan Mustata	0746 150 001	razvan.mustata@gmail.com	2	Administrator	t
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
6	3	4
7	3	3
8	3	2
9	3	1
10	4	4
11	4	3
12	4	2
13	4	1
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."User" (id, name, email, password, "createdAt", picture, status, "updatedAt") FROM stdin;
3	eu	eu@eu.ro	$2b$04$mzZ.wWntysoWnoi4Oa3pwu0fT7UgLa8jbCRN4Dr/wZq1qm0N5SPqG	2024-05-13 13:45:01.553	avatar-1715607901542-333198608.gif	t	2024-05-13 13:45:01.553
4	razvan	razvan.mustata@nirogroup.ro	$2b$04$KBeee/pRFJ4vJbmBKsnzl.cnjoUM1lOfCYuDSQNRCtGQHCC7dsCMu	2024-05-13 16:00:17.863	avatar-1715616017857-165034951.png	t	2024-05-13 16:00:17.863
\.


--
-- Data for Name: WorkFlow; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlow" (id, "updateadAt", "createdAt", "wfName", "wfDescription", status) FROM stdin;
1	2024-05-14 04:23:43.692	2024-05-14 04:23:21.097	Contracte dep. IT	Contracte dep. IT	t
\.


--
-- Data for Name: WorkFlowContractTasks; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowContractTasks" (id, "updateadAt", "createdAt", "contractId", "statusId", "requestorId", "assignedId", "workflowTaskSettingsId", "approvalOrderNumber", duedates, name, reminders, "taskPriorityId", text, uuid) FROM stdin;
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
2	2024-05-14 04:23:43.704	2024-05-14 04:23:43.704	1	departments	Departament	1	ITC
\.


--
-- Data for Name: WorkFlowTaskSettings; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowTaskSettings" (id, "updateadAt", "createdAt", "workflowId", "taskName", "taskNotes", "taskSendNotifications", "taskSendReminders", "taskReminderId", "taskPriorityId", "taskDueDateId") FROM stdin;
1	2024-05-14 04:23:43.706	2024-05-14 04:23:21.108	1	Flux aprobare contracte dep Operational	<p>Test</p>	t	t	2	2	1
\.


--
-- Data for Name: WorkFlowTaskSettingsUsers; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowTaskSettingsUsers" (id, "updateadAt", "createdAt", "workflowTaskSettingsId", "userId", "approvalOrderNumber", "approvalStepName") FROM stdin;
3	2024-05-14 04:23:43.713	2024-05-14 04:23:43.713	1	4	1	p1
4	2024-05-14 04:23:43.714	2024-05-14 04:23:43.714	1	3	2	p2
\.


--
-- Data for Name: WorkFlowXContracts; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."WorkFlowXContracts" (id, "updateadAt", "createdAt", "contractId", "wfstatusId", "ctrstatusId", "workflowTaskSettingsId") FROM stdin;
\.


--
-- Data for Name: _GroupsToPartners; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."_GroupsToPartners" ("A", "B") FROM stdin;
2	1
\.


--
-- Data for Name: _GroupsToUser; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public."_GroupsToUser" ("A", "B") FROM stdin;
2	3
2	4
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: sysadmin
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
c4fcb2a1-491f-4863-8717-2a5fa351800a	ad8576d14b2c62fc95045ce2cd68c064a5e509abfcfe7bcd4663b7deeede4b32	2024-05-13 13:35:16.187259+03	20240131114230_init	\N	\N	2024-05-13 13:35:16.177465+03	1
32951cfe-48b9-4c6f-9993-2f2d83a6b481	23a86e2369db98c99fdec859419347f3fe4e8ecd52e2f689e3c2c3e03a098063	2024-05-13 13:35:15.827133+03	20240104130027_init	\N	\N	2024-05-13 13:35:15.813668+03	1
922ceaaf-7923-45c1-9f6d-393fc70ad408	977ec891876257e28e037c4c9432ef9110adad6c75b9a3f31b73c823c6ae32d3	2024-05-13 13:35:16.006385+03	20240116134140_bank	\N	\N	2024-05-13 13:35:15.999941+03	1
c60cd221-d7b1-4831-805c-ee140a89e0c3	4da2a23903cbbcef13e542877f574cb1a1e01fc341d2bcb4d9571f55c4b57292	2024-05-13 13:35:15.840183+03	20240104133214_init	\N	\N	2024-05-13 13:35:15.827734+03	1
a5274a5c-75d6-41d0-ab9f-4ca77d3fbce8	92a320941ead86308ba6bfa68593da156875e47bf7037ba7acf2667ba46aeb77	2024-05-13 13:35:15.849159+03	20240104141916_init	\N	\N	2024-05-13 13:35:15.841307+03	1
03d99927-4fd0-4f9c-8017-14f039104109	1fdbf30c850caab5676b69dda360e2eb25e79c8b0d9179eaf4f8973287de5ee5	2024-05-13 13:35:16.072349+03	20240126104551_init	\N	\N	2024-05-13 13:35:16.059368+03	1
3bc86898-1f22-42d9-9c27-cbd92ee9d4d7	8879b3c1b4dbc53cec49b5b1069a8cf5fff45819428284d66f75be5e4c6f2219	2024-05-13 13:35:15.880786+03	20240104143603_init	\N	\N	2024-05-13 13:35:15.85014+03	1
23ddaecc-e2d8-409b-be08-2fedca05ca21	7e4715ed7ce572c45c920ff2787e78d219fd9aea0b4899f6af90336a710634dd	2024-05-13 13:35:16.010724+03	20240116135120_bank2	\N	\N	2024-05-13 13:35:16.007139+03	1
eeb1f5b3-b836-4859-bfe2-79f9515229c7	8f2ad4636fb9bd644824bd7438888a640ccd490e838e90f8f35c8aba7e2b93ac	2024-05-13 13:35:15.899382+03	20240108125945_init	\N	\N	2024-05-13 13:35:15.88177+03	1
3c02a56d-d0bb-4f0a-a019-d214da4f6c50	ed60132fe1e6c18d361f612cfca7c420021075dac021c37f2b80bb6324d2a937	2024-05-13 13:35:15.903963+03	20240109101645_without_unique	\N	\N	2024-05-13 13:35:15.900357+03	1
9bd5411c-d6ee-4dd1-ab8e-545c89e27bb0	e1843cee6c521f57dfd32d538f166465e416c06c103956a5f0530e1e48af45c9	2024-05-13 13:35:15.924075+03	20240110101455_nomenclatoare	\N	\N	2024-05-13 13:35:15.904838+03	1
a788f5c6-739b-414d-a8f9-c49e0b7b71b0	39433a0e5c3b9fdf1a8f56bdb14fd7fa2b9b1ca15697b9c16cc9e4c1f92727a5	2024-05-13 13:35:16.015541+03	20240118120039_init	\N	\N	2024-05-13 13:35:16.012019+03	1
b3988299-31a6-49f5-ae86-bc8a2ccd28c7	50258465afcd5d29ce2193d799f3681dfcec8d9cc1dcdbb932fbf1b24f8f9179	2024-05-13 13:35:15.928964+03	20240112153345_add_cat	\N	\N	2024-05-13 13:35:15.924954+03	1
dbea7ab9-e716-4131-a0af-58a050e608e1	a7626cf287742bbe4ca0b3302595a6d8ee01675263ebf7b74d0f16c8e3803f2e	2024-05-13 13:35:15.950537+03	20240114055127_add_lookups	\N	\N	2024-05-13 13:35:15.930242+03	1
2f5bf41f-6c8f-4969-9f74-15aa89b20507	d4de14ee2dfcf17d9908fa793769d1ae8b4452b6e05d026ae8e1815d40562173	2024-05-13 13:35:16.123233+03	20240128161837_init	\N	\N	2024-05-13 13:35:16.115088+03	1
cb516d26-7655-4c35-9921-90eb771f975c	43f7a84ca76a1dd6dea71e1e3c495f1cd9e361ea5ac1ea4b54c928609be101a2	2024-05-13 13:35:15.972913+03	20240115081246_partner	\N	\N	2024-05-13 13:35:15.951641+03	1
de8f6fc4-2eba-4b7b-a927-9ae40a36c745	5dfb88c01f54bdf003872be93ee719948e699b2239aa6c38e0de993fcb291822	2024-05-13 13:35:16.023772+03	20240118120207_init	\N	\N	2024-05-13 13:35:16.016367+03	1
236cbbc1-6e98-4955-af2c-250c60f4eccb	95b3f8c0c67b2e22ee3f5a02ec18fef109827d6f7e30fb9ff214959e369b70b0	2024-05-13 13:35:15.978927+03	20240115081401_partner	\N	\N	2024-05-13 13:35:15.973813+03	1
8c20825f-fa22-45e4-befb-c3ef09422244	07ae453f14f60aa396fa5923109e1e9c7764c5e0583ca7dbc95e7c441f4bad59	2024-05-13 13:35:15.985519+03	20240115092006_init	\N	\N	2024-05-13 13:35:15.979856+03	1
5c70cd52-975e-4d4b-92ea-d191c5319ca6	00b40340787314adf18075a4c719ea9c1fe4630afaaac0c5bb880f887244f724	2024-05-13 13:35:16.076334+03	20240126105841_init	\N	\N	2024-05-13 13:35:16.073269+03	1
5549a97c-5be9-4b93-a6ce-9c4f8bc08bda	be50eef072f565cc3f69431afd017cc9b8b9e1b7628d23f9a4cf0033e6edc4ca	2024-05-13 13:35:15.992929+03	20240116083536_address	\N	\N	2024-05-13 13:35:15.986382+03	1
cdd70a9d-ec2a-4e8a-875a-cbfbff44df2b	39e80257772bdc7ade25a4f4bac482f8077b51864b4b7fdd87efc3da2885e80e	2024-05-13 13:35:16.028234+03	20240118120348_init	\N	\N	2024-05-13 13:35:16.025071+03	1
dc66708a-2214-41f5-ab65-25843fdaf1b4	0720788796ebecfd565f0b688a07def4632bf46a9cbc5d2b7807fc982871d099	2024-05-13 13:35:15.99907+03	20240116100636_address2	\N	\N	2024-05-13 13:35:15.993877+03	1
b14b0054-97d0-42b0-96e4-18c58e0227a3	61ee0d8a5b7b2cb4ad11185acede721e1a342c2cbf56bf9734a8a4dd86e08305	2024-05-13 13:35:16.03407+03	20240118142955_init	\N	\N	2024-05-13 13:35:16.029191+03	1
58b05d04-d2c7-4e87-ae13-cb5bcd7f6dc5	6536256885a20c3fb822093472a941f6c09f5b29345d4920891bf44eaa6cba6c	2024-05-13 13:35:16.038773+03	20240119095713_init	\N	\N	2024-05-13 13:35:16.035229+03	1
8d913c71-b1f7-4f6f-9394-aaa1beb39081	f2aa161f99b17be209b9bfe5d6bd674a2e72a856dd2ff9f1bd7320e457237694	2024-05-13 13:35:16.084857+03	20240126122744_init	\N	\N	2024-05-13 13:35:16.077228+03	1
0d059cfb-0c93-44d9-bc79-78aa349649a0	d6be293aa2ef7a5446954e91ec546a16782eebdf39c74e6bea8154d5518561d0	2024-05-13 13:35:16.048345+03	20240119102921_init	\N	\N	2024-05-13 13:35:16.039792+03	1
42e44014-7d83-45c1-a3f8-c044282a89ce	7678c385cf3ea035dd0497ba02d2953807b7cfd6cb6947a86968ad537cc719cc	2024-05-13 13:35:16.058386+03	20240125113624_init	\N	\N	2024-05-13 13:35:16.049438+03	1
5e1da74c-4aed-4110-9356-729d3b495808	799189d35baa4313617c887d873b3c34edd2aa820ca79a0af5711f8e5584bc75	2024-05-13 13:35:16.169233+03	20240130082940_init	\N	\N	2024-05-13 13:35:16.160025+03	1
530ed750-4fd1-443f-9945-e14fd97938dc	7d4ae120cb9151f649135125b2cc8dfaacf724974836f2002cce719128408d6f	2024-05-13 13:35:16.090847+03	20240126124359_init	\N	\N	2024-05-13 13:35:16.085965+03	1
d5cd3925-9c41-40f5-8110-a5fdbcd2807a	52652cb8679e0232d5df45175aa6732f022e208572110cdfeffb8d7520139332	2024-05-13 13:35:16.128447+03	20240129062205_init	\N	\N	2024-05-13 13:35:16.124406+03	1
56d08122-9efa-43ba-b73c-7ec70c35d95a	658eb499ce0aef6e91cebc84ee16d3bad3d9997495b44100efc8d2a3535252d7	2024-05-13 13:35:16.107269+03	20240128153759_init	\N	\N	2024-05-13 13:35:16.09174+03	1
64c1731c-09e7-4381-beca-7495b9d1c050	6bce4b7971628c4f1e59a5f58920830eabb54d060633600725fcbb4e52ef0903	2024-05-13 13:35:16.114137+03	20240128153945_init	\N	\N	2024-05-13 13:35:16.108246+03	1
d90b3d07-45ac-452e-b2f9-10121ba32723	72466053ded1e79556ea68fe2d65f65aa4b3b1c849b9023e1c3593c115aadcab	2024-05-13 13:35:16.141659+03	20240129070106_init	\N	\N	2024-05-13 13:35:16.129324+03	1
4c19f3bd-6110-46b9-8e6f-d854b7bc1917	9aad9ca02d27fff8e1650c510d86d83cc12262f8f513bd6519824b7b28443e9d	2024-05-13 13:35:16.159042+03	20240129072018_init	\N	\N	2024-05-13 13:35:16.142843+03	1
8c002ed5-be53-48a3-b796-a388c0164919	df4793be4a989e39745bb8ca9478ab1935149c16274d0fc634aa0de3867efd81	2024-05-13 13:35:16.176504+03	20240130083818_init	\N	\N	2024-05-13 13:35:16.1701+03	1
e08edbe4-930c-4ebc-83c9-f7044da106cd	0c0906dcb8391dad5972bbaea86a8d2bad51ced4c152d06d07ef005462046e17	2024-05-13 13:35:16.19723+03	20240201094410_init	\N	\N	2024-05-13 13:35:16.193532+03	1
52077ef4-70ec-4c39-8677-11d70559592d	69c5d55790477b301f0fdf18e4c62219382294902dc53d631cd3d8e42fc53f28	2024-05-13 13:35:16.19221+03	20240201093629_init	\N	\N	2024-05-13 13:35:16.188362+03	1
f4d060da-058f-4a77-bc0a-122289a36de2	8f3747eb875999978dc041819964fc44cc95aa6f30993d4298347e4f64f0a50d	2024-05-13 13:35:16.202006+03	20240201095542_init	\N	\N	2024-05-13 13:35:16.198169+03	1
723a6b7b-f548-416d-b772-d9038742d9cc	e2ebc20c1477adb8c3658642c80736a1d3885306ec19bc02babff0add4e1576d	2024-05-13 13:35:16.206827+03	20240201102051_init	\N	\N	2024-05-13 13:35:16.202789+03	1
514708fc-9aa3-4d2a-adad-bf8dc3927e37	35638aa42bf8eae5e465fb3a938d61e704d2c7949fbc7dd3316f43579825d9f2	2024-05-13 13:35:16.215015+03	20240205065253_init	\N	\N	2024-05-13 13:35:16.207522+03	1
c0f6ba20-c10a-4f42-a427-522ddf62e966	6d58e52871e48b439dfe34583be4e49253c20082ecbfe0104efc31a78af476bb	2024-05-13 13:35:16.22502+03	20240205095417_init	\N	\N	2024-05-13 13:35:16.215934+03	1
02b06532-091c-4142-8f16-ce435998f781	d318c7469a6b6d8252ce8a978e91c6b8a13497bc5e458b4713d3b79900521e68	2024-05-13 13:35:16.234964+03	20240205113433_init	\N	\N	2024-05-13 13:35:16.22595+03	1
18abf946-a6b7-4bf6-a02e-41d939fc2efe	830cc21e3141505a045c668842ed2213c4565140d99dcfd03bf8811755c2bae4	2024-05-13 13:35:16.496795+03	20240220131517_init	\N	\N	2024-05-13 13:35:16.490304+03	1
b11d2f64-c7cb-4376-879c-9541479f5bdd	953cccbd987f900b363e653cfe2def20a9e1ec9a4e6c109cd69bc5a22e261cf3	2024-05-13 13:35:16.240034+03	20240205113712_init	\N	\N	2024-05-13 13:35:16.236115+03	1
d727bf2f-fe97-4fed-b963-a626be8a3549	e019647f6f598f7ef86acb15bacbe24be275e3558fd6371dd5847b7fe5bba0ce	2024-05-13 13:35:16.336823+03	20240212085056_init	\N	\N	2024-05-13 13:35:16.33075+03	1
40dede28-577e-4e09-bbaf-554a8d070dfb	6c4aca507cf7ff9993738a7c7d0f921b0d434feea674ff52073db9c48e5b7049	2024-05-13 13:35:16.257057+03	20240206110336_init	\N	\N	2024-05-13 13:35:16.241074+03	1
b77ef799-3040-4501-950a-e7b1e66a3141	36960761bf8945e0b9aaf2d25d39a97482bc2ff36a1e2fcfee85f718c52d96e9	2024-05-13 13:35:16.261085+03	20240206125522_init	\N	\N	2024-05-13 13:35:16.258017+03	1
4e816c2d-a7d9-40f8-923b-ec806285da50	f4c574e6218885173cc314a56e3a740641e6cb4d546d489b864f0e395c760cab	2024-05-13 13:35:16.411025+03	20240216131812_init	\N	\N	2024-05-13 13:35:16.405889+03	1
19acaf82-b930-4a0d-b3ab-71f06439d20c	5f998307b8fd03ab76eeeaa82ea480a7d4e5eaa8203a8ff09431aa5686d51858	2024-05-13 13:35:16.265029+03	20240206125818_init	\N	\N	2024-05-13 13:35:16.262248+03	1
7768dbfe-6dab-458f-bb1f-356a91eef9de	7fdd2980aef4995dbd048d16c92534034c8b4b34a7853691d3903eb313243c77	2024-05-13 13:35:16.348544+03	20240213090136_init	\N	\N	2024-05-13 13:35:16.337831+03	1
971947bb-836d-45b5-a214-fff26721e8f6	94c2a8c709c3b6c51cfb50a917a19fd7272b2a9780e5af1e2957681b86c5fced	2024-05-13 13:35:16.275146+03	20240207100614_init	\N	\N	2024-05-13 13:35:16.265823+03	1
6fbd3fbb-3e32-41ee-8218-51350d6175f0	d6a162eddbb96991f0f55683123c6e97668648ef39f9a94fae54abe80614dfb7	2024-05-13 13:35:16.2831+03	20240207104440_init	\N	\N	2024-05-13 13:35:16.276105+03	1
ba907bb4-b164-463a-bb87-ae7b975cca8d	af9a72c66447653e81958bc713315f1bffbbcb738d07693529dda46ac6a47df2	2024-05-13 13:35:16.287332+03	20240207105654_init	\N	\N	2024-05-13 13:35:16.284506+03	1
913c65b7-77a8-4501-b558-f439783901ba	51993c60d53428cc9b954f1c94c97c31a80ed28751b0dfc660354554ca053443	2024-05-13 13:35:16.352701+03	20240213090610_init	\N	\N	2024-05-13 13:35:16.34962+03	1
6a48f018-58f0-4645-87e5-6cc11a7d7346	33bce8917466d1bf06cd5aa38b2e93c0bf7a9859d1b85e352aed48bb520bf47f	2024-05-13 13:35:16.295187+03	20240207110138_init	\N	\N	2024-05-13 13:35:16.288214+03	1
2b23faf3-1200-4cfd-b165-40e6ffe2271c	c3c6464ea30a9da42aa4aebee71e025880539966286bf112242bcbf38ad59086	2024-05-13 13:35:16.299513+03	20240207111109_init	\N	\N	2024-05-13 13:35:16.29648+03	1
f3a5bc26-0060-4b4e-b8bc-deafad692f26	87daa102f90741df943e65e9ed96b43b209ac9743f5c12083beb6e8779c5ec5e	2024-05-13 13:35:16.45763+03	20240220091623_init	\N	\N	2024-05-13 13:35:16.446096+03	1
2cb262f4-8878-4500-8f01-5668612c7974	f723b838032e8f790f5a2f1d2ee4c27550b71be8b809540cb9e584d983721f50	2024-05-13 13:35:16.303262+03	20240208130939_init	\N	\N	2024-05-13 13:35:16.300577+03	1
c4a132c9-d939-4d45-88e6-ec448ab924cc	1cf57200905e31d5e96fdcdb7afa1062ea1fb4ac39e816dd636d5d1ff219418a	2024-05-13 13:35:16.364585+03	20240214100544_init	\N	\N	2024-05-13 13:35:16.353731+03	1
9f4138b0-9664-4f44-a244-88e7dd9479f1	6767a6af3ca39854907ae760a129ae4396d4c00dcb59ec19a1ab3b34a4926bf7	2024-05-13 13:35:16.311003+03	20240209131756_init	\N	\N	2024-05-13 13:35:16.304533+03	1
cff23a60-f61b-436c-90b5-69a63c36af5f	058804677db817f2cebe5e426eee5c4be998d2501fde05e8a82435c7cadf72c8	2024-05-13 13:35:16.320535+03	20240212071630_init	\N	\N	2024-05-13 13:35:16.313315+03	1
f583fbd9-038a-41a9-b551-a491945453db	301c44321c0d3958f0475f6d389746b2d9a276d8517cad58c3972aaad9728682	2024-05-13 13:35:16.417513+03	20240220084932_init	\N	\N	2024-05-13 13:35:16.412003+03	1
7c2bfa2d-ba22-4604-93ab-9e91b0a3bd18	cff20eedaeab53a91b6bbe37d8f98579ccdaef2cac1d3e69819f4ca553e84c29	2024-05-13 13:35:16.324259+03	20240212073715_init	\N	\N	2024-05-13 13:35:16.321717+03	1
312bf381-bcd1-4e56-9cb1-1d68d75a9c80	ab2e383159e390310c7283d7798445e01da1a9f3be55f5e740a1a103b24c1211	2024-05-13 13:35:16.371818+03	20240214170817_init	\N	\N	2024-05-13 13:35:16.365508+03	1
fea40d36-96cd-4413-b906-f8ef9c087582	0dc56e1712cc2627ff6c212f7d2c050f912458a9db1afa4ad52d37c5fb97fd76	2024-05-13 13:35:16.3296+03	20240212075104_init	\N	\N	2024-05-13 13:35:16.325131+03	1
11a182c6-fc4d-4b6c-a52c-ff48f6561ac5	03b6766d1a3e68f2ddb73b9077dbd02bfc57b6060d955be9a2163121c2d4fb50	2024-05-13 13:35:16.376174+03	20240214174300_init	\N	\N	2024-05-13 13:35:16.372774+03	1
6e9d676f-f2cd-4a4b-b8e1-b405d99454db	93f036899128aefffcc52cd203de7bdc86431b440336a203e726bd6e7e4640ab	2024-05-13 13:35:16.38663+03	20240215092732_init	\N	\N	2024-05-13 13:35:16.377057+03	1
6cffccf5-ce09-4169-b21a-47c4bb135963	60e76f2cc649ec22ab1d49d2682a57bbdc848ed71f82ed835ea2ccac1289132e	2024-05-13 13:35:16.423085+03	20240220085352_init	\N	\N	2024-05-13 13:35:16.41856+03	1
d59f45d1-4d97-48d5-a71d-310f8230d7bd	d7aa74aa04e518b426301307318b9703bafbef81bfd35abb668ea7b87ea43737	2024-05-13 13:35:16.394883+03	20240216124347_init	\N	\N	2024-05-13 13:35:16.387835+03	1
ed26a4a0-9aa5-4c54-b286-419409e69419	7296e1bde7bb6726414cad2e10ba3fba89100afa608a70dcba914604241b6be6	2024-05-13 13:35:16.404889+03	20240216124527_init	\N	\N	2024-05-13 13:35:16.39593+03	1
07b73e8c-965e-47a7-9c1e-c6b53f8c54c1	ee788d2ac973bc49a46259db6ab8077c2265c54f1ec1fa74e204adc577a6b456	2024-05-13 13:35:16.4843+03	20240220123400_init	\N	\N	2024-05-13 13:35:16.473668+03	1
abb545f0-be20-45dd-ac16-bf29c01cf22f	7f5c6a8698866b2134f63d0b653ef37302c4caf5e3a14fce1d0c73ca4eab8e7b	2024-05-13 13:35:16.427647+03	20240220085632_init	\N	\N	2024-05-13 13:35:16.423985+03	1
d7921dd7-1384-45cb-bf49-cc4896a65b97	03a3bc9a4eafe57f39184592e734601fc1d6347b397f32c791809d74e553f414	2024-05-13 13:35:16.46343+03	20240220093249_init	\N	\N	2024-05-13 13:35:16.459002+03	1
12803ae8-8484-4942-8280-676f876b533e	6bcba9312176f27295cf4153d295e40bb8a7ecb10a8d921c34720b8cd4fb5788	2024-05-13 13:35:16.438994+03	20240220090727_init	\N	\N	2024-05-13 13:35:16.428842+03	1
546aa421-343f-4ee9-9e29-0e013702407c	a4351b023814c6c07c830d6f299c65bdcdbde4362afc57aaf0e7a2af538a3353	2024-05-13 13:35:16.444558+03	20240220091025_init	\N	\N	2024-05-13 13:35:16.44019+03	1
9d02f0a4-4bc7-4449-95af-9e83dbf40d7e	9295fb1d80436946c228c6e16fdb9260b0ded452fb07136d402f57b11a031c78	2024-05-13 13:35:16.468442+03	20240220112317_init	\N	\N	2024-05-13 13:35:16.464589+03	1
6116c143-910e-4416-b129-4307985cfbc2	aeaaf1d2fd2b15332503a92d0111e5c6441e0889c68dcc33d8bcfe97654d17d5	2024-05-13 13:35:16.472255+03	20240220121344_init	\N	\N	2024-05-13 13:35:16.46934+03	1
0e09fc6d-dea5-4e4a-9212-1be6b86da7f2	d293fa174d4e166f71a21ec28eeaa2294aaf3d6da7fd79ea9e76a0dee66dcde8	2024-05-13 13:35:16.489174+03	20240220130657_init	\N	\N	2024-05-13 13:35:16.485384+03	1
e288835a-13df-47b6-9561-0967e87fc1e7	c87440f6264f313707f131a6817c888e789a1e50cd8bb4f74da15d2c7b504ec1	2024-05-13 13:35:16.560061+03	20240220131909_init	\N	\N	2024-05-13 13:35:16.555152+03	1
8bb7caa9-d510-460f-94f7-1f61f251afc1	ea9407543f9c2a29d9525b39b1ba8311d0d7c477fef543bbb33df6261512d3fb	2024-05-13 13:35:16.553905+03	20240220131838_init	\N	\N	2024-05-13 13:35:16.497893+03	1
a5a77596-931f-45db-95da-71107baecc09	48f8ba2191241af3103837dfb07621446116815ab5594edfabcaf9d890203721	2024-05-13 13:35:16.576453+03	20240221103250_init	\N	\N	2024-05-13 13:35:16.561405+03	1
7ae69afd-52fa-48d0-addb-c18bba0992e0	5ef36795bb27e57ed21d7efcbfe868c12058a769c17d9fb67547a279e92fe985	2024-05-13 13:35:16.582951+03	20240221112252_init	\N	\N	2024-05-13 13:35:16.578408+03	1
efc10b5c-27c0-4398-8b24-37645ecfe83f	897cddeeeb140b1f1d53efa3a65fcbfeb509a75d69228c59aac00f1463c4c6d7	2024-05-13 13:35:16.589527+03	20240222081723_init	\N	\N	2024-05-13 13:35:16.584407+03	1
31b2b254-d020-4ff3-93ec-d478f60bd68f	5608940768bf3f0782a1a88fa7e562acc5a441df4492ee1ffc6126f65445c677	2024-05-13 13:35:16.600997+03	20240223084731_init	\N	\N	2024-05-13 13:35:16.590952+03	1
efc32d00-ff6c-4519-8b72-a603452fde39	db351485ebdf8b230caf5ebaa0e06aebade7d44752d5a9e93d38920c28886431	2024-05-13 13:35:16.657285+03	20240223092705_init	\N	\N	2024-05-13 13:35:16.602298+03	1
bfa36320-4f74-45fe-8820-09b9b5387c87	673e6f4dea0c5f8e68558ca16a126d2e87d5c5dc0c474752930732ac1b5a829c	2024-05-13 13:35:17.074308+03	20240401154403_init	\N	\N	2024-05-13 13:35:17.069803+03	1
36e6da9b-e4cb-4a8d-85df-9bf00140bc18	fc22fb479697bdef382d68a8698bfa2cd974efb780a8d45e6b3d2d80429d6c0e	2024-05-13 13:35:16.694014+03	20240223094441_init	\N	\N	2024-05-13 13:35:16.658573+03	1
04d36052-96aa-49ca-9cd0-704faee9d91e	d3aa5ee095b805d575a7b0b2a7e9ddab9736e7f153ec45c10141006c3530955d	2024-05-13 13:35:16.824768+03	20240301140900_init	\N	\N	2024-05-13 13:35:16.817309+03	1
85adab2b-17d4-4e0c-aa80-2da28048991f	dd0698a2369bc4d5c3c578b4ecf95f782937384ac70bbb587803de3e364cb437	2024-05-13 13:35:16.707741+03	20240223095255_init	\N	\N	2024-05-13 13:35:16.695561+03	1
e4e47041-08a4-4861-b600-550eeb44478c	100e8efb61f7cd1373751e214d35d064dd45ef0d35cdc8f768fc298bdb15ac0a	2024-05-13 13:35:16.712704+03	20240226074024_init	\N	\N	2024-05-13 13:35:16.708951+03	1
400c2c02-8531-4531-afc5-4e8c2b384f9a	993d4c7db6741eda9c4f7f0d36c0a2f6e7673c81e60335b252960a47e1e77f01	2024-05-13 13:35:16.924606+03	20240315083220_init	\N	\N	2024-05-13 13:35:16.920429+03	1
096ce4c1-95ca-4e30-a1bf-4836cec823f7	19234c0875a9738eacc57a982bd47e84d36c3a39f8b28732e53a86f41f00a6c9	2024-05-13 13:35:16.72176+03	20240226090217_init	\N	\N	2024-05-13 13:35:16.713926+03	1
912a2bbd-fa91-4e8b-a121-a72fee2f266b	d8bb15a47b140e9c6459d0a7ab47a7e7b7b34ceedc0737c4f138dc01575ac31c	2024-05-13 13:35:16.83021+03	20240301141213_init	\N	\N	2024-05-13 13:35:16.826079+03	1
77d4744f-15a1-41f5-8aad-bdc126aeb530	daf5aadcda116a4ac58165fe96cef096db3961b3f1b13965de5e191f8de6368f	2024-05-13 13:35:16.729485+03	20240226092751_init	\N	\N	2024-05-13 13:35:16.722937+03	1
c496feda-cb49-47aa-9462-3861403edcb5	28c8b960720b30afaae39f7374de14de0d8ddd05d1f69eaab2c5dd06f2a2ed32	2024-05-13 13:35:16.735359+03	20240226134631_init	\N	\N	2024-05-13 13:35:16.731646+03	1
7632cecb-34e3-4b00-970c-eed61c28d160	7bb4cce50a90e6782ea1a5a2bd271412c2d469c9a5d10c86d72f2d966144788a	2024-05-13 13:35:16.740983+03	20240226173020_init	\N	\N	2024-05-13 13:35:16.736534+03	1
2aae6ded-9b49-4d2c-b278-fc8db1780926	4ca2e4f2848faec42ae0c102e6ff9edcb3cacab8226c460a14b2bb65f67f9c78	2024-05-13 13:35:16.83791+03	20240302090628_init	\N	\N	2024-05-13 13:35:16.831278+03	1
27e6c26d-7eca-4f5b-a479-e5808b54da3e	3260f67e24a4f60b89b02f77ff056c6600571c8e43d9adddf65131386e724fbc	2024-05-13 13:35:16.747061+03	20240227100539_init	\N	\N	2024-05-13 13:35:16.742513+03	1
87694a20-ac06-4613-ae78-0991eba447a3	6d6e517933f3350b9f0d6ccdc075d7ddd873ed7504c6fc16d210e027fc4f503c	2024-05-13 13:35:16.758478+03	20240228124252_init	\N	\N	2024-05-13 13:35:16.748254+03	1
5a0f4edc-e97e-441a-913e-f070fdf33fda	f890e3cce45046ca37514f946131bfe0ddb68813f7580905b61864da28869163	2024-05-13 13:35:16.975804+03	20240329071353_init	\N	\N	2024-05-13 13:35:16.966854+03	1
86df3b7a-abd6-43a8-aec3-597c9f3fff15	91e0db8cd2dfc855cfac5f47ad7d9549d2b49fd67729dade614f14212bc69d7a	2024-05-13 13:35:16.762519+03	20240228124922_init	\N	\N	2024-05-13 13:35:16.759507+03	1
9c243cf0-b808-4068-ab8f-90d0409f9eeb	aaf2fd3dc9f15d7ef6fec78cfa366d5182307a602e1f4c5cbca8bc0bdf6ab6a2	2024-05-13 13:35:16.863876+03	20240302102616_init	\N	\N	2024-05-13 13:35:16.839461+03	1
f934b7c5-c0b1-410f-945a-d94aa1f4db3a	55234eab3e1fff02c41e22ef4cef95b8ffb09dad1c67c771776e1b7f00e656ad	2024-05-13 13:35:16.788771+03	20240229124820_init	\N	\N	2024-05-13 13:35:16.763526+03	1
7cc2eba9-074d-403b-a987-4031ca4572d9	1d378adb3194015b5b2e36f3b39d812af75d50e7438476a95e1afb0a97cc075d	2024-05-13 13:35:16.796807+03	20240229142853_init	\N	\N	2024-05-13 13:35:16.790428+03	1
4b161734-1fa4-41e0-baea-e4bb621f8a5c	d140d32efdf50f326e29791d20eabfd4fec07fad5addeaaf2a621c21fe26e19f	2024-05-13 13:35:16.931301+03	20240316044303_init	\N	\N	2024-05-13 13:35:16.925727+03	1
19d14afd-066e-42b7-8f70-1503303009f7	14973e7960f62f883fe593057cdfd463062a0fdc4aa5a4f08e440d31514010db	2024-05-13 13:35:16.810471+03	20240229162414_init	\N	\N	2024-05-13 13:35:16.797893+03	1
247777d2-3af4-4ec5-8e16-1e68aeb81f59	013abe447e39a8e7fa0903ea9db946d642354188f052fa7e12858d3317bc75a5	2024-05-13 13:35:16.871674+03	20240302103202_init	\N	\N	2024-05-13 13:35:16.865265+03	1
e32c56f3-b71e-4763-b3b9-9043ba3cb55d	868b35c23537d330ffffca8cec0941d42fcf9059c176d59c14710b5b031c5a39	2024-05-13 13:35:16.8159+03	20240229163813_init	\N	\N	2024-05-13 13:35:16.812699+03	1
d0bb970a-0ab1-43d1-8a5d-fffa1a4f6916	1bb62a5524d9d5566c634fd653d96b5278f84a73623a94e21ea44a5a7599aa31	2024-05-13 13:35:16.88746+03	20240302125237_init	\N	\N	2024-05-13 13:35:16.872947+03	1
3fb868ea-ee46-4f60-bb7f-98914b8810f1	95c962c9c5d06171551475a650e1fcf2bc62251fa8b74eea43abd59f8500c034	2024-05-13 13:35:16.904662+03	20240310075259_init	\N	\N	2024-05-13 13:35:16.888641+03	1
922df03b-2624-486a-97e7-e282e0eafde1	fe0714d8e345980e2b67568cd3a1f26c73fcddc1799f7fae6777c1074687b2a8	2024-05-13 13:35:16.936407+03	20240316051345_init	\N	\N	2024-05-13 13:35:16.932289+03	1
67e2a96a-c56a-4be9-9252-e492e1f7b515	8a4ad99b03ede20eca5ec8c9c21d38099836dec415a077eb92313e9c9b7375b3	2024-05-13 13:35:16.913492+03	20240313111549_init	\N	\N	2024-05-13 13:35:16.905996+03	1
f52dfd01-d3c7-4382-9854-d990a714c831	156d17d4c03d81a47f3eb8a5cecf9766cc2544022672badf2c983359da491e11	2024-05-13 13:35:16.91846+03	20240313112528_init	\N	\N	2024-05-13 13:35:16.914675+03	1
f4cb6613-771a-4f25-a148-7453e7f984d3	e0e397caf16b5b5dbf444d56cfbecfb88a11d9b00c09aa4ff0ecad12d6f9d9af	2024-05-13 13:35:17.031667+03	20240401143454_init	\N	\N	2024-05-13 13:35:17.028457+03	1
3fffbb36-c63b-415d-adcd-42ca62ef5ad6	2635b01e7f4c31f0f5345ca2c3ee2107321ea53d923e10e8325442a16339abc6	2024-05-13 13:35:16.944777+03	20240319062450_init	\N	\N	2024-05-13 13:35:16.937432+03	1
452543e5-b5c1-4459-ae5d-6e552d0418ac	c88614186fcd95b579bfa9400af9a5321bf9e7260f737773ed6725049d76b042	2024-05-13 13:35:17.018628+03	20240401093739_init	\N	\N	2024-05-13 13:35:16.977274+03	1
9101c495-a922-464b-a8e6-8b70fce5fcaa	124d94dfdfba46094876f7c25f517409447f25768c44aa45001143300b74022f	2024-05-13 13:35:16.960475+03	20240327101254_init	\N	\N	2024-05-13 13:35:16.946073+03	1
fa1f1dfb-1f7a-4070-8c59-12a1c25d4a90	6e012447ca56175ea00b468e234703d7de1151ee243e1f1882932d825dad47b2	2024-05-13 13:35:16.965914+03	20240327165257_init	\N	\N	2024-05-13 13:35:16.961687+03	1
08f7fb01-8bc7-4ea3-a574-0f4bfa730ec5	287dc725f801ce5457bbae2dec456ccd669f728b7d6d7004cc6b22fe51e16751	2024-05-13 13:35:17.023047+03	20240401102217_init	\N	\N	2024-05-13 13:35:17.019631+03	1
b9131856-dce4-47b1-aa78-86b3b2fc4596	a4f15f98d61bd23bf3354499d404e48395cbbfcc0fd44b25a1c166478e380d81	2024-05-13 13:35:17.02753+03	20240401113926_init	\N	\N	2024-05-13 13:35:17.024165+03	1
98a423cf-87aa-4963-ae75-140ff87cad54	aa9eb51089bcd7cad662f014412029db05ff49fdbd395eb45d8b332aa8f1b09b	2024-05-13 13:35:17.068375+03	20240401143838_init	\N	\N	2024-05-13 13:35:17.032827+03	1
d176f3a1-afec-434d-9a8e-7a81797f09d0	3c9d186059ba36aa1a076a9b226e5fbeede5378e229f15a749b777e1bce99ae7	2024-05-13 13:35:17.107234+03	20240402131931_init	\N	\N	2024-05-13 13:35:17.098715+03	1
791b76e7-42e5-44d9-8cb4-3c0921ff7969	9691c15d9916ca37cecaac555eb7ecd529050f69b847ac55c46f6f515f1e500d	2024-05-13 13:35:17.09756+03	20240401161941_init	\N	\N	2024-05-13 13:35:17.075462+03	1
e4141226-173c-4461-b9a7-0e963174dad2	e8b88188bd187cd9145804a0b0f58f870cf7d6b2a890c7e8f67fa26e8f7c4a91	2024-05-13 13:35:17.115247+03	20240402135107_init	\N	\N	2024-05-13 13:35:17.1088+03	1
4a13dcb7-91fc-472e-b179-da6d92af2686	516491528340768b832068f77cf89dac2118d80dbcaedf410d9448a393b06786	2024-05-13 13:35:17.128623+03	20240403085625_init	\N	\N	2024-05-13 13:35:17.11638+03	1
2096f053-3244-40eb-9dc8-33047622baf3	d7da15ec33e34151f7145a47bdec0b848cc216a4c863983fde9ab4ac1807bed2	2024-05-13 13:35:17.133486+03	20240409080738_init	\N	\N	2024-05-13 13:35:17.129677+03	1
8ccf88af-5a69-4b50-a376-bfa04fe16a45	930fbf76a69808284f96a22d2b1dfa5ae1c9c8d094fc46b6888ebe34b353978e	2024-05-13 13:35:17.140147+03	20240426102322_init	\N	\N	2024-05-13 13:35:17.134648+03	1
d74839ff-aec6-4b88-b153-6c3fd5cb1d32	71ac49f7b69fcd70ccc8aeb539f66979033fe4f73b69fda665ddf345be5a2ab7	2024-05-13 13:35:17.158092+03	20240429072037_init	\N	\N	2024-05-13 13:35:17.141451+03	1
4ea91900-5b5f-4410-9635-abb5b68c8cd7	e11c05790dd638077bdec7a82621a2506a522d50de08acf6b6e82484558be795	2024-05-13 13:35:17.167497+03	20240430041906_init	\N	\N	2024-05-13 13:35:17.15962+03	1
5a3f4551-b7fa-4c9f-8603-4cd526697cd6	ff0742a15ea3b269af99b138d5504083225e87397c2ee5e2657008216d87945c	2024-05-13 13:35:17.184097+03	20240506072310_init	\N	\N	2024-05-13 13:35:17.169499+03	1
17b4c641-d013-4c6f-8d87-ad33db638e99	7d62796421b0b614fa4f8d07ec149c6f0e60cc44bbf2859819bc148d3154cc01	2024-05-13 13:35:17.189962+03	20240506081036_init	\N	\N	2024-05-13 13:35:17.185309+03	1
3191405d-fb37-4051-9664-7644322a3392	30554d5f52a0366e49d149fc377e3e42f7d6b268f9076b410aace2b1b77a4f97	2024-05-13 13:35:17.195955+03	20240506095603_init	\N	\N	2024-05-13 13:35:17.19113+03	1
1f27845a-18fc-4fb6-9fcf-ef5657444628	b01ba1c379a15ba6d94f898b7b814ef3622cf7048e62b5f1b99f01ed1de068a6	2024-05-13 13:35:17.207475+03	20240507061255_init	\N	\N	2024-05-13 13:35:17.197966+03	1
795a4514-1c2d-45ba-8e79-4b3552db4f31	f45c055c5d43c3fa002d74340d4453578983d1073602a56876d6407e90efd510	2024-05-13 13:35:17.211633+03	20240507062017_init	\N	\N	2024-05-13 13:35:17.208674+03	1
0effdcef-810a-4203-94e0-0b2f699e949b	c25bac8442a32b22e8793a9013aa407b6abd03262b340799718fb58a495a7013	2024-05-13 13:35:17.217631+03	20240507082144_init	\N	\N	2024-05-13 13:35:17.212811+03	1
ac53207e-8997-4752-af4d-6c940403deeb	3b1b7f0dcd8432c379941f75454836bb40c2e633f8f67216ca1047ed61a7985e	2024-05-13 13:35:17.221392+03	20240507083253_init	\N	\N	2024-05-13 13:35:17.218495+03	1
4d5b4a87-aebb-424c-8414-e9c7680a0edf	dea441fc20c58619ca191707a46190c2811e759aedb53f8281c8e9f34eca610e	2024-05-13 13:35:17.227826+03	20240507090135_init	\N	\N	2024-05-13 13:35:17.222499+03	1
c13ad2c7-c9bf-4ee5-b998-232e088d0a07	a66e928a6834856b7bb24932cd4c96ea8f6a6504b1ba414fefce2e77f4fcdf09	2024-05-13 13:35:17.237527+03	20240507091708_init	\N	\N	2024-05-13 13:35:17.228727+03	1
820889e5-576a-4f39-9fc2-97e150d11ee0	51305ce39116e6dd740243d1435591af00ebd78de1f8f74e4b44e28771f18ee5	2024-05-13 13:35:17.24164+03	20240509082859_init	\N	\N	2024-05-13 13:35:17.23873+03	1
c0032ba5-8509-4448-aa35-6a5be9046c70	85bc469f2b255f63ad90472b8980e6ca34e74224181aa26a35b8616fdf967e96	2024-05-13 13:35:17.255459+03	20240513103118_modfi_status	\N	\N	2024-05-13 13:35:17.243068+03	1
69d839d0-97c9-4244-a58c-9f87912ca703	6430c4db35252ec5a3fa4bbfcafbff490aad68a699922a554719f680f471ec14	2024-05-13 13:35:19.509054+03	20240513103519_modfi_status	\N	\N	2024-05-13 13:35:19.504677+03	1
\.


--
-- Name: Address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Address_id_seq"', 2, true);


--
-- Name: AlertsHistory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."AlertsHistory_id_seq"', 1, true);


--
-- Name: Alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Alerts_id_seq"', 3, true);


--
-- Name: Bank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Bank_id_seq"', 32, true);


--
-- Name: Banks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Banks_id_seq"', 2, true);


--
-- Name: BillingFrequency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."BillingFrequency_id_seq"', 8, true);


--
-- Name: Cashflow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Cashflow_id_seq"', 30, true);


--
-- Name: Category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Category_id_seq"', 1, true);


--
-- Name: ContractAlertSchedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractAlertSchedule_id_seq"', 50, true);


--
-- Name: ContractAttachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractAttachments_id_seq"', 29, true);


--
-- Name: ContractContent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractContent_id_seq"', 4, true);


--
-- Name: ContractDynamicFields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractDynamicFields_id_seq"', 25, true);


--
-- Name: ContractFinancialDetailSchedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractFinancialDetailSchedule_id_seq"', 11, true);


--
-- Name: ContractFinancialDetail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractFinancialDetail_id_seq"', 5, true);


--
-- Name: ContractItems_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractItems_id_seq"', 11, true);


--
-- Name: ContractStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractStatus_id_seq"', 1, true);


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

SELECT pg_catalog.setval('public."ContractTasksReminders_id_seq"', 7, true);


--
-- Name: ContractTasksStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTasksStatus_id_seq"', 1, false);


--
-- Name: ContractTasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTasks_id_seq"', 3, true);


--
-- Name: ContractTemplates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractTemplates_id_seq"', 1, true);


--
-- Name: ContractType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractType_id_seq"', 96, true);


--
-- Name: ContractWFStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractWFStatus_id_seq"', 6, true);


--
-- Name: ContractsAudit_auditid_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ContractsAudit_auditid_seq"', 25, true);


--
-- Name: Contracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Contracts_id_seq"', 25, true);


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

SELECT pg_catalog.setval('public."Department_id_seq"', 1, true);


--
-- Name: DynamicFields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."DynamicFields_id_seq"', 1, true);


--
-- Name: ExchangeRates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."ExchangeRates_id_seq"', 32, true);


--
-- Name: Groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Groups_id_seq"', 3, true);


--
-- Name: Item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Item_id_seq"', 1, true);


--
-- Name: Location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Location_id_seq"', 1, true);


--
-- Name: MeasuringUnit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."MeasuringUnit_id_seq"', 31, true);


--
-- Name: Partners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Partners_id_seq"', 2, true);


--
-- Name: PaymentType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."PaymentType_id_seq"', 10, true);


--
-- Name: Persons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Persons_id_seq"', 2, true);


--
-- Name: Role_User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Role_User_id_seq"', 13, true);


--
-- Name: Role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."Role_id_seq"', 4, true);


--
-- Name: User_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."User_id_seq"', 4, true);


--
-- Name: WorkFlowContractTasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowContractTasks_id_seq"', 1, false);


--
-- Name: WorkFlowRejectActions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowRejectActions_id_seq"', 1, false);


--
-- Name: WorkFlowRules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowRules_id_seq"', 2, true);


--
-- Name: WorkFlowTaskSettingsUsers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowTaskSettingsUsers_id_seq"', 4, true);


--
-- Name: WorkFlowTaskSettings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowTaskSettings_id_seq"', 1, true);


--
-- Name: WorkFlowXContracts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlowXContracts_id_seq"', 1, false);


--
-- Name: WorkFlow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysadmin
--

SELECT pg_catalog.setval('public."WorkFlow_id_seq"', 1, true);


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
-- Name: ContractWFStatus ContractWFStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."ContractWFStatus"
    ADD CONSTRAINT "ContractWFStatus_pkey" PRIMARY KEY (id);


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
-- Name: ContractWFStatus_name_key; Type: INDEX; Schema: public; Owner: sysadmin
--

CREATE UNIQUE INDEX "ContractWFStatus_name_key" ON public."ContractWFStatus" USING btree (name);


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
-- Name: Contracts Contracts_statusWFId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysadmin
--

ALTER TABLE ONLY public."Contracts"
    ADD CONSTRAINT "Contracts_statusWFId_fkey" FOREIGN KEY ("statusWFId") REFERENCES public."ContractWFStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


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
    ADD CONSTRAINT "WorkFlowContractTasks_statusId_fkey" FOREIGN KEY ("statusId") REFERENCES public."ContractWFStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
    ADD CONSTRAINT "WorkFlowXContracts_wfstatusId_fkey" FOREIGN KEY ("wfstatusId") REFERENCES public."ContractWFStatus"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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

