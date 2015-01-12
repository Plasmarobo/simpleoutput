=begin
SimpleCSV
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
require 'csv'

class SimpleCSV < SimpleOutput::SimpleOutputPlugin

   def initialize(file_template)
      super()
      @filename = file_template
      @series_next = 0
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
      @metadata[name]['series_titles'] << "#{@metadata[name]['ylabel']}#{@series_next}"
      @series_next += 1
    end
  end

  def set_x_callback(data, name, options)
    check_title(name, options)
  end

  def new_data_callback(name)
    name = translate_name(name)
    @metadata[name] = {'xlabel' => "#{name}_x", 'ylabel' => "#{name}_y", 'series_titles' => []}
  end

  def append_callback(x,y,name,options)
    if !@metadata.has_key?(name)
      new_data_callback(name)
    end
  end

  def save()
    data = self.get_data_as_xy()
    data.each do |set_name, series|
      CSV.open("#{@filename}_#{set_name}.csv", "wb") do |csv|
        xlabel = @metadata[set_name]['xlabel']
        
        series.each_with_index do |values, i|
          values[0].unshift(xlabel)
          csv << values[0]
          ylabel = @metadata[set_name]['series_titles'].empty? ? @metadata[set_name]['ylabel'] : @metadata[set_name]['series_titles'][i] 
          values[1].unshift(ylabel)
          csv << values[1]
        end
      end
    end
  end

end