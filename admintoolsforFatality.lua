script_author("Harry_Pattersone")
script_version("0.5")

require 'lib.moonloader'
require 'lib.sampfuncs'
local imgui = require 'mimgui'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local bit = require 'bit'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local cp = encoding.CP1251
local inicfg = require('inicfg')
local Matrix3X3 = require "matrix3x3"
local Vector3D = require "vector3d"
local vkeys = require('vkeys')
local json = require 'cjson'

require "strings"

local IniFilename = 'FtAdminTools.ini'
local ini = inicfg.load({
    settings = 
    {
        lvladmin = 12,
        acladmin = 0,
        aclfound = false,
        fdadmin = "Нет",
        fd2admin = "Нет",
        autoaterror = false,
        autounmute = false,
        clickwarp = false,
        farchat = false,
        clearhouse = false,
        flyhack = false,
        invadm = false,
        coloradm  = 0,
        nameadm = 0,
        autonosave = false,
        intot = 0,
        intdo = 0,
        prizint = 0,
        prizvopros = 0,
        tagint = "",
        tagvopros = "",
        commandpriz = "",
        commandvopros = "",
        codeexit = "",
        codeexitvopros = "",
        voprosvopros = "",
    }

}, IniFilename)
inicfg.save(ini, IniFilename)


local ffi = require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local json = require("cjson")
local http = require("socket.http")
local requests = require 'requests'
local effil = require 'effil'
local https = require("ssl.https")


local renderAdminTools = new.bool()
local reconWindowTools = new.bool()
local reconStatsTools = new.bool()
local RINFO = new.bool()
local busAdminTools = new.bool()
local statsAdminTools = new.bool()
local offstatsAdminTools = new.bool()
local viktorinaAdminTools = new.bool()
local voprosAdminTools = new.bool()
local tpmenuAdminTools = new.bool()
local addtpAdminTools = new.bool()


local tab = 5
local show_loading = false
local loading_animation_angle = 0
local ipData = {}
local vpnData = {}
local keys = {
	onfoot = {},
	vehicle = {}
}
isSpectating = false
local rInfo = {
	state = false,
    id = -1,
    gethereid = -1,
    nickname = '',
    ped = -1,
}
local font = {}
local lastHouseData = { nick = nil, houseid = nil, typehouse = nil, waitingForGeton = false }


local banTime = new.int(16)
local banReason = new.char[128]("")
local banIPReason = new.char[128]("")
local jailTime = new.int(16)
local jailReason = new.char[128]("")
local kickReason = new.char[128]("")
local warnReason = new.char[128]("")
local lwarnReason = new.char[128]("")
local awarnReason = new.char[128]("")
local muteTime = new.int(16)
local amuteTime = new.int(16)
local muteReason = new.char[128]("")
local amuteReason = new.char[128]("")
local jokeChoose = new.int(16)
local autoantierror = new.bool(ini.settings.autoaterror)
local autounmute = new.bool(ini.settings.autounmute)
local clickwarp = new.bool(ini.settings.clickwarp)
local farchat = new.bool(ini.settings.farchat)
local flyhack = new.bool(ini.settings.flyhack)
local invadm = new.bool(ini.settings.invadm)
local autonosave = new.bool(ini.settings.autonosave)
local intot = new.int(ini.settings.intot)
local intdo = new.int(ini.settings.intdo)
local prizint = new.int(ini.settings.prizint)
local prizvopros = new.int(ini.settings.prizvopros)
local tagint = new.char[128](ini.settings.tagint)
local tagvopros = new.char[128](ini.settings.tagvopros)
local commandpriz = new.char[128](ini.settings.commandpriz)
local commandvopros = new.char[128](ini.settings.commandvopros)
local codeexit = new.char[128](ini.settings.codeexit)
local codeexitvopros = new.char[128](ini.settings.codeexitvopros)
local voprosvopros = new.char[128](ini.settings.voprosvopros)
local nametp = new.char[128]("")
local inttp = new.int(0)
local vwtp = new.int(0)

----

local comboColor = new.int(ini.settings.coloradm)
local item_color = {'Голубой', 'Зеленыый', 'Синий', 'Сиреневый', 'Красный', 'Оранжевый', 'Синий 2', 'Оранжевый 2', 'Серый', 'Томатный', 'Томатный 2'}
local ImColors = imgui.new['const char*'][#item_color](item_color)

local comboName = new.int(ini.settings.nameadm)
local item_name = {'Гл. администратор', 'No Name', 'Unknown', 'User', 'Admin', 'Jesus', 'Satana', 'Andrey_Holkin[0]'}
local ImNames = imgui.new['const char*'][#item_name](item_name)

local blue = "{319AFF}"
local lightblue = "{8cb3d9}"
local green = "{00ff00}"
local red = "{ff0000}"
local yellow = "{FFCD00}"
local purple = "{9370db}"
local white = "{ffffff}"
local darkpurple = "{a86cfc}"
local darkpink = "{cc3370}"
local orange = "{ff6600}"
local darkblue = "{4466cc}"
local darkred = "{b92228}"
local lightbrown = "{d2a679}"
local lime = "{ccff00}"
local cyan = "{00cc99}"
local lightgreen = "{00cc66}"
local lightred = "{FF6666}"
local pink = "{ff99cc}"
local lightgray = "{cecece}"
local black = "{000000}"
local brown = "{a47259}"
local lightyellow = "{d5ff80}"

local items = {
    [346] = lightyellow .. "Лён", [347] = blue .. "Хлопок", [348] = white .. "Бумбокс", [362] = white .. "Камень", [363] = pink .. "Золото", [364] = purple .. "Серебро", [539] = yellow .. "Бронза",
    [540] = lightbrown .. "Металл", [546] = white .. "Карточка победителя", [549] = yellow .. "Грибочки", [588] = yellow .. "Пчёлка", [589] = lightblue .. "Дельфин на спину", [590] = darkpurple .. "Визажист", [591] = orange .. "Дракон",
    [592] = darkpurple .. "Попугай Кеша", [593] = red .. "Девушка на спину", [594] = red .. "Кровавая накидка", [595] = yellow .. "Плащ бога", [596] = darkblue .. "НЛО на плечо", [597] = red .. "Мумия",
    [598] = darkred .. "Бог любви", [599] = lightbrown .. "Олень на плечо", [600] = lightblue .. "Улыбчивый смайлик", [601] = lightblue .. "Довольный смайлик", [602] = lightblue .. "Флиртующий смайлик",
    [603] = yellow .. "Лазерный меч", [604] = lime .. "Космонавт", [605] = cyan .. "Купидон", [606] = lightbrown .. "Винни Пух", [607] = green .. "Пучеглаз", [608] = yellow .. "Бананчик",
    [609] = yellow .. "Посох солнца", [610] = yellow .. "Магнит репутации", [612] = orange .. "Царский интерьер", [616] = lightgreen .. "Ангельское кольцо", [619] = lightgreen .. "Новогодний интерьер",
    [625] = lightgreen .. "Сияние ангела", [626] = red .. "Золотой жетон", [627] = yellow .. "Рюкзак шахтёра", [629] = red .. "Повышение админки", [630] = orange .. "Медаль ведьмы",
    [631] = yellow .. "Сохранение оружия после релога", [633] = yellow .. "День рождения", [634] = lightred .. "Карта АДМИНКА №12", [635] = lightred .. "Карта АДМИНКА №13", [636] = lightred .. "Карта АДМИНКА №14",
    [637] = lightred .. "Карта Confident", [638] = lightred .. "Карта Анти-Снятие", [639] = lightred .. "Карта Анти-Jail", [640] = lightred .. "Карта Верификация", [641] = red .. "Карточный сундук",
    [642] = yellow .. "Плеер MP3", [643] = yellow .. "Спанч Боб", [644] = yellow .. "Зомби дед", [645] = yellow .. "Спартанец", [646] = yellow .. "Зеленая смерть", [647] = yellow .. "Дарт Вейдер",
    [648] = yellow .. "Негр с гробом", [649] = red .. "Донат кейс", [650] = orange .. "Лотырейный билет", [651] = red .. "Блокировка инвентаря", [652] = yellow .. "Таракашка", [653] = yellow .. "Феечка",
    [654] = orange .. "Ведьма", [655] = orange .. "Конфеты", [656] = orange .. "Зелье ведьмы", [657] = orange.. "Майнкрафт", [658] = lightblue .. "Черепашка", [659] = lightblue .. "Смешарик",
    [660] = lightblue .. "Стич", [661] = lightblue .. "Кролик", [662] = lightblue .. "Подарок 2022", [663] = yellow .. "Ангел", [664] = yellow .. "Hello Kitty", [665] = red .. "Bitcoin (BTC)",
    [666] = darkpink .. "Влюбчивый смайлик", [667] = lime .. "NVIDIA GTX 1080Ti", [668] = lime .. "NVIDIA RTX 2080Ti", [669] = lime .. "NVIDIA RTX 3090Ti", [670] = red .. "NVIDIA RTX A5000",
    [671] = red .. "Охлаждающая жидкость", [672] = red .. "Смазка для разгона", [673] = pink .. "Свадебный подарок", [674] = yellow .. "Пикачу в шляпе", [675] = yellow .. "Веном", [676] = lightgray .. "Туалетомен",
    [677] = lightblue .. "Сонник", [678] = lightgray .. "Крик", [679] = lightgreen .. "Коронавирус", [680] = yellow .. "Красный Angry Birds", [681] = yellow .. "Черный Angry Birds", [682] = green .. "The Sims",
    [683] = yellow .. "Плюшевый мишка", [684] = red .. "Набор ресурсов", [685] = brown .."Какашечка", [686] = orange .. "Сияние демона", [687] = lightgray .. "Для взрослых 18+", [688] = lime .. "Кузнечик",
    [689] = yellow .. "Люкс интерьер", [690] = yellow .. "Элитный интерьер", [691] = yellow .. "VIP интерьер", [692] = red .. "Рубли", [693] = red .. "Кредитный счёт", [694] = lightblue .. "Подарок 2023",
    [695] = yellow .. "ФБР гитарист", [696] = yellow .. "Коп гитарист", [697] = yellow .. "Тоторо", [698] = yellow .. "Игрушки", [699] = lime .. "Копатыч", [700] = lime .. "Крипер", [701] = lime .. "Лунтик",
    [702] = lime .. "Патрик", [703] = lime .. "Чебурашка", [704] = lime .. "Микки маус", [705] = yellow .. "Лицензия на охоту", [706] = yellow .. "Тушка оленя", [707] = lightblue .. "Удочка", [708] = lightblue .. "Снасти",
    [709] = lightblue .. "Наживка", [710] = yellow .. "Рыба", [711] = orange .. "Halloween №1", [712] = orange .. "Halloween №2", [713] = orange .. "Halloween №3", [714] = lightblue .. "Подарок 2024",
    [715] = purple .. "Финн", [716] = purple .. "Джейк", [717] = purple .."БиМО", [718] = purple .. "Гюнтер", [719] = purple .. "Ягодка", [720] = purple .. "Стэн Марш", [721] = purple .. "Брофловски",
    [722] = purple .. "Маккоромик", [723] = purple .. "Крэйг", [724] = purple .. "Шеф Макэлрой", [725] = purple .. "Слизень", [726] = purple .. "Дракон края", [727] = purple .. "Страж",
    [728] = purple .. "Белый медведь", [729] = purple .. "Кися", [730] = pink .. "Буст x2 PayDay", [731] = pink .. "Буст x3 PayDay", [732] = pink .. "Буст x4 PayDay", [733] = pink .. "Буст x2 Активность",
    [734] = pink .. "Буст x3 Активность", [735] = pink .. "Буст x4 Активность", [736] = red .. "VIP очки"
}

local rulesText = ([[
1. Основные 
    1.1 - Запрещено использовать вредительские CLEO или читы, наказуемо* баном аккаунта до 7 дн. 
    1.2 - Запрещен намеренный DeathMatch (DM) - намеренное убийство, наказуемо тюрьмой до 15 м. 
    1.3 - Запрещено убивать игроков на спавне (на месте, где они появляются), наказуемо тюрьмой до 20 м. 
    1.4 - Запрещены убийства наездом или стрельбы из авто без причины, наказуемо тюрьмой до 15 м. 
    1.5 - Запрещено использование недоработок сервера для создания неудобств, наказуемо баном аккаунта до 7 дн. 
    1.6 - Запрещено использование недоработок сервера с целью личной выгоды, наказуемо баном аккаунта до 14 дн. 
    1.7 - Запрещено передавать игровой аккаунт (если имеется админка 14+ уровня), наказуемо баном аккаунта до 14 дн. 
    1.8 - Запрещен обман игроков с целью личной выгоды, наказуемо баном аккаунта до 7 дн. или баном чата до 120 минут* 
    1.9 - Запрещена любая провокация* ст. администрации, наказуемо баном аккаунта до 7дн. или бан чата на 60 минут.

2. Процесс общения
    2.1 - Запрещен частый мат и оскорбление других игроков, наказуемо баном чата до 30 м.
    2.2 - Запрещено оскорбление/упоминание родных игроков, наказуемо баном чата до 300 м.
    2.3 - Запрещены угрозы другим игрокам (не относящиеся к игровому процессу), наказуемо баном чата до 60 м.
    2.4 - Запрещена любая реклама сторонних ресурсов, наказуемо баном чата до 90 минут или баном аккаунта до 7 дн.
    2.5 - Запрещено флудить (написание одинаковых сообщений больше 5 раз), наказуемо баном чата до 15 м.
    2.6 - Запрещено оскорбление сервера или главного администратора, наказуемо баном чата до 120 м.

3. Администрация
    - Необходимо сообщать администрации сервера о любых случаях нарушения данных правил
    - Администрация по правилам выбирает штрафные санкции для каждого конкретного случая
    - Санкции могут применяться сразу после нарушения или через время (например, после рассмотрения жалобы)
    - Если штрафная санкция была применена к Вам ошибочно, свяжитесь с vk.com/andreylolkek

4. Для старшей администрации
    4.1 - Если игрок Вас оскорбил в легкой форме (дурак, тупой и тд), наказывать нет необходимости
    4.2 - Если игрок Вас оскорбил в средней форме (с исп. нецензуры), наказывать необходимо по п. 2.6
    4.3 - Если игрок Вас оскорбил в тяжелой форме (с упом. родных), наказывать необходимо по п. 2.2
    4.4 - Если игрок Вас оскорбил в любой форме и использует вредительское ПО, наказывать необходимо по п. 1.1
    4.5 - Если игрок получил от Вас бан / выговор / бан чата / тюрьму и снял за репутацию/обошел иным путем, а затем вновь начинает нарушать, то
    Вы в праве наказать повторно (но уже с x2 сроком), но при условии, что снятое наказание было выдано за п. 1.1, 1.2, 1.5, 1.7, 1.8, 2.2, 2.4, 2.6 (ВАЖНО)

5. Особые примечания
    5.1 - Ст. администратор превыше игроков, нарушения правил в сторону администратора (кроме п. 2.2) не наказываются
    5.2 - Ст. администратор обязан следить за помехой игровому процессу для других игроков, а не для себя
    5.3 - Ст. администратор обязан иметь доказательства на штрафные санкции (п. 1.1, 1.5, 1.7, 1.8, 1.9, 2.2, 4.1, 4.2, 4.3, 4.4, 4.5)
    5.4 - Ст. администратор не должен наказывать игроков только по 1 нарушению (п. 1.2, 1.3, 1.4, 1.5, 1.6, 1.8), необходимо проследить за повторением

6. Система выговоров
    6.1 - Если ст. администратор начинает угрожать / оскорблять игроков, то он получит выговор или бан чата до 300 минут*
    6.2 - Ст. администратор не должен конфликтовать с игроками, серьезные конфликты наказываются выговором
    6.3 - Ст. администратор - приоритетный пользователь, запрещено вести себя неподобающе (в случае нарушения выговор)
    6.4 - Если ст. администратор проявляет неуважение к другим ст. администраторам, то есть вероятность получить БЧ до 300 м.
    6.5 - Если ст. администратор обходит наказание от гл. администратора, то наказание будет применено по п. 1.6

* - Вид наказания может быть применен по наличию степени нарушения (легкое, среднее, среднее-многочисленное, тяжелое)
*1.1: Не наказуемо если было использовано в безлюдных местах, а так же не создавало помеху игрокам и игровому процессу в целом.
*1.9: К провокациям относятся, пробуждение специальных действий со стороны старшего администратора без каких либо оснований.
На первый раз выдать устное предупреждение, если после предупреждения игрок и дальше продолжает заниматься провокациями, то следует выдать бан чата на 60 минут, затем бан аккаунта.
]])

local nakText = ([[
    1. Игровой чат
        1.1 - Оскорбление = 60 минут
        1.2 - Упоминание родных = 300 минут
        1.3 - Флуд = 5-15 минут
        1.4 - Реклама = 30дн бана/бан IP
        1.5 - Капс = 5-15 минут
        1.6 - Неадекват = 30 минут
    2. A-чат
        2.1 - Оскорбление = 60 минут
        2.2 - Упоминание родных = 300 минут
        2.3 - Флуд = 5-15 минут
        2.4 - Реклама = 30дн бана/бан IP
        2.5 - Капс = 5-15 минут
        2.6 - Неадекват = 30 минут
    3. Читы
        3.1 - Читы на работе = 300 минут jail
        3.2 - Читы на DM = dkick, повторное 30 минут jail
        3.2 - Вред. читы = бан 7дн/30дн/бан IP
    4. Боты
        4.1 - Убийство ботов Harry_Test и [Bot]Denis_Test = 300мин jail
        4.2 - Использование ракбота в целях фарма rep = ЧС
        4.3 - Ломание ботов = -respect
        4.4 - Оск ботов = 300 минут
    5. Другое
        5.1 - Убийство без причины(DM), SK, TK = 30 минут jail
        5.2 - DB = 30 минут jail

    Старший администратор вправе удвоить наказание в случае повторения нарушения. Старший администратор всегда прав!
]])

local ACL1Text = ([[
    {ffffff}Команды AclRule 1.0
        {ffd700}/atops {ffffff}- рейтинг основателей
        {ffd700}/zpanel {ffffff}- панель ст. админа 
        {ffd700}/ripmans {ffffff}- игроки с вечным баном 
        {ffd700}/rconsay {ffffff}- RCON чат
        {ffd700}/offgivedonate {ffffff}- выдать донат очки оффлайн
        {ffd700}/offalvladmin {ffffff}- выдать админку (до 13) оффлайн
        {ffd700}/case(on/off) {ffffff}- вкл/выкл кейсы/подарки
        {ffd700}/rating(on/off) {ffffff}- вкл/выкл рейтинги 
        {ffd700}/agiverub {ffffff}- выдача рублей
        {ffd700}/apanel {ffffff}- панель основателей
        {ffd700}/(а)(un)dostup {ffffff}- снять/выдать фд1/2
        {ffd700}/(un)glava {ffffff}- выдача 16 лвл
        {ffd700}/givecmd {ffffff}- выдача команд
        {ffd700}/(un)farmer {ffffff}- снять/поставить ограничение'
]])
local ACL2Text = ([[
    {ffffff}Команды AclRule 2.0
        {ffd700}/antierror {ffffff}- снять ошибку безопастности
        {ffd700}/offawarn {ffffff}- выдать аварн оффлайн
        {ffd700}/offleader {ffffff}- снять лидера оффлайн
        {ffd700}/jetpack {ffffff}- получить джетпак
        {ffd700}/offgiverub {ffffff}- выдача рублей оффлайн
        {ffd700}/(on/off)prom {ffffff}- вкл/выкл ввод промокодов
        {ffd700}/offleader {ffffff}- список лидеров оффлайн
        {ffd700}/geton {ffffff}- последний вход игрока
    {ffffff}Команды AclRule 2.2
        {ffd700}/cuff {ffffff}- теперь доступна
        {ffd700}/aquest {ffffff}- вкл/выкл квест у игрока
        {ffd700}/title {ffffff}- выдача титулов
        {ffd700}/giveclist {ffffff}- выдать радужный клист
        {ffd700}/getakk {ffffff}- посмотреть пароль игрока
        {ffd700}/(un)osnova {ffffff}- снять/выдать AclRule 1.0 (нужен пин тому, кому хочешь выдать)
]])

local ACL3Text = ([[
    {ffffff}Команды AclRule 3.0
        {ffd700}/setpass {ffffff}- сменить пароль у игрока
        {ffd700}/atp {ffffff}- принудительная телепортация игроков
        {ffd700}/giveitems {ffffff}- выдать аксессуары
        {ffd700}/setarm {ffffff}- изменение брони
        {ffd700}/setcarhp {ffffff}- изменение хп у машины
        {ffd700}/settime {ffffff}- изменение времени
        {ffd700}/setweather {ffffff}- изменение погоды
]])
local ACL4Text = ([[
    {ffffff}Команды AclRule 4.0
        {ffd700}/gifts {ffffff}- логи подарков
        {ffd700}/addgift {ffffff}- выдача подарков
        {ffd700}/testmp {ffffff}- мероприятие Угадай Цифру
        {ffd700}/abanip {ffffff}- быстрый banip
        {ffd700}/nosave {ffffff}- не сохранять аккаунт
        {ffd700}/asms {ffffff}- предупреждение от модератора
        {ffd700}/asetint {ffffff}- изменить int у игрока
        {ffd700}/asetvw {ffffff}- изменить виртуальный мир у игрока
        {ffd700}/inter {ffffff}- тп в интерьеры
        {ffd700}/pmall {ffffff}- ответ от админа всем
        {ffd700}/savemans {ffffff}- игроки с запретом на сохранение
]])
local ACL5Text = ([[
    {ffffff}Команды AclRule 5.0
        {ffd700}/setduel {ffffff}- изменить настройки дуэли у игрока
        {ffd700}/present2 {ffffff}- пикап с подарком (/time)
        {ffd700}/present1 {ffffff}- изменить таймер подарка (/time)
        {ffd700}/giveblow {ffffff}- выдача салюта игрока
        {ffd700}/givepoints {ffffff}- выдача поинтов
        {ffd700}/competition {ffffff}- настройки голосования за семью
        {ffd700}/afk {ffffff}- игроки в афк
        {ffd700}/break {ffffff}- поставить ограждение
        {ffd700}/akick {ffffff}- выгнать из семьи
        {ffd700}/fbanlist {ffffff}- список ограниченных семей
        {ffd700}/fban {ffffff}- ограничить семью
        {ffd700}/unfban {ffffff}- снять ограничение у семьи
        {ffd700}/startvirus {ffffff}- начать зомби апокалипсис
        {ffd700}/zombieoff {ffffff}- выключить зомби апокалипсис
]])
local ACL6Text = ([[
    {ffffff}Команды AclRule 6.0
        {ffd700}/module {ffffff}- модули сервера
        {ffd700}/aip {ffffff}- список online aclrules
        {ffd700}/sp(t/a) {ffffff}- говорить за игрока(обычный/админ чат)
        {ffd700}/sp(me,s) /me, /s от имени игрока
        {ffd700}/test(kick/ban) {ffffff}- шуточный кик/бан
        {ffd700}/gocoord {ffffff}- тп по координатам
        {ffd700}/lego {ffffff}- режим лего
        {ffd700}/hbject {ffffff}- создание обьектов на игроке
        {ffd700}/eplayers {ffffff}- игроки с непройденной регистрацией
        {ffd700}/offadmins {ffffff}- список админов 15+ оффлайн
        {ffd700}/tempfamily {ffffff}- вступить в любую семью
        {ffd700}/allfamily {ffffff}- список всех семей
        {ffd700}/asetsex {ffffff}- изменить пол игроку
        {ffd700}/abonus {ffffff}- бонус без ограничений во времени
        {ffd700}/addzone {ffffff}- создание зз
        {ffd700}/temproom {ffffff}- вступить в приватную комнату
]])
local ACL7Text = ([[
    {ffffff}Команды AclRule 7.0
        {ffd700}Значок (А) в ooc чате
        {ffd700}/vdelete {ffffff}- testcmd
        {ffd700}/set(klass/poscar/cena) {ffffff}-  доступен на лег домах
        {ffd700}/asellhouse {ffffff}- доступен на лег домах
        {ffd700}/delpos {ffffff}- доступен на лег домах
        {ffd700}/savehouse {ffffff}- доступен на лег домах
]])
local ACL8Text = ([[
    {ffffff}Команды AclRule 8.0
        {ffd700}/addexp {ffffff}- выдача опыта семье
        {ffd700}/oi {ffffff}- мини-троллинг
        {ffd700}/uptop {ffffff}- принудительное обновление рейтинга
        {ffd700}/addbiz {ffffff}- создать бизнес
        {ffd700}/klad {ffffff}- тп к кладу
        {ffd700}/server {ffffff}- статистика сервера
        {ffd700}/settings {ffffff}- настройки цен
]])
local ACL9Text = ([[
    {ffffff}Команды AclRule 9.0
        {ffd700}/fixmysql {ffffff}- исправление чтения бд на русский язык
        {ffd700}/reloadnews {ffffff}- перезагрузка новостной ленты
        {ffd700}/unawarn {ffffff}- снятие аварнов
        {ffd700}/addquest {ffffff}- доступность квестов
        {ffd700}/age {ffffff}- поставить др игроку
        {ffd700}/gzcolor {ffffff}- изменение цвета квадратиков
        {ffd700}/mtest {ffffff}- АLT+ПКМ на расстоянии
        {ffd700}/prizeyear {ffffff}- красивый текст
        {ffd700}/aobj2 {ffffff}- уебищные обьекты самому себе
        {ffd700}/iinfo {ffffff}- название предмета
        {ffd700}/bank {ffffff}- работает на расстоянии
        {ffd700}/setsale {ffffff}- распродажа админок
    {ffffff}Доп. команды к AclRule 9.0
        {ffd700}/unrip {ffffff}- снять рип
        {ffd700}/giverep {ffffff}- выдать репутацию
        {ffd700}/addreps {ffffff}- выдать репутацию всем онлайн игрокам
        {ffd700}/arep {ffffff}- изменение репутации у игрока
        {ffd700}/giveactivity {ffffff}- выдать активность
        {ffd700}/apassword {ffffff}- пароль на сервер
        {ffd700}/confident {ffffff}- выдать Confident
        {ffd700}/averify {ffffff}- выдать/снять верификацию
        {ffd700}/createprom {ffffff}- создать промокод
        {ffd700}/additem {ffffff}- выдать предмет
        {ffd700}/delitem {ffffff}- удалить предмет
        {ffd700}/anti(jail/sniat) {ffffff}- выдать услугу анти-джаил/снятие
        {ffd700}/offosnova {ffffff}- выдача AclRule оффлайн
        {ffd700}/ajail {ffffff}- посадить/выпустить в безлимитную тюрьму
]])
local ACL10Text = ([[
    {ffffff}Команды AclRule 10.0
        {ffd700}/note {ffffff}- сделать запись в /show
        {ffd700}/auc {ffffff}>> Административный раздел
        {ffd700}/reloadtasks {ffffff}- перезагрузка /tasks
        {ffd700}/lsd {ffffff}- пикапы в виде таблеток
        {ffd700}/offrepedit {ffffff}- изменение репутация в оффе
        {ffd700}/repedit {ffffff}- изменение репутации в онлайне
        {ffd700}/editcode {ffffff}- изменить PIN-код
        {ffd700}Команды изменения домов/бизов {ffffff}- доступны
        {ffd700}/pkick {ffffff}- кикнуть с ПБ
        {ffd700}/givekill {ffffff}- выдать очки дм
]])

local icolors = {}
local sizeX, sizeY = getScreenResolution()
keyToggle = VK_F5
secondaryKey = VK_B
positionX = 10
positionY = sizeY/2
pagesize = 13
messagesMax = 500
blacklist = {
	'На паузе %d+:%d+',
	'На паузе %d+ сек.',
    '%+%d+ активн%. %+ %d+ бонус',
	'+%d hp'
}
playerColor = nil
local giveitemstate = false
local idgiveitem = -1
local ditemstate = false
local finditem = "nil"
local itemsht
local dunjailstate = false
local flySpeed = 40
local busRace1 = false
local busRace2 = false
local busRace3 = false
local REP = 0
local points = 0
local checkpoints = 0
local allcheckpoints = 0
local countrace = 0
local cursorEnabled = false
local statstext = "nil"
local offstatstext = "nil"
local statstitle = "nil"
local offstatstitle = "nil"
local vikstr = 0
local successint = 0
local successvopros = ""
local voprosstr = 0
local sizebutton = nil
local aclFound = false
local teleports = {}
local teleportsFilePath = "teleports.json"

local dialogcolor = false
local dialogname = false
local dialoginv = false
local aint, avw, resultiv = "", "", false

function isItemList(item)
    if items[item] then
        return true, items[item]
    else
        return false, nil
    end
end

local tabs = {
    'Основное',
    'Настройки',
    'Правила сервера',
    'Таблица наказаний',
    'Информация',
}

function checkadminka(nick)
    if ini.settings.aclfound then return end

    sampSendChat("/adminka " .. nick) -- ACL6+ 
    lua_thread.create(function()
        wait(1000)
        if not ini.settings.aclfound then
            sampSendChat("/giveblow") -- ACL5
            wait(1000)
            if not ini.settings.aclfound then
                sampSendChat("/asetint") -- ACL4
                wait(1000)
                if not ini.settings.aclfound then
                    sampSendChat("/setarm") -- ACL3
                    wait(1000)
                    if not ini.settings.aclfound then
                       sampSendChat("/antierror") -- ACL2
                        wait(1000)
                        if not ini.settings.aclfound then
                            sampSendChat("/zpanel") -- ACL1
                            wait(1000)
                            if not ini.settings.aclfound then
                                sampSendChat('/setpref') -- FD2
                                wait(1000)
                                if not ini.settings.aclfound then
                                    sampSendChat('/ahelp') -- FD1
                                    wait(1000)
                                    if not ini.settings.aclfound then
                                        sampSendChat('/admins') -- LVLADMIN
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = tostring(s):lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function lowers(str)
    -- Используем правильную таблицу преобразования
    local result = ""
    
    for i = 1, #str do
        local char = str:sub(i, i)
        local byte = string.byte(char)
        
        -- Английские буквы A-Z
        if byte >= 65 and byte <= 90 then  -- A-Z
            result = result .. string.char(byte + 32)  -- a-z
        -- Русские буквы А-Я (кроме Ё)
        elseif byte >= 192 and byte <= 223 and byte ~= 208 then  -- А-Я (кроме Ё)
            result = result .. string.char(byte + 32)
        -- Буква Ё
        elseif byte == 168 then  -- Ё
            result = result .. string.char(184)  -- ё
        -- Все остальные символы без изменений
        else
            result = result .. char
        end
    end
    
    return result
end

function utext(text)
    text = u8:decode(text)
    return text
end

function find(s, p)
    return string.rlower(s):find(string.rlower(p))
end

function match(s, p)
	return string.rlower(s):match(string.rlower(p))
end

function ACM(text, color)
    color = color:match("%{(.+)%}")
    newcolor = "0x"..color
    text = sampAddChatMessage(text, newcolor)
    return text
end

function getCarSpeed( vehicleTarget, kilometersBool ) -- if "kilometersBool" is true, return km/h
    if not vehicleTarget or type( vehicleTarget ) ~= 'number' then return false end
    if not doesVehicleExist( vehicleTarget ) then return false end
    local x, y, z = getCarSpeedVector( vehicleTarget )
    if not x or not y or not z then x, y, z = 0, 0, 0 end
    local kmh = math.floor( (math.sqrt( (x*x) + (y*y) + (z*z) ) * 180) / 100 ) -- KM/H
    local mph = math.floor( (math.sqrt( (x*x) + (y*y) + (z*z) ) * 180) / 1.609344 / 100 ) -- MPH
    if kilometersBool then return true, kmh else return true, mph end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4
    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end
    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end
        end
    end
    render_text(text)
end

function MinimalistVerticalMenu(items, current)
    local button_padding = 0
    local button_height = 45
    local button_width  = 220
    local active_line_width = 3

    for i, item in ipairs(items) do
        local is_selected = (current == i)

        local color_normal        = imgui.ImVec4(0.13, 0.16, 0.19, 0.0)
        local color_hovered       = imgui.ImVec4(0.00, 0.68, 0.71, 0.25)
        local color_active        = imgui.ImVec4(0.00, 0.68, 0.71, 0.55)
        local color_selected_bg   = imgui.ImVec4(0.00, 0.68, 0.71, 0.85)
        local color_text          = imgui.ImVec4(0.85, 0.85, 0.88, 0.80)
        local color_text_selected = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
        local color_accent        = imgui.ImVec4(0.00, 0.70, 0.50, 1.00)

        imgui.PushStyleColor(imgui.Col.Text, is_selected and color_text_selected or color_text)
        imgui.PushStyleColor(imgui.Col.Button, is_selected and color_selected_bg or color_normal)
        imgui.PushStyleColor(imgui.Col.ButtonHovered, color_hovered)
        imgui.PushStyleColor(imgui.Col.ButtonActive, color_active)
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, button_padding))

        if imgui.Button(item, imgui.ImVec2(button_width, button_height)) then
            current = i
        end

        if is_selected then
            local draw_list = imgui.GetWindowDrawList()
            local min = imgui.GetItemRectMin()
            local max = imgui.GetItemRectMax()
            draw_list:AddRectFilled(
                imgui.ImVec2(min.x, min.y),
                imgui.ImVec2(min.x + active_line_width, max.y),
                imgui.ColorConvertFloat4ToU32(color_accent)
            )
        end

        imgui.PopStyleColor(4)
        imgui.PopStyleVar(2)
    end
    return current
end

function MinimalistSeparator()
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()
    local width = imgui.GetContentRegionAvail().x
    draw_list:AddLine(
        imgui.ImVec2(p.x, p.y),
        imgui.ImVec2(p.x + width, p.y),
        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.25, 0.25, 0.25, 1.00))
    )
    imgui.Dummy(imgui.ImVec2(0, 1))
