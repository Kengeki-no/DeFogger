--[[
FogClear.lua

Reveals unexplored world-map overlays while leaving Blizzard's normal
explored overlays untouched.

Overlay names and geometry are based on the WotLK-compatible ElvUI Fog of War
data set. The data has been converted here from packed integers into explicit
width, height, X, and Y values for DeFogger.

ElvUI Fog of War is distributed under the MIT License.
https://github.com/cr4ckp0t/ElvUI_FogofWar
]]

local FogClear = {}
DeFogger.modules["fogClear"] = FogClear

local SubSet = DeFogger.SubSet

local TILE_SIZE = 256
local FOG_GREY = 0.50

-- Each overlay entry is:
-- { width, height, offsetX, offsetY }
local overlayData = {
    ["LochModan"] = {
        ["VALLEYOFKINGS"] = {195, 250, 109, 370},
        ["IRONBANDSEXCAVATIONSITE"] = {345, 256, 482, 321},
        ["THELSAMAR"] = {256, 230, 217, 203},
        ["SILVERSTREAMMINE"] = {235, 270, 229, 11},
        ["THELOCH"] = {320, 410, 352, 87},
        ["MOGROSHSTRONGHOLD"] = {315, 235, 542, 48},
        ["THEFARSTRIDERLODGE"] = {370, 295, 546, 199},
        ["STONESPLINTERVALLEY"] = {255, 285, 215, 348},
        ["STONEWROUGHTDAM"] = {290, 175, 339, 11},
        ["GRIZZLEPAWRIDGE"] = {295, 358, 309, 310},
        ["NORTHGATEPASS"] = {230, 300, 125, 12},
    },
    ["BurningSteppes"] = {
        ["TERRORWINGPATH"] = {280, 355, 722, 46},
        ["PILLAROFASH"] = {320, 270, 377, 285},
        ["BLACKROCKPASS"] = {270, 310, 589, 279},
        ["RUINSOFTHAURISSAN"] = {270, 285, 513, 99},
        ["DRACODAR"] = {415, 315, 56, 258},
        ["MORGANSVIGIL"] = {294, 270, 708, 311},
        ["BLACKROCKMOUNTAIN"] = {256, 280, 173, 101},
        ["ALTAROFSTORMS"] = {225, 220, 36, 109},
        ["BLACKROCKSTRONGHOLD"] = {245, 265, 334, 114},
        ["DREADMAULROCK"] = {220, 225, 707, 168},
    },
    ["Moonglade"] = {
        ["LAKEELUNEARA"] = {555, 510, 244, 89},
    },
    ["Barrens"] = {
        ["RATCHET"] = {125, 125, 556, 189},
        ["RAZORFENDOWNS"] = {155, 115, 407, 553},
        ["THEMERCHANTCOAST"] = {95, 100, 581, 247},
        ["GROLDOMFARM"] = {125, 115, 492, 63},
        ["CAMPTAURAJO"] = {145, 125, 365, 350},
        ["THEMORSHANRAMPART"] = {128, 100, 412, 0},
        ["AGAMAGOR"] = {200, 185, 340, 234},
        ["HONORSSTAND"] = {128, 128, 306, 130},
        ["THORNHILL"] = {140, 128, 498, 119},
        ["THESLUDGEFEN"] = {170, 120, 456, 0},
        ["RAPTORGROUNDS"] = {115, 110, 507, 294},
        ["DREADMISTPEAK"] = {128, 105, 419, 63},
        ["LUSHWATEROASIS"] = {175, 185, 365, 177},
        ["FIELDOFGIANTS"] = {210, 150, 355, 402},
        ["FARWATCHPOST"] = {100, 165, 564, 52},
        ["THEFORGOTTENPOOLS"] = {120, 125, 384, 115},
        ["RAZORFENKRAUL"] = {128, 128, 341, 537},
        ["NORTHWATCHFOLD"] = {150, 120, 527, 307},
        ["THESTAGNANTOASIS"] = {155, 128, 481, 211},
        ["BAELMODAN"] = {128, 128, 431, 479},
        ["BLACKTHORNRIDGE"] = {155, 128, 335, 462},
        ["BRAMBLESCAR"] = {125, 165, 442, 298},
        ["BOULDERLODEMINE"] = {120, 110, 555, 0},
        ["THEDRYHILLS"] = {200, 145, 317, 29},
        ["THECROSSROADS"] = {155, 155, 431, 118},
    },
    ["Winterspring"] = {
        ["LAKEKELTHERIL"] = {215, 185, 401, 198},
        ["WINTERFALLVILLAGE"] = {145, 125, 617, 158},
        ["FROSTWHISPERGORGE"] = {200, 160, 523, 376},
        ["MAZTHORIL"] = {185, 180, 493, 258},
        ["ICETHISTLEHILLS"] = {125, 165, 611, 242},
        ["THEHIDDENGROVE"] = {175, 185, 555, 27},
        ["TIMBERMAWPOST"] = {230, 120, 229, 243},
        ["EVERLOOK"] = {165, 200, 509, 107},
        ["DARKWHISPERGORGE"] = {255, 205, 447, 441},
        ["FROSTSABERROCK"] = {250, 180, 368, 7},
        ["OWLWINGTHICKET"] = {165, 140, 593, 340},
        ["STARFALLVILLAGE"] = {185, 160, 392, 137},
        ["FROSTFIREHOTSPRINGS"] = {240, 140, 222, 172},
    },
    ["Hinterlands"] = {
        ["THECREEPINGRUIN"] = {180, 170, 408, 260},
        ["SERADANE"] = {275, 275, 509, 19},
        ["JINTHAALOR"] = {235, 285, 505, 333},
        ["HIRIWATHA"] = {225, 200, 171, 306},
        ["SHAOLWATHA"] = {280, 205, 571, 239},
        ["THEOVERLOOKCLIFFS"] = {170, 310, 693, 303},
        ["SKULKROCK"] = {160, 145, 512, 232},
        ["AGOLWATHA"] = {205, 195, 374, 164},
        ["PLAGUEMISTRAVINE"] = {145, 220, 158, 149},
        ["AERIEPEAK"] = {255, 205, 13, 245},
        ["QUELDANILLODGE"] = {185, 195, 237, 185},
        ["VALORWINDLAKE"] = {170, 170, 319, 302},
        ["THEALTAROFZUL"] = {200, 165, 373, 365},
        ["SHADRAALOR"] = {195, 185, 240, 387},
    },
    ["Westfall"] = {
        ["WESTFALLLIGHTHOUSE"] = {280, 190, 205, 467},
        ["SENTINELHILL"] = {195, 240, 442, 241},
        ["JANGOLODEMINE"] = {215, 215, 307, 29},
        ["THEDUSTPLAINS"] = {288, 235, 523, 377},
        ["MOONBROOK"] = {220, 200, 317, 331},
        ["THEMOLSENFARM"] = {225, 205, 328, 148},
        ["ALEXSTONFARMSTEAD"] = {305, 210, 204, 260},
        ["DEMONTSPLACE"] = {200, 185, 208, 375},
        ["GOLDCOASTQUARRY"] = {225, 256, 220, 102},
        ["THEDAGGERHILLS"] = {256, 175, 339, 418},
        ["THEJANSENSTEAD"] = {165, 200, 488, 0},
        ["SALDEANSFARM"] = {225, 210, 459, 105},
        ["THEDEADACRE"] = {200, 240, 524, 252},
        ["FURLBROWSPUMPKINFARM"] = {210, 215, 387, 11},
    },
    ["Badlands"] = {
        ["APOCRYPHANSREST"] = {256, 256, 17, 310},
        ["THEDUSTBOWL"] = {270, 275, 159, 199},
        ["THEMAKERSTERRACE"] = {245, 205, 389, 7},
        ["CAMPCAGG"] = {256, 256, 12, 428},
        ["CAMPBOFF"] = {255, 280, 501, 341},
        ["LETHLORRAVINE"] = {370, 455, 611, 110},
        ["AGMONDSEND"] = {265, 270, 345, 389},
        ["CAMPKOSH"] = {220, 220, 551, 48},
        ["ANGORFORTRESS"] = {195, 200, 325, 148},
        ["MIRAGEFLATS"] = {256, 256, 148, 384},
        ["KARGATH"] = {256, 256, 0, 148},
        ["DUSTWINDGULCH"] = {245, 205, 498, 209},
        ["VALLEYOFFANGS"] = {230, 230, 349, 256},
        ["HAMMERTOESDIGSITE"] = {200, 195, 445, 120},
    },
    ["Darkshore"] = {
        ["TOWEROFALTHALAXX"] = {170, 195, 468, 85},
        ["GROVEOFTHEANCIENTS"] = {200, 170, 305, 412},
        ["CLIFFSPRINGRIVER"] = {230, 190, 375, 94},
        ["AUBERDINE"] = {150, 215, 318, 162},
        ["THEMASTERSGLAIVE"] = {175, 158, 329, 510},
        ["REMTRAVELSEXCAVATION"] = {175, 183, 229, 485},
        ["AMETHARAN"] = {190, 205, 324, 306},
        ["RUINSOFMATHYSTRA"] = {195, 215, 510, 0},
        ["BASHALARAN"] = {180, 195, 365, 181},
    },
    ["WesternPlaguelands"] = {
        ["GAHRRONSWITHERING"] = {180, 205, 520, 250},
        ["DARROWMERELAKE"] = {370, 270, 504, 343},
        ["THONDRORILRIVER"] = {205, 340, 590, 86},
        ["FELSTONEFIELD"] = {160, 125, 300, 311},
        ["HEARTHGLEN"] = {340, 288, 307, 16},
        ["THEWEEPINGCAVE"] = {160, 200, 566, 198},
        ["NORTHRIDGELUMBERCAMP"] = {220, 180, 382, 164},
        ["THEWRITHINGHAUNT"] = {170, 190, 451, 323},
        ["DALSONSTEARS"] = {220, 150, 381, 265},
        ["RUINSOFANDORHOL"] = {285, 230, 260, 355},
        ["CAERDARROW"] = {170, 165, 600, 412},
        ["SORROWHILL"] = {300, 206, 355, 462},
        ["THEBULWARK"] = {225, 185, 137, 293},
    },
    ["Desolace"] = {
        ["MAGRAMVILLAGE"] = {205, 285, 590, 365},
        ["VALLEYOFSPEARS"] = {245, 285, 212, 215},
        ["SHADOWPREYVILLAGE"] = {230, 230, 167, 389},
        ["TETHRISARAN"] = {205, 145, 431, 0},
        ["THUNDERAXEFORTRESS"] = {190, 220, 447, 102},
        ["MANNOROCCOVEN"] = {285, 280, 399, 380},
        ["SARGERON"] = {285, 245, 625, 33},
        ["KODOGRAVEYARD"] = {275, 250, 387, 244},
        ["KOLKARVILLAGE"] = {220, 220, 607, 215},
        ["ETHELRETHOR"] = {205, 250, 311, 61},
        ["SHADOWBREAKRAVINE"] = {205, 195, 690, 444},
        ["GELKISVILLAGE"] = {195, 242, 293, 426},
        ["RANAZJARISLE"] = {100, 100, 241, 6},
        ["KORMEKSHUT"] = {170, 160, 555, 181},
        ["NIJELSPOINT"] = {200, 250, 554, 0},
    },
    ["Arathi"] = {
        ["THANDOLSPAN"] = {200, 220, 355, 412},
        ["NORTHFOLDMANOR"] = {230, 240, 192, 90},
        ["HAMMERFALL"] = {205, 250, 655, 120},
        ["BOULDERGOR"] = {245, 245, 232, 145},
        ["BOULDERFISTHALL"] = {215, 235, 432, 362},
        ["CIRCLEOFWESTBINDING"] = {190, 210, 138, 54},
        ["WITHERBARKVILLAGE"] = {215, 210, 559, 333},
        ["DABYRIESFARMSTEAD"] = {180, 210, 472, 165},
        ["CIRCLEOFINNERBINDING"] = {210, 185, 286, 310},
        ["CIRCLEOFOUTERBINDING"] = {170, 155, 419, 293},
        ["FALDIRSCOVE"] = {256, 215, 171, 424},
        ["GOSHEKFARM"] = {230, 195, 531, 276},
        ["THORADINSWALL"] = {190, 240, 87, 138},
        ["REFUGEPOINT"] = {175, 225, 370, 186},
        ["CIRCLEOFEASTBINDING"] = {160, 230, 558, 112},
        ["STROMGARDEKEEP"] = {240, 230, 108, 287},
    },
    ["Durotar"] = {
        ["DRYGULCHRAVINE"] = {210, 160, 427, 78},
        ["ORGRIMMAR"] = {445, 160, 244, 0},
        ["TIRAGARDEKEEP"] = {190, 180, 462, 286},
        ["THUNDERRIDGE"] = {190, 200, 327, 60},
        ["KOLKARCRAG"] = {160, 120, 413, 476},
        ["RAZORHILL"] = {220, 230, 432, 170},
        ["ECHOISLES"] = {200, 240, 549, 427},
        ["SENJINVILLAGE"] = {160, 190, 474, 384},
        ["SKULLROCK"] = {128, 110, 464, 33},
        ["RAZORMANEGROUNDS"] = {230, 230, 301, 189},
        ["VALLEYOFTRIALS"] = {215, 215, 355, 320},
    },
    ["Tirisfal"] = {
        ["RUINSOFLORDAERON"] = {315, 235, 463, 361},
        ["MONASTARY"] = {211, 189, 746, 125},
        ["SCARLETWATCHPOST"] = {175, 247, 689, 104},
        ["STILLWATERPOND"] = {186, 128, 395, 277},
        ["BALNIRFARMSTEAD"] = {216, 179, 630, 326},
        ["BULWARK"] = {230, 205, 698, 362},
        ["VENOMWEBVALE"] = {237, 214, 757, 205},
        ["GARRENSHAUNT"] = {174, 220, 497, 145},
        ["BRIGHTWATERLAKE"] = {201, 288, 587, 139},
        ["DEATHKNELL"] = {245, 205, 227, 328},
        ["BRILL"] = {128, 256, 537, 299},
        ["NIGHTMAREVALE"] = {243, 199, 363, 349},
        ["COLDHEARTHMANOR"] = {150, 128, 474, 327},
        ["AGAMANDMILLS"] = {256, 210, 335, 139},
        ["CRUSADEROUTPOST"] = {173, 128, 694, 289},
        ["SOLLIDENFARMSTEAD"] = {256, 156, 239, 250},
    },
    ["SwampOfSorrows"] = {
        ["MISTYVALLEY"] = {245, 305, 0, 140},
        ["MISTYREEDSTRAND"] = {256, 668, 746, 0},
        ["THEHARBORAGE"] = {235, 205, 171, 145},
        ["POOLOFTEARS"] = {300, 275, 565, 218},
        ["SORROWMURK"] = {215, 365, 724, 120},
        ["STONARD"] = {360, 315, 279, 237},
        ["THESHIFTINGMIRE"] = {315, 235, 286, 110},
        ["SPLINTERSPEARJUNCTION"] = {275, 240, 129, 236},
        ["STAGALBOG"] = {345, 250, 552, 378},
        ["FALLOWSANCTUARY"] = {365, 305, 492, 0},
        ["ITHARIUSSCAVE"] = {240, 245, 0, 262},
    },
    ["StonetalonMountains"] = {
        ["WEBWINDERPATH"] = {288, 355, 457, 282},
        ["BOULDERSLIDERAVINE"] = {145, 107, 572, 561},
        ["CAMPAPARAJE"] = {190, 97, 718, 571},
        ["WINDSHEARCRAG"] = {320, 275, 553, 197},
        ["STONETALONPEAK"] = {270, 205, 247, 0},
        ["SUNROCKRETREAT"] = {150, 150, 389, 320},
        ["SISHIRCANYON"] = {125, 125, 475, 433},
        ["GRIMTOTEMPOST"] = {225, 120, 668, 515},
        ["THECHARREDVALE"] = {230, 355, 210, 234},
        ["MALAKAJIN"] = {125, 86, 663, 582},
        ["MIRKFALLONLAKE"] = {200, 215, 390, 145},
    },
    ["DunMorogh"] = {
        ["ANVILMAR"] = {240, 185, 155, 403},
        ["THETUNDRIDHILLS"] = {155, 128, 522, 322},
        ["COLDRIDGEPASS"] = {150, 128, 295, 385},
        ["IRONFORGE"] = {315, 200, 397, 163},
        ["ICEFLOWLAKE"] = {128, 180, 281, 167},
        ["FROSTMANEHOLD"] = {125, 125, 217, 287},
        ["MISTYPINEREFUGE"] = {128, 165, 502, 221},
        ["GOLBOLARQUARRY"] = {165, 165, 608, 291},
        ["AMBERSTILLRANCH"] = {128, 128, 573, 280},
        ["GNOMERAGON"] = {180, 165, 166, 184},
        ["HELMSBEDLAKE"] = {155, 170, 694, 273},
        ["THEGRIZZLEDDEN"] = {200, 185, 314, 311},
        ["SOUTHERNGATEOUTPOST"] = {128, 120, 792, 279},
        ["CHILLBREEZEVALLEY"] = {180, 128, 274, 296},
        ["NORTHERNGATEOUTPOST"] = {128, 165, 759, 173},
        ["BREWNALLVILLAGE"] = {115, 115, 252, 249},
        ["KHARANOS"] = {200, 200, 386, 294},
        ["SHIMMERRIDGE"] = {128, 190, 347, 163},
    },
    ["SearingGorge"] = {
        ["BLACKCHARCAVE"] = {275, 235, 77, 366},
        ["THECAULDRON"] = {425, 325, 250, 170},
        ["FIREWATCHRIDGE"] = {405, 430, 85, 30},
        ["THESEAOFCINDERS"] = {360, 280, 247, 388},
        ["DUSTFIREVALLEY"] = {460, 365, 422, 8},
        ["TANNERCAMP"] = {305, 230, 545, 407},
        ["GRIMSILTDIGSITE"] = {305, 220, 494, 300},
    },
    ["Hilsbrad"] = {
        ["EASTERNSTRAND"] = {230, 320, 524, 339},
        ["PURGATIONISLE"] = {125, 100, 109, 482},
        ["DURNHOLDEKEEP"] = {384, 365, 605, 75},
        ["SOUTHPOINTTOWER"] = {288, 225, 2, 192},
        ["WESTERNSTRAND"] = {285, 155, 208, 368},
        ["SOUTHSHORE"] = {235, 270, 418, 201},
        ["AZURELOADMINE"] = {165, 200, 175, 275},
        ["NETHANDERSTEAD"] = {215, 240, 541, 236},
        ["TARRENMILL"] = {220, 310, 509, 0},
        ["HILLSBRADFIELDS"] = {305, 275, 198, 155},
        ["DARROWHILL"] = {205, 155, 414, 154},
        ["DUNGAROK"] = {240, 275, 637, 294},
    },
    ["Duskwood"] = {
        ["THEROTTINGORCHARD"] = {250, 230, 539, 369},
        ["ADDLESSTEAD"] = {275, 250, 55, 342},
        ["RAVENHILLCEMETARY"] = {350, 300, 85, 149},
        ["DARKSHIRE"] = {315, 280, 631, 162},
        ["RAVENHILL"] = {195, 145, 102, 302},
        ["THEDARKENEDBANK"] = {910, 210, 89, 31},
        ["BRIGHTWOODGROVE"] = {220, 340, 504, 117},
        ["TWILIGHTGROVE"] = {360, 420, 298, 79},
        ["VULGOLOGREMOUND"] = {255, 285, 243, 348},
        ["MANORMISTMANTLE"] = {200, 175, 653, 120},
        ["TRANQUILGARDENSCEMETARY"] = {220, 220, 690, 353},
        ["THEYORGENFARMSTEAD"] = {235, 250, 390, 382},
        ["THEHUSHEDBANK"] = {160, 330, 19, 132},
    },
    ["ThousandNeedles"] = {
        ["THEGREATLIFT"] = {210, 180, 205, 70},
        ["WINDBREAKCANYON"] = {240, 220, 492, 250},
        ["HIGHPERCH"] = {190, 190, 31, 155},
        ["FREEWINDPOST"] = {210, 190, 357, 264},
        ["THESCREECHINGCANYON"] = {250, 240, 179, 200},
        ["DARKCLOUDPINNACLE"] = {205, 195, 259, 131},
        ["CAMPETHOK"] = {305, 310, 0, 0},
        ["THESHIMMERINGFLATS"] = {320, 365, 610, 300},
        ["SPLITHOOFCRAG"] = {210, 195, 391, 192},
    },
    ["Ashenvale"] = {
        ["WARSONGLUMBERCAMP"] = {200, 160, 796, 311},
        ["THESHRINEOFAESSINA"] = {220, 195, 104, 259},
        ["THERUINSOFSTARDUST"] = {155, 150, 260, 373},
        ["THISTLEFURVILLAGE"] = {255, 195, 203, 158},
        ["FELFIREHILL"] = {245, 255, 713, 344},
        ["LAKEFALATHIM"] = {128, 195, 131, 137},
        ["IRISLAKE"] = {200, 205, 392, 218},
        ["MYSTRALLAKE"] = {275, 240, 356, 347},
        ["NIGHTRUN"] = {225, 255, 597, 258},
        ["MAESTRASPOST"] = {215, 305, 205, 38},
        ["THEZORAMSTRAND"] = {245, 245, 19, 28},
        ["SATYRNAAR"] = {285, 185, 694, 225},
        ["FALLENSKYLAKE"] = {235, 205, 547, 426},
        ["FIRESCARSHRINE"] = {165, 175, 189, 324},
        ["THEHOWLINGVALE"] = {210, 185, 463, 141},
        ["BOUGHSHADOW"] = {146, 200, 856, 151},
        ["ASTRANAAR"] = {205, 185, 272, 251},
        ["RAYNEWOODRETREAT"] = {180, 245, 520, 238},
    },
    ["Teldrassil"] = {
        ["THEORACLEGLADE"] = {170, 240, 272, 127},
        ["WELLSPRINGLAKE"] = {180, 256, 377, 93},
        ["LAKEALAMETH"] = {256, 185, 436, 380},
        ["BANETHILHOLLOW"] = {160, 210, 382, 281},
        ["POOLSOFARLITHRIEN"] = {128, 190, 335, 313},
        ["DARNASSUS"] = {315, 256, 101, 247},
        ["STARBREEZEVILLAGE"] = {200, 200, 561, 292},
        ["GNARLPINEHOLD"] = {185, 128, 368, 443},
        ["SHADOWGLEN"] = {225, 225, 491, 153},
        ["RUTTHERANVILLAGE"] = {128, 100, 494, 548},
        ["DOLANAAR"] = {190, 128, 462, 323},
    },
    ["BlastedLands"] = {
        ["DREADMAULPOST"] = {245, 195, 361, 195},
        ["GARRISONARMORY"] = {170, 200, 472, 9},
        ["SERPENTSCOIL"] = {225, 170, 501, 140},
        ["THETAINTEDSCAR"] = {384, 450, 212, 178},
        ["DARKPORTAL"] = {265, 220, 453, 259},
        ["RISEOFTHEDEFILER"] = {170, 145, 405, 123},
        ["ALTAROFSTORMS"] = {185, 155, 310, 133},
        ["DREADMAULHOLD"] = {195, 180, 361, 15},
        ["NETHERGARDEKEEP"] = {185, 190, 559, 30},
    },
    ["Mulgore"] = {
        ["WINDFURYRIDGE"] = {205, 128, 395, 0},
        ["WILDMANEWATERWELL"] = {185, 128, 291, 0},
        ["THEVENTURECOMINE"] = {225, 235, 532, 238},
        ["REDCLOUDMESA"] = {470, 243, 270, 425},
        ["THEGOLDENPLAINS"] = {215, 240, 428, 80},
        ["THEROLLINGPLAINS"] = {256, 190, 523, 356},
        ["RAVAGEDCARAVAN"] = {128, 120, 473, 260},
        ["BLOODHOOFVILLAGE"] = {256, 200, 367, 303},
        ["THUNDERHORNWATERWELL"] = {128, 155, 379, 242},
        ["REDROCKS"] = {205, 230, 502, 16},
        ["BAELDUNDIGSITE"] = {210, 180, 255, 214},
        ["PALEMANEROCK"] = {128, 205, 303, 307},
        ["WINTERHOOFWATERWELL"] = {170, 128, 458, 369},
        ["THUNDERBLUFF"] = {280, 240, 249, 59},
    },
    ["Felwood"] = {
        ["SHATTERSCARVALE"] = {235, 200, 307, 123},
        ["DEADWOODVILLAGE"] = {175, 135, 408, 533},
        ["IRONTREEWOODS"] = {215, 215, 420, 54},
        ["JADEFIREGLEN"] = {165, 155, 332, 465},
        ["JADEFIRERUN"] = {195, 170, 330, 29},
        ["BLOODVENOMFALLS"] = {235, 145, 292, 263},
        ["TALONBRANCHGLADE"] = {160, 145, 548, 90},
        ["JAEDENAR"] = {245, 128, 271, 331},
        ["FELPAWVILLAGE"] = {240, 145, 483, 0},
        ["MORLOSARAN"] = {145, 159, 496, 509},
        ["EMERALDSANCTUARY"] = {185, 160, 405, 429},
        ["RUINSOFCONSTELLAS"] = {235, 155, 297, 381},
    },
    ["Silverpine"] = {
        ["THESEPULCHER"] = {210, 160, 352, 168},
        ["MALDENSORCHARD"] = {256, 160, 465, 0},
        ["THESHININGSTRAND"] = {256, 220, 459, 13},
        ["THEGREYMANEWALL"] = {210, 215, 379, 447},
        ["DEEPELEMMINE"] = {160, 170, 470, 261},
        ["AMBERMILL"] = {240, 240, 494, 262},
        ["THESKITTERINGDARK"] = {185, 165, 286, 37},
        ["NORTHTIDESHOLLOW"] = {180, 128, 323, 128},
        ["PYREWOODVILLAGE"] = {140, 125, 391, 446},
        ["THEDEADFIELD"] = {175, 165, 402, 65},
        ["BERENSPERIL"] = {240, 180, 491, 417},
        ["THEDECREPITFERRY"] = {180, 185, 457, 144},
        ["SHADOWFANGKEEP"] = {220, 160, 364, 359},
        ["FENRISISLE"] = {250, 215, 593, 74},
        ["OLSENSFARTHING"] = {165, 185, 382, 252},
    },
    ["Aszhara"] = {
        ["SOUTHRIDGEBEACH"] = {370, 220, 389, 353},
        ["BITTERREACHES"] = {245, 185, 644, 40},
        ["FORLORNRIDGE"] = {220, 255, 191, 369},
        ["JAGGEDREEF"] = {570, 170, 366, 0},
        ["RUINSOFELDARATH"] = {265, 280, 238, 221},
        ["TOWEROFELDARA"] = {120, 155, 818, 107},
        ["SHADOWSONGSHRINE"] = {225, 180, 35, 422},
        ["THALASSIANBASECAMP"] = {240, 155, 499, 119},
        ["THERUINEDREACHES"] = {395, 128, 396, 540},
        ["VALORMOK"] = {215, 175, 84, 229},
        ["HALDARRENCAMPMENT"] = {200, 150, 77, 331},
        ["RAVENCRESTMONUMENT"] = {240, 125, 552, 499},
        ["TEMPLEOFARKKORAN"] = {190, 200, 681, 153},
        ["URSOLAN"] = {145, 215, 422, 95},
        ["BAYOFSTORMS"] = {270, 300, 479, 201},
        ["THESHATTEREDSTRAND"] = {160, 210, 404, 194},
        ["LAKEMENNAR"] = {315, 200, 296, 429},
        ["TIMBERMAWHOLD"] = {235, 270, 250, 106},
        ["LEGASHENCAMPMENT"] = {235, 140, 478, 44},
    },
    ["Elwynn"] = {
        ["NORTHSHIREVALLEY"] = {256, 256, 381, 147},
        ["EASTVALELOGGINGCAMP"] = {256, 210, 704, 330},
        ["BRACKWELLPUMPKINPATCH"] = {256, 249, 577, 419},
        ["FORESTSEDGE"] = {256, 341, 124, 327},
        ["JERODSLANDING"] = {256, 237, 425, 431},
        ["FARGODEEPMINE"] = {256, 240, 238, 428},
        ["RIDGEPOINTTOWER"] = {306, 233, 696, 435},
        ["CRYSTALLAKE"] = {225, 220, 422, 332},
        ["STORMWIND"] = {485, 405, 0, 0},
        ["TOWEROFAZORA"] = {255, 250, 551, 292},
        ["GOLDSHIRE"] = {240, 220, 250, 270},
        ["STONECAIRNLAKE"] = {310, 256, 587, 190},
    },
    ["Tanaris"] = {
        ["SANDSORROWWATCH"] = {195, 175, 299, 100},
        ["STEAMWHEEDLEPORT"] = {155, 150, 592, 75},
        ["SOUTHMOONRUINS"] = {195, 210, 323, 359},
        ["WATERSPRINGFIELD"] = {165, 180, 509, 168},
        ["DUNEMAULCOMPOUND"] = {205, 145, 325, 289},
        ["VALLEYOFTHEWATCHERS"] = {150, 160, 291, 434},
        ["CAVERNSOFTIME"] = {155, 150, 561, 256},
        ["EASTMOONRUINS"] = {160, 150, 395, 346},
        ["ABYSSALSANDS"] = {215, 180, 363, 194},
        ["GADGETZAN"] = {175, 165, 421, 91},
        ["THISTLESHRUBVALLEY"] = {185, 250, 203, 286},
        ["LANDSENDBEACH"] = {205, 157, 445, 511},
        ["ZALASHJISDEN"] = {110, 140, 611, 147},
        ["THENOXIOUSLAIR"] = {180, 200, 252, 199},
        ["ZULFARRAK"] = {210, 175, 254, 0},
        ["NOONSHADERUINS"] = {120, 135, 533, 104},
        ["LOSTRIGGERCOVE"] = {160, 190, 629, 220},
        ["BROKENPILLAR"] = {110, 180, 473, 234},
        ["THEGAPINGCHASM"] = {220, 210, 449, 372},
        ["SOUTHBREAKSHORE"] = {215, 175, 499, 293},
    },
    ["Silithus"] = {
        ["THESCARABWALL"] = {288, 256, 116, 413},
        ["TWILIGHTBASECAMP"] = {320, 256, 344, 197},
        ["HIVEASHI"] = {512, 320, 265, 12},
        ["SOUTHWINDVILLAGE"] = {384, 384, 500, 65},
        ["HIVEREGAL"] = {512, 384, 245, 285},
        ["THECRYSTALVALE"] = {320, 289, 104, 24},
        ["HIVEZORA"] = {384, 512, 97, 144},
    },
    ["Feralas"] = {
        ["SARDORISLE"] = {180, 180, 208, 234},
        ["FERALSCARVALE"] = {115, 115, 486, 329},
        ["ONEIROS"] = {110, 110, 493, 70},
        ["THETWINCOLOSSALS"] = {285, 245, 319, 75},
        ["FRAYFEATHERHIGHLANDS"] = {110, 170, 478, 386},
        ["THEFORGOTTENCOAST"] = {145, 320, 404, 256},
        ["THEWRITHINGDEEP"] = {240, 220, 618, 298},
        ["DIREMAUL"] = {230, 195, 454, 201},
        ["CAMPMOJACHE"] = {155, 160, 689, 233},
        ["LOWERWILDS"] = {225, 180, 751, 198},
        ["GRIMTOTEMCOMPOUND"] = {120, 195, 623, 167},
        ["RUINSOFISILDIEN"] = {190, 250, 540, 320},
        ["DREAMBOUGH"] = {150, 125, 454, 0},
        ["ISLEOFDREAD"] = {215, 293, 192, 375},
        ["GORDUNNIOUTPOST"] = {140, 165, 690, 141},
        ["RUINSOFRAVENWIND"] = {190, 155, 305, 0},
    },
    ["EasternPlaguelands"] = {
        ["BLACKWOODLAKE"] = {256, 256, 412, 177},
        ["NORTHDALE"] = {256, 256, 590, 106},
        ["PLAGUEWOOD"] = {384, 288, 139, 61},
        ["ZULMASHAR"] = {256, 256, 584, 8},
        ["ScarletEnclave"] = {284, 450, 718, 218},
        ["QUELLITHIENLODGE"] = {256, 256, 392, 14},
        ["THEUNDERCROFT"] = {256, 191, 142, 455},
        ["THONDRORILRIVER"] = {256, 384, 0, 209},
        ["THEMARRISSTEAD"] = {256, 256, 126, 338},
        ["THEFUNGALVALE"] = {256, 256, 241, 239},
        ["TYRSHAND"] = {256, 197, 687, 449},
        ["CROWNGUARDTOWER"] = {256, 256, 261, 379},
        ["STRATHOLME"] = {256, 243, 164, 0},
        ["LAKEMERELDAR"] = {256, 205, 474, 412},
        ["CORINSCROSSING"] = {256, 256, 471, 345},
        ["EASTWALLTOWER"] = {256, 256, 562, 219},
        ["NORTHPASSTOWER"] = {256, 256, 427, 87},
        ["DARROWSHIRE"] = {256, 179, 279, 467},
        ["PestilentScar"] = {256, 288, 590, 269},
        ["TheInfectisScar"] = {256, 256, 379, 323},
        ["THENOXIOUSGLADE"] = {256, 256, 692, 144},
        ["TERRORDALE"] = {256, 256, 49, 76},
        ["LIGHTSHOPECHAPEL"] = {256, 256, 656, 277},
    },
    ["UngoroCrater"] = {
        ["THESLITHERINGSCAR"] = {345, 285, 367, 380},
        ["FIREPLUMERIDGE"] = {295, 270, 367, 178},
        ["TERRORRUN"] = {345, 285, 158, 368},
        ["IRONSTONEPLATEAU"] = {285, 285, 582, 67},
        ["GOLAKKAHOTSPRINGS"] = {315, 345, 121, 151},
        ["THEMARSHLANDS"] = {310, 355, 560, 240},
        ["LAKKARITARPITS"] = {570, 265, 160, 6},
    },
    ["Dustwallow"] = {
        ["THEDENOFFLAME"] = {255, 250, 257, 313},
        ["BACKBAYWETLANDS"] = {400, 255, 239, 189},
        ["THERAMOREISLE"] = {230, 205, 534, 224},
        ["BRACKENWALLVILLAGE"] = {280, 270, 230, 0},
        ["ALCAZISLAND"] = {200, 195, 660, 21},
        ["THEWYRMBOG"] = {285, 240, 367, 381},
        ["WITCHHILL"] = {250, 315, 422, 0},
    },
    ["DeadwindPass"] = {
        ["KARAZHAN"] = {300, 245, 269, 337},
        ["DEADMANSCROSSING"] = {380, 365, 249, 76},
        ["THEVICE"] = {270, 270, 426, 299},
    },
    ["Wetlands"] = {
        ["BLACKCHANNELMARSH"] = {240, 175, 77, 245},
        ["WHELGARSEXCAVATIONSITE"] = {195, 185, 247, 205},
        ["GRIMBATOL"] = {350, 360, 611, 230},
        ["MOSSHIDEFEN"] = {205, 245, 527, 264},
        ["RAPTORRIDGE"] = {190, 160, 628, 176},
        ["THEGREENBELT"] = {185, 240, 456, 125},
        ["MENETHILHARBOR"] = {175, 128, 13, 314},
        ["ANGERFANGENCAMPMENT"] = {225, 185, 347, 218},
        ["DUNMODR"] = {205, 180, 401, 21},
        ["THELGANROCK"] = {230, 190, 470, 371},
        ["BLUEGILLMARSH"] = {225, 190, 89, 142},
        ["SALTSPRAYGLEN"] = {200, 240, 237, 41},
        ["IRONBEARDSTOMB"] = {200, 185, 349, 115},
        ["DIREFORGEHILL"] = {256, 250, 507, 115},
        ["SUNDOWNMARSH"] = {300, 240, 92, 82},
    },
    ["Redridge"] = {
        ["STONEWATCH"] = {255, 300, 500, 215},
        ["ALTHERSMILL"] = {235, 270, 399, 129},
        ["THREECORNERS"] = {365, 350, 0, 284},
        ["GALARDELLVALLEY"] = {250, 250, 654, 161},
        ["LAKESHIRE"] = {340, 195, 83, 197},
        ["REDRIDGECANYONS"] = {365, 245, 121, 72},
        ["STONEWATCHFALLS"] = {320, 210, 595, 320},
        ["LAKERIDGEHIGHWAY"] = {430, 290, 187, 333},
        ["RENDERSCAMP"] = {275, 256, 277, 0},
        ["LAKEEVERSTILL"] = {535, 275, 133, 240},
        ["RENDERSVALLEY"] = {465, 255, 484, 361},
    },
    ["Stranglethorn"] = {
        ["WILDSHORE"] = {165, 190, 229, 422},
        ["BOOTYBAY"] = {145, 128, 203, 433},
        ["RUINSOFZULMAMWE"] = {170, 125, 394, 212},
        ["BLOODSAILCOMPOUND"] = {165, 175, 194, 284},
        ["KALAIRUINS"] = {95, 95, 299, 88},
        ["MIZJAHRUINS"] = {105, 110, 311, 131},
        ["MISTVALEVALLEY"] = {125, 125, 280, 368},
        ["REBELCAMP"] = {170, 90, 284, 0},
        ["BALALRUINS"] = {90, 80, 241, 92},
        ["VENTURECOBASECAMP"] = {105, 125, 387, 64},
        ["RUINSOFJUBUWAL"] = {110, 110, 306, 301},
        ["CRYSTALVEINMINE"] = {120, 120, 345, 276},
        ["JAGUEROISLE"] = {125, 120, 314, 493},
        ["BALIAMAHRUINS"] = {110, 140, 371, 129},
        ["ZULGURUB"] = {245, 220, 483, 8},
        ["ZUULDAIARUINS"] = {115, 115, 156, 42},
        ["NEKMANIWELLSPRING"] = {90, 115, 211, 359},
        ["MOSHOGGOGREMOUND"] = {128, 175, 432, 94},
        ["RUINSOFABORAZ"] = {95, 95, 350, 335},
        ["THEARENA"] = {200, 185, 235, 189},
        ["RUINSOFZULKUNDA"] = {125, 140, 196, 3},
        ["ZIATAJAIRUINS"] = {128, 125, 364, 231},
        ["KURZENSCOMPOUND"] = {155, 150, 388, 0},
        ["THEVILEREEF"] = {190, 175, 152, 90},
        ["LAKENAZFERITI"] = {128, 125, 331, 59},
        ["NESINGWARYSEXPEDITION"] = {140, 110, 269, 26},
        ["GROMGOLBASECAMP"] = {110, 105, 260, 132},
    },
    ["Alterac"] = {
        ["DANDREDSFOLD"] = {285, 230, 276, 0},
        ["THEUPLANDS"] = {235, 200, 462, 77},
        ["DALARAN"] = {300, 300, 26, 262},
        ["SOFERASNAZE"] = {255, 320, 462, 307},
        ["LORDAMEREINTERNMENTCAMP"] = {330, 265, 44, 403},
        ["CHILLWINDPOINT"] = {350, 370, 626, 253},
        ["THEHEADLAND"] = {165, 197, 314, 471},
        ["CRUSHRIDGEHOLD"] = {280, 240, 334, 162},
        ["MISTYSHORE"] = {220, 280, 196, 131},
        ["GALLOWSCORNER"] = {200, 200, 406, 279},
        ["STRAHNBRAD"] = {370, 300, 549, 105},
        ["GAVINSNAZE"] = {160, 175, 225, 478},
        ["GROWLESSCAVE"] = {190, 170, 317, 372},
        ["RUINSOFALTERAC"] = {255, 255, 270, 197},
        ["CORRAHNSDAGGER"] = {195, 288, 399, 380},
    },
    ["AzuremystIsle"] = {
        ["AzureWatch"] = {256, 256, 383, 249},
        ["MoongrazeWoods"] = {256, 256, 449, 183},
        ["StillpineHold"] = {256, 256, 365, 49},
        ["BristlelimbVillage"] = {256, 256, 174, 363},
        ["GreezlesCamp"] = {256, 256, 507, 350},
        ["WrathscalePoint"] = {256, 247, 220, 421},
        ["PodWreckage"] = {128, 256, 462, 349},
        ["PodCluster"] = {256, 256, 281, 305},
        ["AmmenFord"] = {256, 256, 515, 279},
        ["SiltingShore"] = {256, 256, 291, 3},
        ["Emberglade"] = {256, 256, 488, 24},
        ["TheExodar"] = {512, 512, 74, 85},
        ["FairbridgeStrand"] = {256, 128, 356, 0},
        ["ValaarsBerth"] = {256, 256, 176, 303},
        ["OdesyusLanding"] = {256, 256, 352, 378},
        ["AmmenVale"] = {475, 512, 527, 104},
        ["SilvermystIsle"] = {256, 222, 23, 446},
    },
    ["Netherstorm"] = {
        ["SocretharsSeat"] = {256, 256, 229, 38},
        ["NetherstormBridge"] = {256, 256, 132, 294},
        ["EtheriumStagingGrounds"] = {256, 256, 481, 208},
        ["TheStormspire"] = {256, 256, 298, 134},
        ["KirinVarVillage"] = {256, 145, 490, 523},
        ["ManaforgeCoruu"] = {256, 179, 357, 489},
        ["ManafrogeAra"] = {256, 256, 171, 155},
        ["TempestKeep"] = {409, 384, 593, 284},
        ["RuinsofFarahlon"] = {512, 256, 354, 49},
        ["RuinsofEnkaat"] = {256, 256, 253, 301},
        ["TheScrapField"] = {256, 256, 356, 261},
        ["CelestialRidge"] = {256, 256, 644, 173},
        ["ForgeBaseOG"] = {256, 256, 237, 22},
        ["RuinedManaforge"] = {256, 256, 513, 138},
        ["Area52"] = {256, 128, 241, 388},
        ["EcoDomeFarfield"] = {256, 256, 396, 10},
        ["Netherstone"] = {256, 256, 411, 20},
        ["ManaforgeBanar"] = {256, 387, 147, 281},
        ["ManaforgeDuro"] = {256, 256, 465, 336},
        ["ArklonRuins"] = {256, 256, 328, 397},
        ["TheHeap"] = {256, 213, 239, 455},
        ["SunfuryHold"] = {256, 217, 454, 451},
    },
    ["Hellfire"] = {
        ["MagharPost"] = {256, 256, 206, 110},
        ["ZethGor"] = {422, 238, 580, 430},
        ["HonorHold"] = {256, 256, 469, 298},
        ["HellfireCitadel"] = {256, 458, 338, 210},
        ["TheLegionFront"] = {256, 512, 579, 128},
        ["WarpFields"] = {256, 260, 308, 408},
        ["TempleofTelhamat"] = {512, 512, 38, 152},
        ["VoidRidge"] = {256, 256, 705, 368},
        ["PoolsofAggonar"] = {256, 512, 326, 45},
        ["FalconWatch"] = {512, 342, 183, 326},
        ["ForgeCampRage"] = {512, 512, 478, 25},
        ["DenofHaalesh"] = {256, 256, 182, 412},
        ["TheStairofDestiny"] = {256, 512, 737, 156},
        ["FallenSkyRidge"] = {256, 256, 34, 142},
        ["Thrallmar"] = {256, 256, 467, 154},
        ["ThroneofKiljaeden"] = {512, 256, 477, 6},
        ["ExpeditionArmory"] = {512, 255, 261, 413},
        ["RuinsofShanaar"] = {256, 378, 25, 290},
    },
    ["BladesEdgeMountains"] = {
        ["VekhaarStand"] = {256, 256, 629, 406},
        ["ForgeCampWrath"] = {256, 256, 254, 176},
        ["VeilLashh"] = {256, 240, 271, 428},
        ["RuuanWeald"] = {256, 512, 479, 98},
        ["BladesipreHold"] = {256, 507, 314, 161},
        ["ThunderlordStronghold"] = {256, 396, 405, 272},
        ["RidgeofMadness"] = {256, 410, 554, 258},
        ["BladedGulch"] = {256, 256, 623, 147},
        ["CircleofWrath"] = {256, 256, 439, 210},
        ["BashirLanding"] = {256, 256, 422, 0},
        ["MokNathalVillage"] = {256, 256, 658, 297},
        ["Skald"] = {256, 256, 673, 71},
        ["VeilRuuan"] = {256, 128, 563, 151},
        ["BloodmaulOutpost"] = {256, 297, 342, 371},
        ["Sylvanaar"] = {256, 318, 289, 350},
        ["VortexPinnacle"] = {256, 462, 166, 206},
        ["Grishnath"] = {256, 256, 286, 28},
        ["JaggedRidge"] = {256, 254, 446, 414},
        ["RavensWood"] = {512, 256, 214, 55},
        ["RazorRidge"] = {256, 336, 533, 332},
        ["ForgeCampAnger"] = {416, 256, 586, 147},
        ["GruulsLayer"] = {256, 256, 527, 81},
        ["DeathsDoor"] = {256, 419, 512, 249},
        ["BrokenWilds"] = {256, 256, 733, 109},
        ["ForgeCampTerror"] = {512, 252, 144, 416},
        ["BloodmaulCamp"] = {256, 256, 412, 95},
        ["TheCrystalpine"] = {256, 256, 585, 0},
    },
    ["Ghostlands"] = {
        ["GoldenmistVillage"] = {512, 512, 44, 0},
        ["ZebNowa"] = {512, 431, 466, 237},
        ["HowlingZiggurat"] = {256, 449, 340, 219},
        ["FarstriderEnclave"] = {429, 256, 573, 136},
        ["DawnstarSpire"] = {427, 256, 575, 0},
        ["WindrunnerVillage"] = {256, 512, 60, 117},
        ["Deatholme"] = {512, 293, 95, 375},
        ["SanctumoftheSun"] = {256, 512, 448, 150},
        ["IsleofTribulations"] = {256, 256, 585, 0},
        ["SuncrownVillage"] = {512, 256, 460, 0},
        ["SanctumoftheMoon"] = {256, 256, 210, 126},
        ["Tranquillien"] = {256, 512, 365, 2},
        ["ElrendarCrossing"] = {512, 256, 326, 0},
        ["BleedingZiggurat"] = {256, 256, 184, 238},
        ["ThalassiaPass"] = {256, 262, 364, 406},
        ["WindrunnerSpire"] = {256, 256, 40, 287},
        ["AmaniPass"] = {404, 436, 598, 232},
    },
    ["Zangarmarsh"] = {
        ["ZabraJin"] = {256, 256, 175, 232},
        ["AngoroshStronghold"] = {256, 128, 124, 0},
        ["TwinspireRuins"] = {256, 256, 342, 249},
        ["BloodscaleEnclave"] = {256, 256, 596, 412},
        ["CoilfangReservoir"] = {256, 512, 462, 90},
        ["Telredor"] = {256, 512, 569, 112},
        ["TheDeadMire"] = {286, 512, 716, 128},
        ["Sporeggar"] = {512, 256, 20, 202},
        ["CenarionRefuge"] = {308, 256, 694, 321},
        ["TheHewnBog"] = {256, 512, 219, 51},
        ["MarshlightLake"] = {256, 256, 81, 152},
        ["QuaggRidge"] = {256, 343, 141, 325},
        ["TheLagoon"] = {256, 256, 512, 303},
        ["UmbrafenVillage"] = {256, 207, 720, 461},
        ["TheSpawningGlen"] = {256, 256, 31, 339},
        ["AngoroshGrounds"] = {256, 256, 88, 50},
        ["OreborHarborage"] = {256, 512, 329, 25},
        ["FeralfenVillage"] = {512, 336, 314, 332},
    },
    ["BloodmystIsle"] = {
        ["RuinsofLorethAran"] = {256, 256, 556, 216},
        ["TheBloodcursedReef"] = {256, 256, 729, 54},
        ["VeridianPoint"] = {256, 256, 637, 0},
        ["TheCryoCore"] = {256, 256, 293, 285},
        ["RagefeatherRidge"] = {256, 256, 481, 117},
        ["KesselsCrossing"] = {485, 141, 517, 527},
        ["Axxarien"] = {256, 256, 297, 136},
        ["AmberwebPass"] = {256, 512, 44, 62},
        ["WyrmscarIsland"] = {256, 256, 613, 82},
        ["WrathscaleLair"] = {256, 256, 598, 338},
        ["VindicatorsRest"] = {256, 256, 232, 242},
        ["TheBloodwash"] = {256, 256, 302, 27},
        ["Middenvale"] = {256, 256, 414, 406},
        ["Nazzivian"] = {256, 256, 250, 404},
        ["TheVectorCoil"] = {512, 430, 43, 238},
        ["TheFoulPool"] = {256, 256, 221, 136},
        ["TheHiddenReef"] = {256, 256, 205, 39},
        ["BloodWatch"] = {256, 256, 437, 258},
        ["BlacksiltShore"] = {512, 242, 177, 426},
        ["TalonStand"] = {256, 256, 657, 78},
        ["TheLostFold"] = {256, 198, 503, 470},
        ["BloodscaleIsle"] = {239, 256, 763, 256},
        ["TheCrimsonReach"] = {256, 256, 555, 87},
        ["TheWarpPiston"] = {256, 256, 451, 29},
        ["Bladewood"] = {256, 256, 367, 209},
        ["TelathionsCamp"] = {128, 128, 180, 216},
        ["BristlelimbEnclave"] = {256, 256, 546, 410},
        ["Mystwood"] = {256, 185, 309, 483},
    },
    ["EversongWoods"] = {
        ["Zebwatha"] = {128, 193, 554, 475},
        ["ThuronsLivery"] = {256, 128, 539, 305},
        ["WestSanctum"] = {128, 256, 292, 319},
        ["TheGoldenStrand"] = {128, 253, 183, 415},
        ["GoldenboughPass"] = {256, 128, 243, 469},
        ["LakeElrendar"] = {128, 197, 584, 471},
        ["AzurebreezeCoast"] = {256, 256, 669, 228},
        ["StillwhisperPond"] = {256, 256, 474, 314},
        ["TranquilShore"] = {256, 256, 215, 298},
        ["EastSanctum"] = {256, 256, 460, 373},
        ["SilvermoonCity"] = {512, 512, 440, 87},
        ["SatherilsHaven"] = {256, 256, 324, 384},
        ["TorWatha"] = {256, 353, 648, 315},
        ["TheScortchedGrove"] = {256, 128, 255, 507},
        ["TheLivingWood"] = {128, 248, 511, 420},
        ["NorthSanctum"] = {256, 256, 361, 298},
        ["RunestoneShandor"] = {256, 174, 464, 494},
        ["RunestoneFalithas"] = {256, 172, 378, 496},
        ["SunsailAnchorage"] = {256, 128, 231, 404},
        ["ElrendarFalls"] = {128, 256, 580, 399},
        ["RuinsofSilvermoon"] = {256, 256, 307, 136},
        ["SunstriderIsle"] = {512, 512, 195, 5},
        ["FairbreezeVilliage"] = {256, 256, 386, 386},
        ["DuskwitherGrounds"] = {256, 256, 605, 253},
        ["FarstriderRetreat"] = {256, 128, 524, 359},
    },
    ["ShadowmoonValley"] = {
        ["LegionHold"] = {512, 512, 104, 155},
        ["NetherwingLedge"] = {492, 223, 510, 445},
        ["TheHandofGuldan"] = {512, 512, 394, 90},
        ["IlladarPoint"] = {256, 256, 143, 256},
        ["WildhammerStronghold"] = {512, 439, 168, 229},
        ["ShadowmoonVilliage"] = {512, 512, 116, 35},
        ["NetherwingCliffs"] = {256, 256, 554, 308},
        ["EclipsePoint"] = {512, 358, 343, 310},
        ["TheDeathForge"] = {256, 512, 290, 129},
        ["CoilskarPoint"] = {512, 512, 348, 8},
        ["TheWardensCage"] = {512, 410, 469, 258},
        ["TheBlackTemple"] = {396, 512, 606, 126},
        ["AltarofShatar"] = {256, 256, 520, 93},
    },
    ["TerokkarForest"] = {
        ["BonechewerRuins"] = {256, 256, 521, 275},
        ["RaastokGlade"] = {256, 256, 505, 154},
        ["SkethylMountains"] = {512, 320, 449, 348},
        ["StonebreakerHold"] = {256, 256, 397, 165},
        ["CarrionHill"] = {256, 256, 377, 272},
        ["AllerianStronghold"] = {256, 256, 480, 277},
        ["GrangolvarVilliage"] = {512, 256, 143, 171},
        ["RefugeCaravan"] = {128, 256, 316, 268},
        ["FirewingPoint"] = {385, 512, 617, 149},
        ["RazorthornShelf"] = {256, 256, 478, 19},
        ["CenarionThicket"] = {256, 256, 314, 0},
        ["RingofObservance"] = {256, 256, 310, 345},
        ["ShattrathCity"] = {512, 512, 104, 4},
        ["VeilRhaze"] = {256, 256, 222, 362},
        ["TheBarrierHills"] = {256, 256, 116, 4},
        ["SethekkTomb"] = {256, 256, 245, 289},
        ["BleedingHollowClanRuins"] = {256, 367, 103, 301},
        ["Tuurem"] = {256, 512, 455, 34},
        ["SmolderingCaravan"] = {256, 208, 321, 460},
        ["AuchenaiGrounds"] = {256, 234, 247, 434},
        ["WrithingMound"] = {256, 256, 417, 327},
    },
    ["Nagrand"] = {
        ["LaughingSkullRuins"] = {256, 256, 351, 52},
        ["ZangarRidge"] = {256, 256, 277, 54},
        ["TwilightRidge"] = {256, 512, 10, 107},
        ["Telaar"] = {256, 256, 387, 390},
        ["KilsorrowFortress"] = {256, 241, 558, 427},
        ["ForgeCampHate"] = {256, 256, 162, 154},
        ["RingofTrials"] = {256, 256, 533, 267},
        ["WindyreedVillage"] = {256, 256, 666, 233},
        ["ClanWatch"] = {256, 256, 532, 363},
        ["SouthwindCleft"] = {256, 256, 391, 258},
        ["ForgeCampFear"] = {512, 420, 36, 248},
        ["Garadar"] = {256, 256, 431, 143},
        ["WarmaulHill"] = {256, 256, 157, 32},
        ["Halaa"] = {256, 256, 335, 193},
        ["BurningBladeRUins"] = {256, 334, 660, 334},
        ["ThroneoftheElements"] = {256, 256, 504, 53},
        ["SunspringPost"] = {256, 256, 219, 199},
        ["OshuGun"] = {512, 334, 168, 334},
        ["WindyreedPass"] = {256, 256, 598, 79},
    },
    ["Sunwell"] = {
        ["SunsReachHarbor"] = {512, 416, 252, 252},
        ["SunsReachSanctum"] = {512, 512, 251, 4},
    },
    ["HowlingFjord"] = {
        ["ScalawagPoint"] = {350, 258, 168, 410},
        ["ExplorersLeagueOutpost"] = {232, 216, 585, 336},
        ["Halgrind"] = {187, 263, 397, 208},
        ["Nifflevar"] = {178, 208, 595, 240},
        ["Kamagua"] = {333, 265, 99, 278},
        ["Baleheim"] = {174, 173, 576, 170},
        ["IvaldsRuin"] = {193, 201, 668, 223},
        ["EmberClutch"] = {213, 256, 283, 203},
        ["VengeanceLanding"] = {223, 338, 664, 25},
        ["WestguardKeep"] = {347, 220, 90, 180},
        ["CampWinterHoof"] = {223, 209, 354, 0},
        ["UtgardeKeep"] = {248, 382, 477, 216},
        ["Skorn"] = {238, 232, 343, 108},
        ["NewAgamand"] = {284, 308, 415, 360},
        ["CauldrosIsle"] = {181, 178, 490, 161},
        ["TheTwistedGlade"] = {266, 210, 420, 57},
        ["SteelGate"] = {222, 168, 222, 100},
        ["Gjalerbron"] = {242, 189, 225, 0},
        ["GiantsRun"] = {298, 306, 572, 0},
        ["FortWildervar"] = {251, 192, 490, 0},
        ["ApothecaryCamp"] = {263, 265, 99, 37},
        ["BaelgunsExcavationSite"] = {244, 305, 621, 327},
        ["AncientLift"] = {177, 191, 342, 351},
    },
    ["BoreanTundra"] = {
        ["AmberLedge"] = {244, 214, 325, 140},
        ["BorGorokOutpost"] = {396, 203, 314, 0},
        ["TempleCityOfEnKilah"] = {290, 292, 712, 15},
        ["TheDensOfDying"] = {203, 209, 662, 11},
        ["Coldarra"] = {460, 381, 50, 0},
        ["TorpsFarm"] = {186, 276, 272, 237},
        ["DeathsStand"] = {289, 279, 707, 181},
        ["ValianceKeep"] = {259, 302, 457, 264},
        ["TheGeyserFields"] = {375, 342, 480, 0},
        ["SteeljawsCaravan"] = {244, 319, 397, 66},
        ["WarsongStronghold"] = {260, 278, 329, 237},
        ["Kaskala"] = {385, 316, 509, 214},
        ["RiplashStrand"] = {382, 258, 293, 383},
        ["GarroshsLanding"] = {267, 378, 153, 238},
    },
    ["Dragonblight"] = {
        ["WyrmrestTemple"] = {317, 353, 453, 219},
        ["WestwindRefugeeCamp"] = {229, 299, 42, 187},
        ["RubyDragonshrine"] = {188, 211, 374, 208},
        ["NewHearthglen"] = {214, 261, 614, 358},
        ["ScarletPoint"] = {235, 354, 569, 7},
        ["ColdwindHeights"] = {213, 219, 403, 0},
        ["ObsidianDragonshrine"] = {304, 203, 256, 104},
        ["AgmarsHammer"] = {236, 218, 258, 203},
        ["Naxxramas"] = {311, 272, 691, 160},
        ["EmeraldDragonshrine"] = {196, 218, 543, 362},
        ["LightsRest"] = {299, 278, 703, 7},
        ["TheForgottenShore"] = {301, 286, 698, 332},
        ["GalakrondsRest"] = {258, 225, 433, 118},
        ["VenomSpite"] = {226, 212, 661, 264},
        ["IcemistVillage"] = {235, 337, 134, 165},
        ["Angrathar"] = {306, 242, 210, 0},
        ["TheCrystalVice"] = {229, 259, 487, 0},
        ["LakeIndule"] = {356, 300, 217, 313},
    },
    ["GrizzlyHills"] = {
        ["GrizzleMaw"] = {294, 227, 358, 187},
        ["GraniteSprings"] = {356, 224, 7, 207},
        ["DrakilJinRuins"] = {351, 284, 607, 41},
        ["Voldrune"] = {283, 247, 176, 421},
        ["VentureBay"] = {274, 207, 18, 461},
        ["RageFangShrine"] = {475, 362, 312, 294},
        ["ThorModan"] = {329, 246, 509, 0},
        ["UrsocsDen"] = {328, 260, 331, 32},
        ["CampOneqwah"] = {324, 265, 548, 137},
        ["ConquestHold"] = {332, 294, 17, 307},
        ["DunArgol"] = {455, 400, 547, 257},
        ["BlueSkyLoggingGrounds"] = {249, 235, 232, 129},
        ["AmberpineLodge"] = {278, 290, 217, 244},
        ["DrakTheronKeep"] = {382, 285, 0, 46},
    },
    ["ZulDrak"] = {
        ["GunDrak"] = {336, 297, 629, 0},
        ["ZimTorga"] = {249, 258, 479, 241},
        ["AmphitheaterOfAnguish"] = {266, 254, 289, 287},
        ["DrakSotraFields"] = {286, 265, 326, 358},
        ["ThrymsEnd"] = {272, 268, 0, 247},
        ["AltarOfMamToth"] = {311, 317, 575, 88},
        ["AltarOfQuetzLun"] = {261, 288, 607, 251},
        ["AltarOfRhunok"] = {247, 304, 431, 127},
        ["Zeramas"] = {307, 256, 7, 412},
        ["AltarOfSseratus"] = {237, 248, 288, 168},
        ["AltarOfHarKoa"] = {265, 257, 533, 345},
        ["Voltarus"] = {218, 291, 174, 191},
        ["LightsBreach"] = {321, 305, 181, 363},
        ["Kolramas"] = {302, 231, 380, 437},
    },
    ["SholazarBasin"] = {
        ["TheStormwrightsShelf"] = {268, 288, 138, 58},
        ["TheMakersOverlook"] = {233, 286, 705, 236},
        ["TheGlimmeringPillar"] = {294, 327, 308, 34},
        ["TheMakersPerch"] = {249, 248, 172, 135},
        ["TheSavageThicket"] = {293, 229, 396, 51},
        ["RiversHeart"] = {468, 329, 359, 339},
        ["TheAvalanche"] = {322, 265, 596, 92},
        ["TheLifebloodPillar"] = {312, 369, 501, 134},
        ["RainspeakerCanopy"] = {207, 235, 427, 244},
        ["TheMosslightPillar"] = {239, 313, 265, 355},
        ["KartaksHold"] = {329, 293, 76, 375},
        ["TheSuntouchedPillar"] = {455, 316, 82, 186},
    },
    ["CrystalsongForest"] = {
        ["VioletStand"] = {264, 303, 0, 176},
        ["TheDecrepitFlow"] = {288, 222, 0, 0},
        ["TheAzureFront"] = {416, 424, 0, 244},
        ["ForlornWoods"] = {544, 668, 129, 0},
        ["TheUnboundThicket"] = {502, 477, 500, 105},
        ["TheGreatTree"] = {252, 260, 0, 91},
        ["WindrunnersOverlook"] = {558, 285, 444, 383},
        ["SunreaversCommand"] = {446, 369, 536, 40},
    },
    ["TheStormPeaks"] = {
        ["Frosthold"] = {244, 220, 134, 429},
        ["EngineoftheMakers"] = {210, 179, 316, 296},
        ["Ulduar"] = {369, 265, 218, 0},
        ["GarmsBane"] = {184, 191, 395, 470},
        ["NarvirsCradle"] = {180, 239, 214, 144},
        ["SparksocketMinefield"] = {251, 200, 242, 468},
        ["Nidavelir"] = {221, 200, 108, 206},
        ["Thunderfall"] = {306, 484, 627, 179},
        ["TerraceoftheMakers"] = {363, 341, 292, 122},
        ["DunNiffelem"] = {309, 383, 481, 285},
        ["TempleofLife"] = {182, 270, 570, 113},
        ["SnowdriftPlains"] = {205, 232, 162, 143},
        ["Valkyrion"] = {228, 158, 98, 318},
        ["BorsBreath"] = {322, 195, 109, 375},
        ["TempleofStorms"] = {169, 164, 239, 301},
        ["BrunnhildarVillage"] = {305, 298, 339, 370},
    },
    ["IcecrownGlacier"] = {
        ["TheBombardment"] = {248, 243, 538, 181},
        ["Jotunheim"] = {393, 474, 22, 122},
        ["Corprethar"] = {308, 212, 342, 392},
        ["TheBrokenFront"] = {283, 231, 558, 329},
        ["Aldurthar"] = {373, 375, 355, 37},
        ["TheFleshwerks"] = {219, 283, 218, 291},
        ["TheShadowVault"] = {223, 399, 321, 15},
        ["Valhalas"] = {238, 240, 217, 50},
        ["TheConflagration"] = {227, 210, 327, 305},
        ["ValleyofEchoes"] = {269, 217, 715, 390},
        ["Scourgeholme"] = {245, 239, 690, 267},
        ["Ymirheim"] = {223, 207, 444, 276},
        ["OnslaughtHarbor"] = {204, 268, 0, 167},
        ["SindragosasFall"] = {300, 343, 626, 31},
        ["ArgentTournamentGround"] = {314, 224, 616, 30},
        ["IcecrownCitadel"] = {308, 202, 392, 466},
    },
}


