package brick_breaker

import rl "vendor:raylib"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 600
TICK_RATE :: 0.017
Vec2f32 :: [2]f32
PADDLE_WIDTH :: 100
PADDLE_HEIGHT :: 10
PADDLE_PAD :: 25
PADDLE_SPEED :: 3
BALL_SIZE :: 10
BALL_SPEED :: 4

tick_timer: f32 = TICK_RATE
game_over: bool
paused: bool

player_paddle_start_pos: Vec2f32 = {WINDOW_WIDTH / 2 - PADDLE_WIDTH / 2, WINDOW_HEIGHT - PADDLE_PAD - PADDLE_HEIGHT / 2}
player_paddle_pos: Vec2f32
move_direction: Vec2f32
ball_pos: Vec2f32
ball_dir: Vec2f32

restart :: proc() {
    game_over = false
    paused = true
    move_direction = {0, 0}
    player_paddle_pos = player_paddle_start_pos
    ball_pos = player_paddle_pos + {PADDLE_WIDTH / 2, -BALL_SIZE}
    x :=rl.GetRandomValue(-9, 9)
    y := rl.GetRandomValue(-9, -5)
    ball_dir = {f32(x), f32(y)}
    ball_dir = rl.Vector2Normalize(ball_dir)
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Odin Brick Breaker")

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
        }

        if tick_timer <= 0 {
            player_paddle_pos += move_direction * PADDLE_SPEED
            player_paddle_pos.x = rl.Clamp(player_paddle_pos.x, 0, WINDOW_WIDTH - PADDLE_WIDTH)
            move_direction = {0, 0}

            ball_pos += ball_dir * BALL_SPEED

            tick_timer = TICK_RATE + tick_timer
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

        rl.EndDrawing()
        free_all(context.temp_allocator)
    }

    rl.CloseWindow()
}