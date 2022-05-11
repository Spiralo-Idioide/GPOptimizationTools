// Various ways to benchmark
// TODO: Add output files 

to ezBench function timeGoal output verbose { // equivalent of easyBench. Time is in ms
  // Valid outputs are 'text', 'averageTime' and 'frequency'
  // timeGoal is in secs
  // Example: ezBench {sorted (array 9 8 7 6 5 4 3 2 1)} 5 'averageTime' true
  
  if (isClass function 'Command') { function = (function function)}
  if (isNil timeGoal) { timeGoal = 0.1 }
  if (isNil output) { output = 'text' }
  if (isNil verbose) { verbose = false }
  
  
  evalExecutions = 0.1
  timer = (newTimer)
  msecs = 0
  
  while (msecs < 20) { // evaluation of execTime
    evalExecutions = (evalExecutions * 10)
    reset timer
    repeat evalExecutions {call function}
    msecs = (msecs timer)
  }
  
  executions = (truncate (timeGoal * (evalExecutions / (msecs / 1000))))
  
  if ((msecs / 500) < timeGoal) {
    reset timer
    repeat executions {call function}
    msecs = (msecs timer)
  } else {
    executions = evalExecutions
  }
  
  
  totalTime = msecs // in ms
  averageTime = (totalTime / executions) // in ms
  frequency = (round (msToFrequency averageTime) 0.01) // in exec/sec (Hz)
  
  outputString = (join
    'Frequency :             ' (frequencyString frequency) (newline)
    'Average running time :  ' (timeString averageTime) (newline)
    'Executions :            ' (toString executions)    (newline)
    'TotalRunning time :     ' (timeString totalTime)
  )
  
  if verbose { print outputString }
  
  if (== output 'text') {
    return outputString
  } (== output 'averageTime') {
    return averageTime
  } (== output 'frequency') {
    return frequency
  }
}

to ezBenchWithArgs function timeGoal arguments {
  
  if (isClass function 'Command') { function = (function function)}
  if (isNil timeGoal) { timeGoal = 0.1 }
  
  
  evalExecutions = 0.1
  timer = (newTimer)
  msecs = 0
  
  while (msecs < 20) { // evaluation of execTime
    evalExecutions = (evalExecutions * 10)
    reset timer
    repeat evalExecutions {callWith function arguments}
    msecs = (msecs timer)
  }
  
  executions = (truncate (timeGoal * (evalExecutions / (msecs / 1000))))
  
  if ((msecs / 500) < timeGoal) {
    reset timer
    repeat executions {callWith function arguments}
    msecs = (msecs timer)
  } else {
    executions = evalExecutions
  }
  
  
  totalTime = msecs // in ms
  averageTime = (totalTime / executions) // in ms
  return averageTime
  
}

to outC function1 function2 n args... { // output Comparison
  // Check multiple times if the two command called with the same arguments have the same results
  // n: number of tests
  // args: arguments that will be passed to the functions. It is possible to 
  // have an unlimited amount of arguments. If one of the argument is a function it
  // won't be passed as an argument but its output will (usefull with random.gpm)
  // Return false if an difference is encountered
  // 
  // Example: outC (function array {sorted array}) (function array {cSorted array 1 100}) 1 (function {return (randNumArray 1000000 1 100)})
  // 
  //
  // TODO: Change the explanation comment to be easier to understand or even rewrite everything
  // to be easier to understand. Maybe writing something specific examples for randomized objects
  // instead of having to use (function) every time
  
  
  argArray = (newArray ((argCount) - 3)) // argList of argument to pass with function as objects
  for i (range 4 (argCount)) {atPut argArray (i - 3) (arg i)}
  
  repeat n {
    currentArgArray = (generateArgArray argArray) // TODO: rename currentArgArray
    output1 = (callWith function1 currentArgArray)
    output2 = (callWith function2 currentArgArray)
    
    print output1
    print output2
    print ''
    
    if (output1 != output2) {
      print ''
      print 'ERROR ! Outputs are differents !'
      print 'Arguments:' currentArgArray
      print 'output1:' output1
      print 'output2:' output2
      return false
    }
  
  gc
  }
  print 'No difference detected for' n 'comparisons'
  return true
}


to generateArgArray array {
  // Return a copy of the given array but with function items replaced by their output
  // TODO: rename!
  out = (copy array)
  
  for i (count array) {
    item = (at array i)
    if (isClass item 'Function') {
      atPut out i (call item)
    }
  }
  return out
}

