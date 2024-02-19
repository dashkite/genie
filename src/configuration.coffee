configuration = {}

get = ( key ) -> configuration[ key ]

set = ( key, value ) -> configuration[ key ] = value

read = -> configuration

write = ( value ) -> configuration = value

export { get, set, read, write }