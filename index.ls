budgetCtrl = ($scope) ->
  radius = 900
  color = d3.scale.category20c!
  color = d3.scale.ordinal!range <[#F6B4FF #AA8BE8 #86A0FF #A6D7E8 #C0FFEC]>
  $scope <<< do
    inst: ""
    name: ""
    query: ""
    update: ->
      d3.select \#svg .selectAll 'g.inst circle.inst'
        .attr \fill ->
          # if $scope.query and it.name and it.name.indexOf($scope.query)>=0 => return \#f00
          if it.inst => color it.inst else \none
        .transition!
        .duration 750
        .attr \r ->
          if $scope.query and it.name and it.name.indexOf($scope.query)>=0 and $scope.query != '' => return 100
          if $scope.query != '' => return 10
          return it.r
        .style \opacity ->
          if $scope.query and it.name and it.name.indexOf($scope.query)>=0 and $scope.query != '' => return 1
          if $scope.query != '' => return 0.5
          return 1
        .transition!
        .duration 1000
        .attr \transform ->
          if $scope.query and it.name and it.name.indexOf($scope.query)>=0 and $scope.query != '' => return "translate(#{0} #{0})"
          if $scope.query != '' => return "translate(#{400} #{800 - it.y})"
          return "translate(#{0} #{0})"

      d3.select \#svg .selectAll 'text'
        .text ->
          if $scope.query and it.name and it.name.indexOf($scope.query)>=0 and $scope.query != '' => return it.name
          if $scope.query != '' => return ""
          if it.r>15 => it.name else ""
        .style \opacity ->
          if $scope.query and it.name and it.name.indexOf($scope.query)>=0 and $scope.query != '' => return 1
          if $scope.query != '' => return 0
          return 1
        .style \font-size ->
          if $scope.query and it.name and it.name.indexOf($scope.query)>=0 and $scope.query != '' => return 20
          return 10
 
          


  $scope.$watch 'query', ->
    console.log $scope.query
    $scope.update!
  data <- d3.json \budget.json
  bubble = d3.layout.pack!sort null .size [radius,radius] .padding 1.5
  svg = d3.select \#svg
  root = {children: []}
  inst-hash = {}
  circle-hash = {}
  root =
    children: for key of data => do
      name: key
      inst: key
      value: Math.sqrt(data[key]0)
      c: for dept of data[key]1 => {name: dept, inst: key, value: Math.sqrt(data[key]1[dept]>?1)}

  svg.selectAll \g.inst .data bubble.nodes(root)
    ..enter!
      ..append \g .attr \class \inst
        ..attr \transform -> "translate(#{it.x} #{it.y})"
        ..append \circle .attr \class \inst
          .attr \r -> it.r
          .attr \fill -> if it.inst => color it.inst else \none
          .call -> circle-hash[it.name] = @
          .each (d) ->
            parent = (d3.select @)[0][0].parentElement # g element
            d3.select parent .on \click (e) ~>
              if @.r.baseVal.value < 100
                $scope.query = d.name
                $scope.update!
              else
                $scope.query = ''
                $scope.update!
              d3.select parent .selectAll \g.dept .style \opacity 0
            d3.select parent .on \mouseover (e) ~>
              cur_r = @.r.baseVal.value
              $scope.$apply (e)-> $scope.inst = d.inst
              #if d.r < 20 =>
              #  $scope.$apply (e) -> $scope.name = ""
              #  return
              bubble = d3.layout.pack!sort null .size [2 * cur_r, 2 * cur_r] .padding 1.5

              if d.c.length > 0

                  d3.select parent .selectAll \g.dept .data bubble.nodes({children: d.c})
                    ..enter!append \g .attr \class \dept
                      ..append \circle
                        .attr \r -> it.r
                        .attr \fill -> if it.name => color it.name else \none
                        .on \mouseover (it) -> $scope.$apply (e)-> $scope.name = it.name

                  d3.select parent .selectAll \g.dept .data bubble.nodes({children: d.c})
                    .selectAll \circle
                    .attr \r -> it.r
                    .attr \transform ->
                        "translate(#{it.x - cur_r} #{it.y - cur_r})"

              d3.select parent .selectAll \g.dept .style \opacity 1
            # if d.r < 20 => return
            d3.select parent .on \mouseout (e) ~>
              d3.select parent .selectAll \g.dept .style \opacity 0
      ..append \g .attr \class \inst-text
        ..attr \transform -> "translate(#{it.x} #{it.y})"
        ..append \text .attr \class \name
          .text -> if it.r>15 => it.name else ""
          .style \font-size -> 10
