# frozen_string_literal: true

module Cybele
  RAILS_VERSION = ['~> 5.2.2', '>= 5.2.2'].freeze
  RUBY_VERSION = IO.read("#{File.dirname(__FILE__)}/../../.ruby-version").strip
  VERSION = '2.1.0'
end
