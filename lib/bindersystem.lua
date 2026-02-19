local imgui = require('mimgui')
local encoding = require('encoding')
encoding.default = 'CP1251'
local ffi = require('ffi')
local u8 = encoding.UTF8

local BinderSystem = {}


function getMyNickName()
    return sampGetPlayerNickname(getMyId())
end

function getMyId()
    return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
end

BinderSystem.variables = {
    mynick = {
        func = function() return getMyNickName() end,
        description = u8"Возвращает никнейм игрока",
        example = u8"chat(/me {mynick} поправил форму) -- подставит ваш ник"
    },
    myid = {
        func = function() return getMyId() end,
        description = u8"Возвращает ID игрока",
        example = u8"chat(/id {myid}) -- подставит ваш ID"
    }
}

function BinderSystem.registerVariable(name, callback, description, example)
    if type(name) ~= 'string' then
        error('Variable name must be a string')
        return false
    end
    if type(callback) ~= 'function' then
        error('Variable callback must be a function')
        return false
    end
    if BinderSystem.variables[name] then
        error('Variable ' .. name .. ' already exists')
        return false
    end
    
    BinderSystem.variables[name] = {
        func = callback,
        description = description or u8"Нет описания",
        example = example or u8"Нет примера"
    }
    return true
end

function BinderSystem.getVariableDescription(name)
    if BinderSystem.variables[name] then
        return BinderSystem.variables[name].description
    end
    return u8"Переменная не найдена"
end

function BinderSystem.getVariableExample(name)
    if BinderSystem.variables[name] then
        return BinderSystem.variables[name].example
    end
    return u8"Пример не найден"
end

function BinderSystem.getVariableInfo(name)
    if BinderSystem.variables[name] then
        return {
            description = BinderSystem.variables[name].description,
            example = BinderSystem.variables[name].example
        }
    end
    return nil
end

function BinderSystem.getVariablesWithInfo()
    local variables = {}
    for name, data in pairs(BinderSystem.variables) do
        table.insert(variables, {
            name = name,
            description = data.description,
            example = data.example
        })
    end
    return variables
end

function BinderSystem.processVariables(text)
    for name, data in pairs(BinderSystem.variables) do
        local pattern = "{" .. name .. "}"
        text = text:gsub(pattern, tostring(data.func()))
    end
    return text
end

BinderSystem.commands = {
    chat = {
        func = function(message)
            message = message:gsub("{mynick}", tostring(getMyNickName()))
            message = message:gsub("{myid}", tostring(getMyId()))
            sampSendChat(message)
        end,
        description = u8"Отправка сообщения в чат",
        example = u8"chat(/me поправил форму)"
    },
    input = {
        func = function(message)
            message = message:gsub("{mynick}", tostring(getMyNickName()))
            message = message:gsub("{myid}", tostring(getMyId()))
            sampSetChatInputEnabled(true)
            sampSetChatInputText(message)
        end,
        description = u8"Ввод текста в строку чата",
        example = u8"input(/time)"
    },
    notif = {
        func = function(message)
            message = message:gsub("{mynick}", tostring(getMyNickName()))
            message = message:gsub("{myid}", tostring(getMyId()))
            sampAddChatMessage(message, -1)
        end,
        description = u8"Вывод уведомления в чат",
        example = u8"notif(Привет, {mynick}!)"
    },
    wait = {
        func = function(ms)
            ms = tonumber(ms)
            if type(ms) == "number" and math.floor(ms) == ms then
                wait(ms)
            else
                sampAddChatMessage('{414f93}[Binder]: {FFFFFF}wait(not int)', -1)
            end
        end,
        description = u8"Ожидание указанное количество миллисекунд",
        example = u8"wait(1000) -- ждать 1 секунду"
    }
}

function BinderSystem.registerCommand(name, callback, description, example)
    if type(name) ~= 'string' then
        error('Command name must be a string')
        return false
    end
    if type(callback) ~= 'function' then
        error('Command callback must be a function')
        return false
    end
    if BinderSystem.commands[name] then
        error('Command ' .. name .. ' already exists')
        return false
    end
    
    BinderSystem.commands[name] = {
        func = callback,
        description = description or u8"Нет описания",
        example = example or u8"Нет примера"
    }
    return true
