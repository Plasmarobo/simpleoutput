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

class SimpleHTML < SimpleOutput::SimpleOutputPlugin

  require 'json'
  require 'gnuplot'

  def initialize(filename="results.html", title="HTML Results Page", javascript_path="../include")
    @filename = filename
    @html = "<html>\n<title>\n#{title}\n</title>\n"
    @chart_block = []
    @chart_names = {}
    @chart_id = 0
    @js_block = ""
    chartkick_path = javascript_path + ((javascript_path[-1] == "/") ? "chartkick.js" : "/chartkick.js"); 
    @html += "<script src='http://www.google.com/jsapi'></script>\n
                <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js'></script>
                <script src='#{chartkick_path}'></script>\n<body>\n"
  end

  def addDataSet(name=nil, data=[], options={})
    if name != nil
      self.div "<h1>#{name}</h1>"
    end
    if options.has_key?("chart_type")
      chart_div(options["chart_type"], data, name)
    else
      linechart(data)
    end
  end

  def annotate(annotation, name=nil)
    self.p(annotation, name)
  end

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

  def chart_div(type, data, name=nil)
    if data.class == Array
      if(data[0].class != Array)
        data.each_with_index {|point,i| data[i] = [i,point]}
      end
      if(data[0].size > 2)
        data.each_with_index {|point,i| data[i] = [point[0], point[1]]}
      elsif(data[0].size < 2)
        data.each_with_index {|point,i| data[i] = [i,point]}
      end
    end
    @chart_id = @chart_id + 1
    if name != nil
      @chart_names[name] = @chart_id
    end
    self.write_html("<div id='chart-#{@chart_id}' style='height:400px;'></div>\n", @chart_id);
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

  def save
    @chart_block.each {|chart_html| @html += chart_html}
    @html += "<script>$(function (){#{@js_block}});</script></body></html>"
    File.open(@filename, "w") do |file|
      file.syswrite(@html)
    end
  end

end
