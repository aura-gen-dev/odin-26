package asteroids

import "core:fmt"
import "core:container/queue"
import rl "vendor:raylib"


handle_render :: proc(game: ^Game) {
    rl.BeginDrawing()
    rl.ClearBackground({0, 0, 0, 255})

    // Player
    // Define base triangle shape (pointing up)
    base_points := [3]Vec2f32{
        {0, -game.player.size},  // Top point
        {-game.player.size, game.player.size},  // Bottom left
        {game.player.size, game.player.size},   // Bottom right
    }
    
    // Rotate and position each point
    rot := degrees_to_vec2(game.player.rot + 90)
    v1 := rl.Vector2{
        game.player.pos.x + (base_points[0].x * rot.x - base_points[0].y * rot.y),
        game.player.pos.y + (base_points[0].x * rot.y + base_points[0].y * rot.x),
    }
    v2 := rl.Vector2{
        game.player.pos.x + (base_points[1].x * rot.x - base_points[1].y * rot.y),
        game.player.pos.y + (base_points[1].x * rot.y + base_points[1].y * rot.x),
    }
    v3 := rl.Vector2{
        game.player.pos.x + (base_points[2].x * rot.x - base_points[2].y * rot.y),
        game.player.pos.y + (base_points[2].x * rot.y + base_points[2].y * rot.x),
    }
    
    rl.DrawTriangle(v1, v2, v3, rl.WHITE)
    
    // Add circle at bottom center
    circle_pos := rl.Vector2{
        game.player.pos.x + (0 * rot.x - game.player.size * rot.y),
        game.player.pos.y + (0 * rot.y + game.player.size * rot.x),
    }
    rl.DrawCircleV(circle_pos, game.player.size * 0.3, rl.WHITE)

    // Render projectiles
    for i in 0..<queue.len(game.projectiles) {
        projectile := queue.get_ptr(&game.projectiles, i)
        rl.DrawCircleV(
            rl.Vector2{projectile.pos.x, projectile.pos.y},
            PROJECTILE_SIZE,
            rl.WHITE,
        )
    }

    // Render asteroids
    for asteroid in game.asteroids {
        rl.DrawPoly(
            rl.Vector2({asteroid.pos.x, asteroid.pos.y}),
            asteroid.sides,
            asteroid.size,
            asteroid.rot,
            rl.WHITE
        )
    }

    rl.EndDrawing()
}