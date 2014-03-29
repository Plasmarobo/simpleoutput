require '../lib/simpleoutput.rb'
require '../lib/simpleplot.rb'
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
plot_plugin = SimplePlot.new("_output")
output_engine.addPlugin(plot_plugin)

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

output_engine.setArray(gaussX, "GaussX", {"histogram" => true, 'ymin' => 0, 'ymax' => 1})


output_engine.setXY(gaussY, gaussX, "XY2")

output_engine.setArray(gaussY, "GaussY2")

output_engine.save()