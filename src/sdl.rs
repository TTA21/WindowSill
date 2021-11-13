extern crate sdl2;

pub extern crate hlua;

pub use hlua::Lua;

use sdl2::pixels::Color;
use sdl2::render::{Canvas};
use sdl2::video::{Window};
use sdl2::EventPump;
use sdl2::Sdl;
use sdl2::rect::{Rect};

use sdl2::image::{LoadTexture};
use sdl2::render::{Texture, TextureCreator};
use std::borrow::Borrow;
use std::collections::HashMap;
use std::hash::Hash;
use std::rc::Rc;

pub struct Sdl2Instance{
    pub sdl_context: Sdl,
    pub canvas: Canvas<Window>,
    pub event_pump: EventPump,
}

pub struct SpriteObj{
    pub alpha: u8,
    pub rect: Rect,
    pub anim_stage: u32,
    pub texture_id: u32
}

pub struct WindowVars{
    pub name: String,
    pub width: u32,
    pub height: u32
}

pub fn sdl_init(window_vars: &WindowVars) -> Sdl2Instance{
    let sdl_context = sdl2::init().unwrap();
    let video_subsystem = sdl_context.video().unwrap();

    let window = video_subsystem.window(
                                            &window_vars.name, 
                                            window_vars.width, 
                                            window_vars.height
                                        )
        .position_centered()
        .build()
        .unwrap();
    
    let mut canvas = window.into_canvas().build().unwrap();
    canvas.set_draw_color(Color::RGB(0, 0, 0));
    canvas.clear();
    canvas.present();

    let event_pump = sdl_context.event_pump().unwrap();

    return Sdl2Instance{
        sdl_context: sdl_context,
        canvas: canvas,
        event_pump: event_pump,
    };

}
/*
    @load_sprite_name_table()
    Gets the names of the sprites that will actually be loaded in
*/
pub fn load_sprite_name_table(mut lua: Lua) -> (Lua, Vec::<String>){

    let mut names = Vec::<String>::new();

    {
        let mut name_table: hlua::LuaTable<_> = lua.get("texturesToBeLoaded").unwrap();
        for (_k,v) in name_table.iter::<i32, String>().filter_map(|e| e){
            println!("Texture To Load: {}", &v);
            names.push(v);
        }
    }

    return (lua, names);

}

    /*
        Returns pressed keyboard keys in a HashMap and mouse position and buttons in a MouseState.
        Only 4 keyboard keys can be detected at any time.
    */
pub fn get_input(mut events: sdl2::EventPump) -> (
    sdl2::EventPump, 
    std::collections::HashSet<sdl2::keyboard::Keycode>,
    sdl2::mouse::MouseState,
    bool
){
    //WARNING: This should only be run in the thread that initialized the video subsystem, 
    //  and for extra safety, you should consider only doing those things on the main thread in any case.
    //https://github.com/Rust-SDL2/rust-sdl2/issues/835

    let mut quit_event = false;
    for event in events.poll_iter() {
        if let sdl2::event::Event::Quit { .. } = event { quit_event = true;};
    }

    let keys: std::collections::HashSet<sdl2::keyboard::Keycode> = events
            .keyboard_state()
            .pressed_scancodes()
            .filter_map(sdl2::keyboard::Keycode::from_scancode)
            .collect();

    let mouse_pos = events.mouse_state();

    return (events, keys, mouse_pos, quit_event);
}

/*
    @send_keyboard_state_to_lua()
    Sends the name of the pressed keyboard keys to the Lua VM.
    "A", "B", "LEft Shift", etc
 */
pub fn send_keyboard_state_to_lua(
    mut lua: Lua, 
    pressed_keys: std::collections::HashSet<sdl2::keyboard::Keycode>
) -> Lua {
    {
        let mut array = lua.empty_array("keysPressed");
        let mut iter: u8 = 0;
        for key in pressed_keys{
            array.set(iter, key.name());
            iter += 1;
        }
    }
    return lua;
}

/*
    @send_mouse_state_to_lua()
    Sends the name of the pressed mouse buttons and 
        coordinates of the mouse relative to the screen to the Lua VM.
 */
pub fn send_mouse_state_to_lua(mut lua: Lua, mouse: sdl2::mouse::MouseState) -> Lua {
    {
        let mut array = lua.empty_array("mouse");
        array.set("X", mouse.x());
        array.set("Y", mouse.y());
        array.set("LMB", mouse.left());
        array.set("RMB", mouse.right());
        array.set("MMB", mouse.middle());
    }
    return lua;
}

