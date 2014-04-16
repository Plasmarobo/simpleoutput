require './test_data.rb'
require '../lib/simpleoutput.rb'
require '../lib/simpleplot.rb'

#Test standalone
plot = SimplePlot.new("_standalone")
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
plot.setXY(x, y, "XY", {"series" => "Zero", 'xsize' => 2024, 'ysize' => 700 })
plot.appendXY( x, y,"XY", {"series" => "One"})
plot.setPoints(points, "POINTS")
plot.setHash(hash, "Hash", {"xlabel" => 'fish'})
plot.appendPoints(points)
plot.appendHash( {0 => 1, 1 => 3, 3 => 7}, "XY", {'ylabel' => 'seals'})
plot.annotate("Should be Hash")
plot.annotate("Should be XY", "XY")
plot.save()

plot = SimplePlot.new("_histogram")
points = []
100.times do |index|
	points << [index, Random.rand]
end
plot.setPoints(points, "Stats", {'histogram'=>true, 'ymin'=>0, 'ymax' => 1})
plot.save()

data = TestData.new
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
plot_plugin = SimplePlot.new("_output")
output_engine.addPlugin(plot_plugin)

output_engine.setXYarray(data.xy_data, "XY", {"xsize" => 1024, "ysize" => 768})
output_engine.appendXY( data.array_data, data.array_data)
output_engine.appendXYarray([data.array_data, data.array_data])

output_engine.setXY(data.array_data, data.array_data, "Magic",  {'series' => 'first'})
output_engine.appendPoints(data.points_data, "Magic", {'series' => 'second'})
output_engine.setPoints(data.points_data, "NOT MAGIC")
output_engine.appendHash(data.hash_data, "Magic", {'series' => 'third'})
output_engine.setHash(data.hash_data, "mydata", {'series' => 'back'})
output_engine.setArray(data.array_data, "Another")
output_engine.appendArray(data.array_data, "Lester", {'series' => 'magnetc'})

run = 1000
gaussX = []
gaussY = []
run.times do 
	x = Random.rand
	y = Random.rand
	gaussX << x
	gaussY << y
end
output_engine.setXYarray([gaussX, gaussY], "Gauss")

output_engine.setArray(gaussY.clone, "GaussY", {"histogram" => true, 'ymin' => 0, 'ymax' => 1})

output_engine.setXY(gaussY, gaussX, "XY2", {"histogram" => true})
output_engine.setArray(gaussY, "GaussY2")

output_engine.setArray(gaussX, "GaussX", {"histogram" => true, 'ymin' => 0, 'ymax' => 1})


output_engine.save()
