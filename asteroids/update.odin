package asteroids

import rl "vendor:raylib"


handle_update :: proc(game: ^Game, dt: f32) {
    game.player.pos += game.player.velo * dt
    game.player.velo.x = rl.Clamp(game.player.velo.x, -MAX_SPEED, MAX_SPEED)
    game.player.velo.y = rl.Clamp(game.player.velo.y, -MAX_SPEED, MAX_SPEED)

    if game.player.pos.x < 0 {
        game.player.pos.x = WINDOW_WIDTH
    }
    if game.player.pos.x > WINDOW_WIDTH {
        game.player.pos.x = 0
    }
    if game.player.pos.y < 0 {
        game.player.pos.y = WINDOW_HEIGHT
    }
    if game.player.pos.y > WINDOW_HEIGHT {
        game.player.pos.y = 0
    }
}