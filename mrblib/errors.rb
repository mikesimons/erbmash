module Templateer
  class Error < Exception
    attr_accessor :message, :code
    def initialize handle, code
      @data ||= []
      @message = sprintf(_(handle), *@data)
      @code = code
    end
  end

  class NoArgsError < Error
    def initialize
      super :usage, 0
    end
  end

  class InsufficientArgsError < Error
    def initialize usage
      @data = [ usage ]
      super :insufficient_args_error, 1
    end
  end

  class TemplateLoadError < Error
    def initialize file
      @data = [ file ]
      super :template_load_error, 2
    end
  end

  class DataLoadError < Error
    def initialize file
      @data = [ file ]
      super :data_load_error, 3
    end
  end

  class DataParseError < Error
    def initialize file, error
      @data = [ file, error ]
      super :data_parse_error, 4
    end
  end

  class TemplateError < Error
    def initialize error
      @data = [ error ]
      super :template_error, 5
    end
  end
 
  class ReservedKeyError < Error
    def initialize keys
      @data = [ keys ]
      super :reserved_key_error, 6
    end
  end
end
