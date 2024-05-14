import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {


    try {
        const result = await prisma.$executeRaw`    
        CREATE OR REPLACE FUNCTION  public.remove_duplicates_from_task()
        RETURNS void
        LANGUAGE 'plpgsql'
        COST 100
        VOLATILE PARALLEL UNSAFE
        AS $BODY$
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
        $BODY$;
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }


    try {
        const result = await prisma.$executeRaw`    
    CREATE OR REPLACE FUNCTION  public.cttobegeneratedsecv(
        )
    RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 10000
    AS $BODY$
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
        $BODY$;
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }


    try {
        const result = await prisma.$executeRaw`    
    CREATE OR REPLACE FUNCTION contractTaskToBeGenerated(
    )
    RETURNS TABLE(taskName text, taskNotes text, contractId integer, statusId integer, requestorId integer,
        assignedId integer, approvedByAll boolean, approvalTypeInParallel boolean, workflowTaskSettingsId integer,
        Uuid uuid, approvalOrderNumber integer, workflowId integer, PriorityName text, PriorityId integer, ReminderName text,
        ReminderDays integer, DueDate text, DueDateDays integer, CalculatedDueDate TIMESTAMP, CalculatedReminderDate TIMESTAMP,
        taskSendNotifications boolean, taskSendReminders boolean
    ) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 10000
AS $BODY$
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
    $BODY$;
--select * from public.contractTaskToBeGenerated()
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }


    try {
        const result = await prisma.$executeRaw`    
    CREATE OR REPLACE FUNCTION remove_duplicates_from_table2()
        RETURNS SETOF text AS
        $$
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
        $$
        LANGUAGE plpgsql;

--SELECT remove_duplicates_from_table2();
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }


    try {
        const result = await prisma.$executeRaw`    
    CREATE FUNCTION public.active_wf_rulesok99() RETURNS TABLE(workflowid integer, costcenters integer[], departments integer[], cashflows integer[], categories integer[])
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
ALTER FUNCTION public.active_wf_rulesok99() OWNER TO postgres;
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }




    try {
        const result = await prisma.$executeRaw`    
   CREATE OR REPLACE FUNCTION public.contracttasktobegeneratedsecv3(
	contractid_param integer)
    RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, workflowtasksettingsid integer, uuid integer, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 10000

AS $BODY$
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
$BODY$;

--SELECT * FROM contracttasktobegeneratedsecv3(1);
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }


    try {
        const result = await prisma.$executeRaw`          
        CREATE OR REPLACE FUNCTION public.contracttasktobegeneratedSecvent()
        RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, approvedbyall boolean, approvaltypeinparallel boolean, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
        LANGUAGE plpgsql
        ROWS 10000
        AS $function$
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
        $function$
        ;
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }


    try {
        const result = await prisma.$executeRaw`          
        CREATE OR REPLACE FUNCTION public.contracttasktobegeneratedok(
	)
    RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, workflowtasksettingsid integer, uuid uuid, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 10000

    AS $BODY$
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
        $BODY$;

--select * from public.contracttasktobegeneratedok() 
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }


    try {
        const result = await prisma.$executeRaw`          
        CREATE OR REPLACE FUNCTION public.getauditcontract2(contractid integer)
        RETURNS TABLE(contract_id integer, tip_modificare text, data_modificare timestamp without time zone, 
        contract_number text, nume_partener text, nume_entitate text, stare text, starewf text , start_date timestamp without time zone, 
        end_date timestamp without time zone, sign_date timestamp without time zone, completion_date timestamp without time zone, 
        nume_categorie text, departament text, cashflow text, tip_contract text, centru_cost text, locatie text, utilizator text)
        LANGUAGE plpgsql
        AS $function$
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
                            cswf.name as StareWF,
                            c.start as Start_Date,
                            c.end as End_Date,
                            c.sign as Sign_Date,
                            c.completion as Completion_Date,
                            ca.name as Nume_Categorie,
                            dep.name as Departament,
                            cf.name as Cashflow,
                            ct.name as Tip_Contract,
                            cc.name as Centru_Cost,
                            ll.name as Locatie,
                            us.name as Utilizator
                from public."ContractsAudit" c
                left join public."Partners" a on c."partnersId" = a.id 
                left join public."Partners" b on c."entityId" = b.id 
                left join public."Category" ca  on c."categoryId" = ca.id 
                left join public."ContractStatus" cs on cs."id" = c."statusId"
                left join public."ContractWFStatus" cswf on cswf."id" = c."statusWFId"
                left join public."Department" dep  on dep."id" = c."departmentId"
                left join public."Cashflow" cf on cf."id" = c."cashflowId"
                left join public."Location" ll on ll."id" = c."locationId"
                left join public."ContractType" ct on ct."id" = c."typeId"
                left join public."CostCenter"  cc on cc."id" = c."costcenterId"
                left join public."User" us on us."id" = c."userId"
                where c.id = contractid;
                end;
                $function$
        ;
    `
            ;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }


    try {
        const result = await prisma.$executeRaw`          
         CREATE OR REPLACE FUNCTION get_contract_details()
    RETURNS TABLE (
        TipContract TEXT,
        number TEXT,
        start_date DATE,
        end_date DATE,
        sign_date DATE,
        completion_date DATE,
        remarks TEXT,
        partner_name TEXT,
        entity_name TEXT,
        automatic_renewal TEXT,
        status_name TEXT,
        cashflow_name TEXT,
        category_name TEXT,
        contract_type_name TEXT,
        department_name TEXT,
        cost_center_name TEXT,
        partner_person_name TEXT,
        partner_person_role TEXT,
        partner_person_email TEXT,
        entity_person_name TEXT,
        entity_person_role TEXT,
        entity_person_email TEXT,
        partner_address TEXT,
        entity_address TEXT,
        partner_bank TEXT,
        partner_currency TEXT,
        partner_iban TEXT,
        entity_bank TEXT,
        entity_currency TEXT,
        entity_iban TEXT
    )
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
    $$ LANGUAGE plpgsql;

    --SELECT * FROM get_contract_details();     
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }



    try {
        const result = await prisma.$executeRaw`          
                --select * from public.calculate_cashflow_func()

    CREATE OR REPLACE FUNCTION public.calculate_cashflow_func()
    RETURNS TABLE(tip text, billingvalue numeric, month_number numeric ) 

    LANGUAGE plpgsql
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 10000
    AS $BODY$
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
    $BODY$;
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }

    try {
        const result = await prisma.$executeRaw`          
         CREATE OR REPLACE FUNCTION public.report_cashflow(
        )
        RETURNS TABLE(
            ContractId integer, TipTranzactie text, Partener text,
            Entitate text, NumarContract text, Start date, Final date,
            DescriereContract text,
            Cashflow text,
            Data date, ProcentPlusBNR double precision,
            ProcentPenalitate double precision, NrZileScadente integer,
            Articol text, Cantitate double precision, PretUnitarInValuta double precision,
            ValoareInValuta double precision,
            Valuta text, CursValutar double precision,
            ValoareRon numeric, --20
    	PlatitIncasat text, Facturat text
        ) 
        LANGUAGE 'plpgsql'
        COST 100
        VOLATILE PARALLEL UNSAFE
        ROWS 1000

    AS $BODY$
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
        $BODY$;
        --select * from public.report_cashflow()
    `;

        console.log('Function creation query executed successfully:', result);
    } catch (error) {
        console.error('Error executing function creation query:', error);
    }



    console.log('Seed completed');
}
main()
    .then(async () => {
        await prisma.$disconnect()
    })
    .catch(async (e) => {
        console.error(e)
        await prisma.$disconnect()
        process.exit(1)
    })
