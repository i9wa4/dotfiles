-- wezterm-zoo.lua - Interactive animal parade for WezTerm tab bar
-- Pure Lua implementation with ecosystem simulation

local wezterm = require("wezterm")

local M = {}

-- Configuration
M.config = {
  width = 50,
  update_interval = 1000, -- ms
  min_animals = 3,
  max_animals = 15,
  animals_per_width = 20, -- 1 animal per N characters
  base_lifespan = 900, -- 15 minutes base
  dying_threshold = 60, -- start heading to exit when 60 seconds left
  child_age = 120, -- first 2 minutes = child
  teen_age = 300, -- 2-5 minutes = teen (then adult)
  mode = "zoo", -- "zoo" or "aquarium"
}

-- State file path
local STATE_FILE = "/tmp/wezterm-zoo-state.json"

-- Time-based animal/creature sets
local CREATURE_SETS = {
  zoo = {
    morning = {
      animals = { "🐓", "🐤", "🐰", "🦆" },
    },
    afternoon = {
      animals = { "🦁", "🐘", "🦒", "🦓" },
    },
    evening = {
      animals = { "🦊", "🐺", "🐻", "🦌" },
    },
    night = {
      animals = { "🦉", "🐱", "🦝", "🐀" },
    },
  },
  aquarium = {
    morning = {
      animals = { "🐠", "🐟", "🐡", "🐬" },
    },
    afternoon = {
      animals = { "🐳", "🐋", "🦈", "🦭" },
    },
    evening = {
      animals = { "🐢", "🐙", "🐧", "🦦" },
    },
    night = {
      animals = { "🦈", "🦑", "🐙", "🐡" },
    },
  },
}

-- For backward compatibility
local function get_animal_sets()
  return CREATURE_SETS[M.config.mode] or CREATURE_SETS.zoo
end

-- Personality traits
local PERSONALITIES = {
  lazy = { move_chance = 0.3, rest_chance = 0.5, social = 0.3, speed_mult = 0.7 },
  hyper = { move_chance = 0.9, rest_chance = 0.1, social = 0.7, speed_mult = 1.5 },
  friendly = { move_chance = 0.5, rest_chance = 0.2, social = 0.9, speed_mult = 1.0 },
  shy = { move_chance = 0.6, rest_chance = 0.3, social = 0.2, speed_mult = 0.9 },
  curious = { move_chance = 0.7, rest_chance = 0.2, social = 0.6, speed_mult = 1.2 },
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
  playing = "~!",
  running = ">>>",
  dying = "", -- heading to exit
}

local ACTION_NAMES = { "sleeping", "eating", "thinking" }
local CHILD_ACTION_NAMES = { "playing", "running", "eating" }
local TEEN_ACTION_NAMES = { "playing", "eating", "thinking" }

-- Age stages
local function get_age_stage(animal)
  local age = os.time() - animal.birth_time
  if age < M.config.child_age then
    return "child"
  elseif age < M.config.teen_age then
    return "teen"
  else
    return "adult"
  end
end

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

local function get_native_period(emoji)
  local animal_sets = get_animal_sets()
  for period, data in pairs(animal_sets) do
    for _, animal in ipairs(data.animals) do
      if animal == emoji then
        return period
      end
    end
  end
  return nil
end

