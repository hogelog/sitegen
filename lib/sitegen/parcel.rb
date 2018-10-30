require "open3"

module Sitegen
  class Parcel
    class BuildError < StandardError; end

    attr_reader :out_dir

    def initialize(out_dir:)
      @out_dir = out_dir
    end

    def build(source_files)
      unless system("parcel", "build", "-d", out_dir, *source_files)
        raise BuildError
      end
    end

    def entry_file?(source_file)
      source_file.extname == ".html"
    end
  end
end
