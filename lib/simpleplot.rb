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
    if options.has_key?('xsize')
      @metadata[@current_name]['xsize'] = options['xsize']
    end
    if options.has_key?('ysize')
      @metadata[@current_name]['ysize'] = options['ysize']
    end
    if options.has_key?('xlabel')
      @metadata[@current_name]['xlabel'] = options['xlabel']
    end
    if options.has_key?('ylabel')
      @metadata[@current_name]['ylabel'] = options['ylabel']
    end
    if options.has_key?('histogram')
      @metadata[@current_name]['histogram'] = options['histogram']
    end
    if options.has_key?('xmin')
      @metadata[@current_name]['xmin'] = options['xmin']
    end
    if options.has_key?('xmax')
      @metadata[@current_name]['xmax'] = options['xmax']
    end
    if options.has_key?('ymin')
      @metadata[@current_name]['ymin'] = options['ymin']
    end
    if options.has_key?('ymax')
      @metadata[@current_name]['ymax'] = options['ymax']
    end
    if options.has_key?('bincount')
      @metadata[@current_name]['bincount'] = options['bincount']
    end
    if options.has_key?('normalized')
      @metadata[@current_name]['normalized'] = options['normalized']
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

  def new_data_callback(name)
    name = translate_name(name)
    @metadata[name] = {'length' => 0, 'xlabel' => 'x', 'ylabel' => 'y', 'xmin' => 0 , 'xmax' => 10, 'ymin' => 0, 'ymax' => 10, 'series_titles' => [], 'histogram' => false, 'bincount' => 10, 'normalized' => false, 'xsize' => 640, 'ysize' => 480}
  end

  def set_x_callback(data, name, options)
    xmin = data.min
    xmax = data.max
    @metadata[name]['xmin'] = xmin
    @metadata[name]['xmax'] = xmax
    @metadata[name]['length'] = (@metadata[name]['length'] < data.size) ? data.size : @metadata[name]['length']
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
      new_data_callback(name)
    end
    @metadata[name]['length'] = @metadata[name]['length'] < x.size ? x.size : @metadata[name]['length']
    @metadata[name]['xmin'] = xmin < @metadata[name]['xmin'] ? xmin : @metadata[name]['xmin']
    @metadata[name]['xmax'] = xmax > @metadata[name]['xmax'] ? xmax : @metadata[name]['xmax']
    @metadata[name]['ymin'] = ymin < @metadata[name]['ymin'] ? ymin : @metadata[name]['ymin']
    @metadata[name]['ymax'] = ymax > @metadata[name]['ymax'] ? ymax : @metadata[name]['ymax']
    check_title(name, options)
    
  end

  def save()
    data = self.getDataAsXY()
    data.each do |set_name, series|
      Gnuplot.open do |gp|
        Gnuplot::Plot.new(gp) do |plot|
          plot.terminal "png size #{@metadata[set_name]['xsize']},#{@metadata[set_name]['ysize']}"
         
          plot.output "#{set_name+@name}.png"
          #plot.set('size', '{1,1}')

          plot.title set_name

          plot.xlabel @metadata[set_name]['xlabel']
          plot.ylabel @metadata[set_name]['ylabel']
          plot.data = []
          max = @metadata[set_name]['ymax']
          min = @metadata[set_name]['ymin']
          if min == max
            max = min + 1
          end
          if @metadata[set_name]['histogram']
            size = @metadata[set_name]['length']
            bins = @metadata[set_name]['bincount'] 
            width = (max.to_f-min.to_f).to_f/bins.to_f
            #bins = size.to_f/width.to_f
            plot.yrange '[0:]'
            plot.xrange "[#{min}:#{max}]"
            plot.set('boxwidth',width*0.9)
            plot.set('offset', 'graph 0.05,0.05,0.05,0.0')
            plot.set('xtics' " #{min}, #{width.to_f}, #{max}")
            plot.set('tics', 'out nomirror')
            plot.set('style', 'fill solid 0.5')
          else
            plot.xrange "[#{@metadata[set_name]['xmin']}:#{@metadata[set_name]['xmax']}]"
            plot.yrange "[#{min}:#{max}]"
          end
          series.each_with_index do |line, index|
            
            if @metadata[set_name]['histogram']
              data_pts = line[1]
            else
              data_pts = line
            end
             
            d = Gnuplot::DataSet.new(data_pts) 
            d.title = @metadata[set_name]['series_titles'][index]
           
            if @metadata[set_name]['histogram']
              d.using = "(#{width.to_f}*floor($1/#{width.to_f})+#{width.to_f}/2.0):(1.0) smooth freq w boxes lc rgb\"blue\""
            else
               d.with = "linespoints"
               d.linewidth = 2
            end
            plot.data << d
            
          end
        end
      end
    end
  end
end


      