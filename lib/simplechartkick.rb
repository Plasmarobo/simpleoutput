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

  def initialize(filename="results.html", title="Html Results Page", javascript_path="../include")
    super()
    @filename = filename
    @chart_type = {}
    chartkick_path = javascript_path + ((javascript_path[-1] == "/") ? "chartkick.js" : "/chartkick.js"); 
    @html = "<html>\n<title>\n#{title}\n</title>\n<script src='http://www.google.com/jsapi'></script>\n
                <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js'></script>
                <script src='#{chartkick_path}'></script>\n<body>\n"
    
  end

  def options_callback(options)
    if options.has_key?("chart_type")
      @chart_type[@current_name] = options['chart_type']
    end
  end 

  #Rendering Functions functions
  def write_html(content, index)
    @html += content
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

   def getMultiSeriesHashes
      data_hash = {}
      
        @x.each_pair do |(key, x_series)|
          data_hash[key] = []
          y_series = @y[key]
          x_series.each_with_index do |x_data, index|
               
             y_data = y_series[index]
             series_key = @series_names[key][index]
             data_hash[key] << {'name' => series_key}
             data_hash[key].last['data'] = {}
             x_data.each_with_index do |x_point, index|
                y_point = y_data[index]
                data_hash[key].last['data'][x_point] = y_point
             end
          end
       end
       return data_hash
    end

  def save
    @chart_id = 0
    @js_block = ""
    
    self.getMultiSeriesHashes.each_pair do |(chart_name, chart_series)|
      type = @chart_type.has_key?(chart_name) ? @chart_type[chart_name] : "LineChart" 
      if type == "PieChart"
        chart_series = chart_series[0]['data']
      end
      self.chart_div(chart_series, type, chart_name)
      if @annotations.has_key?(chart_name)
        @annotations[chart_name].each {|content| self.p(content)}
      end
    end
    @html += "<script>$(function (){#{@js_block}});</script></body></html>"
    File.open(@filename, "w") do |file|
      file.syswrite(@html)
    end
  end

end
