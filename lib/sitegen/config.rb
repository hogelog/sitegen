module Sitegen
  class Config
    attr_reader :source_dir, :build_dir

    def initialize(options={})
      @source_dir = options[:source_dir] || "source"
      @build_dir = options[:build_dir] || "build"
    end
  end
end
