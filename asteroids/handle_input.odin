package asteroids

import rl "vendor:raylib"


handle_input :: proc(game: ^Game) {
    is_moving := false
    if rl.IsKeyDown(.W) {
        game.player.velo += degrees_to_vec2(game.player.rot)
        is_moving = true
    }
    if rl.IsKeyDown(.S) {
        game.player.velo -= degrees_to_vec2(game.player.rot)
        is_moving = true
    }
    if rl.IsKeyDown(.A) {
        game.player.rot -= PLAYER_ROT_SPEED
    }
    if rl.IsKeyDown(.D) {
        game.player.rot += PLAYER_ROT_SPEED
    }
    if !is_moving {
        game.player.velo *= FRICTION
    }

    if rl.IsKeyPressed(.SPACE) {
        game.fire_projectile = true
    }
}