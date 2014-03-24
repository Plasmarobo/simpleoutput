=begin
SimplePlot

  GnuPlot interface to simpleoutput

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
class SimplePlot < SimpleOutput::SimpleOutputPlugin
  require 'gnuplot'

  def initialize(name_template="_plot", size = 512)
     super()
     @name = name_template
     @size = size
     @series_next = 0;
     @metadata = {}
  end

  def options_callback(options)
    if options.has_key?('xlabel')
      @metadata[@current_name]['xlabel'] = options['xlabel']
    end
    if options.has_key?('ylabel')
      @metadata[@current_name]['ylabel'] = options['ylabel']
    end
  end

  def check_title(name, options)
    if options.has_key?('series')
      @metadata[name]['series_titles'] << options['series']
    else
      @metadata[name]['series_titles'] << "set-#{@series_next}"
      @series_next += 1
    end
  end

  def new_series_callback(name)
    @metadata[name] = {'xlabel' => 'x', 'ylabel' => 'y', 'xmin' => 0 , 'xmax' => 10, 'ymin' => 0, 'ymax' => 10, 'series_titles' => []}
  end

  def set_x_callback(data, name, options)
    xmin = data.min
    xmax = data.max
    @metadata[name]['xmin'] = xmin
    @metadata[name]['xmax'] = xmax
    check_title(name, options)
  end

  def set_y_callback(data, name, options)
    ymin = data.min
    ymax = data.max
    @metadata[name]['ymin'] = ymin
    @metadata[name]['ymax'] = ymax
  end

  def append_callback(x,y,name,options)
    xmin = x.min
    xmax = x.max
    ymin = y.min
    ymax = y.max
    if !@metadata.has_key?(name)
      new_series_callback(name)
    end
    @metadata[name]['xmin'] = xmin < @metadata[name]['xmin'] ? xmin : @metadata[name]['xmin']
    @metadata[name]['xmax'] = xmax > @metadata[name]['xmax'] ? xmax : @metadata[name]['xmax']
    @metadata[name]['ymin'] = ymin < @metadata[name]['ymin'] ? ymin : @metadata[name]['ymin']
    @metadata[name]['ymax'] = ymax > @metadata[name]['ymax'] ? ymax : @metadata[name]['ymax']
    check_title(name, options)
    
  end

  def save()
    data = self.getDataAsXY()
    Gnuplot.open do |gp|
      data.each do |set_name, series|
        Gnuplot::Plot.new(gp) do |plot|
          plot.terminal "png"
          #plot.size 0.95
          plot.output "#{set_name+@name}.png"

          plot.title set_name

          plot.xlabel @metadata[set_name]['xlabel']
          plot.ylabel @metadata[set_name]['ylabel']
          plot.xrange "[#{@metadata[set_name]['xmin']}:#{@metadata[set_name]['xmax']}]"
          plot.yrange "[#{@metadata[set_name]['ymin']}:#{@metadata[set_name]['ymax']}]"
          plot.data = []
          series.each_with_index do |line, index|
            d = Gnuplot::DataSet.new(line) 
            d.title = @metadata[set_name]['series_titles'][index]
            d.with = "linespoints"
            d.linewidth = 2
            plot.data << d
            
          end
        end
      end
    end
  end
end


      