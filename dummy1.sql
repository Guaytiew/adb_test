SELECT   -- WELLVIEW Source start -----------------------------------------
	NEWID() AS id,		
	COALESCE(daily_report.id, '00000000-0000-0000-0000-000000000000') AS daily_report_id,
	'00000000-0000-0000-0000-000000000000' AS opt_code_id,
	'00000000-0000-0000-0000-000000000000' AS form_id,
	wellview.unit_id,
	-- wellview.opt_name,    -- Temporary remove to fit schema on 7 June
	'ONLINE' AS type,
	wellview.start_date_time,
	wellview.end_date_time,
	wellview.duration_time,
	wellview.activity_detail,
	-- CAST(NULL AS VARCHAR) AS activity_detail_structure,  -- Temporary remove to fit schema on 7 June
	wellview.activity_detail_structure,    -- Temporary add to fit schema on 7 June
	wellview.creator_id,
	wellview.creator,
	SYSDATETIMEOFFSET() AS created_date, 
	wellview.creator_id AS modifer_id,
	wellview.creator AS modifier,
	SYSDATETIMEOFFSET() AS modified_date,
	1 AS version,
	CAST(NULL AS VARCHAR) AS remark,
	CAST(NULL AS UNIQUEIDENTIFIER) AS delegated_by_id,
	CAST(NULL AS UNIQUEIDENTIFIER) AS tab_id,
	CAST(NULL AS VARCHAR) AS form_detail,
	CAST(NULL AS VARCHAR) AS form_value,
	CAST(NULL AS VARCHAR) AS activity_code,
	CAST(NULL AS VARCHAR) AS attachment_id   -- Temporary add to fit schema on 7 June
