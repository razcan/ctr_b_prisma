import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {

    const contractType = [
        { name: "Contracte de Vanzare-Cumparare" },
        { name: "Contracte de inchiriere" },
        { name: "Contracte de servicii" },
        { name: "Contracte de parteneriat" },
        { name: "Contracte de colaborare" },
        { name: "Contracte de constructie" },
        { name: "Contracte de licentiere" },
        { name: "Contracte de franciză" },
        { name: "Contracte de imprumut" },
        { name: "Contracte de agent" },
        { name: "Contracte de dezvoltare Software" },
        { name: "Contracte de asigurare" },
        { name: "Contracte imobiliare" },
        { name: "Contracte de mentenanta" },
        { name: "Contracte abonament" },
        { name: "Contract de schimb" },
        { name: "Contract de report" },
        { name: "Contract de antrepriză" },
        { name: "Contract de asociere în participație" },
        { name: "Contract de transport" },
        { name: "Contract de mandat" },
        { name: "Contract de comision" },
        { name: "Contract de consignație" },
        { name: "Contract de agenție" },
        { name: "Contract de intermediere" },
        { name: "Contract de depozit" },
        { name: "Contract de cont curent" },
        { name: "Contract de joc și pariu" },
        { name: "Contract de donație" },
        { name: "Contract de fiducie" },
        { name: "Contract de leasing" },
        { name: "Contract de factoring" }
    ];


    const contractStatus = [
        { name: 'In lucru' },
        { name: 'Asteapta aprobarea' },
        { name: 'In curs de revizuire' },
        { name: 'Aprobat' },
        { name: 'In executie' },
        { name: 'Activ' },
        { name: 'Expirat' },
        { name: 'Finalizat' },
        { name: 'Reinnoit' },
        { name: 'Modificat' },
        { name: 'Inchis inainte de termen' },
        { name: 'Contestat' },
    ]

    const cashflowLines = [
        { name: 'Incasari operationale' },
        { name: 'Incasari financiare' },
        { name: 'Plati operationale' },
        { name: 'Plati investitionale' },
        { name: 'Plati financiare' },
        { name: 'Tranzactii InterCompany' },
        { name: 'Salarii' },
        { name: 'Furnizori activitate curenta' },
        { name: 'Utilitati' },
        { name: 'Auto combustibili si reparatii' },
        { name: 'Paza' },
        { name: 'Publicitate si sponsorizare' },
        { name: 'Deplasari + diurne' },
        { name: 'Marfa MUDR' },
        { name: 'Restituiri clienti' },
        { name: 'Investitii in curs' },
        { name: 'Investitii finalizate' },
        { name: 'Asigurari/ leasing , comisioane banci' },
        { name: 'Restituire credite si dobanzi' },
        { name: 'Impozit pe profit' },
        { name: 'Impozite locale' },
        { name: 'TVA de plata  ' },
        { name: 'Taxa salarii' },
        { name: 'Tranzactii intercompany' },
        { name: 'Transfer bancar(credit)' },
        { name: 'Transfer bancar(debit)' },
        { name: 'Plati Deconturi' },
        { name: 'Investitii Proprii' },
        { name: 'Compensari/Girari/Retururi' }]

    const costcenters = [
        { name: 'Abonamente RATB' },
        { name: 'Achizitii carti de specialitate' },
        { name: 'Achizitii de specialitate' },
        { name: 'Achizitii produse auto' },
        { name: 'Administratia pietelor' },
        { name: 'Administratie' },
        { name: 'Alpinisti utilitari' },
        { name: 'Alte cheltuieli' },
        { name: 'Alte cheltuieli si evenimente' },
        { name: 'Alte facilitati - masa personal, utilitati, servicii, abonamente RATB' },
        { name: 'Alte facilitati personal alte persoane' },
        { name: 'Alte obiective' },
        { name: 'Alte taxe (Reg. comert, mediu, urbanism, avize)' },
        { name: 'Altele' },
        { name: 'Amenajare incinta' },
        { name: 'Andimed - medicina muncii' },
        { name: 'Anunturi piblicitare, taxe postale si alte taxe' },
        { name: 'Anunturi publicitare, taxe postale' },
        { name: 'Apa' },
        { name: 'Apa menajera' },
        { name: 'Apartamente' },
        { name: 'Apele Romane' },
        { name: 'Ascensorul Schindler - servicii mentenanta' },
        { name: 'Asigurari auto casco si RCA' },
        { name: 'Asigurari cladiri si de viata' },
        { name: 'Autofinantare' },
        { name: 'Autorizatie/Licenta utilizare muzica' },
        { name: 'Bonuri de masa' },
        { name: 'Bonuri de masa alte persoane' },
        { name: 'Bugetul Managerului General' },
        { name: 'Carburant Auto' },
        { name: 'Carburant auto personal Tesa' },
        { name: 'Cheltuieli administrare si intretinere' },
        { name: 'Cheltuieli Comunicare' },
        { name: 'Cheltuieli comunicare' },
        { name: 'Cheltuieli cu personalul' },
        { name: 'Cheltuieli financiare' },
        { name: 'Cheltuieli imagine' },
        { name: 'Cheltuieli linie CFR / taxa drumuri/ taxa poduri' },
        { name: 'Cheltuieli Neprevazute' },
        { name: 'Cheltuieli neprevazute' },
        { name: 'Cheltuieli personal alte obiective fara profit' },
        { name: 'Cheltuieli personal Tesa' },
        { name: 'Cheltuieli sp. SNCFR ' },
        { name: 'Cheltuieli transport' },
        { name: 'Cheltuieli utilitati' }]

    const Currency = [
        { code: "RON", name: "LEU" },
        { code: "EUR", name: "Euro" },
        { code: "USD", name: "Dolarul SUA" },
        { code: "CHF", name: "Francul elveţian" },
        { code: "GBP", name: "Lira sterlină" },
        { code: "BGN", name: "Leva bulgarească" },
        { code: "RUB", name: "Rubla rusească" },
        { code: "ZAR", name: "Randul sud-african" },
        { code: "BRL", name: "Realul brazilian" },
        { code: "CNY", name: "Renminbi-ul chinezesc" },
        { code: "INR", name: "Rupia indiană" },
        { code: "MXN", name: "Peso-ul mexican" },
        { code: "NZD", name: "Dolarul neo-zeelandez" },
        { code: "RSD", name: "Dinarul sârbesc" },
        { code: "UAH", name: "Hryvna ucraineană" },
        { code: "TRY", name: "Noua lira turcească" },
        { code: "AUD", name: "Dolarul australian" },
        { code: "CAD", name: "Dolarul canadian" },
        { code: "CZK", name: "Coroana cehă" },
        { code: "DKK", name: "Coroana daneză" },
        { code: "EGP", name: "Lira egipteană" },
        { code: "HUF", name: "Forinți maghiari" },
        { code: "JPY", name: "Yeni japonezi" },
        { code: "MDL", name: "Leul moldovenesc" },
        { code: "NOK", name: "Coroana norvegiană" },
        { code: "PLN", name: "Zlotul polonez" },
        { code: "SEK", name: "Coroana suedeză" },
        { code: "AED", name: "Dirhamul Emiratelor Arabe" },
        { code: "THB", name: "Bahtul thailandez" }
    ]


    const Banks = [
        { name: "Alpha Bank" },
        { name: "BRCI" },
        { name: "Banca FEROVIARA" },
        { name: "Intesa Sanpaolo" },
        { name: "BCR" },
        { name: "BCR Banca pentru Locuinţe" },
        { name: "Eximbank" },
        { name: "Banca Românească" },
        { name: "Banca Transilvania" },
        { name: "Leumi" },
        { name: "BRD" },
        { name: "CEC Bank" },
        { name: "Crédit Agricole" },
        { name: "Credit Europe" },
        { name: "Garanti Bank" },
        { name: "Idea Bank" },
        { name: "Libra Bank" },
        { name: "Vista Bank" },
        { name: "OTP Bank" },
        { name: "Patria Bank" },
        { name: "First Bank" },
        { name: "Porsche Bank" },
        { name: "ProCredit Bank" },
        { name: "Raiffeisen" },
        { name: "Aedificium Banca pentru Locuinte" },
        { name: "UniCredit" },
        { name: "Alior Bank" },
        { name: "BLOM Bank France" },
        { name: "BNP Paribas" },
        { name: "Citibank" },
        { name: "ING" },
        { name: "TBI " }]



    for (const type of contractType) {
        await prisma.contractType.create({
            data: type,
        });
    }

    for (const status of contractStatus) {
        await prisma.contractStatus.create({
            data: status,
        });
    }

    for (const cf of cashflowLines) {
        await prisma.cashflow.create({
            data: cf,
        });
    }

    for (const cc of costcenters) {
        await prisma.costCenter.create({
            data: cc,
        });
    }

    for (const currency of Currency) {
        await prisma.currency.create({
            data: currency,
        });
    }

    for (const bank of Banks) {
        await prisma.bank.create({
            data: bank,
        });
    }



    const Frequency = [
        { name: "Zilnic" },
        { name: "Săptămânal" },
        { name: "Lunar" },
        { name: "Trimestrial" },
        { name: "Semestrial" },
        { name: "Anual" },
        { name: "Personalizat" }
    ]

    const MeasuringUnit = [
        { name: "Lună (lună)" },
        { name: "Oră (h)" },
        { name: "Zi (zi)" },
        { name: "An (an)" },
        { name: "Metru (m)" },
        { name: "Metru pătrat (m²)" },
        { name: "Centimetru (cm)" },
        { name: "Centimetru pătrat (cm²)" },
        { name: "Kilometru (km)" },
        { name: "Milimetru (mm)" },
        { name: "Milă (mi)" },
        { name: "Gram (g)" },
        { name: "Kilogram (kg)" },
        { name: "Tona metrică (t)" },
        { name: "Miligram (mg)" },
        { name: "Centigram (cg)" },
        { name: "Uncie (oz)" },
        { name: "Mililitru (ml)" },
        { name: "Centilitru (cl)" },
        { name: "Secundă (s)" },
        { name: "Minut (min)" },
        { name: "Săptămână (săptămână)" },
        { name: "Centimetru cub (cm³ sau cc)" },
        { name: "Metru cub (m³)" },
        { name: "Mililitru (ml)" },
        { name: "Hectolitră (hl)" },
        { name: "Calorie (cal)" },
        { name: "Kilocalorie (kcal)" },
        { name: "Watt-ora (Wh)" },
        { name: "Kilowatt-ora (kWh)" },
        { name: "Hectare (ha)" }]



    const ContractTasksStatus = [
        { id: 1, name: "In curs" },
        { id: 2, name: "Finalizat" },
        { id: 3, name: "Anulat" },
    ]

    for (const status of ContractTasksStatus) {
        await prisma.contractTasksStatus.create({
            data: status,
        });
    }


    for (const measuringunit of MeasuringUnit) {
        await prisma.measuringUnit.create({
            data: measuringunit,
        });
    }


    for (const frequency of Frequency) {
        await prisma.billingFrequency.create({
            data: frequency,
        });
    }


    const PaymentType = [
        { name: "Numerar" },
        { name: "Ordin de Plată" },
        { name: "Cec" },
        { name: "Bilet la ordin" },
        { name: "Transfer Bancar" },
        { name: "Virament Bancar" },
        { name: "Portofel Digital(PayPal, Venmo...)" },
        { name: "Bitcoin și Criptomonede" },
        { name: "Card de Debit" },
        { name: "Card de Credit" }]

    for (const type of PaymentType) {
        await prisma.PaymentType.create({
            data: type,
        });
    }

    prisma.$executeRaw(`
        INSERT INTO public."Alerts"
        ( "name", "isActive", subject, "text", internal_emails, nrofdays, param, "isActivePartner", "isActivePerson")
        VALUES
        ('Contract Inchis inainte de termen', false, 'Contract Inchis inainte de termen',
        'Va informam faptul ca urmeaza sa expire contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract este in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.',
        'office@companie.ro',30, 'Data Final Contract', false, false);
        `
    )

    prisma.$executeRaw(`
     CREATE OR REPLACE FUNCTION public.getauditcontract(contractid integer)
     RETURNS TABLE(contract_id integer, tip_modificare text, data_modificare timestamp without time zone,
     contract_number text, nume_partener text, nume_entitate text, stare text, start_date timestamp without time zone,
     end_date timestamp without time zone, sign_date timestamp without time zone, completion_date timestamp without time zone,
     nume_categorie text, departament text, cashflow text, tip_contract text, centru_cost text, utilizator text)
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
    $function$;
    `
    )

    prisma.$executeRaw(`
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
    `
    )



    prisma.$executeRaw(`
   -- PROCEDURE: public.calculate_cashflow()

-- DROP PROCEDURE IF EXISTS public.calculate_cashflow();

CREATE OR REPLACE PROCEDURE public.calculate_cashflow(
	)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RAISE NOTICE 'Calculating cashflow...';
    
    CREATE  TABLE temp_cashflow AS
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
    
    RAISE NOTICE 'Cashflow calculation completed.';
END;
$BODY$;
ALTER PROCEDURE public.calculate_cashflow()
    OWNER TO postgres;

`
    )

    prisma.$executeRaw(`
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
    $BODY$;

ALTER FUNCTION public.report_cashflow()
    OWNER TO sysadmin;


    --select * from public.report_cashflow()
    `
    )

    await prisma.alerts.createMany({
        data: [
            {
                name: "Contract Inchis inainte de termen",
                isActive: true,
                subject: "Contract Inchis inainte de termen",
                text: "Va informam faptul ca a fost inchis contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract a fost in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.",
                internal_emails: "office@companie.ro",
                nrofdays: 0,
                param: "Inchis la data",
                isActivePartner: false,
                isActivePerson: false
            },
            {
                name: "Expirare Contract",
                isActive: true,
                subject: "Expirare Contract",
                text: "Va informam faptul ca urmeaza sa expire contractul cu numarul @@NumarContract din data de @@DataContract la partenerul @@Partener. Acest contract este in vigoare in compania @@Entitate si reprezinta @@ScurtaDescriere.",
                internal_emails: "office@companie.ro",
                nrofdays: 30,
                param: "Inchis la data",
                isActivePartner: false,
                isActivePerson: false
            },
        ]
    });


    const roleName = [
        { roleName: "Administrator" },
        { roleName: "Reader" },
        { roleName: "Requestor" },
        { roleName: "Editor" }]

    for (const roles of roleName) {
        await prisma.role.create({
            data: roles,
        });
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