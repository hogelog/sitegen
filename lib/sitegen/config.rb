module Sitegen
  class Config
    attr_reader :source_dir, :build_dir, :tmp_dir, :debug

    def initialize(options={})
      @source_dir = options[:source_dir] || "source"
      @build_dir = options[:build_dir] || "build"
      @tmp_dir = options[:tmp_dir] || "tmp"
      @debug = options[:debug]
    end
  end
end