FROM (
	SELECT
		data_entry.id AS data_entry_id,
		COALESCE(well_work.well_work_no, main.USERTXT1) AS well_work_no,
		mst_well.well_name,
		job.job_type_name,
		DENSE_RANK() OVER (PARTITION BY COALESCE(well_work.well_work_no, main.USERTXT1) ORDER BY main.DTTMSTART) AS report_no,
		main.STARTDATE AS start_date_time,
		COALESCE(main.ENDDATE, DATEADD(HOUR, main.DURATION, main.STARTDATE )) AS end_date_time,
		CAST(FORMAT(DATEADD(MINUTE, main.DURATION * 60, '00:00:00'), 'HH:mm') AS VARCHAR) AS duration_time,
		unit_data_entry.unit_id,
		COALESCE(main.DETAIL, '-') AS activity_detail,
		--CASE 		
		--	WHEN NULLIF(ACTIVITY1, ' ') IS NULL THEN NULLIF(ACTIVITY2, ' ')
		--	WHEN NULLIF(ACTIVITY2, ' ') IS NULL THEN NULLIF(ACTIVITY1, ' ')
		--	WHEN ACTIVITY1 IS NOT NULL AND ACTIVITY2 IS NOT NULL THEN CONCAT(ACTIVITY1, ':', ACTIVITY2)
		--	ELSE NULL
		--END AS opt_name,
		-- Temporary remove to fit schema on 7 June
		'' AS activity_detail_structure,    -- Temporary add to fit schema on 7 June
		COALESCE(mu.id, (SELECT id FROM [Wisdom-DB-02].PRE_WISDOM.mst_user WHERE [name] = 'Data Migration')) AS creator_id,
		main.creator AS creator
	FROM (
		Select
			job.USERTXT1,
			daily.NEW_GUID,
			well.WELLNAME,
			wellbore.DES,
			COALESCE(timelog.DTTMSTARTCALC,daily.DTTMSTART,daily.DTTMEND, SYSDATETIMEOFFSET()) as STARTDATE,
			timelog.DTTMENDCALC as ENDDATE,
			COALESCE(timelog.DURATION, 0) as DURATION,
			timelog.CODE2 as ACTIVITY1,
			timelog.CODE1 as ACTIVITY2,
			timelog.COM as DETAIL,
			job.WVTYP as JOBCATEGORY,
			job.JOBTYP as PRIMARYJOBTYPE,
			timelog.PROBLEMCALC as UNSCHEDULE,
			timelog.DURATIONPROBLEMTIMECALC as UETIME,
			timelog.IDRECPARENT,
			daily.DTTMSTART,
			'Data Migration' AS creator
		from [Wisdom-DB-02].WELLVIEW_METRIC.v_wvwellheader as well
		Inner join [Wisdom-DB-02].WELLVIEW_METRIC.v_wvwellbore as wellbore on well.idwell=wellbore.idwell and wellbore.deleted='FALSE'
		Inner join [Wisdom-DB-02].WELLVIEW_METRIC.v_wvjob as job on wellbore.idwell=job.idwell and job.idrecwellbore=wellbore.idrec and job.deleted='FALSE'
		Inner join [Wisdom-DB-02].WELLVIEW_METRIC.v_wvjobreport as daily on job.idrec=daily.idrecparent and daily.deleted='FALSE'
		Left join [Wisdom-DB-02].WELLVIEW_METRIC.v_wvjobreporttimelog as timelog on timelog.idrecparent=daily.idrec and timelog.deleted='FALSE'
		WHERE job.USERTXT1 <> '' AND job.USERTXT1 IS NOT NULL AND well.deleted = 'FALSE' --AND UPPER(wellbore.DES) <> 'TESTWELL'
			AND wellbore.DES NOT IN ('10A-1', '10A-2', '10A-3',   '11A-1', '11A-2', '1AA-1', '1AA-2',
							'3AA-1', '3CA-1', '3CA-2', '3CA-3', '3CA-A2', '3CA-B1', '3DA-1', '3DA-P', '3DA-X', '3DA-XA', '3DA-XB', '3DA-XC', '3DA-XD', '3DB-1', '3DB-A', '3DC-A', '3DE-1', '3DF-X',
							'AYADANA-1A', 'AYADANA-1AST', 'AYD-1',
							'BA05', 'BA08', 'BA10', 'BA11', 'BA12', 'BA13', 'BA14', 'BA15', 'BA16', 'Baanpot-17', 'Baanpot-18', 'Baanpot-18S', 'Baanpot-18S2', 'Baanpot-19', 'Baanpot-19S', 'Baanpot-20',
							'BADAMYAR-1', 'BADAMYAR-2', 'BDM-4A', 'BDM-4C', 'BDM-4E', 'BDM-4G', 'BDM-4I', 'DA03', 'DA05', 'DA06',
							'ER11', 'ER13', 'ER14', 'ER16', 'ER16R', 'ER28', 'ER37', 'ER46', 'ER47', 'ER48', 'ER49', 'Erawan-50', 'ERWP-36',
							'FU01', 'FU05', 'FU09', 'FU12', 'FU13', 'FU16', 'FU16S', 'FU17', 'FU20', 'FU22', 'FU23', 'FU25', 'FU26', 'FU26S', 'Funan-27', 'GO01', 'GO04', 'GO06',
							'Jakrawan-19', 'Jakrawan-20', 'JK02', 'JK03', 'JK04', 'JK05', 'JK08', 'JK08S', 'JK09', 'JK10', 'JK12', 'JK13', 'JK16', 'JK18', 'JK19', 'JK20',
							'Kaphong-15', 'Kaphong-16', 'KP02', 'KP03', 'KP04', 'KP05', 'KP09', 'KP14',
							'Leg 1', 'Leg 2', 'Leg 3', 'Leg 4', 'Leg 5', 'Leg 6', 'Leg 7', 'Leg 8', 'Leg 9', 'M5/B-1', 'M5A-1', 'M6/A-1', 'M6/D-1',
							'NK01', 'NS01', 'NS02', 'NS03', 'NSDL-01', 'NSDL-02', 'NSDL-03', 'Original Hole',
							'Pakarang-11', 'Pakarang-12', 'Pakarang-13', 'Pakarang-13S', 'Pakarang-13S2', 'Pakarang-14', 'Pakarang-15', 'Pakarang-16', 'Pakarang-17',
							'PD01', 'PD02', 'PD03', 'PD04', 'PD06', 'PD07', 'PD08',
							'PK01', 'PK02', 'PK03', 'PK04', 'PK05', 'PK06', 'PK07', 'PK08', 'PK09', 'PK13S2',
							'PL02', 'PL03', 'PL04', 'PL05', 'PL08', 'PL09', 'PL14', 'PL18', 'PL20', 'PL21', 'Pladang-09', 'Plamuk-08', 'Platong-21', 'Platong-22', 'Platong-23', 'Platong-24', 'Platong-25',
							'PM01', 'PM02', 'PM03', 'PM05', 'PM06', 'PM07',
							'SA01', 'SA02', 'SA03', 'SA04', 'SA05', 'SA07', 'SA25', 'SA27', 'SA29', 'SA30', 'SA31', 'SA32', 'SA32S', 'Satun-33', 'Satun-34', 'Satun-35', 'Satun-35S',
							'SG01', 'SG02', 'SG03', 'SG04', 'SG05', 'SG06', 'Sidetrack 1', 'South Gomin-05', 'South Gomin-06', 'South Gomin-07', 'South Gomin-08',
							'SP01', 'SP02', 'SP03', 'SP07', 'SU04', 'SU05', 'SU06', 'SU07', 'SU08',
							'TR01', 'TR07', 'TR08', 'TR15', 'TR16', 'TR17', 'Trat-04', 'Trat-18', 'Trat-19', 'Trat-20', 'Trat-21', 'Trat-23', 'Trat-24', 'TESTWELL',
							'WD01', 'WD02', 'WD03', 'YA03', 'YA04', 'YA04S', 'YA05', 'YA06', 'YA07', 'Yad-1-m', 'Yad-1-m.G1', 'Yad-2-j',
							'YADANA-1', 'YADANA-1C', 'YADANA-1D', 'YADANA-1F', 'YADANA-1G', 'YADANA-1H', 'YADANA-1I', 'YADANA-1J', 'YADANA-1K', 'YADANA-1K.T1',
							'YADANA-2', 'YADANA-2A', 'YADANA-2B', 'YADANA-2C', 'YADANA-2D', 'YADANA-2E', 'YADANA-2F', 'YADANA-2G', 'YADANA-2GST', 'YADANA-2I', 'YADANA-2K',
							'YADANA-3', 'YADANA-3A', 'YADANA-3B', 'YADANA-4', 'YU01', 'Yungthong-03', 'Yungthong-04')
	) AS main
	LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.mst_user AS mu ON main.creator = mu.[name]
	LEFT JOIN (
		SELECT DISTINCT job_cate.[name] AS job_cate_name, job_type.[name] AS job_type_name, job_type.id AS job_type_id
		FROM [Wisdom-DB-02].PRE_WISDOM.temp_mst_job_cate AS job_cate
		LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.temp_mst_job_type AS job_type ON job_cate.id = job_type.job_cate_id 
	) AS job
	ON main.JOBCATEGORY = job.job_cate_name AND main.PRIMARYJOBTYPE = job.job_type_name
	LEFT JOIN [Wisdom-DB-02].REFINED_DATA.mst_well 	ON main.DES = mst_well.well_name
	LEFT JOIN (
    	SELECT DISTINCT	
    		id,
    		well_work_no,
    		CASE WHEN CHARINDEX('-', well_work_no) > 0
				         AND ISNUMERIC(RIGHT(well_work_no, LEN(well_work_no) - CHARINDEX('-', well_work_no))) = 1 
				         AND LEN(RIGHT(well_work_no, LEN(well_work_no) - CHARINDEX('-', well_work_no))) <= 2
				    THEN LEFT(well_work_no, CHARINDEX('-', well_work_no) - 1)
				    ELSE well_work_no END AS join_well_work_no,
    		well_id,
    		job_type_id
    	FROM [Wisdom-DB-02].PRE_WISDOM.temp_well_work
    	WHERE remark = 'Source WELLVIEW'
    ) AS well_work
    ON  main.USERTXT1 = well_work.join_well_work_no AND
    	mst_well.id = well_work.well_id AND
    	job.job_type_id = well_work.job_type_id
    LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.temp_data_entry AS data_entry
	ON COALESCE(well_work.well_work_no, main.USERTXT1) = data_entry.well_work_no
	LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.temp_unit_data_entry AS unit_data_entry
	ON data_entry.id = unit_data_entry.data_entry_id
) AS wellview
LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.temp_daily_report AS daily_report
ON  wellview.data_entry_id = daily_report.data_entry_id AND
	wellview.report_no = daily_report.report_no
