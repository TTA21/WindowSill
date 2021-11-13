package.path = '?.lua;' .. package.path
package.path = 'src/?.lua;' .. package.path
package.path = 'src/lua/?.lua;' .. package.path
package.path = 'src/lua/classes/?/?.lua;' .. package.path
package.path = 'src/lua/stages/?/?.lua;' .. package.path

---Might want to increase the depth of the searches above


require('textures')
require('classes/require')
require('stages/require')