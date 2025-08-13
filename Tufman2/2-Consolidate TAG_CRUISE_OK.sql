-- CRUISE --

IF OBJECT_ID('T2.tag_cruise', 'u') IS NOT NULL DROP TABLE T2.tag_cruise;

SELECT 'pttp' as source,
			null as old_cru_id,			cruise_id as tag_cru_id,
			project_id as proj_id,
			cruise_no,
			VI.vesselname,
			VI.flag_id,
			V.gear as gr_id,
			VI.vesselname_normalised,
			comments as notes
into T2.tag_cruise 
FROM T2.vw_tag_cruise C
	left join T2.vw_ref_vessels V on c. vessel_id = V.vessel_id
	left join T2.vw_ref_vessel_instances VI on VI.vessel_id = C.vessel_id and C.departure_date between vi.start_date and vi.calculated_end_date

UNION

SELECT 'rttp' as source,
			c.tag_cru_id as old_tag_cru_id,
			newid() as tag_cru_id,
			T2.GET_PROJ(c.proj_id) as proj_id,
			1 as cruise_no,
			c.vesselname,
			LOG_MASTER.ref.VesselNameNormalize(TRIM(c.vesselname),0) as vesselname_normalised,
			c.flag_id,
			c.gr_id,
			c.notes
FROM rttp.tag_cruise AS c

--SELECT * FROM T2.tag_cruise order by tag_cru_id
