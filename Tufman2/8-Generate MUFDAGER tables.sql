-- Generation of MUFDAGER2 files

DECLARE @pID AS int

--------------------------------------------
-------------- RELEASES --------------------
--------------------------------------------

IF OBJECT_ID('tempdb..#PTTP_REL_BEST') IS NOT NULL DROP TABLE #PTTP_REL_BEST
IF OBJECT_ID('tempdb..#PTTP_REL_BEST_TMP') IS NOT NULL DROP TABLE #PTTP_REL_BEST_TMP

SELECT  
		proj_code, 
		YEAR(SCH_DATE) AS YY, 
		MONTH(SCH_DATE) AS MM,
		ref.lat_agg(TRIM(LAT),'5') AS LAT_REL,
		ref.lon_agg(TRIM(LON),'5') AS LON_REL,
		CASE sp_id 
				when 'A' then 'ALB'
				when 'B' then 'BET'
				when 'Y' then 'YFT'
				when 'S' then 'SKJ'
		END as sp_code,
		FLOOR(LEN) AS LEN, 
		COUNT(*) AS FREQ_REL
INTO #PTTP_REL_BEST
FROM muf2.releases 
GROUP BY proj_code, YEAR(SCH_DATE), MONTH(SCH_DATE), ref.lat_agg(TRIM(LAT),'5'), ref.lon_agg(TRIM(LON),'5'), SP_ID, FLOOR(LEN)
order by 1,2,3,4,5

ALTER TABLE #PTTP_REL_BEST 
ADD Rel_ID INT,
		Region_1 VARCHAR(3),
		Region_2 VARCHAR(3),		
		Region_3 VARCHAR(3),		
		Region_4 VARCHAR(3),
		Region_5 VARCHAR(3),
		Region_6 VARCHAR(3)

SELECT
		Rel_ID,
		proj_code, 
		YY, 
		MM, 
		LAT_REL,
		LON_REL,
		SP_CODE,
		LEN 
INTO #PTTP_REL_BEST_TMP
FROM #PTTP_REL_BESTORDER BY 2,3,4

	
--select * from #PTTP_REL_BEST_TMP

--DECLARE @pID AS int
set @pID= 0

UPDATE tmp 
SET Rel_ID  = @pID , @pID = @pID + 1	
FROM #PTTP_REL_BEST_TMP tmp

UPDATE RB
set Rel_ID = tmp.Rel_ID
FROM #PTTP_REL_BEST RB
	inner join #PTTP_REL_BEST_TMP tmp 
			on RB.proj_code = tmp.proj_code AND
				RB.yy = tmp.yy and
				RB.mm = tmp.mm and
				RB.lat_rel = tmp.lat_rel and
				rb.lon_rel = tmp.lon_rel and
				rb.sp_code = tmp.sp_code and
				rb.len = tmp.len
			
--select * from #PTTP_REL_BEST order by proj_code, yy, mm

--------------------------------------------
-------------- RECOVERIES --------------------
--------------------------------------------

IF OBJECT_ID('tempdb..#PTTP_REC_BEST') IS NOT NULL DROP TABLE #PTTP_REC_BEST
IF OBJECT_ID('tempdb..#PTTP_REC_BEST_TMP') IS NOT NULL DROP TABLE #PTTP_REC_BEST_TMP

SELECT 	null AS REL_ID,
				null as rec_id,
				proj_code,
				YEAR(SCH_DATE) AS YY, 
				MONTH(SCH_DATE) AS MM,
				ref.lat_agg(TRIM(RELLAT),'5') AS LAT_REL,
				ref.lon_agg(TRIM(RELLON),'5') AS LON_REL,
				CASE sp_id 
						when 'A' then 'ALB'
						when 'B' then 'BET'
						when 'Y' then 'YFT'
						when 'S' then 'SKJ'
				END as sp_code,
				null AS REGION_1, 
				null AS REGION_2, 
				null AS REGION_3, 
				null AS REGION_4,
				null AS REGION_5, 
				null AS REGION_6, 
				YEAR(CATCHDATE) AS YY_REC, 
				MONTH(CATCHDATE) AS MM_REC, 
 				ref.lat_agg(TRIM(RECLAT),'5') AS LAT_REC,
 				ref.lon_agg(TRIM(RECLON),'5') AS LON_REC,
 				GR_ID,
				FLAG_ID,
				case when FLAG_REG_ID = 'HW' or FLAG_REG_ID= 'AS' then FLAG_REG_ID else ref.GETFLEET(flag_id, gr_id, sp_id, eez) end as fleet_id, 
				IIF(GR_ID='S',ref.GETASSOC(ASSOC_ID),null) AS SCH_ID, 
				FLOOR(LENREL) AS LEN_REL, 
				FLOOR(LENREC) AS LEN_REC, 
				COUNT(DISTINCT TAG_NO) AS FREQ_REC, 
				null AS FISH_1, 
				null AS FISH_2, 
				null AS FISH_3, 
				null AS FISH_4, 
				null AS FISH_5, 
				null AS FISH_6
INTO #PTTP_REC_BEST
FROM muf2.recoveries
GROUP BY
				proj_code,
				YEAR(SCH_DATE), 
				MONTH(SCH_DATE),
				ref.lat_agg(TRIM(RELLAT),'5'),
				ref.lon_agg(TRIM(RELLON),'5'),
				sp_id, 
				YEAR(CATCHDATE), 
				MONTH(CATCHDATE), 
 				ref.lat_agg(TRIM(RECLAT),'5'),
 				ref.lon_agg(TRIM(RECLON),'5'),
 				GR_ID,
				FLAG_ID,
				case when FLAG_REG_ID = 'HW' or FLAG_REG_ID= 'AS' then FLAG_REG_ID else ref.GETFLEET(flag_id, gr_id, sp_id, eez) end, 
				IIF(GR_ID='S',ref.GETASSOC(ASSOC_ID),null), 
				FLOOR(LENREL), 
				FLOOR(LENREC) 

--Select * from #PTTP_REC_BEST

--DECLARE @pID AS int
set @pID= 0

UPDATE RB 
SET Rec_ID  = @pID , @pID = @pID + 1	
FROM #PTTP_REC_BEST RB

UPDATE RECB
set Rel_ID = RELB.Rel_ID
FROM #PTTP_REC_BEST RECB
	inner join #PTTP_REL_BEST RELB 
		 on RECB.proj_code = RELB.proj_code AND
				RECB.yy = RELB.yy and
				RECB.mm = RELB.mm and
				RECB.lat_rel = RELB.lat_rel and
				RECB.lon_rel = RELB.lon_rel and
				RECB.sp_code = RELB.sp_code and
				RECB.len_rel = RELB.len


-------------------- CREATING THE FINAL TABLES ------------------------------
IF OBJECT_ID('muf2.REL_BEST') IS NOT NULL DROP TABLE muf2.REL_BEST
IF OBJECT_ID('muf2.REC_BEST') IS NOT NULL DROP TABLE muf2.REC_BEST

Select * into muf2.rel_best from #PTTP_REL_BEST
Select * into muf2.rec_best from #PTTP_REC_BEST