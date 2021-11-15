mod sdl;
mod lua;

use std::{
    thread,
    time::{Duration, Instant},
};

//const wait_time: std::time::Duration = Duration::from_millis(1);   ///60fps = 16.666666666666668 millis

const render_time: u128 = 15; //in millis
const calc_time: std::time::Duration = Duration::from_millis(1);

/*
    @main_loop()
    Reponsible for every frame, if this loop breaks the game ends.
*/

fn main_loop(
    mut lua: lua::Lua,
    window_vars: sdl::WindowVars,
    mut sdl2_instance: sdl::Sdl2Instance,
){
    
    let mut error_enum = 0; //If any error, error_enum > 0, error value depends on error type
    let mut game_continue = true;

    //Setup Stuff

    //VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    //Cant find a way to do this in a function, blasted TextureManager has a lifetime
    let texture_creator = sdl2_instance.canvas.texture_creator();
    let mut texture_manager = sdl::TextureManager::new(&texture_creator);
    let mut sprite_data = Vec::<(u32, std::rc::Rc<sdl2::render::Texture>, sdl2::rect::Rect)>::new();

    let ret = sdl::load_sprite_name_table(lua);
    lua = ret.0;
    let sprite_names = ret.1;

    {
        let mut sprite_tables: hlua::LuaTable<_> = lua.get("textures").unwrap();

        for name in sprite_names{
            let mut texture: hlua::LuaTable<_> = sprite_tables.get(name).unwrap();

            let texture_path = texture.get::<String,_>("spritePath").unwrap();
            let texture_man = texture_manager.load(&texture_path).unwrap();

            let width = texture.get::<u32,_>("width").unwrap();
            let height = texture.get::<u32,_>("height").unwrap();
            let origin = sdl2::rect::Rect::new(0, 0, width, height);

            let identifier = texture.get::<u32,_>("identifier").unwrap();

            println!("Loaded Sprite:id{}, {}, w{}, h{}", identifier, &texture_path, width, height);

            sprite_data.push((identifier, texture_man, origin));
        }

    }
    //AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    //Textures and sprite data will be brought from Lua Vm to rust for caching

    lua.execute::<()>("setup()").unwrap();

    let mut render_start = Instant::now();
    let mut calc_start = Instant::now();

    while game_continue == true {

        let render_runtime = render_start.elapsed();
        let calc_runtime = calc_start.elapsed();

        //Game Loop
        if calc_runtime.as_millis() > calc_time.as_millis() {
            calc_start = Instant::now();
            //Get the currentStageFunction name for the stage selection
            let main_function = lua.get::<String, _>("currentStageFunction").unwrap();

            //main_function refers to the current stage's main function
            lua.execute::<()>(&(main_function + "()")).unwrap();

            //Get keyboard and mouse data
            let ret = sdl::get_input(sdl2_instance.event_pump);
            sdl2_instance.event_pump = ret.0;

            //Send the input data to the Lua VM
            lua = sdl::send_keyboard_state_to_lua(lua, ret.1);
            lua = sdl::send_mouse_state_to_lua(lua, ret.2);

            if ret.3 {break};
        
            //Check if the game should quit
            game_continue = lua.get::<bool, _>("shouldGameContinue").unwrap();

            if let Some(remaining) = calc_runtime.checked_sub(calc_time) {
                thread::sleep(calc_time);
            }
        }

        if render_runtime.as_millis() > render_time {
            render_start = Instant::now();
            //Get the suff to render
            let ret = sdl::get_render_items(lua);
            lua = ret.0;
            let sprite_objs = ret.1;

            //Render the sprites
            sdl2_instance.canvas = sdl::render_frame(sdl2_instance.canvas, &sprite_data, sprite_objs);
        }

    }

    if error_enum == 0 {
        println!("\n\nGame Exited normally, have a great day!");
    }else{
        println!("\n\nGame Exited with error code {}!", error_enum);
    }

}

/*
    @main()
    Initalizes Lua VM, SDL2 and prepares window variables.
*/

fn main(){
    let mut lua = lua::init_lua();      //Start Lua VM
    let window_vars: sdl::WindowVars;   //Create Window Variables for convenience

    {   //Initialise WindowVars with data from Lua VM
        let mut window_vars_table: hlua::LuaTable<_> = lua.get("windowOptions").unwrap();

        window_vars = sdl::WindowVars{
            name: window_vars_table.get("name").unwrap(),
            width: window_vars_table.get("width").unwrap(),
            height: window_vars_table.get("height").unwrap(),
        };
    }

    println!("Window: '{}', {}x{}", &window_vars.name, window_vars.width, window_vars.height);

    let sdl2_instance: sdl::Sdl2Instance = sdl::sdl_init(&window_vars); //Initiate SDL2 Game

    main_loop(lua, window_vars,sdl2_instance);  //Begin Game loop

}

/////////////////////////////////////////////////
