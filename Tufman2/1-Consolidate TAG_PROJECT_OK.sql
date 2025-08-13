
-- PROJECT --

IF OBJECT_ID('T2.tag_project', 'u') IS NOT NULL DROP TABLE T2.tag_project;

SELECT 'pttp' as source, project_id as proj_id, code as proj_code, name as proj_desc, short_name as proj_short_desc, project_type_id as proj_type_id, long_code as proj_long, comments as notes into T2.tag_project FROM T2.vw_tag_project 
UNION
SELECT 'rttp' as source, newid() as proj_id, proj_id as proj_code, proj_desc, proj_desc as proj_short_desc, 0 as proj_type_id, proj_long,'' as notes FROM rttp.tag_project
ORDER BY 1, 2

--SELECT * FROM tag.tag_project order by proj_id