end

function BinderSystem.getCommandDescription(name)
    if BinderSystem.commands[name] then
        return BinderSystem.commands[name].description
    end
    return u8"Команда не найдена"
end

function BinderSystem.getCommandExample(name)
    if BinderSystem.commands[name] then
        return BinderSystem.commands[name].example
    end
    return u8"Пример не найден"
end

function BinderSystem.getCommandInfo(name)
    if BinderSystem.commands[name] then
        return {
            description = BinderSystem.commands[name].description,
            example = BinderSystem.commands[name].example
        }
    end
    return nil
end

function BinderSystem.getCommandsWithInfo()
    local commands = {}
    for name, data in pairs(BinderSystem.commands) do
        table.insert(commands, {
            name = name,
            description = data.description,
            example = data.example
        })
    end
    return commands
end

BinderSystem.hotkeys = {
    editing = false,
    current_id = nil,
    callbacks = {},
    last_key_state = {},
    keys = {
        [1] = 'LButton', [2] = 'RButton', [3] = 'Cancel', [4] = 'MButton', [5] = 'XButton1', [6] = 'XButton2',
        [8] = 'Back', [9] = 'Tab', [12] = 'Clear', [13] = 'Return', [16] = 'Shift', [17] = 'Control',
        [18] = 'Menu', [19] = 'Pause', [20] = 'Capital', [21] = 'Kana', [23] = 'Junja', [24] = 'Final',
        [25] = 'Hanja', [27] = 'Escape', [28] = 'Convert', [29] = 'NonConvert', [30] = 'Accept',
        [31] = 'ModeChange', [32] = 'Space', [33] = 'Prior', [34] = 'Next', [35] = 'End', [36] = 'Home',
        [37] = 'Left', [38] = 'Up', [39] = 'Right', [40] = 'Down', [41] = 'Select', [42] = 'Print',
        [43] = 'Execute', [44] = 'Snapshot', [45] = 'Insert', [46] = 'Delete', [47] = 'Help',
        [48] = '0', [49] = '1', [50] = '2', [51] = '3', [52] = '4', [53] = '5', [54] = '6', [55] = '7',
        [56] = '8', [57] = '9', [65] = 'A', [66] = 'B', [67] = 'C', [68] = 'D', [69] = 'E', [70] = 'F',
        [71] = 'G', [72] = 'H', [73] = 'I', [74] = 'J', [75] = 'K', [76] = 'L', [77] = 'M', [78] = 'N',
        [79] = 'O', [80] = 'P', [81] = 'Q', [82] = 'R', [83] = 'S', [84] = 'T', [85] = 'U', [86] = 'V',
        [87] = 'W', [88] = 'X', [89] = 'Y', [90] = 'Z', [91] = 'LWin', [92] = 'RWin', [93] = 'Apps',
        [95] = 'Sleep', [96] = 'Numpad0', [97] = 'Numpad1', [98] = 'Numpad2', [99] = 'Numpad3',
        [100] = 'Numpad4', [101] = 'Numpad5', [102] = 'Numpad6', [103] = 'Numpad7', [104] = 'Numpad8',
        [105] = 'Numpad9', [106] = 'Multiply', [107] = 'Add', [108] = 'Separator', [109] = 'Subtract',
        [110] = 'Decimal', [111] = 'Divide', [112] = 'F1', [113] = 'F2', [114] = 'F3', [115] = 'F4',
        [116] = 'F5', [117] = 'F6', [118] = 'F7', [119] = 'F8', [120] = 'F9', [121] = 'F10',
        [122] = 'F11', [123] = 'F12', [144] = 'NumLock', [145] = 'ScrollLock'
    }
}

BinderSystem.hotkeys.ACTIVATION_TYPES = {
    [1] = "ON_PRESS",
    [2] = "ON_RELEASE"
}

function BinderSystem.hotkeys.register(id, key, callback, activation_type)
    BinderSystem.hotkeys.callbacks[id] = {
        key = key,
        callback = callback,
        activation_type = activation_type or 1
    }
end

