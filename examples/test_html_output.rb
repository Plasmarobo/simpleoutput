require './simplehtml.rb'

html = SimpleHTML.new("Test.html", "Data test", true)
html.writediv("Hello world")
data = []
10.times do |index|
  data << ["My: #{index}", index]
end
html.barchart(data)
html.piechart(data)
html.linechart(data)
html.save()