-- WELLVIEW Source end -----------------------------------------
UNION ALL
-- Wise Start ---------------------------------
SELECT 
	--ops.NEW_GUID AS id,  -- Temporary change to new id because id not unique
	NEWID() AS id,
	COALESCE(ops.report_id, '00000000-0000-0000-0000-000000000000') AS daily_report_id,
	'00000000-0000-0000-0000-000000000000' AS opt_code_id,
	'00000000-0000-0000-0000-000000000000' AS form_id,
	tmu.id AS unit_id,
	'ONLINE' AS type,
	ops.START_TIME AS start_date_time,
	ops.END_TIME  AS end_date_time,
	CASE
		WHEN ops.duration_time = '00:00' THEN '00:01'
		ELSE ops.duration_time
	END AS duration_time,
	COALESCE(REPLACE(ops.DESCRIPTION, CHAR(10), '\n'), '-') AS activity_detail,
	'' AS activity_detail_structure,    -- Temporary add to fit schema on 7 June
	COALESCE(mu_c.id, (SELECT id FROM [Wisdom-DB-02].PRE_WISDOM.mst_user WHERE [name] = 'Data Migration')) AS creator_id,
	ops.INSERTED_BY AS creator,
	ops.INSERTED_DATE AS created_date, 
	COALESCE(mu_m.id, (SELECT id FROM [Wisdom-DB-02].PRE_WISDOM.mst_user WHERE [name] = 'Data Migration')) AS modifier_id,
	ops.UPDATED_BY AS modifier,
	COALESCE(ops.LAST_UPDATE, ops.INSERTED_DATE) AS modified_date,
	1 AS version,
	CAST(NULL AS VARCHAR) AS remark,
	CAST(NULL AS UNIQUEIDENTIFIER) AS delegated_by_id,
	CAST(NULL AS UNIQUEIDENTIFIER) AS tab_id,
	CAST(NULL AS VARCHAR) AS form_detail,
	CAST(NULL AS VARCHAR) AS form_value,
	CAST(NULL AS VARCHAR) AS activity_code,
	CAST(NULL AS VARCHAR) AS attachment_id   -- Temporary add to fit schema on 7 June
