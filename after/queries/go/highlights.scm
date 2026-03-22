; Give @type.definition higher priority so it wins over @type
(type_spec
  name: (type_identifier) @type.definition (#set! priority 101))