/* 
    Get renderItems that have a true 'allowRender'
*/
pub fn get_render_items(mut lua: Lua) -> (Lua, Vec::<SpriteObj>){

    let mut destinations = Vec::<SpriteObj>::new();

    {
        let obj_table_size: u32 = lua.execute("return #currentCameraRenderItems").unwrap();
        let mut obj_tables: hlua::LuaTable<_> = lua.get("currentCameraRenderItems").unwrap();

        for index in 0..obj_table_size{
            let mut obj: hlua::LuaTable<_> = obj_tables.get(index+1).unwrap();

            if obj.get::<bool,_>("allowRender").unwrap() {

                let dest = SpriteObj{
                    alpha: obj.get::<u8,_>("alpha").unwrap(),
                    anim_stage: obj.get::<u32,_>("animStage").unwrap(),
                    texture_id: obj.get::<u32,_>("textureId").unwrap(),
                    rect: sdl2::rect::Rect::new(
                        obj.get::<i32,_>("posX").unwrap(), 
                        obj.get::<i32,_>("posY").unwrap(), 
                        obj.get::<u32,_>("width").unwrap() * obj.get::<u32,_>("scale").unwrap(), 
                        obj.get::<u32,_>("height").unwrap() * obj.get::<u32,_>("scale").unwrap()
                    )
                };
                destinations.push(dest);

            }
        }
    }
    
    return (lua, destinations);
}

pub fn render_frame(
    mut canvas: Canvas<Window>,
    textures: &Vec::<(u32, Rc<Texture>, Rect)>,
    game_obj_dest: Vec::<SpriteObj>
)-> Canvas<Window>{

    //Set BackGround
    canvas.set_draw_color(sdl2::pixels::Color::RGB(0, 0, 0));
    canvas.clear();

    for obj_dest in game_obj_dest{
        let mut sel_texture: &(u32, Rc<Texture>, Rect) = &textures[0];
        let mut texture_found = false;

        for texture in textures{
            if texture.0 == obj_dest.texture_id{
                sel_texture = texture;
                texture_found = true;
                break;
            }
        }

        let mut orig = sel_texture.2;
        orig.x = orig.x + (orig.w * obj_dest.anim_stage as i32);
        
        if texture_found{
            canvas.copy(&sel_texture.1, orig, obj_dest.rect).expect("Could not copy");
        }
    }

    //Present the final picture
    canvas.present();

    return canvas;
}

/////////////////////////////////////////////////
pub type TextureManager<'l, T> = ResourceManager<'l, String, Texture<'l>, TextureCreator<T>>;

// Generic struct to cache any resource loaded by a ResourceLoader
pub struct ResourceManager<'l, K, R, L>
where
    K: Hash + Eq,
    L: 'l + ResourceLoader<'l, R>,
{
    loader: &'l L,
    cache: HashMap<K, Rc<R>>,
}

impl<'l, K, R, L> ResourceManager<'l, K, R, L>
where
    K: Hash + Eq,
    L: ResourceLoader<'l, R>,
{
    pub fn new(loader: &'l L) -> Self {
        ResourceManager {
            cache: HashMap::new(),
            loader: loader,
        }
    }

    // Generics magic to allow a HashMap to use String as a key
    // while allowing it to use &str for gets
    pub fn load<D>(&mut self, details: &D) -> Result<Rc<R>, String>
    where
        L: ResourceLoader<'l, R, Args = D>,
        D: Eq + Hash + ?Sized,
        K: Borrow<D> + for<'a> From<&'a D>,
    {
        self.cache.get(details).cloned().map_or_else(
            || {
                let resource = Rc::new(self.loader.load(details)?);
                self.cache.insert(details.into(), resource.clone());
                Ok(resource)
            },
            Ok,
        )
    }
}

// TextureCreator knows how to load Textures
impl<'l, T> ResourceLoader<'l, Texture<'l>> for TextureCreator<T> {
    type Args = str;
    fn load(&'l self, path: &str) -> Result<Texture, String> {
        println!("LOADED A TEXTURE");
        self.load_texture(path)
    }
}

// Generic trait to Load any Resource Kind
pub trait ResourceLoader<'l, R> {
    type Args: ?Sized;
    fn load(&'l self, data: &Self::Args) -> Result<R, String>;
}

// Information needed to load a Font
#[derive(PartialEq, Eq, Hash)]
pub struct FontDetails {
    pub path: String,
    pub size: u16,
}

impl<'a> From<&'a FontDetails> for FontDetails {
    fn from(details: &'a FontDetails) -> FontDetails {
        FontDetails {
            path: details.path.clone(),
            size: details.size,
        }
    }
}