FROM ( SELECT 
			olt.NEW_GUID ,
			vdm.NEW_GUID AS report_id,
			FORMAT(DATEDIFF(HOUR, olt.START_TIME, olt.END_TIME), '00') + ':' +
    		FORMAT(DATEDIFF(MINUTE, olt.START_TIME, olt.END_TIME) % 60, '00') AS duration_time,
			vdm.PROGRAM_NO,
			vdm.BARGE_NAME ,
			olt.OPDATE ,
			olt.WELL_NAME, 
			olt.DESCRIPTION, 
			olt.START_TIME, 
			olt.END_TIME, 
			COALESCE(olt.INSERTED_BY,'Data Migration') AS INSERTED_BY, 
			olt.INSERTED_DATE, 
			COALESCE(olt.UPDATED_BY,'Data Migration') AS UPDATED_BY, 
			olt.LAST_UPDATE,
			CASE 
            WHEN vws.ST_NO = 1 THEN CONCAT(LEFT(vdm.WELL, CHARINDEX(',', vdm.WELL + ',') - 1), '-ST')
            WHEN vws.ST_NO > 1 THEN CONCAT(LEFT(vdm.WELL, CHARINDEX(',', vdm.WELL + ',') - 1), '-ST', vws.ST_NO)
        ELSE LEFT(vdm.WELL, CHARINDEX(',', vdm.WELL + ',') - 1) END AS WELL
		FROM [Wisdom-DB-02].WISE.V_P_OPS_LOG_TEMP AS olt
		LEFT JOIN  [Wisdom-db-02].WISE_VIEW.V_V_DAILYREPORT_WILD_MIGRATION AS vdm
		ON vdm.BARGE_NAME = olt.BARGE_NAME AND vdm.OPDATE = olt.OPDATE AND vdm.WELL = olt.WELL_NAME
		LEFT JOIN [Wisdom-db-02].WISE.V_WILD_SITE AS vws ON vws.SITENAME = vdm.WELL
		WHERE DELETE_FLAG IS NULL
)AS ops
LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.mst_user AS mu_c
ON ops.INSERTED_BY = mu_c.[name]
LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.mst_user AS mu_m
ON ops.UPDATED_BY = mu_m.[name] 
LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.temp_mst_unit AS tmu
ON ops.BARGE_NAME = tmu.[name]
WHERE ops.PROGRAM_NO LIKE 'WWR%' AND 
		ops.WELL NOT IN ('TEST_WELL', 'TN-1-A') AND 
		ops.WELL NOT IN ('15-B-10X', '15-B-11X', '15-B-12X', '15-B-14X', '15-B-4X', '15-B-5X', '15-B-6X', '15-B-8X', '16-E-1', '16-I-1',
				'AT-11-F', 'AT-11-G', 'AT-11-K', 'AT-22-J', 'AT-R26-K_ST', 'AWP-07', 'AWP-09', 'AWP-1N', 'AWP-21', 'AWP-26', 'AWP-32', 'AWP-3N',
				'BK-DEL-15', 'TEST_WELL', 'TN-1-A', 'TN-1-B', 'TN-1-C', 'TN-2-C', 'TON NOK YOONG-1X', 'workshop',
				'WP-04', 'WP-05', 'WP-09', 'WP-13', 'WP-15', 'WP-16', 'WP-18', 'WP-19', 'WP-21', 'WP-37', 'WP-38',
				'ZTK-01-A', 'ZTK-01-B', 'ZTK-03-D', 'ZTK-03-S') AND
		ops.WELL NOT LIKE '*%' AND
		ops.PROGRAM_NO NOT IN (SELECT DISTINCT vw.USERTXT1 
									FROM [Wisdom-DB-02].WELLVIEW_METRIC.v_wvjobreport AS rep
									LEFT JOIN [Wisdom-DB-02].WELLVIEW_METRIC.v_wvjob AS vw  
								    ON rep.IDRECPARENT = vw.IDREC
								    WHERE vw.USERTXT1 <> '' AND vw.USERTXT1 IS NOT NULL)
