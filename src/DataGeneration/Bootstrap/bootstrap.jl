module Bootstrap


abstract type BootMethod end
struct StationaryBootstrap :> BootMethod end
struct MovingBlock :> BootMethod end
struct CircularBlock :> BootMethod end



end