// evbo (function lInt { + lInt lInt }) (function n { return (new 'lInt' (newArray n 1) false) }) (array 1 4 16 64 256 1024 4096 16384 65536 262144) 3

// evbo (function array { copyArray array}) (function n { return (newArray n)}) nil 3

// evbo (function array { superCopy array }) (function n { return (newArray n)}) nil 3


// evbo (function array { replaceArrayRange (newArray (count array) ) 1 nil array }) (function n { return (newArray n)}) nil 3


to evbo function inputFunction steps timeGoal { // evaluateBigO
  // Example: evbo (function array {sorted array}) (function size {return (randNumArray size 1 100)})
  // For function that requires a lot of memory this may not be the best option
  // TODO: Add actual bigO notation information
  if (isNil steps) { steps = (array 10 100 1000 10000 100000 1000000 10000000) }
  if (isNil timeGoal) { timeGoal = 0.5 }
  
  for step steps {
    input = (callWith inputFunction (array step))
    gc
    
    time = (ezBenchWithArgs function timeGoal (array input))
    print 'step =' step '  :  ' (timeString time)
  }
  
}

// evbov (function a {sorted a}) (function n {return (randNumArray n 1 1000)}) (array 100 1000 10000 100000 1000000) 3

to evbo2 function inputFunction steps1 steps2 nSteps1 nSteps2 { // evbo with a 2nd input
  // This one is really badly written and impossible to generalize
  // Example: evbo2 (function array max {radixCSorted array max}) (function size max {return (randNumArray size 1 max)})
  if (isNil steps1) { steps1 = (array  10001 100002 1000003) } 
  if (isNil steps2) { steps2 = (array 99 999 9999 99999 999999 9999999) }
  if (isNil timeGoal) { timeGoal = 0.5 }
  
  for step1 steps1 {
    for step2 steps2 {
      gc
      input = (callWith inputFunction (array step1 step2))
      time = (ezBenchWithArgs function timeGoal (array input step2))
      print 'step=' step1 '|' 'l=' step2 '  :  ' time 'ms'
    }
    print ''
  }
  
  
}


to msToFrequency averageTime {
  return (1000 / averageTime)
}

to timeString time {
  if (time < 0.001) {
    return (join (toString (round (time * 1000000) 0.01)) ' ns')
  } (time < 0.1) {
    return (join (toString (round (time * 1000) 0.01)) ' μs')
  } (time < 100) {
    msecs = (round time 0.01)
    return (join (toString msecs) ' ms')
  } else {
    secs = (round (time / 1000) 0.01)
    return (join (toString secs) ' s')
  }
}

to frequencyString frequency {
  if (frequency > 99999) {
    return (join (toString (round (frequency / 1000000) 0.01)) ' MHz')
  } (frequency > 999) {
    return (join (toString (round (frequency / 1000) 0.01)) ' kHz')
  } else {
    return (join (toString (round frequency 0.01)) ' Hz')
  }
}



// Default benchmarks



to globalBench repetitions { // Unfinished
  if (isNil repetitions) { repetitions = 1}
  results = (newArray 10)
  t = (newTimer)
  
  
  if false {    
    print 'Variable assignation :'
    reset t
    repeat repetitions { 
      repeat 50000000 { a = nil }
    }
    timeMs = (msecs t)
    thisRepetitions = (50000000 * repetitions)
    avgTime = (timeMs / thisRepetitions)
    frequency = (msToFrequency avgTime)
    print 'execTime  :' (timeString avgTime)
    print 'Frequency :' (frequencyString frequency)
    print ''  
  }    
  
  
  if false {
    print 'Float multiplication:'
    reset t
    repeat repetitions { 
      repeat 50000000 { * 9999999.0 9999999.0 }
    }
    timeMs = (msecs t)
    thisRepetitions = (50000000 * repetitions)
    avgTime = (timeMs / thisRepetitions)
    frequency = (msToFrequency avgTime)
    print 'execTime  :' (timeString avgTime)
    print 'Frequency :' (frequencyString frequency)
    print ''  
  }
  
  
  if true {
    print 'Integer multiplication:'
    reset t
    repeat repetitions { 
      repeat 100000000 { * 32767 32767 }
    }
    timeMs = (msecs t)
    print timeMs
    thisRepetitions = (100000000 * repetitions)
    avgTime = (timeMs / thisRepetitions)
    frequency = (msToFrequency avgTime)
    print 'execTime  :' (timeString avgTime)
    print 'Frequency :' (frequencyString frequency)
    print ''  
  }
  
  
  
}

