--- Wise End --
UNION ALL 
--- Soure PWED start ---
SELECT 
	vdrd.NEW_GUID AS id,		
	COALESCE(vdm.NEW_GUID, '00000000-0000-0000-0000-000000000000') AS daily_report_id,
	'00000000-0000-0000-0000-000000000000' AS opt_code_id,
	'00000000-0000-0000-0000-000000000000' AS form_id,
	tmu.id AS unit_id,
	'ONLINE' AS type,
	--vdm.BARGE_NAME AS unit,
	COALESCE(vdrd.START_TIME, vdm.OPDATE) AS start_date_time,
	DATEADD(MINUTE, vdrd.DURATION ,COALESCE(vdrd.START_TIME, vdm.OPDATE))  AS end_date_time,
	FORMAT(DATEADD(MINUTE, vdrd.DURATION, '00:00:00'), 'HH:mm') AS duration_time,
	COALESCE(vdrd.DETAIL_TEXT, '-') AS activity_detail,
	'' AS activity_detail_structure,    -- Temporary add to fit schema on 7 June
	COALESCE(mu.id, (SELECT id FROM [Wisdom-DB-02].PRE_WISDOM.mst_user WHERE [name] = 'Data Migration')) AS creator_id,
	vdrd.USER_DESC AS creator,
	vdrd.DATE_UPDATED AS created_date, 
	COALESCE(mu.id, (SELECT id FROM [Wisdom-DB-02].PRE_WISDOM.mst_user WHERE [name] = 'Data Migration')) AS modifer_id,
	vdrd.USER_DESC AS modifier,
	vdrd.DATE_UPDATED AS modified_date,
	1 AS version,
	CAST(NULL AS VARCHAR) AS remark,
	CAST(NULL AS UNIQUEIDENTIFIER) AS delegated_by_id,
	CAST(NULL AS UNIQUEIDENTIFIER) AS tab_id,
	CAST(NULL AS VARCHAR) AS form_detail,
	CAST(NULL AS VARCHAR) AS form_value,
	CAST(NULL AS VARCHAR) AS activity_code,
	CAST(NULL AS VARCHAR) AS attachment_id   -- Temporary add to fit schema on 7 June
