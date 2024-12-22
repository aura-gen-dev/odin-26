package brick_breaker

import "core:fmt"

import rl "vendor:raylib"
import b2 "vendor:box2d"

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
            fmt.printfln("%v", rl.GetFPS())
        }

        if tick_timer <= 0 {
            player_paddle_pos += move_direction * PADDLE_SPEED
            player_paddle_pos.x = rl.Clamp(player_paddle_pos.x, 0, WINDOW_WIDTH - PADDLE_WIDTH)
            move_direction = {0, 0}

            ball_pos += ball_dir * BALL_SPEED
            if ball_pos.y - BALL_SIZE < 0 || ball_pos.y + BALL_SIZE > WINDOW_HEIGHT {
                ball_dir.y *= -1
            }
            if ball_pos.x - BALL_SIZE < 0 || ball_pos.x + BALL_SIZE > WINDOW_WIDTH {
                ball_dir.x *= -1
            }

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

        for i in 0..<BRICK_ROWS {
            for j in 0..<BRICK_COLS {
                rl.DrawRectangle(
                    i32(BRICK_PAD + j * (BRICK_WIDTH + BRICK_PAD) + BRICK_WIDTH - BRICK_COLS*BRICK_PAD/2),
                    i32(BRICK_TOP + i * (BRICK_HEIGHT + BRICK_PAD)),
                    BRICK_WIDTH,
                    BRICK_HEIGHT,
                    rl.WHITE,
                )
            }
        }

        rl.EndDrawing()
        free_all(context.temp_allocator)
    }

    rl.CloseWindow()
}