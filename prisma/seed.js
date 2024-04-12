import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {

    // const contractType = [
    //     { name: "Contracte de Vanzare-Cumparare" },
    //     { name: "Contracte de inchiriere" },
    //     { name: "Contracte de servicii" },
    //     { name: "Contracte de parteneriat" },
    //     { name: "Contracte de colaborare" },
    //     { name: "Contracte de constructie" },
    //     { name: "Contracte de licentiere" },
    //     { name: "Contracte de franciză" },
    //     { name: "Contracte de imprumut" },
    //     { name: "Contracte de agent" },
    //     { name: "Contracte de dezvoltare Software" },
    //     { name: "Contracte de asigurare" },
    //     { name: "Contracte imobiliare" },
    //     { name: "Contracte de mentenanta" },
    //     { name: "Contracte abonament" },
    //     { name: "Contract de schimb" },
    //     { name: "Contract de report" },
    //     { name: "Contract de antrepriză" },
    //     { name: "Contract de asociere în participație" },
    //     { name: "Contract de transport" },
    //     { name: "Contract de mandat" },
    //     { name: "Contract de comision" },
    //     { name: "Contract de consignație" },
    //     { name: "Contract de agenție" },
    //     { name: "Contract de intermediere" },
    //     { name: "Contract de depozit" },
    //     { name: "Contract de cont curent" },
    //     { name: "Contract de joc și pariu" },
    //     { name: "Contract de donație" },
    //     { name: "Contract de fiducie" },
    //     { name: "Contract de leasing" },
    //     { name: "Contract de factoring" }
    // ];


    // const contractStatus = [
    //     { name: 'Activ' },
    //     { name: 'Reinnoit' },
    //     { name: 'Expirat' },
    //     { name: 'Finalizat' },
    //     { name: 'Contestat' },
    //     { name: 'Reziliat' },

    // ]

    // const cashflowLines = [
    //     { name: 'Incasari operationale' },
    //     { name: 'Incasari financiare' },
    //     { name: 'Plati operationale' },
    //     { name: 'Plati investitionale' },
    //     { name: 'Plati financiare' },
    //     { name: 'Tranzactii InterCompany' },
    //     { name: 'Salarii' },
    //     { name: 'Furnizori activitate curenta' },
    //     { name: 'Utilitati' },
    //     { name: 'Auto combustibili si reparatii' },
    //     { name: 'Paza' },
    //     { name: 'Publicitate si sponsorizare' },
    //     { name: 'Deplasari + diurne' },
    //     { name: 'Marfa MUDR' },
    //     { name: 'Restituiri clienti' },
    //     { name: 'Investitii in curs' },
    //     { name: 'Investitii finalizate' },
    //     { name: 'Asigurari/ leasing , comisioane banci' },
    //     { name: 'Restituire credite si dobanzi' },
    //     { name: 'Impozit pe profit' },
    //     { name: 'Impozite locale' },
    //     { name: 'TVA de plata  ' },
    //     { name: 'Taxa salarii' },
    //     { name: 'Tranzactii intercompany' },
    //     { name: 'Transfer bancar(credit)' },
    //     { name: 'Transfer bancar(debit)' },
    //     { name: 'Plati Deconturi' },
    //     { name: 'Investitii Proprii' },
    //     { name: 'Compensari/Girari/Retururi' }]

    // const costcenters = [
    //     { name: 'Abonamente RATB' },
    //     { name: 'Achizitii carti de specialitate' },
    //     { name: 'Achizitii de specialitate' },
    //     { name: 'Achizitii produse auto' },
    //     { name: 'Administratia pietelor' },
    //     { name: 'Administratie' },
    //     { name: 'Alpinisti utilitari' },
    //     { name: 'Alte cheltuieli' },
    //     { name: 'Alte cheltuieli si evenimente' },
    //     { name: 'Alte facilitati - masa personal, utilitati, servicii, abonamente RATB' },
    //     { name: 'Alte facilitati personal alte persoane' },
    //     { name: 'Alte obiective' },
    //     { name: 'Alte taxe (Reg. comert, mediu, urbanism, avize)' },
    //     { name: 'Altele' },
    //     { name: 'Amenajare incinta' },
    //     { name: 'Andimed - medicina muncii' },
    //     { name: 'Anunturi piblicitare, taxe postale si alte taxe' },
    //     { name: 'Anunturi publicitare, taxe postale' },
    //     { name: 'Apa' },
    //     { name: 'Apa menajera' },
    //     { name: 'Apartamente' },
    //     { name: 'Apele Romane' },
    //     { name: 'Ascensorul Schindler - servicii mentenanta' },
    //     { name: 'Asigurari auto casco si RCA' },
    //     { name: 'Asigurari cladiri si de viata' },
    //     { name: 'Autofinantare' },
    //     { name: 'Autorizatie/Licenta utilizare muzica' },
    //     { name: 'Bonuri de masa' },
    //     { name: 'Bonuri de masa alte persoane' },
    //     { name: 'Bugetul Managerului General' },
    //     { name: 'Carburant Auto' },
    //     { name: 'Carburant auto personal Tesa' },
    //     { name: 'Cheltuieli administrare si intretinere' },
    //     { name: 'Cheltuieli Comunicare' },
    //     { name: 'Cheltuieli comunicare' },
    //     { name: 'Cheltuieli cu personalul' },
    //     { name: 'Cheltuieli financiare' },
    //     { name: 'Cheltuieli imagine' },
    //     { name: 'Cheltuieli linie CFR / taxa drumuri/ taxa poduri' },
    //     { name: 'Cheltuieli Neprevazute' },
    //     { name: 'Cheltuieli neprevazute' },
    //     { name: 'Cheltuieli personal alte obiective fara profit' },
    //     { name: 'Cheltuieli personal Tesa' },
    //     { name: 'Cheltuieli sp. SNCFR ' },
    //     { name: 'Cheltuieli transport' },
    //     { name: 'Cheltuieli utilitati' }]

    // const Currency = [
    //     { code: "RON", name: "LEU" },
    //     { code: "EUR", name: "Euro" },
    //     { code: "USD", name: "Dolarul SUA" },
    //     { code: "CHF", name: "Francul elveţian" },
    //     { code: "GBP", name: "Lira sterlină" },
    //     { code: "BGN", name: "Leva bulgarească" },
    //     { code: "RUB", name: "Rubla rusească" },
    //     { code: "ZAR", name: "Randul sud-african" },
    //     { code: "BRL", name: "Realul brazilian" },
    //     { code: "CNY", name: "Renminbi-ul chinezesc" },
    //     { code: "INR", name: "Rupia indiană" },
    //     { code: "MXN", name: "Peso-ul mexican" },
    //     { code: "NZD", name: "Dolarul neo-zeelandez" },
    //     { code: "RSD", name: "Dinarul sârbesc" },
    //     { code: "UAH", name: "Hryvna ucraineană" },
    //     { code: "TRY", name: "Noua lira turcească" },
    //     { code: "AUD", name: "Dolarul australian" },
    //     { code: "CAD", name: "Dolarul canadian" },
    //     { code: "CZK", name: "Coroana cehă" },
    //     { code: "DKK", name: "Coroana daneză" },
    //     { code: "EGP", name: "Lira egipteană" },
    //     { code: "HUF", name: "Forinți maghiari" },
    //     { code: "JPY", name: "Yeni japonezi" },
    //     { code: "MDL", name: "Leul moldovenesc" },
    //     { code: "NOK", name: "Coroana norvegiană" },
    //     { code: "PLN", name: "Zlotul polonez" },
    //     { code: "SEK", name: "Coroana suedeză" },
    //     { code: "AED", name: "Dirhamul Emiratelor Arabe" },
    //     { code: "THB", name: "Bahtul thailandez" }
    // ]


    // const Banks = [
    //     { name: "Alpha Bank" },
    //     { name: "BRCI" },
    //     { name: "Banca FEROVIARA" },
    //     { name: "Intesa Sanpaolo" },
    //     { name: "BCR" },
    //     { name: "BCR Banca pentru Locuinţe" },
    //     { name: "Eximbank" },
    //     { name: "Banca Românească" },
    //     { name: "Banca Transilvania" },
    //     { name: "Leumi" },
    //     { name: "BRD" },
    //     { name: "CEC Bank" },
    //     { name: "Crédit Agricole" },
    //     { name: "Credit Europe" },
    //     { name: "Garanti Bank" },
    //     { name: "Idea Bank" },
    //     { name: "Libra Bank" },
    //     { name: "Vista Bank" },
    //     { name: "OTP Bank" },
    //     { name: "Patria Bank" },
    //     { name: "First Bank" },
    //     { name: "Porsche Bank" },
    //     { name: "ProCredit Bank" },
    //     { name: "Raiffeisen" },
    //     { name: "Aedificium Banca pentru Locuinte" },
    //     { name: "UniCredit" },
    //     { name: "Alior Bank" },
    //     { name: "BLOM Bank France" },
    //     { name: "BNP Paribas" },
    //     { name: "Citibank" },
    //     { name: "ING" },
    //     { name: "TBI " }]



    // for (const type of contractType) {
    //     await prisma.contractType.create({
    //         data: type,
    //     });
    // }

    // for (const status of contractStatus) {
    //     await prisma.contractStatus.create({
    //         data: status,
    //     });
    // }

    // for (const cf of cashflowLines) {
    //     await prisma.cashflow.create({
    //         data: cf,
    //     });
    // }

    // for (const cc of costcenters) {
    //     await prisma.costCenter.create({
    //         data: cc,
    //     });
    // }

    // for (const currency of Currency) {
    //     await prisma.currency.create({
    //         data: currency,
    //     });
    // }

    // for (const bank of Banks) {
    //     await prisma.bank.create({
    //         data: bank,
    //     });
    // }



    // const Frequency = [
    //     { name: "Zilnic" },
    //     { name: "Săptămânal" },
    //     { name: "Lunar" },
    //     { name: "Trimestrial" },
    //     { name: "Semestrial" },
    //     { name: "Anual" },
    //     { name: "Personalizat" }
    // ]

    // const MeasuringUnit = [
    //     { name: "Lună (lună)" },
    //     { name: "Oră (h)" },
    //     { name: "Zi (zi)" },
    //     { name: "An (an)" },
    //     { name: "Metru (m)" },
    //     { name: "Metru pătrat (m²)" },
    //     { name: "Centimetru (cm)" },
    //     { name: "Centimetru pătrat (cm²)" },
    //     { name: "Kilometru (km)" },
    //     { name: "Milimetru (mm)" },
    //     { name: "Milă (mi)" },
    //     { name: "Gram (g)" },
    //     { name: "Kilogram (kg)" },
    //     { name: "Tona metrică (t)" },
    //     { name: "Miligram (mg)" },
    //     { name: "Centigram (cg)" },
    //     { name: "Uncie (oz)" },
    //     { name: "Mililitru (ml)" },
    //     { name: "Centilitru (cl)" },
    //     { name: "Secundă (s)" },
    //     { name: "Minut (min)" },
    //     { name: "Săptămână (săptămână)" },
    //     { name: "Centimetru cub (cm³ sau cc)" },
    //     { name: "Metru cub (m³)" },
    //     { name: "Mililitru (ml)" },
    //     { name: "Hectolitră (hl)" },
    //     { name: "Calorie (cal)" },
    //     { name: "Kilocalorie (kcal)" },
    //     { name: "Watt-ora (Wh)" },
    //     { name: "Kilowatt-ora (kWh)" },
    //     { name: "Hectare (ha)" }]

    //de adaugat si useri - admin admin


    //function for generating uuid
    // prisma.$executeRaw(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`)

    // const ContractTasksStatus = [
    // { id: 1, name: "In lucru", en: "Draft", Desription: "The initial state of the document or request before it's submitted for approval." },
    // { id: 2, name: "Înaintat", en: "Submitted", Desription: "The document or request has been submitted for approval but hasn't been reviewed yet." },
    // { id: 3, name: "În curs de revizuire", en: "Under Review", Desription: " The document or request is currently being reviewed by the approver(s)." },
    // { id: 4, name: "Aprobat", en: "Approved", Desription: "The document or request has been reviewed and approved by the approver(s)." },
    // { id: 5, name: "Respins", en: "Rejected", Desription: "The document or request has been reviewed and rejected by the approver(s).This might happen if the request doesn't meet certain criteria or needs further revisions." },
    // { id: 6, name: "Revizii în așteptare", en: "Rejected", Desription: "The document or request has been reviewed and requires revisions before it can be resubmitted for approval." },
    // { id: 7, name: "Aprobare în așteptare", en: "Rejected", Desription: "The document or request has been revised and is pending approval again." },
    // { id: 8, name: "Anulat, en: "Canceled", Desription: "The document or request has been canceled by the requester or administrator.This might happen if the request is no longer needed or if it was submitted in error." },
    // { id: 9, name: "În așteptare: "On Hold", Desription: "The approval process for the document or request has been temporarily paused." },
    // { id: 10, name: "Arhivat": "Archived", Desription: "The document or request has been approved or rejected and is now archived for record - keeping purposes."
    // ]


    // for (const status of ContractTasksStatus) {
    //     await prisma.contractTasksStatus.create({
    //         data: status,
    //     });
    // }


    // for (const measuringunit of MeasuringUnit) {
    //     await prisma.measuringUnit.create({
    //         data: measuringunit,
    //     });
    // }


    // for (const frequency of Frequency) {
    //     await prisma.billingFrequency.create({
    //         data: frequency,
    //     });
    // }


    // const PaymentType = [
    //     { name: "Numerar" },
    //     { name: "Ordin de Plată" },
    //     { name: "Cec" },
    //     { name: "Bilet la ordin" },
    //     { name: "Transfer Bancar" },
    //     { name: "Virament Bancar" },
    //     { name: "Portofel Digital(PayPal, Venmo...)" },
    //     { name: "Bitcoin și Criptomonede" },
    //     { name: "Card de Debit" },
    //     { name: "Card de Credit" }]

    // for (const type of PaymentType) {
    //     await prisma.PaymentType.create({
    //         data: type,
    //     });
    // }


    // const reminders = [
    //     { name: 'La data limită', value: 0 },
    //     { name: '1 zi inainte de data limită', value: 1 },
    //     { name: '2 zile inainte de data limită', value: 2 },
    //     { name: '3 zile inainte de data limită', value: 3 },
    //     { name: '4 zile inainte de data limită', value: 4 },
    //     { name: '5 zile inainte de data limită', value: 5 }
    // ];

    // for (const reminder of reminders) {
    //     await prisma.contractTasksReminders.create({
    //         data: reminder,
    //     });
    // }

    const duedates = [
        { name: 'In ziua generarii task-ului', value: 0 },
        { name: 'La o zi dupa start flux', value: 1 },
        { name: 'La 2 zile dupa start flux', value: 2 },
        { name: 'La 3 zile dupa start flux', value: 3 },
        { name: 'La 4 zile dupa start flux', value: 4 },
        { name: 'La 5 zile dupa start flux', value: 5 },
    ];

    for (const duedate of duedates) {
        await prisma.contractTasksDueDates.create({
            data: duedate,
        });
    }

    // prisma.$executeRaw(`
    // INSERT INTO public."User"
    //     ("name", email, "password", "createdAt", picture, status, "updatedAt")
    // VALUES('admin', 'admin', 'admin', CURRENT_TIMESTAMP, '', false, '');
    //         `
    //     )


    prisma.$executeRaw(`
    --FUNCTION: public.remove_duplicates_from_task()

    --DROP FUNCTION IF EXISTS public.remove_duplicates_from_task();

CREATE OR REPLACE FUNCTION public.remove_duplicates_from_task(
    )
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

ALTER FUNCTION public.remove_duplicates_from_task()
OWNER TO sysadmin;

    --SELECT remove_duplicates_from_task()
`);


    prisma.$executeRaw(`
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
`);

    prisma.$executeRaw(`
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

`);

    prisma.$executeRaw(`
   
CREATE OR REPLACE FUNCTION public.active_wf_rulesok(
	)
    RETURNS TABLE(workflowId integer, costcenters integer[], departments integer[], cashflows integer[],  categories integer[]) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 10000

AS $BODY$
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


select * from public.active_wf_rulesok()

END;
$BODY$;

`);

    prisma.$executeRaw(`-- DROP FUNCTION public.contracttasktobegeneratedsecv3(int4);

CREATE OR REPLACE FUNCTION public.contracttasktobegeneratedsecv3(contractid_param integer)
 RETURNS TABLE(taskname text, tasknotes text, contractid integer, statusid integer, requestorid integer, assignedid integer, approvedbyall boolean, approvaltypeinparallel boolean, workflowtasksettingsid integer, uuid integer, approvalordernumber integer, workflowid integer, priorityname text, priorityid integer, remindername text, reminderdays integer, duedate text, duedatedays integer, calculatedduedate timestamp without time zone, calculatedreminderdate timestamp without time zone, tasksendnotifications boolean, tasksendreminders boolean, taskstatusid integer)
 LANGUAGE plpgsql
 ROWS 10000
AS $function$
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
        AND coalesce(wfct."statusId",0) NOT IN (4,5) 
    --    AND wfct."uuid" is null
    ORDER BY 
        wftsu."approvalOrderNumber" 
    LIMIT 1;
END;
$function$
;
--SELECT * FROM contracttasktobegeneratedsecv3(1);
`);

    prisma.$executeRaw(`
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
--cs."id" = 1 and 
wfts."approvalTypeInParallel" =false ;


END;
$function$
;`);

    prisma.$executeRaw(`
CREATE OR REPLACE FUNCTION public.contracttasktobegeneratedok()
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
cs."id" = 1 and 
wfts."approvalTypeInParallel" =true ;


END;
$function$
;

--select * from public.contracttasktobegeneratedok() `
    );


    //     const priorities = [
    //         { name: 'Normală' },
    //         { name: 'Foarte Importantă' },
    //         { name: 'Importanță Maximă' }
    //     ];

    //     for (const priority of priorities) {
    //         await prisma.ContractTasksPriority.create({
    //             data: priority,
    //         });
    //     }

    //     prisma.$executeRaw(`
    //         INSERT INTO public."Alerts"
    //         ( "name", "isActive", subject, "text", internal_emails, nrofdays, param, "isActivePartner", "isActivePerson")
    //         VALUES
    //         ('Contract Inchis inainte de termen', false, 'Contract Inchis inainte de termen',
    //         'Va informam faptul ca urmeaza sa expire contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. 
    //         Acest contract este in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.',
    //         'office@companie.ro',30, 'Data Final Contract', false, false);
    //         `
    //     )

    //     prisma.$executeRaw(`
    //      CREATE OR REPLACE FUNCTION public.getauditcontract(contractid integer)
    //      RETURNS TABLE(contract_id integer, tip_modificare text, data_modificare timestamp without time zone,
    //      contract_number text, nume_partener text, nume_entitate text, stare text, start_date timestamp without time zone,
    //      end_date timestamp without time zone, sign_date timestamp without time zone, completion_date timestamp without time zone,
    //      nume_categorie text, departament text, cashflow text, tip_contract text, centru_cost text, utilizator text)
    //         LANGUAGE plpgsql
    //         AS $function$
    //     begin 
    // 	RETURN QUERY
    //     select
    //     c.id as contract_id,
    //         c."operationType" Tip_Modificare,
    //             c."createdAt" as Data_Modificare,
    //                 c.number as Contract_Number,
    //                 a.name as Nume_Partener,
    //                 b.name as Nume_Entitate,
    //                 cs.name as Stare,
    //                 c.start as Start_Date,
    //                 c.end as End_Date,
    //                 c.sign as Sign_Date,
    //                 c.completion as Completion_Date,
    //                 ca.name as Nume_Categorie,
    //                 dep.name as Departament,
    //                 cf.name as Cashflow,
    //                 ct.name as Tip_Contract,
    //                 cc.name as Centru_Cost,
    //                 us.name as Utilizator
    // 	from public."ContractsAudit" c
    //     left join public."Partners" a on c."partnersId" = a.id 
    // 	left join public."Partners" b on c."entityId" = b.id 
    // 	left join public."Category" ca  on c."categoryId" = ca.id 
    // 	left join public."ContractStatus" cs on cs."id" = c."statusId"
    // 	left join public."Department" dep  on dep."id" = c."departmentId"
    // 	left join public."Cashflow" cf on cf."id" = c."cashflowId"
    // 	left join public."ContractType" ct on ct."id" = c."typeId"
    // 	left join public."CostCenter"  cc on cc."id" = c."costcenterId"
    // 	left join public."User" us on us."id" = c."userId"
    // where c.id = contractid;
    //     end;
    //     $function$;
    //     `
    //     )

    //     prisma.$executeRaw(`
    //    CREATE OR REPLACE FUNCTION get_contract_details()
    // RETURNS TABLE (
    //     TipContract TEXT,
    //     number TEXT,
    //     start_date DATE,
    //     end_date DATE,
    //     sign_date DATE,
    //     completion_date DATE,
    //     remarks TEXT,
    //     partner_name TEXT,
    //     entity_name TEXT,
    //     automatic_renewal TEXT,
    //     status_name TEXT,
    //     cashflow_name TEXT,
    //     category_name TEXT,
    //     contract_type_name TEXT,
    //     department_name TEXT,
    //     cost_center_name TEXT,
    //     partner_person_name TEXT,
    //     partner_person_role TEXT,
    //     partner_person_email TEXT,
    //     entity_person_name TEXT,
    //     entity_person_role TEXT,
    //     entity_person_email TEXT,
    //     partner_address TEXT,
    //     entity_address TEXT,
    //     partner_bank TEXT,
    //     partner_currency TEXT,
    //     partner_iban TEXT,
    //     entity_bank TEXT,
    //     entity_currency TEXT,
    //     entity_iban TEXT
    // )
    // AS $$
    // BEGIN
    //     RETURN QUERY
    //     SELECT 
    //         CASE
    //             WHEN c."isPurchasing" = FALSE THEN 'Client'
    //             ELSE 'Furnizor'
    //         END AS TipContract,
    //         c.number,
    //         c.start::DATE,
    //         c.end::DATE,
    //         c.sign::DATE,
    //         c.completion::DATE,
    //         COALESCE(c.remarks, '') AS remarks,
    //         p.name AS partner_name,
    //         e.name AS entity_name,
    //        case when  c."automaticRenewal" = true then 'Da' else 'NU' END AS automatic_renewal,
    //         cs.name AS status_name,
    //         COALESCE(c2.name, '') AS cashflow_name,
    //         COALESCE(c3.name, '') AS category_name,
    //         COALESCE(ct.name, '') AS contract_type_name,
    //         COALESCE(d.name, '') AS department_name,
    //         COALESCE(cc.name, '') AS cost_center_name,
    //         COALESCE(pp.name, '') AS partner_person_name,
    //         COALESCE(pp.role, '') AS partner_person_role,
    //         pp.email AS partner_person_email,
    //         COALESCE(pe.name, '') AS entity_person_name,
    //         COALESCE(pe.role, '') AS entity_person_role,
    //         pe.email AS entity_person_email,
    //         COALESCE(ap."completeAddress", '') AS partner_address,
    //         COALESCE(ae."completeAddress", '') AS entity_address,
    //         COALESCE(bp.bank, '') AS partner_bank,
    //         COALESCE(bp.currency, '') AS partner_currency,
    //         COALESCE(bp.iban, '') AS partner_iban,
    //         COALESCE(be.bank, '') AS entity_bank,
    //         COALESCE(be.currency, '') AS entity_currency,
    //         COALESCE(be.iban, '') AS entity_iban
    //     FROM 
    //         public."Contracts" c 
    //     JOIN 
    //         public."ContractStatus" cs ON c."statusId" = cs.id 
    //     JOIN 
    //         "Partners" p ON p.id = c."partnersId" 
    //     JOIN 
    //         "Partners" e ON e.id = c."entityId"    
    //     LEFT JOIN 
    //         "Cashflow" c2 ON c2.id = c."cashflowId" 
    //     LEFT JOIN 
    //         "Category" c3 ON c3.id = c."categoryId" 
    //     LEFT JOIN 
    //         "ContractType" ct ON ct.id = c."typeId" 
    //     LEFT JOIN 
    //         "Department" d ON d.id = c."departmentId" 
    //     LEFT JOIN 
    //         "CostCenter" cc ON cc.id = c."costcenterId" 
    //     LEFT JOIN 
    //         "Persons" pp ON pp.id = c."partnerpersonsId"
    //     LEFT JOIN 
    //         "Persons" pe ON pe.id = c."entitypersonsId"
    //     LEFT JOIN 
    //         "Address" ap ON ap.id = c."partneraddressId" 
    //     LEFT JOIN 
    //         "Address" ae ON ae.id = c."entityaddressId" 
    //     LEFT JOIN 
    //         "Banks" bp ON bp.id = c."partnerbankId"  
    //     LEFT JOIN 
    //         "Banks" be ON be.id = c."entitybankId";
    // END;
    // $$ LANGUAGE plpgsql;



    // --SELECT * FROM get_contract_details();
    //     `
    //     )



    //     prisma.$executeRaw(`

    // --select * from public.calculate_cashflow_func()

    // CREATE OR REPLACE FUNCTION public.calculate_cashflow_func()
    // RETURNS TABLE(tip text, billingvalue numeric, month_number numeric ) 

    // LANGUAGE plpgsql
    // COST 100
    // VOLATILE PARALLEL UNSAFE
    // ROWS 10000
    // AS $BODY$
    // BEGIN
    //    RETURN QUERY
    //     SELECT x.tip,
    //            SUM(x.billingValue) AS billingValue,
    //            EXTRACT(MONTH FROM x."date") AS month_number
    //     FROM (
    //         SELECT 'P' AS tip,
    //                cfdb.date,
    //                ROUND((cfdb."billingValue" * er.amount)::NUMERIC, 2) AS billingValue
    //         FROM public."ContractItems" ci
    //         LEFT JOIN public."Contracts" c ON c."id" = ci."contractId"
    //         LEFT JOIN public."ContractFinancialDetail" cfd ON cfd."contractItemId" = ci."id"
    //         LEFT JOIN public."ContractFinancialDetailSchedule" cfdb ON cfdb."contractfinancialItemId" = cfd."id"
    //         LEFT JOIN public."Currency" cr ON cr."id" = cfdb.currencyid
    //         LEFT JOIN (
    //             SELECT * FROM public."ExchangeRates" WHERE public."ExchangeRates"."date" =
    //                 (SELECT MAX("date") FROM public."ExchangeRates") 
    //         ) er ON er."name" = cr.code
    //         WHERE ci.active IS TRUE
    //         AND cfd.active IS TRUE
    //         AND cfdb.active IS TRUE
    //         AND c."isPurchasing" IS TRUE
    //         AND cfdb."date" BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 months'

    //         UNION ALL

    //         SELECT 'I' AS tip,
    //                cfdb.date,
    //                ROUND((cfdb."billingValue" * er.amount)::NUMERIC, 2) AS billingValue
    //         FROM public."ContractItems" ci
    //         LEFT JOIN public."Contracts" c ON c."id" = ci."contractId"
    //         LEFT JOIN public."ContractFinancialDetail" cfd ON cfd."contractItemId" = ci."id"
    //         LEFT JOIN public."ContractFinancialDetailSchedule" cfdb ON cfdb."contractfinancialItemId" = cfd."id"
    //         LEFT JOIN public."Currency" cr ON cr."id" = cfdb.currencyid
    //         LEFT JOIN (
    //             SELECT * FROM public."ExchangeRates" WHERE public."ExchangeRates"."date" =
    //                 (SELECT MAX("date") FROM public."ExchangeRates") 
    //         ) er ON er."name" = cr.code
    //         WHERE ci.active IS TRUE
    //         AND cfd.active IS TRUE
    //         AND cfdb.active IS TRUE
    //         AND c."isPurchasing" IS FALSE
    //         AND cfdb."date" BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 months'
    //     ) x
    //     GROUP BY x.tip, EXTRACT(MONTH FROM x."date")
    //     ORDER BY 1;

    // END;
    // $BODY$
    // ;

    // ALTER FUNCTION public.get_contract_details()
    //     OWNER TO sysadmin;
    // `
    //     )

    //     prisma.$executeRaw(`
    //     CREATE OR REPLACE FUNCTION public.report_cashflow(
    //     )
    //     RETURNS TABLE(
    //         ContractId integer, TipTranzactie text, Partener text,
    //         Entitate text, NumarContract text, Start date, Final date,
    //         DescriereContract text,
    //         Cashflow text,
    //         Data date, ProcentPlusBNR double precision,
    //         ProcentPenalitate double precision, NrZileScadente integer,
    //         Articol text, Cantitate double precision, PretUnitarInValuta double precision,
    //         ValoareInValuta double precision,
    //         Valuta text, CursValutar double precision,
    //         ValoareRon numeric, --20
    // 	PlatitIncasat text, Facturat text
    //     ) 
    //     LANGUAGE 'plpgsql'
    //     COST 100
    //     VOLATILE PARALLEL UNSAFE
    //     ROWS 1000

    // AS $BODY$
    //     BEGIN
    //     RETURN QUERY
    // SELECT c.id AS ContractId,
    //         CASE
    //             WHEN c."isPurchasing" = FALSE THEN 'Incasare'
    //             ELSE 'Plata'
    //         END AS TipTranzactie,
    //         p.name  AS Partener,
    //             e.name  AS Entitate,
    //                 c.number AS NumarContract,
    //                     c.start::DATE Start,
    //                         c.end::DATE Final,
    //                             COALESCE(c.remarks, '') AS DescriereContract,
    //                                 --cs.name AS status_name,
    //                                     COALESCE(c2.name, '') AS Cashflow,
    //                                         cfdb.date::DATE Data, --10
    //     cfd."currencyPercent" ProcentPlusBNR,
    //         cfd."billingPenaltyPercent" ProcentPenalitate,
    //             cfd."billingDueDays" NrZileScadente,
    //                 it.name Articol,
    //                     cfdb."billingQtty" Cantitate,
    //                         cfdb."billingValue" PretUnitarInValuta,
    //                             (cfdb."billingQtty" * cfdb."billingValue") ValoareInValuta,
    //                                 cr.code Valuta,
    //                                     er.amount CursValutar,
    //                                         ROUND((cfdb."billingQtty" * cfdb."billingValue" * er.amount):: NUMERIC, 2) AS ValoareRon,
    //                                             CASE
    //             WHEN cfdb."isPayed" = FALSE THEN 'Nu'
    //             ELSE 'Da'
    //         END AS PlatitIncasat,

    //         CASE
    //             WHEN cfdb."isInvoiced" = FALSE THEN 'Nu'
    //             ELSE 'Da'
    //         END AS Facturat

    //     FROM
    //     public."ContractItems" ci
    // 	join public."Item" it on ci."itemid" = it."id"
    // 	left join public."Contracts" c on c."id" = ci."contractId"
    //   	left join public."ContractFinancialDetail" cfd on cfd."contractItemId" = ci."id"
    // 	left join public."ContractFinancialDetailSchedule" cfdb 
    // 	left join public."Currency" cr on cr."id" = cfdb.currencyid
    // 	left join(select * from public."ExchangeRates" 
    // 		where public."ExchangeRates"."date" =
    //     (select max("date") from public."ExchangeRates") 
    // 	) er  
    // 	on er."name" = cr.code
    // 	on cfdb."contractfinancialItemId" = cfd."id"
    //     JOIN
    //     public."ContractStatus" cs ON c."statusId" = cs.id
    //     JOIN
    //     "Partners" p ON p.id = c."partnersId"
    //     JOIN
    //     "Partners" e ON e.id = c."entityId"    
    //     LEFT JOIN
    //     "Cashflow" c2 ON c2.id = c."cashflowId" 
    //     LEFT JOIN
    //     "ContractType" ct ON ct.id = c."typeId" 
    //     LEFT JOIN
    //     "Banks" bp ON bp.id = c."partnerbankId"  
    //     LEFT JOIN
    //     "Banks" be ON be.id = c."entitybankId"
    // where ci.active is true and cfd.active is true and cfdb.active is true;
    //     END;
    //     $BODY$;

    // ALTER FUNCTION public.report_cashflow()
    //     OWNER TO sysadmin;


    //     --select * from public.report_cashflow()
    //     `
    //     )

    //     await prisma.alerts.createMany({
    //         data: [
    //             {
    //                 name: "Contract Inchis inainte de termen",
    //                 isActive: true,
    //                 subject: "Contract Inchis inainte de termen",
    //                 text: "Va informam faptul ca a fost inchis contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract a fost in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.",
    //                 internal_emails: "office@companie.ro",
    //                 nrofdays: 0,
    //                 param: "Inchis la data",
    //                 isActivePartner: false,
    //                 isActivePerson: false
    //             },
    //             {
    //                 name: "Expirare Contract",
    //                 isActive: true,
    //                 subject: "Expirare Contract",
    //                 text: "Va informam faptul ca urmeaza sa expire contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract este in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.",
    //                 internal_emails: "office@companie.ro",
    //                 nrofdays: 30,
    //                 param: "Data Final",
    //                 isActivePartner: false,
    //                 isActivePerson: false
    //             },
    //         ]
    //     });


    //     const roleName = [
    //         { roleName: "Administrator" },
    //         { roleName: "Reader" },
    //         { roleName: "Requestor" },
    //         { roleName: "Editor" }]

    //     for (const roles of roleName) {
    //         await prisma.role.create({
    //             data: roles,
    //         });
    //     }

    // console.log('Seed completed');
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