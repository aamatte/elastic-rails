$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'active_support/all'
require 'elastic'
require 'fileutils'

SPEC_SUPPORT_PATH = File.expand_path("../support", __FILE__)
SPEC_TMP_PATH = File.expand_path("../tmp", __FILE__)

Dir[File.join(SPEC_SUPPORT_PATH, "/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.after do
    FileUtils.rm_r Dir.glob File.join(SPEC_TMP_PATH, '*.*')
  end
end