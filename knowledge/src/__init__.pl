:- register_ros_package(knowrob).
:- register_ros_package(knowledge).
:- register_ros_package(rosprolog).

:- rdf_db:rdf_register_ns(hsr_objects, 'http://www.semanticweb.org/suturo/ontologies/2020/3/objects#', [keep(true)]).
:- rdf_db:rdf_register_ns(urdf, 'http://knowrob.org/kb/urdf.owl#', [keep(true)]).

:- use_module(library('knowrob')).

:- use_module(library('config')).
:- use_module(library('urdf')).
:- use_module(library('spatial_comp')).
:- use_module(library('pickup')).
:- use_module(library('object_state')).
:- use_module(library('surfaces')).
:- use_module(library('beliefstate')).
:- use_module(library('assignplaces')).
:- use_module(library('gripper')).
:- use_module(library('mocking')).
:- use_module(library('export')).

:- owl_parser:owl_parse('package://dul/owl/DUL.owl').
:- owl_parser:owl_parse('package://knowrob/owl/knowrob.owl').
:- owl_parser:owl_parse('package://knowledge/owl/objects.owl').
:- owl_parser:owl_parse('package://knowrob/src/ros/urdfprolog/owl/urdf.owl').

:- ros_param_get_string('/param_to_load_URDF_from', Param),
    load_surfaces_from_param(Param).

:- tf_lookup_transform(map, map, _).

:- gripper(Gripper), gripper_init(Gripper).

