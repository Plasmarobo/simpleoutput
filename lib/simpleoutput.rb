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
  



module SimpleOutput
   class SimpleOutputPlugin

      def initialize()
         @x = {}
         @y = {}
         @series_names = {}
         @data_id = 0
         @annotations = {}
         @current_name = "NameError"
         @series_id = 0
         @metadata = {}
      end
      #Virtual Functions
      def options_callback(options)
      end 

      def set_x_callback(data, name, options)
      end

      def set_y_callback(data, name, options)
      end

      def append_callback(x,y,name,options)
      end

      def new_data_callback(name)
      end

      #CORE functions
      def translate_name(name)
         if name == nil
            name = @current_name
         end
         return name
      end

      def advance_series(name=nil)
         @series_id  += 1
         @current_name = name == nil ? "series-#{@series_id}" : name
         self.new_data_callback(name)
         if !@series_names.has_key?(@current_name)
            @series_names[@current_name] = []
         end
         @annotations[@current_name] = []
         @current_name
      end

      def append_series_name(name=nil, options={})
         name = translate_name(name)
         if !@series_names.has_key?(name)
            @series_names[name] = []
         end
         if options.has_key?('series')
            @series_names[name] << options['series']
         else
            @series_names[name] << "data-#{@data_id}"
            @data_id += 1
         end
      end

      def new_data_check(name=nil)
         (!@x.has_key?(name)) || (!@y.has_key?(name)) 
      end

      def setXData(data, name, options={})
        @x[name] = []
        @x[name] << data
        self.set_x_callback(data, name, options)
      end

      def setYData(data, name, options={})
         @y[name] = []
         @y[name] << data
         self.set_y_callback(data, name, options)
      end

      def newData( x=[], y=[],name=nil, options={})
         name = self.advance_series(name)
         self.setXData(x, name, options)
         self.setYData(y, name, options)
         self.append_series_name(name,options)
         self.options_callback(options)
      end

      #Interface Functions ===================================
      def appendXY( x=[], y=[],name=nil, options={})
         name = translate_name(name)
         if !self.new_data_check(name)
            @x[name] << x
            @y[name] << y
            self.append_series_name(name, options)
            self.options_callback(options)
            self.append_callback(x,y,name,options)
         else
            self.newData(x,y,name,options)
         end
      end

      def setXY(x=[], y=[], name=nil, options={})
         self.newData(x,y,name,options)
      end

      def appendPoints(points =[], name=nil, options={})
         x = []
         y = []
         points.each do |point|
            x << point[0]
            y << point[1]
         end
         self.appendXY(x,y,name,options)
      end

      def setPoints(points = [], name=nil, options={})
         x = []
         y = []
         points.each do |point|
            x << point[0]
            y << point[1]
         end
         self.setXY(x,y,name, options)
      end

      def appendHash(hash = {}, name=nil, options={})
         name = translate_name(name)
         x = []
         y = []
         hash.each_with_index do |(key, value), index|
            if key.is_a? Numeric
               x << key
            else
               x << index
            end
            if value.is_a? Numeric
               y << value
            else
               y << 0
            end
         end
         self.appendXY(x,y,name,options)
      end

      def setHash(hash ={}, name=nil, options={})
         x = []
         y = []
         hash.each_with_index do |(key, value), index|
            if key.is_a? Numeric
               x << key
            else
               x << index
            end
            if value.is_a? Numeric
               y << value
            else
               y << 0
            end
         end
         self.setXY(x,y,name,options)
      end

      def annotate(annotation, name=nil, options = {})
         name = translate_name(name)
         @annotations[name] << annotation
         self.options_callback(options)
      end

      def setOptions(name=nil, options = {})
         self.options_callback(options)
      end

      #Internal Helpers
      def getDataAsPoints
         series_data = {}
         @x.each_pair do |(key, x_series)|
            #For each series of data
            y_series = @y[key]
            series_data[key] = []

            x_series.each_with_index do |x_line, index|
               #For each line
               series_data[key] << [] #Create an empty set
               y_line = y_series[index]
               x_line.each_with_index do |x_point, index|
                  y_point = y_line[index]
                  series_data[key].last << [x_point, y_point]
               end
            end
         end
         return series_data    
      end

      def getDataAsXY
         series_data = {}
         @x.each_pair do |(key, x_series)|
            y_series = @y[key]
            series_data[key] = []
            x_series.each_with_index do |x_line, index|
               y_line = y_series[index]
               series_data[key] << [x_line, y_line]
            end
         end
         return series_data
      end

      def getSeriesHashes
         data_hash = {}
        
         @x.each_pair do |(key, x_series)|
            
            data_hash[key] = {}
            y_series = @y[key]
            x_series.each_with_index do |x_data, index|
               
               y_data = y_series[index]
               series_key = @series_names[key][index]
               data_hash[key][series_key] = {}
               x_data.each_with_index do |x_point, index|
                  y_point = y_data[index]
                  data_hash[key][series_key][x_point] = y_point
               end
            end
         end
         return data_hash
      end

      #Output
      def save()
        
      end

   end

   class SimpleOutputEngine

      def initialize()
         @plugins = []
         @data_id = 0
      end

      def addPlugin(plugin)
         @plugins << plugin
      end

      #Accept either [[x,y],[x,y]]
      #Hash [name] = y
      # array [x,y ]
      #Interface Functions
      def appendXY( x=[], y=[],name=nil, options={})
         @plugins.each {|plugin| plugin.appendXY(x.clone,y.clone,name, options)}
      end

      def appendXYarray(data=[], name=nil, options={})
         @plugins.each {|plugin| plugin.appendXY(data[0].clone,data[1].clone,name, options)}
      end

      def setXYarray(data = [], name=nil, options={})
         @plugins.each {|plugin| plugin.setXY(data[0].clone,data[1].clone, name, options)}
      end

      def setXY(x=[], y=[], name=nil, options={})
         @plugins.each {|plugin| plugin.setXY(x.clone,y.clone,name, options)}
      end

      def appendPoints(points =[], name=nil, options={})
         @plugins.each {|plugin| plugin.appendPoints(points.clone,name, options)}
      end

      def setPoints(points = [], name=nil, options={})
         @plugins.each {|plugin| plugin.setPoints(points.clone,name, options)}
      end

      def appendHash(hash = {}, name=nil, options={})
         @plugins.each {|plugin| plugin.appendHash(hash.clone,name, options)}
      end

      def setHash(hash ={}, name=nil, options={})
         @plugins.each {|plugin| plugin.setHash(hash.clone,name, options)}
      end

      def setArray(data = [], name=nil, options={})
         x = []
         data.count.times {|i| x << i}
         y = data
         self.setXY(x,y,name,options)
      end

      def appendArray(data = [], name=nil, options={})
          x = []
         data.count.times {|i| x << i}
         y = data.clone
         self.appendXY(x,y,name,options)
      end

      def annotate(annotation, name=nil, options={})
         @plugins.each {|plugin| plugin.annotate(annotation.clone, name, options)}
      end

      def save()
         @plugins.each {|plugin| plugin.save()}
      end

   end


end