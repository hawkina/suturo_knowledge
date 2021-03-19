:- module(rooms,
    [
        create_rooms/0,
        object_instance_in_room/3,
        object_class_in_room/3,
        are_orthogonal_walls/2,
        get_intersection_of_walls/4,
        get_room_dimensions/5,
        in_room/2,
        all_rooms_of_type/2
    ]).


:- rdf_db:rdf_register_ns(hsr_rooms, 'http://www.semanticweb.org/suturo/ontologies/2021/0/rooms#', [keep(true)]).
:- rdf_db:rdf_register_ns(hsr_locations, 'http://www.semanticweb.org/suturo/ontologies/2021/0/locations#', [keep(true)]).

:- rdf_meta
    min_door_joint_angle(?).


create_rooms :-
    get_urdf_id(URDF),
    urdf_link_names(URDF, Links),
    findall(RoomLink, 
    (
        member(RoomLink, Links),
        sub_string(RoomLink,_,_,_,walls)
    ),
    RoomLinks),
    forall(member(RoomLink2, RoomLinks),
    (    
        create_room(RoomLink2)
    )).

    %forall(has_type(Room, hsr_rooms:'Room'), 
    %(
        %get_room_dimensions(Room, Width, Depth, PosX, PosY),
        %tell(has_type(Shape, soma:'Shape')),
        %tell(triple(Room, soma:'hasShape', Shape)),
        %tell(object_dimensions(Room, Width, Depth, 0.6)),
        %get_urdf_origin(Origin),
        %tell(is_at(Room, [Origin, [PosX, PosY, 0.0], [0.0, 0.0, 0.0, 1.0]]))
    %)).


create_room(RoomLink) :-
    get_room_dimensions(RoomLink, Width, Depth, PosX, PosY),
    tell(has_type(Room, hsr_rooms:'Room')),
    tell(has_type(Shape, soma:'Shape')),
    tell(triple(Room, soma:'hasShape', Shape)),
    tell(object_dimensions(Room, Width, Depth, 0.6)),
    get_urdf_origin(Origin),
    tell(is_at(Room, [Origin, [PosX, PosY, 0.0], [0.0, 0.0, 0.0, 1.0]])),
    ( sub_string(RoomLink,_,_,_,kitchen)
    -> (tell(has_type(KitchenType, hsr_rooms:'Kitchen')), tell(triple(Room, hsr_rooms:'hasRoomTypeRole', KitchenType)))
    ;
    ( sub_string(RoomLink,_,_,_,diningroom)
    -> (tell(has_type(DiningType, hsr_rooms:'DiningRoom')), tell(triple(Room, hsr_rooms:'hasRoomTypeRole', DiningType)))
    ;
    ( sub_string(RoomLink,_,_,_,livingroom)
    -> (tell(has_type(LivingType, hsr_rooms:'LivingRoom')), tell(triple(Room, hsr_rooms:'hasRoomTypeRole', LivingType)))
    ;
    ( sub_string(RoomLink,_,_,_,bedroom)
    -> (tell(has_type(BedType, hsr_rooms:'Bedroom')), tell(triple(Room, hsr_rooms:'hasRoomTypeRole', BedType)))
    ;
    (tell(has_type(OfficeType, hsr_rooms:'Office')), tell(triple(Room, hsr_rooms:'hasRoomTypeRole', OfficeType)))
    )))).



in_room(ObjectClass, RoomType) :-
    holds(ObjectClass, hsr_rooms:'inRoom', RoomType).


all_rooms_of_type(RoomType, Rooms) :-
    findall(Room,
    (
        has_type(Type, RoomType),
        triple(Room, hsr_rooms:'hasRoomTypeRole', Type)
    ),
    Rooms).


object_instance_in_room(ObjInstance, Room, RoomType) :-
    object_frame_name(ObjInstance, ObjFrame),
    get_urdf_origin(Origin),
    tf_lookup_transform(ObjFrame, Origin, pose([XObj, YObj, _], _)),
    has_type(Room, hsr_rooms:'Room'),
    object_frame_name(Room, RoomFrame),
    tf_lookup_transform(RoomFrame, Origin, pose([XRoom, YRoom, _], _)),
    object_dimensions(Room, Width, Depth, _),
    XObj > XRoom - Width/2,
    XObj < XRoom + Width/2,
    YObj > YRoom - Depth/2,
    YObj < YRoom + Depth/2,
    triple(Room , hsr_rooms:'hasRoomTypeRole', RoomType).


