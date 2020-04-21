
:- module(object_state,
    [
      create_object/2,
      object_at/4,
      clear/0,
      object_at_table/1,
      object_of_type/2,
      create_object_at/6,
      create_object_at/10,
      hsr_existing_objects/1,
      hsr_forget_object/1,

      %%% DEBUG %%%
      set_dimension_semantics/4,
      set_object_colour/3,
      object_type_handling/3,
      object_size_ok/1,
      set_colour_semantics/2
    ]).

:- rdf_db:rdf_register_ns(hsr_objects, 'http://www.semanticweb.org/suturo/ontologies/2018/10/objects#', [keep(true)]).
:- rdf_db:rdf_register_ns(robocup, 'http://knowrob.org/kb/robocup.owl#', [keep(true)]).

:- rdf_meta
    create_object(r,?),
	object_at(r,r,r,?),
	object_at_table(?),
	object_of_type(r,?),
	create_object_at(r,r,r,?,-,-),
	hsr_existing_objects(?).


hsr_existing_objects(Objects) :-
    belief_existing_objects(Objects, [hsr_objects:'Item']).

hsr_forget_object(Object) :-
    rdf_retractall(Object,_,_).


object_at(ObjectType, Transform, Threshold, Instance) :-
	hsr_existing_objects(Objectlist),
	member(Instance, Objectlist),
	belief_existing_object_at(ObjectType, Transform, Threshold, Instance).

object_at_table(Instance) :-
	all_objects_on_tables(Instances),once(member(Instance,Instances)).

object_of_type(ObjectType, Instance) :-
	belief_existing_objects(Instance, [ObjectType]).

create_object(ObjectType, Instance) :-
 	owl_subclass_of(ObjectType, hsr_objects:'Item'),
	belief_new_object(ObjectType, Instance).

% deprecated. buggy, too.
create_object_at(ObjectType, Transform, Threshold, Instance, Dimensions, Color) :-
    create_object_at(ObjectType, _, Transform, Threshold, Instance, Dimensions, '', _, Color, _).

create_object_at(PerceivedObjectType, PercTypeConfidence, Transform, Threshold, Instance, [Width, Depth, Height], Shape, PercShapeConfidence, Color, PercColorCondidence) :-
    validate_confidence(class, PercTypeConfidence, TypeConfidence),
    validate_confidence(shape, PercShapeConfidence, ShapeConfidence),
    validate_confidence(color, PercColorCondidence, ColorCondidence),
    object_size_ok([Width, Depth, Height]),
    object_type_handling(PerceivedObjectType, TypeConfidence, ObjectType),
    owl_subclass_of(ObjectType, hsr_objects:'Item'),
    new_perceived_at(ObjectType, Transform, Threshold, Instance),
    atom_number(TypeConfidenceAtom, TypeConfidence),
    rdf_assert(Instance, hsr_objects:'ConfidenceClassValue', TypeConfidenceAtom),
    object_assert_dimensions(Instance, Width, Depth, Height),
    set_dimension_semantics(Instance, Width, Depth, Height),
    object_shape_handling(Instance, Shape, ShapeConfidence),
    atom_number(ShapeConfidenceAtom, ShapeConfidence),
    rdf_assert(Instance, hsr_objects:'ConfidenceShapeValue', ShapeConfidenceAtom),
    atom_number(ColorCondidenceAtom, ColorCondidence),
    rdf_assert(Instance, hsr_objects:'ConfidenceColorValue', ColorCondidenceAtom),
    set_object_colour(Instance, Color, ColorCondidence),
    !,
    place_objects.

place_objects :-
    hsr_existing_objects(Objs),
    forall(member(Obj, Objs),place_object(Obj)).

validate_confidence(class, Is, Should) :-
    var(Is),
    min_class_confidence(Should).

validate_confidence(shape, Is, Should) :-
    var(Is),
    min_shape_confidence(Should).

validate_confidence(color, Is, Should) :-
    var(Is),
    min_color_confidence(Should).

validate_confidence(_, Is, Should) :-
    Should = Is.

object_size_ok([Width,Depth,Height]):-
    Width > 0.01,
    Depth > 0.01,
    Height > 0.01,
    Width < 0.6,
    Depth < 0.6,
    Height < 0.6.

