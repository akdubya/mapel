def Mapel(source)
  Mapel.render(source)
end

module Mapel

  # Mapel.info('image.jpg')
  def self.info(source, engine = :image_magick)
    Mapel::Engine.const_get(camelize(engine)).info(source)
  end

  # Mapel.render('image.jpg').resize("50%").to('output.jpg').run
  def self.render(source, engine = :image_magick)
    Mapel::Engine.const_get(camelize(engine)).render(source)
  end

  # Mapel.list
  def self.list(engine = :image_magick)
    Mapel::Engine.const_get(camelize(engine)).list
  end

  class Engine
    attr_reader :command, :status, :output
    attr_accessor :commands

    def initialize(source = nil)
      @source = source
      @commands = []
    end

    def success?
      @status
    end

    class ImageMagick < Engine
      def self.info(source)
        im = new(source)
        im.commands << 'identify'
        im.commands << source
        im.run.to_info_hash
      end

      def self.render(source = nil)
        im = new(source)
        im.commands << 'convert'
        im.commands << source unless source.nil?
        im
      end

      def self.list(type = nil)
        im = new
        im.commands << 'convert -list'
        im.run
      end

      def crop(*args)
        @commands << "-crop \"#{Geometry.new(*args).to_s(true)}\""
        self
      end

      def gravity(type = :center)
        @commands << "-gravity #{type}"
        self
      end

      def repage
        @commands << "+repage"
        self
      end

      def resize(*args)
        @commands << "-resize \"#{Geometry.new(*args)}\""
        self
      end

      def resize!(*args)
        width, height = Geometry.new(*args).dimensions
        resize("#{width}x#{height}^").crop(width, height).repage
      end

      def scale(*args)
        @commands << "-scale \"#{Geometry.new(*args)}\""
        self
      end

      def to(path)
        @commands << path
        self
      end

      def undo
        @commands.pop
        self
      end
      
      def run
        @output = `#{to_preview}`
        @status = ($? == 0)
        self
      end

      def to_preview
        @commands.map { |cmd| cmd.respond_to?(:call) ? cmd.call : cmd }.join(' ')
      end

      def to_info_hash
        meta = @output.split(' ')
        {
          :path       => meta[0],
          :format     => meta[1],
          :dimensions => meta[2].split('x').map {|d| d.to_i},
          :depth      => meta[4],
          :size       => meta[6]
        }
      end
    end
  end

  class Geometry
    attr_accessor :width, :height, :x, :y, :flag

    FLAGS = ['', '%', '<', '>', '!', '@', '^']

    # Regex parser for geometry strings
    RE = /\A(\d*)(?:x(\d+)?)?([-+]\d+)?([-+]\d+)?([%!<>@\^]?)\Z/

    def initialize(*args)
      if (args.length == 1) && (args.first.kind_of?(String))
        raise(ArgumentError, "Invalid geometry string") unless m = RE.match(args.first)
        args = m.to_a[1..5]
      end
      @width = args[0] ? args[0].to_i.round : 0
      @height = args[1] ? args[1].to_i.round : 0
      raise(ArgumentError, "Width must be >= 0") if @width < 0
      raise(ArgumentError, "Height must be >= 0") if @height < 0
      @x = args[2] ? args[2].to_i : 0
      @y = args[3] ? args[3].to_i : 0
      raise(ArgumentError, "Flags must be in: #{FLAGS.inspect}") if args[4] && !FLAGS.include?(args[4])
      @flag = args[4]
    end

    def dimensions
      [width, height]
    end

    # Convert object to a geometry string
    def to_s(crop = false)
      str = ''
      str << "%g" % @width if @width > 0
      str << 'x' if @height > 0
      str << "%g" % @height if @height > 0
      str << "%+d%+d" % [@x, @y] if (@x != 0 || @y != 0 || crop)
      str << @flag if @flag
      str
    end
  end

  # By default, camelize converts strings to UpperCamelCase.
  #
  # camelize will also convert '/' to '::' which is useful for converting paths to namespaces
  #
  # @example
  # "active_record".camelize #=> "ActiveRecord"
  # "active_record/errors".camelize #=> "ActiveRecord::Errors"
  #
  def self.camelize(word, *args)
    word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end
end