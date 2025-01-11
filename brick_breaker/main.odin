package brick_breaker

import "core:fmt"
import "core:math/linalg"

import rl "vendor:raylib"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 600
TICK_RATE :: 0.017
Vec2f32 :: [2]f32
PADDLE_WIDTH :: 100
PADDLE_HEIGHT :: 10
PADDLE_PAD :: 50
PADDLE_SPEED :: 6
BALL_SIZE :: 10
BALL_SPEED :: 6
BRICK_WIDTH :: 100
BRICK_HEIGHT :: 25
BRICK_PAD :: 5
BRICK_ROWS :: 7
BRICK_COLS :: 8
BRICK_TOP :: 100

tick_timer: f32 = TICK_RATE
game_over: bool
paused: bool

player_paddle_start_pos: Vec2f32 = {WINDOW_WIDTH / 2 - PADDLE_WIDTH / 2, WINDOW_HEIGHT - PADDLE_PAD - PADDLE_HEIGHT / 2}
player_paddle_pos: Vec2f32
move_direction: Vec2f32
prev_ball_pos: Vec2f32
ball_pos: Vec2f32
ball_dir: Vec2f32
bricks: [BRICK_COLS][BRICK_ROWS]bool
score: int

restart :: proc() {
    game_over = false
    paused = true
    move_direction = {0, 0}
    player_paddle_pos = player_paddle_start_pos
    ball_pos = player_paddle_pos + {PADDLE_WIDTH / 2, -BALL_SIZE}
    prev_ball_pos = ball_pos
    x :=rl.GetRandomValue(-9, 9)
    y := rl.GetRandomValue(-9, -5)
    ball_dir = {f32(x), f32(y)}
    ball_dir = rl.Vector2Normalize(ball_dir)
    score = 0

    for x in 0..<BRICK_COLS {
        for y in 0..<BRICK_ROWS {
            bricks[x][y] = true
        }
    }
}

check_collision_ball_rect :: proc(rect: rl.Rectangle) -> rl.Vector2 {
    collision_normal: rl.Vector2
    if rl.CheckCollisionCircleRec(ball_pos, BALL_SIZE, rect) {
        if prev_ball_pos.y < rect.y + rect.height {
            collision_normal += {0, -1}
        }
        if prev_ball_pos.y > rect.y + rect.height {
            collision_normal += {0, 1}
        }

        if prev_ball_pos.x < rect.x {
            collision_normal += {-1, 0}
            // ball_pos.x = rect.x - BALL_SIZE
        }
        if prev_ball_pos.x > rect.x + rect.width {
            collision_normal += {1, 0}
            // ball_pos.x = rect.x + rect.width + BALL_SIZE
        } 
    }

    return collision_normal
}

check_collisions :: proc() {
    // Paddle collision with ball
    collision_normal := check_collision_ball_rect(rl.Rectangle {
        player_paddle_pos.x,
        player_paddle_pos.y,
        PADDLE_WIDTH,
        PADDLE_HEIGHT,
    })

    if collision_normal != 0 {
        ball_dir = linalg.normalize(linalg.reflect(ball_dir, linalg.normalize(collision_normal)))
        return
    }

    for i in 0..<BRICK_COLS {
        for j in 0..<BRICK_ROWS {
            if !bricks[i][j] {
                continue
            }
            brick_rect := rl.Rectangle {
                f32(BRICK_PAD + i * (BRICK_WIDTH + BRICK_PAD) + BRICK_WIDTH - BRICK_COLS*BRICK_PAD/2),
                f32(BRICK_TOP + j * (BRICK_HEIGHT + BRICK_PAD)),
                BRICK_WIDTH,
                BRICK_HEIGHT
            }
            collision_normal = check_collision_ball_rect(brick_rect)
            if collision_normal != 0 {
                // Collision with a brick
                bricks[i][j] = false
                ball_dir = linalg.normalize(linalg.reflect(ball_dir, linalg.normalize(collision_normal)))
                score += 1
                return
            }
        }
    }
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Odin Brick Breaker")
    rl.SetTargetFPS(500);

    restart()

    for !rl.WindowShouldClose() {
        if rl.IsKeyDown(.LEFT) {
            move_direction = {-1, 0}
        }
        if rl.IsKeyDown(.A) {
            move_direction = {-1, 0}
        }
        if rl.IsKeyDown(.RIGHT) {
            move_direction = {1, 0}
        }
        if rl.IsKeyDown(.D) {
            move_direction = {1, 0}
        }

        if game_over {
            if rl.IsKeyPressed(.ENTER) {
                restart()
            }
        } else if paused {
            if rl.IsKeyPressed(.SPACE) {
                paused = false
            }
        } else {
            tick_timer -= rl.GetFrameTime()
            fmt.printfln("%v", rl.GetFPS())
        }

        if tick_timer <= 0 {
            prev_ball_pos = ball_pos
            player_paddle_pos += move_direction * PADDLE_SPEED
            player_paddle_pos.x = rl.Clamp(player_paddle_pos.x, 0, WINDOW_WIDTH - PADDLE_WIDTH)
            move_direction = {0, 0}

            ball_pos += ball_dir * BALL_SPEED

            tick_timer = TICK_RATE + tick_timer

            check_collisions()
            if ball_pos.y - BALL_SIZE < 0 {
                ball_dir.y *= -1
            } else if ball_pos.y + BALL_SIZE > WINDOW_HEIGHT {
                game_over = true
            }
            if ball_pos.x - BALL_SIZE < 0 || ball_pos.x + BALL_SIZE > WINDOW_WIDTH {
                ball_dir.x *= -1
            }
        }

        rl.BeginDrawing()
        rl.ClearBackground({0, 0, 0, 255})

        player_paddle := rl.Rectangle {
            player_paddle_pos.x,
            player_paddle_pos.y,
            PADDLE_WIDTH,
            PADDLE_HEIGHT,
        }

        rl.DrawRectangleRec(player_paddle, rl.WHITE)

        rl.DrawCircle(
            i32(ball_pos.x),
            i32(ball_pos.y),
            BALL_SIZE,
            rl.WHITE,
        )
        
        for i in 0..<BRICK_COLS {
            for j in 0..<BRICK_ROWS {
                if !bricks[i][j] {
                    continue
                }
                brick_rect := rl.Rectangle {
                    f32(BRICK_PAD + i * (BRICK_WIDTH + BRICK_PAD) + BRICK_WIDTH - BRICK_COLS*BRICK_PAD/2),
                    f32(BRICK_TOP + j * (BRICK_HEIGHT + BRICK_PAD)),
                    BRICK_WIDTH,
                    BRICK_HEIGHT
                }

                rl.DrawRectangleRec(brick_rect, rl.WHITE)
            }
        }
        
        if game_over {
            rl.DrawText("Game Over!", 4, 4, 25, rl.RED)
            rl.DrawText("Press Enter to restart", 4, 30, 15, rl.WHITE)
        } else if paused {
            rl.DrawText("Paused", 4, 4, 25, rl.RED)
            rl.DrawText("Press Space to unpause", 4, 30, 15, rl.WHITE)
        }
        score_str := fmt.ctprintf("Score: %v", score)
        rl.DrawText(score_str, WINDOW_WIDTH - 175, WINDOW_HEIGHT -45, 40, rl.GRAY)
        rl.EndDrawing()
        free_all(context.temp_allocator)
    }

    rl.CloseWindow()
}