object_class_in_room(ObjInstance, Rooms, RoomType) :-
    has_type(Location, hsr_rooms:'RoomLocation'),
    triple(Location, hsr_objects:'subject', SupportedClass),
    has_type(ObjInstance, ObjClass),
    transitive(subclass_of(ObjClass, SupportedClass)),
    triple(Location, hsr_rooms:'object', RoomType),
    findall(Room, 
        (
            has_type(RoomTypeInstance, RoomType),
            triple(Room, hsr_rooms:'hasRoomTypeRole', RoomTypeInstance)
        ), 
    Rooms).


object_class_on_furniture(ObjInstance, Furnitures, FurnitureType) :-
    has_type(Location, hsr_rooms:'FurnitureLocation'),
    triple(Location, hsr_objects:'subject', SupportedClass),
    has_type(ObjectInstance, ObjClass),
    transitive(subclass_of(ObjClass, SupportedClass)),
    triple(Location, hsr_rooms:'object', FurnitureType),
    findall(Furniture, has_type(Furniture, FurnitureType), Furnitures).
    


get_room_dimensions(RoomLink, Width, Depth, PosX, PosY) :-
    get_urdf_id(URDF), 
    urdf_link_child_joints(URDF, RoomLink, Joints), 
    findall(Wall, 
    (
        member(Joint, Joints), 
        urdf_joint_child_link(URDF, Joint, Wall)
    ),
    Walls),
    member(Wall1, Walls), member(Wall2, Walls),
    not same_as(Wall1, Wall2),
    %triple(Room, hsr_rooms:'hasSurface', Wall1), has_type(Wall1, hsr_rooms:'Wall'),
    %triple(Room, hsr_rooms:'hasSurface', Wall2), has_type(Wall2, hsr_rooms:'Wall'),
    %not same_as(Wall1, Wall2),
    are_orthogonal_walls(Wall1, Wall2),
    get_intersection_of_walls(Wall1, Wall2, X1, Y1),
    %triple(Room, hsr_rooms:'hasSurface', Wall3), has_type(Wall3, hsr_rooms:'Wall'),
    %triple(Room, hsr_rooms:'hasSurface', Wall4), has_type(Wall4, hsr_rooms:'Wall'),
    member(Wall3, Walls), member(Wall4, Walls),
    not same_as(Wall1, Wall3), not same_as(Wall2, Wall3), 
    not same_as(Wall1, Wall4), not same_as(Wall2, Wall4),
    not same_as(Wall3, Wall4),
    are_orthogonal_walls(Wall3, Wall4),
    get_intersection_of_walls(Wall3, Wall4, X2, Y2),
    ( not X1 = X2, not Y1 = Y2
    -> ( Width is abs(X2 - X1), 
        Depth is abs(Y2 - Y1),
        ( X1 < X2
        -> PosX is X1 + Width/2 
        ; PosX is X2 + Width/2
        ),
        ( Y1 < Y2
        -> PosY is Y1 + Depth/2
        ; PosY is Y2 + Depth/2
        )   
    ; fail
    )).


are_parallel_walls(Wall1, Wall2) :-
    object_frame_name(Wall1, FrameWall1),
    object_frame_name(Wall2, FrameWall2),
    tf_lookup_transform(FrameWall1, FrameWall2, pose(_, [W, X, Y, Z])),
    ( W > -0.1, W < 0.1, X > -0.1, X < 0.1, Y > -0.1, Y < 0.1, Z > 0.9, Z < 1.1
    -> true
    ;
    fail
    ).


are_orthogonal_walls(Wall1, Wall2) :-
    object_frame_name(Wall1, FrameWall1),
    object_frame_name(Wall2, FrameWall2),
    tf_lookup_transform(FrameWall1, FrameWall2, pose(_, [W, X, Y, Z])),
    ( W > -0.1, W < 0.1, X > -0.1, X < 0.1, Y > 0.6, Y < 0.8, Z > 0.6, Z < 0.8
    -> true
    ;
    false
    ).


get_intersection_of_walls(Wall1, Wall2, X, Y) :-
    object_frame_name(Wall1, FrameWall1),
    object_frame_name(Wall2, FrameWall2),
    get_urdf_origin(Origin),
    tf_lookup_transform(Origin, FrameWall1, pose([X1, Y1, _], _)),
    tf_lookup_transform(Origin, FrameWall2, pose([X2, Y2, _], _)),
    X = X2,
    Y = Y1.



%is_horizontal_wall(Wall) :-
%    get_object_name(Wall, Name),
%    is_at(Name, [_, _ , Rot]),
%    ( Rot = [0.0, 0.0, 0.0, 1.0]
%    -> true
%    ; false
%    ).

%is_vertical_wall(Wall) :-
%    get_object_name(Wall, Name),
%    is_at(Name, [_, _, Rot]),
%    ( not Ror = [0.0, 0.0, 0.0, 1.0]
%    -> true
%    ; false
%    ).


%get_object_name(Object, Name) :-
%    split_string(Object, "#", "", [_, Name]).


    