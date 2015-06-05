BPNN = ((layerCount, size) ->
  if layerCount< 3 => layerCount = 3
  @layerCount = layerCount
  @lmax
  @size = size
  @v = [[0 for j from 0 til size] for i from 0 til layerCount]
  @w = [[[0 for k from 0 til size] for j from 0 til size] for i from 0 til layerCount - 1]
  @lo = [[0 for j from 0 til size] for i from 0 til layerCount - 1]
  @randomize!
  @
) <<< prototype: do
  sigmoid: (x) -> 1 / ( 1 + Math.E **(-x))
  randomize: -> 
    for layer from 0 til @layerCount - 1 => for i from 0 til @size => for j from 0 til @size
      @w[layer][i][j] = Math.random! * 2 - 1
  input: (u) -> for i from 0 til @size => @v[0][i] = u[i]
  output: -> for i from 0 til @size => @v[@layerCount - 1][i]
  iterate: ->
    for layer from 0 til @layerCount - 1 =>
      for j from 0 til @size =>
        @v[layer + 1][j] = 0
        for i from 0 til @size =>
          @v[layer + 1][j] += @v[layer][i] * @w[layer][i][j]
        @v[layer + 1][j] = @sigmoid(@v[layer + 1][j])
  error: (u) -> [Math.abs(@v[@layerCount - 1][i] - u[i]) for i from 0 til @size].reduce(((a,b)->a+b),0)
  bp: (u, ln = 0.5) -> 
    lm = @layerCount - 2
    for i from 0 til @size
      @lo[lm][i] = (u[i] - @v[lm + 1][i]) * @v[lm + 1][i] * ( 1 - @v[lm + 1][i] )
    # this is only correct when layer = 3
    for layer from @layerCount - 3 to 0 by -1
      for i from 0 til @size
        @lo[layer][i] = (
          @v[layer + 1][i] * ( 1 - @v[layer + 1][i]) * 
          ([(@lo[layer + 1][j] * @w[layer][i][j]) for j from 0 til @size].reduce(((a,b)->a+b),0))
        )

    for layer from 0 til @layerCount - 1
      for i from 0 til @size => for j from 0 til @size
        @w[layer][i][j] += ln * @lo[layer][j] * @v[layer][i]

  step: (input, output, ln) ->
    @input input
    @iterate!
    @bp output, ln

module.exports = BPNN
