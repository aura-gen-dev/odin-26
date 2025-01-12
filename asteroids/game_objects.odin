package asteroids

import "core:math"
import "core:container/queue"

Game :: struct {
    player: Player,
    projectiles: queue.Queue(Projectile),
    asteroids: [dynamic]Asteroid,
    fire_projectile: bool,
    time: f32,
    last_projectile_time: f32,
    last_asteroid_time: f32
}

init_game :: proc() -> Game {
    game := Game {
        player = Player {
            pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2},
            velo = {0, 0},
            rot = 0,
            size = 15
        },
        time = 0,
    }
    queue.init(&game.projectiles)
    return game
}

Player :: struct {
    pos: Vec2f32,
    velo: Vec2f32,
    rot: f32,
    size: f32
}

Projectile :: struct {
    pos: Vec2f32,
    velo: Vec2f32,
    start_time: f32
}

Asteroid :: struct {
    pos: Vec2f32,
    velo: Vec2f32,
    rot: f32,
    size: f32,
    sides: i32
}

degrees_to_vec2 :: proc(degrees: f32) -> Vec2f32 {
    radians := degrees * math.PI / 180
    return Vec2f32{
        math.sin_f32(radians),
        -math.cos_f32(radians),  // Negative because y-axis is inverted
    }
}