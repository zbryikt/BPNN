require! <[./BPNN]>
simp = -> it.map(format).join(" ")
format = -> 
  v = parseInt(it*100)/100
  if "#v".length == 3 => return "#{v}0"
  if "#v".length == 1 => ( if v == 1 => return "1.00" else return "0.00" )
  return "#v"
gate = -> if it >=0.5 => return 1 else 0
digitize = -> simp(it.map(gate))

generator = do
  input: -> [(if Math.random!>=0.5 => 1 else 0) for i from 0 til it]
  output: (v) -> 
    u = [v[i] for i from 0 til v.length]
    h = parseInt(v.length / 2)
    for i from 0 til h => 
      tmp = u[i]
      u[i] = u[h - i - 1]
      u[h - i - 1] = tmp
    u

bpnn = new BPNN size = 5
iter = 500000
count = 0
while count < iter
  input = generator.input size
  output = generator.output input
  bpnn.step input, output, (iter - count) / iter 
  count++

for i from 0 til 10
  input = generator.input size
  output = generator.output input
  bpnn.input input
  bpnn.iterate!
  console.log digitize(output)
  console.log digitize(bpnn.output!), bpnn.error output

  console.log " "
