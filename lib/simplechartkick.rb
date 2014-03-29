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
    @metadata = {}
    chartkick_path = javascript_path + ((javascript_path[-1] == "/") ? "chartkick.js" : "/chartkick.js"); 
    @html = "<html>\n<title>\n#{title}\n</title>\n<script src='http://www.google.com/jsapi'></script>\n
                <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js'></script>
                <script src='#{chartkick_path}'></script>\n<body>\n"
    
  end
  def new_data_callback(name)
    @metadata[name] = {'chart_type' => 'LineChart', 'bincount' => 10}
  end

  def options_callback(options)
    if options.has_key?("chart_type")
      @metadata[@current_name]['chart_type'] = options['chart_type']
    end
    if options.has_key?('histogram')
      if options['histogram']
        @metadata[@current_name]['chart_type'] = 'Histogram'
      end
    end
    if options.has_key?('bincount')
      @metadata[@current_name]['bincount'] = options['bincount']
    end
    if options.has_key?('ymin')
      @metadata[@current_name]['ymin'] = options['ymin']
    end
    if options.has_key?('ymax')
      @metadata[@current_name]['ymax'] = options['ymax']
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
      if !@metadata.has_key?(chart_name)
        @metadata[chart_name] = {'chart_type' => 'LineChart', 'bincount' => 10}
      end
      type = @metadata[chart_name].has_key?('chart_type') ? @metadata[chart_name]['chart_type'] : 'LineChart' 
      if type == "PieChart"
        chart_series = chart_series[0]['data']
      elsif type == "Histogram"
        type = 'ColumnChart'
        bins =  @metadata[chart_name]['bincount']
        #Reorder data
        chart_series.each do |series|
          name = series['name']
          series_data = series['data']
          
          hist_data = {}
          ypoints = []
          
          series_data.each_pair do |(x, y)|
            ypoints << y
          end
          min = @metadata[chart_name].has_key?('ymin') ? @metadata[chart_name]['ymin'] : ypoints.min
          max = @metadata[chart_name].has_key?('ymax') ? @metadata[chart_name]['ymax'] : ypoints.max
          width = (max.to_f-min.to_f)/bins.to_f
          bins.times do |i| 
            index = (width*i).round(2)
            hist_data[index] = 0
            ypoints.delete_if do |value|
              if value >= width*i && value < width*(i+1)
                hist_data[index] += 1
                true
              else
                false
              end
            end
          end
          series['data'] = hist_data 
        end
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
