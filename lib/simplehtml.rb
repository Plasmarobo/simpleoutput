module SimpleOutput

class SimpleHTML

  require 'json'
  require 'gnuplot'

  def initialize(filename="results.html", title="HTML Results Page", charts=true)
    @filename = filename
    @html = "<html>\n<title>\n#{title}\n</title>\n"
    @chart_id = 0
    @js_block = ""
    if charts
      @html += "<script src='http://www.google.com/jsapi'></script>\n
                <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js'></script>
                <script src='chartkick.js'></script>\n"
    end
    @html += "<body>\n"
  end

  def writediv(content)
    @html += "<div>#{content}</div>\n"
  end

  def writep(content)
    @html += "<p>#{content}</p>\n"
  end

  def chart_div(type, data)
    
    @html += "<div id='chart-#{@chart_id}' style='height:400px;'></div>\n"
    @js_block += "new Chartkick.#{type}('chart-#{@chart_id}'," + data.to_json + ");\n"
    @chart_id = @chart_id + 1
  end

  def linechart(data)
    #Accepts a name:value hash {"Football" => 10, "Basketball" => 5}
    #or a array of pairs [["Football", 10], ["Basketball", 5]]
    #may also nest series with a hash {:name => "Trial1", :data => trial1_data},...
    self.chart_div("LineChart",data)
  end

  def piechart(data)
    #does not accept multiple series
    self.chart_div("PieChart",data)
  end

  def columnchart(data)
   self.chart_div("ColumnChart",data)
  end

  def barchart(data)
    self.chart_div("BarChart",data)
  end

  def areachart(data)
    self.chart_div("AreaChart", data)
  end



  def save
    @html += "<script>$(function (){#{@js_block}});</script></body></html>"
    File.open(@filename, "w") do |file|
      file.syswrite(@html)
    end
  end

end

end