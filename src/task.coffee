tasks = {}

make = ( name, task ) -> tasks[ name ] = { 
  name
  initialize: []
  before: [] 
  after: []
  dependencies: []
  actions: []
  task... 
}

lookup = ( name ) -> tasks[ name ]

list = -> ( Object.keys tasks ).sort()

export { tasks, make, lookup, list }