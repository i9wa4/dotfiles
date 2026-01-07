-- zoo.lua - Interactive animal parade for WezTerm tab bar
-- Pure Lua implementation

local wezterm = require("wezterm")

local M = {}

-- Configuration
M.config = {
  width = 50,
  update_interval = 1000, -- ms
  min_animals = 3,
  max_animals = 15,
  animals_per_width = 20, -- 1 animal per N characters
}

-- State file path
local STATE_FILE = "/tmp/zoo_wezterm_state.json"

-- Time-based animal sets
local ANIMAL_SETS = {
  morning = { -- 5-11
    animals = { "🐓", "🐦", "🐤", "🦆", "🐰", "🦔", "🐿️", "🐝" },
  },
  afternoon = { -- 12-17
    animals = { "🦁", "🐘", "🦒", "🦓", "🐆", "🦏", "🐃", "🦬" },
  },
  evening = { -- 18-21
    animals = { "🦊", "🐺", "🦌", "🐻", "🦡", "🐗", "🦫", "🦦" },
  },
  night = { -- 22-4
    animals = { "🦉", "🦇", "🐱", "🦝", "🐀", "🦨", "🐸", "🦎" },
  },
}

-- Personality traits
local PERSONALITIES = {
  lazy = { move_chance = 0.3, rest_chance = 0.5, social = 0.3 },
  hyper = { move_chance = 0.9, rest_chance = 0.1, social = 0.7 },
  friendly = { move_chance = 0.5, rest_chance = 0.2, social = 0.9 },
  shy = { move_chance = 0.6, rest_chance = 0.3, social = 0.2 },
  curious = { move_chance = 0.7, rest_chance = 0.2, social = 0.6 },
}

local PERSONALITY_NAMES = { "lazy", "hyper", "friendly", "shy", "curious" }

-- Greetings based on social level
local GREETINGS = {
  strangers = { "?", "...", "~" },
  acquaintances = { "!", "~", "o" },
  friends = { "<3", "!!", "***" },
}

-- Actions
local ACTIONS = {
  walking = "",
  sleeping = "zzZ",
  eating = "nom",
  thinking = "...",
}

local ACTION_NAMES = { "sleeping", "eating", "thinking" }

-- Helper functions
local function get_time_period()
  local hour = tonumber(os.date("%H"))
  if hour >= 5 and hour < 12 then
    return "morning"
  elseif hour >= 12 and hour < 18 then
    return "afternoon"
  elseif hour >= 18 and hour < 22 then
    return "evening"
  else
    return "night"
  end
end

