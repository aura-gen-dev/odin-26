package asteroids

import "core:fmt"
import "core:container/queue"
import rl "vendor:raylib"


handle_update :: proc(game: ^Game, dt: f32) {
    game.time += dt
    
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

    // Create new projectile if fire requested
    if game.fire_projectile && game.last_projectile_time + PROJECTILE_SPAWN_RATE < game.time {
        projectile_velo := degrees_to_vec2(game.player.rot) * PROJECTILE_SPEED + game.player.velo
        fmt.printfln("%v", projectile_velo)
        projectile := Projectile{
            pos = game.player.pos,
            velo = projectile_velo,
            start_time = game.time,
        }
        queue.push_back(&game.projectiles, projectile)
        game.fire_projectile = false
        game.last_projectile_time = game.time
    }

    // Create new asteroid if needed
    if game.last_asteroid_time + ASTEROID_SPAWN_RATE < game.time && len(game.asteroids) < MAX_ASTEROIDS {
        asteroid := Asteroid{
            pos = {f32(rl.GetRandomValue(0, WINDOW_WIDTH)), f32(rl.GetRandomValue(0, WINDOW_HEIGHT))},
            velo = degrees_to_vec2(f32(rl.GetRandomValue(0, 360))) * f32(rl.GetRandomValue(0, MAX_ASTEROID_SPEED)),
            rot = f32(rl.GetRandomValue(0, 360)),
            size = f32(rl.GetRandomValue(MIN_ASTEROID_SIZE, MAX_ASTEROID_SIZE)),
            sides = i32(rl.GetRandomValue(4, MAX_ASTEROID_SIDES)),
        }
        append(&game.asteroids, asteroid)
        game.last_asteroid_time = game.time
    }

    // Update projectiles
    for i in 0..<queue.len(game.projectiles) {
        projectile := queue.get_ptr(&game.projectiles, i)
        if game.time - projectile.start_time > PROJECTILE_LIFETIME {
            queue.pop_front(&game.projectiles)
            continue
        }
        
        // Update position
        fmt.printfln("%v", projectile.velo)
        projectile.pos += projectile.velo * dt
        
        // Wrap around screen
        if projectile.pos.x < 0 { projectile.pos.x = WINDOW_WIDTH }
        if projectile.pos.x > WINDOW_WIDTH { projectile.pos.x = 0 }
        if projectile.pos.y < 0 { projectile.pos.y = WINDOW_HEIGHT }
        if projectile.pos.y > WINDOW_HEIGHT { projectile.pos.y = 0 }
    }

    // Update asteroids
    for i in 0..<len(game.asteroids) {
        asteroid := &game.asteroids[i]
        asteroid.pos += asteroid.velo * dt
        if asteroid.pos.x < 0 { asteroid.pos.x = WINDOW_WIDTH }
        if asteroid.pos.x > WINDOW_WIDTH { asteroid.pos.x = 0 }
        if asteroid.pos.y < 0 { asteroid.pos.y = WINDOW_HEIGHT }
        if asteroid.pos.y > WINDOW_HEIGHT { asteroid.pos.y = 0 }
    }

}