FROM (SELECT vd.NEW_GUID, 
		vd.DATE_UPDATED, 
		vd.DETAIL_TEXT, 	
		COALESCE(
		CASE 
			when DURATION < 0 then NULL
			when duration = 0 then null
			else DURATION 
		END, 1) AS DURATION , 
		vd.PROGRAM_SEQ, 
		vd.REPORT_ID, 
		vd.START_TIME, 
		vd.USER_UPDATED, 
		COALESCE(vsu.USER_DESC, 'Data Migration') AS USER_DESC 
		FROM [Wisdom-DB-02].PWED.V_DAILY_REPORT_DETAILS AS vd -- task, time
		LEFT JOIN [Wisdom-DB-02].PWED.V_SYS_USERS AS vsu
		ON vd.USER_UPDATED = vsu.USER_NAME 
) AS vdrd
LEFT JOIN  [Wisdom-db-02].WISE_VIEW.V_V_DAILYREPORT_WILD_MIGRATION AS vdm  -- main data
ON  vdm.REPORTID = vdrd.REPORT_ID
LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.mst_user AS mu 
ON vdrd.USER_DESC = mu.[name] 
LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.temp_mst_unit AS tmu
ON COALESCE(vdm.BARGE_NAME, 'Unit-PWED') = tmu.[name]
WHERE vdm.PROGRAM_NO LIKE 'P_%' AND 
	vdm.WELL NOT IN ('PP Workshop', 'AQP', 'BQP', 'TEST_WELL') AND 
	vdm.WELL NOT LIKE '*%'
-- PWED Source end ------------------------------------
UNION ALL 
-- WILD Source start ----------------------------------
SELECT 
	wild_tlog.NEW_GUID AS id,		
	COALESCE(wild_tlog.report_id, '00000000-0000-0000-0000-000000000000') AS daily_report_id,
	'00000000-0000-0000-0000-000000000000' AS opt_code_id,
	'00000000-0000-0000-0000-000000000000' AS form_id,
	wild_tlog.unit_id AS unit_id,
	'ONLINE' AS type,
	--vdm.OPETYPE AS unit,
	wild_tlog.start_date_time,
	DATEADD(SECOND, wild_tlog.DURATION * 86400, wild_tlog.start_date_time) AS end_date_time,
	FORMAT(DATEADD(SECOND, wild_tlog.DURATION * 86400,'1900-01-01 00:00:00'),'HH:mm') AS duration_time,
	COALESCE(wild_tlog.DETAILTEXT, '-') AS activity_detail,
	'' AS activity_detail_structure,    -- Temporary add to fit schema on 7 June
	wild_tlog.creator_id,
	wild_tlog.creator,
	wild_tlog.created_date, 
	wild_tlog.modifer_id,
	wild_tlog.modifier,
	wild_tlog.modified_date,
	1 AS version,
	CAST(NULL AS VARCHAR) AS remark,
	CAST(NULL AS UNIQUEIDENTIFIER) AS delegated_by_id,
	CAST(NULL AS UNIQUEIDENTIFIER) AS tab_id,
	CAST(NULL AS VARCHAR) AS form_detail,
	CAST(NULL AS VARCHAR) AS form_value,
	CAST(NULL AS VARCHAR) AS activity_code,
	CAST(NULL AS VARCHAR) AS attachment_id   -- Temporary add to fit schema on 7 June
