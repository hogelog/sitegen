require "pathname"
require "logger"

require "tilt"
require "erb"
require "haml"

module Sitegen
  class Generator
    TILT_EXTS = %w(.haml .erb)

    attr_reader :config, :parcel

    def initialize(config)
      @config = config
      @parcel = Sitegen::Parcel.new(out_dir: config.build_dir.to_s)
    end

    def build
      build_dir = Pathname.new(config.build_dir)
      source_dir = Pathname.new(config.source_dir)
      tmp_dir = Pathname.new(config.tmp_dir)

      parcel_files = []

      source_files.each do |source_file|
        next if source_file.directory?

        source_name = source_file.relative_path_from(source_dir)
        build_file = tmp_dir.join(source_name)
        build_file.parent.mkpath
        extname = source_file.extname
        if TILT_EXTS.include?(extname)
          out_file = tmp_dir.join(build_file.basename(extname))
          render_tilt(source_file, out_file)
        else
          out_file = build_file
          FileUtils.copy(source_file.to_s, build_file.to_s)
          logger.debug("Copy: #{build_file.to_s}") if config.debug
        end

        if parcel.entry_file?(out_file)
          parcel_files << out_file.to_s
        else
          copy_to = build_dir.join(source_name)
          copy_to.parent.mkpath
          FileUtils.copy(out_file, copy_to.to_s)
          logger.debug(copy_to)
        end
      end

      parcel.build(parcel_files)
    end

    def source_files
      Pathname.glob("#{config.source_dir}/**/*")
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def logger=(logger)
      @logger = logger
    end

    private

    def render_tilt(source_file, build_file)
      template = Tilt.new(source_file.to_s)
      build_file.binwrite(template.render)
      logger.debug("Render: #{build_file.to_s}") if config.debug
    end
  end
end
