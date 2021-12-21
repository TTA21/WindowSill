package.path = 'src/lua/classes/?/?.lua;' .. package.path

require('classes/prototype')    ---DO NOT REMOVE THIS
require('classes/RenderObj/RenderObj')
require('classes/HitBoxObj/HitBoxObj')
require('classes/BaseObj/BaseObj')
require('classes/MapObj/MapObj')
require('classes/CameraObj/CameraObj')
require('classes/MovableObj/MovableObj')
require('classes/QueueObj/QueueObj')
require('classes/BaseObjAttachedObj/BaseObjAttachedObj')
require('classes/MovableObjAttachedObj/MovableObjAttachedObj')
require('classes/AttachableDialogObj/FontObj')
require('classes/AttachableDialogObj/AttachableDialogObj')
require('classes/AttachableMenuObj/ButtonMenuComponentObj')
require('classes/AttachableMenuObj/StringInputMenuComponentObj')
require('classes/AttachableMenuObj/SliderMenuComponentObj')
require('classes/AttachableMenuObj/AttachableMenuObj')

