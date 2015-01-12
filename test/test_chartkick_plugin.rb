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
html.set_xy(x, y, "XY")
html.append_xy( x, y,"XY", {"chart_type" => "ColumnChart"})
html.set_points(points, "POINTS", {"chart_type" => "PieChart"})
html.set_hash(hash, "Hash", {"chart_type" => "AreaChart"})
html.append_points(points)
html.append_hash( {0 => 1, 1 => 3, 3 => 7}, "XY")
html.annotate("Should be Hash")
html.annotate("Should be XY", "XY")
html.save()

html = SimpleChartkick.new("histogram.html", "histogram_test", "../../chartkick.js")
points = []
100.times do |index|
	points << [index, Random.rand]
end
html.set_points(points, "Stats", {'histogram'=>true, 'ymin'=>0, 'ymax' => 1})
html.save()

data = TestData.new
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
html_plugin = SimpleChartkick.new("test_chartkick_Engine.html", "Output Engine", "../../chartkick.js")
output_engine.add_plugin(html_plugin)

output_engine.set_xy_array(data.xy_data, "XY")
output_engine.append_xy( data.array_data, data.array_data)
output_engine.append_xy_array([data.array_data, data.array_data])

output_engine.set_xy(data.array_data, data.array_data, "Magic",  {'series' => 'first'})
output_engine.append_points(data.points_data, "Magic", {'series' => 'second'})
output_engine.set_points(data.points_data, "NOT MAGIC")
output_engine.append_hash(data.hash_data, "Magic", {'series' => 'third'})
output_engine.set_hash(data.hash_data, "mydata", {'series' => 'back'})
output_engine.set_array(data.array_data, "Another")
output_engine.append_array(data.array_data, "Lester", {'series' => 'magnetc'})
output_engine.save()