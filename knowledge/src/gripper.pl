:- module(gripper,
    [
    all_objects_in_gripper/1,
    gripper/1,
    gripper_init/1,
    attach_object_to_gripper/1,
    release_object_from_gripper/1
    ]).

:- rdf_db:rdf_register_ns(hsr_objects, 'http://www.semanticweb.org/suturo/ontologies/2020/3/objects#', [keep(true)]).
:- rdf_db:rdf_register_ns(robocup, 'http://www.semanticweb.org/suturo/ontologies/2020/2/Robocup#', [keep(true)]).


:- rdf_meta
    gripper(+),
    gripper_int(r),
    attach_object_to_gripper(r),
    release_object_from_gripper(r)
    .




gripper(Gripper) :-
    Gripper = gripper.

gripper_init(Gripper) :-
    %rdf_instance_from_class(knowrob:'EnduringThing-Localized', belief_state, Gripper),
    tell(has_type(Gripper, owl:'NamedIndividual')),
    tell(triple(Gripper, knowrob:'frameName', hand_palm_link)).


all_objects_in_gripper(Instances):-
    findall(Instance, (
        objects_on_surface(Objs, gripper),
        member(Instance, Objs)
        ), Instances).

attach_object_to_gripper(Instance) :-
    forall(triple(Instance, hsr_objects:'supportedBy', _), tripledb_forget(Instance, hsr_objects:'supportedBy', _)),
    gripper(Gripper),
    tell(triple(Instance, hsr_objects:'supportedBy', Gripper)),
    %object_frame_name(Instance, InstanceFrame),
    %object_frame_name(Gripper,GripperFrame),
    hsr_lookup_transform(Gripper, Instance, PoseTrans, PoseRota),
    tell(is_at(Instance, [Gripper, PoseTrans, PoseRota])).

release_object_from_gripper([NewPose,NewRotation]) :-
    gripper(Gripper),
    objects_on_surface(Instances, Gripper),
    member(Instance, Instances),
    %object_frame_name(Instance, InstanceFrame),
    hsr_belief_at_update(Instance, [map, _, NewPose, NewRotation]),
    place_object(Instance),
    group_target_objects.
