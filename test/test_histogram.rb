require '../lib/simpleoutput.rb'
require '../lib/simpleplot.rb'
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
plot_plugin = SimplePlot.new("_output")
output_engine.add_plugin(plot_plugin)

run = 1000
gaussX = []
gaussY = []
run.times do 
	x = Random.rand
	y = Random.rand
	gaussX << x
	gaussY << y
end

output_engine.set_xy_array([gaussX, gaussY], "Gauss")

output_engine.set_array(gaussY.clone, "GaussY", {"histogram" => true, 'ymin' => 0, 'ymax' => 1})

output_engine.set_array(gaussX, "GaussX", {"histogram" => true, 'ymin' => 0, 'ymax' => 1})


output_engine.set_xy(gaussY, gaussX, "XY2")

output_engine.set_array(gaussY, "GaussY2")

output_engine.save()