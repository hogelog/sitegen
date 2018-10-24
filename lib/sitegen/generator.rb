require "pathname"
require "tilt"
require "erb"
require "haml"

module Sitegen
  class Generator
    TILT_EXTS = %w(.haml .erb)

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def build
      build_dir = Pathname.new(config.build_dir)
      source_dir = Pathname.new(config.source_dir)

      source_files.each do |source_file|
        next if source_file.directory?

        build_file = build_dir.join(source_file.relative_path_from(source_dir))
        build_file.parent.mkpath
        extname = source_file.extname
        if TILT_EXTS.include?(extname)
          render_tilt(source_file, build_dir.join(build_file.basename(extname)))
        else
          FileUtils.copy(source_file.to_s, build_file.to_s)
        end
      end
    end

    def source_files
      Pathname.glob("#{config.source_dir}/**/*")
    end

    private

    def render_tilt(source_file, build_file)
      template = Tilt.new(source_file.to_s)
      build_file.binwrite(template.render)
    end
  end
end