function BinderSystem.hotkeys.checkActivation(key, activation_type)
    local current_state = isKeyDown(key)
    local last_state = BinderSystem.hotkeys.last_key_state[key] or false
    local result = false
    
    if activation_type == 0 then
        result = current_state
    elseif activation_type == 1 then
        result = current_state and not last_state
    elseif activation_type == 2 then
        result = not current_state and last_state
    end
    
    BinderSystem.hotkeys.last_key_state[key] = current_state
    return result
end

function BinderSystem.hotkeys.checkKeys(keys, activation_type)
    if type(keys) == 'number' then
        return BinderSystem.hotkeys.checkActivation(keys, activation_type)
    elseif type(keys) == 'table' then
        local all_pressed = true
        for _, key in ipairs(keys) do
            if not isKeyDown(key) then
                all_pressed = false
                break
            end
        end
        
        if all_pressed and #keys > 0 then
            return BinderSystem.hotkeys.checkActivation(keys[#keys], activation_type)
        end
    end
    return false
end

function BinderSystem.hotkeys.getActivationTypeName(activation_type)
    if activation_type == 1 then
        return u8"При нажатии"
    elseif activation_type == 2 then
        return u8"При отпускании"
    end
    return u8"Неизвестно"
end

function BinderSystem.hotkeys.unregister(id)
    BinderSystem.hotkeys.callbacks[id] = nil
end

function BinderSystem.hotkeys.isKeyDown(key)
    return isKeyDown(key)
end

function BinderSystem.hotkeys.getKeyName(key)
    return BinderSystem.hotkeys.keys[key] or 'Unknown'
end

function BinderSystem.hotkeys.getCurrentKey()
    if BinderSystem.hotkeys.editing then
        for key, _ in pairs(BinderSystem.hotkeys.keys) do
            if isKeyDown(key) then
                return key
            end
        end
    end
    return nil
end

function BinderSystem.hotkeys.getBindKeys(id)
    local callback = BinderSystem.hotkeys.callbacks[id]
    if not callback then 
        return u8"Не назначено"
    end
    
    local key = callback.key
    if type(key) == 'number' then
        if key == 0 then 
            return u8"Не назначено"
        end
        return BinderSystem.hotkeys.getKeyName(key)
    elseif type(key) == 'table' then
        if #key == 0 or (key[1] and key[1] == 0) then 
            return u8"Не назначено"
        end
        local names = {}
        for _, k in ipairs(key) do
            table.insert(names, BinderSystem.hotkeys.getKeyName(k))
        end
        return table.concat(names, ' + ')
    end
    return u8"Не назначено"
end

function BinderSystem.renderHotkeyButton(id, key, enabled)
    if not enabled then
        imgui.Text(u8'Активируйте бинд для назначения клавиши')
        return key
    end

    local width = 200
    local height = 25
    
    imgui.BeginGroup()
    imgui.Text(u8'Текущая клавиша: ' .. BinderSystem.hotkeys.getBindKeys(id))
    
    local current_callback = BinderSystem.hotkeys.callbacks[id]
    if current_callback then
        local current_type = current_callback.activation_type or 1
        local combo_label = BinderSystem.hotkeys.getActivationTypeName(current_type)
        
        imgui.PushItemWidth(150)
        if imgui.BeginCombo('##activation_type'..id, combo_label) then
            for type_id = 1, 2 do
                local is_selected = (type_id == current_type)
                if imgui.Selectable(BinderSystem.hotkeys.getActivationTypeName(type_id), is_selected) then
                    current_callback.activation_type = type_id
                    for _, binder in ipairs(BinderSystem.binders) do
                        if binder.id == id then
                            binder.activation_type = type_id
                            break
                        end
                    end
                    BinderSystem.saveBinders()
                end
                if is_selected then
                    imgui.SetItemDefaultFocus()
                end
            end
            imgui.EndCombo()
        end
        imgui.PopItemWidth()
    end
    
    local button_label = BinderSystem.hotkeys.editing and id == BinderSystem.hotkeys.current_id 
        and u8'Нажмите клавишу...' or u8'Сменить клавишу'
    
    if imgui.Button(button_label .. '##' .. id, imgui.ImVec2(width, height)) then
        BinderSystem.hotkeys.editing = true
        BinderSystem.hotkeys.current_id = id
    end
    
    imgui.EndGroup()
    return key
end

function BinderSystem.init(config_path)
    if not doesFileExist(config_path) then
        local file = io.open(config_path, 'w')
        if file then
            file:write('{"binders":[]}')
            file:close()
        end
    end
    
    BinderSystem.binders = BinderSystem.loadBinders(config_path)
    BinderSystem.config_path = config_path
    
    for i, binder in ipairs(BinderSystem.binders) do
        if binder.enabled then
            BinderSystem.hotkeys.register(binder.id, binder.key, function()
                if not sampIsCursorActive() then
                    lua_thread.create(function()
                        BinderSystem.execute_script(binder.text)
                    end)
                end
            end, binder.activation_type or 1)
        end
    end
end

function BinderSystem.loadBinders(config_path)
    local file = io.open(config_path, 'r')
    if file then
        local content = file:read('*all')
        file:close()
        local data = decodeJson(content)
        for k, v in ipairs(data.binders or {}) do
            local name = v.name and u8:decode(v.name) or u8'Бинд_'..k
            local text = v.text and u8:decode(v.text) or ''
            
            local binder = {
                enabled = v.enabled,
                text = text,
                key = v.key or 0,
                name = name,
                id = v.id or ('binder'..k),
                activation_type = tonumber(v.activation_type) or 1
            }
            binder.name_buffer = imgui.new.char[256](u8(name))
            data.binders[k] = binder
        end
        return data.binders or {}
    end
    return {}
end

function BinderSystem.saveBinders()
    local file = io.open(BinderSystem.config_path, 'w')
    if file then
        local bindersToSave = {}
        for k, v in ipairs(BinderSystem.binders) do
            bindersToSave[k] = {
                enabled = v.enabled,
                text = u8:encode(v.text),
                key = v.key,
                name = u8:encode(v.name),
                id = v.id,
                activation_type = v.activation_type
            }
        end
        file:write(encodeJson({binders = bindersToSave}))
        file:close()
    end
end

function BinderSystem.execute_script(script)
    local function unknown_command(command)
        sampAddChatMessage("{414f93}[Binder]: {FFFFFF}Unknown command: " .. command, -1)
    end

    local function find_matching_parenthesis(s, start_pos)
        local depth = 1
        for i = start_pos, #s do
            local char = s:sub(i, i)
            if char == "(" then
                depth = depth + 1
            elseif char == ")" then
                depth = depth - 1
                if depth == 0 then
                    return i
                end
            end
        end
        return nil
    end

    local function parse_and_execute(script)
        local pos = 1
        while pos <= #script do
            local start_func, end_func = script:find("(%w+)%s*%(", pos)
            if not start_func then break end
            
            local func_name = script:sub(start_func, end_func - 1)
            local start_param = end_func + 1
            local end_param = find_matching_parenthesis(script, start_param)
            if not end_param then break end

            local param = script:sub(start_param, end_param - 1)
            pos = end_param + 1
            
            param = BinderSystem.processVariables(param)
            
            if BinderSystem.commands[func_name] then
                BinderSystem.commands[func_name].func(param)
            else
                unknown_command(func_name .. "(" .. param .. ")")
            end
        end
    end
    parse_and_execute(script)
end

function BinderSystem.renderBinderTab()
    imgui.Text(u8'Система биндера')
    imgui.Separator()
    
    for i, binder in ipairs(BinderSystem.binders) do
        if not binder.name_buffer then
            binder.name_buffer = imgui.new.char[256](u8(binder.name))
        end
        
        if imgui.CollapsingHeader(u8(binder.name)..'##'..binder.id) then
            local enabled = imgui.new.bool(binder.enabled)
            local text = imgui.new.char[1024](u8(binder.text))
            
            imgui.PushItemWidth(200)
            if imgui.InputText(u8'Название бинда##input'..binder.id, binder.name_buffer, 256) then
            end
            imgui.PopItemWidth()
            
            imgui.SameLine()
            if imgui.Button(u8'Сохранить название##'..binder.id) then
                binder.name = u8:decode(ffi.string(binder.name_buffer))
                BinderSystem.saveBinders()
            end
            
            if imgui.Checkbox(u8'Активен##'..binder.id, enabled) then
                binder.enabled = enabled[0]
                if binder.enabled then
                    BinderSystem.hotkeys.register(binder.id, binder.key, function()
                        if not sampIsCursorActive() then
                            lua_thread.create(function()
                                BinderSystem.execute_script(binder.text)
                            end)
                        end
                    end, binder.activation_type or 1)
                else
                    BinderSystem.hotkeys.unregister(binder.id)
                end
                BinderSystem.saveBinders()
            end
            
            if imgui.InputTextMultiline(u8'Текст бинда##'..binder.id, text, 1024) then
                binder.text = u8:decode(ffi.string(text))
                BinderSystem.saveBinders()
            end
            
            local newKey = BinderSystem.renderHotkeyButton(binder.id, binder.key, binder.enabled)
            if newKey ~= binder.key then
                binder.key = newKey
                BinderSystem.saveBinders()
            end
            
            imgui.SameLine()
            if imgui.Button(u8'Удалить##'..binder.id) then
                BinderSystem.hotkeys.unregister(binder.id)
                table.remove(BinderSystem.binders, i)
                BinderSystem.saveBinders()
            end
            
            if imgui.Button(u8'Отправить##'..binder.id) and binder.enabled then
                lua_thread.create(function()
                    BinderSystem.execute_script(binder.text)
                end)
            end
        end
    end
    
    imgui.Separator()
    if imgui.Button(u8'Добавить новый бинд', imgui.ImVec2(150, 25)) then
        local newBindName = u8'Бинд_' .. (#BinderSystem.binders + 1)
        local newId = 'binder' .. (#BinderSystem.binders + 1)
        
        BinderSystem.hotkeys.unregister(newId)
        
        local newBinder = {
            enabled = false,
            text = '',
            key = 0,
            name = u8:decode(newBindName),
            id = newId,
            name_buffer = imgui.new.char[256](newBindName),
            activation_type = 1
        }
        
        table.insert(BinderSystem.binders, newBinder)
        BinderSystem.hotkeys.register(newId, 0, function() end, 1)
        BinderSystem.saveBinders()
    end
end

addEventHandler('onWindowMessage', function(msg, key)
    if msg == 0x0100 then
        if BinderSystem.hotkeys.editing then
            if key == VK_ESCAPE then
                BinderSystem.hotkeys.editing = false
                BinderSystem.hotkeys.current_id = nil
                consumeWindowMessage(true, true)
            elseif key == VK_BACK then
                if BinderSystem.hotkeys.current_id then
                    BinderSystem.hotkeys.callbacks[BinderSystem.hotkeys.current_id] = nil
                end
                BinderSystem.hotkeys.editing = false
                BinderSystem.hotkeys.current_id = nil
                consumeWindowMessage(true, true)
            else
                if BinderSystem.hotkeys.current_id then
                    local callback = BinderSystem.hotkeys.callbacks[BinderSystem.hotkeys.current_id]
                    if callback then
                        local activation_type = callback.activation_type or 1
                        for _, binder in ipairs(BinderSystem.binders) do
                            if binder.id == BinderSystem.hotkeys.current_id then
                                binder.key = key
                                break
                            end
                        end
                        BinderSystem.hotkeys.register(BinderSystem.hotkeys.current_id, key, callback.callback, activation_type)
                        BinderSystem.hotkeys.last_key_state = {}
                        BinderSystem.saveBinders()
                    end
                    BinderSystem.hotkeys.editing = false
                    BinderSystem.hotkeys.current_id = nil
                    consumeWindowMessage(true, true)
                end
            end
        else
            for id, callback in pairs(BinderSystem.hotkeys.callbacks) do
                if callback and callback.key == key and callback.activation_type ~= nil then
                    if callback.activation_type == 1 then
                        if not BinderSystem.hotkeys.last_key_state[key] then
                            callback.callback()
                            BinderSystem.hotkeys.last_key_state[key] = true
                        end
                    end
                end
            end
        end
    elseif msg == 0x0101 then
        for id, callback in pairs(BinderSystem.hotkeys.callbacks) do
            if callback and callback.key == key then
                if callback.activation_type == 2 then
                    callback.callback()
                end
                BinderSystem.hotkeys.last_key_state[key] = false
            end
        end
    end
end)

return BinderSystem 