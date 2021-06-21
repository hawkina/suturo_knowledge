:- module(pickup,
    [
      next_object_/1,
      surface_pose_to_perceive_from/2,
      object_pose_to_grasp_from/2,
      surface_not_a_bucket/1
    ]).

:- rdf_db:rdf_register_ns(hsr_objects, 'http://www.semanticweb.org/suturo/ontologies/2020/3/objects#', [keep(true)]).
:- rdf_db:rdf_register_ns(robocup, 'http://www.semanticweb.org/suturo/ontologies/2020/2/Robocup#', [keep(true)]).

:- rdf_meta
    next_object_(?).
    

next_object_(BestObj) :-
    place_objects,
    hsr_existing_objects(X),
    findall(Object,
         (
         member(Object,X),
         object_supported_by_surface(Object,S),
         surface_not_a_bucket(S)
         )
         ,
        Objects),
    predsort(compareDistances, Objects, SortedObjs),
    nth0(0, SortedObjs, BestObj).


surface_pose_to_perceive_from(Surface, [[2.8899999839230626, 0.46000000509103018, 0], [0.0, 0.0, -0.707106771713121, 0.707106790659974]]) :-
    has_urdf_name(Surface, "bin_b:table:table_center").



surface_pose_to_perceive_from(Surface, [[XPos,YPos,0],Rotation]):-
    has_urdf_name(Surface, SurfaceLink),
    surface_dimensions(Surface,X,_,_),
    HalfX is X / 2,
    XOffset is (X * -1.75) - HalfX,
    (XOffset >= -0.6  - HalfX
    -> XOffsetUsed is -0.6  - HalfX
    ; XOffsetUsed is (X * -1.75) - HalfX),
    tf_transform_point(SurfaceLink, map, [XOffsetUsed, 0, 0], [XPos,YPos,_]),
    tf_lookup_transform('map', SurfaceLink, pose(_,Rotation)).
    


object_pose_to_grasp_from(Object,[[XPose,YPose,0], Rotation]):-
    object_supported_by_surface(Object,Surface),
    has_urdf_name(Surface,Name),
    surface_front_edge_center_pose(Surface,[_, Rotation]),
    object_tf_frame(Object,F),
    tf_lookup_transform(Name, F, pose([_,Y,_],_)),
    surface_dimensions(Surface, Depth, _, _),
    Offset is -(Depth / 2 + 0.5),
    tf_transform_point(Name, map, [Depth, Y,0], [XPose,YPose,_]).

surface_not_a_bucket(S):-
    has_urdf_name(S,N),
    not(sub_string(N,_,_,_,"bucket")),
    not(gripper(S)).

surface_not_a_bucket(S):-
    is_room(S).

