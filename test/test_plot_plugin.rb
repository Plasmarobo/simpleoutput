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
plot.set_xy(x, y, "XY", {"series" => "Zero", 'xsize' => 2024, 'ysize' => 700 })
plot.append_xy( x, y,"XY", {"series" => "One"})
plot.set_points(points, "POINTS")
plot.set_hash(hash, "Hash", {"xlabel" => 'fish'})
plot.append_points(points)
plot.append_hash( {0 => 1, 1 => 3, 3 => 7}, "XY", {'ylabel' => 'seals'})
plot.annotate("Should be Hash")
plot.annotate("Should be XY", "XY")
plot.save()

plot = SimplePlot.new("_histogram")
points = []
100.times do |index|
	points << [index, Random.rand]
end
plot.set_points(points, "Stats", {'histogram'=>true, 'ymin'=>0, 'ymax' => 1})
plot.save()

data = TestData.new
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
plot_plugin = SimplePlot.new("_output")
output_engine.add_plugin(plot_plugin)

output_engine.set_xy_array(data.xy_data, "XY", {"xsize" => 1024, "ysize" => 768})
output_engine.append_xy( data.array_data, data.array_data)
output_engine.append_xy_array([data.array_data, data.array_data])

output_engine.set_xy(data.array_data, data.array_data, "Magic",  {'series' => 'first'})
output_engine.append_points(data.points_data, "Magic", {'series' => 'second'})
output_engine.set_points(data.points_data, "NOT MAGIC")
output_engine.append_hash(data.hash_data, "Magic", {'series' => 'third'})
output_engine.set_hash(data.hash_data, "mydata", {'series' => 'back'})
output_engine.set_array(data.array_data, "Another")
output_engine.append_array(data.array_data, "Lester", {'series' => 'magnetc'})

run = 1000
gaussX = []
gaussY = []
zeros = []
run.times do 
	x = Random.rand
	y = Random.rand
	gaussX << x
	gaussY << y
	zeros << 0
end
output_engine.set_xy_array([gaussX, gaussY], "Gauss")

output_engine.set_array(gaussY.clone, "GaussY", {"histogram" => true, 'ymin' => 0, 'ymax' => 1})

output_engine.set_xy(gaussY, gaussX, "XY2", {"histogram" => true})
output_engine.set_array(gaussY, "GaussY2")

output_engine.set_array(gaussX, "GaussX", {"xsize" => 1000, "ysize" => 1000, "histogram" => true, 'ymin' => 0, 'ymax' => 1})
output_engine.set_array(zeros.clone, "Zero Test", {"xsize" => 1000, "ysize" => 1000, "histogram" => true})
output_engine.set_array(zeros.clone, "Zero Test2", {"xsize" => 1000, "ysize" => 1000})
output_engine.save()
