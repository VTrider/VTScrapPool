--[[
=======================================
*   VT's Scrap Pool
*   
*   Holographic Effects Module
*
*	Required Event Handlers:
*	- Update(dt)
=======================================
--]]

local math3d = require("vsp_math3d")
local object = require("vsp_object")
local set = require("vsp_set")
local utility = require("vsp_utility")

local exu = require("exu")

local vsp_holographic = {}
do
    --- Abstract hologram base class
    --- @class basic_hologram : object
    --- @field position userdata vector
    --- @field color string
    local basic_hologram = object.make_class("basic_hologram")

    local drawable_list = set.make_set()
	drawable_list:make_weak()

	function basic_hologram:basic_hologram(position, color)
		self.position = position
        self.color = string.upper((color or "G"))

        drawable_list:insert(self)

        basic_hologram.class_initialized = true
	end

	--- @nodiscard
    --- @param position userdata vector
    --- @param color? string
    --- @return basic_hologram
    function vsp_holographic.make_basic_hologram(position, color)
        return basic_hologram:new(position, color)
    end

    --- @return self
    function basic_hologram:enable()
        drawable_list:insert(self)
        return self
    end

    --- @return self
    function basic_hologram:disable()
        drawable_list:remove(self)
        return self
    end

    function basic_hologram:draw()
        self:abstract("draw")
    end

    local function draw_all_holograms(dt)
        for hologram in drawable_list:iterator() do
            hologram:draw()
        end
    end

    --- @class holotext : basic_hologram, object
	--- @field text string text to draw
	--- @field position userdata vector
	--- @field color string 'R' 'G' or 'Y'
    local holotext = object.make_class("holotext", basic_hologram)

	holotext.default_tracking = 1.5
	holotext.default_leading = 2.5
	holotext.whitespace = ' '
	holotext.newline = '\n'

	function holotext:holotext(position, text)
		self:super(position)

		self.text = text

        self.tracking = holotext.default_tracking
        self.leading = holotext.default_leading
	end

	--- Creates a directional holo text object, the holo text will persist as long as
	--- the returned result is stored, or until it's disabled
	--- @nodiscard
	--- @param position any vector
	--- @param text string text to draw
	--- @return holotext
    function vsp_holographic.make_holotext(position, text)
        return holotext:new(util.get_any_position(position), text)
    end

	--- @nodiscard
	--- @return any direction vector
	function holotext:get_facing_direction()
		return Normalize(math3d.get_posit(exu.GetCameraTransformMatrix()) - self.position)
	end

	--- Completes one render of the holotext (will disappear after the lifespan defined in the odf)
    function holotext:draw()
        local draw_pos = self.position
        local x_offset = CrossProduct(self:get_facing_direction(), SetVector(0, 1, 0)) * self.tracking -- draw to the right relative to facing direction
        local y_offset = SetVector(0, -self.leading, 0)
        for i = 1, self.text:len() do
            local char = self.text:sub(i, i) -- extract a char

			if char == holotext.whitespace then
				draw_pos = draw_pos + x_offset
			elseif char == holotext.newline then
				draw_pos = self.position + y_offset
			else
				local xpl_odf
				if holotext.char_table[char] then
					xpl_odf = holotext.char_table[char] .. self.color
				else
					xpl_odf = holotext.char_table['?'] .. self.color -- can't find character from char table
				end
				
				MakeExplosion(xpl_odf, draw_pos)
	
				draw_pos = draw_pos + x_offset
			end
        end
    end

	--- Letter to explosion odf map
    holotext.char_table = {
		A = "txt0000",
		B = "txt0001",
		C = "txt0002",
		D = "txt0003",
		E = "txt0004",
		F = "txt0005",
		G = "txt0006",
		H = "txt0007",
		I = "txt0008",
		J = "txt0009",
		K = "txt0010",
		L = "txt0011",
		M = "txt0012",
		N = "txt0013",
		O = "txt0014",
		P = "txt0015",
		Q = "txt0016",
		R = "txt0017",
		S = "txt0018",
		T = "txt0019",
		U = "txt0020",
		V = "txt0021",
		W = "txt0022",
		X = "txt0023",
		Y = "txt0024",
		Z = "txt0025",
		a = "txt0026",
		b = "txt0027",
		c = "txt0028",
		d = "txt0029",
		e = "txt0030",
		f = "txt0031",
		g = "txt0032",
		h = "txt0033",
		i = "txt0034",
		j = "txt0035",
		k = "txt0036",
		l = "txt0037",
		m = "txt0038",
		n = "txt0039",
		o = "txt0040",
		p = "txt0041",
		q = "txt0042",
		r = "txt0043",
		s = "txt0044",
		t = "txt0045",
		u = "txt0046",
		v = "txt0047",
		w = "txt0048",
		x = "txt0049",
		y = "txt0050",
		z = "txt0051",
		['0'] = "txt0052",
		['1'] = "txt0053",
		['2'] = "txt0054",
		['3'] = "txt0055",
		['4'] = "txt0056",
		['5'] = "txt0057",
		['6'] = "txt0058",
		['7'] = "txt0059",
		['8'] = "txt0060",
		['9'] = "txt0061",
		['-'] = "txt0062",
		['+'] = "txt0063",
		['='] = "txt0064",
		['/'] = "txt0065",
		['\\'] = "txt0066",
		['?'] = "txt0067",
		['!'] = "txt0068",
		['\''] = "txt0069",
		['\"'] = "txt0070",
		[','] = "txt0071",
		['.'] = "txt0089",
		['('] = "txt0082",
		[')'] = "txt0083",
		['['] = "txt0084",
		[']'] = "txt0085",
		[':'] = "txt0072",
		['<'] = "txt0074",
		['>'] = "txt0075",
		['@'] = "txt0076",
		['#'] = "txt0077",
		['$'] = "txt0078",
		['%'] = "txt0079",
		['&'] = "txt0080",
		['*'] = "txt0081",
		['{'] = "txt0086",
		['}'] = "txt0087",
		[';'] = "txt0073",
		['`'] = "txt0088"
	}


	local HoloCharsSymbol = {
		{"G", "txt0100"}, -- Red Box
		{"Y", "txt0101"}, -- Green Box
		{"R", "txt0102"}, -- Yellow Box
		{"A", "txt0103"}, -- Yellow Selector Arrow Pointing Right
		{"!", "txt0104"}, -- Faction: NSDF
		{"@", "txt0105"}, -- Faction: CCA
		{"#", "txt0106"}, -- Faction: BDOG
		{"$", "txt0107"}, -- Faction: CRA
	}

    function vsp_holographic.Update(dt)
        draw_all_holograms(dt)
    end
end
return vsp_holographic