FROM (
SELECT 
	vwdd.NEW_GUID, 
	vdm.NEW_GUID AS report_id,
	tmu.id AS unit_id, 
	vwdd.DETAILTEXT,
	CASE
		WHEN vws.ST_NO = 1 THEN CONCAT(LEFT(vdm.WELL, CHARINDEX(',', vdm.WELL + ',') - 1), '-ST')
	    WHEN vws.ST_NO > 1 THEN CONCAT(LEFT(vdm.WELL, CHARINDEX(',', vdm.WELL + ',') - 1), '-ST', vws.ST_NO)
    ELSE LEFT(vdm.WELL, CHARINDEX(',', vdm.WELL + ',') - 1) END AS WELL,
	COALESCE(CAST(CONVERT(VARCHAR, OPDATE, 23) + ' ' + CONVERT(VARCHAR, OPETIME, 108) AS DATETIMEOFFSET), vdm.OPDATE) AS start_date_time,
		COALESCE(CASE 
		when DURATION < 0 then NULL
		when duration = 0 then null
		else DURATION 
	END, 0.0006944444 ) AS DURATION ,
	COALESCE(mst_user.id, (SELECT id FROM [Wisdom-DB-02].PRE_WISDOM.mst_user WHERE [name] = 'Data Migration')) AS creator_id,
	COALESCE(NULLIF(CONCAT(vwp.FNAME, ' ', vwp.LNAME), ''), 'Data Migration') AS creator,
	vwd.REPORTDATE AS created_date, 
	COALESCE(mst_user.id, (SELECT id FROM [Wisdom-DB-02].PRE_WISDOM.mst_user WHERE [name] = 'Data Migration')) AS modifer_id,
	COALESCE(NULLIF(CONCAT(vwp.FNAME, ' ', vwp.LNAME), ' '), 'Data Migration') AS modifier,
	vwd.REPORTDATE AS modified_date
FROM [Wisdom-db-02].WISE.V_WILD_DAILYREPORT_DETAIL AS vwdd 
LEFT JOIN  [Wisdom-db-02].WISE_VIEW.V_V_DAILYREPORT_WILD_MIGRATION AS vdm
ON vwdd.REPORTID = vdm.REPORTID
LEFT JOIN [Wisdom-db-02].WISE.V_WILD_SITE AS vws 
ON vws.SITENAME = vdm.WELL
LEFT JOIN [Wisdom-db-02].WISE.V_WILD_DAILYREPORT AS vwd 
ON vdm.REPORTID = vwd.REPORTID 
LEFT JOIN [Wisdom-DB-02].WISE.V_WILD_PERSONNEL AS vwp 
ON vwp.PERSONNELID  = vwd.SUPERVISORID 
LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.mst_user AS mst_user
ON LOWER(mst_user.[name]) = COALESCE(LOWER(CONCAT(vwp.FNAME, ' ', vwp.LNAME)), 'Data Migration')
LEFT JOIN [Wisdom-DB-02].PRE_WISDOM.temp_mst_unit AS tmu
ON COALESCE(vdm.OPETYPE, 'Unit-WILD') = tmu.[name]
WHERE vdm.PROGRAM_NO = '[WILD]' AND 
	vdm.WELL NOT IN ('PP Workshop', 'AQP', 'BQP') AND
	vdm.WELL NOT LIKE '*%'
	) AS wild_tlog
WHERE wild_tlog.WELL NOT IN ('AWP01', 'AWP01N', 'AWP02', 'AWP02N', 'AWP03', 'AWP04', 'AWP05', 'AWP06', 'AWP07', 'AWP08', 'AWP09', 'AWP10', 'AWP11(del)', 'AWP12', 'AWP13', 'AWP14', 'AWP15', 'AWP16', 'AWP17',
'BK-1-L(OLD)', 'BK-1-M(OLD)', 'BKRIG T-3', 'Demob', 'HLB Base', 'Mob', 'Move', 'Move1', 'Move2',
'SGK', 'SKL Base', 'SKL Workshop', 'SLB Base', 'T1', 'TEST-1-A', 'TEST-2', 'TEST-3', 'TN-1-A',
'WP01', 'WP02', 'WP03', 'WP04', 'WP05', 'WP06', 'WP07', 'WP08', 'WP09', 'WP10', 'WP11', 'WP12', 'WP13', 'WP14', 'WP15', 'WP16', 'WP17', 'WP18', 'WP19', 'WP20', 'WP21', 'WP22', 'WP23', 'WP24', 'WP-25',
'WPS-1', 'WPS-2', 'WPS-3', 'WPS-4', 'WPS-5', 'WPS-6',
'ZTK-01-A', 'ZTK-01-B', 'ZTK-01-F', 'ZTK-01-H', 'ZTK-01-J', 'ZTK-01-L', 'ZTK-01-M', 'ZTK-01-P',
'ZTK-02-A', 'ZTK-02-B', 'ZTK-02-C', 'ZTK-02-H', 'ZTK-02-J', 'ZTK-02-M', 'ZTK-02-N', 'ZTK-02-P', 'ZTK-02-R', 'ZTK-02-S', 'ZTK-02-T', 'ZTK-02-U', 'ZTK-02-V',
'ZTK-03-B', 'ZTK-03-C', 'ZTK-03-D', 'ZTK-03-E', 'ZTK-03-F', 'ZTK-03-J', 'ZTK-03-K', 'ZTK-03-L', 'ZTK-03-S', 'ZTK-03-T', 'ZTK-03-U', 'ZTK-03-V')
