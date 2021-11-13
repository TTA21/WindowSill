pub extern crate hlua;

pub use hlua::Lua;
pub use std::fs::File;

const LUA_FILE_PREFIX: &str = "src/lua/";
const LUA_MAIN_FILE: &str = "main.lua";

pub fn init_lua() -> Lua<'static>{
    let mut lua = Lua::new();   //Start new VM
    lua.openlibs();             //Import std libs

    let script = File::open(LUA_FILE_PREFIX.to_owned() + LUA_MAIN_FILE).unwrap(); 
    lua.execute_from_reader::<(), _>(script).unwrap();  //Load main lua file

    return lua;
}