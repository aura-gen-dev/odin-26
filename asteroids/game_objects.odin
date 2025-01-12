package asteroids

import "core:math"

Game :: struct {
    player: Player,
    projectiles: [dynamic]Projectile,
    fire_projectile: bool
}

init_game :: proc() -> Game {
    return Game {
        player = Player {
            pos = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2},
            velo = {0, 0},
            rot = 0,
            size = 15
        },
    }
}

Player :: struct {
    pos: Vec2f32,
    velo: Vec2f32,
    rot: f32,
    size: f32
}

Projectile :: struct {
    pos: Vec2f32,
    velo: Vec2f32
}

degrees_to_vec2 :: proc(degrees: f32) -> Vec2f32 {
    radians := degrees * math.PI / 180
    return Vec2f32{
        math.sin_f32(radians),
        -math.cos_f32(radians),  // Negative because y-axis is inverted
    }
}