object_type_handling(PerceivedObjectType, TypeConfidence, ObjectType) :-
    min_class_confidence(MinConf),
    (   number(TypeConfidence),
        TypeConfidence >= MinConf
        -> ObjectType = PerceivedObjectType
        ; ObjectType = 'http://www.semanticweb.org/suturo/ontologies/2018/10/objects#Other'
        ).

set_dimension_semantics(Instance, _, _, Height) :-
    Height > 0.16,
    rdf_assert(Instance, hsr_objects:'size', 'tall').

set_dimension_semantics(Instance, Width, Depth, Height) :-
    Height < Width * 0.9,
    Height < Depth * 0.9,
    rdf_assert(Instance, hsr_objects:'size', 'flat').

set_dimension_semantics(Instance, Width, Depth, Height) :-
    ((Depth > Width * 2, Depth > Height * 2);
     (Width > Depth * 2, Width > Height * 2)),
    rdf_assert(Instance, hsr_objects:'size', 'long').

set_dimension_semantics(Instance, Width, Depth, Height) :-
    Volume is Width * Depth * Height * 1000,
    Volume < 0.6,
    rdf_assert(Instance, hsr_objects:'size', 'small').

set_dimension_semantics(Instance, Width, Depth, Height) :-
    Volume is Width * Depth * Height * 1000,
    Volume > 2.0,
    rdf_assert(Instance, hsr_objects:'size', 'big').

set_dimension_semantics(_Instance,_W,_D,_H) :-
    true.

object_shape_handling(Instance, Shape, Confidence) :-
    min_shape_confidence(MinConf),
    Confidence > MinConf,
    rdf_assert(Instance, 'http://www.ease-crc.org/ont/EASE-OBJ.owl#Shape', Shape).

object_shape_handling(Instance, _, Confidence) :-
    min_shape_confidence(MinConf),
    Confidence =< MinConf,
    rdf_assert(Instance, 'http://www.ease-crc.org/ont/EASE-OBJ.owl#Shape', '').

set_object_colour(Instance, _, Confidence) :-
    min_color_confidence(MinConf),
    Confidence < MinConf,
    rdf_assert(Instance, hsr_objects:'colour', ''),
    object_assert_color(Instance, '').

set_object_colour(Instance, [0.0, 0.0, 0.0, 0.0], _) :-
    object_assert_color(Instance, [0.8, 0.8, 0.8, 0.8]),
    rdf_assert(Instance, hsr_objects:'colour', 'grey'), !.

set_object_colour(Instance, [R,G,B,_], _) :-
    RConv is R/255,    GConv is G/255,    BConv is B/255,
    object_assert_color(Instance, [RConv,GConv,BConv,0.8]),
    set_colour_semantics(Instance, [RConv,GConv,BConv]).

set_colour_semantics(Instance, [0.0, 0.0, 0.0]) :-
    rdf_assert(Instance, hsr_objects:'colour', 'dark').

set_colour_semantics(Instance, [1.0, 0.0, 0.0]) :-
    rdf_assert(Instance, hsr_objects:'colour', 'red').

set_colour_semantics(Instance, [0.0, 1.0, 0.0]) :-
    rdf_assert(Instance, hsr_objects:'colour', 'green').

set_colour_semantics(Instance, [1.0, 1.0, 0.0]) :-
    rdf_assert(Instance, hsr_objects:'colour', 'yellow').

set_colour_semantics(Instance, [0.0, 0.0, 1.0]) :-
    rdf_assert(Instance, hsr_objects:'colour', 'dark-blue').

set_colour_semantics(Instance, [1.0, 0.0, 1.0]) :-
    rdf_assert(Instance, hsr_objects:'colour', 'violet').

set_colour_semantics(Instance, [0.0, 1.0, 1.0]) :-
    rdf_assert(Instance, hsr_objects:'colour', 'light-blue').

set_colour_semantics(Instance, [1.0, 1.0, 1.0]) :-
    rdf_assert(Instance, hsr_objects:'colour', 'bright').

set_colour_semantics(_, _) :-
    true.
    
clear :-
	belief_forget.