end

function MinimalistSectionHeader(text)
    imgui.Spacing()
    imgui.PushFont(font_18)
    imgui.Text(text)
    imgui.PopFont()
    MinimalistSeparator()
    imgui.Spacing()
end

function MinimalistIconButton(icon, label, size)
    size = size or imgui.ImVec2(120, 35)
    local color_normal   = imgui.ImVec4(0.18, 0.18, 0.18, 1.00)
    local color_hovered  = imgui.ImVec4(0.25, 0.25, 0.25, 1.00)
    local color_active   = imgui.ImVec4(0.35, 0.35, 0.35, 1.00)
    
    imgui.PushStyleColor(imgui.Col.Button, color_normal)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, color_hovered)
    imgui.PushStyleColor(imgui.Col.ButtonActive, color_active)
    imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
    
    local result = imgui.Button(string.format("%s  %s", icon, label), size)
    
    imgui.PopStyleVar()
    imgui.PopStyleColor(3)
    
    return result
end

function loadTeleports()
    local file = io.open(teleportsFilePath, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content and content ~= "" then
            teleports = decodeJson(content) or {}
        end
    end
end

function saveTeleports()
    local lines = {}
    table.insert(lines, "[")
    
    for i, tp in ipairs(teleports) do
        local line = string.format(
            '  {"name":"%s","x":%d,"y":%d,"z":%d,"interior":%d,"virtualWorld":%d}',
            tostring(tp.name or "Unnamed"):gsub('"', ''),
            tonumber(tp.x),
            tonumber(tp.y),
            tonumber(tp.z),
            tonumber(tp.interior) or 0,
            tonumber(tp.virtualWorld) or 0
        )
        
        if i < #teleports then
            line = line .. ","
        end
        
        table.insert(lines, line)
    end
    
    table.insert(lines, "]")
    
    local file = io.open(teleportsFilePath, "w")
    if file then
        file:write(table.concat(lines, "\n"))
        file:close()
        return true
    end
    return false
end

function imgui.ReconPopup(popup_id, labels, buffers, types, button_labels, callbacks)
    if imgui.BeginPopupModal(popup_id, nil, imgui.WindowFlags.AlwaysAutoResize) then

        for i, buf in ipairs(buffers) do

            local label = labels[i]
            local buf_type = types[i]

            if buf_type == 'int' then
                imgui.Text(label)
                imgui.InputInt("##".. label, buf)
            elseif buf_type == "string" then
                imgui.Text(label)
                imgui.InputTextMultiline("##"..label, buf, sizeof(buf))
            end
        end

        for i=1, #button_labels do
            if imgui.Button(button_labels[i]) then
                if callbacks[i] then callbacks[i]() end
                imgui.CloseCurrentPopup()
            end
            if i < #button_labels then imgui.SameLine() end
        end

        imgui.EndPopup()
    end
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
    imgui.Text(u8(text))
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local handler = require 'samp.events.handlers'
    local extra_types = require 'samp.events.extra_types'
    local hooks = {

        --[[ Outgoing rpcs
        ['onSendEnterVehicle'] = { 'int16', 'bool8', 26 },
        ['onSendClickPlayer'] = { 'int16', 'int8', 23 },
        ['onSendClientJoin'] = { 'int32', 'int8', 'string8', 'int32', 'string8', 'string8', 'int32', 25 },
        ['onSendEnterEditObject'] = { 'int32', 'int16', 'int32', 'vector3d', 27 },
        ['onSendCommand'] = { 'string32', 50 },
        ['onSendSpawn'] = { 52 },
        ['onSendDeathNotification'] = { 'int8', 'int16', 53 },
        ['onSendDialogResponse'] = { 'int16', 'int8', 'int16', 'string8', 62 },
        ['onSendClickTextDraw'] = { 'int16', 83 },
        ['onSendVehicleTuningNotification'] = { 'int32', 'int32', 'int32', 'int32', 96 },
        ['onSendChat'] = { 'string8', 101 },
        ['onSendClientCheckResponse'] = { 'int8', 'int32', 'int8', 103 },
        ['onSendVehicleDamaged'] = { 'int16', 'int32', 'int32', 'int8', 'int8', 106 },
        ['onSendEditAttachedObject'] = { 'int32', 'int32', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 116 },
        ['onSendEditObject'] = { 'bool', 'int16', 'int32', 'vector3d', 'vector3d', 117 },
        ['onSendInteriorChangeNotification'] = { 'int8', 118 },
        ['onSendMapMarker'] = { 'vector3d', 119 },
        ['onSendRequestClass'] = { 'int32', 128 },
        ['onSendRequestSpawn'] = { 129 },
        ['onSendPickedUpPickup'] = { 'int32', 131 },
        ['onSendMenuSelect'] = { 'int8', 132 },
        ['onSendVehicleDestroyed'] = { 'int16', 136 },
        ['onSendQuitMenu'] = { 140 },
        ['onSendExitVehicle'] = { 'int16', 154 },
        ['onSendUpdateScoresAndPings'] = { 155 },
        ['onSendGiveDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },
        ['onSendTakeDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },]]

        -- Incoming rpcs
        ['onInitGame'] = { 139 },
        ['onPlayerJoin'] = { 'int16', 'int32', 'bool8', 'string8', 137 },
        ['onPlayerQuit'] = { 'int16', 'int8', 138 },
        ['onRequestClassResponse'] = { 'bool8', 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 128 },
        ['onRequestSpawnResponse'] = { 'bool8', 129 },
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },
        ['onSetPlayerPos'] = { 'vector3d', 12 },
        ['onSetPlayerPosFindZ'] = { 'vector3d', 13 },
        ['onSetPlayerHealth'] = { 'float', 14 },
        ['onTogglePlayerControllable'] = { 'bool8', 15 },
        ['onPlaySound'] = { 'int32', 'vector3d', 16 },
        ['onSetWorldBounds'] = { 'float', 'float', 'float', 'float', 17 },
        ['onGivePlayerMoney'] = { 'int32', 18 },
        ['onSetPlayerFacingAngle'] = { 'float', 19 },
        --['onResetPlayerMoney'] = { 20 },
        --['onResetPlayerWeapons'] = { 21 },
        ['onGivePlayerWeapon'] = { 'int32', 'int32', 22 },
        --['onCancelEdit'] = { 28 },
        ['onSetPlayerTime'] = { 'int8', 'int8', 29 },
        ['onSetToggleClock'] = { 'bool8', 30 },
        ['onPlayerStreamIn'] = { 'int16', 'int8', 'int32', 'vector3d', 'float', 'int32', 'int8', 32 },
        ['onSetShopName'] = { 'string256', 33 },
        ['onSetPlayerSkillLevel'] = { 'int16', 'int32', 'int16', 34 },
        ['onSetPlayerDrunk'] = { 'int32', 35 },
        ['onCreate3DText'] = { 'int16', 'int32', 'vector3d', 'float', 'bool8', 'int16', 'int16', 'encodedString4096', 36 },
        --['onDisableCheckpoint'] = { 37 },
        ['onSetRaceCheckpoint'] = { 'int8', 'vector3d', 'vector3d', 'float', 38 },
        --['onDisableRaceCheckpoint'] = { 39 },
        --['onGamemodeRestart'] = { 40 },
        ['onPlayAudioStream'] = { 'string8', 'vector3d', 'float', 'bool8', 41 },
        --['onStopAudioStream'] = { 42 },
        ['onRemoveBuilding'] = { 'int32', 'vector3d', 'float', 43 },
        ['onCreateObject'] = { 44 },
        ['onSetObjectPosition'] = { 'int16', 'vector3d', 45 },
        ['onSetObjectRotation'] = { 'int16', 'vector3d', 46 },
        ['onDestroyObject'] = { 'int16', 47 },
        ['onPlayerDeathNotification'] = { 'int16', 'int16', 'int8', 55 },
        ['onSetMapIcon'] = { 'int8', 'vector3d', 'int8', 'int32', 'int8', 56 },
        ['onRemoveVehicleComponent'] = { 'int16', 'int16', 57 },
        ['onRemove3DTextLabel'] = { 'int16', 58 },
        ['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
        ['onUpdateGlobalTimer'] = { 'int32', 60 },
        ['onShowDialog'] = { 'int16', 'int8', 'string8', 'string8', 'string8', 'encodedString4096', 61 },
        ['onDestroyPickup'] = { 'int32', 63 },
        ['onLinkVehicleToInterior'] = { 'int16', 'int8', 65 },
        ['onSetPlayerArmour'] = { 'float', 66 },
        ['onSetPlayerArmedWeapon'] = { 'int32', 67 },
        ['onSetSpawnInfo'] = { 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 68 },
        ['onSetPlayerTeam'] = { 'int16', 'int8', 69 },
        ['onPutPlayerInVehicle'] = { 'int16', 'int8', 70 },
        --['onRemovePlayerFromVehicle'] = { 71 },
        ['onSetPlayerColor'] = { 'int16', 'int32', 72 },
        ['onDisplayGameText'] = { 'int32', 'int32', 'string32', 73 },
        --['onForceClassSelection'] = { 74 },
        ['onAttachObjectToPlayer'] = { 'int16', 'int16', 'vector3d', 'vector3d', 75 },
        ['onInitMenu'] = { 76 },
        ['onShowMenu'] = { 'int8', 77 },
        ['onHideMenu'] = { 'int8', 78 },
        ['onCreateExplosion'] = { 'vector3d', 'int32', 'float', 79 },
        ['onShowPlayerNameTag'] = { 'int16', 'bool8', 80 },
        ['onAttachCameraToObject'] = { 'int16', 81 },
        ['onInterpolateCamera'] = { 'bool', 'vector3d', 'vector3d', 'int32', 'int8', 82 },
        ['onGangZoneStopFlash'] = { 'int16', 85 },
        ['onApplyPlayerAnimation'] = { 'int16', 'string8', 'string8', 'bool', 'bool', 'bool', 'bool', 'int32', 86 },
        ['onClearPlayerAnimation'] = { 'int16', 87 },
        ['onSetPlayerSpecialAction'] = { 'int8', 88 },
        ['onSetPlayerFightingStyle'] = { 'int16', 'int8', 89 },
        ['onSetPlayerVelocity'] = { 'vector3d', 90 },
        ['onSetVehicleVelocity'] = { 'bool8', 'vector3d', 91 },
        ['onServerMessage'] = { 'int32', 'string32', 93 },
        ['onSetWorldTime'] = { 'int8', 94 },
        ['onCreatePickup'] = { 'int32', 'int32', 'int32', 'vector3d', 95 },
        ['onMoveObject'] = { 'int16', 'vector3d', 'vector3d', 'float', 'vector3d', 99 },
        ['onEnableStuntBonus'] = { 'bool', 104 },
        ['onTextDrawSetString'] = { 'int16', 'string16', 105 },
        ['onSetCheckpoint'] = { 'vector3d', 'float', 107 },
        ['onCreateGangZone'] = { 'int16', 'vector2d', 'vector2d', 'int32', 108 },
        ['onPlayCrimeReport'] = { 'int16', 'int32', 'int32', 'int32', 'int32', 'vector3d', 112 },
        ['onGangZoneDestroy'] = { 'int16', 120 },
        ['onGangZoneFlash'] = { 'int16', 'int32', 121 },
        ['onStopObject'] = { 'int16', 122 },
        ['onSetVehicleNumberPlate'] = { 'int16', 'string8', 123 },
        ['onTogglePlayerSpectating'] = { 'bool32', 124 },
        ['onSpectatePlayer'] = { 'int16', 'int8', 126 },
        ['onSpectateVehicle'] = { 'int16', 'int8', 127 },
        ['onShowTextDraw'] = { 134 },
        ['onSetPlayerWantedLevel'] = { 'int8', 133 },
        ['onTextDrawHide'] = { 'int16', 135 },
        ['onRemoveMapIcon'] = { 'int8', 144 },
        ['onSetWeaponAmmo'] = { 'int8', 'int16', 145 },
        ['onSetGravity'] = { 'float', 146 },
        ['onSetVehicleHealth'] = { 'int16', 'float', 147 },
        ['onAttachTrailerToVehicle'] = { 'int16', 'int16', 148 },
        ['onDetachTrailerFromVehicle'] = { 'int16', 149 },
        ['onSetWeather'] = { 'int8', 152 },
        ['onSetPlayerSkin'] = { 'int32', 'int32', 153 },
        ['onSetInterior'] = { 'int8', 156 },
        ['onSetCameraPosition'] = { 'vector3d', 157 },
        ['onSetCameraLookAt'] = { 'vector3d', 'int8', 158 },
        ['onSetVehiclePosition'] = { 'int16', 'vector3d', 159 },
        ['onSetVehicleAngle'] = { 'int16', 'float', 160 },
        ['onSetVehicleParams'] = { 'int16', 'int16', 'bool8', 161 },
        --['onSetCameraBehind'] = { 162 },
        ['onChatMessage'] = { 'int16', 'string8', 101 },
        ['onConnectionRejected'] = { 'int8', 130 },
        ['onPlayerStreamOut'] = { 'int16', 163 },
        ['onVehicleStreamIn'] = { 164 },
        ['onVehicleStreamOut'] = { 'int16', 165 },
        ['onPlayerDeath'] = { 'int16', 166 },
        ['onPlayerEnterVehicle'] = { 'int16', 'int16', 'bool8', 26 },
        ['onUpdateScoresAndPings'] = { 'PlayerScorePingMap', 155 },
        ['onSetObjectMaterial'] = { 84 },
        ['onSetObjectMaterialText'] = { 84 },
        ['onSetVehicleParamsEx'] = { 'int16', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 24 },
        ['onSetPlayerAttachedObject'] = { 'int16', 'int32', 'bool', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 113 }

    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end

function sampev.onSendPlayerSync(data)
	if spec then
		local sync = samp_create_sync_data('spectator')
		sync.position = data.position
        sync.keysData = data.keysData
		sync.send()
		return false
	end

    if active then
        for i = 0, 2 do
            data.quaternion[i] = 0
        end
        data.upDownKeys = 65408
        data.keysData = 8
        data.animationId = 1538
        data.animationFlags = 32770

        local heading = getCharHeading(PLAYER_PED)

        data.moveSpeed.x = 0
        data.moveSpeed.y = 0
    end
end

function sampev.onRemoveBuilding(modelId, position, radius)
    return false
end

function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
	if nopPlayerSync and id == 207 then return false end
	if nopPlayerSync and id == 204 then return false end
end

function initializeRender()
    font = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
    font2 = renderCreateFont("Arial", 8, FCR_ITALICS + FCR_BORDER)
end

function rotateCarAroundUpAxis(car, vec)
    local mat = Matrix3X3(getVehicleRotationMatrix(car))
    local rotAxis = Vector3D(mat.up:get())
    vec:normalize()
    rotAxis:normalize()
    local theta = math.acos(rotAxis:dotProduct(vec))
    if theta ~= 0 then
        rotAxis:crossProduct(vec)
        rotAxis:normalize()
        rotAxis:zeroNearZero()
        mat = mat:rotate(rotAxis, -theta)
    end
    setVehicleRotationMatrix(car, mat:get())
end

function readFloatArray(ptr, idx)
    return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
end

function writeFloatArray(ptr, idx, value)
    writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
end

function getVehicleRotationMatrix(car)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
        local mat = readMemory(entityPtr + 0x14, 4, false)
        if mat ~= 0 then
            local rx, ry, rz, fx, fy, fz, ux, uy, uz
            rx = readFloatArray(mat, 0)
            ry = readFloatArray(mat, 1)
            rz = readFloatArray(mat, 2)

            fx = readFloatArray(mat, 4)
            fy = readFloatArray(mat, 5)
            fz = readFloatArray(mat, 6)

            ux = readFloatArray(mat, 8)
            uy = readFloatArray(mat, 9)
            uz = readFloatArray(mat, 10)
            return rx, ry, rz, fx, fy, fz, ux, uy, uz
        end
    end
end

function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
        local mat = readMemory(entityPtr + 0x14, 4, false)
        if mat ~= 0 then
            writeFloatArray(mat, 0, rx)
            writeFloatArray(mat, 1, ry)
            writeFloatArray(mat, 2, rz)

            writeFloatArray(mat, 4, fx)
            writeFloatArray(mat, 5, fy)
            writeFloatArray(mat, 6, fz)

            writeFloatArray(mat, 8, ux)
            writeFloatArray(mat, 9, uy)
            writeFloatArray(mat, 10, uz)
        end
    end
end

function displayVehicleName(x, y, gxt)
    x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
    useRenderCommands(true)
    setTextWrapx(640.0)
    setTextProportional(true)
    setTextJustify(false)
    setTextScale(0.23, 0.8)
    setTextDropshadow(0, 0, 0, 0, 0)
    setTextColour(255, 0, 0, 230)
    setTextEdge(1, 0, 0, 0, 100)
    setTextFont(1)
    displayText(x, y, gxt)
end

function createPointMarker(x, y, z)
    pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
end

function removePointMarker()
    if pointMarker then
        removeUser3dMarker(pointMarker)
        pointMarker = nil
    end
end

function getCarFreeSeat(car)
    if doesCharExist(getDriverOfCar(car)) then
        local maxPassengers = getMaximumNumberOfPassengers(car)
        for i = 0, maxPassengers do
            if isCarPassengerSeatFree(car, i) then
                return i + 1
            end
        end
        return nil
    else
        return 0
    end
end

function jumpIntoCar(car)
    local seat = getCarFreeSeat(car)
    if not seat then return false end
    if seat == 0 then warpCharIntoCar(playerPed, car)
    else warpCharIntoCarAsPassenger(playerPed, car, seat - 1)
    end
    restoreCameraJumpcut()
    return true
end

function teleportPlayer(x, y, z)
    if isCharInAnyCar(playerPed) then
        setCharCoordinates(playerPed, x, y, z)
    end
    setCharCoordinatesDontResetAnim(playerPed, x, y, z)
end

function setCharCoordinatesDontResetAnim(char, x, y, z)
    if doesCharExist(char) then
        local ptr = getCharPointer(char)
        setEntityCoordinates(ptr, x, y, z)
    end
end

function setEntityCoordinates(entityPtr, x, y, z)
    if entityPtr ~= 0 then
        local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
        if matrixPtr ~= 0 then
            local posPtr = matrixPtr + 0x30
            writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
            writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
            writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
        end
    end
end

function showCursorClickWarp(toggle)
    if toggle then
      sampSetCursorMode(3)
      cursorEnabled = true
    else
      sampToggleCursor(false)
      sampSetCursorMode(0)
      cursorEnabled = false
    end
end

function haversine(lat1, lon1, lat2, lon2)
    local R = 6371
    local dLat = math.rad(lat2 - lat1)
    local dLon = math.rad(lon2 - lon1)

    local a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) *
              math.sin(dLon / 2) * math.sin(dLon / 2)
    
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c
end

function getGorod(ip)
    if not ip or ip == "" or ip == "N/A" then
        return { city = "N/A", country = "N/A", region = "N/A", isp = "N/A", latitude = "N/A", longitude = "N/A" }, "Ошибка: Неправильный Айпи адрес"
    end

    if ipData[ip] then
        return ipData[ip]
    end

    local url = string.format("https://ipwho.is/%s?lang=ru", ip)

    local response = {}
    local _, code = https.request{
        url = url,
        sink = ltn12.sink.table(response),
    }

    if code ~= 200 then
        return { city = "Ошибка", country = "Ошибка", region = "Ошибка", isp = "Ошибка", latitude = "Ошибка", longitude = "Ошибка" }, 
               "Ошибка: Не удалось получить данные. Код ответа: " .. tostring(code)
    end

    local data = table.concat(response)

    local success, parsedData = pcall(json.decode, data)
    if not success or not parsedData then
        return { city = "Ошибка", country = "Ошибка", region = "Ошибка", isp = "Ошибка", latitude = "Ошибка", longitude = "Ошибка" }, 
               "Ошибка: Не удалось разобрать JSON. Данные ответа: " .. tostring(data)
    end

    local result = {
        region = parsedData.region or "Неизвестный регион",
        country = parsedData.country or "Неизвестная страна",
        city = parsedData.city or "Неизвестный город",
        isp = parsedData.connection and parsedData.connection.isp or "Неизвестная организация",
        latitude = parsedData.latitude or "Неизвестная широта",
        longitude = parsedData.longitude or "Неизвестная долгота"
    }

    ipData[ip] = result

    return result
end

function getVPN(ip)
    if not ip or ip == "" or ip == "N/A" then
        return { proxy = "N/A", type = "N/A", risk = "N/A" }, "Ошибка: Неправильный Айпи адрес"
    end

    if vpnData[ip] then
        return vpnData[ip]
    end

    local url = string.format("https://proxycheck.io/v2/%s?key=422p28-2r1189-49240e-900390&vpn=1&risk=1", ip)

    local response = {}
    local _, code = https.request{
        url = url,
        sink = ltn12.sink.table(response),
    }

    if code ~= 200 then
        return { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" },
            "Ошибка: Не удалось получить данные. Код ответа: " .. tostring(code)
    end

	local data = table.concat(response)


    local success, parsedData = pcall(json.decode, data)
    if not success then
        return { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" },
            "Ошибка: Не удалось разобрать JSON. Проверьте данные ответа: " .. tostring(data)
    end

	local ipData = parsedData[ip]
    if not ipData then
        return { proxy = "Ошибка", type = "Ошибка", risk = "Ошибка" },
            "Ошибка: В ответе отсутствуют данные для указанного IP."
    end

    local result = {
		proxy = ipData.proxy or "Неизвестный vpn",
		type = ipData.type or "Неизвестный тип",
		provider = ipData.provider or "Неизвестный провайдер",
		risk = ipData.risk or "Неизвестный риск",
    }

    vpnData[ip] = result

    return result
end

function viktorina()
    lua_thread.create(function ()
        if ini.settings.commandpriz == "trep" or ini.settings.commandpriz == 'giverep' then
            sampSendChat(string.format(utext('/a [%s] Начинается викторина! Угадайте число от %s до %s!'), utext(ini.settings.tagint), ini.settings.intot, ini.settings.intdo))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответы писать только в /a! Приз: %s реп'), utext(ini.settings.tagint), ini.settings.prizint))
            vikstr = 1
        elseif ini.settings.commandpriz == "additem" then
            sampSendChat(string.format(utext('/a [%s] Начинается викторина! Угадайте число от %s до %s!'), utext(ini.settings.tagint), ini.settings.intot, ini.settings.intdo))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответы писать только в /a! Приз: Предмет ID %s'), utext(ini.settings.tagint), ini.settings.prizint))
            vikstr = 1
        else
            sampSendChat(string.format(utext('/a [%s] Начинается викторина! Угадайте число от %s до %s!'), utext(ini.settings.tagint), ini.settings.intot, ini.settings.intdo))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответы писать только в /a! Приз: Неизвестно'), utext(ini.settings.tagint)))
            vikstr = 1
        end
    end)
end

function vopros()
    lua_thread.create(function ()
        if ini.settings.commandvopros == "trep" or ini.settings.commandvopros == 'giverep' then
            sampSendChat(string.format(utext('/a [%s] %s?'), utext(ini.settings.tagvopros), utext(ini.settings.voprosvopros)))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответ писать только в /a! Приз: %s реп'),utext( ini.settings.tagvopros), ini.settings.prizvopros))
            voprosstr = 1
        elseif ini.settings.commandvopros == "additem" then
            sampSendChat(string.format(utext('/a [%s] %s?'), utext(ini.settings.tagvopros), utext(ini.settings.voprosvopros)))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответ писать только в /a! Приз: Предмет ID %s'), utext(ini.settings.tagvopros), ini.settings.prizvopros))
            voprosstr = 1
        else
            sampSendChat(string.format(utext('/a [%s] %s?'), utext(ini.settings.tagvopros), utext(ini.settings.voprosvopros)))
            wait(1000)
            sampSendChat(string.format(utext('/a [%s] Ответ писать только в /a! Приз: Неизвестно'), utext(ini.settings.tagvopros)))
            voprosstr = 1
        end
    end)
end

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    local path = getFolderPath(0x14) .. '\\trebucbd.ttf'
    imgui.GetIO().Fonts:Clear()
    imgui.GetIO().Fonts:AddFontFromFileTTF(path, 15.0, nil, glyph_ranges)
    font_16 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 16.0, nil, glyph_ranges)
    font_17 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 16.0, nil, glyph_ranges)
    font_18 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 18.0, nil, glyph_ranges)
    font_21 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 21.0, nil, glyph_ranges)
    font_22 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 22.0, nil, glyph_ranges)
    font_23 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 24.0, nil, glyph_ranges)
    font_24 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 24.0, nil, glyph_ranges)
    font_25 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 25.0, nil, glyph_ranges)
    font_40 = imgui.GetIO().Fonts:AddFontFromFileTTF(path, 40.0, nil, glyph_ranges)
    SoftBlueTheme()
    theme[1].change()
    sW, sH = getScreenResolution()
    u32 = imgui.ColorConvertFloat4ToU32
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true

