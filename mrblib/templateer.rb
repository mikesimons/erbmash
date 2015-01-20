module Templateer
  VERSION = '0.0.1'

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
        return JSON.parse(file_handle.read)
      rescue JSON::ParserError => e
        raise DataParseError.new(file, e.to_s)
      end 
    end

    def load_template file
      raise TemplateLoadError.new(file) unless File.exist?(file)
      File.read(file) or raise TemplateLoadError.new(file)
    end

    def evaluate data, template
      merb = ::MERB.new
      merb.template = template

      evaluator = "
      class EvaluatorContext
        def __evaluate__ __merb_data__
          @params = __merb_data__
          #{merb.source}
        end
      end
      "

      begin
        eval(evaluator, nil, @template_file, 0)
        (EvaluatorContext.new).__evaluate__(data)
        return ::MERB.out
      rescue Exception => e
        raise e if e.is_a? Error
        str = e.inspect.split("\n").map do |line|
          parts = line.split(':')
          parts[1] = parts[1].to_i - 5
          parts.join(':')
        end.join("\n")
        raise TemplateError.new(str)
      end
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
