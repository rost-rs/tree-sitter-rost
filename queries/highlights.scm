; Directives (@theme, @version, @author, @rule)
"@" @keyword.directive
(directive
  name: (identifier) @keyword.directive)

; Section headers & Selectors (#button.primary, #card)
"#" @punctuation.special
"##" @punctuation.special

(block
  selector: (selector) @type.definition)

(block
  name: (identifier) @type.definition)

(section
  name: (selector) @type.definition)

(subsection
  name: (identifier) @type)

; Properties (width:, bg:, padding:)
(property
  key: (identifier) @property)

; Primitive and Compound Values
(string) @string
(dimension) @number
(hex_color) @constant.builtin
(boolean) @boolean
(number) @number

; Enums & State sets (| idle, hover, active |)
"|" @punctuation.bracket
(enum_definition
  key: (identifier) @type.enum)

(enum_variant
  (identifier) @variable.parameter)

; Arrays & Lists ([ 8px, 16px ])
"[" @punctuation.bracket
"]" @punctuation.bracket
(list_definition
  key: (identifier) @variable)

; Expression & Functional Event Bindings (on_click = emit_event())
"=" @operator
(binding
  key: (identifier) @function.method
  expression: (expression) @function.call)

; Comments & Structural Delimiters
(comment) @comment
":" @punctuation.delimiter
"," @punctuation.delimiter
";" @punctuation.delimiter
"{" @punctuation.bracket
"}" @punctuation.bracket
(escape_sequence) @string.escape
