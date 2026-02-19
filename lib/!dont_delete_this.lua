local encoding = require "encoding" --К переменным

encoding.default = 'CP1251'
u8 = encoding.UTF8
local samp = getModuleHandle("samp.dll")

if samp == 0 then return end

local memory = require("memory")

local function write_string(address, value, count)
    local str = value..("\x00"):rep(count-#value)
    memory.copy(address, memory.strptr(str), #str, true)
end

write_string(samp + 0xD396C, "SA:MP {adff2f}Fatality R1{A9C4E4} started  ", 43)
write_string(samp + 0xD3A78, "Server closed the connection.", 30)
write_string(samp + 0xD3998, "Connect to{adff2f}%s:%d", 23)
write_string(samp + 0xD3A98, "Пароль для подключения к серверу неверный", 23)
write_string(samp + 0xD3B8C, "пенис", 31)
write_string(samp + 0xD3D8C, "Connected to {adff2f}%.64s", 29)
write_string(samp + 0xD3A58, "Сервер полон..", 24)
write_string(samp + 0xD3AB0, "Сервер не отвечает..", 37)
write_string(samp + 0xD47E4, "Соединение с сервером потеряно", 27)
write_string(samp + 0xD3A10, "Ваш IP адрес заблокирован на сервере", 32)
write_string(samp + 0xD3B34, "Перезагрузка сервера, подождите..", 27)
write_string(samp + 0xD78C4, "Включена серверная музыка: %s", 18)
write_string(samp + 0xD83A8, "[Айди: %d, Тип: %d Подвид: %d Хп: %.1f Предзагружен: %u]\nДистанция: %.2fm\nПассажирок: %u\nКлиентская Позиция: %.3f,%.3f,%.3f\nСерверная Позиция: %.3f,%.3f,%.3f", 139)