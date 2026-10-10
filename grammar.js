module.exports = grammar({
  name: 'rost',

  extras: $ => [
    /\s/,
    $.comment,
  ],

  rules: {
    source_file: $ => repeat($._item),

    _item: $ => choice(
      $.directive,
      $.block,
      $.section,
      $.subsection,
      $.property,
      $.enum_definition,
      $.list_definition,
      $.binding,
      ',',
      ';',
    ),

    comment: $ => token(seq('//', /.*/)),

    directive: $ => seq(
      '@',
      field('name', $.identifier),
      optional(field('value', choice($.string, $.number))),
      optional(field('body', $.block_body)),
    ),

    section: $ => seq(
      '#',
      field('name', $.selector),
    ),

    subsection: $ => seq(
      '##',
      field('name', $.identifier),
      optional(choice(
        field('value', $.string),
        seq(':', field('value', choice($.string, $.identifier))),
      )),
    ),

    block: $ => seq(
      choice(
        seq('#', field('selector', $.selector)),
        field('name', $.identifier),
      ),
      field('body', $.block_body),
    ),

    block_body: $ => seq(
      '{',
      repeat($._item),
      '}',
    ),

    selector: $ => token(
      /[a-zA-Z_][a-zA-Z0-9_\-\.]*/
    ),

    property: $ => seq(
      field('key', $.identifier),
      ':',
      field('value', $._value),
    ),

    enum_definition: $ => seq(
      field('key', $.identifier),
      '|',
      optional(seq(
        $.enum_variant,
        repeat(seq(',', $.enum_variant)),
        optional(','),
      )),
      '|',
    ),

    enum_variant: $ => choice(
      $.identifier,
      seq(field('name', $.identifier), ':', field('value', $._value)),
    ),

    list_definition: $ => seq(
      field('key', $.identifier),
      '[',
      optional(seq(
        $._value,
        repeat(seq(',', $._value)),
        optional(','),
      )),
      ']',
    ),

    binding: $ => seq(
      field('key', $.identifier),
      '=',
      field('expression', $.expression),
    ),

    expression: $ => token(
      /[^\n,;}]+/
    ),

    _value: $ => choice(
      $.string,
      $.dimension,
      $.hex_color,
      $.boolean,
      $.number,
      $.identifier,
    ),

    dimension: $ => token(
      seq(
        /-?[0-9]+(\.[0-9]+)?/,
        choice('px', 'rem', 'em', '%', 'vh', 'vw', 'pt', 'ms', 's', 'deg'),
      )
    ),

    hex_color: $ => token(
      choice(
        /#[0-9a-fA-F]{3,8}/,
        /0x[0-9a-fA-F]+/,
      )
    ),

    boolean: $ => choice('true', 'false'),

    number: $ => token(
      /-?[0-9]+(\.[0-9]+)?/
    ),

    string: $ => seq(
      '"',
      repeat(choice(
        token.immediate(/[^"\\]+/),
        $.escape_sequence,
      )),
      '"',
    ),

    escape_sequence: $ => token.immediate(
      seq('\\', /./)
    ),

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_-]*/,
  },
});
