require './test_data.rb'
require '../lib/simpleoutput.rb'
require '../lib/simplechartkick.rb'

#Test standalone
html = SimpleChartkick.new("test_chartkick_Standalone.html", "Data test", "../../chartkick.js/")
html.div("Hello world")
points = []
x = []
y = []
hash = {}
10.times do |index|
  points << [index, index]
  hash[index] = index
  x << index
  y << index
end
html.setXY(x, y, "XY")
html.appendXY( x, y,"XY", {"chart_type" => "ColumnChart"})
html.setPoints(points, "POINTS", {"chart_type" => "PieChart"})
html.setHash(hash, "Hash", {"chart_type" => "AreaChart"})
html.appendPoints(points)
html.appendHash( {0 => 1, 1 => 3, 3 => 7}, "XY")
html.annotate("Should be Hash")
html.annotate("Should be XY", "XY")
html.save()

html = SimpleChartkick.new("histogram.html", "histogram_test", "../../chartkick.js")
points = []
100.times do |index|
	points << [index, Random.rand]
end
html.setPoints(points, "Stats", {'histogram'=>true, 'ymin'=>0, 'ymax' => 1})
html.save()

data = TestData.new
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
html_plugin = SimpleChartkick.new("test_chartkick_Engine.html", "Output Engine", "../../chartkick.js")
output_engine.addPlugin(html_plugin)

output_engine.setXYarray(data.xy_data, "XY")
output_engine.appendXY( data.array_data, data.array_data)
output_engine.appendXYarray([data.array_data, data.array_data])

output_engine.setXY(data.array_data, data.array_data, "Magic",  {'series' => 'first'})
output_engine.appendPoints(data.points_data, "Magic", {'series' => 'second'})
output_engine.setPoints(data.points_data, "NOT MAGIC")
output_engine.appendHash(data.hash_data, "Magic", {'series' => 'third'})
output_engine.setHash(data.hash_data, "mydata", {'series' => 'back'})
output_engine.setArray(data.array_data, "Another")
output_engine.appendArray(data.array_data, "Lester", {'series' => 'magnetc'})
output_engine.save()