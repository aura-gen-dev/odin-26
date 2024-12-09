package pong

import rl "vendor:raylib"
import "core:fmt"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 600
TICK_RATE :: 0.017
Vec2f32 :: [2]f32
PADDLE_WIDTH :: 10
PADDLE_HEIGHT :: 100
PADDLE_PAD :: 15
PADDLE_SPEED :: 3
BALL_SPEED :: 4
BALL_SIZE :: 10

tick_timer: f32 = TICK_RATE
move_direction: Vec2f32
game_over: bool
ball_start_pos: Vec2f32 = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2}
ball_pos := ball_start_pos
ball_dir: Vec2f32
ball_speed: f32 = BALL_SPEED
player_paddle_start_pos: Vec2f32 = {WINDOW_WIDTH - PADDLE_WIDTH - PADDLE_PAD, WINDOW_HEIGHT / 2 - PADDLE_HEIGHT / 2}
opp_paddle_start_pos: Vec2f32 = {PADDLE_PAD, WINDOW_HEIGHT / 2 - PADDLE_HEIGHT / 2}
player_paddle_pos: Vec2f32
opp_paddle_pos: Vec2f32
score: [2]int = {0, 0}
player_score: bool = false
opp_score: bool = false

restart :: proc() {
    ball_pos = ball_start_pos
    x :=rl.GetRandomValue(-9, 9)
    y := rl.GetRandomValue(5, 9)
    ball_dir = {f32(x), f32(y)}
    ball_dir = rl.Vector2Normalize(ball_dir)

    player_paddle_pos = player_paddle_start_pos
    opp_paddle_pos = opp_paddle_start_pos
    game_over = false
    player_score = false
    opp_score = false
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Odin Pong")

    restart()

    for !rl.WindowShouldClose() {
        if rl.IsKeyDown(.UP) {
            move_direction = {0, -1}
        }
        if rl.IsKeyDown(.W) {
            move_direction = {0, -1}
        }
        if rl.IsKeyDown(.DOWN) {
            move_direction = {0, 1}
        }
        if rl.IsKeyDown(.S) {
            move_direction = {0, 1}
        }

        if game_over {
            if rl.IsKeyPressed(.ENTER) {
                restart()
            }
        } else {
            tick_timer -= rl.GetFrameTime()
        }

        if game_over {
            if player_score {
                rl.DrawText("Player Scores!", 4, 4, 25, rl.RED)
            } else {
                rl.DrawText("Opponent Scores!", 4, 4, 25, rl.RED)
            }
            rl.DrawText("Press Enter to restart", 4, 30, 15, rl.WHITE)
        }

        if tick_timer <= 0 {
            tick_timer = TICK_RATE + tick_timer

            // Ball
            ball_pos += ball_dir * ball_speed
            ball_speed *= 1.0001
            if ball_pos.y - BALL_SIZE < 0 || ball_pos.y + BALL_SIZE > WINDOW_HEIGHT {
                ball_dir.y *= -1
            }
            if ball_pos.x - BALL_SIZE < 0 || ball_pos.x + BALL_SIZE > WINDOW_WIDTH {
                game_over = true
                if ball_pos.x - BALL_SIZE < 0 {
                    player_score = true
                    score[1] += 1
                } else{
                    opp_score = true
                    score[0] += 1
                }
            }
            
            // Player Paddle
            player_paddle_pos += move_direction * PADDLE_SPEED
            player_paddle_pos.y = rl.Clamp(player_paddle_pos.y, 0, WINDOW_HEIGHT - PADDLE_HEIGHT)
            move_direction = {0, 0}

            // Opponent Paddle
            opp_direction: Vec2f32
            dir: Vec2f32

            if ball_dir.x < 0 {
                dir = ball_pos - (opp_paddle_pos + {0, PADDLE_HEIGHT / 2})
            } else {
                dir = opp_paddle_start_pos - opp_paddle_pos
            }

            if dir.y < -5 {
                opp_direction = {0, -1}
            } else if dir.y > 5 {
                opp_direction = {0, 1}
            } else {
                opp_direction = {0, 0}
            }
            
            opp_paddle_pos += opp_direction * PADDLE_SPEED
            opp_paddle_pos.y = rl.Clamp(opp_paddle_pos.y, 0, WINDOW_HEIGHT - PADDLE_HEIGHT)

            // Collision
            if ball_pos.x + BALL_SIZE > player_paddle_pos.x && ball_pos.x - BALL_SIZE < player_paddle_pos.x + PADDLE_WIDTH {
                if ball_pos.y + BALL_SIZE > player_paddle_pos.y && ball_pos.y - BALL_SIZE < player_paddle_pos.y + PADDLE_HEIGHT {
                    ball_dir.x *= -1
                }
            }

            if ball_pos.x + BALL_SIZE > opp_paddle_pos.x && ball_pos.x - BALL_SIZE < opp_paddle_pos.x + PADDLE_WIDTH {
                if ball_pos.y + BALL_SIZE > opp_paddle_pos.y && ball_pos.y - BALL_SIZE < opp_paddle_pos.y + PADDLE_HEIGHT {
                    ball_dir.x *= -1
                }
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

        opp_paddle := rl.Rectangle {
            opp_paddle_pos.x,
            opp_paddle_pos.y,
            PADDLE_WIDTH,
            PADDLE_HEIGHT,
        }
        
        rl.DrawRectangleRec(player_paddle, rl.WHITE)
        rl.DrawRectangleRec(opp_paddle, rl.WHITE)
        rl.DrawCircle(
            i32(ball_pos.x),
            i32(ball_pos.y),
            BALL_SIZE,
            rl.WHITE,
        )

        score_str := fmt.ctprintf("Oponent Score: %v, Player Score: %v", score[0], score[1])
        rl.DrawText(score_str, WINDOW_WIDTH / 2 - 175, 25, 20, rl.GRAY)

        rl.EndDrawing()
        free_all(context.temp_allocator)
    }

    rl.CloseWindow()
}