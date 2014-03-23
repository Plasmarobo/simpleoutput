=begin
SimpleOutput

Copyright 2014 Austen Higgins-Cassidy

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
=end

class SimpleChartkick < SimpleOutput::SimpleOutputPlugin

  require 'json'

  def initialize(filename="results.html", title="HTML Results Page", javascript_path="../include")
    super()
    @filename = filename
    @title = title
    @javascript_path = javascript_path
  end

  #Rendering Functions functions
  def write_html(content, index)
    if(index != nil)
      if @chart_block[index] == nil
        @chart_block[index] = content
      else
        @chart_block[index] += content
      end
    else
      @html += content
    end
  end

  def div(content, name = nil)
     if name == nil
      index = @chart_id
    else
      index = @chart_names[name]
    end
    self.write_html("<div>#{content}</div>\n", index)
  end

  def p(content, name = nil)
     if name == nil
      index = @chart_id
    else
      index = @chart_names[name]
    end
    self.write_html("<p>#{content}</p>\n", index)
  end

  def chart_div(data, type="LineChart", name=nil)
    #Convert data to pairs
    @chart_id = @chart_id + 1
    if name != nil
      self.div("<h1>#{name}</h1>")
    end
    self.write_html("<div id='chart-#{@chart_id}' style='height:450px;'></div>\n", @chart_id);
    @js_block += "new Chartkick.#{type}('chart-#{@chart_id}'," + data.to_json + ", {'format':'string'});\n"
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

 
  def annotate(annotation, name=nil)
    self.p(annotation, name)
  end

  def save
    html = "<html>\n<title>\n#{@title}\n</title>\n"
    chart_id = 0
    js_block = ""
    chartkick_path = @javascript_path + ((@javascript_path[-1] == "/") ? "chartkick.js" : "/chartkick.js"); 
    html += "<script src='http://www.google.com/jsapi'></script>\n
                <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js'></script>
                <script src='#{chartkick_path}'></script>\n<body>\n"
    self.getSeriesHashes.each do |chart_name, chart_series|
      self.chart_div(chart_name, chart_series)
    end
    @html += "<script>$(function (){#{@js_block}});</script></body></html>"
    File.open(@filename, "w") do |file|
      file.syswrite(@html)
    end
  end

end
