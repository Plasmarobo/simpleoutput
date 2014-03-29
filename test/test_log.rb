require './test_data.rb'
require '../lib/simpleoutput.rb'
require '../lib/simplelog.rb'

#Test standalone
log = SimpleLog.new("testlog")
puts log.getTimestamp()

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

log.setXY(x, y, "XY")
log.appendXY( x, y,"XY", {"chart_type" => "ColumnChart"})
log.setPoints(points, "POINTS", {"chart_type" => "PieChart"})
log.setHash(hash, "Hash", {"chart_type" => "AreaChart"})
log.appendPoints(points)
log.appendHash( {0 => 1, 1 => 3, 3 => 7}, "XY")
log.annotate("Should be Hash")
log.annotate("Should be XY", "XY")
log.save()

log = SimpleLog.new("histtest")
points = []
100.times do |index|
	points << [index, Random.rand]
end
log.setPoints(points, "Stats", {'histogram'=>true, 'ymin'=>0, 'ymax' => 1})
log.save()

data = TestData.new
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
log_plugin = SimpleLog.new("outputtest")
output_engine.addPlugin(log_plugin)

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