local function random_choice(tbl)
  return tbl[math.random(#tbl)]
end

local function random_float(min, max)
  return min + math.random() * (max - min)
end

-- JSON encode/decode (simple implementation)
local function json_encode(obj)
  if type(obj) == "table" then
    local is_array = #obj > 0
    local parts = {}
    if is_array then
      for _, v in ipairs(obj) do
        table.insert(parts, json_encode(v))
      end
      return "[" .. table.concat(parts, ",") .. "]"
    else
      for k, v in pairs(obj) do
        table.insert(parts, string.format('"%s":%s', k, json_encode(v)))
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
  elseif type(obj) == "string" then
    return string.format('"%s"', obj)
  elseif type(obj) == "number" then
    return tostring(obj)
  elseif type(obj) == "boolean" then
    return obj and "true" or "false"
  else
    return "null"
  end
end

local function json_decode(str)
  -- Simple JSON parser for our specific format
  if not str or str == "" then
    return nil
  end
  -- Use wezterm's json parsing if available
  local ok, result = pcall(function()
    return wezterm.json_parse(str)
  end)
  if ok then
    return result
  end
  return nil
end

-- State management
local function load_state()
  local file = io.open(STATE_FILE, "r")
  if not file then
    return {}
  end
  local content = file:read("*a")
  file:close()
  return json_decode(content) or {}
end

local function save_state(animals)
  local file = io.open(STATE_FILE, "w")
  if file then
    file:write(json_encode(animals))
    file:close()
  end
end

-- Animal creation
local function create_animal(width, existing_positions)
  local period = get_time_period()
  local animal_set = ANIMAL_SETS[period]

  -- Find position not too close to others
  local pos
  for _ = 1, 10 do
    pos = random_float(2, width - 2)
    local ok = true
    for _, p in ipairs(existing_positions) do
      if math.abs(pos - p) < 3 then
        ok = false
        break
      end
    end
    if ok then
      break
    end
  end

  return {
    emoji = random_choice(animal_set.animals),
    pos = pos,
    direction = math.random(2) == 1 and 1 or -1,
    speed = random_float(0.3, 1.5),
    personality = random_choice(PERSONALITY_NAMES),
    birth_time = os.time(),
    lifespan = random_float(15, 45),
    action = "walking",
    action_until = 0,
  }
end

-- Animal update
local function update_animal(animal, width, all_animals)
  local now = os.time()
  local traits = PERSONALITIES[animal.personality]

  -- Check if doing an action
  if now < animal.action_until then
    return animal
  end

  -- Random chance to start an action
  if math.random() < traits.rest_chance * 0.3 then
    animal.action = random_choice(ACTION_NAMES)
    animal.action_until = now + math.random(2, 5)
    return animal
  end

  animal.action = "walking"

  -- Movement
  if math.random() < traits.move_chance then
    -- Occasionally change direction
    if math.random() < 0.15 then
      animal.direction = animal.direction * -1
    end

    -- Move
    animal.pos = animal.pos + animal.direction * animal.speed

    -- Bounce off walls
    if animal.pos < 1 then
      animal.pos = 1
      animal.direction = 1
    elseif animal.pos > width - 2 then
      animal.pos = width - 2
      animal.direction = -1
    end
  end

  -- Social behavior
  for _, other in ipairs(all_animals) do
    if other ~= animal then
      local dist = other.pos - animal.pos
      if math.abs(dist) < 5 then
        if math.random() < traits.social then
          animal.direction = dist > 0 and 1 or -1
        elseif animal.personality == "shy" then
          animal.direction = dist > 0 and -1 or 1
        end
      end
    end
  end

  return animal
end

-- Check interactions
local function check_interactions(animals)
  local interactions = {}

  for i = 1, #animals do
    for j = i + 1, #animals do
      local a1, a2 = animals[i], animals[j]
      local dist = math.abs(a1.pos - a2.pos)

      if dist < 2 then
        local social_avg = (PERSONALITIES[a1.personality].social + PERSONALITIES[a2.personality].social) / 2

        local greet_type
        if social_avg > 0.6 then
          greet_type = "friends"
        elseif social_avg > 0.3 then
          greet_type = "acquaintances"
        else
          greet_type = "strangers"
        end

        local greeting = random_choice(GREETINGS[greet_type])
        local pos = (a1.pos + a2.pos) / 2
        table.insert(interactions, { pos = pos, greeting = greeting })
      end
    end
  end

  return interactions
end

-- Render
local function render(animals, interactions, width)
  local field = {}
  for i = 1, width do
    field[i] = " "
  end

  -- Place interactions first
  for _, interaction in ipairs(interactions) do
    local p = math.floor(interaction.pos)
    if p >= 1 and p <= width - #interaction.greeting then
      for i = 1, #interaction.greeting do
        field[p + i - 1] = interaction.greeting:sub(i, i)
      end
    end
  end

  -- Sort animals by position
  table.sort(animals, function(a, b)
    return a.pos < b.pos
  end)

  -- Place animals
  for _, animal in ipairs(animals) do
    local p = math.floor(animal.pos)
    if p >= 1 and p <= width then
      field[p] = animal.emoji

      -- Show action if not walking
      if animal.action ~= "walking" then
        local action_str = ACTIONS[animal.action]
        for i = 1, #action_str do
          if p + i <= width then
            field[p + i] = action_str:sub(i, i)
          end
        end
      end
    end
  end

  return table.concat(field)
end

-- Main update function
function M.get_zoo_display(width)
  width = width or M.config.width
  local now = os.time()

  -- Seed random
  math.randomseed(now)

  -- Load existing animals
  local animals = load_state()

  -- Remove dead animals
  local alive = {}
  for _, animal in ipairs(animals) do
    if now - animal.birth_time < animal.lifespan then
      table.insert(alive, animal)
    end
  end
  animals = alive

  -- Ensure we have enough animals (scales with width)
  local target_count =
    math.max(M.config.min_animals, math.min(math.floor(width / M.config.animals_per_width), M.config.max_animals))
  local existing_positions = {}
  for _, a in ipairs(animals) do
    table.insert(existing_positions, a.pos)
  end

  while #animals < target_count do
    local new_animal = create_animal(width, existing_positions)
    table.insert(animals, new_animal)
    table.insert(existing_positions, new_animal.pos)
  end

  -- Update each animal
  for _, animal in ipairs(animals) do
    update_animal(animal, width, animals)
  end

  -- Check interactions
  local interactions = check_interactions(animals)

  -- Save state
  save_state(animals)

  -- Render
  return render(animals, interactions, width)
end

-- Apply to WezTerm config
function M.apply_to_config(config)
  wezterm.on("update-status", function(window, pane)
    local width = M.config.width
    local zoo_display = M.get_zoo_display(width)

    window:set_left_status(wezterm.format({
      { Text = zoo_display },
    }))
  end)
end

return M
