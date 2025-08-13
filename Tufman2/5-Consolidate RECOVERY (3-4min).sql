-- RECOVERY --

IF OBJECT_ID('T2.tag_recovery', 'u') IS NOT NULL DROP TABLE T2.tag_recovery;

SELECT
		'pttp' AS source,
		R1.recovery_id,
		null AS old_recovery_id,
		T.release_id as tag_rel_id,
		i.tag_no,
		tt.tag_type_code as tag_type,
		tt.tag_category as type_id,
		left(R1.sp_code,1) as sp_id,
		R1.sp_reliability_id as sp_qual_id,
		R1.sex_code as sex_id,
		IIF(RV.catch_from_date is null, IIF(RV.catch_to_date is null, R1.found_date, RV.catch_to_date),RV.catch_from_date) as catchdate,
		R1.found_date as date_found,
		R1.catch_date_reliability_id as dt_rel_id,
		R1.best_catch_date as best_catchdate,
		R1.validity as validity_id,
		IIF(RV.catch_from_lat is not null, RV.catch_from_lat, R1.best_catch_lat) as lat,
		IIF(RV.catch_from_lon is not null, RV.catch_from_lon, R1.best_catch_lon) as lon,
		IIF(RV.catch_from_eez is not null, RV.catch_from_eez, R1.best_catch_eez) as eez,
 		R1.best_catch_lat as best_lat,
 		R1.best_catch_lon as best_lon,
 		R1.area_reliability_id as a_rel_id,
 		R1.length_cm as len,
 		R1.length_accuracy_id as len_acc_id,
 		R1.length_reliability_id as len_qual_id,
 		R1.measured_by_id,
 		R1.weight_kg as wt,
 		R1.weight_accuracy_id as wt_acc_id,
 		R1.weight_code as wt_state_id,
 		R1.fish_condition_id as fish_state_id,
 		VI.vesselname,
 		VI.flag_id,
 		VI.vesselname_normalised,
 		VI.flag_rg_id as flag_reg_id,
 		V.gear as fishmeth_id,
 		RV.school_association_id as assoc_id,
 		R1.comments as notes,
 		R1.validated_by,
 		R1.validation_date as validated_date,
		R1.validation_status_id
		into T2.tag_recovery
FROM T2.vw_tag_recovery AS R1
	INNER JOIN T2.vw_tags t on t.recovery_id = R1.recovery_id
	INNER JOIN T2.vw_tag_inventory i on i.tag_inventory_id = t.tag_inventory_id
	inner join T2.vw_tag_bundles b on b.tag_bundle_id = i.tag_bundle_id
	left join T2.vw_tag_types tt on tt.tag_type_id = b.tag_type_id
	left join T2.vw_recovery_vessels rv on rv.recovery_id = R1.recovery_id
	left join T2.vw_ref_vessel_instances VI on rv.vessel_id = vi.vessel_id and COALESCE(RV.catch_from_date,RV.catch_to_date) between vi.start_date and vi.calculated_end_date
	left join T2.vw_ref_vessels V on V.vessel_id = VI.vessel_id

UNION

SELECT
		'rttp' AS source,
		newid() AS recovery_id,
		R2.recovery_id AS old_recovery_id,
		T2.Get_Release(R2.tag_rel_id) AS tag_rel_id,
		R2.tag_no,
		null as tag_type,
		null as type_id,
		R2.sp_id,
		R2.sp_cred_id AS sp_quad_id,
		null AS sex_id,
		R2.catchdate,
		null AS date_found,
		R2.dt_rel_id,
		null AS best_catchdate,
		null AS validity_id,
		R2.lat,
		R2.lon,
		R2.EEZ_SQLSERVER AS EEZ,
 		null AS best_lat,
 		null AS best_lon,
 		R2.a_rel_id,
 		R2.len,
 		null AS len_acc_id,
 		R2.len_rel_id as len_qual_id,
 		null AS measured_by_id,
 		R2.wt,
 		null AS wt_acc_id,
 		null AS wt_state_id,
 		null as fish_state_id,
 		R2.vesselname,
 		case when R2.flag_id = 'HW' or R2.flag_id = 'AS' then 'US' else R2.flag_id end as flag_id,
 		LOG_MASTER.ref.VesselNameNormalize(R2.vesselname,0) as vesselname_normalised,
 		case when R2.flag_id = 'HW' or R2.flag_id = 'AS' then R2.flag_id else null end AS flag_reg_id,
 		R2.fishmeth AS fishmeth_id,
 		IIF(ASCII(R2.assoc_id) between 49 and 57, R2.assoc_id, null) as assoc_id,
 		CONVERT(nvarchar(max),R2.comment) as notes,
 		null as validated_by,
 		null as validated_date,
		3 as validation_status_id
FROM rttp.recovery as R2

--SELECT * FROM tag.tag_recovery order by recovery_id

-- select assoc_id, ascii(assoc_id), count(*) from rttp.recovery group by assoc_id
