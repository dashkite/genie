import { performance as Performance } from "node:perf_hooks"

Benchmark =
  
  start: ( name ) -> Performance.mark "#{ name }-start"

  finish: ( name ) -> Performance.mark "#{ name }-finish"
  
  duration: ( name ) ->
    { duration } = Performance.measure name, 
      "#{ name }-start", 
      "#{ name }-finish"
    duration

export {
  Benchmark
}