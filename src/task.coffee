tasks = {}

make = ( name, task ) -> tasks[ name ] = { 
  name
  before: [] 
  after: []
  dependencies: []
  actions: []
  task... 
}

lookup = ( name ) -> tasks[ name ]

list = -> ( Object.keys tasks ).sort()

export { tasks, make, lookup, list }