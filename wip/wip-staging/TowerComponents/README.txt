
This README should tell you everything you need to know about the room system

=== NOTES ===

- For the player to be detected by doors, attach ../5_Others/player_area.tscn to player
- Doors must be connected to the rooms from the editor

=== SCENE STRUCTURES ===

 MAIN SCENE
// Any node names are fine in the main scene

Root
↳ RoomController (Node)   (room_controller.gd)
↳ Tower          (Node2D) (tower_root.gd)
  ↳ Room 1       // TOWER ROOM SCENE //
  ↳ Door 1       (Node2D) (room_door.tscn instance)
  ↳ Room 2
  ↳ Door 2
	 etc.
↳ Camera         (Camera2D) (camera_script.gd)    
// Rooms and Door ordering does not matter as long as they are each children of the root tower

TOWER ROOM SCENES
// Look at basic_room.tscn in the /example folder

// Nodes marked with   *    mean the name must be exactly that
Node2D (tower_room.gd)
↳ RoomContent  * (Node2D)
   ↳ Here are all the things that go in the room, no restrictions. (Will be disabled when the room is "unloaded")
↳ CameraTarget * (Marker2D)
↳ CameraBounds * (ReferenceRect)
