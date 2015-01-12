require './test_data.rb'
require '../lib/simpleoutput.rb'
require '../lib/simplelog.rb'

#Test standalone
log = SimpleLog.new("testlog")
puts log.get_timestamp()

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

log.set_xy(x, y, "XY")
log.append_xy( x, y,"XY", {"chart_type" => "ColumnChart"})
log.set_points(points, "POINTS", {"chart_type" => "PieChart"})
log.set_hash(hash, "Hash", {"chart_type" => "AreaChart"})
log.append_points(points)
log.append_hash( {0 => 1, 1 => 3, 3 => 7}, "XY")
log.annotate("Should be Hash")
log.annotate("Should be XY", "XY")
log.save()

log = SimpleLog.new("histtest")
points = []
100.times do |index|
	points << [index, Random.rand]
end
log.set_points(points, "Stats", {'histogram'=>true, 'ymin'=>0, 'ymax' => 1})
log.save()

data = TestData.new
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
log_plugin = SimpleLog.new("outputtest")
output_engine.add_plugin(log_plugin)

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