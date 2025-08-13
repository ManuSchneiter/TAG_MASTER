-- RELEASE --

IF OBJECT_ID('T2.tag_release', 'u') IS NOT NULL DROP TABLE T2.tag_release;
IF OBJECT_ID('tempdb..#pttp') IS NOT NULL DROP TABLE #pttp
IF OBJECT_ID('tempdb..#rttp') IS NOT NULL DROP TABLE #rttp

SELECT
		'pttp' AS source,
		null AS old_tag_rel_id,
		r.release_id as tag_rel_id,
		r.event_id as tag_event_id,
		i.tag_no,
		tt.tag_type_code as tag_type,
		tt.tag_category as tag_type_id,
		null as arc_tag_no,
		null as arc_tag_type,
		null as sonic_tag_no,
		null as sonic_tag_type,
		null as dbl_tag_no,
		null as dbl_tag_type,
		null as dbl_t_qual_id,
 		JSON_VALUE(r.extra_info_json, '$.ReleaseDetails.ReleaseTime') AS time_released,
		null as time_removed,
		r.fishing_method_code as gr_id,
		r.tagger_id,
		fs.staff_code as tagger,
		left(r.sp_code,1) as sp_id,
		r.sp_reliability_id as sp_qual_id,
  		JSON_VALUE(t.extra_info_json, '$.TagDetails.TagReleaseQualityId') AS t_qual_id,
		r.fish_condition_id as t_cond_id,
		r.length_cm as len,
		r.length_reliability_id as len_qual_id,
 		case when JSON_VALUE(t.extra_info_json, '$.TagDetails.IsDoubleTag')='false' then 2 else null end AS db_tag,
		null as tag_prev,
		null as seed_area_code_desc,
		null as well_no,
		null as OTC,
		JSON_VALUE(r.extra_info_json, '$.ReleaseDetails.OtcConditionId') AS OTC_Qual_ID,
		JSON_VALUE(r.extra_info_json, '$.ReleaseDetails.HookTypeId') AS hook_type_id,
		null as tag_partner_id,
		null as agency_id,
		r.comments as notes,
		r.entered_Date,
		null as SSMA_timestamp
		INTO T2.tag_release
FROM T2.vw_tag_release AS r
	INNER JOIN T2.vw_tags t on t.release_id = r.release_id
	INNER JOIN T2.vw_tag_inventory i on i.tag_inventory_id = t.tag_inventory_id
	inner join T2.vw_tag_bundles b on b.tag_bundle_id = i.tag_bundle_id
	left join T2.vw_tag_types tt on tt.tag_type_id = b.tag_type_id
	left join T2.vw_field_staff fs on fs.staff_id = r.tagger_id

union

SELECT
		'rttp' as source,
		r.tag_rel_id AS old_tag_rel_id,
		newid() AS tag_rel_id,
		T2.Get_Event(r.tag_sch_id) as tag_event_id,
		r.tag_no,
		t.tag_type,
		null as tag_type_id,
		r.arc_tag_no,
		r.arc_tag_type,
		null AS sonic_tag_no,
		null AS sonic_tag_type,
		r.dbl_tag_no,
		t.tag_type as dbl_tag_type,
		null AS dbl_t_qual_id,
		null AS time_released,
		null AS time_removed,
		r.gr_id,
		null as tag_tagger_id,
		cast(r.tagger as nvarchar(3)) AS tag_tagger,
		r.sp_id,
		null as sp_qual_id,
		r.t_qual_id,
		r.t_cond_id,
		r.len,
		r.len_rel_id AS len_qual_id,
		r.db_tag,
		null as tag_prev,
		null as seed_area_code_desc,
		null as well_no,
		null as OTC,
		null as OTC_Qual_ID,
		null as hook_type_id,
		null as tag_partner_id,
		r.agency_id,
		null as notes,
		null as entered_Date,
		null as SSMA_timestamp
FROM rttp.release AS r 
	left join tag.tag_event e on r.tag_sch_id = e.old_sch_id
	left join rttp.tag_tagger t on t.tag_sch_id = r.tag_sch_id and t.tagger = r.tagger


-- indexing the old_tag_rel_id field for use in RECOVERIES consolidation (Get_Release function)
CREATE INDEX idx_old_tag_rel_id on T2.tag_release (old_tag_rel_id)

--SELECT * FROM tag.tag_release order by tag_rel_id

