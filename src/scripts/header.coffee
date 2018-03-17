console.log "Header"

hello = () -> 
  one = await Promise.resolve(1)
  console.log one

hello()

var a = 20 # this is a error did not use var