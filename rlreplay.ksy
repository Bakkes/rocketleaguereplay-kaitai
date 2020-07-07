meta:
  id: rocketleague
  file-extension: replay
  endian: le
seq:
  - id: size
    type: u4
    doc: Filesize in bytes
  - id: crc
    type: u4
    doc: CRC of entire file 
  - id: engine_version
    type: u4
  - id: licensee_version
    type: u4
  - id: net_version
    type: u4
    if: 'engine_version >= 868 and licensee_version >= 18'
  - id: gametype
    type: ustring
  - id: properties
    type: propertymap
  - id: body_size
    type: u4
  - id: body_crc
    type: u4
  - id: levels
    type: stringmap
  - id: keyframes
    type: keyframemap
  - id: netstream_size
    type: u4
  - id: netstream_data
    size: netstream_size
  - id: debug_strings
    type: stringmap
  - id: replay_ticks
    type: stringintpairmap
  - id: replicated_packages
    type: stringmap
  - id: objects
    type: stringmap
  - id: names
    type: stringmap
  - id: class_indices
    type: stringintpairmap
  - id: classnet_count
    type: u4
  - id: classnets
    type: classnet
    repeat: expr
    repeat-expr: classnet_count
  - id: unknown_end
    type: s4
    if: 'net_version >= 10'
    
types:
  dummy: {}
  
  ustring:
    seq:
      - id: len
        type: s4
        doc: the length of the string. if the length is negative, it's an Unicode string
      - id: content
        type: str
        size: len < 0 ? (-(len - 1))*2 : len-1
        encoding: UTF-8
      - id: null_terminator
        size: len < 0 ? 2 : 1
    
  byte_property:
    seq:
      - id: enum_prop
        type: ustring
      - id: value
        type:
          switch-on: enum_prop.content
          cases:
            "'OnlinePlatform_Steam'": dummy
            "'OnlinePlatform_PS4'": dummy
            _: ustring
  
  bool_property:
    seq:
      - id: value
        type:
          switch-on: _root.engine_version == 0 and _root.licensee_version == 0 and _root.net_version == 0
          cases:
            true: u4
            false: u1

  
  property_value:
    seq:
      - id: property_type
        type: ustring
      - id: property_size
        type: u4
      - id: idk
        type: u4
      - id: value
        type:
          switch-on: property_type.content
          cases:
            "'None'": dummy
            '"Name"': ustring
            '"IntProperty"': s4
            '"NameProperty"': ustring
            '"StrProperty"': ustring
            '"ByteProperty"': byte_property
            '"BoolProperty"': bool_property
            '"QWordProperty"': u8
            '"FloatProperty"': f4
            '"ArrayProperty"': array_property
            _: dummy
  
  property:
    seq:
      - id: property_name
        type: ustring
      - id: property_value
        type: property_value
        if: 'property_name.content != "None"'
        
        
  array_property_elem:
    seq:
      - id: prop
        type: property
        repeat: until
        repeat-until: '_.property_name.content == "None"'
        
  array_property:
    seq:
      - id: len
        type: s4
      - id: mappp
        type: array_property_elem
        repeat: expr
        repeat-expr: len
  
  propertymap:
    seq:
      - id: mappp
        type: property
        repeat: until
        #repeat-expr: 8
        repeat-until: '_.property_name.content == "None"'
        
  stringmap:
    seq:
      - id: len
        type: u4
      - id: strings
        type: ustring
        repeat: expr
        repeat-expr: len
      
  keyframe:
    seq:
      - id: time
        type: f4
      - id: frame
        type: u4
      - id: filepos
        type: u4
        
  keyframemap:
    seq:
      - id: len
        type: u4
      - id: keyframes
        type: keyframe
        repeat: expr
        repeat-expr: len

  stringintpair:
    seq:
      - id: str
        type: ustring
      - id: int
        type: u4
  
  stringintpairmap:
    seq:
      - id: len
        type: u4
      - id: pair
        type: stringintpair
        repeat: expr
        repeat-expr: len
        
        
  prop_index:
    seq:
      - id: prop_index
        type: s4
      - id: prop_id
        type: s4
  
  classnet:
    seq:
      - id: index
        type: s4
      - id: parent
        type: s4
      - id: id
        type: s4
      - id: prop_indices_size
        type: s4
      - id: prop_indices
        type: prop_index
        repeat: expr
        repeat-expr: prop_indices_size
