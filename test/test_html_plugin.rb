require './test_data.rb'
require '../lib/simpleoutput.rb'
require '../lib/simplehtml.rb'

#Test standalone
html = SimpleHTML.new("TestStandalone.html", "Data test", "../../chartkick.js/")
html.div("Hello world")
data = []
10.times do |index|
  data << ["My: #{index}", index]
end
html.p "Barchart"
html.barchart(data)
html.div "<i>Piechart</i>"
html.piechart(data)
html.p "Linechart"
html.linechart(data)
html.div "<h2>Areachart</h2>"
html.areachart(data)
html.p "Columnchart"
html.columnchart(data)
html.save()

data = TestData.new
#Test output Engine
output_engine = SimpleOutput::SimpleOutputEngine.new
html_plugin = SimpleHTML.new("TestOutputEngine.html", "Output Engine", "../../chartkick.js")
output_engine.addPlugin(html_plugin)
output_engine.addDataSet("Array", data.array_data)
output_engine.addDataSet("Hash", data.hash_data)
output_engine.annotate("This is a hash", "Hash")
output_engine.annotate("This is an array", "Array")
output_engine.annotate("This should be hash", "Hash")
output_engine.addDataSet("PieChart", data.array_data, {"confidence" => "high","chart_type" => "PieChart"})
output_engine.save()