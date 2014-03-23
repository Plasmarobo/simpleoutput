require './test_data.rb'
require '../lib/simpleoutput.rb'
require '../lib/simpleplot.rb'

#Test standalone
plot = SimplePlot.new
data = []
10.times do |index|
  data << ["My: #{index}", index]
end
plot.addDataSet("String_index", data)
plot.annotate("Comment", "String index", {'xlabel' => 'X units'})
data = []
10.times do |index|
  data << [index, index*Random.rand]
end
plot.addDataSet("Int_index", data)
data = []
subset = []
10.times do |x|
  subset << [x, 10*x]
end
data << subset
subset = []
10.times do |y|
  subset << [y, -10*y]
end
data << subset
plot.addDataSet("Multiseries", data)
plot.annotate(options={'title' => ['X data', 'Y data']})
data = {}
10.times do |index|
  data[index] = index+5
end
plot.addDataSet("Hash", data)
plot.annotate(options={'xrange' => '[-10,10]'})
plot.save()


data = TestData.new
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
plot_plugin = SimplePlot.new("_out_engine")
output_engine.addPlugin(plot_plugin)
output_engine.addDataSet("Array", data.array_data)
output_engine.addDataSet("Hash", data.hash_data)
output_engine.annotate("This is a hash", "Hash")
output_engine.annotate("This is an array", "Array")
output_engine.annotate("This should be hash", "Hash")
output_engine.addDataSet("Junk", data.array_data, {"xrange" => "[0, 100]", "confidence" => "high","chart_type" => "PieChart"})
output_engine.save()