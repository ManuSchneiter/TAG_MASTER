-- SCHOOL --

IF OBJECT_ID('T2.tag_event', 'u') IS NOT NULL DROP TABLE T2.tag_event;

SELECT
		'pttp' as source,
		null as old_sch_id,
		e.event_id as tag_event_id,
		ce.cruise_id as tag_cru_id,
		e.event_no,
		e.start_date as event_date,
		e.start_time,
		e.end_time,
		e.lat as event_lat,
		e.lon as event_lon,
		e.sst_c as event_SST,
		JSON_VALUE(extra_info_json, '$.EventDetails.School.SchoolTypeId') AS schtype,
		CASE school_association_id WHEN 4 then 5 WHEN 5 then 4 ELSE school_association_id END AS assoc_id,
		e.eez as event_EEZ,
		e.comments as notes
		into T2.tag_event 
FROM T2.vw_tag_event AS e 
	inner join T2.vw_cruise_events ce on ce.event_id = e.event_id 

UNION

SELECT
		'rttp' as source,
		s.tag_sch_id AS old_sch_id,
		newid() as tag_event_id,
		T2.GET_CRUISE(s.tag_cru_id) as tag_cru_id,
		s.sch_no AS event_no,
		s.schdate AS event_date,
		s.schstart AS start_time,
		s.schstop AS end_time,
		s.lat AS event_lat,
		s.lon AS event_lon,
		s.sst AS event_sst,
		s.schtype,
		case s.assoc_id when 'A' then '8' when 'Z' then '8' else s.assoc_id end as assoc_id,
		s.EEZ_SQLSERVER AS event_eez,
		s.notes
FROM rttp.tag_school AS s
order by assoc_id desc

--SELECT * FROM T2.tag_event order by tag_event_id
