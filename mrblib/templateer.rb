module Templateer
  VERSION = '0.0.1'

  class EvaulationContext
    def initialize params
      @params = params
    end
  end

  class Templateer
    def initialize data_file, template_file
      @data_file = data_file
      @template_file = template_file
    end

    def process
      data = load_data(@data_file)
      template = load_template(@template_file)
      evaluate(data, template)
    end

    private

    def load_data file
      file_handle = if file == '-'
        STDIN
      else
        raise DataLoadError.new(file) unless File.exist?(file)
        File.open(file, 'rb') or raise DataLoadError.new(file)
      end

      begin
        return YAML.load(file_handle.read)
      rescue => e
        raise DataParseError.new(file, e.to_s)
      end 
    end

    def load_template file
      raise TemplateLoadError.new(file) unless File.exist?(file)
      File.read(file) or raise TemplateLoadError.new(file)
    end

    def evaluate data, template
      erb = ERB.new(template)
      context = EvaulationContext.new data
      return erb.result(context)
    end
  end

  def self.handle_error e
    STDERR.puts e.message
    exit e.code
  end
end

def main
  usage = "Usage: templateer <input.json> <template.erb>"
  Slop.parse do
    banner usage

    run do |opts, args|
      begin
        raise Templateer::InsufficientArgsError.new(usage) if args.length < 2
        t = Templateer::Templateer.new args[0], args[1]   
        puts t.process
      rescue Exception => e
        Templateer::handle_error e
      end
    end
  end
end
