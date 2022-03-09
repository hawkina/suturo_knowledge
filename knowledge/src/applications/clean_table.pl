:- module(clean_table,
	  [
	      temporary_storage_surface/1,
	      temporary_storage_pose/2
	  ]).

:- use_module(library('beliefstate')).
:- use_module(library('locations/spatial_comp'),
	[
            surface_dimensions/4
	]).

:- use_module(library('model/environment/surfaces'),
	   [
	       has_table_shape/1
	   ]).

:- rdf_meta
   temporary_storage_surface(?),
   temporary_storage_pose(-, ?).

temporary_storage_surface(Surface) :-
    has_urdf_name(Surface,"long_table:table:table_center").

temporary_storage_pose(Instance, [Translation, Rotation]) :-
    temporary_storage_surface(Surface),
    temporary_storage_pose_(Instance, [Translation, Rotation], Surface).

temporary_storage_pose_(Instance, [Translation, Rotation], Surface) :-
    %% The logging here is done in case there is an error in this method and you want to quickly look at what failed.
    format(string(Log1), "temporary_storage_pose_('~w', [Translation, Rotation], '~w')", [Instance, Surface]),
    ros_info(Log1),

    %% This code is copied mostly from object_goal_pose in gripper/placing.pl
    has_table_shape(Surface),
    has_urdf_name(Surface, SurfaceLink),
    %% Note: the SurfaceLink is in the center of the surface

    min_space_between_objects(MinSpace),
    object_dimensions(Instance, ObjectWidth, ObjectDepth, _),
    all_groups_on_tablelike_surface(Surface, Groups),
    surface_dimensions(Surface, SurfaceWidth, SurfaceDepth, SurfaceHeight),
    length(Groups, NGroups),
    format(string(Log2), "temporary_storage_pose_/3 variables. Groups: ~w, NGroups:~w", [Groups, NGroups]),
    ros_info(Log2),



    (NGroups = 0
    ->
	(
	    %%      to the front   and space away and to the center of the object
            RefX is (-SurfaceWidth/2) + MinSpace + ObjectDepth/2,
	    %%      to the left and space away and to the center of the object
            RefY is SurfaceDepth/2 - MinSpace - ObjectWidth/2,
            tf_transform_pose(SurfaceLink, 'map', pose([RefX, RefY, 0.1], [0, 0, 0, 1]), pose(Translation, Rotation)),

            tell(has_type(NewGroup, hsr_objects:'Group')),
            tell(triple(Instance, hsr_objects:'inGroup', NewGroup)),
        );
     (NGroups = 1 ->
          (
              [Group] = Groups,

	      %% group_position_on_surface returns the hind left corner, but we need the front right
	      group_position_on_surface(Group, Surface, [GroupX, GroupY, _]),
              group_dimensions(Group, GroupDepth, GroupWidth),

	      %% start at the back of the group, go to the front, and go back to the center of the object.
	      %% this way all object align their start at the local x coordinate
	      RefX is GroupX - GroupDepth + ObjectDepth/2,

	      %% start at the left, go to the right, add the spacer, go to the center of the new object
	      RefY is GroupY - GroupWidth - MinSpace - ObjectWidth/2,
              tf_transform_pose(SurfaceLink, 'map', pose([RefX, RefY, 0.1], [0, 0, 0, 1]), pose(Translation, Rotation)),
	      tell(triple(Instance, hsr_objects:'inGroup', Group))
          );
      %% Idk how groups are supposed to work and i don't have the time to try it now.
      %% Because of that i won't implement handling more than one group on a surface
      (ros_info("Ngroups Fail"),fail()))),
    !.

