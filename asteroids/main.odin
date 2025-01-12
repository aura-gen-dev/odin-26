package asteroids

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Odin Asteroids")
    rl.SetTargetFPS(500);

    game := init_game()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        // fmt.printfln("%v", rl.GetFPS())
        handle_input(&game)
        handle_update(&game, dt)
        handle_render(&game)
    }
}