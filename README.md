SimpleOutput
============

A simple output/plotting library for Ruby
Released with Apache 2.0 License

![alt tag](https://raw.github.com/Plasmarobo/simpleoutput/splash.png)

## SimpleOutput::SimpleOutputEngine
The output engine provides an aggrigating interface for output plugins.
With one data set and one interface you can produce a number of different reports, graphs, and data files.
It makes it easy to swap plugins in and out, getting your raw data into more human formats.

The Output Engine is instanced so:
```ruby
output_engine = SimpleOutput::SimpleOutputEngine.new
#Let's load the chartkick plugin as an exmple
chartkick_plugin = SimpleChartkick.new("MyFile.html", "Test_Title", "/path/to/chartkick.js")
output_engine.add_plugin(chartkick_plugin)
```
We register any plugins we want to use. A plugin represents an output format. The OutputEngine by itself merely provides an interface to one or more plugins. 
Now any operations performed via the output engine will be echoed to the Chartkick plugin. The output engine does a bit of pre-processing. To include some data for output, we must name the set of data. We can make a call like so:

```ruby
data = []
100.times {|x| data << [x, Random.rand]}
output_engine.set_points(data, "Random Data")
```

set_points is one of several data formats. It takes an array of two arrays. The first array is a series of x values (should be scalar/numerical), and the second is a series of y values (again, scalar/numerical). Plugins may support additional formats, but they all must support x/y data. 

The set* functions create a new chart or 'data object'. The append* functions add data to an existing chart. Most plugins accept the 'series' option to allow naming individual lines within a plot. 

The Output Engine supports the following append and set commands
```ruby
append_xy( x=[x1, x2, x3...], y=[y1, y2, y3...],name=nil, options={})
set_xy(x=[x1, x2, x3...], y=[y1, y2, y3...], name=nil, options={})
append_points(points =[[x1,x2,x3...],[y1,y2,y3...]], name=nil, options={})
set_points(points = [[x1,x2,x3...],[y1,y2,y3...]], name=nil, options={})
append_hash(hash = {x1=>y1, x2=>y2}, name=nil, options={})
set_hash(hash ={x1=>y1, x2=>y2}, name=nil, options={})
append_xy_array(data=[], name=nil, options={}) #Note: uses array index as X value
set_xy_array(data=[], name=nil, options={}) #Note: uses array index as X value
```

The optional options parameter accepts the `{'series' => 'name'}` option for most plugins. Additionally metadata can be added to a trend or chart by using the `annotate(annotation, name=nil, options = {})` function. This is defined per-plugin and may have very different behavor, or my simply be ignored. 

## Default Plugins
### SimpleChartkick (output filename, title, path to chartkick.js)
A simple built in html/chartting plugin. Accepts `'chart_type'` as an options with the following values:
```ruby
"PieChart" #Does NOT support series
"LineChart"
"AreaChart"
"ColumnChart"
"BarChart"
'histogram' => true/false
'bincount' => 10  #Automatically determines width
'ymin' => 0 #Only for histograms, sets min-bin
'ymax' => 0 #Only for histograms, set max-bin
'series_name' => 'Text'
```
The annotate function inserts paragraphs below a chart.
Chartkick depends on a MODIFIED version of chartkick.js that is included with the gem. 

### SimplePlot (output suffix)
An interface to Gnuplot (unix/cygwin only). Untested Windows support for Gnuplot. If there is a good port available, it's possible this could work. 
Gnuplot accepts the following options:
```ruby
'xsize' => pixel count
'ysize' => pixel count
'xlabel' => 'Text'
'ylabel' => 'Text'
'histogram' => true/false
'bincount' => 10 #Sets the number of bins, auto-sized
'ymin' => 0  #Note: sets the min bin for histograms
'ymax' => 0  #Note: sets the max bin for histograms
'xmax' => 0
'xmin' => 0
'series_name' => 'Text'
```
Max and Min values are automatically set by your data. 

### SimpleLog (output suffix, output format [.txt])
A simple txt logging tool. Provides timestamped events and name tracing. Will traverse and print arrays and hashes. Will attempt to print values using to_s if they are not a string or numeric. 
Simplelog ignores options

### SimpleCSV (output prefix)
A simple tool to render data into csv. Uses Header-column convention, and renders x rows and y rows of data. More options to come in future. 
SimpleCSV accepts the following options:
```ruby
'xlabel' => 'Text'
'ylabel' => 'Text' #Used if series_name not present
'series_name' => 'Text'
```

# Developing Plugins
Plugins should inherit from the SimpleOutputPlugin class, which provides the following interface and callback functions:
```ruby
class SimpleOutputPlugin

      def initialize()
         @x = {} #Scalar x-data vector
         @y = {} #Scalar y-data vector
         @series_names = {} #Hash containing names of series/lines for a dataset
         @data_id = 0 #Internal default naming counter
         @annotations = {} #Hash containing annotations for a dataset
         @current_name = "" #The current dataset key
         @series_id = 0 #Internal default naming counter
      end

      #Virtual Functions (Optional)

      def options_callback(options)
        #Called at the end of any function which accepts options
      end 

      def set_x_callback(data, name, options)
        #Called at the end of any function which sets X data
      end

      def set_y_callback(data, name, options)
        #Called at the end of any function which sets Y data
      end

      def append_callback(x,y,name,options)
        #Called at the end of any function which appends data
      end

      def new_data_callback(name)
        #Called when a new chart or dataset is created 
      end

      #Virtual Functions (Required)
      def save()
        #Physcally writes data to disk or other interface
      end

      #Interface Functions ===================================
      def append_xy( x=[], y=[],name=nil, options={})
         name = translate_name(name)
         @x[name] << x
         @y[name] << y
         self.append_series_name(name, options)
         self.options_callback(options)
         self.append_callback(x,y,name,options)
      end

      def set_xy(x=[], y=[], name=nil, options={})
         self.new_data(x,y,name,options)
      end

      def append_points(points =[], name=nil, options={})
         x = []
         y = []
         points.each do |point|
            x << point[0]
            y << point[1]
         end
         self.append_xy(x,y,name,options)
      end

      def set_points(points = [], name=nil, options={})
         x = []
         y = []
         points.each do |point|
            x << point[0]
            y << point[1]
         end
         self.set_xy(x,y,name, options)
      end

      def append_hash(hash = {}, name=nil, options={})
         name = translate_name(name)
         x, y = self.hash_to_xy(hash)
         self.append_xy(x,y,name,options)
      end

      def set_hash(hash ={}, name=nil, options={})
         x, y = self.hash_to_xy(hash)
         self.set_xy(x,y,name,options)
      end

      def annotate(annotation, name=nil, options = {})
         name = translate_name(name)
         @annotations[name] << annotation
         self.options_callback(options)
      end

      #Internal Helpers
      def get_data_as_points
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

      def get_data_as_xy
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

      def get_series_hashes
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

      private
      def hash_to_xy(hash)
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
         return x, y
      end
   end
   ```

   An implementation of a plugin should not heavily modify the interface functions. Core functions are not included in this documentation. If you are interested in re-writing the core of a plugin I can be reached via Github. 

