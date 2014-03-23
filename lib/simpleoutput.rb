=begin

SimpleOutput Module
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
         @data = {}
         @width = 10

      end

      def addDataSet(name="My Set", data=[])
         @last_set = name
         @data[name] = data
      end

      def annotate(annotation, name=nil, options = {})
         if name == nil
            name = @last_set
         end
         @annotations[name] << annotation
      end

      def save()
         @data.each do |name, value|
            puts name
            annotation = ""
            @annotations[name].each do |annotation|
               annotation += annotation + "|"
            end
            puts annotation
            puts "   " + value
         end
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

      def addDataSet(name=nil, data=[], options = {})
         @data_id = @data_id + 1
         if name == nil
            name = "DataSet#{@data_id}"
         end
         @plugins.each {|plugin| plugin.addDataSet(name, data, options)}
      end

      def annotate(annotation, name=nil)
         @plugins.each {|plugin| plugin.annotate(annotation, name)}
      end

      def save()
         @plugins.each {|plugin| plugin.save()}
      end

   end


end