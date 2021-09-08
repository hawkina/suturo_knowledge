:- module(furnitures,
    [   init_furnitures/0,
        is_furniture/1,
        all_furnitures/1,
        furniture_surfaces/2,
        has_surface/2,
        has_table_shape/1,
        has_shelf_shape/1,
        has_bucket_shape/1
    ]).


:- use_module('./surfaces', [create_surface/3]).


:- tripledb_load(
	'package://knowledge/owl/rooms.owl',
	[ namespace(hsr_rooms, 'http://www.semanticweb.org/suturo/ontologies/2021/0/rooms#')
	]).



is_furniture(Furniture) :-
    has_type(Furniture, soma:'DesignedFurniture').


all_furnitures(Furnitures) :-
    findall(Furniture, is_furniture(Furniture), Furnitures).


has_surface(Furniture, Surface) ?+>
    triple(Furniture, hsr_rooms:'hasSurface', Surface).


furniture_surfaces(Furniture, Surfaces) :-
    findall(Surface, has_surface(Furniture, Surface), Surfaces).


has_table_shape(Surface) :-
    has_surface(Furniture, Surface),
    triple(Furniture, soma:'hasShape', hsr_rooms:'TableShape'),
    not has_bucket_shape(Surface).


has_shelf_shape(Surface) :-
    has_surface(Furniture, Surface),
    triple(Furniture, soma:'hasShape', hsr_rooms:'ShelfShape').


has_bucket_shape(Surface) :-
    has_surface(Furniture,Surface),
    has_type(Furniture, hsr_rooms:'Deposit').


init_furnitures :-
    get_urdf_id(URDF),
    urdf_link_names(URDF, Links),
    forall((
        member(FurnitureLink, Links),
        is_furniture_link(FurnitureLink)
    ), 
    init_furniture(FurnitureLink)).


init_furniture(FurnitureLink) :-
    split_string(FurnitureLink, ":", "", [_, Type, Shape]),
    writeln(FurnitureLink),
    create_furniture(Type, Furniture),
    tell(has_urdf_name(Furniture, FurnitureLink)),
    assign_furniture_location(Furniture),
    assign_surfaces(Furniture, FurnitureLink, Shape).


create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"armchair"),
    tell(has_type(Furniture, hsr_rooms:'Armchair')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"bed"),
    tell(has_type(Furniture, hsr_rooms:'Bed')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"bucket"),
    tell(has_type(Furniture, hsr_rooms:'Bucket')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"container"),
    tell(has_type(Furniture, hsr_rooms:'Container')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"couch"),
    tell(has_type(Furniture, hsr_rooms:'Couch')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"cabinet"),
    tell(has_type(Furniture, hsr_rooms:'Cabinet')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"dishwasher"),
    tell(has_type(Furniture, hsr_rooms:'Dishwasher')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"fridge"),
    tell(has_type(Furniture, hsr_rooms:'Fridge')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"shelf"),
    tell(has_type(Furniture, hsr_rooms:'Shelf')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"sideboard"),
    tell(has_type(Furniture, hsr_rooms:'Sideboard')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"sidetable"),
    tell(has_type(Furniture, hsr_rooms:'Sidetable')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"sink"),
    tell(has_type(Furniture, hsr_rooms:'Sink')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"table"),
    tell(has_type(Furniture, hsr_rooms:'Table')),
    !.

create_furniture(FurnitureType, Furniture) :-
    sub_string(FurnitureType,_,_,_,"tray"),
    tell(has_type(Furniture, hsr_rooms:'Tray')),
    !.


assign_surfaces(Furniture, FurnitureLink, Shape) :-
    sub_string(Shape,_,_,_,"table"),
    sub_atom(FurnitureLink, 0, _, 17, FurnitureStem),
    atom_concat(FurnitureStem, "center", SurfaceLink),
    create_surface(Shape, SurfaceLink, Surface),
    tell(has_surface(Furniture, Surface)),
    tell(triple(Furniture, soma:'hasShape', hsr_rooms:'TableShape')).


assign_surfaces(Furniture, FurnitureLink, Shape) :-
    sub_string(Shape,_,_,_,"shelf"),
    tell(triple(Furniture, soma:'hasShape', hsr_rooms:'ShelfShape')),
    get_urdf_id(URDF),
    urdf_link_child_joints(URDF, FurnitureLink, Joints),
    findall(SurfaceLink,
    (
        member(Joint, Joints),
        urdf_joint_child_link(URDF, Joint, SurfaceLink)
    ), 
    SurfaceLinks),
    forall((
        member(SurfaceLink, SurfaceLinks), 
        create_surface(Shape, SurfaceLink, Surface)
    ), tell(has_surface(Furniture, Surface))).


assign_surfaces(Furniture, FurnitureLink, Shape) :-
    sub_string(Shape,_,_,_,"bucket"),
    tell(triple(Furniture, soma:'hasShape', hsr_rooms:'BucketShape')),
    sub_atom(FurnitureLink, 0, _, 17, FurnitureStem),
    atom_concat(FurnitureStem, "surface_center", SurfaceLink),
    create_surface(Shape, SurfaceLink, Surface),
    tell(has_surface(Furniture, Surface)).


assign_furniture_location(Furniture) :-
    tell(has_type(Location, soma:'Location')),
    tell(has_location(Furniture, Location)).


is_furniture_link(Link) :-
    sub_string(Link,_,_,_,"table_front_edge_center");
    sub_string(Link,_,_,_,"shelf_base_center");
    sub_string(Link,_,_,_,"bucket_front_edge_center").

