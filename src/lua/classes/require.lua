package.path = 'src/lua/classes/?/?.lua;' .. package.path

require('classes/prototype')    ---DO NOT REMOVE THIS
require('classes/RenderObj/RenderObj')
require('classes/HitBoxObj/HitBoxObj')
require('classes/BaseObj/BaseObj')
require('classes/MapObj/MapObj')
require('classes/CameraObj/CameraObj')
require('classes/MovableObj/MovableObj')