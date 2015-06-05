BPNN = ((size) ->
  @size = size
  @v = [[0 for j from 0 til size] for i from 0 til 3]
  @w = [[[0 for k from 0 til size] for j from 0 til size] for i from 0 til 2]
  @randomize!
  @
) <<< prototype: do
  sigmoid: (x) -> 1 / ( 1 + Math.E **(-x))
  randomize: -> 
    for i from 0 til 2 => for j from 0 til @size => for k from 0 til @size
      @w[i][j][k] = Math.random! * 2 - 1
  input: (u) -> for i from 0 til @size => @v[0][i] = u[i]
  output: -> for i from 0 til @size => @v[2][i]
  iterate: ->
    for i from 0 til 2 =>
      for j from 0 til @size =>
        @v[i + 1][j] = 0
        for k from 0 til @size =>
          @v[i + 1][j] += @v[i][k] * @w[i][k][j]
        @v[i + 1][j] = @sigmoid(@v[i + 1][j])
  error: (u) -> [Math.abs(@v[2][i] - u[i]) for i from 0 til @size].reduce(((a,b)->a+b),0)
  bp: (u, ln = 0.5) -> 
    lo2 = [(u[i] - @v[2][i]) * @v[2][i] * ( 1 - @v[2][i] ) for i from 0 til @size]
    lo1 = [[lo2[i] * @w[1][j][i] for i from 0 til @size]reduce(((a,b)->a+b),0) * @v[1][j] * ( 1 - @v[1][j] ) for j from 0 til @size]
    for i from 0 til @size => for j from 0 til @size =>
      @w[0][i][j] += ln * lo1[j] * @v[0][i]
      @w[1][i][j] += ln * lo2[j] * @v[1][i]
  step: (input, output, ln) ->
    @input input
    @iterate!
    @bp output, ln

module.exports = BPNN
