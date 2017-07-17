-- Initializing the error class.
local Validator = class()

----------------------
-- Instance methods --
----------------------

-- Constructor. Sets up instance properties.
function Validator:constructor()
  self._customRules = {}
end

-- TODO
function Validator:addCustomRule(...)
  -- Setting proper names for each argument
  local name, callback = ...

  -- Adding the rule to the custom rules table.
  table.insert(self._customRules, {
    name = name,
    callback = callback
  })
end

-- TODO
function Validator:validate(...)
  -- Setting proper names for each argument
  local rules, funcName, level = ...

  -- Table which holds info about a potential error
  local potentialError = { error = false }

  -- Validating all the arguments according to the passed rules.
  for key, rule in pairs(rules) do
    if type(rule.type) == 'string' and
        (rule.type == 'nil' or rule.type == 'boolean'
        or rule.type == 'number' or rule.type == 'string'
        or rule.type == 'function' or rule.type == 'userdata'
        or rule.type == 'thread' or rule.type == 'table') then
      if type(rule.value) ~= rule.type
          and not (type(rule.value) == 'nil' and rule.optional) then
        potentialError = {
          error = true,
          number = key,
          message = rule.type .. ' expected, got ' .. type(rule.value)
        }

        break
      end

      if rule.type == 'string' and type(rule.regex) == 'string'
          and not (type(rule.value) == 'nil' and rule.optional) then
        if string.find(rule.value, rule.regex) == nil then
          potentialError = {
            error = true,
            number = key,
            message = rule.regexInfo or 'regex mismatch: ' .. rule.regex
          }

          break
        end
      end
    elseif type(rule.type) == 'table' and rule.type.__IS_CLASS then
      if getmetatable(rule.value) ~= rule.type
          and not (type(rule.value) == 'nil' and rule.optional) then
        potentialError = {
          error = true,
          number = key,
          message = 'instance of "' .. rule.type.__CLASS_PATH .. '" expected'
        }

        break
      end
    else
      for _, customRule in pairs(self._customRules) do
        if rule.type == customRule.name then
          local hasError, message = customRule.callback(rule)
          if hasError then
            potentialError = {
              error = true,
              number = key,
              message = message
            }
          end

          break
        end
      end

      if potentialError.error then break end
    end
  end

  if (potentialError.error) then
    local pe = potentialError
    error('Invalid argument #' .. pe.number .. ' at "' .. funcName .. '" '
        .. '(' .. pe.message .. ')', level + 1)
  end
end

-------------------------
-- Returning the class --
-------------------------
return Validator