local function random_choice(tbl)
  return tbl[math.random(#tbl)]
end

local function random_float(min, max)
  return min + math.random() * (max - min)
end

-- JSON encode/decode
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
  if not str or str == "" then
    return nil
  end
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

local function save_state(animals, width)
  local state = {
    animals = animals,
    width = width,
  }
  local file = io.open(STATE_FILE, "w")
  if file then
    file:write(json_encode(state))
    file:close()
  end
end

-- Animal creation
local function create_animal(width, existing_positions)
  local period = get_time_period()
  local animal_sets = get_animal_sets()
  local animal_set = animal_sets[period]

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

  local emoji = random_choice(animal_set.animals)
  local personality = random_choice(PERSONALITY_NAMES)
  local base_speed = random_float(0.3, 1.0)

  return {
    emoji = emoji,
    pos = pos,
    direction = math.random(2) == 1 and 1 or -1,
    speed = base_speed * PERSONALITIES[personality].speed_mult,
    personality = personality,
    birth_time = os.time(),
    lifespan = M.config.base_lifespan + random_float(-60, 60), -- 240-360 seconds
    lifespan_bonus = 0, -- accumulated bonuses
    action = "walking",
    action_until = 0,
    last_alone_check = os.time(),
    alone_duration = 0,
  }
end

-- Count nearby animals
local function count_nearby(animal, all_animals, distance)
  local count = 0
  for _, other in ipairs(all_animals) do
    if other ~= animal and math.abs(other.pos - animal.pos) < distance then
      count = count + 1
    end
  end
  return count
end

-- Find same species nearby
local function find_same_species(animal, all_animals, distance)
  for _, other in ipairs(all_animals) do
    if other ~= animal and other.emoji == animal.emoji and math.abs(other.pos - animal.pos) < distance then
      return other
    end
  end
  return nil
end

-- Update lifespan based on conditions
local function update_lifespan(animal, all_animals, width)
  local now = os.time()
  local period = get_time_period()
  local native_period = get_native_period(animal.emoji)
  local bonus = 0

  -- Time period bonus/penalty
  if native_period == period then
    bonus = bonus + 0.5 -- +0.5 sec per update when in native period
  else
    bonus = bonus - 0.3 -- -0.3 sec per update when not in native period
  end

  -- Density check
  local nearby = count_nearby(animal, all_animals, 10)
  if nearby >= 5 then
    bonus = bonus - 0.5 -- overcrowded
  elseif nearby >= 3 then
    bonus = bonus - 0.2 -- crowded
  elseif nearby == 0 then
    -- Alone penalty
    animal.alone_duration = animal.alone_duration + 1
    if animal.alone_duration > 10 then
      bonus = bonus - 0.3 -- lonely
    end
  else
    animal.alone_duration = 0 -- reset when with others
  end

  -- Action bonuses
  if animal.action == "eating" then
    bonus = bonus + 0.3
  elseif animal.action == "sleeping" then
    bonus = bonus + 0.2
  end

  -- Meeting bonus (close friend)
  local close_animals = count_nearby(animal, all_animals, 3)
  if close_animals > 0 then
    local traits = PERSONALITIES[animal.personality]
    if traits.social > 0.5 then
      bonus = bonus + 0.2 -- social animals enjoy company
    end
  end

  animal.lifespan_bonus = animal.lifespan_bonus + bonus
end

-- Check for reproduction
local function try_reproduce(animal, all_animals, width, existing_positions)
  local same = find_same_species(animal, all_animals, 3)
  if same and math.random() < 0.01 then -- 1% chance per update when close to same species
    -- Baby appears near parents
    local baby_pos = (animal.pos + same.pos) / 2 + random_float(-2, 2)
    baby_pos = math.max(2, math.min(width - 2, baby_pos))

    return {
      emoji = animal.emoji,
      pos = baby_pos,
      direction = math.random(2) == 1 and 1 or -1,
      speed = random_float(0.3, 0.8), -- babies are slower
      personality = random_choice(PERSONALITY_NAMES),
      birth_time = os.time(),
      lifespan = M.config.base_lifespan * 0.8, -- slightly shorter lifespan
      lifespan_bonus = 0,
      action = "walking",
      action_until = 0,
      last_alone_check = os.time(),
      alone_duration = 0,
    }
  end
  return nil
end

-- Animal update
local function update_animal(animal, width, all_animals)
  local now = os.time()
  local age = now - animal.birth_time
  local remaining = (animal.lifespan + animal.lifespan_bonus) - age
  local traits = PERSONALITIES[animal.personality]
  local age_stage = get_age_stage(animal)

  -- Age-based speed multiplier
  local age_speed_mult = 1.0
  if age_stage == "child" then
    age_speed_mult = 1.8 -- children are fast!
  elseif age_stage == "teen" then
    age_speed_mult = 1.3 -- teens are energetic
  else
    age_speed_mult = 0.9 -- adults are calm
  end

  -- Update lifespan based on conditions
  update_lifespan(animal, all_animals, width)

  -- Check if dying (heading to exit)
  if remaining < M.config.dying_threshold then
    animal.action = "dying"
    -- Determine nearest edge
    local left_dist = animal.pos
    local right_dist = width - animal.pos
    if left_dist < right_dist then
      animal.direction = -1 -- head left
    else
      animal.direction = 1 -- head right
    end
    -- Move slowly toward exit
    animal.pos = animal.pos + animal.direction * 0.3
    return animal
  end

  -- Check nearby animals for action decisions
  local nearby_count = count_nearby(animal, all_animals, 2)

  -- Check if doing an action
  if now < animal.action_until then
    -- Cancel action if another animal comes within 2 cells
    if nearby_count > 0 then
      animal.action = "walking"
      animal.action_until = 0
    else
      return animal
    end
  end

  -- Random chance to start an action (varies by age)
  -- Only trigger actions when no animals within 2 cells to prevent visual interference
  if nearby_count == 0 then
    local action_chance = traits.rest_chance * 0.3
    local action_list = ACTION_NAMES

    if age_stage == "child" then
      action_chance = 0.4 -- children do things more often
      action_list = CHILD_ACTION_NAMES
    elseif age_stage == "teen" then
      action_chance = 0.25
      action_list = TEEN_ACTION_NAMES
    end

    if math.random() < action_chance then
      animal.action = random_choice(action_list)
      local action_duration = math.random(2, 5)
      if age_stage == "child" then
        action_duration = math.random(1, 3) -- children have short attention span
      end
      animal.action_until = now + action_duration
      return animal
    end
  end

  animal.action = "walking"

  -- Movement (affected by age)
  local move_chance = traits.move_chance
  if age_stage == "child" then
    move_chance = 0.95 -- children almost always moving
  elseif age_stage == "teen" then
    move_chance = 0.8
  end

  if math.random() < move_chance then
    -- Direction change (children change direction more often)
    local dir_change_chance = 0.15
    if age_stage == "child" then
      dir_change_chance = 0.35 -- children are unpredictable
    end

    if math.random() < dir_change_chance then
      animal.direction = animal.direction * -1
    end

    -- Move with collision detection
    local new_pos = animal.pos + animal.direction * animal.speed * age_speed_mult
    local collision = false

    -- Check collision with other animals
    for _, other in ipairs(all_animals) do
      if other ~= animal then
        local other_pos = other.pos
        -- Check if new position would overlap (within 1.5 cells)
        if math.abs(new_pos - other_pos) < 1.5 then
          -- Only collide if moving toward the other animal
          local moving_toward = (animal.direction > 0 and other_pos > animal.pos)
            or (animal.direction < 0 and other_pos < animal.pos)
          if moving_toward then
            collision = true
            break
          end
        end
      end
    end

    if collision then
      -- Bounce back (reverse direction)
      animal.direction = animal.direction * -1
    else
      -- No collision, proceed with movement
      animal.pos = new_pos
    end

    -- Bounce off walls (with small penalty)
    if animal.pos < 1 then
      animal.pos = 1
      animal.direction = 1
      animal.lifespan_bonus = animal.lifespan_bonus - 1
    elseif animal.pos > width - 2 then
      animal.pos = width - 2
      animal.direction = -1
      animal.lifespan_bonus = animal.lifespan_bonus - 1
    end
  end

  -- Social behavior (children seek playmates)
  for _, other in ipairs(all_animals) do
    if other ~= animal then
      local dist = other.pos - animal.pos
      local other_age_stage = get_age_stage(other)

      if math.abs(dist) < 5 then
        -- Children love to play with other children
        if age_stage == "child" and other_age_stage == "child" then
          if math.random() < 0.7 then
            animal.direction = dist > 0 and 1 or -1 -- run toward!
          end
        elseif math.random() < traits.social then
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
      if a1.action ~= "dying" and a2.action ~= "dying" then
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
      if animal.action ~= "walking" and animal.action ~= "dying" then
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

  -- Load existing state
  local state = load_state()
  local animals = state.animals or {}
  local saved_width = state.width

  -- Reset if width changed
  if saved_width and saved_width ~= width then
    animals = {}
  end

  -- Remove dead animals (reached edge while dying, or exceeded lifespan + bonus)
  local alive = {}
  for _, animal in ipairs(animals) do
    local age = now - animal.birth_time
    local total_lifespan = animal.lifespan + (animal.lifespan_bonus or 0)

    if animal.action == "dying" then
      -- Only remove if reached edge
      if animal.pos > 1 and animal.pos < width - 1 then
        table.insert(alive, animal)
      end
      -- else: reached edge, don't add to alive (graceful exit)
    elseif age < total_lifespan then
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

  -- Try reproduction
  local babies = {}
  for _, animal in ipairs(animals) do
    if animal.action ~= "dying" and #animals + #babies < M.config.max_animals then
      local baby = try_reproduce(animal, animals, width, existing_positions)
      if baby then
        table.insert(babies, baby)
      end
    end
  end
  for _, baby in ipairs(babies) do
    table.insert(animals, baby)
  end

  -- Check interactions
  local interactions = check_interactions(animals)

  -- Save state with width
  save_state(animals, width)

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
