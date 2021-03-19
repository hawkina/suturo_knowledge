:- register_ros_package(rosprolog).
:- register_ros_package(knowrob).
:- register_ros_package(knowledge).
%%% KnowRob imports
:- use_module(library('semweb/rdf_db')).
:- use_module(library('semweb/rdfs')).
:- use_module(library('db/tripledb'), [tripledb_load/1, tripledb_load/2, tripledb_tell/5, tripledb_forget/3]).
:- use_module(library('utility/url'),[ros_package_iri/2]).
%:- use_module(library('reasoning/OWL/plowl/individual'),[owl_individual_of/3]).
%:- use_module(library('reasoning/OWL/plowl/property'),[owl_has/4]).
:- use_module(library('lang/terms/triple')).
:- use_module(library('model/metrics/WuPalmer')).
:- use_module(library('lang/terms/is_at'), [is_at/2]).
:- use_module(library('utility/algebra'), [transform_close_to/3]).
%:- use_module('ros/marker/maker_plugin.pl', [marker_message_new/3]).
%:- ros_package_path('knowrob',X),atom_concat(X,'/src/ros/marker/marker_plugin.pl',P),use_module(P).
%:- ros_package_path('knowrob',X),atom_concat(X,'/src/ros/marker/marker_plugin.pl',P),use_module(P).
%(library('ros/marker/marker_plugin')), [marker_message_new/3].
%%% knowledge imports
:- use_module(library('config')).
:- use_module(library('urdf')).
:- use_module(library('spatial_comp')).
:- use_module(library('pickup')).
:- use_module(library('object_state')).
:- use_module(library('surfaces'), [all_surfaces/1, supporting_surface/1, assert_surface_types/1, pose_of_shelves/1, table_surfaces/1, assert_surface_types/1, supporting_surface/1, assert_object_on/2, surface_type_of/2, is_legal_obj_position/1, all_surfaces/1, is_surface/1, is_table/1, is_bucket/1, is_shelf/1, all_source_surfaces/1, all_target_surfaces/1, ground_surface/1, shelf_surfaces/1, big_shelf_surfaces/1, shelf_floor_at_height/2, table_surfaces/1, bucket_surfaces/1, is_legal_obj_position/1, find_supporting_surface/2, pose_of_tables/1, pose_of_shelves/1, pose_of_buckets/1, pose_of_target_surfaces/1, pose_of_source_surfaces/1, pose_of_surfaces/2, compareDistances/3, objects_on_surface/2, make_all_surface_type_role/2,objects_on_list_of_surfaces/2, all_objects_on_source_surfaces/1, all_objects_on_target_surfaces/1, all_objects_on_ground/1, all_objects_in_whole_shelf_/1, all_objects_on_tables_/1, all_objects_in_buckets/1, all_objects_on_table/1]).
:- use_module(library('beliefstate')).
:- use_module(library('assignplaces')).
:- use_module(library('gripper'), [gripper/1, gripper_init/1]).
:- use_module(library('export')).

:- ros_package_iri(knowledge, 'package://knowledge/owl/objects.owl').

writeln('here').
writeln(pwd).


:- tripledb_load(
	'http://www.ontologydesignpatterns.org/ont/dul/DUL.owl',
	[ namespace(dul)
	]).
:- tripledb_load(
	'http://knowrob.org/kb/knowrob.owl',
	[ namespace(knowrob)
	]).
:- tripledb_load('package://knowledge/owl/objects.owl',
	[ namespace(hsr_objects)
	]).
:- tripledb_load(
	'http://knowrob.org/kb/URDF.owl',
	[ namespace(urdf, 'http://knowrob.org/kb/urdf.owl#')
	]).

:- ros_param_get_string('/param_to_load_URDF_from', Param),
    load_surfaces_from_param(Param).

:- tf_lookup_transform(map, map, _).

:- gripper(Gripper), gripper_init(Gripper).

