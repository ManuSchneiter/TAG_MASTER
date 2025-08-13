-- FILTER RECOVERIES DATA
USE TAG_MASTER

--IF OBJECT_ID('tempdb..#recoveries') IS NOT NULL DROP TABLE #recoveries
IF OBJECT_ID('muf2.recoveries') IS NOT NULL DROP TABLE muf2.recoveries

SELECT		C.source,
		P.Proj_code, 
		E.event_date AS sch_date, 
		E.event_lat AS Rellat, 
		E.event_lon AS Rellon, 
		REL.sp_id, 
		IIf(REC.best_catchdate is not null,REC.best_catchdate, IIf(REC.catchdate is not null,REC.catchdate,REC.date_found)) AS catchdate, 
		REC.dt_rel_id AS RecDate_reliability, 
		IIf(REC.best_lat is not null,REC.best_lat,REC.lat) AS reclat, 
		IIf(REC.best_lon is not null,REC.best_lon,REC.lon) AS reclon, 
		REC.a_rel_id AS recArea_reliability, 
		REC.EEZ, 
		CONVERT(bit, IIf(validation_status_id <> 3,0,1)) AS Validated, 
		CONVERT(bit,IIf(validity_id<>5,1,0)) AS Verified, 
		REC.fishmeth_id AS gr_id, 
		REC.flag_id, 
		REC.flag_reg_id,
		REC.assoc_id, 
		REL.Len AS lenRel, 
		REC.Len AS lenRec, 
		REC.tag_no 
		INTO muf2.recoveries
FROM 
		T2.tag_cruise C
		INNER JOIN T2.tag_project P on C.proj_id = P.proj_id
		INNER JOIN T2.tag_event E ON C.tag_cru_id = E.tag_cru_id 
		INNER JOIN T2.tag_release REL ON E.tag_event_id = REL.tag_event_id 
		INNER JOIN T2.tag_recovery REC ON REL.tag_rel_id = REC.tag_rel_id
WHERE 
		(
		C.source = 'pttp' 
		AND Rec.sp_id in ('A','S','B','Y') 
		AND REL.Len > 0 
		AND (REC.lat is not null OR REC.best_lat is not null) 
		AND (REC.lon is not null OR REC.best_lon is not null) 
		AND P.proj_code<>'SED' 
		AND (REL.t_qual_id = 1 Or REL.t_qual_id=2 Or REL.t_qual_id=3) 
		AND REL.dbl_tag_no Is Null 
		AND REC.Type_ID = 'CON'  
		AND REL.Sonic_tag_no Is Null
		)
	OR
		(
		C.source = 'rttp' 
 		AND Rel.Len <> 0 
 		AND Rec.sp_id in ('A','S','B','Y') 
 		AND Rel.Db_tag < 2 
 		AND Rel.t_qual_id Between 1 And 3 
 		AND Rel.arc_tag_type Is Null 
 		AND E.event_lat is not null 
 		AND E.event_lon is not null 
 		AND (REC.lat is not null OR REC.best_lat is not null) 
 		AND (REC.lon is not null OR REC.best_lon is not null) 
 		)

Select * from muf2.recoveries -- where source = 'pttp'