# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('.', __dir__)

require 'minitest/autorun'
require 'idkollen/client'
require 'mock_adapter'