local overlayTextures = {}


local function HideOverlayTextures()
    for i = 1, #overlayTextures do
        overlayTextures[i]:Hide()
    end
end


local function GetOverlayTexture(index)
    local texture = overlayTextures[index]

    if not texture then
        texture = WorldMapDetailFrame:CreateTexture(nil, "BORDER")
        overlayTextures[index] = texture
    end

    return texture
end


local function UpdateOverlayTextures()
    if not FogClear.enabled then
        HideOverlayTextures()
        return
    end

    if not WorldMapFrame or not WorldMapFrame:IsShown() then
        return
    end

    local mapFileName = GetMapInfo()

    if not mapFileName then
        HideOverlayTextures()
        return
    end

    local mapOverlays = overlayData[mapFileName]

    if not mapOverlays then
        HideOverlayTextures()
        return
    end

    local transparency = SubSet.GetParam("fogTransparency") or 0

    if transparency < 0 then
        transparency = 0
    elseif transparency > 1 then
        transparency = 1
    end

    -- 0 = grey unexplored areas, 1 = full-colour unexplored areas.
    local tint = FOG_GREY + ((1 - FOG_GREY) * transparency)

    local pathPrefix = "Interface\\WorldMap\\" .. mapFileName .. "\\"
    local textureCount = 0

    for textureName, data in pairs(mapOverlays) do
        local width = data[1]
        local height = data[2]
        local offsetX = data[3]
        local offsetY = data[4]

        local texturesWide = math.ceil(width / TILE_SIZE)
        local texturesTall = math.ceil(height / TILE_SIZE)

        for row = 1, texturesTall do
            local pixelHeight

            if row < texturesTall then
                pixelHeight = TILE_SIZE
            else
                pixelHeight = math.fmod(height, TILE_SIZE)
                if pixelHeight == 0 then
                    pixelHeight = TILE_SIZE
                end
            end

            local fileHeight = 16
            while fileHeight < pixelHeight do
                fileHeight = fileHeight * 2
            end

            for column = 1, texturesWide do
                textureCount = textureCount + 1

                local pixelWidth

                if column < texturesWide then
                    pixelWidth = TILE_SIZE
                else
                    pixelWidth = math.fmod(width, TILE_SIZE)
                    if pixelWidth == 0 then
                        pixelWidth = TILE_SIZE
                    end
                end

                local fileWidth = 16
                while fileWidth < pixelWidth do
                    fileWidth = fileWidth * 2
                end

                local texture = GetOverlayTexture(textureCount)
                local tileNumber = ((row - 1) * texturesWide) + column

                texture:SetWidth(pixelWidth)
                texture:SetHeight(pixelHeight)
                texture:SetTexCoord(
                    0,
                    pixelWidth / fileWidth,
                    0,
                    pixelHeight / fileHeight
                )

                texture:ClearAllPoints()
                texture:SetPoint(
                    "TOPLEFT",
                    WorldMapDetailFrame,
                    "TOPLEFT",
                    offsetX + (TILE_SIZE * (column - 1)),
                    -(offsetY + (TILE_SIZE * (row - 1)))
                )

                texture:SetTexture(pathPrefix .. textureName .. tileNumber)
                texture:SetVertexColor(tint, tint, tint)
                texture:SetAlpha(1)
                texture:SetDrawLayer("BORDER")
                texture:Show()
            end
        end
    end

    for i = textureCount + 1, #overlayTextures do
        overlayTextures[i]:Hide()
    end
end


function DeFogger.UpdateFogClearSettings()
    UpdateOverlayTextures()
end


function FogClear.Enable()
    FogClear.enabled = true

    if not FogClear.hookedUpdates then
        hooksecurefunc("WorldMapFrame_Update", function()
            if FogClear.enabled then
                UpdateOverlayTextures()
            end
        end)

        FogClear.hookedUpdates = true
    end

    UpdateOverlayTextures()
end


function FogClear.Disable()
    if not FogClear.enabled then
        return
    end

    FogClear.enabled = false
    HideOverlayTextures()
end
