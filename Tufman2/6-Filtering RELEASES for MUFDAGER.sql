-- FILTER RELEASE DATA

--IF OBJECT_ID('tempdb..#releases') IS NOT NULL DROP TABLE #releases
IF OBJECT_ID('muf2.releases') IS NOT NULL DROP TABLE muf2.releases

SELECT 
		C.source,
		P.proj_code, 
		E.event_date AS sch_date, 
		E.event_lat AS lat, 
		E.event_lon AS lon, 
		Rel.sp_id, 
		Rel.Len 
		INTO muf2.releases
FROM T2.tag_cruise C
		INNER JOIN T2.tag_project P on C.proj_id = P.proj_id
		INNER JOIN T2.tag_event E ON C.tag_cru_id = E.tag_cru_id 
		INNER JOIN T2.Tag_Release Rel ON E.tag_event_id = Rel.tag_event_id
 WHERE 
 		(
		C.source = 'pttp'
   	and Rel.sp_id in ('A','S','B','Y')
   	and Rel.Len > 0  
 		and C.proj_id <> '676198E3-F6B2-4042-84E1-5320F7C22DB1' 
  	and E.event_lat is not null 
  	and E.event_lon is not null 
 		and (Rel.t_qual_id = 1 Or Rel.t_qual_id=2 Or Rel.t_qual_id=3) 
 		and Rel.Dbl_tag_no Is Null 
 		and Rel.Tag_type_id = 'CON'
 		and Rel.Arc_tag_no Is Null 
 		and Rel.Sonic_tag_no Is Null
		)

	 OR
		(
		C.source = 'rttp'  
 		and Rel.sp_id in ('A','S','B','Y') 
 		and Rel.Len > 0 
 		and E.event_lat is not null 
 		and E.event_lon is not null 
 		and Rel.t_qual_id between 1 and 3 
 		and Rel.Db_tag < 2 
 		and Rel.Arc_tag_no Is Null
 		)

-- 		
Select * from muf2.releases --where source='pttp'