end)

local newadmintools = imgui.OnFrame(
    function() return renderAdminTools[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX * 0.65, sizeY * 0.65), imgui.Cond.FirstUseEver)
        imgui.Begin("##Admin", renderAdminTools, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
        imgui.BeginChild("LeftPanel", imgui.ImVec2(270, 0), true)
        tab = MinimalistVerticalMenu(tabs, tab)
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("RightPanel", imgui.ImVec2(0, 0), true)
        if tab == 1 then
            MinimalistSectionHeader("Админ-Панель")
            imgui.PushFont(font_17)

            imgui.Text(string.format(
                "Ваш уровень админки: %s | ACL: %s | FD1: %s | FD2: %s",
                ini.settings.lvladmin, ini.settings.acladmin, ini.settings.fdadmin, ini.settings.fd2admin
            ))
            imgui.Spacing()
            if imgui.Button(">> Проверить <<") then
                local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
                local nick = sampGetPlayerNickname(id)
                checkadminka(nick)
            end
            imgui.Spacing()
            local acl = tonumber(ini.settings.acladmin) or 0
            if acl >= 1 then
                MinimalistSectionHeader("Команды ACL")

                if imgui.TreeNodeStr("Команды ACL") then

                    local function renderACL(level, title, text)
                        if acl >= level and imgui.TreeNodeStr(title) then
                            imgui.BeginChild(title .. "Child", imgui.ImVec2(500, 250), true)
                            for line in text:gmatch("[^\n]+") do
                                imgui.TextColoredRGB(line)
                            end
                            imgui.EndChild()
                            imgui.TreePop()
                        end
                    end

                    if acl == 1 then
                        renderACL(1, "ACL1", ACL1Text)
                    elseif acl == 2 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                    elseif acl == 3 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                    elseif acl == 4 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                    elseif acl == 5 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                    elseif acl == 6 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                    elseif acl == 7 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                        renderACL(7, "ACL7", ACL7Text)
                    elseif acl == 8 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                        renderACL(7, "ACL7", ACL7Text)
                        renderACL(8, "ACL8", ACL8Text)
                    elseif acl == 9 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                        renderACL(7, "ACL7", ACL7Text)
                        renderACL(8, "ACL8", ACL8Text)
                        renderACL(9, "ACL9", ACL9Text)
                    elseif acl == 10 then
                        renderACL(1, "ACL1", ACL1Text)
                        renderACL(2, "ACL2", ACL2Text)
                        renderACL(3, "ACL3", ACL3Text)
                        renderACL(4, "ACL4", ACL4Text)
                        renderACL(5, "ACL5", ACL5Text)
                        renderACL(6, "ACL6", ACL6Text)
                        renderACL(7, "ACL7", ACL7Text)
                        renderACL(8, "ACL8", ACL8Text)
                        renderACL(9, "ACL9", ACL9Text)
                        renderACL(10, "ACL10", ACL10Text)
                    end
                    imgui.TreePop()
                end
            end
            imgui.EndChild()
            imgui.PopFont()
        end
        if tab == 2 then
            MinimalistSectionHeader("Настройки")
            imgui.BeginChild("SettingsTab", imgui.ImVec2(0, 0), true)
            if imgui.Checkbox('Включить Auto-AntiError', autoantierror) then
                ini.settings.autoaterror = autoantierror[0]
                inicfg.save(ini, IniFilename)
            end
            if imgui.Checkbox('Включить Auto-Unmute', autounmute) then
                ini.settings.autounmute = autounmute[0]
                inicfg.save(ini, IniFilename)
            end
            if imgui.Checkbox("Clickwarp", clickwarp) then
                ini.settings.clickwarp = clickwarp[0]
                inicfg.save(ini, IniFilename)
            end
            if imgui.Checkbox("FarChat", farchat) then
                ini.settings.farchat = farchat[0]
                bubbleBox:toggle(ini.settings.farchat)
                inicfg.save(ini, IniFilename)
            end
            if imgui.Checkbox("FlyHack", flyhack) then
                ini.settings.flyhack = flyhack[0]
                inicfg.save(ini, IniFilename)
            end
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            local nick = sampGetPlayerNickname(id)
            if nick == "Denis_Angelov" or nick == "Harry_Pattersone" or nick == "Navalny_Vandal" or nick == "navalny_vandal" then
                if imgui.Checkbox("Invisible Admin-Chat", invadm) then
                    ini.settings.invadm = invadm[0]
                    inicfg.save(ini, IniFilename)
                    sampSendChat('/adminmenu')
                    dialoginv = true
                end
                if invadm[0] then
                    if imgui.Combo('Color Adm Chat', comboColor, ImColors, #item_color) then
                        ini.settings.coloradm = comboColor[0]
                        inicfg.save(ini, IniFilename)
                        sampSendChat('/adminmenu')
                        dialogcolor = true
                    end
                    if imgui.Combo('Name Adm Chat', comboName, ImNames, #item_name) then
                    ini.settings.nameadm = comboName[0]
                    inicfg.save(ini, IniFilename)
                    sampSendChat('/adminmenu')
                    dialogname = true
                    end
                end
            end
            if imgui.Checkbox("Auto-NoSave", autonosave) then
                ini.settings.autonosave = autonosave[0]
                inicfg.save(ini, IniFilename)
            end
            imgui.SameLine()
            imgui.TextColoredRGB("{ff0000}Можно получить AWARN!")
            imgui.Spacing()
            MinimalistSeparator()
            imgui.Spacing()
            if imgui.Button("Настроить викторину") then
                viktorinaAdminTools[0] = not viktorinaAdminTools[0]
                renderAdminTools[0] = not renderAdminTools[0]
            end
            if imgui.Button("Настроить вопрос") then
                voprosAdminTools[0] = not voprosAdminTools[0]
                renderAdminTools[0] = not renderAdminTools[0]
            end
            imgui.EndChild()
        end
        if tab == 3 then
            MinimalistSectionHeader("Правила сервера")
            imgui.PushFont(font_17)
            imgui.BeginChild('RulesFatality', imgui.ImVec2(0, 0), true, imgui.WindowFlags.HorizontalScrollbar)
            for line in rulesText:gmatch("[^\n]+") do
                imgui.Text(line)
            end
            imgui.EndChild()
            imgui.PopFont()
        end
        if tab == 4 then
            MinimalistSectionHeader("Таблица наказаний")
            imgui.PushFont(font_17)
            imgui.BeginChild('NakFatality', imgui.ImVec2(0, 0), true, imgui.WindowFlags.HorizontalScrollbar)
            for line in nakText:gmatch("[^\n]+") do
                imgui.Text(line)
            end
            imgui.EndChild()
            imgui.PopFont()
        end
        if tab == 5 then
            MinimalistSectionHeader("Информация о скрипте")
            imgui.PushFont(font_18)
            imgui.BeginChild('InfoScript', imgui.ImVec2(0,0), true)
            imgui.TextColoredRGB((
            [[ 
                                                                                                            {808080}[Скрипт]

                {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                {ffffff}Название скрипта: {00ADB5}AdminTools for Fatality NRP
                {ffffff}Автор скрипта: {ff0000}Harry_Pattersone
                {ffffff}Версия скрипта: {00ADB5}0.5
                {ffffff}Описание скрипта: {00ADB5}Данный скрипт упрощает администрирование на Fatality NRP, 
                                                {00ADB5}а также добавляет новые функции и интерфейсы.
                {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                                                        {808080}[Функционал]
                {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                {ffffff}Открыть данное меню: {ff0000}/at
                {ffffff}Список коротких команд: 
                        {ffff00}/osk {808080}[id/nick] {ffffff}| быстрый mute(offmute) за osk в обычном чате;
                        {ffff00}/aosk {808080}[id] {ffffff}| быстрый mute за osk в A-чате;
                        {ffff00}/sosk {808080}[id/nick] [номер] {ffffff}| быстрый mute(offmute) за Оск. Сервера;
                        {ffff00}/cheat {808080}[id/nick] [номер] {ffffff}| наказания за читы(Чит на работе, Вред.читы(бан, banip), Чит на DM(dkick, jail));
                        {ffff00}/offcheat {808080}[nick] [номер] {ffffff}| наказания за читы в оффлайн(Чит на работе, Вред.читы, Читы на DM);
                        {ffff00}/ur {808080}[id/nick] [номер] {ffffff}| быстрый mute(offmute) за У.Р в обычном чате;
                        {ffff00}/aur {808080}[id] [номер] {ffffff}| быстрый мут за У.Р в A-чате;
                        {ffff00}/giveitem {808080}[id] [название предмета] [кол-во] {ffffff}| быстрая выдача предмета по его названию;
                        {ffff00}/ditem {808080}[id] [название предмета] [кол-во] {ffffff}| быстрое удаление предмета по его названию;
                        {ffff00}/clearhouse {ffffff}| система авто-продажи дома(бета); {ff0000}[Может крашнуть]
                        {ffff00}/dunjail {ffffff}| быстрый выход из jail через Донат; {ff0000}[Может не сработать с 1 раза]
                        {ffff00}/inv {ffffff}| Инвиз(не видно даже на карте); {ff0000}[Умеет кое-что ещё, но тссс...]
                        {ffff00}/flip {ffffff}| Та команда которую Ревков не может сделать.
                {ffffff}Список измененных команд:
                        {ffff00}/hp {808080}[без аргумента/id] {ffffff}| теперь команда без аргумента вылечит вас;
                        {ffff00}/hpall {ffffff}| теперь команда вылечит всех в зоне стрима, включая Вас;
                        {ffff00}/gun {808080}[id] {ffffff}| выдаст Deagle, M4, Shotgun игроку;
                        {ffff00}/gun {808080}[id] [idgun | название] {ffffff}| выдаст оружие с 1 патроном;
                        {ffff00}/gun {808080}[id] [idgun | название] [ammo] {ffffff}| выдаст оружие с указанным кол-вом патронов;
                        {ffff00}/slap {808080}[id/up/down] {ffffff}| {808080}[id игрока] {ffffff} слапнет игрока обычно, {808080}[up] {ffffff}слапнет Вас обычно, {808080}[down] {ffffff}слапнет Вас вниз.
                {ffffff}Список горячих клавиш:
                        {ffff00}ПКМ+Shift {ffffff}| откроет круговое меню;
                        {ffff00}Колёсико мыши {ffffff}| clickwarp;
                        {ffff00}B+MINUS {ffffff}| прокрутить дальний чат вниз;
                        {ffff00}B+PLUS {ffffff}| прокрутить дальний чат вверх;
                        {ffff00}Ю | > | . {ffffff}| флай из собейта, {ffff00}Колёсико мыши {ffffff}| регулировка скорости; {ff0000}[ГМ у этого флая кривой, переделывать лень]
                        {ffff00}M {ffffff}| выход из рекона;
                        {ffff00}SPACE в /re {ffffff}| Обновить recon.
                {ffffff}Список измененных(новых) интерфейсов:
                        {ffff00}/stats {808080}[без аргумента/id] {ffffff}| теперь команда без аргумента откроет вашу статистику. А также обновленный дизайн;
                        {ffff00}/offstats {ffffff}| новый дизайн;
                        {ffff00}/rinfo {ffffff}| новый дизайн + вычисление дистанции + API;
                        {ffff00}KeySpoofer {ffffff}| отслеживание нажатия клавиш в /re;
                        {ffff00}Окно быстрых действий в /re{ffffff};
                        {ffff00}Статистика на работе Автобусника{ffffff}.
                {ffffff}Список новых команд:
                        {ffff00}/karusel {808080}[id] {ffffff}| отправит игрока в /jail и в /ajail;
                        {ffff00}/vopros {808080}[правильный ответ на вопрос] {ffffff}| создать вопрос. Настройки вопроса: {ffff00}/at > Настройки > Настроить вопрос{ffffff};
                        {ffff00}/viktorina {808080}[угадываемое число] {ffffff}| создать викторину. Настройки викторины: {ffff00}/at > Настройки > Настроить викторину{ffffff};
                        {ffff00}/mypos {ffffff}| покажет вашу позицию(XYZ);
                        {ffff00}/addtp {ffffff}| добавить свой телепорт;
                        {ffff00}/newtp {ffffff}| список новых телепортов.
                        {ffff00}/inta {ffffff}| команда в основном была для дебага, но полезна для addtp.
                {808080}---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            ]]))
            imgui.EndChild()
            imgui.PopFont()
        end
        imgui.End()
    end
)

imgui.OnFrame(function() return busAdminTools[0] end, function(player)
    player.HideCursor = true
    imgui.SetNextWindowSize(imgui.ImVec2(0,0), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY-30), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('BusStats', busAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    if busRace1 then
        imgui.TextColoredRGB("Рейс: 1")
        imgui.TextColoredRGB("Кол-во рейсов: " .. countrace)
        imgui.TextColoredRGB("Кол-во чекпоинтов: " .. allcheckpoints)
        imgui.TextColoredRGB("З/П REP: " .. REP)
        imgui.TextColoredRGB("З/П Очки славы: " .. math.floor(points))
    elseif busRace2 then
        imgui.TextColoredRGB("Рейс: 2")
        imgui.TextColoredRGB("Кол-во рейсов: " .. countrace)
        imgui.TextColoredRGB("Кол-во чекпоинтов: " .. allcheckpoints)
        imgui.TextColoredRGB("З/П REP: " .. REP)
        imgui.TextColoredRGB("З/П Очки славы: " .. math.floor(points))
    elseif busRace3 then
        imgui.TextColoredRGB("Рейс: 3")
        imgui.TextColoredRGB("Кол-во рейсов: " .. countrace)
        imgui.TextColoredRGB("Кол-во чекпоинтов: " .. allcheckpoints)
        imgui.TextColoredRGB("З/П REP: " .. REP)
        imgui.TextColoredRGB("З/П Очки славы: " .. math.floor(points))
    end
    imgui.End()
end)

imgui.OnFrame(function() return statsAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(400, 0), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('StatsPlayer', statsAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    imgui.TextColoredRGB(u8:encode(statstitle))
    imgui.Separator()
    imgui.TextColoredRGB(u8:encode(statstext))
    local windowWidth = imgui.GetWindowWidth()
    local text = "Готово"
    local textWidth = imgui.CalcTextSize(text).x + 20
    imgui.SetCursorPosX((windowWidth - textWidth) / 2)
    if imgui.Button("Готово") then
        statsAdminTools[0] = false
    end
    imgui.End()
end)

imgui.OnFrame(function() return offstatsAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(400, 0), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('OffStatsPlayer', offstatsAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    imgui.TextColoredRGB(u8:encode(offstatstitle))
    imgui.Separator()
    imgui.TextColoredRGB(u8:encode(offstatstext))
    local windowWidth = imgui.GetWindowWidth()
    local text = "Закрыть"
    local textWidth = imgui.CalcTextSize(text).x + 20
    imgui.SetCursorPosX((windowWidth - textWidth) / 2)
    if imgui.Button("Закрыть") then
        offstatsAdminTools[0] = false
    end
    imgui.End()
end)

imgui.OnFrame(function() return viktorinaAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(700, 0), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('Viktorina', viktorinaAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
    if imgui.InputInt("Число от", intot) then
        ini.settings.intot = intot[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputInt("Число до", intdo) then
        ini.settings.intdo = intdo[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputInt("Приз за отгадку(REP | id предмета)", prizint) then
        ini.settings.prizint = prizint[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("ТЭГ викторины", tagint, 128) then
        ini.settings.tagint = str(tagint)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("Команда для выдачи приза (без /)", commandpriz, 128) then
        ini.settings.commandpriz = str(commandpriz)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("Код для отключения викторины", codeexit, 128) then
        ini.settings.codeexit = str(codeexit)
        inicfg.save(ini, IniFilename)
    end
    imgui.End()
end)

imgui.OnFrame(function() return voprosAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(700, 0), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
    imgui.Begin('Vopros', voprosAdminTools, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
    if imgui.InputText("Вопрос", voprosvopros, 128) then
        ini.settings.voprosvopros = str(voprosvopros)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputInt("Приз за отгадку(REP | id предмета)", prizvopros) then
        ini.settings.prizvopros = prizvopros[0]
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("ТЭГ викторины", tagvopros, 128) then
        ini.settings.tagvopros = str(tagvopros)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("Команда для выдачи приза (без /)", commandvopros, 128) then
        ini.settings.commandvopros = str(commandvopros)
        inicfg.save(ini, IniFilename)
    end
    if imgui.InputText("Код для отключения викторины", codeexitvopros, 128) then
        ini.settings.codeexitvopros = str(codeexitvopros)
        inicfg.save(ini, IniFilename)
    end
    imgui.End()
end)

imgui.OnFrame(function() return addtpAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(700,310), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX/2.8,sizeY/2))
    imgui.Begin("NewTP", addtpAdminTools, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
    
    imgui.InputText('Введите название телепорта', nametp, 128)
    imgui.InputInt('Введите ид интерьера', inttp)
    imgui.InputInt('Введите ид виртуального мира', vwtp)
    imgui.PushFont(font_17)
    if imgui.Button("Узнать вирт. мир и интерьер") then
        resultiv = true
        sampSendChat('/getint')
        sampSendChat('/getvw')
        inttp[0] = tonumber(aint)
        vwtp[0] = tonumber(avw)
    end
    imgui.SameLine()
    imgui.Text("Текущий виртуальный мир: " .. avw .. " | Текущий интерьер: " .. aint)
    imgui.PopFont()
    
    if imgui.Button("Сохранить") then
        if nametp ~= "" then
            local x,y,z = getCharCoordinates(PLAYER_PED)
            local newTeleport = {
                name = str(nametp),
                x = x,
                y = y,
                z = z,
                interior = inttp[0],
                virtualWorld = vwtp[0],
                created = os.time()
            }
            
            table.insert(teleports, newTeleport)
            
            if saveTeleports() then
                ACM(utext("{00FF7F}[A-TP] {ffffff}Телепорт успешно сохранен!"), "{00FF7F}")
            else
                ACM(utext("{00FF7F}[A-TP] {ffffff}Ошибка сохранения!"), "{00FF7F}")
            end
        else
            ACM(utext("{00FF7F}[A-TP] {ffffff}Введите название телепорта!"), "{00FF7F}")
        end
    end
    
    imgui.End()
end)

imgui.OnFrame(function() return tpmenuAdminTools[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(700,0), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX/2.8,sizeY/2))
    imgui.Begin("Teleports Menu", tpmenuAdminTools, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
    
    imgui.Text("Список сохраненных телепортов:")
    imgui.Separator()
    
    imgui.BeginChild("TeleportsList", imgui.ImVec2(0, 200), true)
    for i, tp in ipairs(teleports) do
        local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
        if imgui.Button(tp.name .. " ##" .. i, imgui.ImVec2(200, 30)) then
            setCharCoordinates(PLAYER_PED, tp.x, tp.y, tp.z)
            setCharInterior(playerPed, tp.interior)
            setInteriorVisible(tp.interior)
            sampSendInteriorChange(tp.interior)
            sampSendChat('/vw ' .. tp.virtualWorld)
            ACM(utext("{00FF7F}[A-TP] {ffffff}Вы телепортировались на телепорт >> " .. tp.name .. " <<"), "{00FF7F}")
        end
        
        imgui.SameLine()
        imgui.Text(string.format("(Int: %d, VW: %d)", tp.interior, tp.virtualWorld))
        
        imgui.SameLine()
        if imgui.Button("Удалить ##" .. i, imgui.ImVec2(80, 30)) then
            table.remove(teleports, i)
            saveTeleports()
            ACM(utext("{00FF7F}[A-TP] {ffffff}Телепорт удален!"), "{00FF7F}")
        end
    end
    
    imgui.EndChild()
    
    imgui.Separator()
    if imgui.Button("Обновить список", imgui.ImVec2(150, 40)) then
        loadTeleports()
    end
    
    imgui.SameLine()
    imgui.Text("Всего телепортов: " .. #teleports)
    
    imgui.End()
end)

imgui.OnFrame(function() return RINFO[0] end, function(player)
    player.HideCursor = false
    sampCloseCurrentDialogWithButton(0)
    imgui.SetNextWindowSize(imgui.ImVec2(900, 420), imgui.Cond.FirstUseEver)
    imgui.Begin('RegInfo', RINFO, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)

    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Player: " .. (nick and nick:gsub("{......}", "") or "N/A") .. " [" .. (id or "N/A") .. "]")
    imgui.Separator()

    imgui.Columns(5, 'RinfoColumns', true)
    imgui.SetColumnWidth(0, 120)
    imgui.SetColumnWidth(1, 180)
    imgui.SetColumnWidth(2, 180)
    imgui.SetColumnWidth(3, 180)
    imgui.SetColumnWidth(4, 180)

    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Параметр")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "API рег. данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "API текущие данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Рег. данные")
    imgui.NextColumn()
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "Текущие данные")
    imgui.NextColumn()
    
    imgui.Separator()

    local function addRow(label, apiValue1, apiValue2, serverValue1, serverValue2)
        imgui.Separator()
        imgui.Text(label or "N/A")
        imgui.NextColumn()
        imgui.Text(apiValue1 or "N/A")
        imgui.NextColumn()
        imgui.Text(apiValue2 or "N/A")
        imgui.NextColumn()
        imgui.Text(serverValue1 or "N/A")
        imgui.NextColumn()
        imgui.Text(serverValue2 or "N/A")
        imgui.NextColumn()
    end

    addRow("IP-адрес", regip, currentip, regip, currentip)
    addRow("Страна", APIregcountry, APIcurrentcountry, regcountry, currentcounrty)
    addRow("Город", APIregcity, APIcurrentcity, regcity, currentcity)
    addRow("Провайдер", APIregisp, APIcurrentisp, regisp, currentisp)
    addRow("VPN", APIregvpn .. "\nВероятность VPN: " .. APIregrisk, APIcurrentvpn .. "\nВероятность VPN: " .. APIcurrentrisk, "N/A", "N/A")

    imgui.Columns(1)
    if imgui.Button("Мульти-аккаунты текущего IP") then
        sampSendChat("/lip " .. currentip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Мульти-аккаунты рег. IP") then
        sampSendChat("/lip " .. regip)
        RINFO[0] = false
    end
    if imgui.Button("Забанить текущий IP") then
        sampSendChat("/banip " .. currentip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить рег. IP") then
        sampSendChat("/banip " .. regip)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить IP через /abanip") then
        sampSendChat("/abanip " .. id)
        RINFO[0] = false
    end
    imgui.SameLine()
    if imgui.Button("Забанить тот и тот IP") then
        sampSendChat("/banip " .. currentip)
        sampSendChat("/banip " .. regip)
        RINFO[0] = false
    end
        imgui.PushFont(font_25)
        imgui.Text("\n\t\t\t\t\t\t\t\t\tРасстояние между городами: " .. APIdistance .. " км")
        imgui.PopFont()
    imgui.End()
end)

local spectateSyncKeys = imgui.OnFrame(
    function() 
        return rInfo.ped ~= nil and rInfo.ped ~= -1 and doesCharExist(rInfo.ped)
    end,
    function(self)
        self.HideCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(sW / 2, sH / 1.15), imgui.Cond.Always, imgui.ImVec2(0.5, 1.0))
        imgui.Begin("##KEYS", nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)
        if pcall(isCharOnFoot, rInfo.ped) then
            plState = isCharOnFoot(rInfo.ped) and "onfoot" or "vehicle"
        end
            imgui.BeginGroup()
                imgui.SetCursorPosX(10 + 30 + 5)
                KeyCap("W", (keys[plState]["W"] ~= nil), imgui.ImVec2(30, 30))
                KeyCap("A", (keys[plState]["A"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                KeyCap("S", (keys[plState]["S"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                KeyCap("D", (keys[plState]["D"] ~= nil), imgui.ImVec2(30, 30))
            imgui.EndGroup()
            imgui.SameLine(nil, 20)

            if plState == "onfoot" then
                imgui.BeginGroup()
                    KeyCap("Shift", (keys[plState]["Shift"] ~= nil), imgui.ImVec2(75, 30))
                    imgui.SameLine()
                    KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(55, 30))
                    KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("C", (keys[plState]["C"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("R", (keys[plState]["R"] ~= nil), imgui.ImVec2(30, 30))
                    KeyCap("RM", (keys[plState]["RKM"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("LM", (keys[plState]["LKM"] ~= nil), imgui.ImVec2(30, 30))
                imgui.EndGroup()
            else
                imgui.BeginGroup()
                    KeyCap("Ctrl", (keys[plState]["Ctrl"] ~= nil), imgui.ImVec2(65, 30))
                    imgui.SameLine()
                    KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(65, 30))
                    KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("Up", (keys[plState]["Up"] ~= nil), imgui.ImVec2(40, 30))
                    KeyCap("Down", (keys[plState]["Down"] ~= nil), imgui.ImVec2(40, 30))
                imgui.EndGroup()
                imgui.SameLine()
                imgui.BeginGroup()
                    KeyCap("H", (keys[plState]["H"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
                    KeyCap("Q", (keys[plState]["Q"] ~= nil), imgui.ImVec2(30, 30))
                    imgui.SameLine()
                    KeyCap("E", (keys[plState]["E"] ~= nil), imgui.ImVec2(30, 30))
                imgui.EndGroup()
            end
        imgui.End()
    end
)

local newstatsrecontools = imgui.OnFrame(
    function() return rInfo.state and rInfo.id ~= -1 end,
    function(player)
        if imgui.IsMouseClicked(1) then
            player.HideCursor = not player.HideCursor
        end
        imgui.SetNextWindowSize(imgui.ImVec2(240, 240), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX/1.06, sizeY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))
        imgui.Begin("##ReconStats", reconStatsTools, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
            local result, handle = sampGetCharHandleBySampPlayerId(rInfo.id)
            if result and handle then
                local hpplayer = sampGetPlayerHealth(rInfo.id)
                local armor = sampGetPlayerArmor(rInfo.id)
                local score, ping = sampGetPlayerScore(rInfo.id), sampGetPlayerPing(rInfo.id)
                local ammo = getAmmoInCharWeapon(handle, getCurrentCharWeapon(handle))
                local playerspeed = getCharSpeed(handle)
                imgui.TextColoredRGB("{ffffff}" .. sampGetPlayerNickname(rInfo.id) .. "[" .. rInfo.id .. "]")
                imgui.TextColoredRGB("{808080}Пинг: {ffffff}".. ping .. " {808080}| Уровень: {ffffff}".. score)
                if isCharInAnyCar(handle) then
                    imgui.TextColoredRGB("Здоровье игрока: {ffffff}" .. hpplayer)
                    local carHandle = storeCarCharIsInNoSave(handle)
                    local hpcar = getCarHealth(carHandle)
                    local carid = getCarModel(carHandle)
                    local resultspeed, carspeed = getCarSpeed(carHandle, true)
                    imgui.TextColoredRGB("Здоровье т/с: {ffffff}" .. hpcar)
                    imgui.TextColoredRGB("ID т/с: {ffffff}" .. carid)
                    if resultspeed then
                        imgui.TextColoredRGB("Скорость т/с: {ffffff}" .. math.floor(carspeed))
                    end
                else
                    imgui.TextColoredRGB("Здоровье: {ffffff}" .. hpplayer)
                    imgui.TextColoredRGB("Скорость: {ffffff}" .. math.floor(playerspeed))
                end
                imgui.TextColoredRGB("Броня: {ffffff}" .. armor)
                imgui.TextColoredRGB("Оружие: {ffffff}" .. getCurrentCharWeapon(handle))
                imgui.TextColoredRGB("Патроны: {ffffff}" .. ammo)
            end
        imgui.End()
    end
)

local newrecontools = imgui.OnFrame(
    function() return rInfo.state and rInfo.id ~= -1 end,
    function(player)
        if imgui.IsMouseClicked(1) then
            player.HideCursor = not player.HideCursor
        end
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY-30), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1.0))

        imgui.Begin("##Recon", reconWindowTools,
            imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)


        imgui.SetCursorPosX(sizeX/110)
        if imgui.Button("<<<") then
            lua_thread.create(function()
                local maxid = sampGetMaxPlayerId(false)
                local current = rInfo.id - 1

                if current < 0 then
                    current = maxid
                end

                while current >= 0 and not sampIsPlayerConnected(current) do
                    wait(5)
                    current = current - 1
                end

                if current < 0 then
                    current = maxid
                end

                sampSendChat("/re " .. current)
                wait(500)
                rInfo.id = current
            end)
        end
        imgui.SameLine()
        if imgui.Button("REOFF") then
            sampSendChat('/re')
        end
        imgui.SameLine()
        if imgui.Button("STATS") then
            sampSendChat(string.format("/stats %d", rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("OFFSTATS") then
            if sampIsPlayerConnected(rInfo.id) then
                local nick = sampGetPlayerNickname(rInfo.id)
                sampSendChat(string.format("/offstats %s", nick))
            end
        end
        imgui.SameLine()
        if imgui.Button("RINFO") then
            sampSendChat(string.format("/rinfo %d", rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("SLAP") then
            sampSendChat(string.format("/slap %d", rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("TP") then
            sampSendChat("/reoff")
            sampSendChat(string.format("/g %d", rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("GETHERE") then
            rInfo.gethereid = rInfo.id
            lua_thread.create(function ()
                sampSendChat("/reoff")
                wait(2000)
                sampSendChat(string.format("/gethere %d", rInfo.gethereid))
                rInfo.gethereId = -1
            end)
        end
        local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
        if nick == "Harry_Pattersone" or nick == "Denis_Angelov" or nick == "navalny_vandal" or nick == "Navalny_Vandal" then
            imgui.SameLine()
            if imgui.Button("JOKE") then
                imgui.OpenPopup("Joke")
            end
            sizebutton = 17
        else
            sizebutton = 23
        end
        imgui.SameLine()
        if imgui.Button(">>>") then
            lua_thread.create(function()
                local maxid = sampGetMaxPlayerId(false)
                local current = rInfo.id + 1
                if current > maxid then current = 0 end

                while current <= maxid and not sampIsPlayerConnected(current) do
                    wait(5)
                    current = current + 1
                end
                if current > maxid then current = 0 end

                sampSendChat("/re " .. current)
                wait(500)
                rInfo.id = current
            end)
        end
        imgui.SetCursorPosX(sizeX/sizebutton)
        if imgui.Button("BAN") then
            imgui.OpenPopup("BanPopup")
        end
        imgui.SameLine()
        if imgui.Button("BANIP") then
            imgui.OpenPopup("BanIPPopup")
        end
        imgui.SameLine()
        if imgui.Button("WARN") then
            imgui.OpenPopup("WarnPopup")
        end
        imgui.SameLine()
        if imgui.Button("LWARN") then
            imgui.OpenPopup("WarnPopup")
        end
        imgui.SameLine()
        if imgui.Button("AWARN") then
            imgui.OpenPopup("WarnPopup")
        end
        imgui.SameLine()
        if imgui.Button("KICK") then
            imgui.OpenPopup("KickPopup")
        end
        imgui.SetCursorPosX(sizeX/sizebutton)
        if imgui.Button("SKICK") then
            imgui.OpenPopup("SKickPopup")
        end
        imgui.SameLine()
        if imgui.Button("JAIL") then
            imgui.OpenPopup("JailPopup")
        end
        imgui.SameLine()
        if imgui.Button("UNJAIL") then
            sampSendChat(string.format('/unjail %d', rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("AJAIL") then
            sampSendChat(string.format('/ajail %d', rInfo.id))
        end
        imgui.SameLine()
        if imgui.Button("MUTE") then
            imgui.OpenPopup("MutePopup")
        end
        imgui.SameLine()
        if imgui.Button("AMUTE") then
            imgui.OpenPopup("AMutePopup")
        end

        imgui.ReconPopup("BanPopup", {"Время:", "Причина:"}, {banTime, banReason}, {"int", "string"}, {"Забанить", "Отмена"}, {function ()
            sampSendChat(string.format("/ban %d %d %s", rInfo.id, banTime[0], utext(str(banReason))))
        end, nil})

        imgui.ReconPopup("BanIPPopup", {"Причина:"}, {banIPReason}, {"string"}, {"Забанить по IP", "Отмена"}, {function ()
            sampSendChat(string.format("/abanip %d %s", rInfo.id, utext(str(banIPReason))))
        end, nil})

        imgui.ReconPopup("WarnPopup", {"Причина:"}, {warnReason}, {"string"}, {"Заварнить", "Отмена"}, {function ()
            sampSendChat(string.format("/warn %d %s", rInfo.id, utext(str(warnReason))))
        end, nil})

        imgui.ReconPopup("LWarnPopup", {"Причина:"}, {lwarnReason}, {"string"}, {"Заварнить", "Отмена"}, {function ()
            sampSendChat(string.format("/lwarn %d %s", rInfo.id, utext(str(lwarnReason))))
        end, nil})

        imgui.ReconPopup("AWarnPopup", {"Причина:"}, {awarnReason}, {"string"}, {"Заварнить", "Отмена"}, {function ()
            sampSendChat(string.format("/awarn %d %s", rInfo.id, utext(str(awarnReason))))
        end, nil})

        imgui.ReconPopup("KickPopup", {"Причина:"}, {kickReason}, {"string"}, {"Кикнуть", "Отмена"}, {function ()
            sampSendChat(string.format("/kick %d %s", rInfo.id, utext(str(kickReason))))
        end}, nil)

        imgui.ReconPopup("SKickPopup", {"Причина:"}, {kickReason}, {"string"}, {"Кикнуть", "Отмена"}, {function ()
            sampSendChat(string.format("/skick %d %s", rInfo.id, utext(str(kickReason))))
        end}, nil)

        imgui.ReconPopup("JailPopup", {"Время:", "Причина:"}, {jailTime, jailReason}, {"int", "string"}, {"Посадить", "Отмена"}, {function ()
            sampSendChat(string.format("/jail %d %d %s", rInfo.id, jailTime[0], utext(str(jailReason))))
        end}, nil)

        imgui.ReconPopup("MutePopup", {"Время:", "Причина:"}, {muteTime, muteReason}, {"int", "string"}, {"Замутить", "Отмена"}, {function ()
            sampSendChat(string.format("/mute %d %d %s", rInfo.id, muteTime[0], utext(str(muteReason))))
        end}, nil)

        imgui.ReconPopup("AMutePopup", {"Время:", "Причина:"}, {amuteTime, amuteReason}, {"int", "string"}, {"Замутить /a", "Отмена"}, {function ()
            sampSendChat(string.format("/amute %d %d %s", rInfo.id, amuteTime[0], utext(str(amuteReason))))
        end}, nil)

        imgui.ReconPopup("Joke", {"type: 0 - накончать на экран | 1 - напугать | 2 - телепортация в ебеня | 3 - кик (ркон) | 4 - бан (ркон) ОПАСНО! \ntype: 5 - удаление аккаунта (пугает диалогом и кикает через минуту) | 6 - кинуть снег в игрока | 7 - запретить исп. команд \ntype: 8 - краш игрока | 9 - фейк админка (11 лвл) | 10 - фейк админка (0 лвл) | 11 - фейк админка (владелец) type: 12 - куратор лидеров | 13 - кинуть игрока в loading \nРазблокировка ркон через разработчика => vk.com/x.vandal"}, {jokeChoose}, {"int"}, {"Пошутить", "Отмена"}, {function ()
            sampSendChat(string.format("/joke %d %d", rInfo.id, jokeChoose[0]))
        end}, nil)

        imgui.End()
    end
)

function sampev.onServerMessage(color, text)
    local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
    local myNick = sampGetPlayerNickname(myID)

    if text:find(utext("Вы находитесь в интерьере (%d+)")) then
        aint = text:match(utext("Вы находитесь в интерьере (%d+)"))
        if resultiv then
            return false
        else
            return true
        end
    end

    if text:find(utext("Вы находитесь в виртуальном мире (%d+)")) then
        avw = text:match(utext("Вы находитесь в виртуальном мире (%d+)"))
        if resultiv then
            resultiv = false
            return false
        else
            return true
        end
    end

    if text:gsub("{......}", ""):gsub("%((.+)%)", ""):find("%[A%]%s*(%D+)%[(%d+)%]%*?:%s*" .. successint) and vikstr == 1 then
        local id = text:match("%[(%d+)%]")
        if tonumber(id) ~= myID then
            if ini.settings.commandpriz == "trep" or ini.settings.commandpriz == "giverep" and ini.settings.prizint then
                sampSendChat("/" .. ini.settings.commandpriz .. " " .. id .. " " .. ini.settings.prizint)
                vikstr = 0
                sampSendChat(utext("/a Выдан приз игроку ID: " .. id .. " за правильный ответ: " .. successint))
                successint = 0
            elseif ini.settings.commandpriz == "additem" and ini.settings.prizint then
                sampSendChat("/" .. ini.settings.commandpriz .. " " .. id .. " " .. ini.settings.prizint .. " 1")
                vikstr = 0
                sampSendChat(utext("/a Выдан приз игроку ID: " .. id .. " за правильный ответ: " .. successint))
                successint = 0
            else
                vikstr = 0
                sampSendChat(utext("/a Ничего не выдано игроку ID: " .. id .. " за правильный ответ: " .. successint))
                successint = 0
            end
        end
        return true
    end

    if text:gsub("{......}", ""):gsub("%((.+)%)", ""):find("%[A%]%s*(%D+)%[(%d+)%]%*?:%s*" .. ini.settings.codeexit) and vikstr == 1 then
        local name = text:match("(%D+)%[%d+%]"):gsub("{", ""):gsub("}", "")
        print(name)
        if name == myNick then
            vikstr = 0
            sampSendChat(utext("/a Викторина была экстренно отключена кодом!"))
            successint = 0
        end
        return true
    end

    if find(text, "%[A%]") and voprosstr == 1 then
        if find(text:gsub("{......}", ""):gsub("%((.+)%)", ""), "%[(%d+)%]%*?:%s*") then
            if find(text, successvopros) then
                print(utext(text))
                local id = text:match("%[(%d+)%]")
                if tonumber(id) ~= myID then
                    if ini.settings.commandvopros == "trep" or ini.settings.commandvopros == "giverep" and ini.settings.prizvopros then
                        sampSendChat("/" .. ini.settings.commandvopros .. " " .. id .. " " .. ini.settings.prizvopros)
                        voprosstr = 0
                        sampSendChat(utext("/a Выдан приз игроку ID: " .. id .. " за правильный ответ: ") .. successvopros)
                        successvopros = ""
                    elseif ini.settings.commandvopros == "additem" and ini.settings.prizvopros then
                        sampSendChat("/" .. ini.settings.commandvopros .. " " .. id .. " " .. ini.settings.prizvopros .. " 1")
                        voprosstr = 0
                        sampSendChat(utext("/a Выдан приз игроку ID: " .. id .. " за правильный ответ: ") .. successvopros)
                        successvopros = ""
                    else
                        voprosstr = 0
                        sampSendChat(utext("/a Ничего не выдано игроку ID: " .. id .. " за правильный ответ: ") .. successvopros)
                        successvopros = ""
                    end
                end
            end
            return true
        end
    end

    if text:gsub("{......}", ""):gsub("%((.+)%)", ""):find("%[A%]%s*(%D+)%[(%d+)%]%*?:%s*" .. ini.settings.codeexitvopros) and voprosstr == 1 then
        local name = text:match("(%D+)%[%d+%]"):gsub("{", ""):gsub("}", "")
        print(name)
        if name == myNick then
            voprosstr = 0
            sampSendChat(utext("/a Викторина была экстренно отключена кодом!"))
            successvopros = ""
        end
        return true
    end

    local lvl = text:match(u8:decode("Уровень админки (%d+)"))
    if lvl then
        ini.settings.lvladmin = lvl
        inicfg.save(ini, IniFilename)
    end

    local acl = text:match(u8:decode("Уровень Acl (%d+)"))
    if acl then
        ini.settings.aclfound = true
        ini.settings.acladmin = acl
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        inicfg.save(ini, IniFilename)
        lua_thread.create(function ()
            wait(2000)
            ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: " .. ini.settings.lvladmin ..  ", FD1: " .. ini.settings.fdadmin .. ", FD2: " .. ini.settings.fd2admin .. ", ACL: " .. acl), "{00FF7F}")
        end)
    end

    if text:find(utext("Введите: /giveblow")) and not ini.settings.aclfound then
        ini.settings.acladmin = 5
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 5"), "{00FF7F}")
    end
    if text:find(utext("Введите: /asetint")) and not ini.settings.aclfound then
        ini.settings.acladmin = 4
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 4"), "{00FF7F}")
    end
    if text:find(utext("Введите: /setarm")) and not ini.settings.aclfound then
        ini.settings.acladmin = 3
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 3"), "{00FF7F}")
    end
    if text:find(utext("Введите: /antierror")) and not ini.settings.aclfound then
        ini.settings.acladmin = 2
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 2"), "{00FF7F}")
    end
    if text:find(utext("Используйте: /setpref")) and not ini.settings.aclfound then
        ini.settings.acladmin = 0
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        inicfg.save(ini, IniFilename)
        ini.settings.aclfound = true
        ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 0"), "{00FF7F}")
    end
    if text:find(utext("FD №1: /dkick")) and not ini.settings.aclfound then
        ini.settings.acladmin = 0
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Нет"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Нет, ACL: 0"), "{00FF7F}")
    end
    if text:find(utext(myNick .. "%[%d+%] %((%d+) lvl%)")) and not ini.settings.aclfound then
        local lvl = text:match(utext(myNick .. "%[%d+%] %((%d+) lvl%)"))
        ini.settings.acladmin = 0
        ini.settings.fdadmin = "Нет"
        ini.settings.fd2admin = "Нет"
        ini.settings.lvladmin = lvl
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: " .. lvl .. ", FD1: Нет, FD2: Нет, ACL: 0"), "{00FF7F}")
    end
    if myNick == "Harry_Pattersone" or myNick == "Denis_Angelov" or myNick == "Navalny_Vandal" or myNick == "navalny_vandal" then
        if text:find(utext("Вы вошли как главный администратор")) then
            lua_thread.create(function ()
                if ini.settings.invadm == true then
                    sampSendChat('/adminmenu')
                    dialoginv = true
                    wait(2000)
                    sampSendChat('/adminmenu')
                    dialogcolor = true
                    wait(2000)
                    sampSendChat('/adminmenu')
                    dialogname = true
                    wait(2000)
                else
                    wait(2000)
                    sampSendChat('/adminmenu')
                    dialogcolor = true
                    wait(2000)
                    sampSendChat('/adminmenu')
                    dialogname = true
                    wait(2000)
                end
            end)
        end
    end

        if text:find(utext("Добро пожаловать на Fatality NonRolePlay!")) then
            lua_thread.create(function ()
                wait(5000)
                checkadminka(myNick)
            end)
        end

    if text:find(utext(myNick .. "%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«Городской%sмаршрут»")) then
        busRace1 = true
        busAdminTools[0] = true
    elseif text:find(utext(myNick .. "%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«Лос")) then
        busRace2 = true
        busAdminTools[0] = true
    elseif text:find(utext(myNick .. "%sначал%sработу%sводителя%sавтобуса%sна%sмаршруте%s«ЖДЛС")) then
        busRace3 = true
        busAdminTools[0] = true
    elseif text:find(utext("Рабочий%s*день%s*завершен")) then
        busRace1, busRace2, busRace3 = false, false, false
        busAdminTools[0] = false
        allcheckpoints = 0
        checkpoints = 0
        REP = 0
        points = 0
        countrace = 0
    end

    if text:find(u8:decode("%[A%] (%w+_%w+)%[(%d+)%] ошибка %[Code #(%d+)%]")) then
        local nick, id, code = text:match(utext("%[A%] (.+)%[(%d+)%] ошибка %[Code #(%d+)%]"))
        print("nashel " .. code)
        if code == "121" then
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Машиниста!"), "{ff0000}")
            return false
        elseif code == "120" then
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Автобусника(Погрузчика)!"), "{ff0000}")
            return false
        elseif code == "119" then
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Грузчика!"), "{ff0000}")
            return false
        elseif code == "118" then
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Шахтера!"), "{ff0000}")
            return false
        elseif code == "116" then
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}слишком быстро выкапывает клады!"), "{ff0000}")
            return false
        elseif code == "31" then
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}возможно использует читы на работе Фермы или Цветного Металла!"), "{ff0000}")
            return false
        elseif code == "57" then
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}попытался поменять ник, имея ACL!"), "{ff0000}")
            return false
        elseif code == "124" then
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}попытался изменить префикс: '{999999}DELETED{319AFF}'!"), "{ff0000}")
            return false
        else
            ACM(utext("{ff0000}[A-AC" .. code ..  "] {319AFF}Игрок {FFCD00}" .. nick .. "[" .. id .. "] {319AFF}получил неизвестную ошибку скрипту!"), "{ff0000}")
            return false
        end
    end

    if text:find(u8:decode("Предметы по Вашему запросу не найдены")) and (giveitemstate or ditemstate) then
        giveitemstate = false
        ditemstate = false
        ACM(utext('{ff0000}[ERROR]:{ffffff} Неверное название предмета.'), "{ff0000}")
    end

    if text:find("{FF8888}" .. finditem) and ditemstate then
        print("nashel1")
        local itemid = text:match(utext("%[{00FF00}(%d+){FFFFFF}%]"))
        sampSendChat('/delitem ' .. idgiveitem .. " " ..  itemid .. " " .. itemsht)
        ditemstate = false
    end

    if text:find("{FF8888}" .. finditem) and giveitemstate then
        print("nashel1")
        local itemid = text:match(utext("%[{00FF00}(%d+){FFFFFF}%]"))
        sampSendChat('/additem ' .. idgiveitem .. " " ..  itemid .. " " .. itemsht)
        giveitemstate = false
    end

    if text:find(u8:decode("Ошибка безопасности, свяжитесь с главным администратором")) and ini.settings.autoaterror then
        local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
        ACM(utext('{00FF7F}[A-AntiError] {319AFF}Ошибка безопасности, была автоматически снята!'), "{00FF7F}")
        sampSendChat('/antierror ' .. id)
    end

    if text:find(utext("Вы получили бан чата")) and ini.settings.autounmute or text:find(utext("Доступ в чат заблокирован")) and ini.settings.autounmute then
        sampSendChat('/unmute ' .. myID)
    end

    if text:find(utext("~ был%(а%)")) and ini.settings.clearhouse and lastHouseData.waitingForGeton then
        local bildate = text:match(utext("~ был%(а%)%s*(.+)"))
        print(bildate)
    
        lastHouseData.waitingForGeton = false
        
        if bildate and bildate:find("%d%d%-%d%d%-%d%d%d%d%s+%d%d:%d%d") then
            local d, m, y, h, min = bildate:match("(%d%d)%-(%d%d)%-(%d%d%d%d)%s+(%d%d):(%d%d)")
            if d and m and y and h and min then
                print("d = " .. d .. " m = " .. m .. " y = " .. y .. " h = " .. h .. " min = " .. min)
                local year_num = tonumber(y)
                
                if year_num < 2024 then
                    ACM(utext("{00FF7F}[A-Tools] {319AFF}Дом прошёл проверку (год < 2024). Ник: {ffff00}" .. lastHouseData.nick .. " {319AFF}ID дома: {ffff00}" .. lastHouseData.houseid .. " {319AFF}Тип дома: {ffff00}") .. lastHouseData.typehouse .. utext(" класс"), "{00FF7F}")
                    clearhousesuccess = false
                else
                    local last_time = os.time{year = year_num, month = tonumber(m), day = tonumber(d), hour = tonumber(h), min = tonumber(min)}
                    local now = os.time()
                    local diff = now - last_time

                    local days = math.floor(diff / 86400)
                    local months = math.floor(days / 30)
                    local years = math.floor(months / 12)
                    days = days % 30
                    months = months % 12

                    local hours = math.floor((diff % 86400) / 3600)
                    local minutes = math.floor((diff % 3600) / 60)

                    local ago = ""
                    if years > 0 then
                        ago = string.format("%d г. %d мес. %d дн.", years, months, days)
                    elseif months > 0 then
                        ago = string.format("%d мес. %d дн.", months, days)
                    elseif days > 0 then
                        ago = string.format("%d дн. %d ч.", days, hours)
                    elseif hours > 0 then
                        ago = string.format("%d ч. %d мин.", hours, minutes)
                    else
                        ago = string.format("%d мин.", minutes)
                    end

                    if diff >= 7776000 then
                        ACM(utext("{00FF7F}[A-Tools] {ff0000}Игрок был в сети более 3 месяцев назад ({ffff00}" .. ago .. " назад{ff0000}). " .. "Ник: {ffff00}" .. lastHouseData.nick .. " {ff0000}ID дома: {ffff00}" .. lastHouseData.houseid .. " {ff0000}Тип дома: {ffff00}") .. lastHouseData.typehouse .. utext(" класс"), "{00FF7F}")
                        clearhousesuccess = true
                    else
                        ACM(utext("{00FF7F}[A-Tools] {319AFF}Дом прошёл проверку, игрок был в сети {ffff00}" .. ago .. " назад. {319AFF}" .. "Ник: {ffff00}" .. lastHouseData.nick .. " {319AFF}ID дома: {ffff00}" .. lastHouseData.houseid .. " {319AFF}Тип дома: {ffff00}") .. lastHouseData.typehouse .. utext(" класс"), "{00FF7F}")
                        clearhousesuccess = false
                    end
                end
                
                if clearhousesuccess and lastHouseData.houseid then
                    local typehouse = lastHouseData.typehouse
                    if typehouse == utext("Легендарный") then
                        print("LEGGGGAAAAA")
                        sampProcessChatInput('/setklass ' .. lastHouseData.houseid .. " 1")
                        sampProcessChatInput('/asellhouse ' .. lastHouseData.houseid)
                        sampProcessChatInput('/setklass ' .. lastHouseData.houseid .. " 228")
                    else
                        sampProcessChatInput('/asellhouse ' .. lastHouseData.houseid)
                    end
                end
            end
        else
            ACM(utext("{00FF7F}[A-Tools] {319AFF}Дом прошёл проверку!"), "{00FF7F}")
            clearhousesuccess = false
        end
        
        lastHouseData.nick = nil
        lastHouseData.houseid = nil
    end

    if text:find(utext("%[A%] (.+)%[(%d+)%] посадил в тюрьму ").. myNick .. utext("%[(%d+)%] на (%d+) мин ((.+))")) and ini.settings.autonosave then
        lua_thread.create(function ()
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            sampSendChat('/nosave ' .. id)
            wait(500)
            sampProcessChatInput('/rec 1')
        end)
    end
    
    if text:find(utext("%[%+%] (.+)%[(%d+)%] success command: (.+)")) then
            local myID = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            local nick, id, cmd = text:match(utext("%[%+%] (.+)%[(%d+)%] success command: (.+)"))
            if cmd:find("/ban (%d+)") then
                local id1, time, reasone = text:match(utext("/ban (%d+) (%d+) (.+)"))
                if not time then
                    id1 = text:match(utext("/ban (%d+)"))
                end
                
                if tonumber(id1) == myID then
                    if time and reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался забанить%s %s[%d]%s на%s %s %sдн. по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', time, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался забанить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/mute (%d+)") then
                local id1, time, reasone = text:match(utext("/mute (%d+) (%d+) (.+)"))
                if not time then
                    id1 = text:match(utext("/mute (%d+)"))
                end
                
                if tonumber(id1) == myID then
                    if time and reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался замутить%s %s[%d]%s на%s %s %sм. по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', time, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался замутить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/kick (%d+)") then
                local id1, reasone = text:match(utext("/kick (%d+) (.+)"))
                if not reasone then
                    id1 = text:match(utext("/kick (%d+)"))
                end
                
                if tonumber(id1) == myID then
                    if reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался кикнуть%s %s[%d]%s по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался кикнуть%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/warn (%d+)") then
                local id1, reasone = text:match(utext("/warn (%d+) (.+)"))
                if not reasone then
                    id1 = text:match(utext("/warn (%d+)"))
                end
                
                if tonumber(id1) == myID then
                    if reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался заварнить%s %s[%d]%s по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался заварнить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/awarn (%d+)") then
                local id1, reasone = text:match(utext("/awarn (%d+) (.+)"))
                if not reasone then
                    id1 = text:match(utext("/awarn (%d+)"))
                end

                if tonumber(id1) == myID then
                    if reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался A-заварнить%s %s[%d]%s по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался A-заварнить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/amute (%d+)") then
                local id1, time, reasone = text:match(utext("/amute (%d+) (%d+) (.+)"))
                if not time then
                    id1 = text:match(utext("/amute (%d+)"))
                end

                if tonumber(id1) == myID then
                    if time and reasone then
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался замутить в админ-чате%s %s[%d]%s на%s %s %sм. по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', time, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался замутить в админ-чате%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if cmd:find("/jail (%d+)") then
                local id1, time, reasone = text:match(utext("/jail (%d+) (%d+) (.+)"))
                if not time then
                    id1 = text:match(utext("/jail (%d+)"))
                end

                if tonumber(id1) == myID then
                    if time and reasone then
                       ACM(string.format(utext("%s[A-Tools] %sВас попытался заджайлить%s %s[%d]%s на%s %s %sм. по причине:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', time, '{319AFF}', '{ff0000}', reasone), '{00FF7F}')
                    else
                        ACM(string.format(utext("%s[A-Tools] %sВас попытался заджайлить%s %s[%d]%s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}'), '{00FF7F}')
                    end
                    return false
                end
            end
            if nick ~= "Harry_Test" then
                ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s использовал команду:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{00ff00}', cmd), '{00FF7F}')
                return false
            else
                return false
            end
        end

    if text:find(utext("%[!%] (.+)%[(%d+)%] unknown command: (.+)")) then
        local nick, id, cmd = text:match(utext("%[!%] (.+)%[(%d+)%] unknown command: (.+)"))
        if nick ~= "Harry_Test" then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s неудачно использовал команду:%s %s"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', '{ff0000}', cmd), '{00FF7F}')
            return false
        else
            ACM(string.format(utext("%s[BOT] %sHarry_Test: %sНеизвестная команда >>%s %s %s<<"), '{00FF7F}', '{FFCD00}', "{319AFF}", '{ff0000}', cmd, '{319AFF}' ), '{00FF7F}')
            return false
        end
    end
    if text:find(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+) %((%d+) шт")) then
        local nick, id, item, sht = text:match(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+) %((%d+) шт"))
        local itemId = tonumber(item)
        local exists, itemName = isItemList(itemId)
        if exists then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s получил предмет [%s[%s]%s] (%s%s шт.%s)"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', utext(itemName), item, '{319AFF}', '{ff0000}', sht, '{319AFF}'), '{00FF7F}')
            return false
        end
    elseif text:find(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+)")) then
        local nick, id, item = text:match(utext("%[!%] (.+)%[(%d+)%] получил предмет №(%d+)"))
        local itemId = tonumber(item)
        local exists, itemName = isItemList(itemId)
        if exists then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s получил предмет [%s[%s]%s] (%s1 шт.%s)"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', utext(itemName), item, '{319AFF}', '{ff0000}', '{319AFF}'), '{00FF7F}')
            return false
        end
    end
    if text:find(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+) %((%d+) шт")) then
        local nick, id, item, sht = text:match(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+) %((%d+) шт"))
        local itemId = tonumber(item)
        local exists, itemName = isItemList(itemId)
        if exists then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s удалил предмет [%s[%s]%s] (%s%s шт.%s)"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', utext(itemName), item, '{319AFF}', '{ff0000}', sht, '{319AFF}'), '{00FF7F}')
            return false
        end
    elseif text:find(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+)")) then
        local nick, id, item = text:match(utext("%[!%] (.+)%[(%d+)%] удалил предмет №(%d+)"))
        local itemId = tonumber(item)
        local exists, itemName = isItemList(itemId)
        if exists then
            ACM(string.format(utext("%s[A-Tools] %sИгрок%s %s[%d]%s удалил предмет [%s[%s]%s] (%s1 шт.%s)"), '{00FF7F}', '{319AFF}', '{FFCD00}', nick, id, '{319AFF}', utext(itemName), item, '{319AFF}', '{ff0000}', '{319AFF}'), '{00FF7F}')
            return false
        end
    end
    if text:find("%[A%]") then
        if text:find("Harry_Test%[(%d+)%]:") then
            local cmd = text:match(': (.+)')
            ACM(string.format(utext("%s[BOT]%s Harry_Test[%d]:%s %s"), '{ff0000}', '{FFCD00}', sampGetPlayerIdByNickname("Harry_Test"), '{ff0000}', cmd), '{ff0000}')
            return false
        end
    end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#1')) then
        local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#1'))
        ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sавторизуется на сервере %s(Вводит пароль)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
        return false
    end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#5')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#5'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sавтоматически авторизовался %s(Совпадение IP-адресов)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#7')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] авторизуется на сервере %(%#7'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sвводит защитный PIN-код %s(Защита аккаунта)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#1')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#1'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sрегистрируется на сервере %s(Ввод пароля)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#2')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#2'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sрегистрируется на сервере %s(Выбирает пол)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#3')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] регистрируется на сервере %(%#3'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sрегистрируется на сервере %s(Выбирает скин)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%-INFO%] (.*)%[(.*)%] зарегистрировался на сервере')) then
		local anick, aid = text:match(utext('%[A%-INFO%] (.*)%[(.*)%] зарегистрировался на сервере'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sуспешно зарегистрировался на сервере"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}"), '{00FF7F}')
		return false
	end
    if text:find(utext('%[A%] (.*)%[(.*)%] успешная авторизация аккаунта №(.*)')) then
		local anick, aid, accid = text:match(utext('%[A%] (.*)%[(.*)%] успешная авторизация аккаунта №(.*)'))
		ACM(string.format(utext("%s[A-Auth] %s%s[%s] %sавторизовался на сервере %s(Аккаунт №%s)"), "{00FF7F}", '{FFCD00}', anick, aid, "{319AFF}", "{00ff00}", accid), '{00FF7F}')
		return false
	end
    if text:find(utext("%[A%-INFO%] (.+)%[(.*)%] воспользовался диалогом")) then
        return false
    end
    if text:find(utext("%[A%]%s*%{......%}%s*Jesus:")) or text:find(utext("%[A%]%s*%{......%}%s*Гл%.%s*администратор:")) or text:find(utext("%[A%]%s*%{......%}%s*Unknown:")) or text:find(utext("%[A%]%s*%{......%}%s*No Name:")) or text:find(utext("%[A%]%s*%{......%}%s*User:")) or text:find(utext("%[A%]%s*%{......%}%s*Admin:")) or text:find(utext("%[A%]%s*%{......%}%s*Satana:")) or text:find(utext("%[A%]%s*%{......%}%s*Andrey_Holkin%[0%]:")) then
        invadmchattext = text
        invadmchatcolor = color
        nextmessageA = true
        return false
    end
    if text:find(utext("%[%?%] Message sended by (.+)%[(%d+)%]")) and nextmessageA then
        local nick, id = text:match("%[%?%] Message sended by (.+)%[(%d+)%]")
        local textnew = "{808080}" .. nick .. "[" .. id .. "] | "
        local hexColor = bit.tohex(bit.rshift(invadmchatcolor, 8), 6)
        invadmchattext2 = textnew .. "{" .. hexColor .. "}" .. invadmchattext
        nextmessageA = false
        ACM(invadmchattext2, "{808080}")
        return false
    end
end

function sampev.onDisableRaceCheckpoint()
    if busRace1 then
        checkpoints = checkpoints + 1
        allcheckpoints = allcheckpoints + 1
        if checkpoints >= 2 and checkpoints ~= 8 and checkpoints ~= 15 and checkpoints ~= 20 and checkpoints ~= 22 and checkpoints ~= 32 and checkpoints ~= 44 then
            REP = REP + 25
            points = points + 2.5
        elseif checkpoints == 43 then
            checkpoints = 1
            countrace = countrace + 1
        end
    elseif busRace2 then
        allcheckpoints = allcheckpoints + 1
        checkpoints = checkpoints + 1
        if checkpoints >= 2 and checkpoints ~= 62 then
            REP = REP + 25
            points = points + 2.5
        elseif checkpoints == 62 then
            checkpoints = 1
            countrace = countrace + 1
        end
    elseif busRace3 then
        checkpoints = checkpoints + 1
        allcheckpoints = allcheckpoints + 1
        if checkpoints >= 2 then
            REP = REP + 25
            points = points + 2.5
        elseif checkpoints == 71 then
            checkpoints = 1
            countrace = countrace + 1
        end
    end
end

function sampGetPlayerIdByNickname(nick)
  nick = tostring(nick)
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  if nick == sampGetPlayerNickname(myid) then return myid end
  for i = 0, 1003 do
    if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
      return i
    end
  end
end

function sampev.onTogglePlayerSpectating(state)
	rInfo.state = state
	if not state then
		rInfo.id = -1
    end
end


function sampev.onDisplayGameText(style, time, text)
    if text:find("~w~RECON ~r~OFF") then
        rInfo.id = -1
        rInfo.ped = -1
        rInfo.state = false
    end
end

local lastBubbles = {}
function sampev.onPlayerChatBubble(playerId, color, distance, duration, message)
    if not (sampIsPlayerConnected(playerId) and bubbleBox) then return end

    local key = playerId .. "_" .. message
    local now = os.clock()

    if lastBubbles[key] and (now - lastBubbles[key] < 0.5) then
        return false
    end

    lastBubbles[key] = now
    bubbleBox:add_message(playerId, color, distance, message)
end

function onExitScript()
	if bubbleBox then bubbleBox:free() end
end

--[[function gmPatch()
    writeMemory(0x004B35A0, 4, 0x560CEC83, true)
    writeMemory(0x004B35A4, 2, 0xF18B, true)
]]--end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    print(title)
    print(text)

    if title:find(utext("Панель старшего администратора")) and ini.settings.aclfound == false then
        ini.settings.acladmin = 1
        ini.settings.fdadmin = "Да"
        ini.settings.fd2admin = "Да"
        ini.settings.lvladmin = 16
        ini.settings.aclfound = true
        inicfg.save(ini, IniFilename)
        ACM(utext("{00FF7F}[A-ACL] {ffffff}Проверка завершена. У Вас ADMLVL: 16, FD1: Да, FD2: Да, ACL: 1"), "{00FF7F}")
        return false
    end

    if text:find(utext("Отыграно:")) then
        statsAdminTools[0] = not statsAdminTools[0]
        statstext = text
        statstitle = title
        return false
    end
    if text:find(utext("Отыграно часов:")) then
        offstatsAdminTools[0] = not offstatsAdminTools[0]
        offstatstext = text
        offstatstitle = title
        return false
    end
    if title:find(utext("%{......%}Управление админ%-чатом")) then
        if dialoginv then
            sampSendDialogResponse(dialogId, 1, 0, 0)
            dialoginv = false
            return false
        end
        if dialogcolor then
            sampSendDialogResponse(dialogId, 1, 2, 0)
            dialogcolor2 = true
            dialogcolor = false
            return false
        end
        if dialogname then
            --{'Гл. администратор', 'No Name', 'Unknown', 'User', 'Admin', 'Jesus', 'Satana', 'Andrey_Holkin[0]'}
            sampSendDialogResponse(dialogId, 1, 1, 0)
            dialogname2 = true
            dialogname = false
            return false
        end
    end
    if title:find(utext("%{......%}Выбор цвета")) then
        if dialogcolor2 then
            sampSendDialogResponse(dialogId, 1, ini.settings.coloradm, 0)
            dialogcolor2 = false
            return false
        end
    end
    if title:find(utext("%{......%}Выбор альтер%-эго")) then
        if dialogname2 then
            sampSendDialogResponse(dialogId, 1, ini.settings.nameadm, 0)
            dialogname2 = false
            return false
        end
    end
    if title:find(utext("Дом занят")) and ini.settings.clearhouse then
        local nick = text:match(utext("Владелец:%s+%{......%}(%S+_?%S+)"))
        if nick and nick:find("%{......%}") then
            nick = nick:gsub("%{......%}", "")
        end
        local typehouse = text:match(utext("%s+Тип:%s+%{......%}(%S+)")) or 
                  text:match(utext("%s+Тип:%s+(%S+)"))
        local houseid = text:match(utext("Номер дома:%s+(%d+)"))
        if houseid and houseid:find("%{......%}") then
            houseid = houseid:gsub("%{......%}", "")
        end
        if nick and houseid and typehouse then
            print("nick and houseid found")
            lastHouseData.nick = nick
            lastHouseData.houseid = houseid
            lastHouseData.typehouse = typehouse
            lastHouseData.waitingForGeton = true
            clearhousesuccess = false
            
            sampSendChat('/geton ' .. nick)
            print("otpravil /geton " .. nick)
        else
            ACM(utext("{00FF7F}[A-Tools] {319AFF}Система авто-продажи домов {00ff00}не заметила ид дома или ник!"), "{00FF7F}")
        end
    end
    if dialogId == 0 then
        nick, id, regip, regcountry, regcity, regisp, currentip, currentcounrty, currentcity, currentisp =
            text:match(utext("Проверка игрока: (.+)%[(%d+)%].-IP при регистрации: (%d+%.%d+%.%d+%.%d+).-Страна при регистрации: (.-)\nГород при регистрации: (.-)\nПровайдер при регистрации: (.-)\nТекущий IP: (%d+%.%d+%.%d+%.%d+).-Текущая страна: (.-)\nТекущий город: (.-)\nТекущий провайдер: (.+)"))
        if nick then
            RINFO[0] = true
            local regData = getGorod(regip)
            local currentData = getGorod(currentip)
            APIregcountry = regData.country
            APIregcity = regData.city
            APIregisp = regData.isp

            if regData and currentData and regData.latitude and currentData.latitude then
                APIdistance = haversine(
                    tonumber(regData.latitude), tonumber(regData.longitude),
                    tonumber(currentData.latitude), tonumber(currentData.longitude)
                )
            end

            APIcurrentcountry = currentData.country
            APIcurrentcity = currentData.city
            APIcurrentisp = currentData.isp

            local VPNregData = getVPN(regip)
            local VPNcurrentData = getVPN(currentip)

            if VPNregData.proxy == "no" then
                VPNregData.proxy = "VPN не найден"
            else
                VPNregData.proxy = "VPN найден"
            end
            
            APIregvpn = VPNregData.proxy
            APIregrisk = VPNregData.risk
            APIcurrentvpn = VPNcurrentData.proxy
            APIcurrentrisk = VPNcurrentData.risk
        end
    end
end

function sampev.onSpectatePlayer(playerId, camType)
    lua_thread.create(function ()
        wait(500)
        local result, ped = sampGetCharHandleBySampPlayerId(playerId)
        if result and doesCharExist(ped) then
            if sampIsPlayerConnected(playerId) then
                rInfo.ped = ped
                rInfo.id = playerId
            end
        end
    end)
end

function sampev.onSpectateVehicle(vehicleId, camType)
    if isSpectating then return end

    lua_thread.create(function()
        wait(500)
        local resultveh, car = sampGetCarHandleBySampVehicleId(vehicleId)
        
        if resultveh then
            local drivercar = getDriverOfCar(car)
            if drivercar and doesCharExist(drivercar) then
                rInfo.ped = drivercar
                local id = select(2, sampGetPlayerIdByCharHandle(drivercar))
                rInfo.id = id
                isSpectating = true
            elseif not drivercar or not doesCharExist(drivercar) then
                isSpectating = false
                rInfo.id = -1
            end
        elseif not resultveh then
            isSpectating = false
            rInfo.id = -1
        end
    end)
end

function sampev.onSetPlayerHealth()
    if ini.settings.flyhack then
        return false
    end
end

function sampev.onPlayerSync(playerId, data)
    local result, id = sampGetPlayerIdByCharHandle(rInfo.ped)
    if result and id == playerId then
        keys.onfoot = {}

        keys.onfoot["W"] = (data.upDownKeys == 65408) or nil
        keys.onfoot["A"] = (data.leftRightKeys == 65408) or nil
        keys.onfoot["S"] = (data.upDownKeys == 128) or nil
        keys.onfoot["D"] = (data.leftRightKeys == 128) or nil

        keys.onfoot["Alt"]   = (bit.band(data.keysData, 1024) == 1024) or nil
        keys.onfoot["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
        keys.onfoot["Space"] = (bit.band(data.keysData, 32) == 32) or nil
        keys.onfoot["R"]     = (bit.band(data.keysData, 64) == 64) or nil
        keys.onfoot["F"]     = (bit.band(data.keysData, 16) == 16) or nil
        keys.onfoot["C"]     = (bit.band(data.keysData, 2) == 2) or nil

        keys.onfoot["RKM"]   = (bit.band(data.keysData, 4) == 4) or nil
        keys.onfoot["LKM"]   = (bit.band(data.keysData, 128) == 128) or nil
    end
end
function sampev.onVehicleSync(playerId, vehicleId, data)
    local result, id = sampGetPlayerIdByCharHandle(rInfo.ped)
    if result and id == playerId then

        keys.vehicle = {}

        keys.vehicle["W"]     = (bit.band(data.keysData, 8) == 8) or nil
        keys.vehicle["A"]     = (data.leftRightKeys == 65408) or nil
        keys.vehicle["S"]     = (bit.band(data.keysData, 32) == 32) or nil
        keys.vehicle["D"]     = (data.leftRightKeys == 128) or nil

        keys.vehicle["H"]     = (bit.band(data.keysData, 2) == 2) or nil
        keys.vehicle["Space"] = (bit.band(data.keysData, 128) == 128) or nil
        keys.vehicle["Ctrl"]  = (bit.band(data.keysData, 1) == 1) or nil
        keys.vehicle["Alt"]   = (bit.band(data.keysData, 4) == 4) or nil
        keys.vehicle["Q"]     = (bit.band(data.keysData, 256) == 256) or nil
        keys.vehicle["E"]     = (bit.band(data.keysData, 64) == 64) or nil
        keys.vehicle["F"]     = (bit.band(data.keysData, 16) == 16) or nil

        keys.vehicle["Up"]    = (data.upDownKeys == 65408) or nil
        keys.vehicle["Down"]  = (data.upDownKeys == 128) or nil
    end
end

function KeyCap(keyName, isPressed, size)
    local DL = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local colors = {
        [true] = imgui.ImVec4(0.00, 0.68, 0.71, 0.60),
        [false] = imgui.ImVec4(0.14, 0.18, 0.21, 1.00)
    }

    if KEYCAP == nil then KEYCAP = {} end
    if KEYCAP[keyName] == nil then
        KEYCAP[keyName] = {
            status = isPressed,
            color = colors[isPressed],
            timer = nil
        }
    end

    local K = KEYCAP[keyName]
    if isPressed ~= K.status then
        K.status = isPressed
        K.timer = os.clock()
    end

    local rounding = 3.0
    local A = imgui.ImVec2(p.x, p.y)
    local B = imgui.ImVec2(p.x + size.x, p.y + size.y)
    if K.timer ~= nil then
        K.color = bringVec4To(colors[not isPressed], colors[isPressed], K.timer, 0.1)
    end
    local ts = imgui.CalcTextSize(keyName)
    local text_pos = imgui.ImVec2(p.x + (size.x / 2) - (ts.x / 2), p.y + (size.y / 2) - (ts.y / 2))

    imgui.Dummy(size)
    DL:AddRectFilled(A, B, u32(K.color), rounding)
    DL:AddRect(A, B, u32(colors[true]), rounding, 0, 1)
    DL:AddText(text_pos, 0xFFFFFFFF, keyName)
end

function bringVec4To(from, dest, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (dest.x - from.x) / 100),
            from.y + (count * (dest.y - from.y) / 100),
            from.z + (count * (dest.z - from.z) / 100),
            from.w + (count * (dest.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and dest or from, false
end

function getVelocity(x, y, z, x1, y1, z1, flyspeed)
    local x2, y2, z2 = x1 - x, y1 - y, z1 - z
    local dist = math.sqrt((x1 - x) ^ 2 + (y1 - y) ^ 2 + (z1 - z) ^ 2)
    return x2 / dist * flyspeed, y2 / dist * flyspeed, z2 / dist * flyspeed
end

function sampev.onShowMenu()
    return false
end
function sampev.onHideMenu()
    return false
end
function sampev.onShowTextDraw(id, data)
    if data.text:find("HEALTH") then
        local nick, playerid = data.text:match("(%S+%s*%S+)%s*%((%d+)%)")
        rInfo.id = playerid
    end
end

local adminMenuState = {
    main = false,
    punishments = false,
    ban = false,
    kick = false,
    mute = false,
    amute = false,
    jail = false,
}

local weaponAliases = {
    [0] = {"fist", "кулак", "руки", "пусто"},
    [1] = {"brass", "knuckles", "кастет"},
    [2] = {"golf", "golfclub", "клюшка"},
    [3] = {"nightstick", "дубинка"},
    [4] = {"knife", "нож"},
    [5] = {"bat", "бита", "baseball"},
    [6] = {"shovel", "лопата"},
    [7] = {"poolcue", "кий"},
    [8] = {"katana", "катана"},
    [9] = {"chainsaw", "пила", "бензопила"},

    [22] = {"colt", "colt45", "9mm", "пистолет", "кольт"},
    [23] = {"silenced", "taser", "глушак", "пистолет с глушителем", "глушитель"},
    [24] = {"deagle", "desert", "desert eagle", "дигл", "орел", "пустынный орел"},

    [25] = {"shotgun", "дробовик", "помпа"},
    [26] = {"sawn", "sawn-off", "обрез", "двустволка"},
    [27] = {"combat", "combat shotgun", "боевой", "боевой дробовик", "тактикал"},

    [28] = {"uzi", "micro", "micro uzi", "узи"},
    [29] = {"mp5", "смг", "пп"},
    [32] = {"tec9", "tec", "тек", "тек9", "тек-9"},

    [30] = {"ak47", "ak", "калаш", "ак-47", "автомат"},
    [31] = {"m4", "m4a1", "эмка", "м4", "штурмовая"},
    [33] = {"rifle", "винтовка", "охотничья"},
    [34] = {"sniper", "sniper rifle", "снайпер", "снайперка", "снайперская"},

    [35] = {"rpg", "rocket launcher", "ракета", "рпг", "гранатомет"},
    [36] = {"hs rocket", "heatseeker", "самонаводка", "самонаводящаяся", "ракета2"},
    [37] = {"flamethrower", "огнемет"},
    [38] = {"minigun", "миниган", "мг"},

    [16] = {"grenade", "граната"},
    [17] = {"tear gas", "газ", "слезоточивый", "слезогаз"},
    [18] = {"molotov", "молотов", "коктейль", "зажигательная"},

    [39] = {"satchel", "взрывпакет", "пакет", "детонатор"},
    [40] = {"detonator", "детонатор"},
    [41] = {"spray", "spraycan", "баллончик", "краска"},
    [42] = {"fireext", "extinguisher", "огнетушитель"},
    [43] = {"camera", "камера", "фото"},
    [44] = {"nightvision", "ночник", "ночное зрение"},
    [45] = {"infrared", "infrared goggles", "инфракрасные"},
    [46] = {"parachute", "парашют"},
}

function getWeaponIdByName(name)
    name = name:lower()
    for id, aliases in pairs(weaponAliases) do
        for _, alias in ipairs(aliases) do
            if name == utext(alias):lower() then
                return id
            end
        end
    end
    return tonumber(name)
end


function main()
    if not isSampLoaded() and not isSampfuncsLoaded() then return end
    initializeRender()
    loadTeleports()
    while not isSampAvailable() do wait(100) end
    --gmPatch()
    local ip, port = sampGetCurrentServerAddress()
    if ip ~= "46.174.54.87" then
        ACM(utext("{ff0000}[A-Unload] {00FF7F}Admin Tools {319AFF}работает только на серверах {FFCD00}Fatality NRP!"), "{ff0000}")
        thisScript():unload()
    end
    bubbleBox = ChatBox(pagesize, blacklist)
    sampRegisterChatCommand("at", function() renderAdminTools[0] = not renderAdminTools[0] end)

    sampRegisterChatCommand('debug', function ()
        local bs = raknetNewBitStream()
        raknetSendRpc(52, bs)
        raknetSendRpc(118, bs)
        raknetSendRpc(128, bs)
        raknetSendRpc(129, bs)
        raknetDeleteBitStream(bs)
    end)

    sampRegisterChatCommand('inta', function ()
        local interior = getCharActiveInterior(PLAYER_PED)
        ACM(interior, "{ffffff}")
    end)
    sampRegisterChatCommand('addtp', function ()
        addtpAdminTools[0] = not addtpAdminTools[0]
        resultiv = true
        sampSendChat('/getint')
        sampSendChat('/getvw')
        lua_thread.create(function ()
            wait(1000)
            inttp[0] = tonumber(aint)
            vwtp[0] = tonumber(avw)
        end)
    end)
    sampRegisterChatCommand('newtp', function ()
        tpmenuAdminTools[0] = not tpmenuAdminTools[0]
    end)
    sampRegisterChatCommand('slap', function (args)
        if args:find(utext("^(%d+)$")) then
            sampSendChat('/slap ' .. args)
        elseif args:find(utext("^(.+)$")) then
            local x,y,z = getCharCoordinates(PLAYER_PED)
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            if args == "up" then
                sampSendChat('/slap ' .. id)
            elseif args == "down" then
                setCharCoordinates(PLAYER_PED, x, y, z-3)
            end
        else
            ACM(utext("{ffffff}Введите: /slap [id игрока]"), "{ffffff}")
        end
    end)
    sampRegisterChatCommand('inv', function()
        spec = not spec
        nopPlayerSync = not nopPlayerSync
        if spec then
            sampAddChatMessage(utext("Невидимка {00ff00}включена"), -1)
        else
            sampAddChatMessage(utext("Невидимка {ff0000}выключена"), -1)
        end
    end)
    
    sampRegisterChatCommand('clearhouse', function ()
        ini.settings.clearhouse = not ini.settings.clearhouse
        if ini.settings.clearhouse then
            ACM(utext("{00FF7F}[A-Tools] {319AFF}Система авто-продажи домов {00ff00}включена!"), "{00FF7F}")
        else
            ACM(utext("{00FF7F}[A-Tools] {319AFF}Система авто-продажи домов {ff0000}выключена!"), "{00FF7F}")
        end
        inicfg.save(ini, IniFilename)
    end)

    sampRegisterChatCommand('giveitem', function (args)
        giveitemstate = true
        if args:find(utext("(%d+) (.+) (%d+)")) then
            local arg1, arg2, arg3 = args:match(utext("(%d+) (.+) (%d+)"))
            if arg1 and arg2 and arg3 then
                idgiveitem = arg1
                finditem = arg2
                itemsht = arg3
                sampSendChat('/finditem ' .. arg2)
            else
                ACM(utext('{ff0000}[ERROR]:{ffffff} Используйте /giveitem [id] [название предмета] [кол-во]'), "{ff0000}")
            end
        else
            ACM(utext('{ff0000}[ERROR]:{ffffff} Используйте /giveitem [id] [название предмета] [кол-во]'), "{ff0000}")
        end
    end)

    sampRegisterChatCommand('ditem', function (args)
        ditemstate = true
        if args:find("(%d+) (.+) (%d+)") then
            local arg1, arg2, arg3 = args:match(utext("(%d+) (.+) (%d+)"))
            if arg1 and arg2 and arg3 then
                idgiveitem = arg1
                finditem = arg2
                itemsht = arg3
                sampSendChat('/finditem ' .. arg2)
            else
                ACM(utext('{ff0000}[ERROR]:{ffffff} Используйте /ditem [id] [название предмета] [кол-во]'), "{ff0000}")
            end
        else
            ACM(utext('{ff0000}[ERROR]:{ffffff} Используйте /ditem [id] [название предмета] [кол-во]'), "{ff0000}")
        end
    end)

    sampRegisterChatCommand('dunjail', function ()
        dunjailstate = true
        sampSendChat('/donate')
        lua_thread.create(function ()
            wait(60)
            local dialogid = sampGetCurrentDialogId()
            sampSendDialogResponse(dialogid, 1, 18, "")
            wait(60)
            dialogid = sampGetCurrentDialogId()
            sampSendDialogResponse(dialogid, 1, 4, "")
            sampCloseCurrentDialogWithButton(0)
        end)
    end)

    sampRegisterChatCommand('hp', function (arg)
        if #arg > 0 then
            if tonumber(arg) ~= nil then
                sampSendChat('/hp ' .. arg)
            else
                ACM(utext("{ffffff}Введите: /hp [id игрока]"), "{ffffff}")
            end
        else
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            sampSendChat('/hp ' .. id)
        end
    end)

    sampRegisterChatCommand('hpall', function ()
        for idstream = 0, sampGetMaxPlayerId(true) do
            local result, handle = sampGetCharHandleBySampPlayerId(idstream)
            if result and doesCharExist(handle) then
                if sampIsPlayerConnected(id) then
                    sampSendChat('/hp ' .. idstream)
                    print("/hp " .. idstream)
                end
            end
        end
        local myIDStream = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
        sampSendChat('/hp ' .. myIDStream)
    end)

    sampRegisterChatCommand('stats', function (arg)
        if #arg > 0 then
            if tonumber(arg) ~= nil then
                sampSendChat('/stats ' .. arg)
            else
                ACM(utext("{ffffff}Введите: /stats [id игрока]"), "{ffffff}")
            end
        else
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            sampSendChat('/stats ' .. id)
        end
    end)

    sampRegisterChatCommand('gun', function (args)
        if #args == 0 then
            sampSendChat('/gun')
            return
        end
        
        local parts = {}
        for part in args:gmatch("%S+") do
            table.insert(parts, part)
        end
        
        if #parts == 1 then
            local id = parts[1]
            sampSendChat('/givegun ' .. id .. " 24 100")
            sampSendChat('/givegun ' .. id .. " 25 50")
            sampSendChat('/givegun ' .. id .. " 31 500")
        elseif #parts == 2 then
            local id, gun = parts[1], getWeaponIdByName(parts[2])
            if not gun then
                ACM(utext("{FF0000}[ERROR]{FFFFFF} Неверное название оружия."), "{ff0000}")
                return
            end
            sampSendChat('/givegun ' .. id .. " " .. gun .. " 1")
        elseif #parts == 3 then
            local id, gun, ammo = parts[1], getWeaponIdByName(parts[2]), parts[3]
            if not gun then
                ACM(utext("{FF0000}[ERROR]{FFFFFF} Неверное название оружия."), "{ff0000}")
                return
            end
            sampSendChat('/givegun ' .. id .. " " .. gun .. " " .. ammo)
        else
            sampSendChat('/gun')
        end
    end)
    
    sampRegisterChatCommand('flip', function ()
		if isCharInAnyCar(PLAYER_PED) then
            local x, y, z, w = getVehicleQuaternion(storeCarCharIsInNoSave(PLAYER_PED))
            setVehicleQuaternion(storeCarCharIsInNoSave(PLAYER_PED), 0, 0, z, w)
            local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            sampSendChat('/hp ' .. id)
		end
    end)

    sampRegisterChatCommand('osk', function (arg) 
        if arg:find("(%d+)") then 
            sampSendChat('/mute ' .. arg .. " " .. "60 osk")
        elseif arg:find("(%D+)") then
            sampSendChat('/offmute ' .. arg .. " " .. "60 osk")
        else 
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /osk [id | nick]'), "{00FF7F}") 
        end 
    end)
    sampRegisterChatCommand('aosk', function (arg)
        if arg:find("(%d+)") then
             sampSendChat('/amute ' .. arg .. " " .. "60 osk")
        else 
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /aosk [id]'), "{00FF7F}") 
        end 
    end)
    sampRegisterChatCommand('sosk', function (args)
        if args:find("(%d+) (%d+)") then
            local arg1, arg2 = args:match("(%d+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/ban ' .. arg1 .. utext(" 30 Оск. Сервера"))
                elseif arg2 == "2" then
                    sampSendChat('/abanip ' .. arg1 .. utext(" Оск. Сервера"))
                else
                    ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /sosk [id] [Номер]'), "{00FF7F}")
                    ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Оск. Сервера (ban) 2. Оск. Сервера (abanip)'), "{00FF7F}")
                end
            else
                ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /sosk [id] [Номер]'), "{00FF7F}")
                ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Оск. Сервера (ban) 2. Оск. Сервера (abanip)'), "{00FF7F}")
            end
        elseif args:find("(%D+) (%d+)") then
            local arg1, arg2 = args:match("(%D+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/offban ' .. arg1 .. utext(" 30 Оск. Сервера"))
                else
                    ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /sosk [nick] [Номер]'), "{00FF7F}")
                    ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Оск. Сервера (offban)'), "{00FF7F}")
                end
            else
                ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /sosk [nick] [Номер]'), "{00FF7F}")
                ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Оск. Сервера (offban)'), "{00FF7F}")
            end
        else
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /sosk [id | nick] [Номер]'), "{00FF7F}")
            ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Оск. Сервера (ban | offban) 2. Оск. Сервера (abanip)'), "{00FF7F}")
        end
    end)
    sampRegisterChatCommand('cheat', function (args)
        if args:find("(%d+) (%d+)") then
            local arg1, arg2 = args:match("(%d+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/jail ' .. arg1 .. " " .. utext("300 cheat работа"))
                elseif arg2 == "2" then
                    sampSendChat('/ban ' .. arg1 .. " " .. utext("7 Вред.читы"))
                elseif arg2 == "3" then
                    sampSendChat('/ban ' .. arg1 .. " " .. utext("30 Вред.читы"))
                elseif arg2 == "4" then
                    sampSendChat('/abanip ' .. arg1 .. " " .. utext("Вред.читы"))
                elseif arg2 == "5" then
                    sampSendChat('/dkick ' .. arg1)
                elseif arg2 == "6" then
                    sampSendChat('/jail ' .. arg1 .. " " .. utext("30 cheat DM"))
                else
                    ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /cheat [id] [Номер]'), "{00FF7F}")
                    ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Чит на работе(jail) 2. Вред.читы(ban 7) 3. Вред.читы(ban 30) 4. Вред.читы(banip) 5. Чит на DM(dkick) 6. Чит на DM(jail)'), "{00FF7F}")
                end
            else
                ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /cheat [id] [Номер]'), "{00FF7F}")
                ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Чит на работе(jail) 2. Вред.читы(ban 7) 3. Вред.читы(ban 30) 4. Вред.читы(banip) 5. Чит на DM(dkick) 6. Чит на DM(jail)'), "{00FF7F}")
            end
        else
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /cheat [id] [Номер]'), "{00FF7F}")
            ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Чит на работе(jail) 2. Вред.читы(ban 7) 3. Вред.читы(ban 30) 4. Вред.читы(banip) 5. Чит на DM(dkick) 6. Чит на DM(jail)'), "{00FF7F}")
        end
     end)
    sampRegisterChatCommand('karusel', function (arg)
        if arg:find("(%d+)") then
            sampSendChat('/jail ' .. arg .. " 0 karusel")
            sampSendChat('/ajail ' .. arg)
        else
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /karusel [id]'), "{00FF7F}")
        end
    end)
    sampRegisterChatCommand('offcheat', function (args)
        if args:find("(%D+) (%d+)") then
            local arg1, arg2 = args:match("(%D+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/offjail ' .. arg1 .. " " .. utext("300 cheat работа"))
                elseif arg2 == "2" then
                    sampSendChat('/offban ' .. arg1 .. " " .. utext("7 Вред.читы"))
                elseif arg2 == "3" then
                    sampSendChat('/offban ' .. arg1 .. " " .. utext("30 Вред.читы"))
                elseif arg2 == "4" then
                    sampSendChat('/offjail ' .. arg1 .. " " .. utext("30 cheat DM"))
                else
                    ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /offcheat [nick] [Номер]'), "{00FF7F}")
                    ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Чит на работе(offjail) 2. Вред.читы(offban 7) 3. Вред.читы(offban 30) 6. Чит на DM(offjail)'), "{00FF7F}")
                end
            else
                ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /offcheat [nick] [Номер]'), "{00FF7F}")
                ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Чит на работе(offjail) 2. Вред.читы(offban 7) 3. Вред.читы(offban 30) 6. Чит на DM(offjail)'), "{00FF7F}")
            end
        else
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /offcheat [nick] [Номер]'), "{00FF7F}")
            ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Чит на работе(offjail) 2. Вред.читы(offban 7) 3. Вред.читы(offban 30) 6. Чит на DM(offjail)'), "{00FF7F}")
        end
     end)
     sampRegisterChatCommand('ur', function (args)
        if args:find("(%d+) (%d+)") then
            local arg1, arg2 = args:match("(%d+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/mute ' .. arg1 .. " " .. utext(" 300 У.Р"))
                elseif arg2 == "2" then
                    sampSendChat('/abanip ' .. arg1)
                else
                    ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /ur [id] [Номер]'), "{00FF7F}")
                    ACM(utext('{00FF7F}[Номера]:{ffffff} 1. У.Р(mute) 2. У.Р(abanip)'), "{00FF7F}")
                end
            else
                ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /ur [id] [Номер]'), "{00FF7F}")
                ACM(utext('{00FF7F}[Номера]:{ffffff} 1. У.Р(mute) 2. У.Р(abanip)'), "{00FF7F}")
            end
        elseif args:find("(%D+) (%d+)") then
            local arg1, arg2 = args:match("(%D+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/offmute ' .. arg1 .. " " .. utext(" 300 У.Р"))
                else
                    ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /ur [nick] [Номер]'), "{00FF7F}")
                    ACM(utext('{00FF7F}[Номера]:{ffffff} 1. У.Р(offmute)'), "{00FF7F}")
                end
            else
                ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /ur [nick] [Номер]'), "{00FF7F}")
                ACM(utext('{00FF7F}[Номера]:{ffffff} 1. У.Р(offmute)'), "{00FF7F}")
            end
        else
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /ur [id | nick] [Номер]'), "{00FF7F}")
            ACM(utext('{00FF7F}[Номера]:{ffffff} 1. У.Р(mute | offmute) 2. У.Р(abanip)'), "{00FF7F}")
        end
     end)
     sampRegisterChatCommand('aur', function (args)
        if args:find("(%d+) (%d+)") then
            local arg1, arg2 = args:match("(%d+) (%d+)")
            if #arg1 > 0 then
                if arg2 == "1" then
                    sampSendChat('/amute ' .. arg1 .. " " .. utext(" 300 У.Р"))
                elseif arg2 == "2" then
                    sampSendChat('/abanip ' .. arg1)
                else
                    ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /aur [id] [Номер]'), "{00FF7F}")
                    ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Мут 2. бан IP'), "{00FF7F}")
                end
            else
                ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /aur [id] [Номер]'), "{00FF7F}")
                ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Мут 2. бан IP'), "{00FF7F}")
            end
        else
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /aur [id] [Номер]'), "{00FF7F}")
            ACM(utext('{00FF7F}[Номера]:{ffffff} 1. Мут 2. бан IP'), "{00FF7F}")
        end
     end)

     sampRegisterChatCommand('viktorina', function (arg)
        if arg:find("(%d+)") then
            if tonumber(arg) >= ini.settings.intot and tonumber(arg) <= ini.settings.intdo then
                print(arg)
                successint = arg
                viktorina()
            else
                ACM(string.format(utext('{00FF7F}[A-CMD]:{ffffff} Обнаружена умствено-отсталая деятельность! Пожалуйста выберите число от {ff0000}%d {ffffff}до {ff0000}%d{ffffff}!'), ini.settings.intot, ini.settings.intdo), "{00FF7F}")
            end
        else
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /viktorina [угадываемое число]'), "{00FF7F}")
        end
     end)

    sampRegisterChatCommand('vopros', function (arg)
        if arg:find("(.+)") then
            print(arg)
            successvopros = arg
            vopros()
        else
            ACM(utext('{00FF7F}[A-CMD]:{ffffff} Используйте /vopros [правильный ответ на вопрос]'), "{00FF7F}")
        end
     end)

    sampRegisterChatCommand('mypos', function ()
        local x, y, z = getCharCoordinates(PLAYER_PED)
        ACM(utext("{00FF7F}[A-Tools] {319AFF}X: " .. x .. " Y: " .. y .. " Z: " .. z), "{00FF7F}")
    end)

    while true do
        
        if isKeyJustPressed(VK_M) and rInfo.state == true then
            sampSendChat('/re')
        end

        if rInfo.state == true and wasKeyPressed(VK_SPACE) and not sampIsChatInputActive() and not sampIsDialogActive() then
			sampSendChat('/re '..rInfo.id)
			printStyledString('Update Recon', 1000, 5)
		end

        if isKeyJustPressed(VK_OEM_PERIOD) and ini.settings.flyhack and not isCharInAnyCar(PLAYER_PED) then
            print('pressed')
            active = not active
            if active then
                setCharProofs(PLAYER_PED, true, true, true, true, true)
                --writeMemory(0x96916E, 1, 1, false)
                --writeMemory(0xB7CEE6, 1, 1, true)
                makePlayerFireProof(PLAYER_HANDLE, true)
                local pointer = getCharPointer(PLAYER_PED) + 66
                --writeMemory(pointer, 1, 204, false)
            end
            if not active then
                clearCharTasksImmediately(PLAYER_PED) 
                setCharProofs(PLAYER_PED, false, false, false, false, false)
                --writeMemory(0x96916D, 1,  0, true)
                --writeMemory(0xB7CEE6, 1, 0, true)
                makePlayerFireProof(PLAYER_HANDLE, false)
                local pointer = getCharPointer(PLAYER_PED) + 66
                --writeMemory(pointer, 1, 0, false)
            end
        end

        --flyhacjk
		if active then
            local cpedaqw = readMemory(0xB6F5F0, 4)
            writeMemory(cpedaqw + 0x46C, 1, 0, false)
            
            local x, y, z = getActiveCameraCoordinates()
            local x1, y1, z1 = getActiveCameraPointAt()
            x1, y1, z1 = x1 - x, y1 - y, z1 - z
            setCharHeading(PLAYER_PED, getHeadingFromVector2d(x1, y1))
            
            local atX, atY, atZ = getCharCoordinates(PLAYER_PED)
            local angle = getCharHeading(PLAYER_PED)
            
            local animLib, animName = "SWIM", "SWIM_BREAST"
            
            if isKeyDown(VK_W) and not sampIsChatInputActive() then
                animLib, animName = "SWIM", "SWIM_BREAST"
            elseif isKeyDown(VK_A) and not sampIsChatInputActive() then
                animLib, animName = "PARACHUTE", "FALL_SkyDive_L"
            elseif isKeyDown(VK_D) and not sampIsChatInputActive() then
                animLib, animName = "PARACHUTE", "FALL_SkyDive_R"
            elseif isKeyDown(VK_S) and not sampIsChatInputActive() then
                animLib, animName = "PARACHUTE", "FALL_skyDive"
            elseif isKeyDown(VK_SPACE) then
                animLib, animName = "PARACHUTE", "FALL_skyDive"
            end
            
            requestAnimation(animLib)
            taskPlayAnim(PLAYER_PED, animName, animLib, 4.0, true, true, true, false, -1)
            taskPlayAnim(PLAYER_PED, animName, animLib, 4.0, true, true, true, false, -1)
            
            local wheelDelta = getMousewheelDelta()
            if wheelDelta > 0 then
                flySpeed = math.min(flySpeed + 5, 100)
            elseif wheelDelta < 0 then
                flySpeed = math.max(flySpeed - 5, 10)
            end

            if isKeyDown(VK_W) and not sampIsChatInputActive() then
                atX1 = atX + (40 * math.sin(math.rad(-angle)))
                atY1 = atY + (40 * math.cos(math.rad(-angle)))
                atZ1 = atZ + (40 * z1)
                setCharVelocity(PLAYER_PED, getVelocity(atX, atY, atZ, atX1, atY1, atZ1, flySpeed))
                
            elseif isKeyDown(VK_A) and not sampIsChatInputActive() then
                local angle = angle + 90
                atX1 = atX + (40 * math.sin(math.rad(-angle)))
                atY1 = atY + (40 * math.cos(math.rad(-angle)))
                setCharVelocity(PLAYER_PED, getVelocity(atX, atY, atZ, atX1, atY1, atZ, flySpeed))
                
            elseif isKeyDown(VK_D) and not sampIsChatInputActive() then
                local angle = angle - 90
                atX1 = atX + (40 * math.sin(math.rad(-angle)))
                atY1 = atY + (40 * math.cos(math.rad(-angle)))
                setCharVelocity(PLAYER_PED, getVelocity(atX, atY, atZ, atX1, atY1, atZ, flySpeed))
                
            elseif isKeyDown(VK_S) and not sampIsChatInputActive() then
                angle = angle - 180
                atX1 = atX + (40 * math.sin(math.rad(-angle)))
                atY1 = atY + (40 * math.cos(math.rad(-angle)))
                atZ1 = atZ + (-(40 * z1))
                setCharVelocity(PLAYER_PED, getVelocity(atX, atY, atZ, atX1, atY1, atZ1, flySpeed))
                
            elseif isKeyDown(VK_SPACE) then
                setCharVelocity(PLAYER_PED, 0, 0, 0.35)
            end
        end

        --interactive
        local playerHandleColor = getNearCharToCenter(200)
        if playerHandleColor then
           r, i = sampGetPlayerIdByCharHandle(playerHandleColor)
           if r then
                playerColor = sampGetPlayerColor(i)
                if playerColor == 553648127 then
                    playerColor = 4294967295
                elseif playerColor == 2855350577 then
                    playerColor = 4281413937
                end
           end
        end

        if isKeyDown(VK_LSHIFT) and isKeyDown(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
            local X, Y = getScreenResolution()
            renderFigure2D(X/2, Y/2, 50, 200, playerColor)
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local posX, posY = convert3DCoordsToScreen(x, y, z)
            renderDrawPolygon(X/2, Y/2, 7, 7, 40, 0, -1)
            local player = getNearCharToCenter(200)
            
            if player then
                local playerId = select(2, sampGetPlayerIdByCharHandle(player))
                local playerNick = sampGetPlayerNickname(playerId)
                local x2, y2, z2 = getCharCoordinates(player)
                local isScreen = isPointOnScreen(x2, y2, z2, 200)
                
                if isScreen then
                    local posX2, posY2 = convert3DCoordsToScreen(x2, y2, z2)
                    renderDrawLine(posX, posY - 50, posX2, posY2, 2.0, playerColor)
                    renderDrawPolygon(posX2, posY2, 10, 10, 40, 0, playerColor)
                    local distance = math.floor(getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
                    
                    renderFontDrawTextAlign(font, string.format('%s[%d]', playerNick, playerId), posX2, posY2-30, playerColor, 2)
                    renderFontDrawTextAlign(font, string.format(utext('Дистанция: %s'), distance), X/2, Y/2+210, playerColor, 2)
                    
                    local function resetMenuStates()
                        adminMenuState.punishments = false
                        adminMenuState.ban = false
                        adminMenuState.kick = false
                        adminMenuState.mute = false
                        adminMenuState.amute = false
                        adminMenuState.jail = false
                    end
                    
                    if isKeyJustPressed(VK_LCONTROL) then
                        if adminMenuState.ban or adminMenuState.kick or adminMenuState.mute or adminMenuState.amute or adminMenuState.jail then
                            adminMenuState.ban = false
                            adminMenuState.kick = false
                            adminMenuState.mute = false
                            adminMenuState.amute = false
                            adminMenuState.jail = false
                            adminMenuState.punishments = true
                        elseif adminMenuState.punishments then
                            resetMenuStates()
                        end
                    end
                    
                    if not adminMenuState.punishments and not adminMenuState.ban and not adminMenuState.kick and not adminMenuState.mute and not adminMenuState.amute and not adminMenuState.jail then
                        renderFontDrawTextAlign(font, utext('1 - Перейти в слежку\n2 - SLAP\n3 - Заспавнить\n4 - Выдать 100 HP\n5 - Телепортировать к себе\n6 - ТП к игроку\n7 - Наказания'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_7) then
                            adminMenuState.punishments = true
                        end
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat('/re '..playerId)
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat('/slap '..playerId)
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat('/spawn '..playerId)
                        elseif isKeyJustPressed(VK_4) then
                            sampSendChat('/sethp '..playerId..' 100')
                        elseif isKeyJustPressed(VK_5) then
                            sampSendChat('/gethere '..playerId)
                        elseif isKeyJustPressed(VK_6) then
                            sampSendChat('/g '..playerId)
                        end
                    
                    elseif adminMenuState.punishments and not adminMenuState.ban and not adminMenuState.kick and not adminMenuState.mute and not adminMenuState.amute and not adminMenuState.jail then
                        renderFontDrawTextAlign(font, utext('Наказания:\n1 - Бан\n2 - Кик\n3 - БанИП\n4 - Мут\n5 - АМут\n6 - Jail\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            adminMenuState.punishments = false
                            adminMenuState.ban = true
                        elseif isKeyJustPressed(VK_2) then
                            adminMenuState.punishments = false
                            adminMenuState.kick = true
                        elseif isKeyJustPressed(VK_3) then
                            adminMenuState.punishments = false
                            sampSendChat('/abanip ' .. playerId)
                        elseif isKeyJustPressed(VK_4) then
                            adminMenuState.punishments = false
                            adminMenuState.mute = true
                        elseif isKeyJustPressed(VK_5) then
                            adminMenuState.punishments = false
                            adminMenuState.amute = true
                        elseif isKeyJustPressed(VK_6) then
                            adminMenuState.punishments = false
                            adminMenuState.jail = true
                        end
                    
                    elseif adminMenuState.ban then
                        renderFontDrawTextAlign(font, utext('Вид бана:\n1 - 7 дней (Vred)\n2 - 30 дней (Реклама)\n3 - ЧСП\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/ban " .. playerId .. " 7 Vred")
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/ban " .. playerId .. utext(" 30 Реклама"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat("/ban " .. playerId .. utext(" 365 ЧСП"))
                            resetMenuStates()
                        end
                    
                    elseif adminMenuState.kick then
                        renderFontDrawTextAlign(font, utext('Причина кика:\n1 - Перезайди\n2 - !\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/kick " .. playerId .. utext(" Перезайди"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/kick " .. playerId .. " !")
                            resetMenuStates()
                        end
                    elseif adminMenuState.mute then
                        renderFontDrawTextAlign(font, utext('Причина мута:\n1 - Оск\n2 - Флуд\n3 - Капс\n4 - Реклама\n5 - У.Р\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/mute " .. playerId .. utext(" 60 Оск"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/mute " .. playerId .. utext(" 15 flood"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat("/mute " .. playerId .. utext(" 15 CAPS"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_4) then
                            sampSendChat("/mute " .. playerId .. utext(" 300 Реклама"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_5) then
                            sampSendChat("/mute " .. playerId .. utext(" 300 У.Р"))
                            resetMenuStates()
                        end
                    elseif adminMenuState.amute then
                        renderFontDrawTextAlign(font, utext('Причина мута:\n1 - Оск\n2 - Флуд\n3 - Капс\n4 - Реклама\n5 - У.Р\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/amute " .. playerId .. utext(" 60 Оск"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/amute " .. playerId .. utext(" 15 flood"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat("/amute " .. playerId .. utext(" 15 CAPS"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_4) then
                            sampSendChat("/amute " .. playerId .. utext(" 300 Реклама"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_5) then
                            sampSendChat("/amute " .. playerId .. utext(" 300 У.Р"))
                            resetMenuStates()
                        end
                    elseif adminMenuState.jail then
                        renderFontDrawTextAlign(font, utext('Причина jail:\n1 - Читы на работе\n2 - ДМ\n3 - Читы /dm\n4 - ДБ\nLCTRL - Назад'), X/2+210, Y/2-30, playerColor, 1)
                        
                        if isKeyJustPressed(VK_1) then
                            sampSendChat("/jail " .. playerId .. utext(" 300 читы на работе"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_2) then
                            sampSendChat("/jail " .. playerId .. utext(" 30 ДМ"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_3) then
                            sampSendChat("/jail " .. playerId .. utext(" 30 Читы /dm"))
                            resetMenuStates()
                        elseif isKeyJustPressed(VK_4) then
                            sampSendChat("/jail " .. playerId .. utext(" 30 ДБ"))
                            resetMenuStates()
                        end
                    end
                end
            end
        end

        --farchat
        bubbleBox:toggle(ini.settings.farchat)

		if bubbleBox.active then
			bubbleBox:draw(positionX, positionY)
			if is_key_check_available() and isKeyDown(VK_B) then
				if isKeyJustPressed(VK_OEM_MINUS) then
					bubbleBox:scroll(-1)
                elseif isKeyJustPressed(VK_OEM_PLUS) then
                    bubbleBox:scroll(1)
				end
			end
		end

        --clickwarp
        while isPauseMenuActive() do
            if cursorEnabled then
                showCursorClickWarp(false)
            end
            wait(100)
        end

        if isKeyDown(0x04) and ini.settings.clickwarp then
            cursorEnabled = not cursorEnabled
            showCursorClickWarp(cursorEnabled)
            while isKeyDown(0x04) do wait(80) end
        end
        if cursorEnabled then
            local mode = sampGetCursorMode()
            if mode == 0 then
                showCursor(true)
            end
            local sx, sy = getCursorPos()
            local sw, sh = getScreenResolution()
            -- is cursor in game window bounds?
            if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
                local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
                local camX, camY, camZ = getActiveCameraCoordinates()
                -- search for the collision point
                local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
                if result and colpoint.entity ~= 0 then
                    local normal = colpoint.normal
                    local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                    local zOffset = 300
                    if normal[3] >= 0.5 then zOffset = 1 end
                    -- search for the ground position vertically down
                    local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
                    true, true, false, true, false, false, false)
                    if result then
                        pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)
            
                        local curX, curY, curZ  = getCharCoordinates(playerPed)
                        local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                        local hoffs             = renderGetFontDrawHeight(font)
            
                        sy = sy - 2
                        sx = sx - 2
                        renderFontDrawText(font, string.format("%0.2fm", dist), sx, sy - hoffs, 0xEEEEEEEE)
            
                        local tpIntoCar = nil
                        if colpoint.entityType == 2 then
                            local car = getVehiclePointerHandle(colpoint.entity)
                            if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                                displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                                local color = 0xAAFFFFFF
                                if isKeyDown(0x02) then
                                    tpIntoCar = car
                                    color = 0xFF00FF00
                                end
                                renderFontDrawText(font2, "Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
                            end
                        end
            
                        createPointMarker(pos.x, pos.y, pos.z)
            
                        -- teleport!
                        if isKeyDown(0x01) then
                            if tpIntoCar then
                                if not jumpIntoCar(tpIntoCar) then
                                    -- teleport to the car if there is no free seats
                                    teleportPlayer(pos.x, pos.y, pos.z)
                                end
                            else
                                if isCharInAnyCar(playerPed) then
                                    local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                                    local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                                    rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                                    pos = pos - norm * 1.8
                                    pos.z = pos.z - 0.8
                                end
                                teleportPlayer(pos.x, pos.y, pos.z)
                            end
                            removePointMarker()
            
                            while isKeyDown(0x01) do wait(0) end
                            showCursorClickWarp(false)
                        end
                    end
                end
            end
        end
        wait(0)
        removePointMarker()
    end
end

ChatBox = function(pagesize, blacklist)
  local obj = {
    pagesize = pagesize,
		active = false,
		font = nil,
		messages = {},
		blacklist = blacklist,
		firstMessage = 0,
		currentMessage = 0,
  }

	function obj:initialize()
		if self.font == nil then
			self.font = renderCreateFont('Verdana', 8, FCR_BORDER + FCR_BOLD)
		end
	end

	function obj:free()
		if self.font ~= nil then
			renderReleaseFont(self.font)
			self.font = nil
		end
	end

	function obj:toggle(show)
		self:initialize()
		self.active = show
	end

  function obj:draw(x, y)
		local add_text_draw = function(text, color)
			renderFontDrawText(self.font, text, x, y, color)
			y = y + renderGetFontDrawHeight(self.font)
		end

		-- draw caption
    add_text_draw(utext("Дальний чат"), 0xFFE4D8CC)

		-- draw page indicator
		if #self.messages == 0 then return end
		local cur = self.currentMessage
		local to = cur + math.min(self.pagesize, #self.messages) - 1
		add_text_draw(string.format("%d/%d", to, #self.messages), 0xFFE4D8CC)

		-- draw messages
		x = x + 4
		for i = cur, to do
			local it = self.messages[i]
			add_text_draw(
				string.format("{E4E4E4}[%s] (%.1fm) {%06X}%s{D4D4D4}({EEEEEE}%d{D4D4D4}): {%06X}%s",
					it.time,
					it.dist,
					argb_to_rgb(it.playerColor),
					it.nickname,
					it.playerId,
					argb_to_rgb(it.color),
					it.text),
				it.color)
		end
  end

	function obj:add_message(playerId, color, distance, text)
		-- ignore blacklisted messages
		if self:is_text_blacklisted(text) then return end

		-- process only streamed in players
		local dist = get_distance_to_player(playerId)
		if dist ~= nil then
			color = bgra_to_argb(color)
			if dist > distance then color = set_argb_alpha(color, 0xA0)
			else color = set_argb_alpha(color, 0xF0)
			end
			table.insert(self.messages, {
				playerId = playerId,
				nickname = sampGetPlayerNickname(playerId),
				color = color,
				playerColor = sampGetPlayerColor(playerId),
				dist = dist,
				distLimit = distance,
				text = text,
				time = os.date('%X')})

			-- limit message list
			if #self.messages > messagesMax then
				self.messages[self.firstMessage] = nil
				self.firstMessage = #self.messages - messagesMax
			else
				self.firstMessage = 1
			end
			self:scroll(1)
		end
	end

	function obj:is_text_blacklisted(text)
		for _, t in pairs(self.blacklist) do
			if string.match(text, utext(t)) then
				return true
			end
		end
		return false
	end

	function obj:scroll(n)
		self.currentMessage = self.currentMessage + n
		if self.currentMessage < self.firstMessage then
			self.currentMessage = self.firstMessage
		else
			local max = math.max(#self.messages, self.pagesize) + 1 - self.pagesize
			if self.currentMessage > max then
				self.currentMessage = max
			end
		end
	end

  setmetatable(obj, {})
  return obj
end

function get_distance_to_player(playerId)
	if sampIsPlayerConnected(playerId) then
		local result, ped = sampGetCharHandleBySampPlayerId(playerId)
		if result and doesCharExist(ped) then
			local myX, myY, myZ = getCharCoordinates(playerPed)
			local playerX, playerY, playerZ = getCharCoordinates(ped)
			return getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
		end
	end
	return nil
end

function is_key_check_available()
  if not isSampfuncsLoaded() then
    return not isPauseMenuActive()
  end
  local result = not isSampfuncsConsoleActive() and not isPauseMenuActive()
  if isSampLoaded() and isSampAvailable() then
    result = result and not sampIsChatInputActive() and not sampIsDialogActive()
  end
  return result
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end

function join_argb(a, r, g, b)
  local argb = b  -- b
  argb = bit.bor(argb, bit.lshift(g, 8))  -- g
  argb = bit.bor(argb, bit.lshift(r, 16)) -- r
  argb = bit.bor(argb, bit.lshift(a, 24)) -- a
  return argb
end

function bgra_to_argb(bgra)
  local b, g, r, a = explode_argb(bgra)
  return join_argb(a, r, g, b)
end

function set_argb_alpha(color, alpha)
	  local _, r, g, b = explode_argb(color)
		return join_argb(alpha, r, g, b)
end

function get_argb_alpha(color)
	local alpha = explode_argb(color)
	return alpha
end

function argb_to_rgb(argb)
	return bit.band(argb, 0xFFFFFF)
end

function renderFigure2D(x, y, points, radius, color)
    local step = math.pi * 2 / points
    local render_start, render_end = {}, {}
    for i = 0, math.pi * 2, step do
        render_start[1] = radius * math.cos(i) + x
        render_start[2] = radius * math.sin(i) + y
        render_end[1] = radius * math.cos(i + step) + x
        render_end[2] = radius * math.sin(i + step) + y
        renderDrawLine(render_start[1], render_start[2], render_end[1], render_end[2], 1, color)
    end
end
function getNearCharToCenter(radius)
    local arr = {}
    local sx, sy = getScreenResolution()
    for _, player in ipairs(getAllChars()) do
        if select(1, sampGetPlayerIdByCharHandle(player)) and isCharOnScreen(player) and player ~= playerPed then
            local plX, plY, plZ = getCharCoordinates(player)
            local cX, cY = convert3DCoordsToScreen(plX, plY, plZ)
            local distBetween2d = getDistanceBetweenCoords2d(sx / 2, sy / 2, cX, cY)
            if distBetween2d <= tonumber(radius and radius or sx) then
                table.insert(arr, {distBetween2d, player})
            end
        end
    end
    if #arr > 0 then
        table.sort(arr, function(a, b) return (a[1] < b[1]) end)
        return arr[1][2]
    end
    return nil
end
function renderFontDrawTextAlign(font, text, x, y, color, align)
    if not align or align == 1 then
        renderFontDrawText(font, text, x, y, color)
    end
  
    if align == 2 then
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text) / 2, y, color)
    end
  
    if align == 3 then
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text), y, color)
    end
  end

function SoftBlueTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    style.WindowPadding      = imgui.ImVec2(14, 14)
    style.WindowRounding     = 12.0
    style.ChildRounding      = 8.0
    style.FramePadding       = imgui.ImVec2(9, 7)
    style.FrameRounding      = 8.0
    style.ItemSpacing        = imgui.ImVec2(10, 9)
    style.ItemInnerSpacing   = imgui.ImVec2(10, 6)
    style.IndentSpacing      = 22.0
    style.ScrollbarSize      = 14.0
    style.ScrollbarRounding  = 9.0
    style.GrabMinSize        = 12.0
    style.GrabRounding       = 6.0
    style.PopupRounding      = 10.0
    style.WindowTitleAlign   = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign    = imgui.ImVec2(0.5, 0.5)
    style.TabRounding        = 8.0
    style.ChildBorderSize    = 1.0
    style.FrameBorderSize    = 1.0
    style.WindowBorderSize   = 1.0
end

theme = {
    {
        change = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(0.93, 0.93, 0.93, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(0.55, 0.58, 0.60, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.13, 0.16, 0.19, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(0.14, 0.18, 0.21, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.16, 0.20, 0.24, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(0.00, 0.68, 0.71, 0.60)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(0.18, 0.22, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(0.00, 0.68, 0.71, 0.55)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(0.00, 0.68, 0.71, 0.85)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.11, 0.14, 0.17, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.11, 0.14, 0.17, 0.75)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.00, 0.68, 0.71, 0.85)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(0.18, 0.22, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(0.00, 0.68, 0.71, 0.85)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(0.00, 0.84, 0.88, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(0.00, 0.85, 0.88, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(0.00, 0.68, 0.71, 0.85)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(0.00, 0.85, 0.88, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(0.18, 0.22, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(0.00, 0.68, 0.71, 0.70)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(0.00, 0.85, 0.88, 0.90)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(0.15, 0.19, 0.22, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(0.00, 0.68, 0.71, 0.85)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(0.00, 0.85, 0.88, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(0.25, 0.28, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(0.00, 0.68, 0.71, 0.70)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(0.00, 0.85, 0.88, 0.90)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(0.00, 0.68, 0.71, 0.35)
            imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = ImVec4(0.13, 0.16, 0.19, 0.85)


        end
    }
}